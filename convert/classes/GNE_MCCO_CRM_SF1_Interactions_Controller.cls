public with sharing class GNE_MCCO_CRM_SF1_Interactions_Controller extends GNE_MCCO_CRM_Base_Ctrl {

    private static final String ACCT_PREFIX = '001';
    public String accountIds {get; private set;}
    public Id interactionLogoId {get; private set;}
    public String userTimeZone {get; private set;}

    public GNE_MCCO_CRM_SF1_Interactions_Controller() {
        accountIds = getAccounts();
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        interactionLogoId = [SELECT Id FROM Document WHERE Name = 'Interaction Tab Logo' LIMIT 1].Id;
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
    public static Integer getInteractionsCount(String minAcctIds, String search) {
        List<String> acctIds = new List<String>();
        Id userId = UserInfo.getUserId();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        String query = 'SELECT count() FROM Call2_vod__c WHERE CreatedById =: userId AND Account_vod__c IN :acctIds AND Parent_Call_vod__c = null AND Call_Datetime_vod__c >= LAST_90_DAYS AND Call_Datetime_vod__c <= NEXT_90_DAYS';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ' OR Account_vod__r.Name Like \'%' + search + '%\'';
            query += ' OR Interaction_Status_gne__c Like \'%' + search + '%\'';
            query += ')';
        }

        System.debug('##### Query === ' + query);

        return Database.countQuery(query);
    }

    @RemoteAction
    public static List<InteractionWrapper> getInteractions(String minAcctIds, Integer displayLength, Integer displayStart, String search) {
        List<String> acctIds = new List<String>();
        Id userId = UserInfo.getUserId();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        List<InteractionWrapper> result = new List<InteractionWrapper>();

        String query = 'SELECT Id, Name, Account_vod__r.Name, Call_Datetime_vod__c, Interaction_Status_gne__c FROM Call2_vod__c WHERE CreatedById =: userId AND Account_vod__c IN :acctIds AND Parent_Call_vod__c = null AND Call_Datetime_vod__c >= LAST_90_DAYS AND Call_Datetime_vod__c <= NEXT_90_DAYS';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ' OR Account_vod__r.Name Like \'%' + search + '%\'';
            query += ' OR Interaction_Status_gne__c Like \'%' + search + '%\'';
            query += ')';
        }
        query += ' ORDER BY Name DESC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }

        System.debug('##### Query === ' + query);

        for (Call2_vod__c call : Database.query(query)) {
            result.add(new InteractionWrapper(call.Id, call.Name, call.Account_vod__r.Name, call.Interaction_Status_gne__c, call.Call_Datetime_vod__c));
        }

        return result;
    }


    /* WRAPPER CLASS */

    public class InteractionWrapper {

        private Id id {get; set;}
        private String callName {get; set;}
        private String accountName {get; set;}
        private String status {get; set;}
        private Datetime callDate {get; set;}

        public InteractionWrapper(Id id, String callName, String accountName, String status, Datetime callDate) {
            this.id = id;
            this.callName = callName;
            this.accountName = accountName;
            this.status = status;
            this.callDate = callDate;
        }
    }
}