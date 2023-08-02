/** @date 10/14/2012
* @Author Pawel Sprysak
* @description Batch class for sending Emails to CCO with reminder about Held Transactions
*/
global class AGS_ST_HeldTransactionEmail_Batch_gne { //implements Database.Batchable<SObject>, Database.Stateful {
	/* HD Decommissioning
    private Map<String,List<AGS_ST_Held_And_Dispute_Junction_gne__c>> heldTransactionMap;
    private List<AGS_ST_Held_And_Dispute_Junction_gne__c> junctionList;
    */

    /** @date 10/14/2012
    * @Author Pawel Sprysak
    * @description Method for collecting data into batch
    * @param Database.BatchableContext context
    * @return Database.Querylocator
    */
    /* HD Decommissioning
    global Database.Querylocator start(Database.BatchableContext context) {
        heldTransactionMap = new Map<String,List<AGS_ST_Held_And_Dispute_Junction_gne__c>>();
        //Get list of all not processed Held Junction - for changing their statuses
        junctionList = AGS_ST_DbUtils.getAllNotProcessedHeldJuncList();
        //Get list of all not processed Held Junction related to resolved disputes
        return Database.getQueryLocator(
                    [SELECT Id, AGS_ST_Dispute_Management_gne__r.Id, AGS_ST_Dispute_Management_gne__r.Name, AGS_ST_Held_Transaction_gne__r.Name, AGS_ST_Held_Transaction_gne__r.Id, AGS_ST_Held_Transaction_gne__r.Source_Transaction_Amount_gne__c FROM AGS_ST_Held_And_Dispute_Junction_gne__c 
                        WHERE AGS_ST_ProcessedByEmailBatch_gne__c = false 
                        AND (AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c = 'Resolved With Correction' OR AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c = 'Resolved No Correction' OR AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c = 'Corrected Pending SSR')]
                );
    }
    */

    /** @date 10/14/2012
    * @Author Pawel Sprysak
    * @description Method for processing data in batch
    * @param Database.BatchableContext context
    * @param List<SObject> scope
    */
    /* HD Decommissioning
    global void execute(Database.BatchableContext context, List<SObject> scope) {
        //Changing batch process status
        for(AGS_ST_Held_And_Dispute_Junction_gne__c juncObj : junctionList) {
            juncObj.AGS_ST_ProcessedByEmailBatch_gne__c = true;
        }
        //Create map for Held Transaction Junc objects
        for(SObject heldJuncRec : scope) {
            AGS_ST_Held_And_Dispute_Junction_gne__c heldJunc = (AGS_ST_Held_And_Dispute_Junction_gne__c) heldJuncRec;
            if(heldTransactionMap.containsKey(heldJunc.AGS_ST_Held_Transaction_gne__r.Name)) {
                heldTransactionMap.get(heldJunc.AGS_ST_Held_Transaction_gne__r.Name).add(heldJunc);
            } else {
                List<AGS_ST_Held_And_Dispute_Junction_gne__c> heldList = new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
                heldList.add(heldJunc);
                heldTransactionMap.put(heldJunc.AGS_ST_Held_Transaction_gne__r.Name, heldList);
            }
        }
    }
    */

    /** @date 10/14/2012
    * @Author Pawel Sprysak
    * @description Method for updating data and sending email
    * @param Database.BatchableContext context
    */
    /* HD Decommissioning
    global void finish(Database.BatchableContext context) {
        //Creating and sending email with notification
        if(heldTransactionMap.keySet().size() > 0) {
            AGS_ST_Settings_gne__c setting = AGS_ST_Utils.getCustomSettings();
            String messageToSend = 'Additional records have been received and are being held for following Disputes. Please review these items and determine whether to "Hold them" or "Release them".<br/>';
            String posMessageToSend = '';
            String negMessageToSend = '';
            for(String key : heldTransactionMap.keySet()) {
                String message = '';
                message += '<br/><b>Held Transaction:</b> <a href="' + setting.Domain_gne__c + '/' + heldTransactionMap.get(key).get(0).AGS_ST_Held_Transaction_gne__r.Id + '"><b>' + key + '</b><a><br/>';
                for(AGS_ST_Held_And_Dispute_Junction_gne__c held : heldTransactionMap.get(key)) {
                    message += 'Dispute Detail: <a href="' + setting.Domain_gne__c + '/' + held.AGS_ST_Dispute_Management_gne__r.Id + '">' + held.AGS_ST_Dispute_Management_gne__r.Name + '<a><br/>';
                }
                if(heldTransactionMap.get(key).get(0).AGS_ST_Held_Transaction_gne__r.Source_Transaction_Amount_gne__c != null && Integer.valueOf(heldTransactionMap.get(key).get(0).AGS_ST_Held_Transaction_gne__r.Source_Transaction_Amount_gne__c) < 0) {
                    negMessageToSend += message;
                } else {
                    posMessageToSend += message;
                }
            }
            if(posMessageToSend != '') {
                messageToSend += '<br/><b>HELD TRANSACTIONS with Positive Source Transaction Amount</b>' + posMessageToSend;
            }
            if(negMessageToSend != '') {
                messageToSend += '<br/><b>HELD TRANSACTIONS with Negative Source Transaction Amount</b>' + negMessageToSend;
            }
            String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();
        	String oweaAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
            if(!String.isBlank(oweaId) && !String.isBlank(oweaAddress)) {
                Messaging.SendEmailResult er1 = AGS_ST_MailUtil.sendEmail(oweaAddress, '', 'Held Transactions', messageToSend, oweaId);
                update junctionList;
            }
        }
    }
    */
}