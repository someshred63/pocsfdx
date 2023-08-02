/**
 * @author GFRS Dev Team
 * @date 12/04/2018
 * @description Controller class for Change Approver visualforce page
 */

public without sharing class GFRS_ChangeApproverController {

    public Id requestId { get {return ApexPages.currentPage().getParameters().get('id');} set; }
    public GFRS_Funding_Request__c request { get; private set; }
    public User currentApprover { get; set; }
    public Group currentApproverQueue { get; set; }
    public Id currentApproverId { get; set; }
    public String currentStepStatus { get; set; }
    public User newApprover { get; set; }
    public String currentStatus { get; set; }
    public String currentStep { get; set; }
    public Contact dummyContact { get; set; }
    public String message { get; set; }

    public Boolean isProcessRunning { get; set; }
    public Boolean hasUserAccessToChangeApprover { get; set; }
    public Boolean wasApproverSaved { get; set; }
    public Boolean isApproverUser { get; set; }

    private List<ProcessInstance> processInstances { get; set; }
    private List<ProcessInstanceNode> processInstancesNodes { get; set; }

    public GFRS_ChangeApproverController(ApexPages.StandardController standardController) {
        try {
            List<GFRS_Funding_Request__c> requests = [SELECT Id, Name, OwnerId FROM GFRS_Funding_Request__c WHERE Id = :requestId LIMIT 1];
            request = (requests.size() == 1) ? requests.get(0) : null;
            dummyContact = new Contact();
            initializeProcess();
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private List<ProcessInstanceNode> getProcessInstanceNodes(Id processInstanceId) {
        List<ProcessInstanceNode> processInstanceNodes = [SELECT Id, NodeStatus, ProcessNode.Name, ProcessInstanceId FROM ProcessInstanceNode WHERE ProcessInstanceId = :processInstanceId];
        return processInstanceNodes.size() > 0 ? processInstanceNodes : new List<ProcessInstanceNode>();
    }

    private void getAndSetCurrentApprover(ProcessInstance processInstance) {
        if (processInstance != null) {
            if (processInstance.Workitems.size() > 0) {
                ProcessInstanceWorkitem currentItem = processInstance.Workitems[0];
                currentApproverId = currentItem.ActorId;
            }
        }
        if (isUserApprover(currentApproverId)) {
            currentApprover = gFRS_Util_NoShare.getUserById(currentApproverId);
            isApproverUser = true;
        } else {
            currentApproverQueue = getQueue(currentApproverId);
            isApproverUser = false;
        }
    }

    private Boolean isUserApprover(Id groupId) {
        return getQueue(groupId) != null ? false : true;
    }

    private Group getQueue(Id groupId) {
        List<Group> groups = [SELECT Id, Name FROM Group WHERE Id = :groupId LIMIT 1];
        return groups.size() == 1 ? groups.get(0) : null;
    }

    private String getCurrentStep(List<ProcessInstanceNode> processInstanceNodes) {
        for (ProcessInstanceNode node : processInstanceNodes) {
            if (node.NodeStatus == 'Pending') return node.ProcessNode.Name;
        }
        return '';
    }

    private String getCurrentStatus(List<ProcessInstanceNode> processInstanceNodes) {
        for (ProcessInstanceNode node : processInstanceNodes) {
            if (node.NodeStatus == 'Pending') return 'Pending';
        }
        return 'Approved';
    }

    private void initializeProcess() {
        processInstances = gFRS_Util_NoShare.getProcessInstances(requestId);
        isProcessRunning = hasUserAccessToChangeApprover = wasApproverSaved = false;
        if (processInstances.size() > 0) {
            isProcessRunning = true;
            setPropertiesFromApprovalProcess(processInstances[0]);
            hasUserAccessToChangeApprover = gFRS_Util_NoShare.checkIfUserHasCustomPermission('gFRS_Change_Approver') || gFRS_Util.isSystemAdministrator(UserInfo.getUserId()) ;
            if (!hasUserAccessToChangeApprover) {
                message = 'You don\'t have permission to change approver';
            }
            if (currentStatus.equals('Approved')) {
                hasUserAccessToChangeApprover = false;
                message = 'All approval steps are approved. No action is needed.';
            }
            if (currentApproverId != null && currentApproverId.equals(UserInfo.getUserId())) {
                hasUserAccessToChangeApprover = false;
                message = 'You are now approver. You can reassign approval process to other user.';
            }
        }
    }

    private void setPropertiesFromApprovalProcess(ProcessInstance processInstance) {
        getAndSetCurrentApprover(processInstance);
        processInstancesNodes = getProcessInstanceNodes(processInstance.Id);
        currentStatus = getCurrentStatus(processInstancesNodes);
        currentStep = getCurrentStep(processInstancesNodes);
    }

    public PageReference back() {
        PageReference pageRef = new PageReference('/' + requestId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void saveApprover() {
        assignNewApprover(dummyContact.OwnerId);
    }

    public void assignToMe() {
        assignNewApprover(UserInfo.getUserId());
    }

    private void assignNewApprover(Id newApproverId) {
        currentApprover = gFRS_Util_NoShare.getUserById(newApproverId);
        GFRS_ChangeApproverService.changeApprovalAction(requestId, currentApprover.Id);
        isApproverUser = wasApproverSaved = true;
    }
}