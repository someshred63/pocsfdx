trigger GNE_SFA2_CallThreat_Trigger on Call2_Threat_vod__c (before delete, after delete) {
    if (!GNE_SFA2_Util.isAdminMode() ) {    	
        if(Trigger.isBefore && Trigger.isDelete){        	
        	GNE_SFA2_Deleted_Records_Util.onBeforeDelete(Trigger.old, Call2_Threat_vod__c.getSObjectType());       	          	       	   
        } else if(Trigger.isAfter && Trigger.isDelete){
        	GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, Call2_Threat_vod__c.getSObjectType());            
        }
    }
}