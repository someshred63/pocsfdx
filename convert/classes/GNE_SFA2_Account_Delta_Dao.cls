public with sharing class GNE_SFA2_Account_Delta_Dao extends GNE_Account_Dao {
    
    private static final String HCP_DELTA_WHERE = String.valueOf(SFA2_Address_Delta_gne__c.Type_gne__c) + '=\'' + GNE_SFA2_Account_Delta_Engine.getHcpUsNoMdmIdType() + '\'';
    private static final String HCO_DELTA_WHERE = String.valueOf(SFA2_Address_Delta_gne__c.Type_gne__c) + '=\'' + GNE_SFA2_Account_Delta_Engine.getHcoUsNoMdmIdType() + '\'';
    private static final String ACCOUNT_REF_FIELD_PREFIX = 'Account_vod__r.';
    
    private Set<Id> altNamesAccountIds;
    
    public GNE_SFA2_Account_Delta_Dao(Boolean isTest) {
        super(isTest);
    }
    
    public override void init() {
        super.init();
        ClassName = GNE_SFA2_Account_Delta_Dao.class.getName();
    }
    
    public override List<SFASearchStrings_gne__c> getByPager(GNE_Account_Pager pager) {
        pager.whereClause = ' WHERE ' + (isHcoSearch(pager) ? HCO_DELTA_WHERE : HCP_DELTA_WHERE);
        
        if(Pager.GetIsNameSearch()) {
            final String nameField = String.valueOf(SFA2_Address_Delta_gne__c.Account_Name_gne__c);
            final String prefNameField = String.valueOf(SFA2_Address_Delta_gne__c.Account_Preferred_Name_gne__c);
            pager.whereClause += getNameWhere(pager, nameField, prefNameField);
        }else{
            pager.whereClause += ' ';
        }
                    
        if (Pager.GetIsAddressSearch()) {
			final String addrNameField = String.valueOf(SFA2_Address_Delta_gne__c.Address_Name_gne__c);
            final String cityField = String.valueOf(SFA2_Address_Delta_gne__c.Address_City_gne__c);
            final String stateField = String.valueOf(SFA2_Address_Delta_gne__c.Address_State_gne__c);
            final String zipField = String.valueOf(SFA2_Address_Delta_gne__c.Address_Zip_gne__c);
            
            pager.whereClause += getAddressWhere(pager, ' AND ', addrNameField, cityField, stateField, zipField);
        }   
        
        return executeQuery(pager);
    }
    
    private Boolean isHcoSearch(GNE_Account_Pager pager) {
    	return pager.CurrSearch.AccountType_gne__c == 'HCO';
    }
    
    protected override List<SFASearchStrings_gne__c> executeQuery(GNE_Account_Pager pager) {
        List<SFASearchStrings_gne__c> result = null;
        
        String fullQuery = 'SELECT Address_gne__c, Account_gne__c FROM SFA2_Address_Delta_gne__c' + pager.whereClause + 
                ' ORDER BY ' + (isHcoSearch(pager) 
                		? String.valueOf(SFA2_Address_Delta_gne__c.Account_Name_gne__c) 
                		: (String.valueOf(SFA2_Address_Delta_gne__c.Account_Last_Name_gne__c) + ', ' + String.valueOf(SFA2_Address_Delta_gne__c.Account_First_Name_gne__c))) +
                (IsTestCase ? ' LIMIT 1' : (' LIMIT ' + pager.getMaxResults()));
        System.debug('fullQuery = ' + fullQuery);
        Set<Id> addrIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<SFA2_Address_Delta_gne__c> deltaRecs = Database.query(fullQuery);
        
        for(SFA2_Address_Delta_gne__c deltaRec : deltaRecs) {
            addrIds.add(deltaRec.Address_gne__c);
            accIds.add(deltaRec.Account_gne__c);
        }
        
        if(!addrIds.isEmpty()) {
            fullQuery = BASE_QUERY.replace('$fieldList$', FIELD_LIST) + ' WHERE Id IN :accIds';
            fullQuery = fullQuery.replace('$where_addr$', 'WHERE Id IN :addrIds');
            result = buildResultsFromAccounts(Database.query(fullQuery), pager);
        }
        
        return result!=null ? result : new List<SFASearchStrings_gne__c>();
    }
    
    public override String getAltNameWhere(GNE_Account_Pager pager) {
        String sqlWhere = '';
        altNamesAccountIds = new Set<Id>();
        String searchText = pager.CurrSearch.OrgName_gne__c;
        
        List <Alternate_Name_gne__c> altList = altNameDao.getAccountsByAlternateName(pager.CurrSearch.OrgName_gne__c/*, whereClause*/); 
        
        for(Alternate_Name_gne__c altNameRec : altList) {
            altNamesAccountIds.add(altNameRec.Account_Name_gne__c);
        }
        
        if(!altNamesAccountIds.isEmpty()) {
            sqlWhere += ' Account_gne__c in :altNamesAccountIds ';
        }
        
        return sqlWhere;
    }
}