public with sharing class GNE_MCCO_CRM_SF1_Accounts_Controller {

	private static final String ACCT_PREFIX = Account.sObjectType.getDescribe().getKeyPrefix();
    public String accountIds {get; private set;}

    public GNE_MCCO_CRM_SF1_Accounts_Controller() {
        accountIds = getAccounts();
    }

    private String getAccounts() {
        Set<String> territories = new Set<String>();
        for(Territory2 t : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
            territories.add(t.Name);
        }
        String result = '';
        for (TSF_vod__c tsf : [SELECT Account_vod__c FROM TSF_vod__c WHERE External_Id_vod__c != null AND Address_vod__c != null AND Territory_vod__c IN : territories AND Account_vod__r.IsPersonAccount = false LIMIT 49000]) {
            String minAcctId = String.valueOf(tsf.Account_vod__c).substring(3,4) + String.valueOf(tsf.Account_vod__c).substring(8,18);
            if(!result.contains(minAcctId)) {
                result += minAcctId + ',';
            }
        }
        return result.removeEnd(',');
    }

    @RemoteAction
    public static Integer getAccountsCount(String minAcctIds, String search) {
        List<String> acctIds = new List<String>();
        Id userId = UserInfo.getUserId();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        String query = 'SELECT count() FROM Account WHERE Id IN : acctIds';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ')';
        }

        return Database.countQuery(query);
    }

    @RemoteAction
    public static List<AccountWrapper> getAccounts(String minAcctIds, Integer displayLength, Integer displayStart, String search) {
        List<String> acctIds = new List<String>();
        Id userId = UserInfo.getUserId();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        List<AccountWrapper> result = new List<AccountWrapper>();

        String query = 'SELECT Id, Name, (SELECT Name from Address_vod__r WHERE Primary_vod__c = true) FROM Account WHERE Id IN :acctIds';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ')';
        }
        query += ' ORDER BY Name ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }

        for (Account a : Database.query(query)) {
            result.add(new AccountWrapper(a.Id, a.Name, a.Address_vod__r));
        }

        return result;
    }


    /* WRAPPER CLASS */

    public class AccountWrapper {

        private Id id {get; set;}
        private String acctName {get; set;}
        private String address {get; set;}
        private String status {get; set;}
        private Datetime callDate {get; set;}

        public AccountWrapper(Id id, String acctName, List<Address_vod__c> addresses) {
            this.id = id;
            this.acctName = acctName;
            this.address = !addresses.isEmpty() ? addresses.get(0).Name : '';
        }
    }
}