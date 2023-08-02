public with sharing virtual class GNE_SFA2_PFG_Interaction_Controller extends GNE_SFA2_PFG_Base_Controller {
	private GNE_SFA2_Interaction_Controller mainController;
	
	public List<CallPfgDetailWrapper> callPfgDetails {get; private set;}
	public Map<Integer,CallPfgDetailWrapper> callPfgDetailsMap {get; private set;}
	public Boolean isCompleted {get { return mainController.isCompleted; }}
	public String rowIdx {get; set;}
	public String productId {get; set;}
	public String lotId {get; set;}
	public String productLookupWhereExpression {get; private set;}
	public String productLookupAvailableIds {get; private set;}
	public String lotCatalogLookupAvailableIds {get; private set;}
	public Boolean isDTP {get {return distributionMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;}}
	public Boolean isHC {get {return distributionMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;}}
	public Call_PFG_Detail_gne__c firstCallDetail {get; private set;}
	
	private String distributionMethod;
	private Set<Id> userDtpProductIds;
	private Set<Id> userHcProductIds;
	private Set<Id> userHcLotCatalogIds;
	private Boolean isSomethingChanged;
	private Set<Id> callDetailIdsToRemove;
	
	public GNE_SFA2_PFG_Interaction_Controller() {}
	
	public GNE_SFA2_PFG_Interaction_Controller(GNE_SFA2_Interaction_Controller a_mainController) {
		mainController = a_mainController;
	}
	
	protected override PageReference intInitCotroller() {
		callPfgDetails = new List<CallPfgDetailWrapper>();
		callPfgDetailsMap = new Map<Integer,CallPfgDetailWrapper>();
		callDetailIdsToRemove = new Set<Id>();
		
		if(!mainController.isCallInsert) {
			Integer rowIdx = 0;
			List<Call_PFG_Detail_gne__c> cDetails = GNE_SFA2_PFG_DAO.getCallDetailsByCallIds(new Set<Id>{mainController.call.Id});
			// cache lot catalogs  
			GNE_SFA2_PFG_Util.getLotCatalogList(cDetails);
			for(Call_PFG_Detail_gne__c cDetail : cDetails) {
				if(firstCallDetail==null) {
					firstCallDetail = cDetail;
				}
				CallPfgDetailWrapper wrapper = new CallPfgDetailWrapper(cDetail,rowIdx++);
				callPfgDetailsMap.put(rowIdx,wrapper);
				callPfgDetails.add(wrapper);
			}
		}
		
		setDistributionMethod();
		return null;
	}
	
	private void setDistributionMethod() {
		distributionMethod = null;
			
		for(CallPfgDetailWrapper cpdWrapper : callPfgDetails) {
			if(String.isNotBlank(cpdWrapper.record.Product_gne__c)) {
				for(String distMethod : GNE_SFA2_PFG_Util.getDistMethodsForProduct((Id)cpdWrapper.record.Product_gne__c)) {
					distributionMethod = distMethod;
					break; 
				}
				break;	
			}
		}
		
		Set<Id> userProductIds = new Set<Id>();
		Set<Id> userLotCatalogIds = new Set<Id>();
		Id userId = UserInfo.getUserId();
		if(isCs) {
			if(GNE_SFA2_PFG_Util.canCsUseHc(userId) && (String.isBlank(distributionMethod) || distributionMethod==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC)) {
				if(userHcProductIds==null) {
					userHcProductIds = GNE_SFA2_PFG_Util.getUsedPfgProductsIdsForUser(userId,GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC); 
				}
				userProductIds.addAll(userHcProductIds);
				
				if(userHcLotCatalogIds==null) {
					userHcLotCatalogIds = GNE_SFA2_PFG_Util.getUsedPfgLotCatalogsIdsForUser(userId,GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
				}
				
				userLotCatalogIds.addAll(userHcLotCatalogIds);
			}
			
			if(String.isBlank(distributionMethod) || distributionMethod==GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP) {
				if(userDtpProductIds==null) {
					Set<String> terrIds = new Set<String>();
					String currentTerrName = GNE_SFA2_Interaction_Util.selectInteractionTerritory();
					
					for (Territory2 terr : GNE_SFA2_PFG_Util.getTerritoriesForUser(userId)) {
						if(terr.Name == currentTerrName) {
							terrIds.add(terr.Id);
						}
					}
					userDtpProductIds = GNE_SFA2_PFG_Util.getUsedPfgProductsIdsForTerritory(terrIds, new Set<Integer>{getCallDetailDate().year()});
				}
				userProductIds.addAll(userDtpProductIds);
			}
		}
		
		if(userProductIds.isEmpty()) {
		   	// To be sure that no matching products will be found
		   	userProductIds.add(userId);
		}
		    
		if(userLotCatalogIds.isEmpty()) {
		   	// To be sure that no matching lot catalog will be found
		   	userLotCatalogIds.add(userId);
		}
		
		productLookupAvailableIds = String.join(new List<Id>(userProductIds),',');
		lotCatalogLookupAvailableIds = String.join(new List<Id>(userLotCatalogIds),',');
	}
	
	public List<ApexPages.Message> validate() {
		List<ApexPages.Message> msgs = new List<ApexPages.Message>();
		Boolean isSomethingChanged = isSomethingChanged(true);
		
		if(isSomethingChanged && mainController.call.Completed_gne__c) {
			msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_PFG_CANNOT_COMPLETE_INTERACTION_WITHOUT_SIGNATURE));
		} else if(isSomethingChanged) {
			Id userId = UserInfo.getUserId();
			validateUser(userId, msgs);
			validateAddress(mainController.call.Parent_Address_vod__c, msgs);
			
			if(msgs.isEmpty()) {
				String callYear = String.valueOf(mainController.call.Date_Completed_gne__c!=null 
						? mainController.call.Date_Completed_gne__c.year()
						: System.today().year());
				prepareCache(userId, callYear);
				
				// Validate fields
				validateCallPfgDetails(userId, callYear, msgs);
			}
		}
		
		return msgs;
	}
	
	private void validateUser(Id userId, List<ApexPages.Message> msgs) {
		Boolean isLOA = GNE_SFA2_PFG_Util.checkIsUserLOA(userId);
		Boolean isCertified = GNE_SFA2_PFG_Util.checkIsUserCertified(userId); 
		
		if(isLOA && !isCertified) {
			msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.PFG_USER_ON_LOA_AND_UNCERTIFIED));
		}else if(isLOA) {
			msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.PFG_USER_ON_LOA));
		}else if(!isCertified) {
			msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.PFG_USER_UNCERTIFIED));
		}
	}
	
	private void validateAddress(Id addrId, List<ApexPages.Message> msgs) {
		Boolean isSlnValid = GNE_SFA2_PFG_Util.checkIsSlnValid(addrId);
			
		if(!isSlnValid) {
			msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_PFG_ADDRESS_SLN_NOT_VALID));
		}
	}
	
	private void prepareCache(Id userId, String callYear) {
		// Cache Territory or User Details
		List<Call_PFG_Detail_gne__c> cDetails = new List<Call_PFG_Detail_gne__c>();
			
		for(CallPfgDetailWrapper cpd : callPfgDetails) {
			Call_PFG_Detail_gne__c cDetail = cpd.record;
			cDetails.add(cDetail);
		}
			
		if(isDTP) {
			GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(cDetails, userId, Integer.valueOf(callYear));
		} else if(isHC) {
			GNE_SFA2_PFG_Util.cachePfgToUserDetails(cDetails, userId);
		}
			
		// Cache HCP and Product Limit Records
		GNE_SFA2_PFG_Util.cachePfgToAccountDetails(cDetails,callYear);
		GNE_SFA2_PFG_Util.cacheAccLimitExceptions(cDetails,callYear);
		GNE_SFA2_PFG_Util.cacheProductLimits(cDetails,callYear);
	}
	
	private void validateCallPfgDetails(Id userId, String callYear, List<ApexPages.Message> msgs) {
		Integer i = 0;
		Boolean isSingleMode = callPfgDetails.size() == 1;
		Set<Id> prodIds = new Set<Id>();
		Set<String> lotNos = new Set<String>();
		
		for(CallPfgDetailWrapper cpd : callPfgDetails) {
			String rowPrefix = 'PFG: ' + (isSingleMode ? '' : ('Row ' + ++i + ': '));
			Call_PFG_Detail_gne__c cDetail = cpd.record;
			
			if(String.isBlank(cDetail.Product_gne__c)) {
				msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
					rowPrefix + 'NDC' + GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE));
			} else if(isDTP) {
				if(prodIds.contains(cDetail.Product_gne__c)) {
					msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
						rowPrefix + 'NDC' + GNE_SFA2_PFG_Base_Controller.VALUE_ALREADY_IN_USE_MSG));
				}
				
				prodIds.add(cDetail.Product_gne__c);
			}
			
			if(isHC) {
				if(String.isBlank(cDetail.Lot_No_gne__c))	{
					msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
						rowPrefix + Call_PFG_Detail_gne__c.Lot_No_gne__c.getDescribe().getLabel() + 
						GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE));
				} else {
					if(lotNos.contains(cDetail.Lot_No_gne__c)) {
						msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
							rowPrefix + Call_PFG_Detail_gne__c.Lot_No_gne__c.getDescribe().getLabel() + 
							GNE_SFA2_PFG_Base_Controller.VALUE_ALREADY_IN_USE_MSG));
					}
					lotNos.add(cDetail.Lot_No_gne__c);
				}
			}
			
			List<Integer> minAndMaxValues = new List<Integer>{null,null};
			
			if(!GNE_SFA2_PFG_Base_Controller.validateIsInteger(cDetail.Quantity_gne__c)) {
				msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
						rowPrefix + System.Label.GNE_SFA2_PFG_QUANTITY_IS_TOO_LARGE));
			} else {
				setCallDetailDate(cDetail);
				String currentTerrName = GNE_SFA2_Interaction_Util.selectInteractionTerritory();
				 
				if(!GNE_SFA2_PFG_Util.validateCallDetailQuantity(cDetail,userId,currentTerrName,distributionMethod,minAndMaxValues)) {
		    		if(minAndMaxValues[1] == null) {
		    			msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
		    				rowPrefix + String.format(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_GREATER, new String[]{minAndMaxValues[0].format()})));
		    		} else if(minAndMaxValues[1] == 0) {
						msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
							rowPrefix + System.Label.GNE_SFA2_PFG_QUANTITY_NOT_AVAILABLE));
					} else if( minAndMaxValues[0] != minAndMaxValues[1]){
						msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
		    				rowPrefix + String.format(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_BETWEEN, new String[]{minAndMaxValues[0].format(),minAndMaxValues[1].format()})));
					} else {
						msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, 
		    				rowPrefix + String.format(System.Label.GNE_SFA2_PFG_QUANTITY_MUST_BE_EQUAL, new String[]{minAndMaxValues[0].format()})));
		    		}
		    	}
		    	
		    	if(!GNE_SFA2_PFG_Util.validateHcpQuantityLimit(cDetail, callYear)) {
		    		Integer availableQuantity = GNE_SFA2_PFG_Util.getHcpMaxQuantity(cDetail.Account_gne__c, cDetail.Product_gne__c, callYear);
		    		availableQuantity = availableQuantity == null ? GNE_SFA2_PFG_Util.getProductMaxQuantity(cDetail.Product_gne__c, callYear) : availableQuantity;
		    		
		    		msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, rowPrefix + String.format(System.Label.PFG_HCP_QUANTITY_LIMIT_REACHED, new String[]{availableQuantity.format()})));
		    	}
		    	
		    	Integer callQtyLimit = String.isNotBlank(cDetail.Product_gne__c) ? GNE_SFA2_PFG_Util.getInteractionQtyLimit(cDetail.Product_gne__c, distributionMethod) : null;
		    	
		    	if(callQtyLimit!=null && callQtyLimit<cDetail.Quantity_gne__c) {
		    		Product_vod__c pfgProd = GNE_SFA2_PFG_Util.getPfgProduct(cDetail.Product_gne__c);
		    		msgs.add(new ApexPages.Message(ApexPages.severity.ERROR, rowPrefix + String.format(System.Label.GNE_SFA2_PFG_HCP_CALL_QUANTITY_LIMIT_REACHED, new String[]{pfgProd.NDC_Number_gne__c, callQtyLimit.format()})));
		    	}
			}
		}
	}
	
	public PageReference save() {
		if(isSomethingChanged(false)) {
			GNE_SFA2_PFG_Util.addSessionLabel(GNE_SFA2_Interaction_Controller.class.getName());
			List<Call_PFG_Detail_gne__c> callDetailsToRemove = new List<Call_PFG_Detail_gne__c>();
			List<Call_PFG_Detail_gne__c> callDetailsToUpsert = new List<Call_PFG_Detail_gne__c>();
			
			for(Id cDetailId : callDetailIdsToRemove) {
				callDetailsToRemove.add(new Call_PFG_Detail_gne__c(Id = cDetailId));
			}
			
			if(!callDetailsToRemove.isEmpty()) {
				delete callDetailsToRemove;
			}
			
			for(CallPfgDetailWrapper cpdWrapper : callPfgDetails) {
				if(mainController.call.Completed_gne__c || cpdWrapper.isChanged(distributionMethod)) {
					Call_PFG_Detail_gne__c cDetail = cpdWrapper.record;
					if(String.isBlank(cDetail.Call_gne__c)) {
						cDetail.Call_gne__c = mainController.call.Id;
					}
					
					cDetail.Distribution_Method_gne__c = distributionMethod;
					cDetail.Is_Completed_gne__c = mainController.call.Completed_gne__c;
					setCallDetailDate(cDetail);
					callDetailsToUpsert.add(cDetail);
				}
			}
			
			if(!callDetailsToUpsert.isEmpty()) {
				upsert callDetailsToUpsert;
			}
		}
				
		return null;
	}
		
	public PageReference addCallPfgDetail() {
    	Call_PFG_Detail_gne__c cDetail = new Call_PFG_Detail_gne__c(
    		Call_gne__c = mainController.call.Id,
    		Account_gne__c = mainController.call.Account_vod__c,
    		Quantity_gne__c = 0.0);
    	
    	Integer maxUsedIdx = 0;
    	for(Integer usedIdx : callPfgDetailsMap.keySet()) {
    		maxUsedIdx = Math.max(usedIdx, maxUsedIdx);
    	}
    	
    	Integer idx = Math.max(maxUsedIdx+1,callPfgDetails.size());
    	CallPfgDetailWrapper cpdWrapper = new CallPfgDetailWrapper(cDetail,idx);
    	callPfgDetails.add(cpdWrapper);
    	callPfgDetailsMap.put(idx,cpdWrapper);
    	return null;
    }
    
    public PageReference removeCallPfgDetail() {
    	Integer idx = Integer.valueOf(rowIdx);
    	callPfgDetailsMap.remove(idx);
    	
    	Integer idxToRemove=0;
    	for(CallPfgDetailWrapper cpdWrapper : callPfgDetails) {
    		if(cpdWrapper.rowIdx == idx) {
    			if(!cpdWrapper.isNew) {
    				callDetailIdsToRemove.add(cpdWrapper.record.Id);
    			}
    			break;
    		}
    		idxToRemove++;
    	}
    	
    	if(idxToRemove>=0) {
    		callPfgDetails.remove(idxToRemove);
    	}
    	
    	setDistributionMethod();
    	return null;
    }
    
    public PageReference productChanged() {
    	return productChanged(false);
    }
        
    public PageReference productChanged(Boolean causedByLotNoUpdate) {
    	Integer idx = Integer.valueOf(rowIdx);
    	
    	if(callPfgDetailsMap.containsKey(idx)) {
			CallPfgDetailWrapper cpdWrapper = callPfgDetailsMap.get(idx);
			Call_PFG_Detail_gne__c cDetail = cpdWrapper.record;
			
			cDetail.Product_gne__c = null;
			cDetail.Product_gne__r = null;
			if(!causedByLotNoUpdate) {
				cDetail.Lot_No_gne__c = null;
				cpdWrapper.lotCatalogId = null;
				cpdWrapper.clearWhereExpression();
			}
			
			if(String.isNotBlank(productId)) {
				for(Product_vod__c prod : GNE_SFA2_PFG_DAO.getProductsById(new Set<String>{ productId })) {
					cDetail.Product_gne__c = prod.Id;
					cDetail.Product_gne__r = prod;
					cpdWrapper.addToWhereExpression('Product_gne__c = \''+ productId +'\'');
					
					break;
				}
			}
		}
		
		setDistributionMethod();
		return null;          
    }
    
    public PageReference lotNumberChanged() {
    	Integer idx = Integer.valueOf(rowIdx);
    	
		if(callPfgDetailsMap.containsKey(idx)) {
			CallPfgDetailWrapper cpdWrapper = callPfgDetailsMap.get(idx);
			Call_PFG_Detail_gne__c cDetail = cpdWrapper.record;
			
			cDetail.Lot_No_gne__c = null;
			cpdWrapper.lotCatalogId = null;
			
			if(String.isNotBlank(lotId)) {
				for(SFA2_Lot_Catalog_gne__c lotCatalog : GNE_SFA2_PFG_DAO.getLotCatalogsForIds(new Set<String>{lotId})) {
					cpdWrapper.lotCatalogId = lotCatalog.Id;
					cDetail.Lot_No_gne__c = lotCatalog.Name;
					if(String.isBlank(cDetail.Product_gne__c) || lotCatalog.Product_gne__c!=cDetail.Product_gne__c) {
						// Populate product fields
						productId = lotCatalog.Product_gne__c;
						productChanged(true);
					}
					break;
				}
			}
		}
		
		return null;          
    }
    
    private void setCallDetailDate(Call_PFG_Detail_gne__c cDetail) {
		cDetail.Date_gne__c = getCallDetailDate();
	}
	
	private Date getCallDetailDate() {
		return mainController.call.Date_Completed_gne__c!=null ? mainController.call.Date_Completed_gne__c : System.today();
	}
    
    private Boolean isSomethingChanged(Boolean forceReload) {
    	
    	if(isSomethingChanged==null || forceReload) {
	    	isSomethingChanged = !callDetailIdsToRemove.isEmpty();
	    	
	    	if(!isSomethingChanged) {
		    	for(CallPfgDetailWrapper cpd : callPfgDetails) {
		    		if(isSomethingChanged = ((!mainController.isCompleted && mainController.call.Completed_gne__c) || cpd.isChanged(distributionMethod))) {
		    			break;
		    		}  
		    	}
	    	}
    	}
    	
    	return isSomethingChanged;
    }
	
	public class CallPfgDetailWrapper {
		public Call_PFG_Detail_gne__c record {get; private set;}
		public Integer rowIdx {get; private set;}
		public String lotCatalogId {get; set;}
		public Boolean isNew {get; private set;}
		public String lotWhereExpression {get; set;}
		private Call_PFG_Detail_gne__c origRecord;
		
		public CallPfgDetailWrapper(Call_PFG_Detail_gne__c a_record, Integer a_rowIdx) {
			record = a_record;
			rowIdx = a_rowIdx;
			isNew = String.isBlank(record.Id);
			origRecord = a_record.clone();
			clearWhereExpression();
			
			if(String.isNotBlank(record.Lot_No_gne__c)) {
	    		SFA2_Lot_Catalog_gne__c lotC = GNE_SFA2_PFG_Util.getLotCatalog(record.Lot_No_gne__c);
	    		lotCatalogId = lotC!=null ? lotC.Id : null;
    		}
		}
		
		public Boolean isChanged(String dMethod) {
			return isNew ||
				String.isBlank(record.Product_gne__c) || origRecord.Product_gne__c!=record.Product_gne__c ||
				(dMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC && 
					(String.isBlank(record.Lot_No_gne__c) || origRecord.Lot_No_gne__c!=record.Lot_No_gne__c)) ||
				origRecord.Quantity_gne__c!=record.Quantity_gne__c;
		}
		
		public void clearWhereExpression() {
			lotWhereExpression = 'Distribution_Method_gne__c = \'' + GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC + '\'';
		}
		
		public void addToWhereExpression(String whereStatement) {
			if(lotWhereExpression==null) {
				clearWhereExpression();
			}
			
			lotWhereExpression += ' AND ' + whereStatement;
		}
	}
}