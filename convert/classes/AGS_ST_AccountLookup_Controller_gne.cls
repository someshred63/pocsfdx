/** @date 8/13/2013
* @Author Pawel Sprysak
* @description Controller for AGS_ST_AccountLookup_gne page
*/
public without sharing class AGS_ST_AccountLookup_Controller_gne {
    private final static Integer  MAX_ACCOUNTS_IN_FIRST_QUERY = 10000;
    private final static Integer  MAX_ACCOUNTS_IN_SECOND_QUERY = 1000;
    public String                 lookupId     { get; set; }
    // Search filter holders
    public String                 firstName    { get; set; }
    public String                 lastName     { get; set; }
    public String                 mdmId        { get; set; }
    public String                 npi          { get; set; }
//    public String licenseStateNo         { get; set; }
//    public String licenseStateSt         { get; set; }
    // List vars
    private String                soqlWhereStatement { get; set; }
    public Boolean                isMaxDisputes { get; set; }
    public List<Account>          accountList  { get; set; }
    public AGS_ST_DMPagingAndSortingUtils accountListUtil { get; set; }

    public AGS_ST_AccountLookup_Controller_gne() {
        lookupId = System.currentPageReference().getParameters().get('lknm');
        accountList = new List<Account>();
        accountListUtil = new AGS_ST_DMPagingAndSortingUtils();
        accountListUtil.totalDisputes = 0;
    }

    public PageReference updateFilter() {
        List<String> andStatementList = new List<String>();
        //andStatementList.add('DCH_Merge_Status_gne__c = \'Merge Completed\'');
        //andStatementList.add('DCH_Action_gne__c = \'Winner\'');
        if(!firstName.equals('')) {
            andStatementList.add('FirstName LIKE \'' + String.escapeSingleQuotes(firstName.trim()).replace('*', '%') + '\'');
        }
        if(!lastName.equals('')) {
            andStatementList.add('LastName LIKE \'' + String.escapeSingleQuotes(lastName.trim()).replace('*', '%') + '\'');
        }
        if(!mdmId.equals('')) {
            andStatementList.add('MDMID_gne__c = \'' + mdmId + '\'');
        }
        if(!npi.equals('')) {
            andStatementList.add('NPI_vod__c = \'' + npi + '\'');
        }
        /*
        if(!licenseStateNo.equals('')) {
            andStatementList.add('??? = \'' + licenseStateNo + '\'');
        }
        if(!licenseStateSt.equals('')) {
            andStatementList.add('??? = \'' + licenseStateSt + '\'');
        }
        */

        String whereStatement = '';
        for(String andStat : andStatementList) {
            if(whereStatement.equals('')) {
                whereStatement = andStat;
            } else {
                whereStatement += ' AND ' + andStat;
            }
        }
        if(!whereStatement.equals('')) {
            whereStatement = ' WHERE ' + whereStatement;
        }
        soqlWhereStatement = whereStatement;

        String selectQuery = 'SELECT Id FROM Account';
        if(!soqlWhereStatement.equals('')) {
            selectQuery += soqlWhereStatement;
        }
        selectQuery += ' LIMIT ' + MAX_ACCOUNTS_IN_FIRST_QUERY;
        Map<Id, Id> accountMapIds = new Map<Id, Id>();
        //Map<Id, Account> accountMap = new Map<Id, Account>(Database.query(selectQuery));
        Map<Id, Id> accountMap = new Map<Id, Id>();
        System.debug(selectQuery);
        for(Account acc : Database.query(selectQuery)) {
            accountMap.put(acc.Id, acc.Id);
        }
        for(User usr : [SELECT accountId FROM User WHERE accountId IN :accountMap.keySet()]) {
            accountMapIds.put(usr.accountId, usr.accountId);
        }
        List<Id> finalAccountIds = new List<Id>();
        for(Id allActIds : accountMap.keySet()) {
            if(!accountMapIds.containsKey(allActIds)) {
                finalAccountIds.add(allActIds);
            }
        }
        accountList = [SELECT Id, Name, FirstName, LastName, MDMID_gne__c, NPI_vod__c FROM Account WHERE Id IN :finalAccountIds LIMIT :MAX_ACCOUNTS_IN_SECOND_QUERY];
        accountListUtil.setParameters(accountList.size());

        return null;
    }

    public List<Account> getFinalAccountList() {
        ApexPages.StandardSetController physicianDisputeSSC = new ApexPages.StandardSetController(accountList);
        physicianDisputeSSC.setPageSize(accountListUtil.perPage);
        physicianDisputeSSC.first();
        for(Integer i=1; i<accountListUtil.actualPage; i++) {
            physicianDisputeSSC.next();
        }
        return (List<Account>)physicianDisputeSSC.getRecords();
    }
}