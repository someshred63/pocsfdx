//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Account_Dao
//   PURPOSE: Dao for Account   
//    
//   CREATED: 07/2010  
//--------------------------------------------------------------------------------
public with sharing virtual class GNE_Account_Dao extends GNE_Base_Dao{        
    public class AccountException extends Exception {}  
    public class TooManyResultsException extends Exception {}
    
    public GNE_Alternate_Name_Dao altNameDao;
    private static String NAME = 'Address_vod__c';
    
    public static final String HCP_WHERE = ' WHERE Account_Type_gne__c != \'ArchivedAccount\' AND IsPersonAccount = true AND RecordType.Name in (\'Professional_vod\',\'LWO Healthcare Professional_gne\')';
    public static final String HCO_WHERE = ' WHERE Account_Type_gne__c != \'ArchivedAccount\' AND IsPersonAccount = false AND RecordType.Name <> \'Professional_vod\'';
    
    public static final String HCP_WHERE_CAN = ' WHERE Account_Type_gne__c != \'ArchivedAccount\' AND IsPersonAccount = true AND RecordType.Name = \'HCP Canada\'';
    public static final String HCP_WHERE_RESTRICTED_CAN = ' AND ((Account_Type_gne__c IN (\'Pharmacist\', \'Physician\') AND MRM_Status_can_gne__c = \'ACTIVE\') OR (Account_Type_gne__c NOT IN (\'Pharmacist\', \'Physician\')))';
    public static final String HCO_WHERE_CAN = ' WHERE Account_Type_gne__c != \'ArchivedAccount\' AND IsPersonAccount = false AND RecordType.Name <> \'HCP Canada\'';
    
    public static final String MDM_SUB_QUERY = ' AND MDM_Address_ID_gne__c NOT IN ($mdm_list$)';
    
    public static final String FIELD_LIST = 'Id, Name, MDMID_gne__c, '
    + 'professional_Type_gne__c, Account_Type_gne__c, IsPersonAccount, '
    + 'FirstName, LastName, Middle_vod__c,  '
    + 'preferred_name_vod__c, Main_Address_gne__c, Roche_Id_can_gne__c, '
    + ' (SELECT Inactive_vod__c, MDM_Address_ID_gne__c, Id, name, address_1_gne__c, '
    + '  city_vod__c, state_vod__c, zip_vod__c, address_line_2_vod__c, License_vod__c, '
    + '  Postal_Code_can_gne__c, Province_can_gne__c, Country_gen__c ' 
    + '  FROM Address_vod__r $where_addr$ ORDER BY '
    + '  address_1_gne__c, city_vod__c, state_vod__c, zip_vod__c),'
    + ' (SELECT Account_Name_gne__c, Alternate_Name_gne__c , '
    + '  Alternate_Name_Type_gne__c from R00NR0000000VOJiMAO) ';
    
    public static final String ACCOUNT_FIELD_LIST = ' Id, Name, MDMID_gne__c, '
    + ' professional_Type_gne__c, Account_Type_gne__c, IsPersonAccount,  '
    + ' formatted_name_vod__c, FirstName, LastName, Middle_vod__c, RecordType.Description, '
    + ' preferred_name_vod__c, Main_Address_gne__c, Roche_Id_can_gne__c, '
    + ' (SELECT Inactive_vod__c, MDM_Address_ID_gne__c, Id, name, address_1_gne__c, '
    + '  city_vod__c, state_vod__c, zip_vod__c, address_line_2_vod__c, License_vod__c, Postal_Code_can_gne__c, Province_can_gne__c, Country_gen__c '
    + '  FROM Address_vod__r ORDER by CreatedDate DESC) ';
    
    public static final String ADDRESS_FIELD_LIST = ' Inactive_vod__c, MDM_Address_ID_gne__c, Id, Name, '
    + ' city_vod__c, state_vod__c, zip_vod__c, address_line_2_vod__c, address_1_gne__c, Postal_Code_can_gne__c, Province_can_gne__c, Country_gen__c ';

    public static String BASE_QUERY = 'SELECT $fieldList$ FROM Account';
    public static final String TOO_MANY_RESULTS_MSG = 'Too many query rows';
    
    //---Test Constructor
    public GNE_Account_Dao(boolean testCase){
        IsTestCase = testCase;
        init();
    }
    
    public virtual void init(){
        ObjectName = NAME;
        ClassName = 'GNE_Account_Dao';
        altNameDao = new GNE_Alternate_Name_Dao(IsTestCase);
    }
    
    public static String fldList;   
    public static String getFieldStr(){
        return ACCOUNT_FIELD_LIST;
    }
    
    //---Get by Id
    public Account getById(String idInp){
        Account obj = (Account)getSObjectById(getFieldStr(), 'Account', idInp);
        return obj;
    }  
    
    //---Get by MDM Id - this field is an external ID, is unique so will just return 1 row
    public Account getByMDMId(String idInp){
        String whereClause = ' MDMID_gne__c = \'' + idInp + '\'';
        List <Account> objList = (List <Account>) getSObjectListByWhere(getFieldStr(), 'Account', whereClause);
        if (objList != null && objList.size() > 0) return objList[0];
        return null;
    }  
    
    //---Get an Address by MDM Address Id 
    public Address_vod__c getByMDMAddressId(String idInp){
        String whereClause = ' MDM_Address_ID_gne__c = \'' + idInp + '\'';
        List <Address_vod__c> objList = (List <Address_vod__c>) getSObjectListByWhere(ADDRESS_FIELD_LIST, NAME, whereClause);
        if (objList != null && objList.size() > 0) return objList[0];
        return null;
    }  

    //---Get an Account.Id given the Address_vod__c.Id     
    public String getAccountIdForAddressId(String idInp){
        Address_vod__c addr = [select Account_vod__c from Address_vod__c where id = :idInp];
        if (addr != null) return addr.Account_vod__c;
        return null;
    }
    
    //---Get a list of Address_vod__c objects given the Account.Id
    public Map <String, Address_vod__c> getAddressesForAccountId(String idInp){
        Map <String, Address_vod__c> addrList = new Map <String, Address_vod__c>([select Id, mdm_address_id_gne__c from Address_vod__c where Account_vod__c = :idInp]);
        return addrList;
    } 
    
    //---Get using a pager.  Used in Account Search Create page.
    //---The pager contains attributes used to hold the user request parameters
    //---as well as the result of the search. 
    public virtual List<SFASearchStrings_gne__c> getByPager(GNE_Account_Pager pager) {
        String whereClause = '';    
        
        if (Pager.isMdmIdSearchMode()){
            pager.whereClause = addSqlWhereMatch( 'MdmId_gne__c', pager.CurrSearch.MDMId_gne__c);
        } else{
            //mode is NameAddress
            if(Pager.GetIsNameSearch()){
                pager.whereClause = getNameWhere(pager);
            }else{
                pager.whereClause = ' ';
            }
            
            if(!isNullOrEmpty(pager.CurrSearch.Roche_Id_can_gne__c)){ 
                pager.whereClause += addSqlLikeStart('Roche_Id_can_gne__c', pager.CurrSearch.Roche_Id_can_gne__c);
            }
            // add additional criteria for CANADA users
            if(getHasCanadaProfile()){
                if (pager.CurrSearch.AccountType_gne__c == 'HCO'){
                    if(GNE_SFA2_Util.isCanadaRAMA()) {
                        if(!isNullOrEmpty(pager.CurrSearch.RAMA_Account_Type_HCO_can__c)){
                            String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.RAMA_Account_Type_HCO_can__c).replace(';', '\' , \'');
                            pager.whereClause += addSqlWhereIN('Account_Type_gne__c',fieldValue);
                        }
                    } else {
                        if(!isNullOrEmpty(pager.CurrSearch.Account_Type_HCO_can__c)){
                            String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.Account_Type_HCO_can__c).replace(';', '\' , \'');
                            pager.whereClause += addSqlWhereIN('Account_Type_gne__c',fieldValue);
                        }
                    }
                }
                if (pager.CurrSearch.AccountType_gne__c == 'HCP'){
                    Boolean isRestrictedMode = false; 
                    String profileName = getProfileName();

                    if(GNE_SFA2_Util.isCanadaRAMA()) {
                        if(!isNullOrEmpty(pager.CurrSearch.RAMA_Account_Type_HCP_can__c)){
                            String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.RAMA_Account_Type_HCP_can__c).replace(';', '\' , \'');
                            pager.whereClause += addSqlWhereIN('Account_Type_gne__c',fieldValue);

                            if(profileName != 'RCanada-SFA-Ops'
                            && (pager.CurrSearch.RAMA_Account_Type_HCP_can__c.contains('Pharmacist')
                                || pager.CurrSearch.RAMA_Account_Type_HCP_can__c.contains('Physician'))) {
                                isRestrictedMode = true;
                            }
                        } else if(profileName != 'RCanada-SFA-Ops') {
                            isRestrictedMode = true;
                        }
                    } else {
                        if(!isNullOrEmpty(pager.CurrSearch.Account_Type_HCP_can__c)){                            
                            String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.Account_Type_HCP_can__c).replace(';', '\' , \'');
                            pager.whereClause += addSqlWhereIN('Account_Type_gne__c',fieldValue);

                            if(profileName != 'RCanada-SFA-Ops'
                            && (pager.CurrSearch.Account_Type_HCP_can__c.contains('Pharmacist')
                                || pager.CurrSearch.Account_Type_HCP_can__c.contains('Physician'))) {
                                isRestrictedMode = true;
                            }
 
                        }
                        else if(profileName != 'RCanada-SFA-Ops') {
                            isRestrictedMode = true;
                        }
                    }

                    if(isRestrictedMode) {
                        pager.whereClause += HCP_WHERE_RESTRICTED_CAN;
                    }

                    if(!isNullOrEmpty(pager.CurrSearch.Specialties_can__c)){
                        String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.Specialties_can__c).replace(';', '\' , \'');
                        pager.whereClause += addSqlWhereInclude('Specialties_can_gne__c',fieldValue);
                    }
                    
                    if(!isNullOrEmpty(pager.CurrSearch.Rep_Speciality_can__c)){
                        String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.Rep_Speciality_can__c).replace(';', '\' , \'');
                        pager.whereClause += addSqlWhereInclude('Rep_Specialty_can_gne__c',fieldValue);
                    }
                    
                    if(!isNullOrEmpty(pager.CurrSearch.Active_US_License_gne__c)){
                        String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.Active_US_License_gne__c).replace(';', '\' , \'');
                        pager.whereClause += addSqlWhereMatch('Active_US_License_gne__c',fieldValue);
                    }

                    if(!isNullOrEmpty(pager.CurrSearch.Tier_Level_gne__c)){
                        String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.Tier_Level_gne__c).replace(';', '\' , \'');
                        pager.whereClause += addSqlWhereIN('Tier_Level_gne__c',fieldValue);
                    }

                    if(!isNullOrEmpty(pager.CurrSearch.HCP_Stakeholder_Type_gne__c)){
                        String fieldValue = String.escapeSingleQuotes(pager.CurrSearch.HCP_Stakeholder_Type_gne__c).replace(';', '\' , \'');
                        pager.whereClause += addSqlWhereIN('HCP_Stakeholder_Type_gne__c',fieldValue);
                    }
                }
            }
            
            if (Pager.GetIsAddressSearch()){
                String whereStart = ' AND Id IN (SELECT Account_vod__c FROM Address_vod__c WHERE ';
                pager.whereClause += getAddressWhere(pager, whereStart);
                pager.whereClause += ') ';
            }   
        }
        return executeQuery(pager);       
    }
    
    //---Setup address part of where clause
    protected String getAddressWhere(GNE_Account_Pager pager, String whereStart){
        return getAddressWhere(pager, whereStart, 'name', 'city_vod__c', 'state_vod__c', 'zip_vod__c');
    }
    protected String getAddressWhere(GNE_Account_Pager pager, String whereStart, 
            final String nameField, final String cityField, final String stateField, final String zipField){
        String sqlWhere = '';
        
        if (pager.CurrSearch.Street_gne__c != null){
            sqlWhere += addSqlWhere( nameField, pager.CurrSearch.Street_gne__c);
        }
        
        if (!isNullOrEmpty(pager.CurrSearch.City_gne__c)){
            sqlWhere += addSqlWhere( cityField, pager.CurrSearch.City_gne__c);
        }
        
        if (!isNullOrEmpty(pager.CurrSearch.State_gne__c)){
            sqlWhere += addSqlWhereMatch( stateField, pager.CurrSearch.State_gne__c);
        }
        
        if (pager.CurrSearch.Zip_gne__c != null){
            sqlWhere += addSqlLikeStart( zipField, pager.CurrSearch.Zip_gne__c);
        }
        
        if(pager.CurrSearch.Postal_Code_can_gne__c != null){
            sqlWhere += addSqlLikeStart( 'Postal_Code_can_gne__c', pager.CurrSearch.Postal_Code_can_gne__c);
        }
        
        if(!isNullOrEmpty(pager.CurrSearch.Province_can_gne__c)){
            sqlWhere += addSqlWhereMatch( 'Province_can_gne__c', pager.CurrSearch.Province_can_gne__c);
        }
        
        if(!isNullOrEmpty(pager.CurrSearch.Country_can_gen__c)){ 
            sqlWhere += addSqlWhereMatch( 'Country_gen__c', pager.CurrSearch.Country_can_gen__c);
        }

        //hide inactive addresses
        sqlWhere += addSqlWhereMatch( 'Inactive_vod__c', false);
        
        sqlWhere = removeLeadingAnd( sqlWhere);
        
        sqlWhere = whereStart + sqlWhere;
        
        return sqlWhere;
    }
    
    //---Setup Name part of where clause.... new for version 2.2
    protected String getNameWhere(GNE_Account_Pager pager) {
        final String nameField = String.valueOf(Account.Name);
        final String prefNameField = String.valueOf(Account.Preferred_Name_vod__c);
        return getNameWhere(pager, nameField, prefNameField);
    }
    
    protected String getNameWhere(GNE_Account_Pager pager, final String nameField, final String prefNameField) {
        String query;
        String nameWhere = ' ';
        String prefNameWhere = ' ';
        String altWhere = getAltNameWhere(pager);
        
        String[] splitFields;
        if (!isNullOrEmpty(pager.CurrSearch.OrgName_gne__c)) splitFields = pager.CurrSearch.OrgName_gne__c.split(' ');
        if (splitFields != null && splitFields.size() > 0){
            if (pager.CurrSearch.AccountType_gne__c == 'HCP'){
                for (String row : splitFields){
                    nameWhere += addSqlWhere( nameField, row);
                    prefNameWhere += addSqlWhere( prefNameField, row);
                }
                query = ' AND ((' + nameWhere.substring(5) + ') OR (' + prefNameWhere.substring(5) + ')';
                if (!isNullOrEmpty(altWhere)){
                    query +=  ' OR (' + altWhere + ')) ';
                } else{
                    query +=  ') '; 
                }
            }
            else{
                nameWhere += addSqlWhereLikeInside( nameField, splitFields);
                prefNameWhere += addSqlWhereLikeInside( prefNameField, splitFields);
                
                query = ' AND ((' + nameWhere.substring(5) + ') OR (' + prefNameWhere.substring(5) + ')';
                if (!isNullOrEmpty(altWhere)){
                    query +=  ' OR (' + altWhere + ')) ';
                } else{
                    query +=  ') '; 
                }
            }
        }
        return query;
    }

    public virtual String getAltNameWhere(GNE_Account_Pager pager){
        String sqlWhere = '';
        
        List <Alternate_Name_gne__c> altList;
        altList = altNameDao.getAccountsByAlternateName(pager.CurrSearch.OrgName_gne__c);
        
        if (altList != null && altList.size() > 0){
            sqlWhere += ' Id in (';
            boolean firstOne = true;
            for (Alternate_Name_gne__c row : altList){
                if (!firstOne) sqlWhere += ',';
                sqlWhere += '\'' + String.escapeSingleQuotes(row.Account_Name_gne__c) + '\'';
                firstOne = false;
            }
            sqlWhere += ') ';
        }
        
        return sqlWhere;
    }
    
    protected virtual List<SFASearchStrings_gne__c> executeQuery(GNE_Account_Pager pager){
        List <SFASearchStrings_gne__c> returnList;
        String licNames;
        Address_vod__c primAddr;
        SFASearchStrings_gne__c result;

        String fullQuery = '';
        String countQuery = '';
        String orderBy = ' ORDER BY '; 
        Integer recCount = 0;
        
        debug('pager.whereClause='+pager.whereClause);
        
        if(getHasCanadaProfile()){
            if (pager.CurrSearch.AccountType_gne__c == 'HCO'){
                fullQuery = BASE_QUERY.replace('$fieldList$', FIELD_LIST) + HCO_WHERE_CAN + pager.whereClause;
                orderBy += 'Name';
            } else {
                String profileName = getProfileName();                
                fullQuery = BASE_QUERY.replace('$fieldList$', FIELD_LIST) + HCP_WHERE_CAN + pager.whereClause;
                orderBy += 'LastName, FirstName';
            }
        }else{
            if (pager.CurrSearch.AccountType_gne__c == 'HCO'){
                fullQuery = BASE_QUERY.replace('$fieldList$', FIELD_LIST) + HCO_WHERE + pager.whereClause;
                orderBy += 'Name';
            } else {
                fullQuery = BASE_QUERY.replace('$fieldList$', FIELD_LIST) + HCP_WHERE + pager.whereClause;
                orderBy += 'LastName, FirstName';
            }
        }
        
        if (pager.isNameAddressSearchMode() && pager.GetIsAddressSearch()){
            fullQuery = fullQuery.replace('$where_addr$', getAddressWhere(pager, ' WHERE '));       
        } else{
            fullQuery = fullQuery.replace('$where_addr$', '');
        }
        
        if (!pager.currSearch.Show_Plans_gne__c){
            fullQuery += ' AND RecordType.Name != \'MCO Plan_vod\' ';
        }    
        
        fullQuery += orderBy;
        if (IsTestCase){   
            fullQuery += ' LIMIT 1';
        } else{
            fullQuery += ' LIMIT ' + pager.getMaxResults();
        }       
        
        debug('fullQuery='+fullQuery);
        
        returnList = buildResultsFromQuery(fullQuery, pager);
        return returnList;  
    }
    
    protected List<SFASearchStrings_gne__c> buildResultsFromQuery(String query, GNE_Account_Pager pager){
        return buildResultsFromAccounts(Database.query(query), pager);
    }
    
    protected List<SFASearchStrings_gne__c> buildResultsFromAccounts(List<Account> acctList, GNE_Account_Pager pager){
        List<SFASearchStrings_gne__c> returnList = new List<SFASearchStrings_gne__c>{};
        SFASearchStrings_gne__c result;
        Id primaryAddrId;
        Integer addrRowNum;
        Pager.mdmAddrIdSet = new Set <String>();
        String profileName = getProfileName();
        
        if (acctList != null && acctList.size() >= pager.getMaxResults()){
            system.debug('XX Acc pager.SearchOnlyFirstMax  : ' + pager.SearchOnlyFirstMax);
            if(pager.SearchOnlyFirstMax == false){
                pager.ShowTooManyResults = true;
                throw new TooManyResultsException();
            }
            else if(pager.SearchOnlyFirstMax == true){
                system.debug('error TooManyResultsException should be trow but SearchOnlyFirstMax is set to :' +pager.SearchOnlyFirstMax);
            }
            
        } else{
            for(Account row : acctList){           
                
                if (returnList != null && returnList.size() >= pager.getMaxResults()){
                    system.debug('XX Acc1 pager.SearchOnlyFirstMax  : ' + pager.SearchOnlyFirstMax);
                    if(pager.SearchOnlyFirstMax == false){
                        pager.ShowTooManyResults = true;
                        throw new TooManyResultsException();
                    }
                    else if(pager.SearchOnlyFirstMax == true){
                        system.debug('error TooManyResultsException should be trow but SearchOnlyFirstMax is set to :' +pager.SearchOnlyFirstMax);
                    }
                }   
                if (row.Main_Address_gne__c != null){
                    primaryAddrId = row.Main_Address_gne__c;
                } else{
                    if (row.Address_vod__r != null && row.Address_vod__r.size() > 0) primaryAddrId = row.Address_vod__r[0].Id;
                }
                
                if (row.Address_vod__r != null && row.Address_vod__r.size() > 0){
                    for (Address_vod__c addrRow : row.Address_vod__r){
                        if (addrRow.Id == primaryAddrId){
                            addrRowNum = 0;
                        } else{
                            addrRowNum = 1;
                        }
                        result = createSearchResult(addrRow, row, addrRowNum, Pager.CurrSearch);
                        //also set Address_MDM_Id_gne__c to the Address ID because this will be used
                        //in the page to pass into the subscribe method for consistency.
                        result.Address_Mdm_Id_gne__c = addrRow.Id;
                        result.Address_MDMID__c = addrRow.MDM_Address_ID_gne__c;
                        returnList.Add(result);
                        if (!isNullOrEmpty(addrRow.MDM_Address_ID_gne__c)) pager.mdmAddrIdSet.add(addrRow.MDM_Address_ID_gne__c);
                    }
                } else{
                    //no addresses for this account, if LWO Profile only, create a basic result object with just account data.
                    //this is because LWO profiles (Lucentis Web Ordering) create and use accounts with no addresses
                    if (profileName != null && (profileName.contains('LWO') || profileName.contains('GNE-CM'))){
                        result = createNoAddressSearchResult(row, Pager.CurrSearch);
                        returnList.Add(result);
                    }       
                }           
            }
        }         
        debug('<buildResultsFromQuery> returnList.size() = '+returnList.size());     
        return returnList;
    }    
    
    protected SFASearchStrings_gne__c createSearchResult(Address_vod__c addrRow, Account row, Integer resultRow, SFASearchStrings_gne__c currSearch){
        SFASearchStrings_gne__c result = new SFASearchStrings_gne__c();
        
        result.Address_seq_gne__c = resultRow + '';
        populateNameFields(result, row, currSearch);
        result.Street_gne__c = addrRow.Name;
        if (!isNullOrEmpty(addrRow.Address_line_2_vod__c)) result.Street_gne__c +=  ' \n' + addrRow.Address_line_2_vod__c;
        result.Street_2_gne__c = addrRow.Address_line_2_vod__c;
        result.City_gne__c = addrRow.City_vod__c;
        result.State_gne__c = addrRow.State_vod__c;
        result.Zip_gne__c = addrRow.Zip_vod__c;
        String url = 'http://maps.google.com/maps?f=q&hl=en&q=' + EncodingUtil.urlEncode(String.valueOf(addrRow.Name) +'+'+ String.valueOf(addrRow.City_vod__c) +'+'+ String.valueOf(addrRow.State_vod__c) +'+'+ String.valueOf(addrRow.Zip_vod__c), 'UTF-8');
        result.Map_Url_gne__c = url;
        
        result.Postal_Code_can_gne__c = addrRow.Postal_Code_can_gne__c;
        result.Province_can_gne__c = addrRow.Province_can_gne__c;

        return result;  
    } 
    
    protected SFASearchStrings_gne__c createNoAddressSearchResult(Account row, SFASearchStrings_gne__c currSearch){
        SFASearchStrings_gne__c result = new SFASearchStrings_gne__c();
        populateNameFields(result, row, currSearch);
        return result;  
    } 
    
    protected void populateNameFields(SFASearchStrings_gne__c result, Account row, SFASearchStrings_gne__c currSearch){
        String licNames = '';
        String altNames = '';
        
        if (currSearch.AccountType_gne__c == 'HCP'){
            result.Type_gne__c = row.Professional_Type_gne__c;
        } else{
            result.Type_gne__c = row.Account_Type_gne__c;
        }
        
        if (!isNullOrEmpty(row.Preferred_Name_vod__c)) altNames = row.Preferred_Name_vod__c; 
        
        for (Alternate_Name_gne__c altNmRow : row.R00NR0000000VOJiMAO){
            if (altNames > '') altNames += ', ';
            altNames += altNmRow.Alternate_Name_gne__c;
        }   
        
        if (altNames.length() > 255) altNames = altNames.substring(0, 250) + '...';
        result.AKA_gne__c = altNames;   

        result.Account_gne__c = row.Id;   
        result.Address_Mdm_Id_gne__c = row.Id;
        
        //concatenate middle name to first name for display purposes
        if (!isNullOrEmpty(row.Middle_vod__c)){
            result.FirstName_gne__c = row.FirstName + ' ' + row.Middle_vod__c;
        } else{
            result.FirstName_gne__c = row.FirstName;
        }   
        result.LastName_gne__c = row.LastName;
        if (licNames.length() > 255) licNames = licNames.substring(0, 250) + '...';
        result.License_Number_gne__c = licNames;
        result.OrgName_gne__c = row.Name;
        result.MDMID_gne__c = row.MDMID_gne__c;
        //result.Address_Seq_gne__c = '0';
        result.Roche_Id_can_gne__c = row.Roche_Id_can_gne__c;
        
        setNameAndSort(result, currSearch);     
    }
    
    protected void setNameAndSort(SFASearchStrings_gne__c result, SFASearchStrings_gne__c currSearch){
        String sortOrd;
        if (currSearch.AccountType_gne__c == 'HCO'){   

            //result.Default_Sort_Field_gne__c =  sortOrd + result.OrgName_gne__c.toUpperCase() + result.Address_Seq_gne__c;
            //NEW
            result.Default_Sort_Field_gne__c =  result.OrgName_gne__c.toUpperCase() + result.Address_Seq_gne__c;
            result.Name = '0';
        } else{

            String sortField =  result.LastName_gne__c.toUpperCase();
            if (result.FirstName_gne__c != null) sortField += ' ' + result.FirstName_gne__c.toUpperCase();
            sortField += + result.Address_Seq_gne__c;
            result.Default_Sort_Field_gne__c  = sortField;
            result.Name = '0';
        }   
    }
    //method to indicate whether the logged on user is a Lucentis Web Order user (LWO)
    protected String getProfileName(){
        return [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
    }
    
    public boolean getHasCanadaProfile() {
        String profileName = getProfileName();
        if (profileName != null && profileName.toUpperCase().contains('CANADA')) {
            return true;
        } else {
            return false;
        }    
    }
}