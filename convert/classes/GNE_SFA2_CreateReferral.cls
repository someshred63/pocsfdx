public without sharing class GNE_SFA2_CreateReferral{

	/* 
	This class is used for creating a Referral.
	Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication  request with a recordType Referral.
	
	Author : Sweta Khalasi
	Created : 01 Jul 2011
	Last Modified : 24 Aug 2011
	Project : gMARS Phase 2  
	*/
	public static final String PRODUCT_MOLECULE_TYPE='Molecule';
	public static final String PRODUCT_DETAIL_TYPE='Detail';
	public static final String PRODUCT_THERA_DISEASE_TYPE='TheraDisease';
	public static final String PRODUCT_BRAND_TYPE='Brand';
	public static final String PRODUCT_APPROVED_INDICATION_TYPE='Approved Product Indications';

	public String assignmentType { get; set; }
	public String searchFld { get; set; }
	public Id searchId { get; set; }
	public String searchFld1 { get; set; }
	public Id searchId1 { get; set; }
	public Id selectedAddressId{get; set;}  
	public Id selectedProductId{get; set;}  
	public Id selectedMoleculeId{get; set;}
	public Id selectedTA_SubTA{get; set;}
	public String question{get; set;}
	public Medical_Communication_gne__c objReferralProxy {get; private set;}
	public Referral_Assignment_gne__c objReferralAssignmentProxy {get; private set;} 
	public Boolean isMedComm { get; set; }
	public Boolean disable { get; set; }
	
	private Account account;
	private User currentUser = null;
	private String strErrorMsg=null;
	private Boolean isCreateAllowed = true;
	private Boolean disableInput = false;
	private SFA2_Configuration_Object_gne__c pageConfiguration;
	private Map<Id,Id> mapProductToTASubTA = new Map<Id,Id> ();
	private List<Address_vod__c> lstAddress;
	private Map<Id,Address_vod__c> mapAddressId = new Map<Id,Address_vod__c> ();
	private List<Product_vod__c> lstProducts = new List<Product_vod__c> ();
	private Map<Id,Product_vod__c> mapTA_SubTAId = new Map<Id,Product_vod__c> ();
	private Map<Id,Product_vod__c> mapMoleculeId = new Map<Id,Product_vod__c> ();
	private List<Id> lstdefautTASubTAs=new List<Id>();
	private List<Id> lstdefautMolecules=new List<Id>();

	public void disableCloseDateInput(){
		objReferralAssignmentProxy = new Referral_Assignment_gne__c();
		searchFld='';
		searchId=null;
		disableInput = true;
	}

	public void enableCloseDateInput(){
		objReferralAssignmentProxy = new Referral_Assignment_gne__c();
		searchFld='';
		searchId=null;
		disableInput = false;
	}

	public Boolean getdisableInput(){
		return disableInput;
	}
	
	public List<SelectOption> getMyAssType() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Manual Assignment','Manual Assignment'));
		options.add(new SelectOption('Auto Assignment','Auto Assignment')); 
		return options;
	}

	//action functions
	public void assType(){
		if(assignmentType == 'Manual Assignment'){
			enableCloseDateInput();
		}
		if(assignmentType == 'Auto Assignment'){
			disableCloseDateInput();
		}     
	}
	
	public void doDisable() {
		objReferralProxy.Requested_By_gne__c = null;
		searchFld1='';
		searchId1=null;
		disable = isMedComm;  
	} 

	public GNE_SFA2_CreateReferral(){
	}

	//Requested By field is editable by MedAffair profile user only as they can raise referra on behalf of MCCO users.
	public Boolean getIsMCLUser(){
		if (currentUser !=null && currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile))){
			return true;
		}
		return false;
	}
	
	public Boolean getIsCreateAllowed(){
		return isCreateAllowed;
	}

	public GNE_SFA2_CreateReferral(ApexPages.StandardController controller){
		pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Referral_Assignment_gne__c');
		assignmentType = 'Manual Assignment';
		enableCloseDateInput();
		currentUser=[select Profile_Name_gne__c from User where Id = :UserInfo.getUserId() limit 1];
		isCreateAllowed = GNE_Referral_Utils.isCreateReferralAllowed(currentUser);
		
		List<String> productOwnerQueueName = new List<String> ();
		productOwnerQueueName.add(System.Label.GNE_SFA_Canada_Queue);
		productOwnerQueueName.add('GNE-INACTIVE-PROD-QUEUE');
		List<Id> productOwnerQueueId = GNE_Referral_Utils.getProductOwnerQueueId(productOwnerQueueName);
		//Referral will be created by SFA, MedAffair, ATLS and system admin profile only.
		if(isCreateAllowed){    
			//intantiate proxy object
			objReferralProxy = new Medical_Communication_gne__c(RecordTypeId =  GNE_Referral_Utils.getReferralRecordType().id);
			objReferralAssignmentProxy = new Referral_Assignment_gne__c();
			Id accId = ApexPages.currentPage().getParameters().get('AccId');
			Set<Id> hiddenAddrIds = getHiddenAddressIds(accId);
			
			account = [
                Select Id, Name, FirstName, LastName, MDMID_gne__c,  PersonEmail, IsPersonAccount,Secondary_Email_gne__c, 
                    (Select Account_vod__c, Active_Flag_gne__c, Address_1_gne__c, Address_line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, Address_Type_gne__c, 
                        City_vod__c, Country_gen__c, Email_gne__c, Fax_2_vod__c, Fax_vod__c, Id, Inactive_vod__c, License_Status_vod__c, License_vod__c, Name, 
                        Phone_1_Ext_gne__c, Phone_2_Ext_gne__c, Phone_2_vod__c, Phone_vod__c, State_vod__c, Zip_4_vod__c, Zip_vod__c,
                        Province_can_gne__c, Postal_Code_can_gne__c
                     From Address_vod__r
                     where Inactive_vod__c=false and Id not in :hiddenAddrIds)
                     from Account where id = :accId
            ];    
			if(account!=null){
				//asssign address
				lstAddress = account.address_vod__r;
				if(lstAddress != null && lstAddress.size()>0){
					for(Address_vod__c ad: lstAddress){
						if(account.PersonEmail != null){
							ad.Email_gne__c = account.PersonEmail;
						}else if(account.Secondary_Email_gne__c != null){
							ad.Email_gne__c = account.Secondary_Email_gne__c;
						}
						
						if((String)ad.Fax_vod__c == null && (String)ad.Fax_2_vod__c != null){
							ad.Fax_vod__c=ad.Fax_2_vod__c;
						}
						mapAddressId.put(ad.Id,ad);         
					}
				} else {
				    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,String.format(System.Label.GNE_SFA2_HideAddress_Error_AddressIsRequired, new String[]{'Medical Referral'})));
				}
			}
			List<String> lstMedAffairsMoleculeNames = GNE_Referral_Utils.getRestrictedProductName();
			List<Product_vod__c> lstAllProducts;
			if(productOwnerQueueId != null && productOwnerQueueId.size() >0){
				lstAllProducts = [Select Id, Name,Detail_Product_Subtype_Code_gne__c,TheraDisease_Reference_gne__c,OwnerId,Product_Type_vod__c, Therapeutic_Area_vod__c from Product_vod__c where Name not IN :lstMedAffairsMoleculeNames and OwnerId not In : productOwnerQueueId order by name];
			}else{
				lstAllProducts = [Select Id, Name,Detail_Product_Subtype_Code_gne__c,TheraDisease_Reference_gne__c,OwnerId,Product_Type_vod__c, Therapeutic_Area_vod__c from Product_vod__c where Name not IN :lstMedAffairsMoleculeNames order by name];     
			}
			for(Product_vod__c prod: lstAllProducts){
				if(prod.Product_Type_vod__c==PRODUCT_DETAIL_TYPE && (prod.Detail_Product_Subtype_Code_gne__c == PRODUCT_BRAND_TYPE || prod.Detail_Product_Subtype_Code_gne__c == PRODUCT_APPROVED_INDICATION_TYPE)){
					lstProducts.add(prod);
					if(prod.TheraDisease_Reference_gne__c != null){
						mapProductToTASubTA.put(prod.Id,prod.TheraDisease_Reference_gne__c);
					}                    
				}
				if(prod.Product_Type_vod__c!=null && prod.Detail_Product_Subtype_Code_gne__c!= null && prod.Product_Type_vod__c==PRODUCT_DETAIL_TYPE && prod.Detail_Product_Subtype_Code_gne__c== PRODUCT_THERA_DISEASE_TYPE){
					mapTA_SubTAId.put(prod.Id,prod);
				}
				if(prod.Detail_Product_Subtype_Code_gne__c!= null && prod.Detail_Product_Subtype_Code_gne__c==PRODUCT_MOLECULE_TYPE){
					mapMoleculeId.put(prod.Id,prod);                    
				}           
			}
			System.debug('mapProductToTASubTA.size(): --> ' + mapProductToTASubTA.size());   
		}else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
		}
	}
	
	private Set<Id> getHiddenAddressIds(Id accId) {
        return (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddressIds(UserInfo.getUserId(), accId);
    }

	public Account getAccountInfo(){
		return account;
	}

	public String getActiveMenuItem() {
		String result = '';
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
		}
		return result;
	}

	public List<SelectOption> getAddressList(){               
		List<SelectOption> options=new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		
		if(lstAddress!=null && lstAddress.size()>0){
			for(Address_vod__c ad: lstAddress  ){
			    String addressLongName = GNE_SFA2_Util.getAddressAsString(ad);
			    options.add(new SelectOption(ad.Id, addressLongName));    
			}
		}
		return options;
	}
	
	public List<Product_vod__c> getSortedList(Map<Id,Product_vod__c> mapProdId){   
		Map<String,Product_vod__c> map4TA_SubTAId = new Map<String,Product_vod__c> ();
		List<String> lst1TA_SubTA = new List<String> ();
		List<Product_vod__c> lstTA_SubTAFinal = new List<Product_vod__c> ();
		
		String tempId=null;
		if(mapProdId.values().size()>0){
			for(Product_vod__c prod: mapProdId.values()){
				lst1TA_SubTA.add(prod.Name + '-' + (String)prod.Id);
				map4TA_SubTAId.put((String)prod.Id, prod);
			}
			lst1TA_SubTA.sort();
			for(String strProd: lst1TA_SubTA){
				if(strProd.lastIndexOf('-') !=-1){
					tempId = strProd.substring(strProd.lastIndexOf('-')+1).trim();
				}
				if(map4TA_SubTAId.size() >0 && map4TA_SubTAId.containsKey(tempId)){
					lstTA_SubTAFinal.add(map4TA_SubTAId.get(tempId));
				}
				tempId = null;
			}
		}
		return lstTA_SubTAFinal;
	}

	public void loadDefautTA_SubTA(){
		if (lstdefautTASubTAs != null && lstdefautTASubTAs.size() >0){
			lstdefautTASubTAs.clear();
		}
		if(selectedProductId!=null && mapProductToTASubTA != null && mapProductToTASubTA.size() >0 && mapProductToTASubTA.containsKey(selectedProductId)){
			lstdefautTASubTAs.add(mapProductToTASubTA.get(selectedProductId));
			selectedTA_SubTA = mapProductToTASubTA.get(selectedProductId);              
		}else{
			selectedTA_SubTA = null;
			selectedMoleculeId = null;
			if (lstdefautTASubTAs != null && lstdefautTASubTAs.size() >0){
				lstdefautTASubTAs.clear();
			}
			if(lstdefautMolecules != null && lstdefautMolecules.size()>0){
				lstdefautMolecules.clear();
			}
		}
		System.debug('lstdefautTASubTAs: --> ' + lstdefautTASubTAs);
		loadDefautMolecule();
	}
	
	public List<SelectOption> getTA_SubTAList(){   
		Integer i=0;
		Map<Id,Product_vod__c> map2TA_SubTAId = mapTA_SubTAId.clone();
		List<Product_vod__c> lstTA_SubTA = new List<Product_vod__c> ();
		List<SelectOption> options=new List<SelectOption>();
		
		if(map2TA_SubTAId != null && map2TA_SubTAId.size() >0){
			if(lstdefautTASubTAs !=null && lstdefautTASubTAs.size() >0){
				for(Id defautTA_SubTA: lstdefautTASubTAs){
					if(defautTA_SubTA != null && map2TA_SubTAId.containsKey(defautTA_SubTA))
					map2TA_SubTAId.remove(defautTA_SubTA);                  
				}
			}else{
				options.add(new SelectOption('', '--None--'));
				selectedTA_SubTA = null;                
			}
			lstTA_SubTA = getSortedList(map2TA_SubTAId);
			if(lstTA_SubTA!=null && lstTA_SubTA.size()>0){
				for(Product_vod__c prod: lstTA_SubTA){
					options.add(new SelectOption(prod.Id, prod.Name));    
				}
			}
		}
		
		if(mapTA_SubTAId != null && mapTA_SubTAId.size() >0){
			if (options.size() > 0 && lstdefautTASubTAs !=null && lstdefautTASubTAs.size() >0) {
				for(Id defautTA_SubTA: lstdefautTASubTAs){
					if(mapTA_SubTAId != null && mapTA_SubTAId.size() >0 && mapTA_SubTAId.containsKey(defautTA_SubTA)){
						if(i==0){
							selectedTA_SubTA = defautTA_SubTA;
						}
						options.add(0,new SelectOption(defautTA_SubTA, mapTA_SubTAId.get(defautTA_SubTA).Name));
						i = i+1;
					}
				}
				options.add(new SelectOption('', '--None--'));
			}
		}
		return options;
	}
	
	public List<SelectOption> getProductList(){               
		List<SelectOption> options=new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		
		if(lstProducts!=null && lstProducts.size()>0){
			for(Product_vod__c prod: lstProducts  ){
				options.add(new SelectOption(prod.Id, prod.Name));    
			}
		}
		return options;
	}
	
	public void loadDefautMolecule(){
		System.debug('selectedTA_SubTA: --> ' + selectedTA_SubTA);
		if (lstdefautMolecules != null && lstdefautMolecules.size() >0){
			lstdefautMolecules.clear();
		}
		
		if(selectedTA_SubTA!=null){
			List<TASubTA_To_Molecule_gne__c> lstTASubTAToMolecules = [Select Id, Name,Default_gne__c,Product_TA_SubTA_gne__c,Product_TA_SubTA_gne__r.Name,Product_Molecule_gne__c, Product_Molecule_gne__r.Name from TASubTA_To_Molecule_gne__c where Product_TA_SubTA_gne__c= : selectedTA_SubTA];   
			for(TASubTA_To_Molecule_gne__c objTAToMol: lstTASubTAToMolecules  ){
				if(objTAToMol != null && objTAToMol.Product_Molecule_gne__c != null){
					lstdefautMolecules.add(objTAToMol.Product_Molecule_gne__c);
					System.debug('objTAToMol.Product_Molecule_gne__c: --> ' + objTAToMol.Product_Molecule_gne__c);
				}
			}
		}else{
			selectedMoleculeId = null;
		}
		System.debug('lstdefautMolecules: --> ' + lstdefautMolecules);
	}
	
	public List<SelectOption> getMoleculeList(){   
		Integer i=1;
		Map<Id,Product_vod__c> map2Molecule = mapMoleculeId.clone();
		List<Product_vod__c> lstMolecule = new List<Product_vod__c> ();
		List<SelectOption> options=new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		
		if(map2Molecule != null && map2Molecule.size() >0){
			if(lstdefautMolecules !=null && lstdefautMolecules.size() >0){
				for(Id defautMolecule: lstdefautMolecules){
					if(defautMolecule != null && map2Molecule.containsKey(defautMolecule)){
						map2Molecule.remove(defautMolecule);        
					}
				}
			}else{
				lstMolecule = getSortedList(map2Molecule);
				if(lstMolecule!=null && lstMolecule.size()>0){
					for(Product_vod__c prod: lstMolecule){
						options.add(new SelectOption(prod.Id, prod.Name));    
					}
				}
			}
		}
		if(mapMoleculeId != null && mapMoleculeId.size() >0){
			if (options.size() > 0 && lstdefautMolecules !=null && lstdefautMolecules.size() >0) {
				for(Id defautMolecule: lstdefautMolecules){
					if(mapMoleculeId != null && mapMoleculeId.size() >0 && mapMoleculeId.containsKey(defautMolecule)){
						options.add(new SelectOption(defautMolecule, mapMoleculeId.get(defautMolecule).Name));                      
					}
				}               
			}
		}
		return options;
	}

	public Address_vod__c getSelectedAddress(){
		Address_vod__c result;
		if(mapAddressId != null && selectedAddressId!=null && mapAddressId.containsKey(selectedAddressId)){
			result = mapAddressId.get(selectedAddressId); 
		}else{
			result = new Address_vod__c();
		}
		objReferralProxy.Phone_gne__c = result.Phone_vod__c; 
		return result;
	}
	
	public Boolean getIsPhoneEmpty(){
		return String.isEmpty(getSelectedAddress().Phone_vod__c);
	}
	
	//action functions
	public void hcpAddress(){
		getSelectedAddress();
	}
	
	public PageReference cancel() {
		PageReference p = new PageReference('/'+ account.Id);
		p.setRedirect(true);
		return p;
	}
	
	public PageReference save() {
		PageReference p = null;
		GNE_Referral_Utils.isMedicalReferral = true;
		System.debug('disableInput: ' + disableInput);
		System.debug('searchFld: ' + searchFld);
		if((!disableInput) && searchFld == ''){
			System.debug('Please enter the value for Assigned To.');
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please specify the "Assigned To" person, or select "Auto Assignment".'));
			GNE_Referral_Utils.isMedicalReferral = false;
			return null;
		}   
		//Requested Completion Date should be greater than or equal today.
		if(String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c) != null && objReferralProxy.Requested_Completion_Date_gne__c < Date.today()){
			System.debug('Requested Completion Date should be greater than or equal today.');
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Requested Completion Date should be greater than or equal today.'));
			GNE_Referral_Utils.isMedicalReferral = false;
			return null;
		}else {
			//Requested By field is editable by MedAffair profile user only as they can raise referra on behalf of MCCO users.
			if(getIsMCLUser()){
				if(!isMedComm){
					if(searchFld1 != null && searchFld1 != ''){
						List<User> lstReqByUserIds = GNE_Referral_Utils.getRequestedByUser(searchFld1);
						if (lstReqByUserIds != null && lstReqByUserIds.size() >0){
							if(lstReqByUserIds.size() ==1){
								objReferralProxy.Requested_By_gne__c = lstReqByUserIds[0].Id;
							}else{
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Multiple User found. Click Lookup icon at Requested By Field to refine the search.'));
								GNE_Referral_Utils.isMedicalReferral = false;
								return null;
							}
						}else{
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No User found. Click Lookup icon at Assigned To Field to select appropriate user.'));
							GNE_Referral_Utils.isMedicalReferral = false;
							return null;
						}
					}else{
						objReferralProxy.Requested_By_gne__c = UserInfo.getUserId();
					}
					
				}
				/*
			if(isMedComm && (String)objReferralProxy.Requested_By_gne__c !=null){
				System.debug('Please uncheck the Is MedComm checkbox if you wanted to enter Requested By user value Or Clear the Requested By user value.');
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please uncheck the Is MedComm checkbox if you wanted to enter Requested By user value Or Clear the Requested By user value.'));
				GNE_Referral_Utils.isMedicalReferral = false;
				return null;
			}
			*/
				if((String)objReferralProxy.Requested_By_gne__c==null || (String)objReferralProxy.Requested_By_gne__c==''){
					if(!isMedComm){
						objReferralProxy.Requested_By_gne__c = UserInfo.getUserId();
					}           
				}
			}else{
				objReferralProxy.Requested_By_gne__c = UserInfo.getUserId();
			}
			if(isValid()){  
				try{
					GNE_Med_iPhone_CreateReferral.ReferralInfo refInfo = new GNE_Med_iPhone_CreateReferral.ReferralInfo();
					refInfo.AccountId = account.Id;
					refInfo.AddressId = selectedAddressId;
					refInfo.MedicalQuestion = question;
					refInfo.FollowupMethod = objReferralProxy.Follow_up_Method_gne__c;
					refInfo.ProductId = selectedProductId;
					refInfo.MoleculeId = selectedMoleculeId;
					refInfo.TA_SubTAId = selectedTA_SubTA;
					refInfo.phone = objReferralProxy.Phone_gne__c;
					if(String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c) != null){
						refInfo.RequestedCompletionDate = objReferralProxy.Requested_Completion_Date_gne__c;
					}
					refInfo.Priority = objReferralProxy.Priority_gne__c;
					if((String)objReferralProxy.Requested_By_gne__c!=null && (String)objReferralProxy.Requested_By_gne__c!=''){
						refInfo.RequestedById = objReferralProxy.Requested_By_gne__c;
						refInfo.isMedComm = false;
					}else{
						refInfo.isMedComm = isMedComm;
					}
					refInfo.UserId = UserInfo.getUserId();
					
					System.debug('searchFld: ' + searchFld);
					if(searchFld != null && searchFld != ''){
						List<User> lstUserIds = GNE_Referral_Utils.getAssignedUser(searchFld,'Create');
						System.debug('lstUserIds: ' + lstUserIds);
						if (lstUserIds != null && lstUserIds.size() >0){
							if(lstUserIds.size() ==1){
								refInfo.AssignedToId = lstUserIds[0].Id;
							}else{
								System.debug('Multiple User found. Click Lookup icon at Assigned To Field to refine the search.:');
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Multiple User found. Click Lookup icon at Assigned To Field to refine the search.'));
								GNE_Referral_Utils.isMedicalReferral = false;
								return null;
							}
						}else{
							System.debug('No User found. Click Lookup icon at Assigned To Field to select appropriate user.:');
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No User found. Click Lookup icon at Assigned To Field to select appropriate user.'));
							GNE_Referral_Utils.isMedicalReferral = false;
							return null;
						}
					}else{
						refInfo.AssignedToId = null;
					}
					
					GNE_Med_iPhone_CreateReferral.Response callResponse = GNE_Med_iPhone_CreateReferral.createReferral(refInfo, false);
					System.debug('callResponse: ' + callResponse);
					if(callResponse != null){
						if(callResponse.ErrorMessage != null && callResponse.ErrorMessage != ''){
							for (String strErrMsg : callResponse.ErrorMessage.split(',')) {
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strErrMsg));                        
							}                       
							GNE_Referral_Utils.isMedicalReferral = false;
							return null;
						}else{
							if(callResponse.getResponseReferral() != null && callResponse.getResponseReferralAssignment() != null){
								p = new PageReference('/'+ callResponse.getResponseReferral().Referral_Assignment_gne__c);
							}else{
								ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,callResponse.ErrorMessage));
								GNE_Referral_Utils.isMedicalReferral = false;
								return null;
							}
						}                   
					}else{
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page' + callResponse));
						GNE_Referral_Utils.isMedicalReferral = false;
						return null;
					}
				}catch (Exception e) {
					System.debug('Error on the page:' + e);
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page' + e));
					GNE_Referral_Utils.isMedicalReferral = false;
					return null;
				}
			}else{
				System.debug('Input Required for below fields:' + strErrorMsg);
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Input Required for below fields:' + strErrorMsg));
				GNE_Referral_Utils.isMedicalReferral = false;
				return null;
			}
		}
		GNE_Referral_Utils.isMedicalReferral = false;
		return p;
	}

	private Boolean isValid(){   
		/*
		strErrorMsg='';
		if (selectedAddress==null){
			strErrorMsg = 'Address';
			blnIsValid=False;
		}
		
		if((String)question==null || (String)question==''){
			if(strErrorMsg==''){
				strErrorMsg = 'Medical Question';               
			}
			else{
				strErrorMsg = strErrorMsg + ', Medical Question';
			}
			blnIsValid=False;           
		}
		
		if((String)selectedProductId=='' || (String)selectedProductId==null){
			if(strErrorMsg==''){
				strErrorMsg = 'Product';                
			}
			else{
				strErrorMsg = strErrorMsg + ', Product';
			}
			blnIsValid=False;
		}
		
		if((String)selectedMoleculeId==null || (String)selectedMoleculeId==''){
			if(strErrorMsg==''){
				strErrorMsg = 'Molecule';               
			}
			else{
				strErrorMsg = strErrorMsg + ', Molecule';
			}
			blnIsValid=False;
		}
		
		if((String)selectedTA_SubTA==null || (String)selectedTA_SubTA==''){
			if(strErrorMsg==''){
				strErrorMsg = 'TA_SubTA';               
			}
			else{
				strErrorMsg = strErrorMsg + ', TA_SubTA';
			}
			blnIsValid=False;
		}
		*/
		return true;
	}
}