public with sharing class GNE_SFA2_Benefit_Design_Edit_Create_Ext  extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Benefit_Design_Edit_Create_Ext(ApexPages.StandardController controller){
         super(controller,'/apex/GNE_SFA2_Benefit_Design_Layout');
        
        if(myObject == null){
                myObject = new Benefit_Design_vod__c();
        }
        
          String accountId = System.currentPageReference().getParameters().get('objectId');
          if(accountId!=null && accountId.length()>=15)
          {
            myObject.put('Account_vod__c',accountId);
          }
     
       
    }
}