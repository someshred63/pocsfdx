public with sharing class GNE_SFA2_PROSPECT_Sponsor_EditCreate_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 

    public GNE_SFA2_PROSPECT_Sponsor_EditCreate_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PROSPECT_Sponsor_Layout');

        if(myObject == null){
            myObject = new CONGA_Sponsor_gne__c();
        }
        if(availabilityMode == 'New'){
            myObject.put('OwnerId', UserInfo.getUserId());
        }
    }
}