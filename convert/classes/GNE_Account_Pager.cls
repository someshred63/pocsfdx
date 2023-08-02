//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care   
//     CLASS: GNE_Account_Pager   
//   PURPOSE: Account Pager  
//   
//   CREATED: 05/2010       
//--------------------------------------------------------------------------------
public with sharing class GNE_Account_Pager extends GNE_Base_Pager{          
	public GNE_Account_Search_Dao dao;
	public Boolean ShowInactive { get; set;}  
	public SFASearchStrings_gne__c  currSearch { get; set;}  
	public Boolean ShowTooManyResults { get; set;}
	public Boolean SearchOnlyFirstMax { get; set;}  
	public String RuleSetName { get; set;}
	public String RuleNameToDisp;
	public String fromName { get; set;}   
	public String columnList  { get; set;}  
	public String whereClause { get; set;}            
	public String addressSubWhereClause { get; set;}  
	public String nameSubWhereClause { get; set;}
	public Integer localListSize { get; set;}
	public Set <String> mdmAddrIdSet { get; set;} 	//populated in GNE_Account_Dao, read in GNE_Stg_Party_Dao
	public Set <String> locIdSet { get; set;}  //populated and used in GNE_Stg_Party_Dao using above list as input
	public Map <String, String> mdmAddrIdToRuleMap { get; set;}
	public Set <ID> ptyLocIdSet { get; set;}  //populated and used in GNE_Stg_Party_Dao holds pty loc ids for mdm address ids returned from mdm
	public Map <String, String> mdmIdToRuleNumMap { get; set;}
	public Map <Id, String> ptyToMdmIdMap { get; set;}
	public Map <Id, String> ptyAddToMdmAddIdMap { get; set;}
	public Map <Id, String> ptyAddToMdmAddIdALLMap { get; set;}
	public Map <String, String> mdmIdToAccTypeMap { get; set;}    
	public String acctId { get; set;}
	public Account acct { get; set;}
	
	private static String NAME_ADDRESS_SEARCH_MODE = 'NameAddress';
	private static String MDMID_SEARCH_MODE = 'MDMId';
	private static String LICENSE_SEARCH_MODE = 'License';  
	
	public override List<SObject> getByPager(GNE_Base_Pager pager){
		fullList = dao.getByPager(this); 
		return fullList;	
	}
	
	public Boolean isNameAddressSearchMode() {
		return currSearch!=null && currSearch.Mode_gne__c == NAME_ADDRESS_SEARCH_MODE; 
	}
	
	public Boolean isMdmIdSearchMode() {
		return currSearch!=null && currSearch.Mode_gne__c == MDMID_SEARCH_MODE; 
	}
	
	public Boolean isLincenseSearchMode() {
		return currSearch!=null && currSearch.Mode_gne__c == LICENSE_SEARCH_MODE; 
	}
	
	public Boolean GetIsAccountSearch(){
		if (acct != null) return true;
		return false;
	}
	
	public Boolean GetIsAddressSearch(){
		if (currSearch != null && 
				(!isNullOrEmpty(currSearch.Street_gne__c) ||
					!isNullOrEmpty(currSearch.City_gne__c) ||
					!isNullOrEmpty(currSearch.State_gne__c) ||
					!isNullOrEmpty(currSearch.Zip_gne__c) ||
					!isNullOrEmpty(currSearch.Postal_Code_can_gne__c) ||
					!isNullOrEmpty(currSearch.Province_can_gne__c)
					)){
			return true;
		}
		return false;
	}

	public Boolean GetIsFullAddressSearch(){
		if (currSearch != null && 
				(!isNullOrEmpty(currSearch.Street_gne__c) &&
					!isNullOrEmpty(currSearch.City_gne__c) &&
					!isNullOrEmpty(currSearch.State_gne__c) &&
					!isNullOrEmpty(currSearch.Zip_gne__c))){
			return true;
		}    
		return false;
	}

	public Boolean GetIsNameSearch(){
		if (currSearch != null && !isNullOrEmpty(currSearch.OrgName_gne__c)){
			return true;
		}
		return false;
	}
	
	public Boolean GetIsNameOnlySearch(){
		if (GetIsNameSearch() && !GetIsLicenseSearch() && !GetIsAddressSearch()) return true;
		return false;
	}
	
	public Boolean GetIsMDMOnlySearch(){
		if (currSearch != null && !isNullOrEmpty(currSearch.MDMID_gne__c)) return true;
		return false;
	}
	
	public Boolean GetIsNameAddressSearch(){
		if (GetIsNameSearch() && GetIsAddressSearch() && !GetIsLicenseSearch()) return true;
		return false;
	}

	public Boolean GetIsNameLicenseSearch(){
		if (GetIsNameSearch() && GetIsLicenseSearch()&& !GetIsAddressSearch()) return true;
		return false;
	}

	public Boolean GetIsNameLicenseAddressSearch(){
		if (GetIsNameSearch() && GetIsLicenseSearch() && GetIsAddressSearch()) return true;
		return false;
	}
	
	public Boolean GetIsLicenseSearch(){
		if (currSearch != null && currSearch.AccountType_gne__c == 'HCP' &&
				(!isNullOrEmpty(currSearch.License_Number_gne__c) || !isNullOrEmpty(currSearch.License_State_gne__c))){
			return true;
		}
		return false;
	}
	
	public Boolean GetIsLicenseOnlySearch(){
		if (currSearch != null && currSearch.AccountType_gne__c == 'HCP' &&
				!isNullOrEmpty(currSearch.License_Number_gne__c) &&
				!GetIsNameSearch() && !GetIsAddressSearch()){
			return true;
		}
		return false;  
	}
	
	
	public Boolean GetIs_1N_BothSearch(){
		if (currSearch != null && GetIsNameSearch() &&	
				isNullOrEmpty(currSearch.Street_gne__c) && isNullOrEmpty(currSearch.City_gne__c) && isNullOrEmpty(currSearch.State_gne__c) && isNullOrEmpty(currSearch.Zip_gne__c)){
			return true;
		}
		return false;
	}  
	
	public Boolean GetIs_1XXL_BothSearch(){
		if (currSearch != null && GetIsNameSearch() &&	
				isNullOrEmpty(currSearch.Street_gne__c) && isNullOrEmpty(currSearch.City_gne__c) && !isNullOrEmpty(currSearch.State_gne__c) && isNullOrEmpty(currSearch.Zip_gne__c)){
			return true;
		}
		return false;
	}  
	
	
	public Boolean GetIs_1XL_BothSearch(){
		if (currSearch != null && GetIsNameSearch() &&	
				(!isNullOrEmpty(currSearch.Street_gne__c) && !isNullOrEmpty(currSearch.State_gne__c)) && isNullOrEmpty(currSearch.Zip_gne__c) && isNullOrEmpty(currSearch.City_gne__c) ){
			return true;
		}
		return false;  
	}
	
	public Boolean GetIs_1L_OrgSearch(){
		if (currSearch != null && GetIsNameSearch() &&	
				isNullOrEmpty(currSearch.Street_gne__c) && !isNullOrEmpty(currSearch.City_gne__c) && !isNullOrEmpty(currSearch.State_gne__c) && isNullOrEmpty(currSearch.Zip_gne__c)){
			return true;
		}
		return false;
	}
	
	public Boolean GetIs_1L_IndvSearch(){
		if (currSearch != null && GetIsNameSearch() &&	
				isNullOrEmpty(currSearch.Street_gne__c) && !isNullOrEmpty(currSearch.State_gne__c) && (!isNullOrEmpty(currSearch.Zip_gne__c) || !isNullOrEmpty(currSearch.City_gne__c) ) ){
			return true;
		}
		return false;
	}
	
	public Boolean GetIs_1T_BothSearch(){
		if (currSearch != null && GetIsNameSearch() &&	
				((!isNullOrEmpty(currSearch.Street_gne__c) && !isNullOrEmpty(currSearch.State_gne__c) && (!isNullOrEmpty(currSearch.Zip_gne__c)|| !isNullOrEmpty(currSearch.City_gne__c)))||
					!isNullOrEmpty(currSearch.State_gne__c) && (!isNullOrEmpty(currSearch.Zip_gne__c) && !isNullOrEmpty(currSearch.City_gne__c)))){
			return true;
		}
		return false;  
	}
	
	public Boolean GetIs_1L_ADR_Search(){
		if (currSearch != null && !GetIsNameSearch() &&	
				(!isNullOrEmpty(currSearch.Street_gne__c) && !isNullOrEmpty(currSearch.State_gne__c) && (!isNullOrEmpty(currSearch.Zip_gne__c) || !isNullOrEmpty(currSearch.City_gne__c))) ||(isNullOrEmpty(currSearch.Street_gne__c)&&!isNullOrEmpty(currSearch.State_gne__c) && (!isNullOrEmpty(currSearch.Zip_gne__c))) || (!isNullOrEmpty(currSearch.State_gne__c) && (!isNullOrEmpty(currSearch.City_gne__c)))){
			return true;
		}
		return false;  
	}
	
	public Boolean GetIs_1XL_ADR_Search(){
		if (currSearch != null && !GetIsNameSearch() &&	
				!isNullOrEmpty(currSearch.Street_gne__c) && !isNullOrEmpty(currSearch.State_gne__c) && isNullOrEmpty(currSearch.Zip_gne__c)&& isNullOrEmpty(currSearch.City_gne__c)){
			return true;
		}
		return false;  
	}
	
	public Boolean GetIs_1XXX_ADR_Search(){
		if (currSearch != null && !GetIsNameSearch() &&	
				!isNullOrEmpty(currSearch.State_gne__c) && isNullOrEmpty(currSearch.Street_gne__c) && isNullOrEmpty(currSearch.Zip_gne__c)&& isNullOrEmpty(currSearch.City_gne__c)){
			return true;
		}
		return false;  
	}
	
	//--- Constructor 
	Public GNE_Account_Pager(){
		IsTestCase = false;
		setup();
	}
	
	//--- Test Constructor
	Public GNE_Account_Pager(Boolean testVal){    	
		IsTestCase = testVal;
		setup();
	}
	
	public void setSearchMax(){
		Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();	
		if (mapConfigItems != null && mapConfigItems.get('SearchAccountMaxResults') != null){
			String strMax = (String) mapConfigItems.get('SearchAccountMaxResults').Configuration_Value_gne__c;
			if (strMax != null){
				setMaxResults(Integer.valueOf(strMax));
			}
		}
	}
	
	public void replaceSpecialChars(){
		if (currSearch != null){
			if (!isNullOrEmpty(currSearch.OrgName_gne__c)){					
				currSearch.OrgName_gne__c = String.escapeSingleQuotes(currSearch.OrgName_gne__c);
			}
			if (!isNullOrEmpty(currSearch.LastName_gne__c)){					
				currSearch.LastName_gne__c = String.escapeSingleQuotes(currSearch.LastName_gne__c);
			}
			if (!isNullOrEmpty(currSearch.FirstName_gne__c)){					
				currSearch.FirstName_gne__c = String.escapeSingleQuotes(currSearch.FirstName_gne__c);
			}
			if (!isNullOrEmpty(currSearch.Street_gne__c)){					
				currSearch.Street_gne__c = String.escapeSingleQuotes(currSearch.Street_gne__c);
			}
			if (!isNullOrEmpty(currSearch.City_gne__c)){					
				currSearch.City_gne__c = String.escapeSingleQuotes(currSearch.City_gne__c);
			}
			if (!isNullOrEmpty(currSearch.License_Number_gne__c)){					
				currSearch.License_Number_gne__c = String.escapeSingleQuotes(currSearch.License_Number_gne__c);
			}
		}
	}
	
	public void clearQueryFields(){
		fromName = '';
		columnList = '';
		whereClause = '';
		addressSubWhereClause = '';
		nameSubWhereClause = '';
		mdmAddrIdSet = null;
		ptyToMdmIdMap = null;
		ptyAddToMdmAddIdMap = null;
		ptyAddToMdmAddIdALLMap = null;
		mdmIdToAccTypeMap = null;
		localListSize = 0;
		locIdSet = null;
		ptyLocIdSet = null;
		acctId = null;
		mdmIdToRuleNumMap = null;
	}
	
	public void clearCriteria(){
		currSearch = new SFASearchStrings_gne__c();
		currSearch.Show_Plans_gne__c = true;
		setCurrentPage(1);   	
	}
	
	public void setup(){
		clearCriteria();
		clearQueryFields();
		setSearchMax();
		SearchOnlyFirstMax = false;
		dao = new GNE_Account_Search_Dao(IsTestCase); 
		ShowInactive = true;
		ShowTooManyResults = false;
		//Added By MISZE : CR for CaseMgn User - START
		if(!dao.isCMuser(Userinfo.getProfileId())){
			currSearch = dao.getByCurrentUser();
		}else{
			currSearch = null;
		}
		//Added By MISZE : CR for CaseMgn User  - END	
		if (currSearch == null){	
			currSearch = new SFASearchStrings_gne__c();
			currSearch.AccountType_gne__c = 'HCO';
			currSearch.Show_Plans_gne__c = true;
		}		
		currSort = 'Name';
		currSortOrder = 'asc';
		RuleSetName = '';
		RuleNameToDisp = '';
	}
	
	//method to indicate whether the logged on user is a Canada user
	private Boolean getHasCanadaProfile() {
		String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
		if (profileName != null && profileName.toUpperCase().contains('CANADA')) {
			return true;
		} else {
			return false;
		}	  
	}
	
	//---Build the display list
	private List<SFASearchStrings_gne__c> dispList;
	public List<SFASearchStrings_gne__c> getDispList(){
		return dispList;
	} 
	 
	public void setDispList(List<SFASearchStrings_gne__c> inlist){
		dispList = inlist;
	}  

	public SFASearchStrings_gne__c getResultByAddressId(String addrId){
		SFASearchStrings_gne__c currRow;
		if (fullList != null && fullList.size() > 0){
			for (SObject row : fullList){
				currRow = (SFASearchStrings_gne__c) row;
				System.debug('currRow.Address_Mdm_Id_gne__c='+currRow.Address_Mdm_Id_gne__c);
				if (addrId == currRow.Address_Mdm_Id_gne__c){
					return currRow;
				}
			}
		}
		return null;
	}
	
	public override void changeDispData(){	
		dispList = new List<SFASearchStrings_gne__c>{};
		if (fullList != null && fullList.size() > 0){
			if (fullList.size() < pageEndPos) pageEndPos = fullList.size();
			for (Integer i = pageStartPos; i < pageEndPos + 1; i++){
				dispList.add((SFASearchStrings_gne__c) fullList[i-1]);
			}
		}	
	}  
}