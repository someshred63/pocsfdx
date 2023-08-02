public class GNE_SFA2_Task_Trigger{
	public static void GNE_SFA2_Task_Trigger(Boolean isInsert, Boolean isDelete, Boolean isUpdate, List<Task> old,List<Task> newTrigger)
	{
		List <String> parentCall = new List<String> ();
		    
	    Task[] tRows = null;    
	    if (isDelete) 
	        tRows = old;
	    else
	        tRows = newTrigger;
	    
	    Schema.DescribeSObjectResult descCall = Call2_vod__c.sObjectType.getDescribe();
	    for (Integer i = 0; i < tRows.size (); i++ ) {
	        String whatId = tRows[i].WhatId;
	        if ((whatId != null) && descCall.getKeyPrefix().equals(whatId.substring(0,3)))
	            parentCall.add (tRows[i].WhatId);          
	    }
	    
	    if (parentCall.size() > 0) {
	        String GNE_SFA2_Submitted_Call_Delete_Error = System.Label.GNE_SFA2_Submitted_Call_Delete_Error;
	        String GNE_SFA2_Submitted_Call_Update_error = System.Label.GNE_SFA2_Submitted_Call_Update_error;
	        
	        Map <Id, Call2_vod__c> calls =  GNE_SFA2_Call2_Child_Common.getCallMap(parentCall);
	        for (Integer k = 0; k < tRows.size(); k++) {
	            if ((isInsert || isUpdate) && (tRows[k].Override_Lock_vod__c == true)) {
	                tRows[k].Override_Lock_vod__c = false;
	                continue;
	            }
	        
	            if (GNE_SFA2_Call2_Child_Common.isLocked (tRows[k].WhatId, calls)) {                
	                if (isDelete) {
	                    tRows[k].WhatId.addError(GNE_SFA2_Submitted_Call_Delete_Error);
	                }
	                else {
	                    tRows[k].WhatId.addError(GNE_SFA2_Submitted_Call_Update_error);
	                }
	            }
	        }
	    }		
	}
}