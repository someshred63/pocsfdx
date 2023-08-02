public with sharing class GNE_SFA2_PROSPECT_Location_EditCreateExt extends GNE_SFA2_Dynamic_VF_Edit_Create { 

    public GNE_SFA2_PROSPECT_Location_EditCreateExt(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PROSPECT_Location_Layout');

        if(myObject == null){
            myObject = new CONGA_Event_Location_gne__c();
        }
        if(availabilityMode == 'New'){
            myObject.put('OwnerId', UserInfo.getUserId());
        }
    }
}