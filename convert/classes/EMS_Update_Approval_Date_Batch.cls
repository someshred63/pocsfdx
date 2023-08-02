global class EMS_Update_Approval_Date_Batch implements Database.Batchable<sObject> {

    String query = 'SELECT Id FROM EMS_Event__c WHERE Status_gne__c != \'Med Ops Rejected\' AND Status_gne__c != \'Rejected\' AND Status_gne__c != \'Recalled\' AND Status_gne__c != \'Unplanned\' AND Status_gne__c != \'Planned\' AND Approval_Date_gne__c = null';


    Set<String> appr1st = new Set<String>{
            'Pending Committee Review',
            'Pending Approval',
            'Pending Medical Manager Review',
            'Pending MAC Committee Review',
            'Pending Manager Review',
            'Pending Director / Manager Review',
            'Pending Budget Approval'
    };

    Set<String> medopsAppr = new Set<String>{
            'Pending Med Ops Review'
    };

    global EMS_Update_Approval_Date_Batch() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    private void calculateApprovalDate(Map<String, DateTime> event_approvaldate, List<ProcessInstance> piList, String prefix, Map<Id, Id> baToEventMap) {
        for (ProcessInstance pi : piList) {
            system.debug('baToEventMap ' + baToEventMap);
            String targetObject = (baToEventMap == null) ? pi.TargetObjectId : baToEventMap.get(pi.TargetObjectId);
            system.debug('targetObject ' + targetObject);
            if (!event_approvaldate.containsKey(targetObject) && pi.Status != 'Removed') {
                Boolean skipPIS = false;
                System.debug('\n');

                // Pending Items (IF there is one peding item we do not check Steps)
                if (pi.Workitems != null && pi.Workitems.size() != 0) {
                    DateTime datetime_previous = null;

                    for (ProcessInstanceWorkitem piw : pi.Workitems) {
                        if (String.valueOf(piw.OriginalActor.Id).startsWith(prefix)) {
                            datetime_previous = piw.CreatedDate;
                        }
                    }

                    if (datetime_previous != null) {
                        event_approvaldate.put(targetObject, datetime_previous);
                        skipPIS = true;
                    }
                }

                // Finished Items
                if (pi.Steps != null && pi.Steps.size() != 0 && skipPIS == false) {
                    String status_previous = '';
                    DateTime datetime_previous = null;
                    Boolean doPut = false;

                    for (ProcessInstanceStep pis : pi.Steps) {
                        System.debug('before datetime_previous ' + datetime_previous);
                        System.debug('before status_previous ' + status_previous);

                        if (pis.StepStatus == 'Approved' && status_previous == 'Started' && String.valueOf(pis.OriginalActor.Id).startsWith(prefix)) {
                            doPut = true;
                            break;
                        }

                        if (pi.Steps.size() == 1 && pis.StepStatus == 'Started' && status_previous == null && String.valueOf(pis.OriginalActor.Id).startsWith(prefix)) {
                            doPut = true;
                        }

                        status_previous = pis.StepStatus;
                        datetime_previous = pis.CreatedDate;
                        System.debug('after datetime_previous ' + datetime_previous);
                        System.debug('after status_previous ' + status_previous);
                    }
                    System.debug('doPut ' + doPut);
                    if (doPut) {
                        event_approvaldate.put(targetObject, datetime_previous);
                    }
                }
            }
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EMS_Event__c> events = (List<EMS_Event__c>) scope;
        System.debug('## events size: ' + events.size());

        List<EMS_Event__History> history = [
                SELECT CreatedDate, Field, NewValue, OldValue, ParentId
                FROM EMS_Event__History
                WHERE ParentId IN :events
                AND Field = 'Status_gne__c'
                ORDER BY CreatedDate DESC, ID DESC
        ];

        // check event history for event owner approval entries
        Map<String, DateTime> event_approvaldate = new Map<String, DateTime>();
        for (EMS_Event__History h : history) {
            Id pId = (Id) h.ParentId;

            if (appr1st.contains(String.valueOf(h.newValue))) {
                if (event_approvaldate.containsKey(pId)) {
                    DateTime tempDT = event_approvaldate.get(pId);
                    if (tempDT < h.CreatedDate) {
                        event_approvaldate.put(pId, h.CreatedDate);
                    }
                } else {
                    event_approvaldate.put(pId, h.CreatedDate);
                }
            }
        }
        System.debug('based on history of event ' + event_approvaldate);
        // check event history for med ops approval entries
        for (EMS_Event__History h : history) { // events that go to med ops approval directly
            Id pId = (Id) h.ParentId;
            if (!event_approvaldate.containsKey(pId)) { // check only for items that didn't have any 1st line approval histories
                if (medopsAppr.contains(String.valueOf(h.newValue)) && (String.valueOf(h.OldValue) == 'Unplanned' || String.valueOf(h.OldValue) == 'Planned')) { // they went straight to Med Ops
                    if (event_approvaldate.containsKey(pId)) {
                        DateTime tempDT = event_approvaldate.get(pId);
                        if (tempDT < h.CreatedDate) {
                            event_approvaldate.put(pId, h.CreatedDate);
                        }
                    } else {
                        event_approvaldate.put(pId, h.CreatedDate);
                    }
                }
            }
        }
        System.debug('based on history of event 2 ' + event_approvaldate);

        List<ProcessInstance> piList = [
                SELECT Id, TargetObjectId, Status, CreatedDate, (SELECT Id, CreatedDate, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate ASC, Id ASC), (SELECT Id, CreatedDate, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate ASC, Id ASC)
                FROM ProcessInstance
                WHERE TargetObjectId IN :events
                ORDER BY CreatedDate DESC, Id DESC
        ];
        //System.debug('### piList.size(): ' + piList.size());

        calculateApprovalDate(event_approvaldate, piList, User.SobjectType.getDescribe().getKeyPrefix(), null);

        System.debug('based on approval history of event ' + event_approvaldate);

        // check budget allocation approval history
        Set<Id> budgetAllocationIds = new Set<Id>();
        Map<Id, Id> baToEventMap = new Map<Id, Id>();
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Id, EMS_Event_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events]) {
            budgetAllocationIds.add(ba.Id);
            baToEventMap.put(ba.Id, ba.EMS_Event_gne__c);
        }
        List<ProcessInstance> budgetAllocationApprovalHistory = [
                SELECT Id, TargetObjectId, Status, CreatedDate, (SELECT Id, CreatedDate, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate ASC, Id ASC), (SELECT Id, CreatedDate, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate ASC, Id ASC)
                FROM ProcessInstance
                WHERE TargetObjectId IN :budgetAllocationIds
                ORDER BY CreatedDate DESC, Id DESC
        ];
        //System.debug('### budgetAllocationApprovalHistory.size(): ' + budgetAllocationApprovalHistory.size());
        calculateApprovalDate(event_approvaldate, budgetAllocationApprovalHistory, User.SobjectType.getDescribe().getKeyPrefix(), baToEventMap);

        System.debug('based on approval history of bas ' + event_approvaldate);

        // check approval history for med ops approvals
        calculateApprovalDate(event_approvaldate, piList, Group.SobjectType.getDescribe().getKeyPrefix(), null);
        System.debug('based on approval history of event (med ops approval)' + event_approvaldate);

        // this loop is used to check if the data is correct
        for (Id evId: event_approvaldate.keyset()) {
            System.debug('### evId: ' + evId + '   ' + event_approvaldate.get(evId).format('M/d/yyyy hh:mm a', UserInfo.getTimeZone().getID()));
        }

        List<EMS_Event__c> eventsToUpdate = [SELECT Approval_Date_gne__c FROM EMS_Event__c WHERE Id IN:event_approvaldate.keySet()];
        for (EMS_Event__c ev : eventsToUpdate) {
            ev.Approval_Date_gne__c = Date.parse(event_approvaldate.get(ev.Id).format('M/d/yyyy'));
        }
        System.debug('## eventsToUpdate: ' + eventsToUpdate);

        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;

        Database.SaveResult[] results = Database.update(eventsToUpdate, true);
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

		AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id =:BC.getJobId()];
		
		List<String> mails = EMS_Util.getApplicationAdminsEmails();
			
    	EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', a.Id, mails);
    	
    	EMS_Email.Send();

    }
}