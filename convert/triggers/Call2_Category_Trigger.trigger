/************************************************************
*  @author: Tomasz Kosecki
*  Date: 2018-03-06
*  Description: This is a trigger for handling Call2_Category_vod__c validations, field updates and child record updates
*    
*  Modification History
*  Date        Name                 Description
*************************************************************/
trigger Call2_Category_Trigger on Call2_Category_vod__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if (!GNE_SFA2_Util.isAdminMode()) {    	
        if(Trigger.isBefore && Trigger.isDelete){        	
        	GNE_SFA2_Deleted_Records_Util.onBeforeDelete(Trigger.old, Call2_Category_vod__c.getSObjectType());        	           	
        } else if(Trigger.isAfter && Trigger.isDelete){
        	GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, Call2_Category_vod__c.getSObjectType());            
        }        
    }
}