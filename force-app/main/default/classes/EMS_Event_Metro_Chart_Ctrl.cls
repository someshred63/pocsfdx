public with sharing class EMS_Event_Metro_Chart_Ctrl {
    public EMS_Event__c event {
        get;
        set {
            event = value;
            fetchApprovalItems();
        }
    }
    public List<ApprovalItem> budgetApprovalItems { get; set; }
    public List<ApprovalItem> fmvApprovalItems { get; set; }
    public List<ProcessInstance> processInstanceList { get; set; }
    public Boolean isBudgetVisible { get {return !(event.Overall_Status_gne__c == 'Draft' || event.Overall_Status_gne__c == 'Cancelled' || event.Overall_Status_gne__c == 'Budget Review');} }
    public Boolean isFmvVisible { get {return !(event.Overall_Status_gne__c == 'Draft' || event.Overall_Status_gne__c == 'Cancelled' || event.Overall_Status_gne__c == 'Budget Review' || event.Overall_Status_gne__c == 'Rejected' || event.Overall_Status_gne__c == 'FMV Review');} }

    @RemoteAction
    public static Map<String, Boolean> getVisibility(Id eventId) {
        EMS_Event__c currentEvent = [SELECT Id, Event_Type_gne__c, Event_Sub_Type_gne__c from EMS_Event__c WHERE Id = :eventId];

        Set<String> programSubTypes = new Set<String>{
                'Patient Program Session',
                'Institutional Session',
                'Institutional/Clinic Session',
                'Institutional/Clinic Session - Product Training',
                'Product Promo'
        };
        Set<String> journalClubSubTypes = new Set<String> {
                'Journal Club',
                'Journal Club / Post Congress',
                'Journal Club / Post Congress / In Kind'
        };
        Boolean hasPayment = false;
        Boolean hasContract = false;

        if (currentEvent.Event_Type_gne__c == 'Donation'
            && currentEvent.Event_Sub_Type_gne__c == 'Non Profit Event Attendance'
        ) {
            hasPayment = false;
            hasContract = false;
        } else if (currentEvent.Event_Type_gne__c == 'Programs'
            && programSubTypes.contains(currentEvent.Event_Sub_Type_gne__c)
        ) {
            hasPayment = false;
            hasContract = false;
        } else if (currentEvent.Event_Type_gne__c == 'Non-promotional program'
            && currentEvent.Event_Sub_Type_gne__c == 'Non-promotional program'
        ) {
            hasPayment = false;
            hasContract = false;
        } else if (currentEvent.Event_Type_gne__c == 'Sponsorships'
            && journalClubSubTypes.contains(currentEvent.Event_Sub_Type_gne__c)
        ) {
            hasPayment = false;
            hasContract = true;
        } else {
            hasPayment = true;
            hasContract = true;
        }

        return new Map<String, Boolean>{
                'payment' => hasPayment,
                'contract' => hasContract
        };
    }
    public class ApprovalItem {

        public String comment { get; set; }
        public String actor { get; set; }
        public String originalActor { get; set; }
        public Datetime stepDate { get; set; }
        public String status { get; set; }

        public ApprovalItem(String comment, String actor, String originalActor, Datetime stepDate, String status) {
            this.comment = comment;
            this.actor = actor;
            this.originalActor = originalActor;
            this.stepDate = stepDate;
            this.status = status;
        }
    }

    public EMS_Event_Metro_Chart_Ctrl() {
        initialie();
    }

    private void initialie() {
        if (processInstanceList == null) processInstanceList = new List<ProcessInstance>();
        if (budgetApprovalItems == null) budgetApprovalItems = new List<ApprovalItem>();
        if (fmvApprovalItems == null) fmvApprovalItems = new List<ApprovalItem>();
    }

    private static Map<Id, List<ProcessInstance>> processInstanceMap = new Map<Id, List<ProcessInstance>>();
    private static Map<Id, ApprovalItem> budgetApprovalItemsMap = new Map<Id, ApprovalItem>();
    private static Map<Id, ApprovalItem> fmvApprovalItemsMap = new Map<Id, ApprovalItem>();
    private static Set<String> medOpsProcessDefinition = new Set<String>{
            'EMS_Med_Ops_Approval', 'EMS_Grants_Donations_Corporate_Planned', 'EMS_Consulting_Meetings'
    };

    private void fetchApprovalItems() {
        initialie();

        // budget approval
        Set<Id> targetObjectIds = new Set<Id>{
                event.Id
        };
        Map<Id, EMS_Budget_Allocation_gne__c> allocationsMap = new Map<Id, EMS_Budget_Allocation_gne__c>([
                SELECT Id
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Event_gne__c = :event.Id
        ]);
        targetObjectIds.addAll(allocationsMap.keySet());

        if (!processInstanceMap.keySet().containsAll(targetObjectIds)) {
            for (Id targetId : targetObjectIds) {
                processInstanceMap.put(targetId, new List<ProcessInstance>());
            }

            for (ProcessInstance pi : [
                    SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, ProcessDefinition.Name, (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate ASC)
                    FROM ProcessInstance
                    WHERE TargetObject.Id IN :targetObjectIds
                    ORDER BY CreatedDate ASC
            ]) {
                processInstanceMap.get(pi.TargetObject.Id).add(pi);
            }
        }
        processInstanceList.clear();
        budgetApprovalItemsMap.clear();
        fmvApprovalItemsMap.clear();
        for (Id targetId : targetObjectIds) {
            for (ProcessInstance pi : processInstanceMap.get(targetId)) {
                processInstanceList.add(pi);
                // Clear approval items to show only last one regardless of status
                if (fmvApprovalItemsMap.containsKey(pi.TargetObjectId)) fmvApprovalItemsMap.remove(pi.TargetObjectId);
                if (budgetApprovalItemsMap.containsKey(pi.TargetObjectId)) budgetApprovalItemsMap.remove(pi.TargetObjectId);

                for (ProcessInstanceStep piStep : pi.Steps) {
                    // Only approved/rejected
                    if (piStep != null && (piStep.StepStatus == 'Rejected' || piStep.StepStatus == 'Approved')) {
                        if (medOpsProcessDefinition.contains(pi.ProcessDefinition.Name)) { // FMV
                            fmvApprovalItemsMap.put(pi.TargetObjectId, new ApprovalItem(piStep.Comments, piStep.actor.name, piStep.originalactor.name, piStep.createdDate, piStep.StepStatus));
                        } else if (piStep.OriginalActorId.getSobjectType() == User.SObjectType) { // Budget approval (if Original Actor is type of User)
                            budgetApprovalItemsMap.put(pi.TargetObjectId, new ApprovalItem(piStep.Comments, piStep.actor.name, piStep.originalactor.name, piStep.createdDate, piStep.StepStatus));
                        }
                    }
                }
            }
        }

        budgetApprovalItems = budgetApprovalItemsMap.values();
        fmvApprovalItems = fmvApprovalItemsMap.values();
    }
}