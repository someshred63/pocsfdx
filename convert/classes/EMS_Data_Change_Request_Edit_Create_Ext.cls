public with sharing class EMS_Data_Change_Request_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public EMS_Data_Change_Request_gne__c changeRequest {get; set;}

    public EMS_Data_Change_Request_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Data_Change_Request_Layout');
        additionalQueryFields.addAll(new List<String> {
                'Assigned_BPS_gne__c '
        });
    }

    public PageReference submit() {
        changeRequest = (EMS_Data_Change_Request_gne__c) myObject;
        changeRequest.Status_gne__c = 'Submitted';
        if(!renderAssignedBPS) {
            changeRequest.Assigned_BPS_gne__c = null;
        }
        PageReference result = save();
        result.getParameters().put('msg', 'Data Change Request was submitted successfully');
        return result;
    }

    public Boolean renderRecordType { get {
        return availabilityMode == 'New' && hasMultipleRecordTypes == true;
    } }

    public boolean getisNew() {
        changeRequest = (EMS_Data_Change_Request_gne__c) myObject;
        return changeRequest.Status_gne__c == 'New' ;
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getId() == null) {
            changeRequest = new EMS_Data_Change_Request_gne__c();
            changeRequest.Status_gne__c = 'New';

            myObject = changeRequest;
        }
        super.initController(controller);
    }

    public Boolean renderAssignedBPS { get {
        return recordTypeName == 'Event_Data_Change_Request';
    } }

    public List<SelectOption> getActiveBPSMembers() {
        List<SelectOption> result = new List<SelectOption>();

        for(User bps : EMS_Util.emsUserRoleMap.get('AARC')) {
            result.add(new SelectOption(bps.Id, bps.Name));
        }

        return result;
    }
}