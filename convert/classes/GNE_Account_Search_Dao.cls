//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Account_Search_Dao
//   PURPOSE: Dao for SFASearchStrings_gne__c and searching Accounts
//   
//   CREATED: 05/2010  
//--------------------------------------------------------------------------------
public with sharing class GNE_Account_Search_Dao extends GNE_Base_Dao{           
    private transient GNE_Account_Dao acctDao;
    private transient GNE_SFA2_Account_Delta_Dao acctDeltaDao;
    private transient GNE_Stg_Party_Dao ptyDao;  
    private transient GNE_MDM_Siperian_Dao mdmDao; 
    public boolean searchLocalOnly;
    private Boolean lwoProfileMode; 
    private Boolean cmProfileMode;
    
    private static String NAME = 'SFASearchStrings_gne__c';
    
    public static final String FIELD_LIST = 'Id, MDMID_gne__c, Account_gne__c, Address_MDM_ID_gne__c, ' 
    + 'FirstName_gne__c, LastName_gne__c, OrgName_gne__c, Street_gne__c, '
    + 'State_gne__c, City_gne__c, Zip_gne__c, AccountType_gne__c, Type_gne__c, '
    + 'AKA_gne__c, License_Number_gne__c, License_State_gne__c, Show_Plans_gne__c, Mode_gne__c, '
    + 'Province_can_gne__c, Postal_Code_can_gne__c, Roche_Id_can_gne__c, Country_can_gen__c, '
    + 'Rep_Speciality_can__c, Specialties_can__c, Active_US_License_gne__c, '
    + 'Tier_Level_gne__c, HCP_Stakeholder_Type_gne__c';
    
    //Added By MISZE : CR for CaseMgn User - START
    public static final String USER_PROF_FIELD = 'Id, Name';
    //Added By MISZE : CR for CaseMgn User - END
    
    //---Test Constructor
    public GNE_Account_Search_Dao(boolean isTest){  
        IsTestCase = isTest;
        init();
    }
    
    public void init(){
        ObjectName = NAME;
        searchLocalOnly = false;
        ClassName = 'GNE_Account_Search_Dao';
        if (!IsTestCase){ 
            setSearchType();
        }
    }
    
    private GNE_Account_Dao getAccountDao() {
        if(acctDao==null) {
            acctDao = new GNE_Account_Dao(IsTestCase);
        }
        
        return acctDao;
    }
    
    private GNE_SFA2_Account_Delta_Dao getAccountDeltaDao() {
        if(acctDeltaDao==null) {
            acctDeltaDao = new GNE_SFA2_Account_Delta_Dao(IsTestCase);
        }
        
        return acctDeltaDao;
    }
    
    private GNE_Stg_Party_Dao getStgPartyDao() {
        if(ptyDao==null) {
            ptyDao = new GNE_Stg_Party_Dao(IsTestCase);
        }
        
        return ptyDao;
    }
    
    private GNE_MDM_Siperian_Dao getMdmSiperianDao() {
        if(mdmDao==null) {
            mdmDao = new GNE_MDM_Siperian_Dao(IsTestCase);
        }
        
        return mdmDao;
    }
    
    public void setSearchType(){
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        lwoProfileMode = profileName.containsIgnoreCase('LWO');
        cmProfileMode = profileName.containsIgnoreCase('GNE-CM');
        Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            
        if (mapConfigItems != null && mapConfigItems.size() > 0){
            String profiles = (String) mapConfigItems.get('SearchAccountLocalOnly').Configuration_Value_gne__c;
            if (profiles != null){
                List<String> splitFields = profiles.split(',');
                if (splitFields != null && splitFields.size() > 0){
                    for (String row : splitFields){
                        if (profileName != null && profileName.toUpperCase().contains(row.toUpperCase())){
                            searchLocalOnly = true;
                            break;
                        }
                    }
                }
            }   
        }
    }
    
    public static String fldList;   
    public static String getFieldStr(){
        return FIELD_LIST;
    }  
    
    //---Get using a pager
    public List<SFASearchStrings_gne__c> getByPager(GNE_Account_Pager pager){   
        List <SFASearchStrings_gne__c> acctList;  
        List <SFASearchStrings_gne__c> stgList;  
        
        if (pager.getIsAccountSearch()){
            //this is an Account search from New Address button on Account layouts
            //Just search staging data to look for external addresses for this account
            //stgList = getStgPartyDao().getByPager(pager); comment during SFA-2244
        }else{
            //this is an account and address search from the Account Search Create (SBC)
            //first get local data, then get MDM data and combine results.
            
            // SFDC Account's DAO works only for Canada users or only if MDM Siperian Service doesn't work. 
            // Otherwise Account's Delta DAO is used.
            if (searchLocalOnly) {
                acctList = getAccountDao().getByPager(pager);
                pager.localListSize = acctList.size();
            } else {
                Boolean masterDataServiceFailed = false;
                
                if (pager.isMdmIdSearchMode()){
                    Pager.mdmIdToRuleNumMap = new Map <String, String>();  
                    Pager.mdmIdToRuleNumMap.put(pager.currSearch.MDMID_gne__c.trim(), '0');
                    System.Debug('XXX MDMId Mode :Pager.mdmIdToRuleNumMap' + Pager.mdmIdToRuleNumMap);
                } else if (pager.isLincenseSearchMode()){
                    System.Debug('XXX License Mode search for License_Number : '+ pager.currSearch.License_Number_gne__c);
                    System.Debug('XXX License Mode search for License_State : '+ pager.currSearch.License_State_gne__c);
                    //stgList = getStgPartyDao().getHCPPartyByLicense(pager); remove during sfa-2244 j.laniecki 08/09/2016
                } else{ 
                    //its a name/address search, so call mdm web service
                    Exception ex;      
                    if (!IsTestCase){
                        ex = getMdmSiperianDao().getSiperianMatches(pager);
                    }  
                    if (ex != null){
                        ApexPages.Message myMsg;
                        if (ex instanceOf GNE_Account_Dao.TooManyResultsException){
                            debug('instance of toomanyresults. ex.getMessage()='+ex.getMessage());
                            Pager.clearFullList();  
                            throw ex;                   
                        } else{
                            masterDataServiceFailed = true;
                            System.debug('MASTER DATA SERVICE Exception - ' + ex.getMessage() + '\nStackTrace: ' + ex.getStackTraceString());
                            myMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error occurred calling the Master Data Service.  Only SFDC has been searched.');
                            ApexPages.addMessage( myMsg);
                        }
                    }
                }
                
                // mdmAddrIdSet will be filled by GNE_Account_Dao (acctDao) and used by GNE_Stg_Party_Dao (ptyDao)
                // to make sure that there will be no duplicates with the same MDM Address Id.
                // In Delta mode is not needed - it will remain empty.
                pager.mdmAddrIdSet = new Set <String>();
                
                Boolean localSearchInDeltaMode = !masterDataServiceFailed && !lwoProfileMode && !cmProfileMode && 
                        pager.isNameAddressSearchMode() && GNE_SFA2_Account_Delta_Engine.isDeltaModeEnabled();
                acctList = localSearchInDeltaMode ? getAccountDeltaDao().getByPager(pager) : getAccountDao().getByPager(pager);
                
                if (pager.mdmIdToRuleNumMap != null && pager.mdmIdToRuleNumMap.size() > 0){
                    //stgList = getStgPartyDao().getMDMResultData(pager);
                }
            }   
            if (stgList != null){       
                System.debug(Logginglevel.INFO,'stgList.size()='+ stgList.size());
            } else{
                System.debug(Logginglevel.INFO,'stgList is null');
                stgList = new List <SFASearchStrings_gne__c>{};
            }   
            
            if (acctList != null){
                System.debug(Logginglevel.INFO,'acctList.size()='+ acctList.size());
                System.debug(Logginglevel.INFO,'getMdmSiperianDao().lowestvalue='+ getMdmSiperianDao().lowestvalue);
                // Filtering results based on last name field 
                // This functionality is a workaround for switching from '%SearchString%'  to  'SerachString%'
                // Idally shoulde be implemented in GNE_Account_Dao when will be time
                if (pager.currSearch.AccountType_gne__c != 'HCO'){
                    String[] splitFields;
                    if (!isNullOrEmpty(pager.CurrSearch.OrgName_gne__c)) splitFields = pager.CurrSearch.OrgName_gne__c.split(' ');
                    if (splitFields != null && splitFields.size() > 0){
                        
                        if(splitFields.size() == 1){
                            Pager.currSearch.FirstName_gne__c = '';
                            Pager.currSearch.LastName_gne__c = splitFields[0];
                        }
                        if(splitFields.size() == 2){
                            Pager.currSearch.FirstName_gne__c = splitFields[0];
                            Pager.currSearch.LastName_gne__c = splitFields[1];
                        }
                        if(splitFields.size() > 2){
                            Pager.currSearch.FirstName_gne__c = splitFields[0];
                            Pager.currSearch.LastName_gne__c = splitFields[2];
                        }   
                    }
                    else{
                        System.debug('XXXXX Set frist name and last to clear');
                        Pager.currSearch.FirstName_gne__c = null;
                        Pager.currSearch.LastName_gne__c = null;
                    }
                }
                //########################################## 
                System.debug('XXXXX Pager.currSearch.FirstName_gne__c :' + Pager.currSearch.FirstName_gne__c );
                System.debug('XXXXX Pager.currSearch.LastName_gne__c :' + Pager.currSearch.LastName_gne__c );
                for (SFASearchStrings_gne__c row : acctList){
                    //row.Default_Sort_Field_gne__c = mdmDao.lowestvalue + '?' + row.Default_Sort_Field_gne__c;
                    if (pager.currSearch.AccountType_gne__c != 'HCO' && pager.GetIsNameSearch()){
                        
                        System.debug('XXXXX row.LastName_gne__c :' + row.LastName_gne__c );
                        if(Pager.currSearch.LastName_gne__c  != null && Pager.currSearch.FirstName_gne__c == null && row.LastName_gne__c.toUpperCase().startsWith(Pager.currSearch.LastName_gne__c.toUpperCase())){
                            row.Default_Sort_Field_gne__c = '1?' + row.Default_Sort_Field_gne__c;
                            stgList.add(row);
                        }
                        else if(Pager.currSearch.LastName_gne__c  != null && Pager.currSearch.FirstName_gne__c == null && row.FirstName_gne__c.toUpperCase().startsWith(Pager.currSearch.LastName_gne__c.toUpperCase())){
                            row.Default_Sort_Field_gne__c = '1?' + row.Default_Sort_Field_gne__c;
                            stgList.add(row);
                        }
                        else if(Pager.currSearch.LastName_gne__c  != null && Pager.currSearch.FirstName_gne__c != null &&  row.FirstName_gne__c.toUpperCase().startsWith(Pager.currSearch.FirstName_gne__c.toUpperCase()) && row.LastName_gne__c.toUpperCase().startsWith(Pager.currSearch.LastName_gne__c.toUpperCase())){
                            row.Default_Sort_Field_gne__c = '1?' + row.Default_Sort_Field_gne__c;
                            stgList.add(row);
                        }
                        else if(Pager.currSearch.LastName_gne__c  != null && Pager.currSearch.FirstName_gne__c != null &&  row.FirstName_gne__c.toUpperCase().startsWith(Pager.currSearch.LastName_gne__c.toUpperCase()) && row.LastName_gne__c.toUpperCase().startsWith(Pager.currSearch.FirstName_gne__c.toUpperCase())){
                            row.Default_Sort_Field_gne__c = '1?' + row.Default_Sort_Field_gne__c;
                            stgList.add(row);
                        }
                    }
                    else{
                        if (pager.currSearch.AccountType_gne__c != 'HCP'){
                            row.Default_Sort_Field_gne__c = '1?' + row.Default_Sort_Field_gne__c;
                            // Check that Account Type/Org Type is valid and comes from Stg tables.
                            System.debug('XXXXX Check that Account Type/Org Type is valid and comes from Stg tables');
                            System.debug('XXXXX look value for address_mdm_id :'+ row.Address_MDMID__c);
                            if(pager.mdmIdToAccTypeMap != null && pager.mdmIdToAccTypeMap.containsKey((String) row.Address_MDMID__c)){
                                System.debug('XXXXX Old Account type value: ' + row.Type_gne__c);
                                row.Type_gne__c = pager.mdmIdToAccTypeMap.get((String) row.Address_MDMID__c);
                                System.debug('XXXXX New Account type found and new value comes from Siperion : ' +row.Type_gne__c);
                            }
                            stgList.add(row);
                        }
                        else{
                            row.Default_Sort_Field_gne__c = '1?' + row.Default_Sort_Field_gne__c;
                            stgList.add(row);   
                        }
                    }
                }
            } else{
                System.debug(Logginglevel.INFO,'acctList is null');
            }   
        }           
        if (stgList != null) Pager.setRecordCount(stgList.size());
        if (stgList != null){
            System.debug(Logginglevel.INFO,'final stgList.size()='+ stgList.size());
            
            // All exact maches will be put on the top of the results list only when user perform Name Search
            if (pager.currSearch.AccountType_gne__c != 'HCP' && pager.GetIsNameSearch()){
                for (SFASearchStrings_gne__c row : stgList){
                    if(Pager.currSearch.OrgName_gne__c != null && row.OrgName_gne__c == Pager.currSearch.OrgName_gne__c.toUpperCase()){
                        if(row.Default_Sort_Field_gne__c.startsWith('1?')){
                            row.Default_Sort_Field_gne__c = '00' + row.Default_Sort_Field_gne__c.substring(2);
                        }
                        else{
                            row.Default_Sort_Field_gne__c = '0' + row.Name + row.Default_Sort_Field_gne__c.substring(1);
                        }
                        
                        
                    }
                }
            }
        } else{
            System.debug(Logginglevel.INFO,'final stgList is null');
        }   
        return stgList;
    }
    
    //---Get by UserId
    public SFASearchStrings_gne__c getByCurrentUser(){  
        String whereClause = 'ownerid = \''+Userinfo.getUserId()+'\'';
        String orderClause = 'CreatedDate DESC' ;  
        String FieldList = getFieldStr() + ',Account_Type_HCP_can__c, Account_Type_HCO_can__c, SAM_Account_Type_HCP_can__c, SAM_Account_Type_HCO_can__c, RAMA_Account_Type_HCO_can__c, RAMA_Account_Type_HCP_can__c';
        List<SFASearchStrings_gne__c> objList = (List<SFASearchStrings_gne__c>)getSObjectListByWhere(FieldList, NAME, whereClause ,orderClause);
        if (objList != null && objList.size() > 0)  return objList[0];
        return null; 
    } 
    //---Get User's prfile name
    //Added By MISZE : CR for CaseMgn User - START
    public boolean isCMuser(String profId){
        Profile userRecord = (Profile) getSObjectById(USER_PROF_FIELD ,'Profile',profId);
        if(userRecord.Name.contains('GNE-CM')) return true;
        // add case insen
        return false;
    }
    //Added By MISZE : CR for CaseMgn User - END
    
}