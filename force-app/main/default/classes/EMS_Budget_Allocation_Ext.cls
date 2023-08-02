public with sharing class EMS_Budget_Allocation_Ext extends EMS_DynamicVFLoader {

    public List<sObject> budgetAllocations { get; set; }
    private Id processInstanceWorkitemId;
    private EMS_Budget_Allocation_gne__c budgetAllocation;
    private Id submittedBy;

    public EMS_Budget_Allocation_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Allocation_Layout');
        budgetAllocations = new List<sObject>{
                myObject
        };
        budgetAllocation = (EMS_Budget_Allocation_gne__c) myObject;
        processInstanceWorkitemId = fetchApprovalProcessItems();
    }

    public PageReference edit() {
        Pagereference pageref = new PageReference('/apex/EMS_Budget_Allocation_Edit_Create_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    private Id fetchApprovalProcessItems() {
        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                where TargetObject.Id = :myObject.Id
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    submittedBy = piw.CreatedById;
                    return piw.Id;
                }
            }
        }
        return null;
    }
}