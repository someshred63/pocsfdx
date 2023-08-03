trigger SCM_MovePERTrigger on Case (before Update,after Insert) {
    // skip all logic during merge process or in Admin Mode
    if (GNE_SFA2_Util.isMergeMode() || GNE_SFA2_Util.isAdminMode())
    {
        return;
    }
    Case[] Cases = Trigger.new;
    for(Case cse: Cases){
    	
        if (cse.Patient_Enrollment_Request_gne__c != null || cse.Patient_Enrollment_Request_gne__c != ''){
           if (Trigger.IsUpdate){
            	Case oldCase = Trigger.oldMap.get(cse.Id);
            	if (oldCase.Patient_Enrollment_Request_gne__c != cse.Patient_Enrollment_Request_gne__c){
                	SCM_StartWorkflow.StartWorkflowMovePER(cse.id);
            	}
           }
          
        }
         if(Trigger.IsInsert && cse.Patient_Enrollment_Request_gne__c != null){
           		SCM_StartWorkflow.StartWorkflowMovePER(cse.id);
           }	
    }

}