public with sharing class GNE_SFA2_Account_Goal_Edit_Create_Ext  extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Account_Goal_Edit_Create_Ext  (ApexPages.StandardController controller){
         super(controller,'/apex/GNE_SFA2_Account_Goal_Layout');
        
        if(myObject == null){
                myObject = new Account_Goal_and_Objective_gne__c();
        }
        if(myObject.id == null){
            Schema.DescribeSObjectResult R = Account_Plan_vod__c.SObjectType.getDescribe();
            String prfx = R.getkeyPrefix();
            String accountPlanId = ApexPages.currentPage().getParameters().get('objectId');
            if(accountPlanId != null && accountPlanId.substring(0,3).equalsIgnoreCase(prfx)) myObject.put('Account_Plan_gne__c', accountPlanId);
            myObject.put('OwnerId', UserInfo.getUserId());
        }
                

    }
}