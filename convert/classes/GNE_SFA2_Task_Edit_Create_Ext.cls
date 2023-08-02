public with sharing class GNE_SFA2_Task_Edit_Create_Ext  extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Task_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Task_Layout');
        
        if(myObject == null){
            myObject = new Task();
        }
        
        myObject.put('OwnerId',UserInfo.getUserId());
     
        if(System.currentPageReference().getParameters().get('objectId')!=null){
            String relatedTo = System.currentPageReference().getParameters().get('objectId');
            if(relatedTo.startsWith('003') || relatedTo.startsWith('00Q')) //for leads or contacts 
            {
             myObject.put('WhoId',relatedTo);
            }
            else{
                myObject.put('WhatId',relatedTo);
            }
        }
        
       // if(System.currentPageReference().getParameters().get('relatedTo')!=null){
       //   myObject.WhatId=System.currentPageReference().getParameters().get('relatedTo');
        //}
    }
}