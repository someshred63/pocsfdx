public class SCM_StartWorkflow{
    
   @future(callout=true)
    public static void StartWorkflowPERDelete(string DeletedPERId, string DeletedPerNumber)
    {
        SCM_Webservices_2014.SpringCMServiceSoap service = new  SCM_Webservices_2014.SpringCMServiceSoap();
       string token = SCM_Security.SCM_AuthenticateNonDefault();
      
       string xml = '<Params><DeletedId>' + DeletedPERId + '</DeletedId><PerNumber>' + DeletedPerNumber + '</PerNumber></Params>';
       
       string workflowRequestToken = service.BPMInitiateWorkflow(token, 'Delete PER', xml);
       SCM_DeletedPER__c del = [select id from SCM_DeletedPER__c d where d.DeletedPERID__c = :DeletedPERId and d.DeletedPERNumber__c = :DeletedPerNumber];
       delete del;
         
    }
    
       @future(callout=true)
    public static void StartWorkflowMovePER(string CaseId)
    {
        SCM_Webservices_2014.SpringCMServiceSoap service = new  SCM_Webservices_2014.SpringCMServiceSoap();
       string token = SCM_Security.SCM_AuthenticateNonDefault();

      Case cse = [select Patient_Enrollment_Request_gne__r.Id,Patient_Enrollment_Request_gne__r.Name,Product_gne__c,
      CaseNumber,RecordType.Name,Case_Manager__c,Foundation_Specialist_gne__c,Patient_gne__r.Patient_ID_gne__c
       from Case where Id = :CaseId];
              string AssignTo =  cse.Case_Manager__c ;
              if (cse.RecordType.Name == 'GATCF - Standard Case' || cse.RecordType.Name == 'GATCF - Eligibility Screening'){
                  AssignTo = cse.Foundation_Specialist_gne__c;
              }
       string xml = '<Params><PERId>'+ cse.Patient_Enrollment_Request_gne__r.Id +'</PERId><PERNumber>'+ cse.Patient_Enrollment_Request_gne__r.Name + '</PERNumber><CaseProduct>' + cse.Product_gne__c + '</CaseProduct><CaseId>' + CaseId + '</CaseId><CaseNumber>' + cse.CaseNumber + '</CaseNumber><AssignTaskTo>' + AssignTo + '</AssignTaskTo><PatientId>' + cse.Patient_gne__r.Patient_ID_gne__c + '</PatientId></Params>';
       
       string workflowRequestToken = service.BPMInitiateWorkflow(token, 'Move PER', xml);
       
         
    }
}