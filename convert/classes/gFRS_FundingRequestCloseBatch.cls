/**
 * Created by kozminsl on 22.01.2019.
 */

public with sharing class gFRS_FundingRequestCloseBatch implements Database.Batchable<SObject>, Schedulable {

    private static final Integer DAY_DELAY = -14;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM GFRS_Funding_Request__c WHERE Status__c != {0} AND SYS_Request_Approved__c = {1} AND LOA_Signed__c = {2} AND SAP_Payment_ID__c != null AND Program_End_Date_max__c < {3} AND Record_Type_Name__c IN {4}';
        String formattedDate = System.now().addDays(DAY_DELAY).format('yyyy-MM-dd');
        query = String.format(query, new List<String>{
                '\'' + gFRS_Util.REQUEST_STATUS_CLOSED + '\'', '\'' + gFRS_Util.YES + '\'', '\'' + gFRS_Util.YES + '\'', formattedDate, joinTypes(gFRS_Util.INTERNAL_FUNDING_TYPES)
        });
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        for(GFRS_Funding_Request__c request : (List<GFRS_Funding_Request__c>) scope){
            request.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
    }

    private static String joinTypes(Set<String> fundingTypes) {
        String result = '(';
        for (String fType : fundingTypes) {
            result += '\'' + fType + '\', ';
        }
        result = result.substring(0, result.length() - 2);
        result += ')';
        return result;
    }

    public void execute(SchedulableContext sc) {
        Database.Batchable<SObject> batch = new gFRS_FundingRequestCloseBatch();
        Database.executeBatch(batch);
    }
}