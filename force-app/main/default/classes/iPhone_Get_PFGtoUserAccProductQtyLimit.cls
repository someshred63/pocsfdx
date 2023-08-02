/******************************************************************************************
*  @author: Bartosz Osowiecki, Roche (contractor)
*  @email: bartosz.osowiecki@contractors.roche.com
*  Created: 2013-07-02
*  First version was createdy by Karl Simon (2013-06-17) to refactor to use Promotional Free Goods (PFG) solution object, Call_PFG_Detail_gne__c, and deprecate defunct use of Veeva Call2Samples.
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call_PFG_Detail_gne__c child records for the specified accounts.
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetPFGtoUserAccProductQtyLimit/*')
global with sharing class iPhone_Get_PFGtoUserAccProductQtyLimit {

    private static Id currentUserId;
    private static Map<Id,UserTerritory2Association> userTerritoryCache;

    global class RestResponse extends iPhone_Commons_gne.RestResponse {
    	public List<AvailableProduct> products = new List<AvailableProduct>();
    	public List<String> xids = new List<String>();
    	public transient List<Product_vod__c> pfgProducts;
    	public transient Set<Territory2> territories;
    	public transient Map<String,SFA2_PFG_to_Territory_Detail_gne__c> tDetailsMap;
    	public transient String limitYear = String.valueOf(GNE_SFA2_PFG_Util.getYear());
    	public transient String lastSyncDate;
    }

    global class AvailableProduct {
    	public String id; // Detail Object Id
    	public String pid; // Product_vod__c.Id
    	public String tid; // Territory Id
    	public String ax; // Delta: 'i' or 'u'
    	public String nm; // Product_vod__c.Name
    	public String ndc; // Product_vod__c.NDC_Number_gne__c
    	public String uom; // Product_vod__c.UOM_gne__c
    	public String lno; // Lot Number - SFA2_Lot_Catalog_gne__c.Name
    	public Integer qty; // Max Available Quantity
    	public String dm; // Distribution Method
    	public String ed; // SFA2_Lot_Catalog_gne__c.Expiration_Date_gne__c
    	public Integer lyr; // Product Limit Year
    	public List<AccountProductLimit> accs = new List<AccountProductLimit>();

    	public AvailableProduct(Product_vod__c pfgProduct, Territory2 terr, String limitYear) {
    		id = pfgProduct.Id + ':' + terr.Id;
    		pid = pfgProduct.Id;
        nm  = pfgProduct.Name;
        ndc = pfgProduct.NDC_Number_gne__c;
        uom = pfgProduct.UOM_gne__c;
        tid = terr.Id;
        qty = 0;
        dm = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
        lyr = GNE_SFA2_PFG_Util.getProductMaxQuantity(pfgProduct.Id, limitYear);
        lno = '';
    	}

    	public void setTerritoryDetail(SFA2_PFG_to_Territory_Detail_gne__c tDetail) {
    		id	= tDetail.Id;
    		qty	= tDetail.Qty_Total_Available_gne__c.intValue();
    		dm	= tDetail.Distribution_Method_gne__c;
    		ed	= iPhone_REST_Utils.formatDate(tDetail.Expiration_Date_gne__c, 'MM/dd/yyyy');
    	}

    	public void addAccountLimit(Id accId, Integer maxQty, String limitYear) {
    		accs.add(new AccountProductLimit(accId, pid, lno, maxQty, limitYear));
    	}

    	public void setDeltaStatus(String deltaStatus) {
    		ax = deltaStatus;
    	}
    }

    global class AccountProductLimit {
    	public String id; // Account.Id
    	public String pid; // Product_vod__c.Id
    	public String lno; // Lot Number - SFA2_Lot_Catalog_gne__c.Name
    	public Integer qty; // Max Available Quantity
    	public Integer lyr; // Limit Year
    	public Integer ytd; // YTD Disbursed

    	public AccountProductLimit(Id accId, Id prodId, String lotNo, Integer maxQty, String limitYear) {
    		id	= accId;
    		pid	= prodId;
    		lno	= lotNo;
    		qty	= maxQty;

    		PFG_Staging_Account_Limit_Exception_gne__c accLimitEx = GNE_SFA2_PFG_Util.getAccLimitException(accId, prodId, limitYear);
    		SFA2_PFG_to_Account_Detail_gne__c accDetail = GNE_SFA2_PFG_Util.getPfgToAccountDetail(accId, prodId, limitYear);

    		lyr = (accLimitEx!=null && accLimitEx.Exception_Quantity_gne__c!=null) ? accLimitEx.Exception_Quantity_gne__c.intValue() : null;
    		ytd = (accDetail!=null && accDetail.Qty_Disbursed_gne__c!=null) ? accDetail.Qty_Disbursed_gne__c.intValue() : null;
    	}
    }

    @HttpPost
    global static RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {
     	iPhone_Commons_gne.setStartTimeStamp();
     	RestResponse result = new RestResponse();
     	try {
	     	intProcessRequest(lastSyncDate, unixId, accountIds, result);
            iPhoneBase.handleLogging(result, lastSyncDate!=null, unixId, 'iPhoneGetPFGtoUserAccProductQtyLimit');
	    } catch(Exception ex) {
     		result.setErrorStatus(ex);
     		String className = iPhone_Get_PFGtoUserAccProductQtyLimit.class.getName();
     		RequestParameters requestParams = new RequestParameters(lastSyncDate, unixId, accountIds, enhDelta, otrVersion);
     		iPhoneBase.handleException(ex, UserInfo.getUserId(), 'OTR', '[iPhone REST]' + className , RequestParameters.class, requestParams, '[iPhone REST] Error while processing ' + className);
     	}

     	return result;
     }

     private static void intProcessRequest(String lastSyncDate, String unixId, List<String> accountIds, RestResponse result) {
      result.lastSyncDate = lastSyncDate;
      Id userId = currentUserId = validateUser(unixId);
      List<String> accIds = accountIds!=null ? accountIds : new List<String>();
      prepareCache(result, userId, accIds);
      prepareResult(result, accIds);
      result.setSuccessStatus();
     }

     private static Id validateUser(String unixId) {
     	User user = iPhone_DAO.getUserByExternalId(unixId);

	    if(user==null) {
	    	throw new iPhone_Commons_gne.IPhoneException('User not found: ' + unixId);
	    }

	    return user.Id;
     }

     private static void prepareCache(RestResponse result, Id userId, List<String> accountIds) {
     	String limitYear = result.limitYear;
     	result.pfgProducts = new List<Product_vod__c>();

     	for (String brandName : GNE_SFA2_PFG_Util.getBrandNamesByUserTerritory(userId)){
        result.pfgProducts.addAll(GNE_SFA2_PFG_Util.getProductsForBrand(brandName));
      }

     	result.territories = GNE_SFA2_PFG_Util.getTerritoriesForUser(userId);
     	Set<String> terrNames = new Set<String>();

     	for(Territory2 terr : result.territories) {
     		terrNames.add(terr.Name);
     	}

     	List<SFA2_PFG_to_Territory_Detail_gne__c> tDetails = GNE_SFA2_PFG_Util.getPFGToTerrDetailsActiveForTerrNamesFlat(terrNames, new Set<Integer>{GNE_SFA2_PFG_Util.getYear()});
     	result.tDetailsMap = new Map<String,SFA2_PFG_to_Territory_Detail_gne__c>();

     	List<Id> accIds = new List<Id>();
     	List<Id> prodIds = new List<Id>();
     	Set<Id> terrIds = new Set<Id>();

     	for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : tDetails) {
     		Id prodId = tDetail.Product_gne__c;
     		Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryByNumber(tDetail.Territory_Number_gne__c);

     		if(terr!=null) {
     			terrIds.add(terr.Id);
     			result.tDetailsMap.put(prodId + ':' + terr.id, tDetail);
     		}
     	}

     	for(Product_vod__c pfgProduct : result.pfgProducts) {
     		for(String accId : accountIds) {
          accIds.add((Id)accId);
          prodIds.add(pfgProduct.Id);
        }
     	}

     	GNE_SFA2_PFG_Util.cacheProductLimits(new Set<Id>(prodIds), limitYear);
     	GNE_SFA2_PFG_Util.cacheAccLimitExceptions(accIds, prodIds, limitYear);
     	GNE_SFA2_PFG_Util.cachePfgToAccountDetails(accIds, prodIds, limitYear);
     	userTerritoryCache = new Map<Id,UserTerritory2Association>();

     	// Needed in delta mode
     	if(!terrIds.isEmpty()) {
     		for (UserTerritory2Association ut : [SELECT Territory2Id, LastModifiedDate FROM UserTerritory2Association WHERE Territory2Id IN :terrIds AND UserId = :currentUserId ORDER BY LastModifiedDate ASC]) {
     			userTerritoryCache.put(ut.Territory2Id, ut);
     		}
     	}
    }

    private static void prepareResult(RestResponse result, List<String> accountIds) {
    	String limitYear = result.limitYear;
    	DeltaCalculator deltaCalc = new DeltaCalculator(result.lastSyncDate);

    	for(Product_vod__c pfgProduct : result.pfgProducts) {
    		Boolean isFirstTerr = true;

    		for(Territory2 terr : result.territories) {
    			AvailableProduct ap = new AvailableProduct(pfgProduct, terr, limitYear);
          String deltaStatus = deltaCalc.getDeltaStatus(pfgProduct, terr, limitYear);
    			SFA2_PFG_to_Territory_Detail_gne__c tDetail = result.tDetailsMap.get(pfgProduct.Id + ':' + terr.Id);

    			if(tDetail!=null) {
    				ap.setTerritoryDetail(tDetail);
    				result.xids.add(tDetail.Id);
    				deltaStatus = deltaStatus == deltaCalc.STAT_SYNC ? deltaCalc.getDeltaStatus(tDetail) : deltaStatus;
    			}

    			if(ap.lyr!=null && isFirstTerr) {
            isFirstTerr = false;

            for(String accId : accountIds) {
              Integer accLimit = GNE_SFA2_PFG_Util.getHcpMaxQuantity((Id)accId, pfgProduct.Id, limitYear);

              if(accLimit!=null) {
                deltaStatus = deltaCalc.getDeltaStatus((Id)accId, pfgProduct.Id, limitYear, deltaStatus);
                ap.addAccountLimit((Id)accId,accLimit,limitYear);
              }
            }
    			}

    			if(deltaStatus==null || deltaStatus == deltaCalc.STAT_INSERT || deltaStatus == deltaCalc.STAT_UPDATE) {
            ap.setDeltaStatus(deltaStatus);
            result.products.add(ap);
          }
        }
    	}
    }

    private static Set<String> getTerritoryNamesForUser( Id userId) {
    	Set<String> result = new Set<String>();

    	for(Territory2 terr : GNE_SFA2_PFG_Util.getTerritoriesForUser(userId)) {
    		result.add(terr.Name);
    	}

    	return result;
    }

    private static String getCurrentYear() {
    	return String.valueOf(System.today().year());
    }

    public class DeltaCalculator extends iPhone_Commons_gne.DeltaCalculator {

    	public DeltaCalculator(String lastSyncDate) {
    		super(lastSyncDate);
    	}

    	protected override String getDeltaStatus(SObject rec) {
    		return super.getDeltaStatus(rec);
    	}

    	private String getDeltaStatus(Product_vod__c pfgProduct, Territory2 terr, String limitYear) {
    		String deltaStatus = getDeltaStatus(pfgProduct);

    		if(deltaStatus==STAT_SYNC) {
    			SFA2_PFG_Product_Limit_gne__c prodLimit = GNE_SFA2_PFG_Util.getProductLimit(pfgProduct.Id, limitYear);
          deltaStatus = prodLimit!=null ? getDeltaStatus(prodLimit) : null;
    		}

    		if(deltaStatus==STAT_SYNC && userTerritoryCache.containsKey(terr.Id) && userTerritoryCache.get(terr.Id).LastModifiedDate >= lastSynchronized) {
    			deltaStatus = STAT_UPDATE;
    		}

    		return deltaStatus;
    	}

    	private String getDeltaStatus(Id accId, Id prodId, String limitYear, String prevDeltaStatus) {
    		String deltaStatus = prevDeltaStatus;
        String childDeltaStatus = null;

        if(prevDeltaStatus == STAT_SYNC) {
          SFA2_PFG_to_Account_Detail_gne__c accDetail = GNE_SFA2_PFG_Util.getPfgToAccountDetail(accId, prodId, limitYear);
          childDeltaStatus = accDetail!=null ? getDeltaStatus(accDetail) : STAT_SYNC;
        }

        if(childDeltaStatus==STAT_SYNC) {
          PFG_Staging_Account_Limit_Exception_gne__c accLimitEx = GNE_SFA2_PFG_Util.getAccLimitException(accId, prodId, limitYear);
          childDeltaStatus = accLimitEx!=null ? getDeltaStatus(accLimitEx) : null;
        }

        if(childDeltaStatus == STAT_INSERT || childDeltaStatus == STAT_UPDATE) {
          deltaStatus = STAT_UPDATE;
        }

        return deltaStatus;
      }
    }

    public class RequestParameters extends iPhone_Commons_gne.DeltaArgs implements iPhoneBase.RequestTestable {
    	private String lastSyncDate;
     	private String unixId;
     	private List<String> accountIds;

     	public RequestParameters(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {
     		super(lastSyncDate, unixId, accountIds, enhDelta, otrVersion);
     	}

     	public void testRequest() {
			iPhone_Get_PFGtoUserAccProductQtyLimit.intProcessRequest(lastSyncDate, unixId, accountIds, new RestResponse());
		}
    }
}