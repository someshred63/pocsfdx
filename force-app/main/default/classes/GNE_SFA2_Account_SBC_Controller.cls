public with sharing virtual class GNE_SFA2_Account_SBC_Controller extends GNE_Base_Controller {
	//class constants
	public static String NEW_ADDR_PAGE_URL = '/apex/GNE_SFA2_Address_Edit_Create_Layout';
	public static final String REC_TYPE_HCP = 'Professional_vod';
	public static final String REC_TYPE_LWO_HCP = 'LWO Healthcare Professional_gne';
	public static final String REC_TYPE_LWO_HCO = 'LWO Health Care Organization_gne';
	public static final String REC_TYPE_CP = 'Contracted_Patient_gne';

	public static final String REC_TYPE_ACC_CAN_HCO = 'GNE-SFA-Roche_Canada';
	public static final String REC_TYPE_ACC_CAN_HCO_Developer = 'GNE_SFA_Roche_Canada_can';
	public static final String REC_TYPE_ACC_CAN_HCP = 'HCP Canada';
	public static final String REC_TYPE_ACC_CAN_HCP_Developer = 'HCP_Canada';

	public static final String REC_TYPE_ADDR = 'RepMaintained';
	public static final String REC_TYPE_ADDR_CAN_HCO = 'SFA Canada Rep Maintained HCO';
	public static final String REC_TYPE_ADDR_CAN_HCP = 'SFA Canada Rep Maintained HCP';

	public static final String CLASS_NAME = 'GNE_Account_Search_Create_Controller';
	public static final String NONE_SELECTED = '--None--';
	public static final String NO_TERRITORY_SELECTED = '--Do Not Align--';
	public static final String DEFAULT_PAGE_TITLE = 'Search Before Create';
	public static final String SEARCH_PAGE_TITLE = 'Account Search';
	public static final String ERROR_MSG_SUB_ADDR = 'An error occurred in the attempt to load this address.  The address was created, but license information could not be accessed.  If license information is required, please submit a Remedy ticket to support.  Press Cancel to return to the Account page.';
	public static final String ERROR_MSG_SUB_ACCT = 'An error occurred in the attempt to load this Account.  Please submit a Remedy ticket to support.';

	//used to perform profile specific logic
	public String profileName;
	//used to store value from custom setting, used to re-direct some users to old page.
	public String profiles;

	//full path needed for links in certain browser versions.  Store in host.
	public String host  {get; set;}
	//displays title which differs depending on where user is coming from
	public String pageTitle {get; set;}
	//pager is a container object holding search parameters, search result list and
	//supporting fields/methods
	public GNE_Account_Pager pager {get;set;}
	//acctType designates current search type - it is either "HCO" or "HCP"
	public String acctType {get;set;}
	//next 3 variables control enabling the "create new account" button - only after a search has been done
	public Boolean hasSearchedForHCO {get;set;}
	public Boolean hasSearchedForHCP {get;set;}
	public Boolean showCreateNew {get;set;}
	//mode of page - can be displayed as a popup depending on where user is coming from
	public Boolean isPopup {get; set;}
	//mode of popup page... sometimes this page is opened modally which may require special logic
	public Boolean isModal {get; set;}
	public transient List<SelectOption> SpecTypeList;
	//list of HCO Account types read from custom setting GNE_Foun_Org_Type_Map_gne__c
	public transient List<SelectOption> orgTypeList;
	//list of HCO Account types read from custom setting GNE_Foun_Role_Ranking_gne__c
	public transient List<SelectOption> profTypeList;
	//list of RuleSet names read from custom setting GNE_FOUN_RuleSet_Matrix_gne__c
	public transient List<SelectOption> ruleSetNameList { get; set;}
	// CANADA
	public String selectedSpecType {get;set;}
	//account type selected by user during HCO account creation
	public String selectedOrgType {get;set;}
	//professional type selected by user during HCP account creation
	public String selectedProfType {get;set;}
	//can be either "BOTH", "HCP", or "HCO", depending on where the user is coming from
	public String allowedType {get;set;}
	// variable used to hold the ruleSet Name for Admin only
	public String ruleInput {get;set;}
	public String ruleInputDispAdmin {get;set;}
	//variable used to hold newly created accounts
	public Account newAcct {get;set;}
	public Account fakeAcct {get;set;}
	public Address_vod__c fakeAddress {get;set;}
	public String newId {get;set;}
	public SFASearchStrings_gne__c newAddr {get;set;}
	//list of territories for the currently logged on user.  This is used in the Create New Account page.
	public  transient List <SelectOption> territoryList { get; set;}
	//territory selected by user during account creation.  This is the territory the account will be aligned with
	public String selectedTerritory { get; set;}
	//next 4 variables are parameters that may be passed in to the setup method
	public transient String sIsPopup = '';
	public transient String sIsModal = '';
	public transient String sAllowedType = '';
	public transient String sAddrId = '';
	public transient String sAccountforAffiliation = '';
	//Distinguishes LWO (Lucentis Web Ordering) users from others
	public Boolean hasLWOProfile;
	//Distinguishes Canada users from others
	public Boolean hasCanadaProfile;
	//Distinguishes OPS users from others
	public Boolean hasOPSProfile;
	//next 3 variables are data access objects used by class to rerieve data
	private transient GNE_Account_Dao acctDao;
	private transient GNE_Account_Search_Dao searchDao;
	private transient GNE_Territory_Dao terrDao;
	//holds map of record type names and ids used in the account creation process
	private transient Map<String, Map<String, RecordType>> recTypeNameToObj;
	//---Reference to standard controller
	public ApexPages.StandardController StdCont { get; set;}
	// holds information that search return more than limited results
	private Boolean isTrrigerfromsearchLess;
	//--pointer to new address object
	public Address_vod__c addr { get; set;}
	public String addrRecTypeId;
	public String accRecTypeId;

	public String getAddrRecTypeId(){
		List<RecordType> recTypes;
		if (addrRecTypeId == null){
			if(getHasCanadaProfile()){
				if(acctType == 'HCP'){
					recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR_CAN_HCP);
				}else{
					recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR_CAN_HCO);
				}
			}else{
				recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR);
			}
			if (recTypes != null && recTypes.size() > 0) {
				addrRecTypeId = recTypes[0].Id;
			}
		}
		return addrRecTypeId;
	}

	public String getAccRecTypeId(){
		List<RecordType> recTypes;

		if(getHasCanadaProfile()){
			if(acctType == 'HCP'){
				recTypes = fetchRecordTypes('Account', REC_TYPE_ACC_CAN_HCP_Developer);
			}else{
				recTypes = fetchRecordTypes('Account', REC_TYPE_ACC_CAN_HCO_Developer);
			}
		}else{
			recTypes = fetchRecordTypes('Account', REC_TYPE_HCP);
		}
		if (recTypes != null && recTypes.size() > 0) {
			accRecTypeId = recTypes[0].Id;
		}
		return accRecTypeId;
	}

	public Boolean getShowMdmId(){
		Boolean showMdmId = false;
		Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();
		if (mapConfigItems != null && mapConfigItems.size() > 0 &&  mapConfigItems.get('SearchShowMDMId') != null){
			String profiles = (String) mapConfigItems.get('SearchShowMDMId').Configuration_Value_gne__c;

			if (profiles.contains('ALL')){
				showMdmId = true;
			} else{
				List<String> splitFields = profiles.split(',');
				if (splitFields != null && splitFields.size() > 0){
					for (String row : splitFields){
						if (profileName != null && profileName.toUpperCase().contains(row.toUpperCase())){
							showMdmId = true;
							break;
						}
					}
				}
			}
		}
		return showMdmId;
	}

	//method to indicate whether HCO, HCP or BOTH account types can be searched
	public Boolean getShowBothTypes(){
		if (allowedType != null && allowedType == 'BOTH') return true;
		return false;
	}

	//method to indicate whether the logged on user is a Lucentis Web Order user (LWO)
	public Boolean getHasLWOProfile(){
		if (hasLWOProfile == null){
			if (profileName != null && profileName.toUpperCase().contains('LWO')){
				hasLWOProfile = true;
			} else{
				hasLWOProfile = false;
			}
		}
		return hasLWOProfile;
	}

	//method to indicate whether the logged on user is a Canada user
	public Boolean getHasCanadaProfile() {
		if (hasCanadaProfile == null) {
			if (profileName != null && profileName.toUpperCase().contains('CANADA')) {
				hasCanadaProfile = true;
			} else {
				hasCanadaProfile = false;
			}
		}
		return hasCanadaProfile;
	}

	//method to indicate whether the logged on user is a Canada SAM user
	public Boolean getHasSAMProfile() {
		return (profileName != null && profileName.toUpperCase().equals('RCANADA-SFA-SAM')) ? true : false;
	}

	public Boolean getHasRAMAProfile() {
		return (profileName != null && profileName.toUpperCase().equals('RCANADA-SFA-RAMA')) ? true : false;
	}

	//method to indicate whether the logged on user is a SFA-OPS user
	public Boolean getHasOPSProfile() {
		if (hasOPSProfile == null) {
			if (profileName != null && profileName.toUpperCase().contains('SFA-OPS')) {
				hasOPSProfile = true;
			} else {
				hasOPSProfile = false;
			}
		}
		return hasOPSProfile;
	}

	public Boolean getHasSysAdminProfile(){
		return (profileName != null && profileName.toUpperCase().contains('SYS')) ? true : false;
	}

	public Boolean getHasReadOnlyProfile(){
		return (profileName != null && profileName.toUpperCase().contains('READONLY')) ? true : false;
	}

	public Boolean getTooManyResults(){
		return pager.ShowTooManyResults;
	}

	//get Account types in a list of SelectOption.
	public List<SelectOption> getItems(){
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('HCO','Organization (HCO)', GNE_SFA2_Util.isCanadaINFUUser()));
		options.add(new SelectOption('HCP','Professional (HCP)'));
		return options;
	}

	public List<SelectOption> getSpecType(){
		List<SelectOption> options = new List<SelectOption>();

		Schema.DescribeFieldResult Specialties_gne = Account.Specialties_can_gne__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = Specialties_gne.getPicklistValues();

		for(Schema.PicklistEntry temp :picklistValues){
			options.add(new SelectOption(temp.getLabel(),temp.getValue()));
		}
		SpecTypeList = options;
		return SpecTypeList;
	}

	//get list of HCO Account Types via Custom Setting, filter those to show only those
	//with a record type that the user has access to
	public List<SelectOption> getOrgTypes(){
		List<SelectOption> options;
		if(orgTypeList == null){
			options = new List<SelectOption>();
			options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
			// Retreive record types that are valid for the logged on user
			Map <String, String> recTypeMap = getAccountRecordTypes();
			// Retrieve org type to record type map from Custom Setting
			if(getHasCanadaProfile()){
				if(getHasSAMProfile()) {
					Map <String, GNE_SFA_Canada_SAM_HCO_Record_Types__c> orgTypeMap = GNE_SFA_Canada_SAM_HCO_Record_Types__c.getAll();
					
					for(GNE_SFA_Canada_SAM_HCO_Record_Types__c row : orgTypeMap.values()){
						options.add(new SelectOption(row.RecordType__c, row.RecordType__c));						
					}
					sortSelectOptions(options, 1, options.size() - 1);
					orgTypeList = removeDups(options);
				} else if(getHasRAMAProfile()) {
					Map <String, GNE_SFA_Canada_RAMA_HCO_Record_Types__c> orgTypeMap = GNE_SFA_Canada_RAMA_HCO_Record_Types__c.getAll();
					
					for(GNE_SFA_Canada_RAMA_HCO_Record_Types__c row : orgTypeMap.values()){
						options.add(new SelectOption(row.RecordType__c, row.RecordType__c));						
					}
					sortSelectOptions(options, 1, options.size() - 1);
					orgTypeList = removeDups(options);
				} else {
					Map <String, GNE_SFA_Canada_HCO_Record_Types__c> orgTypeMap = GNE_SFA_Canada_HCO_Record_Types__c.getAll();

					String recTypeId;
					for(GNE_SFA_Canada_HCO_Record_Types__c row : orgTypeMap.values()){
						if (recTypeMap.containsKey(row.RecordType__c)){
							recTypeId = recTypeMap.get(row.RecordType__c);
							options.add(new SelectOption(row.RecordTypeDisplay__c + ',' + recTypeId, row.RecordTypeDisplay__c));
						}
					}
					sortSelectOptions(options, 1, options.size() - 1);
					orgTypeList = removeDups(options);
				}
			}else{
				Map <String, GNE_Foun_Org_Type_Map_gne__c> orgTypeMap = GNE_Foun_Org_Type_Map_gne__c.getAll();
				String recTypeId;
				for(GNE_Foun_Org_Type_Map_gne__c row : orgTypeMap.values()){
					debug('row.Account_Record_Type_gne__c='+row.Account_Record_Type_gne__c);
					if (recTypeMap.containsKey(row.Account_Record_Type_gne__c)){
						recTypeId = recTypeMap.get(row.Account_Record_Type_gne__c);
						options.add(new SelectOption(row.Account_Record_Type_Display_gne__c + ',' + recTypeId, row.Account_Record_Type_Display_gne__c));
					}
				}
				sortSelectOptions(options, 1, options.size() - 1);
				orgTypeList = removeDups(options);
			}
		}
		return orgTypeList;
	}

	//get list of HCP Professional Types via Custom Setting
	public List<SelectOption> getProfTypes(){
		List<SelectOption> options;
		if(profTypeList == null){
			options = new List<SelectOption>();
			options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));

			if(getHasCanadaProfile()){
				if(getHasSAMProfile()) {
					Map <String, GNE_SFA_Canada_SAM_HCP_Record_Types__c> typeMap = GNE_SFA_Canada_SAM_HCP_Record_Types__c.getAll();
					if(typeMap != null && typeMap.size() > 0){
						for (GNE_SFA_Canada_SAM_HCP_Record_Types__c row : typeMap.values()){
							options.add(new SelectOption(row.RecordType__c, row.RecordType__c));
						}
					}
				} else if(getHasRAMAProfile()) {
					Map <String, GNE_SFA_Canada_RAMA_HCP_Record_Types__c> typeMap = GNE_SFA_Canada_RAMA_HCP_Record_Types__c.getAll();
					if(typeMap != null && typeMap.size() > 0){
						for (GNE_SFA_Canada_RAMA_HCP_Record_Types__c row : typeMap.values()){
							options.add(new SelectOption(row.RecordType__c, row.RecordType__c));
						}
					}
				} else {
					Map <String, GNE_SFA_Canada_HCP_Record_Types__c> typeMap = GNE_SFA_Canada_HCP_Record_Types__c.getAll();
					if(typeMap != null && typeMap.size() > 0){
						for (GNE_SFA_Canada_HCP_Record_Types__c row : typeMap.values()){
							options.add(new SelectOption(row.RecordType__c, row.RecordType__c));
						}
					}
				}
				sortSelectOptions(options, 1, options.size() - 1);
				profTypeList = removeDups(options);
			}else{
				Map <String, GNE_Foun_Role_Ranking_gne__c> typeMap = GNE_Foun_Role_Ranking_gne__c.getAll();
				if(typeMap != null && typeMap.size() > 0){
					for (GNE_Foun_Role_Ranking_gne__c row : typeMap.values()){
						options.add(new SelectOption(row.Account_Professional_Type_gne__c, row.Account_Professional_Type_gne__c));
					}
					sortSelectOptions(options, 1, options.size() - 1);
					profTypeList = removeDups(options);
				}
			}
		}
		return profTypeList;
	}

	//get list of RuleSetName via Custom Setting
	public List<SelectOption> getRules(){
		List<SelectOption> options;
		if (ruleSetNameList == null){
			options = new List<SelectOption>();
			options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
			Map<String, GNE_FOUN_RuleSet_Matrix_gne__c> mapRuleSetItems = GNE_FOUN_RuleSet_Matrix_gne__c.getAll();
			if (mapRuleSetItems != null && mapRuleSetItems.size() > 0){
				for (GNE_FOUN_RuleSet_Matrix_gne__c row : mapRuleSetItems.values()){
					options.add(new SelectOption(row.Name,row.Name));
				}
				ruleSetNameList = options;
			}
		}
		return ruleSetNameList;
	}

	//get list of territories assigned to current user
	public List<SelectOption> getTerritories(){
		List<SelectOption> options;
		if (territoryList == null){
			options = new List<SelectOption>();
			terrDao = new GNE_Territory_Dao();
			List <Territory2> terrList = terrDao.getByUser(Userinfo.getUserId());
			if (terrList != null && terrList.size() > 0){
				for (Territory2 row : terrList){
					options.add(new SelectOption(row.Id,row.Name));
				}
				options.add(new SelectOption(NO_TERRITORY_SELECTED, NO_TERRITORY_SELECTED));
				territoryList = options;
			}
		}
		return territoryList;
	}

	//method to indicate whether current user is assigned to any territories
	public Boolean getHasTerritories(){
		if (getTerritories() != null && getTerritories().size() > 0) return true;
		return false;
	}

	//controls showing/hiding of result list portion of page
	public Boolean getShowResults(){
		if (hasSearchedForHCO || hasSearchedForHCP) return true;
		return false;
	}

	//controls disabling/enabling of the Create New Account button
	public Boolean getHasSearched(){
		if ((acctType == 'HCO' && hasSearchedForHCO)) return true;
		if ((acctType == 'HCP' && hasSearchedForHCP)) return true;
		return false;
	}

	//standard constructor
	public GNE_SFA2_Account_SBC_Controller(ApexPages.StandardController cont){
		IsTestCase = false;
		StdCont = cont;
		init();
	}

	//no arg constructor
	public GNE_SFA2_Account_SBC_Controller(){
		IsTestCase = true;
		init();
	}

    // remote usage controller
    public GNE_SFA2_Account_SBC_Controller(Boolean isTestCase, Boolean isRemoteMode) {
        this.isTestCase = isTestCase;
        this.isRemoteMode = isRemoteMode;
        init();
    }

	//called by all constructors for initialization
	public void init(){
		Pager = new GNE_Account_Pager(IsTestCase);
		hasSearchedForHCO = false;
		hasSearchedForHCP = false;
		showCreateNew = false;
		isPopup = false;
		isModal = false;
		allowedType = 'BOTH';
		ruleInput = '--None--';
		ruleInputDispAdmin = '';
		selectedOrgType= '';
		selectedProfType = '';
		isTrrigerfromsearchLess = false;
		profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
		host = URL.getSalesforceBaseUrl().toExternalForm();

		acctType = Pager.currSearch.AccountType_gne__c;
        fakeAddress = new Address_vod__c();

		if(getHasCanadaProfile()) {
			system.debug('MICK :init(): acctType = ' + acctType);
			system.debug('MICK SFA-174 : Rec Id ' +  getAccRecTypeId());
			// For Canada user only , fake acc and address to populate picklist values
			fakeAcct = new Account();
			fakeAcct.RecordTypeId = getAccRecTypeId();
			fakeAcct.Account_Type_gne__c = null;
			fakeAddress.RecordTypeId = getAddrRecTypeId();
		}
	}

	//this method is called upon invocation of GNE_Account_Search_Create_Help.page.
	public PageReference setupHelp(){
		String sCreateNew;
		if (!IsTestCase){
			sIsPopup = System.currentPageReference().getParameters().get('isPopup');
			sIsModal = System.currentPageReference().getParameters().get('isModal');
			acctType = System.currentPageReference().getParameters().get('acctType');
			sCreateNew = System.currentPageReference().getParameters().get('showCreateNew');

		}
		if (sIsPopup == 'true') isPopup = true;
		if (sIsModal == 'true') isModal = true;
		if (sCreateNew == 'true') ShowCreateNew = true;
		return null;
	}

	//this method is called upon invocation of GNE_Account_Address_Search.page,
	//which is reached via the "new" address button
	public PageReference setupAddress(){
		hasSearchedForHCO = true;
		hasSearchedForHCP = true;
		try{
			SObject sobjectInstance = StdCont.getRecord();
			if(sobjectInstance != null){
				addr = (Address_vod__c) sobjectInstance;
				acctDao = new GNE_Account_Dao(IsTestCase);
				Account acct = acctDao.getById(addr.Account_vod__c);
				if (acct != null && !isNullOrEmpty(acct.MDMID_gne__c) && !getHasCanadaProfile()){
					Pager.clearCriteria();
					Pager.clearQueryFields();
					Pager.acct = acct;
					Pager.loadData();
					if(Pager.getDispList() == null || Pager.getDispList().size() == 0){
						debug('no addresses found... go directly to create new address');
						return redirectToAddressLayout();
					}
				}else{
					debug('no mdmId, go directly to create new address');
					return redirectToAddressLayout();
				}
			}
		}catch (Exception ex){
			handleError(CLASS_NAME, 'setupAddress', ex);
		}
		return null;
	}

	private void filterResultList(){
		System.debug('kwiatkol - Filter result set');
		GNE_Stg_Party_Dao ptyDao = new GNE_Stg_Party_Dao(IsTestCase);
		String sfdcAddressId = '';

		Map <String, Address_vod__c> addrIdMap = acctDao.getAddressesForAccountId(Pager.acctId);
		if (addrIdMap != null && addrIdMap.size() > 0){
			List <SFASearchStrings_gne__c> filteredList = new List <SFASearchStrings_gne__c>();
			for (SFASearchStrings_gne__c row : Pager.getDispList()){
				sfdcAddressId = ptyDao.getSFDCAddressId(row.Address_Mdm_Id_gne__c);
				if (sfdcAddressId == null || sfdcAddressId.length() == 0){
					filteredList.add(row);
				}
			}
			Pager.setDispList(filteredList);
		}
	}

	public PageReference cancelAddress(){

		PageReference pageRef;
		String retURL = ApexPages.currentPage().getParameters().get('retURL');
		if (retURL != null){
			pageRef = new PageReference(retUrl);
		} else{
			//if retUrl is not available, try to redirect to Account view layout directly.
			if (addr != null && !isNullOrEmpty(addr.Account_vod__c)){
				pageRef = new PageReference('/'+addr.Account_vod__c);
			}
		}
		return pageRef;
	}

	public PageReference redirectToAddressLayout(){
		String retURL = ApexPages.currentPage().getParameters().get('retURL');
		//String recType = ApexPages.currentPage().getParameters().get('RecordType');
		//String configKey = ApexPages.currentPage().getParameters().get('CF00N70000001tDKx');
		String configKeyLookup = ApexPages.currentPage().getParameters().get('CF00N70000001tDKx_lkid');
		String inpId = ApexPages.currentPage().getParameters().get('id');
		//String sfdcoverride = ApexPages.currentPage().getParameters().get('sfdc.override');
		String accountId = ApexPages.currentPage().getParameters().get('accountId');

		PageReference addrLayout = new PageReference(NEW_ADDR_PAGE_URL);
		addrLayout.getParameters().put('retURL',retUrl);
		//set record type here to "Rep Maintained".  This is done to avoid the default SFDC record type selection page.
		addrLayout.getParameters().put('preSetRecordType',getAddrRecTypeId());
		//addrLayout.getParameters().put('CF00N70000001tDKx',configKey);
		addrLayout.getParameters().put('CF00N70000001tDKx_lkid',configKeyLookup);
		addrLayout.getParameters().put('accountId',accountId);
		//addrLayout.getParameters().put('nooverride', '1');
		//set sfdc.override flag to false here to that the user will be re-directed to the standard "New" page layout
		//addrLayout.getParameters().put('sfdc.override', '0');

		addrLayout.setRedirect(true);
		debug('kwiatkol redirect end');
		return addrLayout;
	}

	//this method is called upon invocation of GNE_Account_Search_Create.page.
	public PageReference setup(){
		try{
			if (!IsTestCase){
				sIsPopup = System.currentPageReference().getParameters().get('isPopup');
				sIsModal = System.currentPageReference().getParameters().get('isModal');
				sAllowedType = System.currentPageReference().getParameters().get('allowType');
				pageTitle = System.currentPageReference().getParameters().get('pgTitle');
				sAccountforAffiliation = System.currentPageReference().getParameters().get('lksrch');
			}

			system.debug('XXXX System.currentPageReference().getParameters().get lksrch ' + sAccountforAffiliation);
			if (!isNullOrEmpty(sAllowedType)) allowedType = sAllowedType;
			if (sIsPopup == 'true') isPopup = true;
			if (sIsModal == 'true') isModal = true;

			if(sAccountforAffiliation != null) Pager.currSearch.OrgName_gne__c = sAccountforAffiliation;

			if (allowedType == 'HCO'){
				Pager.currSearch.AccountType_gne__c = 'HCO';
			} else if (allowedType == 'HCP'){
				Pager.currSearch.AccountType_gne__c = 'HCP';
			}

			acctType = Pager.currSearch.AccountType_gne__c;
			if (pageTitle == 'SEARCH'){
				if (allowedType != 'BOTH'){
					pageTitle = allowedType + ' ' + ' SEARCH';
				} else{
					pageTitle = SEARCH_PAGE_TITLE;
				}
			} else{
				pageTitle = DEFAULT_PAGE_TITLE;
			}
			//this is code needed to implement the new account search create page
			//only for specific profiles.  All other users will
			//see the existing "Search Before Create" and "Advanced Account Search"
			//All instances where this page is used as a popup will not be redirected
			if (!IsPopup){
				PageReference redirect = checkForRedirect();
				if (redirect != null){
					redirect.setRedirect(true);
					return redirect;
				}
			}
		} catch (Exception e){
			handleError(CLASS_NAME, 'setup', e);
		}
		return null;
	}

	//This method decides whether to re-direct the user to the old
	//Search Before Create page and Advanced Account Search Page.
	//This is done using a Custom Setting.  Method can be removed
	//when this page is implemented for all profiles.
	public PageReference checkForRedirect(){
		Boolean showNew = false;
		Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();
		if (mapConfigItems != null && mapConfigItems.size() > 0){
			if (!IsTestCase){
				if  (mapConfigItems.get('SearchAccountShowNew') != null){
					profiles = (String) mapConfigItems.get('SearchAccountShowNew').Configuration_Value_gne__c;
				} else{
					showNew = true;
				}
			}
			if (profiles != null){
				if (profiles.contains('ALL')){
					showNew = true;
				} else{
					List<String> splitFields = profiles.split(',');
					if (splitFields != null && splitFields.size() > 0){
						for (String row : splitFields){
							if (profileName != null && profileName.contains(row)){
								showNew = true;
								break;
							}
						}
					}
				}
			}
		}

		if (showNew){
			return null;
		} else{
			if (pageTitle.contains('Before')){
				return new PageReference('/apex/GNE_Account_Search_Create_Redirect');
			} else{
				return new PageReference('/apex/AdvancedAccountSearch');
			}
		}
	}

	public void searchLess(){
		isTrrigerfromsearchLess = true;
		pager.SearchOnlyFirstMax = true;
		pager.ShowTooManyResults = false;
		system.debug('XX pager.SearchOnlyFirstMax  : ' + pager.SearchOnlyFirstMax);
		search();
	}

	//this method is called when the Search button is clicked by the user on the Account search page.
	public void search(){
		if(isTrrigerfromsearchLess == false) pager.SearchOnlyFirstMax = false;
		isTrrigerfromsearchLess = false;
		Pager.clearFullList();
		pager.ShowTooManyResults = false;

		if (!validateSearchCriteria()){
			if (acctType == 'HCO') hasSearchedForHCO = false;
			if (acctType == 'HCP') hasSearchedForHCP = false;
			return;
		}

		if (acctType == 'HCO'){
			hasSearchedForHCO = true;
		} else{
			hasSearchedForHCP = true;
		}

		try{
			system.debug('xxxx ruleInput = '+ ruleInput);
			Pager.RuleSetName = ruleInput;
			Pager.clearQueryFields();
			Pager.CurrSearch.AccountType_gne__c = acctType;
			Pager.loadData();
			searchDao = new GNE_Account_Search_Dao(IsTestCase);
			Boolean isSaved = searchDao.saveSObject(Pager.currSearch);

			if (Pager.getRecordCount() == 0){
				showMessage('There were no Accounts found for the current search criteria.');
			} else{
				Pager.currSortOrder = 'asc';
				Pager.CurrSort = null;
				sortName();
			}
			ruleInputDispAdmin = pager.RuleNameToDisp;
			pager.clearQueryFields();
		} catch (GNE_Account_Dao.TooManyResultsException ex){
			showError('The current search will return too much data. Please narrow your search by entering additional search criteria.');
			hasSearchedForHCO = false;
			hasSearchedForHCP = false;
		} catch (Exception ex){
			debug('Exception caught in search method.');
			handleError(CLASS_NAME, 'search', ex);
			hasSearchedForHCO = false;
			hasSearchedForHCP = false;
		}
	}

	public PageReference changeType(){
		hasSearchedForHCO = false;
		hasSearchedForHCP = false;
		pager.ShowTooManyResults = false;
		if(pager.currSearch != null){
			pager.currSearch.mode_gne__c = 'NameAddress';
		}
		if(getHasCanadaProfile()) {
			fakeAcct.RecordTypeId = getAccRecTypeId();
			fakeAcct.Account_Type_gne__c = null;
		}
		return null;
	}

	public PageReference changeMode(){
		String newMode = System.currentPageReference().getParameters().get('mode');
		if (newMode != null && newMode.length() > 0 && pager.currSearch != null){
			pager.currSearch.mode_gne__c = newMode;
		}
		return null;
	}

	public PageReference leaveBar(){
		return null;
	}

    private static Boolean isINFUUser() {
        return GNE_SFA2_Util.isCanadaINFUUser();
    }

	//a user selected this account by clicking an Account name on the Account search results list.
	//This method may create an Account and Address in SFDC if it did not already exist there.
	public PageReference subscribeAcct(){
		String retURL;
		if (!IsTestCase){
			sAddrId = System.currentPageReference().getParameters().get('addrId');
			retUrl = ApexPages.currentPage().getParameters().get('retURL');
		}
		try{
			if(!isNullOrEmpty(sAddrId)){

				//check to see if this is an address_vod__c.id
				if (sAddrId.startsWith(Schema.SObjectType.Address_vod__c.getKeyPrefix())){
					SFASearchStrings_gne__c addrRow = pager.getResultByAddressId(sAddrId);
					newId = addrRow.Account_gne__c;
				} else {
					if(getHasReadOnlyProfile()){
						showError('Read Only profiles can\'t subscribe Account');
						return null;
					}
					GNE_Stg_Party_Dao ptyDao = new GNE_Stg_Party_Dao(IsTestCase);
					Account acct = ptyDao.subscribeAddress(sAddrId);
					if (acct != null && acct.Id != null){
						//subscribe was successful
						newId = acct.Id;
					} else {
						SFASearchStrings_gne__c result = pager.getResultByAddressId(sAddrId);
						//subscribe was not successful.  If this page was reached via
						//the New Address button or the Account already exists, create the address
						//and inform the user with a message.  otherwise, just present error message to user
						if (result != null && !isNullOrEmpty(result.Account_gne__c)){
							createNewAddress(result);
							showError(ERROR_MSG_SUB_ADDR);
						} else {
							showError(ERROR_MSG_SUB_ACCT);
						}
						return null;
					}
				}
			}
			PageReference pageRef;
			if (!IsPopup){
                if(isINFUUser()){
                    pageRef = new PageReference('/apex/GNE_SFA2_Interaction?accountId='+newId+'&addrId='+sAddrId); 
                    pageRef.getParameters().put('expenseType', System.currentPageReference().getParameters().get('expenseType'));
                    pageRef.getParameters().put('expKey', System.currentPageReference().getParameters().get('expKey'));
                    pageRef.getParameters().put('transactionAmount', System.currentPageReference().getParameters().get('transactionAmount'));
                    pageRef.getParameters().put('itemUrl', System.currentPageReference().getParameters().get('itemUrl'));
                    pageRef.getParameters().put('retURL', System.currentPageReference().getParameters().get('retURL'));
                } else {
				pageRef = new PageReference('/apex/GNE_SFA2_Account_Layout?id='+newId);
                }
			} else {
				if (!isNullOrEmpty(retUrl)){
					pageRef = new PageReference(retUrl);
				} else {
                    if(isINFUUser()){
                        pageRef = new PageReference('/apex/GNE_SFA2_Interaction?accountId='+newId+'&addrId='+sAddrId); 
                        pageRef.getParameters().put('expenseType', System.currentPageReference().getParameters().get('expenseType'));
                        pageRef.getParameters().put('expKey', System.currentPageReference().getParameters().get('expKey'));
						pageRef.getParameters().put('transactionAmount', System.currentPageReference().getParameters().get('transactionAmount'));
						pageRef.getParameters().put('itemUrl', System.currentPageReference().getParameters().get('itemUrl'));
                        pageRef.getParameters().put('retURL', System.currentPageReference().getParameters().get('retURL'));
                    } else {
					pageRef = new PageReference('/apex/GNE_SFA2_Account_Layout?id='+newId);
				}
			}
            }
			return pageRef;
		} catch (Exception ex) {
			handleError(CLASS_NAME, 'subscribeAcct', ex);
		}
		return null;
	}

	public void createNewAddress(SFASearchStrings_gne__c result){
		addr = new Address_vod__c();
		addr.Active_Flag_gne__c = true;
		addr.Inactive_vod__c = false;
		addr.Account_vod__c = result.Account_gne__c;
		addr.Address_1_gne__c = result.Street_gne__c;
		addr.Name = result.Street_gne__c;
		addr.City_vod__c = result.City_gne__c;
		addr.State_vod__c = result.State_gne__c;
		addr.Zip_vod__c = result.Zip_gne__c;
		addr.MDM_Address_ID_gne__c = result.Address_MDM_Id_gne__c;
		addr.RecordTypeId = getAddrRecTypeId();
		acctDao = new GNE_Account_Dao(IsTestCase);
		acctDao.saveSObject(addr);
	}

	//clear button was clicked by user on Account search page.  Clear search criteria
	public PageReference clear(){
		debug('<clear>');
		Pager.clearCriteria();
		if(pager.currSearch != null){
			pager.currSearch.mode_gne__c = 'NameAddress';
		}
		hasSearchedForHCO = false;
		hasSearchedForHCP = false;
		return null;
	}

	//create new Account button was clicked by user on Account search page
	public PageReference createNew(){
		if(getHasCanadaProfile()) {
			String url = GNE_Foun_Misc_Config_Items_gne__c.getValues('NewAccReq_And_Dcr_Canada_Smartsheet') != null ? GNE_Foun_Misc_Config_Items_gne__c.getValues('NewAccReq_And_Dcr_Canada_Smartsheet').Configuration_Value_gne__c : '';
			pagereference pageref = new pagereference(url);
			pageref.setredirect(true);
			return pageref;
		}
		if (!validateCreateNew()){
			return null;
		}

		hasSearchedForHCO = false;
		hasSearchedForHCP = false;
		showCreateNew = true;
		newAcct = new Account();
		setAccountType();
		newAddr = new SFASearchStrings_gne__c();

		if (acctType == 'HCP'){
			String tmp1 = Pager.CurrSearch.OrgName_gne__c;
			String[] tmp = tmp1.split(' ',0);
			if(tmp.size()> 1){
				newAddr.LastName_gne__c = tmp[1];
				newAddr.FirstName_gne__c = tmp[0];
			}else{
				newAddr.LastName_gne__c = tmp[0];
			}
			getProfTypes();
		} else{
			newAcct.Name = Pager.CurrSearch.OrgName_gne__c;
			getOrgTypes();
		}

		newAddr.Street_gne__c = Pager.currSearch.Street_gne__c;
		newAddr.City_gne__c = Pager.currSearch.City_gne__c;
		newAddr.State_gne__c = Pager.currSearch.State_gne__c;
		newAddr.Zip_gne__c = Pager.currSearch.Zip_gne__c;

		newAddr.Province_can_gne__c = Pager.currSearch.Province_can_gne__c;
		newAddr.Postal_Code_can_gne__c = Pager.currSearch.Postal_Code_can_gne__c;
		return null;
	}

	//save button was clicked by user on new Account page
	public PageReference saveNew() {
		try {
			newId = null;
			if(!validateSaveNew()){
				return null;
			}
			if (acctType == 'HCP'){
				newAcct.LastName = newAddr.LastName_gne__c;
				newAcct.FirstName = newAddr.FirstName_gne__c;
			}

			if(!saveObject()){
				return null;
			}
			showCreateNew = False;
			hasSearchedForHCP = false;
			hasSearchedForHCO = false;
			if(isPopup){
				return null;
            } else {
                if(isINFUUser()) {
                    PageReference pageRef = new PageReference('/apex/GNE_SFA2_Interaction?accountId='+newId+'&addrId='+fakeAddress.Id); 
                    pageRef.getParameters().put('expenseType', System.currentPageReference().getParameters().get('expenseType'));
                    pageRef.getParameters().put('expKey', System.currentPageReference().getParameters().get('expKey'));
                    pageRef.getParameters().put('transactionAmount', System.currentPageReference().getParameters().get('transactionAmount'));
                    pageRef.getParameters().put('itemUrl', System.currentPageReference().getParameters().get('itemUrl'));
                    pageRef.getParameters().put('retURL', System.currentPageReference().getParameters().get('retURL'));
                    return pageRef;
                } else {
				return new PageReference('/apex/GNE_SFA2_Account_Layout?id='+newAcct.Id);
			}
            }
		}catch(Exception e){
			handleError(CLASS_NAME, 'saveNew', e);
		}
		return null;
	}

	//save button was clicked by user on new Account page
	public PageReference saveNewAddress(){
		try{
			if (!validateSaveNew()) return null;

			if (acctType == 'HCP'){
				newAcct.LastName = newAddr.LastName_gne__c;
				newAcct.FirstName = newAddr.FirstName_gne__c;
			}

			if (!saveObject()) return null;
			showCreateNew = False;
			hasSearchedForHCP = false;
			hasSearchedForHCO = false;
			return new PageReference('/'+newAcct.Id);
		} catch (Exception e){
			handleError(CLASS_NAME, 'saveNew', e);
		}
		return null;
	}

	//cancel button from new Account page was clicked by User... return to search page
	public PageReference cancel(){
		showCreateNew = false;
		if (acctType == 'HCO'){
			hasSearchedForHCO = true;
		} else{
			hasSearchedForHCP = true;
		}
		return null;
	}

	//saves an Account and Address
	private Boolean saveObject(){
		Boolean success = true;
		acctDao = new GNE_Account_Dao(IsTestCase);
		Savepoint dbSavePoint = Database.setSavepoint();

		try {
			Address_vod__c address = new Address_vod__c();
			address.name = newAddr.Street_gne__c;

			if(getHasCanadaProfile()){
				address.Address_1_gne__c = newAddr.Street_gne__c;
				address.Address_line_2_vod__c = newAddr.Street_2_gne__c;
				address.city_vod__c = newAddr.City_gne__c;
				address.Province_can_gne__c = newAddr.Province_can_gne__c;
				address.Postal_Code_can_gne__c = newAddr.Postal_Code_can_gne__c;
				address.Primary_vod__c = true;
				address.Active_Flag_gne__c = true;
				address.Country_gen__c = 'CANADA';
				address.Address_Type_gne__c = fakeAddress.Address_Type_gne__c;
			}else{
				address.name = newAddr.Street_gne__c;
				address.Address_1_gne__c = newAddr.Street_gne__c;
				address.Address_line_2_vod__c = newAddr.Street_2_gne__c;
				address.city_vod__c = newAddr.City_gne__c;
				address.state_vod__c = newAddr.State_gne__c;
				address.zip_vod__c = newAddr.Zip_gne__c;
				address.Primary_vod__c = true;
				address.Active_Flag_gne__c = true;
			}
			//This condition will only be false when this is an "addrses only" search from new Address page.
			if(isNullOrEmpty(newAddr.Account_gne__c)){
				setAccountType();
				if (acctType == 'HCP' && !getHasCanadaProfile()){
					newAcct.Credentials_gne__pc = newAcct.Credentials_vod__c;
					newAcct.Credentials_gne__c = newAcct.Credentials_vod__c;
					if(newAcct.Professional_Type_gne__c == 'Patient Ambassador') {
						newAcct.Credentials_gne__c = newAcct.Credentials_gne__pc = newAcct.Credentials_vod__c = 'NONC';
					}
				}

				//save Account
				Exception ex = acctDao.saveSObjectEx(newAcct);
				if (ex != null){
					System.debug(Logginglevel.INFO,'exception returned from saveobject. message='+ex.getMessage());
					if (ex.getMessage().contains('duplicate value found: MDMID_gne__c')){
						//get the account that it is a duplicate of and continue on
						newAcct = acctDao.getByMDMId(newAcct.MDMID_gne__c);
						return true;
					}  else{
						handleError(CLASS_NAME, 'saveNew', ex);
						return false;
					}
				}
			} else{
				newAcct = acctDao.getById(newAddr.Account_gne__c);
			}
			//newId used in javascript on page
			newId = newAcct.Id;

			//if LWO profile, do not save address or alignment info because
			//address fields do not appear on create page for LWO profile users.
			if (!getHasLWOProfile()){
				//set address record type to RepMaintained and save it
				List<RecordType> recTypes;
				if(getHasCanadaProfile()){
					if(acctType == 'HCP'){
						recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR_CAN_HCP);
					}else{
						recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR_CAN_HCO);
					}
				}else{
					recTypes = fetchRecordTypes('Address_vod__c', REC_TYPE_ADDR);
				}
				if (recTypes != null && recTypes.size() > 0) address.RecordTypeId = recTypes[0].Id;

				address.Account_vod__r = newAcct;
				address.Account_vod__c = newAcct.Id;
				Exception ex = acctDao.saveSObjectEx(address);
                if(address.Id != null)fakeAddress.Id = address.Id;
                
				if (ex != null)  {
					handleError(CLASS_NAME, 'saveNew', ex);
					Database.rollback(dbSavePoint);
					return false;
				}
				//save territory alignment
				if(!isNullOrEmpty(selectedTerritory)){
					if (selectedTerritory != NO_TERRITORY_SELECTED){
						terrDao = new GNE_Territory_Dao();
						ex = terrDao.alignAccountToTerritory(newAcct.Id, address.Id, selectedTerritory);
						Account_Alignment_WS.InsertBrandAffiliation(selectedTerritory, newAcct.Id);
						if (ex != null){
							handleError(CLASS_NAME, 'saveNew', ex);
							success = false;
						}
						if(getHasCanadaProfile()){
							makeNotMyTargetCanadaAccount(newAcct.Id);
						}
					}else{
						debug('do not align was selected');
					}
				}
			}
		} catch (Exception ex) {
            System.debug('ex '+ex.getLineNumber());
            System.debug('ex '+ex.getStackTraceString());
			handleError(CLASS_NAME, 'saveNew', ex);
			success = false;
			Database.rollback(dbSavePoint);
		}
		return success;
	}

	public Exception makeNotMyTargetCanadaAccount(String acctId){
		List<TSF_vod__c> tsfs = [SELECT Id, My_Target_vod__c FROM TSF_vod__c WHERE Account_vod__c = :acctId];
		for(TSF_vod__c tsf : tsfs){
			tsf.My_Target_vod__c = false;
		}
		try {
			if(tsfs != null && tsfs.size() > 0){
				update tsfs;
			}
		} catch (Exception ex) {
			return ex;
		}
		return null;
	}

	//gets the account and account record type
	public void setAccountType(){
		String recordTypeId;
		System.debug(Logginglevel.ERROR, 'BOS:: selectedOrgType = ' + selectedOrgType);
		recTypeNameToObj = new Map<String, Map<String, RecordType>>();

		// Retreive record types
		List<RecordType> recTypeList = fetchRecordTypes('Account', null);

		for (RecordType recType : recTypeList) {
			debug('recType.Name='+recType.Name);
			if (recTypeNameToObj.containsKey(recType.SobjectType)) {
				recTypeNameToObj.get(recType.SobjectType).put(recType.Name, recType);
			} else {
				recTypeNameToObj.put(recType.SobjectType, new Map<String, RecordType>{recType.Name => recType});
			}
		}
		if (acctType == 'HCO') {
			//for HCOS, if LWO Profile, set record type to LWO HCO, otherwise set
			//record type based on user selected Account Type.
			if (getHasLWOProfile()) {
				RecordType recordType = recTypeNameToObj.get('Account').get(REC_TYPE_LWO_HCO);
				if (recordType != null) recordTypeId = recordType.Id;
			} else if(getHasCanadaProfile()){
				RecordType recordType = recTypeNameToObj.get('Account').get(REC_TYPE_ACC_CAN_HCO);
				if (recordType != null) recordTypeId = recordType.Id;

				if(getHasRAMAProfile()) {
					String[] splitFields = selectedOrgType.split(',');
					if (splitFields != null && splitFields.size() >= 1) {
						newAcct.Account_Type_RAMA_gne__c = splitFields[0];
					}
				} else {
					String[] splitFields = selectedOrgType.split(',');
					if (splitFields != null && splitFields.size() > 1){
						newAcct.Account_Type_gne__c = splitFields[0];
						recordTypeId = splitFields[1];
					}
				}
			} else {
				String[] splitFields = selectedOrgType.split(',');
				if (splitFields != null && splitFields.size() > 1){
					newAcct.Account_Type_gne__c = splitFields[0];
					recordTypeId = splitFields[1];
				}
			}
		} else {
			newAcct.Professional_Type_gne__c = selectedProfType;
			if(getHasLWOProfile() && recTypeNameToObj.get('Account').get(REC_TYPE_LWO_HCP) != null) {
					recordTypeId = recTypeNameToObj.get('Account').get(REC_TYPE_LWO_HCP).Id;
			} else if(getHasRAMAProfile() && recTypeNameToObj.get('Account').get(REC_TYPE_ACC_CAN_HCP) != null) {
				recordTypeId = recTypeNameToObj.get('Account').get(REC_TYPE_ACC_CAN_HCP).Id;
				newAcct.Account_Type_RAMA_gne__c = selectedProfType;
			} else if(getHasCanadaProfile() && recTypeNameToObj.get('Account').get(REC_TYPE_ACC_CAN_HCP) != null) {
					recordTypeId = recTypeNameToObj.get('Account').get(REC_TYPE_ACC_CAN_HCP).Id;
				newAcct.Account_Type_gne__c = selectedProfType;
			} else if(selectedProfType == 'Patient Ambassador' && recTypeNameToObj.get('Account').get(REC_TYPE_CP) != null) {
					recordTypeId = recTypeNameToObj.get('Account').get(REC_TYPE_CP).Id;
			} else if(recTypeNameToObj.get('Account').get(REC_TYPE_HCP) != null) {
					recordTypeId = recTypeNameToObj.get('Account').get(REC_TYPE_HCP).Id;
			}
		}
		newAcct.RecordTypeId = recordTypeId;
		debug('newAcct.RecordTypeId='+newAcct.RecordTypeId);
	}

	//validates enough data was entered before creating a new Account
	private Boolean validateCreateNew(){
		Boolean success = true;
		if (acctType == 'HCP'){
			if (isNullOrEmpty(Pager.CurrSearch.OrgName_gne__c)){
				showError('Please enter Name of HCP before clicking Create New Account.');
				success = false;
			}
		} else{
			if (isNullOrEmpty(Pager.CurrSearch.OrgName_gne__c)){
				showError('Please enter Name of HCO before clicking Create New Account.');
				success = false;
			}
		}
		return success;
	}

	//validates enough data has been entered by user to save a new Account
	private Boolean validateSaveNew(){
		Boolean success = true;

		if (!getHasLWOProfile()){
			if (acctType == 'HCO'){
				if (selectedOrgType == null){
					showError('Account Type must be selected.');
					success = false;
				} else{
					if (selectedOrgType == NONE_SELECTED){
						showError('Account Type must be selected.');
						success = false;
					}
				}
			} else{
				if (selectedProfType == NONE_SELECTED){
					if(getHasCanadaProfile()){
						showError('Account Type must be selected.');
					}else{
						showError('Professional Type must be selected.');
					}
					success = false;
				}
			}
			if(getHasCanadaProfile() && newAddr.Province_can_gne__c.contains('None')){
				showError('Please select Province to create Account');
				success = false;
			}

			if(getHasCanadaProfile() && fakeAddress.Address_Type_gne__c == null){
				showError('Please select Address Type to create Account');
				success = false;
			}

			if(getHasCanadaProfile() && !Pattern.matches('[A-Z][0-9][A-Z]\\s[0-9][A-Z][0-9]', newAddr.Postal_Code_can_gne__c)){
				showError('Postal Code must consist of 3 capital letters, 3 digits and one space character and match "XXX XXX" pattern (i.e. A0A 1B1)');
				success = false;
			}
		} else{
			//if SAP id was entered, validate that it is unique.
			if (!isNullOrEmpty(newAcct.SAP_ID_gne__c) && !isSAPIdUnique(newAcct.SAP_ID_gne__c)){
				success = false;
			}
		}

		if (!isNullOrEmpty(newAddr.Zip_gne__c) && !isZipValid(newAddr.Zip_gne__c)){
			success = false;
			showError('Zip code entered is not valid.  Please enter as valid numbers and optionally a dash.');
		}

		return success;
	}

	private Boolean checkForRAMA(String[] splittedFields) {
		if(splittedFields != null && splittedFields.size() >= 1) {
			return true;
		}
		return false;
	}

	//For LWO profile, users may enter SAP ID when creating new HCO or HCP.
	//This method validates that the SAP ID is unique.  This is enforced by the DB,
	//butis done pro-actively in order to provide the user with a friendly error message
	//consistent with the rest of the page.
	private Boolean isSAPIdUnique(String sapId){
		Boolean isUnique = true;
		String newSapId = String.escapeSingleQuotes(sapId);
		List <Account> acctList;
		try{
			acctList = [SELECT Id, Name FROM Account WHERE SAP_ID_gne__c = :newSapId];
		} catch (QueryException e){
			//do nothing, not a problem if no rows for assignment
		}

		if (acctList != null && acctList.size() > 0){
			isUnique = false;
			showError('SAP ID entered is not valid. There was a duplicate value on record: ' + acctList[0].Name + '.');
		}
		return isUnique;
	}

	//validates that at least the minimum data was entered to do a search
	private Boolean validateSearchCriteria(){
		Boolean success = true;
		if (Pager.currSearch.Mode_gne__c == 'MDMId'){
			if (isNullOrEmpty(Pager.currSearch.MDMID_gne__c)){
				showError('Entry of MDM Id is required before searching.');
				return false;
			}
		} else if (Pager.currSearch.Mode_gne__c == 'License'){
			if (isNullOrEmpty(Pager.currSearch.License_Number_gne__c) || isNullOrEmpty(Pager.currSearch.License_State_gne__c)){
				showError('Entry License Number and License State is required before searching.');
				return false;
			}
			if (Pager.currSearch.License_Number_gne__c.length() < 3){
				showError('Entry License Number should be at least 3 characters before searching.');
				return false;
			}
		} else{
			//mode is "NameAddress"
			if (Pager.GetIsAddressSearch()
					&& ((isNullOrEmpty(Pager.currSearch.State_gne__c) || Pager.currSearch.State_gne__c.contains('None')))
					&& !getHasCanadaProfile()) {
				showError('Selection of State is required when searching for address.');
				return false;
			}
			if(getHasCanadaProfile() && acctType == 'HCP' &&
					(isNullOrEmpty(Pager.currSearch.OrgName_gne__c) || Pager.currSearch.OrgName_gne__c.length() < 2) &&
					((isNullOrEmpty(Pager.currSearch.Rep_Speciality_can__c) && !isHCOAccountTypeValid(Pager.currSearch) && isNullOrEmpty(Pager.currSearch.Specialties_can__c)) || isNullOrEmpty(Pager.currSearch.Province_can_gne__c))){
				showError('You must enter  at least two characters in Person Name OR select one Account Type, Specialties, or Rep Specialty AND a Province before searching.');
				return false;
			}
			if(getHasCanadaProfile() && acctType == 'HCO' &&
					(isNullOrEmpty(Pager.currSearch.OrgName_gne__c) || Pager.currSearch.OrgName_gne__c.length() < 2) &&
					(!isHCOAccountTypeValid(Pager.currSearch) ||isNullOrEmpty(Pager.currSearch.Province_can_gne__c)) ){
				showError('You must enter at least two characters in Name OR select one Account Type AND a Province before searching.');
				return false;

			}
			if (acctType == 'HCO' || acctType == 'HCP'){
				if(!getHasCanadaProfile() && isNullOrEmpty(Pager.currSearch.OrgName_gne__c) && (isNullOrEmpty(Pager.currSearch.State_gne__c) || Pager.currSearch.State_gne__c.contains('None')) ){
					showError('You must enter State to perform address search.');
					return false;
				}

				/*if(isNullOrEmpty(Pager.currSearch.OrgName_gne__c) && !(!isNullOrEmpty(Pager.currSearch.City_gne__c) || !isNullOrEmpty(Pager.currSearch.Street_gne__c) || !isNullOrEmpty(Pager.currSearch.Zip_gne__c))){
		showError('You must enter more information than the State to perform  address search.');
		return false;
		}*/
				if ((isNullOrEmpty(Pager.currSearch.OrgName_gne__c) || Pager.currSearch.OrgName_gne__c.length() < 2) &&
						isNullOrEmpty(Pager.currSearch.City_gne__c) &&
						isNullOrEmpty(Pager.currSearch.Street_gne__c) &&
						isNullOrEmpty(Pager.currSearch.Zip_gne__c) &&
						isNullOrEmpty(Pager.currSearch.State_gne__c) &&
						isNullOrEmpty(Pager.currSearch.Province_can_gne__c) &&
						isNullOrEmpty(Pager.currSearch.Roche_Id_can_gne__c) &&
						isNullOrEmpty(Pager.currSearch.Postal_code_can_gne__c)){

					showError('You must enter a partial name (at least 2 characters) AND/OR a partial address before searching.  You will get better results by providing as much search information as you are able.');
					return false;
				}
			}
			// no longer need this as HCP and HCO can search for address only
			/* else{
		if ((isNullOrEmpty(Pager.currSearch.OrgName_gne__c) || Pager.currSearch.OrgName_gne__c.length() < 2) &&
		isNullOrEmpty(Pager.currSearch.City_gne__c) &&
		isNullOrEmpty(Pager.currSearch.Street_gne__c) &&
		isNullOrEmpty(Pager.currSearch.Zip_gne__c)){
		showError('You must enter a partial name (at least 2 characters) AND Select State before searching.  You will get better results by providing as much search information as you are able.');
		return false;
		} else{
		if (isNullOrEmpty(Pager.currSearch.OrgName_gne__c) || Pager.currSearch.OrgName_gne__c.length() < 2){
			showError('You must enter a partial name (at least 2 characters) AND Select State before searching.  You will get better results by providing as much search information as you are able.');
			return false;
		}
		}
		}  */
			if (!isNullOrEmpty(Pager.currSearch.Zip_gne__c) && !isZipValid(Pager.currSearch.Zip_gne__c)){
				showError('Zip code entered is not valid.  Please enter the 5 or 9 digit zip code to search for.  Enter only the numbers, no dashes.');
				return false;
			}
		}
		return success;
	}

	private Boolean isHCOAccountTypeValid(SFASearchStrings_gne__c currSearch) {
		if(GNE_SFA2_Util.isCanadaRAMA() && isNullOrEmpty(currSearch.RAMA_Account_Type_HCO_can__c)) {
			return false;
		} else if(!GNE_SFA2_Util.isCanadaRAMA() && isNullOrEmpty(Pager.CurrSearch.Account_Type_HCO_can__c)) {
			return false;
		}
		return true;
	}

	private Boolean isHCPAccountTypeValid(SFASearchStrings_gne__c currSearch) {
		if(GNE_SFA2_Util.isCanadaRAMA() && isNullOrEmpty(currSearch.RAMA_Account_Type_HCP_can__c)) {
			return false;
		} else if(!GNE_SFA2_Util.isCanadaRAMA() && isNullOrEmpty(Pager.CurrSearch.Account_Type_HCP_can__c)) {
			return false;
		}
		return true;
	}

	private List<SelectOption> removeDups(List<SelectOption> inList){
		List<SelectOption> newList = new List<SelectOption>{};
		String currVal;
		for (SelectOption row : inList){
			if (currVal != row.getLabel()){
				newList.add(row);
			}
			currVal = row.getLabel();
		}
		return newList;
	}

	/**
	* change method qualificator for requirements: SFA-436
	* Retreives Record Types
	*/
	public static List<RecordType> fetchRecordTypes(String objName, String recTypeName){
		if (recTypeName != null){
			return  [SELECT
			Id,
			Name,
			DeveloperName,
			SobjectType,
			Description
			FROM
			RecordType
			WHERE
			SobjectType = :objName
			AND DeveloperName = :recTypeName
			ORDER BY
			SobjectType ASC];
		} else{
			return  [SELECT
			Id,
			Name,
			DeveloperName,
			SobjectType
			FROM
			RecordType
			WHERE
			SobjectType = :objName
			ORDER BY
			SobjectType ASC];
		}
	}

	private  Map <String, String> getAccountRecordTypes(){
		Map <String, String> recTypeMap = new Map <String, String>();

		Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();

		Map <Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']);

		for ( Id rtId : rtMapById.keyset() ){
			Schema.RecordTypeInfo rtById = rtMapById.get( rtId );
			if ( rtById.IsAvailable() == true  ){
				RecordType rt = rtMap.get(rtId);
				if (rt != null) recTypeMap.put(rt.Name, rt.Id);
			}
		}

		for(String tmp  :recTypeMap.keyset()){
			System.Debug('XXXXX key returned : '+ tmp +'AND value :' + recTypeMap.get(tmp));
		}
		return recTypeMap;
	}

	private String getQueueId(){
		Group grp = [select Id, Name from Group where name = 'GNE-SFA-QUEUE'];
		if (grp != null) return grp.Id;
		return null;
	}

	public PageReference sortName(){
		Pager.sortList('Default_Sort_Field_gne__c');
		return null;
	}
	public PageReference sortOrgName(){
		Pager.sortList('OrgName_gne__c');
		return null;
	}

	public PageReference sortLastName(){
		Pager.sortList('LastName_gne__c');
		return null;
	}

	public PageReference sortFirstName(){
		Pager.sortList('FirstName_gne__c');
		return null;
	}

	public PageReference sortType(){
		Pager.sortList('Type_gne__c');
		return null;
	}

	public PageReference sortStreet(){
		Pager.sortList('Street_gne__c');
		return null;
	}

	public PageReference sortCity(){
		Pager.sortList('City_gne__c');
		return null;
	}

	public PageReference sortState(){
		Pager.sortList('State_gne__c');
		return null;
	}

	public PageReference sortZip(){
		Pager.sortList('Zip_gne__c');
		return null;
	}

	public PageReference sortLicense(){
		Pager.sortList('License_Number_gne__c');
		return null;
	}

	public PageReference sortAka(){
		Pager.sortList('Aka_gne__c');
		return null;
	}

	public PageReference sortMdmId(){
		Pager.sortList('MDMID_gne__c');
		return null;
	}

	public PageReference sortProvince(){
		Pager.sortList('Province_can_gne__c');
		return null;
	}

	public PageReference sortPostalCode(){
		Pager.sortList('Postal_Code_can_gne__c');
		return null;
	}

	public PageReference sortRocheId(){
		Pager.sortList('Roche_Id_can_gne__c');
		return null;
	}

	public static List<String> getAvailableClassification(){
        return null;
    }
    
    public Boolean getIsMenuVisible() {
        return !GNE_SFA2_Util.isCanadaINFUUser();
    }
}