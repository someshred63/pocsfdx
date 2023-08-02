public without sharing class gFRS_Annual_EvaluationTriggerUtil {
     
    public static boolean isFinalOrgAnnualEvaluationOverdue(String userOrganizationId){
        Integer total = [SELECT count() FROM gFRS_Tasks__c WHERE Action_Type__c='Annual Evaluation' AND Status__c='Not Submitted' AND gFRS_Funding_Request__c IN (SELECT Id FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c='Fellowships' AND Organization__c=:userOrganizationId AND Foundation_Classified__c='TRUE' AND Program_End_Date_max__c<LAST_N_DAYS:90)];
        return (total>0);
    
     }
     
    public static Date getAnnualEvaluationDate(Id taskId){
        gFRS_Tasks__c task = [SELECT gFRS_Funding_Request__r.Program_End_Date_max__c, Years_Before_Annual_Evaluation__c FROM gFRS_Tasks__c WHERE Id=:taskId AND Action_Type__c='Annual Evaluation'];
        return task.gFRS_Funding_Request__r.Program_End_Date_max__c.addYears((Integer)task.Years_Before_Annual_Evaluation__c);
    
    }
    
    public static boolean isAllAnnualEvaluationsSubmitted(Id requestId){  	  	
		Date requestProgramMaxDate = [select Program_End_Date_max__c from GFRS_Funding_Request__c WHERE Id=:requestId].Program_End_Date_max__c;		
        return (requestProgramMaxDate<system.today() && [SELECT Id from gFRS_Tasks__c WHERE Action_Type__c='Annual Evaluation' AND gFRS_Funding_Request__c=:requestId AND Status__c='Not Submitted' LIMIT 1].size()==0);
    }
    
    public static void completeAnnualEvalutionTasksAndCloseRequest(Id requestId){
        List<gFRS_Tasks__c> tasks = [SELECT Id, Status__c from gFRS_Tasks__c WHERE Action_Type__c='Annual Evaluation' AND gFRS_Funding_Request__c=:requestId AND Status__c!='Completed' ORDER BY Years_Before_Annual_Evaluation__c ASC LIMIT 1];
        for(gFRS_Tasks__c task:tasks){
            task.Status__c = 'Completed';
        }
        update tasks;
        
        gFRS_Funding_Request__c request = [SELECT Id, Status__c, Sub_Status__c, Program_End_Date_max__c FROM gFRS_Funding_Request__c WHERE Id=:requestId AND Sub_Status__c!='Closed'];
     	if(request!=null && request.Program_End_Date_max__c <= system.today()){

            request.Status__c     =  'Closed';
            request.Sub_Status__c =  'Approved';
            
        	update request;
     	}
    }
    public static void updateRequestSubStatusToEvalutaion(Id requestId){
    	gFRS_Funding_Request__c request = [SELECT Id, Status__c, Sub_Status__c,  Foundation_Classified__c, Record_Type_Name__c FROM gFRS_Funding_Request__c WHERE Id=:requestId AND Sub_Status__c!='Closed'];
     	if(request!=null) {
	     	if(request.Foundation_Classified__c=='TRUE' && request.Record_Type_Name__c=='Fellowships'){ //completly different status changes just for Fellowships Foundation requests
	     		request.Sub_Status__c          = 'Approved';       	
	            request.External_Sub_status__c = 'Approved';
	        	update request;
	     	} else {
	            request.Sub_Status__c          = 'Approved-Program Evaluations';       	
	            request.External_Sub_status__c = 'Approved-Program Evaluations';
	        	update request;
	     	}
     	}
    }
	
	public static void updateRequestsSubStatusesToEvaluation(List<GFRS_Funding_Request__c> requests){
		if(requests!=null){
			for(GFRS_Funding_Request__c request:requests){
                request.Sub_Status__c          = 'Approved-Program Evaluations';			
                request.External_Sub_status__c = 'Approved-Program Evaluations';
			}
			update requests;
		}
	}
}