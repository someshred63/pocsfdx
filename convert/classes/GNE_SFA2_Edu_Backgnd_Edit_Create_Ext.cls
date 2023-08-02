/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-16
*  Description: This is a controller extension for GNE_SFA2_Edu_Backgnd_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Edu_Backgnd_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 
    public GNE_SFA2_Edu_Backgnd_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Edu_Backgnd_Layout');
        
        if(myObject == null){
            myObject = new Educational_Background_gne__c();
        }
        String parentId = ApexPages.currentPage().getParameters().get('objectId');
        if(parentId != null && parentId != '' && myObject.id == null){
            // Commented the below 4 lines of code as per the Defect#1426 
            //Account AccRecordType = [SELECT RecordType.Name FROM Account WHERE Id= :parentId limit 1];        
            //if(AccRecordType.RecordType.Name=='Professional_vod')    
            //    myObject.put('Account_gne__c', parentId);
            //else
                myObject.put('Institution_gne__c', parentId);
        }    
    }
}