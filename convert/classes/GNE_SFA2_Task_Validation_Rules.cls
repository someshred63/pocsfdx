public with sharing class GNE_SFA2_Task_Validation_Rules {
   public static void OnBeforeUpdate(Map<Id,Task> oldMap,Map<Id,Task> newMap){
        List<Task> newTasks= new List<Task>();
        if(newMap.size() > 0){
            newTasks.addAll(newMap.values());
        }
        List<Task> oldTasks= new List<Task>();
        if(newMap.size() > 0){
            oldTasks.addAll(oldMap.values());
        }
        taskTriggerBeforeUpdateOrInsert(newTasks);
        creatorCommentsValidation(oldTasks,newTasks);
        checkRelatedToValidation(oldTasks,newTasks);
        checkWhatIdValidation(newTasks);
        escalatedCallValidation(newTasks);
        activityLockFieldsValidation(oldTasks,newTasks);
    
   }

   public static void OnBeforeInsert(List<Task> newTasks){
        taskTriggerBeforeUpdateOrInsert(newTasks);
        checkWhatIdValidation(newTasks);
        escalatedCallValidation(newTasks);
   }
      
   public static void OnBeforeDelete(Map<Id,Task> oldMap){
        List<Task> tasks= new List<Task>();
        if(oldMap.size() > 0) {
            tasks.addAll(oldMap.values());
        }
       taskTriggerBeforeDelete(tasks);
    }
   
    private static void taskTriggerBeforeDelete(List<Task> tasks)
    {
        try{
            List <String> parentCall = new List<String> ();
            Schema.DescribeSObjectResult descCall = Call2_vod__c.sObjectType.getDescribe();
            for (Integer i = 0; i < tasks.size(); i++ ) {
                String whatId = tasks.get(i).WhatId;
                if ((whatId != null) && descCall.getKeyPrefix().equals(whatId.substring(0,3)))
                    parentCall.add(whatId );          
            }
            if (parentCall.size() > 0) {
                Map <Id, Call2_vod__c> calls = GNE_SFA2_TaskTrigger_Util.getCallMap(parentCall);
                for (Integer k = 0; k < tasks.size(); k++) {
                    if (GNE_SFA2_TaskTrigger_Util.isLocked (tasks.get(k).WhatId, calls)) {                
                        tasks.get(k).WhatId.addError(System.Label.GNE_SFA2_Submitted_Call_Delete_Error);
                    }
                }
            }
        }
        catch(Exception e)
        {       
        }
    }
    
    
    private static void taskTriggerBeforeUpdateOrInsert(List<Task> newTasks)
    {
        List <String> parentCall = new List<String> ();
    
        Schema.DescribeSObjectResult descCall = Call2_vod__c.sObjectType.getDescribe();
        for (Integer i = 0; i < newTasks.size(); i++ ) {
            String whatId = newTasks.get(i).WhatId;
            if ((whatId != null) && descCall.getKeyPrefix().equals(whatId.substring(0,3)))
                parentCall.add (whatId );          
        }
        
        if (parentCall.size() > 0) {
            Map <Id, Call2_vod__c> calls =  GNE_SFA2_TaskTrigger_Util.getCallMap(parentCall);
            for (Integer k = 0; k < newTasks.size(); k++) {
                if (newTasks.get(k).Override_Lock_vod__c ) {
                    newTasks.get(k).Override_Lock_vod__c = false;
                    continue;
                }
            if (GNE_SFA2_TaskTrigger_Util.isLocked (newTasks.get(k).WhatId, calls)) {                
                    newTasks.get(k).WhatId.addError(System.Label.GNE_SFA2_Submitted_Call_Update_error);
                }
            }
        }
    }
    
    //function to replicate the validation rule - Creator_Comments
    private static Boolean creatorCommentsValidation(List<Task> oldTasks, List<Task> newTasks){
        Boolean foundError = false;
        for(Integer i = 0; i < newTasks.Size();i++){
            Task newTask = newTasks.get(i);
            Task oldTask = oldTasks.get(i);
            if(oldTask.Creator_Comments_gne__c != newTask.Creator_Comments_gne__c){
                newTask.addError(System.Label.Creator_Comments_Validation);
                foundError = true;
                
            }
        }
        return foundError;
    }
    
	//
    private static Map<ID, RecordType> RECORD_TYPES_CACHE = new Map<ID, RecordType>();
   
    public static Map<Task,String> getRecordTypes(List<Task> tasks){
        Map<Task, String> result = new Map<Task, String>();

        Map<ID, Task> recordTypeIdMap = new Map<ID, Task>();
        for(Task t : tasks){
            recordTypeIdMap.put(t.RecordTypeId, t);
        }
         
        if(recordTypeIdMap.size() > 0)
        {
        	List<ID> recordTypesIds = new List<ID>();
        	for(ID recordTypeId : recordTypeIdMap.keySet()){
        		RecordType recordType = RECORD_TYPES_CACHE.get(recordTypeId);
        		if(recordType != null){
        		   result.put(recordTypeIdMap.get(recordType.Id), recordType.Name);
        		}else{
        		   recordTypesIds.add(recordTypeId);
        		}
        	}
			if(recordTypesIds.size() > 0){
	            List<RecordType> recordTypes = [select Id, Name from RecordType where Id in :recordTypesIds];
	            if(recordTypes != null){
    	            for(RecordType r : recordTypes){
        	        	RECORD_TYPES_CACHE.put(r.Id, r);
            	        result.put(recordTypeIdMap.get(r.Id), r.Name);    
	                }
    	        }
            }
        } 
        return result;
    }
    
    //function to replicate the validation rule - GNE_CM_Activity_Lock_Fields
    private static Boolean activityLockFieldsValidation(List<task> oldTasks,List<Task> newTasks){
        Boolean foundError = false;
        Map<Task,String> recordTypes = getRecordTypes(newTasks);                
        for(Integer i = 0; i < newTasks.Size();i++){
            Task newTask = newTasks.get(i);
            Task oldTask = oldTasks.get(i);
            if(( ( oldTask.Subject != null && ((oldTask.Subject) != (newTask.Subject)) ) ||
                ( (oldTask.Activity_Type_gne__c != null) && ( oldTask.Activity_Type_gne__c != newTask.Activity_Type_gne__c))  ||
            ( (oldTask.Process_Category_gne__c != null) &&  (oldTask.Process_Category_gne__c != newTask.Process_Category_gne__c)) ) && 
            recordTypes.get(newTask) == 'CM Task' ){
                newTask.addError(System.Label.Activity_Lock_Fields_Validation);
                foundError = true;
            }
        }
        return foundError;
    }
    
    //function to replicate the validation rule - GNE_CM_Check_RelatedTo
    private static Boolean checkRelatedToValidation(List<Task> oldTasks,List<Task> newTasks){
        Boolean foundError = false;
        Map<Task,String> recordTypes = getRecordTypes(newTasks);
        for(Integer i = 0; i < newTasks.Size();i++){
            Task newTask = newTasks.get(i);
            Task oldTask = oldTasks.get(i);
            if(recordTypes.get(newTask) == 'CM Task' &&
                ( newTask.WhatId != oldTask.WhatId)){
                newTask.addError(System.Label.Check_RelatedTo);
                foundError = true;
            }
        }
        return foundError;
    }
    
    //function to replicate the validation rule - GNE_CM_CheckWhatID
    private static Boolean checkWhatIdValidation(List<Task> newTasks){
        Boolean foundError = false;
        Map<Task,String> recordTypes = getRecordTypes(newTasks);
        for(Integer i = 0; i < newTasks.Size();i++){
            Task newTask = newTasks.get(i);
            if(recordTypes.get(newTask)=='CM Task' && newTask.WhatId == null){
               newTask.addError(System.Label.Check_What_Id);
               foundError = true;
            }
        }
        return foundError;
    }
    
    //function to replicate the validation rule - GNE_CM_Escalated_Call
    private static Boolean escalatedCallValidation(List<Task> newTasks){
        Boolean foundError = false;
        Set<String> profiles = new Set<String>();
        profiles.add('GNE-CM-CRSUPERVISOR');
        profiles.add('GNE-CM-CRMANAGER');
        profiles.add('GNE-CM-DIR');
        profiles.add('GNE-CM-GATCFMANAGER');
        profiles.add('GNE-CM-GATCFSUPERVISOR');
        profiles.add('GNE-CM-INTAKESUPERVISOR');
        profiles.add('System Administrator');
        Boolean allowedProfile = false;
        String profile = GNE_SFA2_Util.getCurrentUserProfileName();
        Map<Task,String> recordTypes = getRecordTypes(newTasks);
        if(profile != null){
            for(String p: profiles){
                if(profile.indexOf(p) == 0){
                    allowedProfile = true;
                    break;
                }
            }
        }
        for(Integer i = 0; i < newTasks.Size();i++){
            Task newTask = newTasks.get(i);               
            if((newTask.Activity_Type_gne__c == 'Escalated Management Call') && (recordTypes.get(newTask) == 'CM Task') && !allowedProfile){
                newTask.addError(System.Label.escalatedCall_Validation);
                foundError = true;
            }
        }
        return foundError;
    }
    
}