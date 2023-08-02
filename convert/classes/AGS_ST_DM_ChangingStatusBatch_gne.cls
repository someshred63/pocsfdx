global class AGS_ST_DM_ChangingStatusBatch_gne implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT  Id, Internal_Status_gne__c,
                    AGS_Spend_Expense_Transaction_gne__r.Id,
                    AGS_Spend_Expense_Transaction_gne__r.DisputesListToUpdate_gne__c
            FROM    AGS_ST_DisputeManagement_gne__c
            WHERE   Internal_Status_gne__c IN ('Corrected Pending SSR', 'Resolved No Correction', 'Resolved With Correction')
            AND     AGS_Spend_Expense_Transaction_gne__r.DisputesListToUpdate_gne__c != null
        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<AGS_Spend_Expense_Transaction_gne__c> spends = new List<AGS_Spend_Expense_Transaction_gne__c>();
        Map<Id, List<AGS_ST_DisputeManagement_gne__c>> spendIdToDipsutesListMap = new Map<Id, List<AGS_ST_DisputeManagement_gne__c>>();
        for(AGS_ST_DisputeManagement_gne__c d : (List<AGS_ST_DisputeManagement_gne__c>)scope) {
            String spendId = d.AGS_Spend_Expense_Transaction_gne__r.Id;
            if( !spendIdToDipsutesListMap.containsKey(spendId) ) {
                spendIdToDipsutesListMap.put( spendId, new List<AGS_ST_DisputeManagement_gne__c>() );
                spends.add(d.AGS_Spend_Expense_Transaction_gne__r);
            }
            spendIdToDipsutesListMap.get(spendId).add(d);
        }

        List<AGS_Spend_Expense_Transaction_gne__c> spendsToUpdate = new List<AGS_Spend_Expense_Transaction_gne__c>();
        List<AGS_ST_DisputeManagement_gne__c> disputesToUpdate = new List<AGS_ST_DisputeManagement_gne__c>();
        for(AGS_Spend_Expense_Transaction_gne__c s : spends) {
            Set<Id> disputeIds = new Set<Id>();
            for(String dId : s.DisputesListToUpdate_gne__c.split(',')) {
                try {
                    disputeIds.add( dId.trim() );
                } catch(Exception e) { }
            }
            Integer initDisputeIdsLength = disputeIds.size();
            for( AGS_ST_DisputeManagement_gne__c d : spendIdToDipsutesListMap.get(s.Id) ) {
                if( disputeIds.contains(d.Id) ) {
                    disputeIds.remove(d.Id);
                    if(d.Internal_Status_gne__c == 'Corrected Pending SSR') {
                        disputesToUpdate.add(
                            new AGS_ST_DisputeManagement_gne__c(
                                Id = d.Id,
                                Internal_Status_gne__c = 'Resolved With Correction'
                            )
                        );
                    }
                }
            }
            if(initDisputeIdsLength != disputeIds.size()) {
                String newDisputeIdList = '';
                for(String dId : disputeIds) {
                    newDisputeIdList += dId + ',';
                }
                s.DisputesListToUpdate_gne__c = String.isBlank(newDisputeIdList) ? null : newDisputeIdList.substring(0, newDisputeIdList.length() - 1);
                spendsToUpdate.add(s);
            }
        }
        update spendsToUpdate;
        update disputesToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
        // Will run 5 minutes after Changing Status batch
        DateTime presentDate = System.now();
        Integer invokeMin = presentDate.minute() + 5;
        Integer invokeHour;
        if(invokeMin >= 60) {
            invokeHour = presentDate.hour() + 1;
            invokeMin = invokeMin - 60;
        } else {
            invokeHour = presentDate.hour();
        }
        Integer presentDay      = presentDate.day();
        Integer presentMonth    = presentDate.month();
        Integer presentYear     = presentDate.year();

        String scheduleTime = '0 ' + String.valueof(invokeMin) + ' ' + String.valueof(invokeHour) + ' ' +
            String.valueof(presentDay) + ' ' + String.valueof(presentMonth) + ' ? ' + String.valueof(presentYear);
        AGS_ST_DM_StatusNotificationSchedule_gne schedulerObj = new AGS_ST_DM_StatusNotificationSchedule_gne();
        System.schedule('AGS ST Status Notification Scheduler: ' + scheduleTime, scheduleTime, schedulerObj);
    }
}