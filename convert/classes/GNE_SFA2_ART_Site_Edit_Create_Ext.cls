public with sharing class GNE_SFA2_ART_Site_Edit_Create_Ext  extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_ART_Site_Edit_Create_Ext(ApexPages.StandardController controller){
         super(controller,'/apex/GNE_SFA2_ART_Site_Layout');
        
        if(myObject == null){
                myObject = new ART_Site_gne__c();
        }
        
        //myObject.put('OwnerId',UserInfo.getUserId());
     
       
    }
}