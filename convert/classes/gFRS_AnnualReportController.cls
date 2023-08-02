/**
* @author GFRS Dev Team
* @date 25/08/2015
* @description gFRS_AnnualReportController class - controller for GFRS_AnnualReport page. Class is responsible for handling request from page and communication with webservices and database. 
*/
public without sharing class gFRS_AnnualReportController {

    public gFRS_Annual_Evaluation__c currentAnnualReport { get; set; }
    public gFRS_Tasks__c task { get; set; }
    private Id taskId;
       
    public Boolean isMeetingPresentation {get;set;}
    
    public Attachment financialReport { get; set; }
    /** final page to move to after completing the page **/
    public static final String PATH_COMPLETE = '/apex/GFRS_Home';
    
    private ApexPages.StandardController stdController;
    
    public gFRS_AnnualReportController( ApexPages.StandardController std ){ 
        if (!Test.isRunningTest()) std.addFields(new List<String> {'Upcoming_Publications__c', 'Financial_Report__c', 'Financial_Report_URL__c', 'Funding_Request__c', 'Funding_Request__r.Name', 'Funding_Request__r.Event_Program_Title__c', 'Meeting_Presentations__c', 'Rule_Trigger_Date__c', 'Were_Goals_Met__c', 'Specific_Meetings__c'});
        this.stdController = std;
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if(params !=null){
            taskId =  (Id) params.get('task');  
        }
                
        this.currentAnnualReport = (gFRS_Annual_Evaluation__c)stdController.getRecord();                    
        if(this.currentAnnualReport.Id == null){        
            if(params !=null){
                Id requestId =  String.valueOf(params.get('requestId'));
                GFRS_Funding_Request__c request =[ SELECT Id, Name, Event_Program_Title__c from GFRS_Funding_Request__c WHERE Id=:requestId]; 
                currentAnnualReport.Funding_Request__r = request;
                currentAnnualReport.Funding_Request__c = request.Id;
                currentAnnualReport.Rule_Trigger_Date__c = gFRS_Annual_EvaluationTriggerUtil.getAnnualEvaluationDate(taskId);
            }
        }
        isMeetingPresentation = 'Yes'.equals(currentAnnualReport.Meeting_Presentations__c);
        List<Attachment> listOfAttachments = [SELECT Id, ParentID, Name FROM Attachment WHERE Id = :this.currentAnnualReport.Financial_Report__c];
        
        GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( listOfAttachments );
        this.financialReport = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.currentAnnualReport.Financial_Report__c, this.currentAnnualReport.Id );
    }
    
    /**
    * @author ADMD Team
    * @date 25/08/2015
    * @description uploadFinancialReport method - upload Financial Report attachment
    */
    public void uploadFinancialReport(){
        
        try{
            if (currentAnnualReport.Id==null){
                insert currentAnnualReport;
            }
            financialReport.ParentId = currentAnnualReport.Id;
            
            financialReport.Description = 'Financial Report';
            upsert financialReport;
            financialReport.body = null;
              
            gFRS_Annual_Evaluation__c partialAnnualReport = [ SELECT Id FROM gFRS_Annual_Evaluation__c WHERE Id = :currentAnnualReport.Id ];
            partialAnnualReport.Financial_Report__c = financialReport.Id;
            update partialAnnualReport;
            
        } catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        } finally {
        	if (financialReport!=null && financialReport.body!=null) financialReport.body = null;
        }
    }
    
    public void specificMeetingChanged(){
        isMeetingPresentation = 'Yes'.equals(currentAnnualReport.Meeting_Presentations__c); 
    }
    
    public PageReference doSave(){  
        if(validate()){
            currentAnnualReport.Rule_Trigger_Date__c = gFRS_Annual_EvaluationTriggerUtil.getAnnualEvaluationDate(taskId);
            upsert currentAnnualReport;
            submitTask();
            updateAllTasksAndRequest();    
            return new ApexPages.Pagereference(PATH_COMPLETE);
        }
        else{
            return null;
        }
    }
    private boolean validate(){    
        Boolean result = true;  
                    
        if(String.isEmpty(currentAnnualReport.Were_Goals_Met__c)){          
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Were Goals Met?: You must enter a value'));
            result =false;
        }           
        
        if(String.isEmpty(currentAnnualReport.Upcoming_Publications__c)){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Upcoming Publications: You must enter a value'));
            result =false;              
        }
        
        if(String.isEmpty(currentAnnualReport.Meeting_Presentations__c)){  
           ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Meeting Presentations: You must enter a value'));
           result =false;
        }else if('Yes'.equals(currentAnnualReport.Meeting_Presentations__c) && String.isEmpty(currentAnnualReport.Specific_Meetings__c)){
              ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Specific Meetings: You must enter a value'));
              result =false;
        }
            
        if(currentAnnualReport==null || currentAnnualReport.Id==null){  
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Financial Report: You must enter a value'));
            result = false;
         }
         
        return result;
    }
    
    private void submitTask(){
        task = [SELECT Id, Status__c, Annual_Evaluation__c from gFRS_Tasks__c WHERE Id = :taskId AND Action_Type__c='Annual Evaluation'];
        task.Status__c= gFRS_Util.TASK_SUBMITTED;
        task.Annual_Evaluation__c = currentAnnualReport.Id;
        upsert task;    
    }
    
    private void updateAllTasksAndRequest(){
        boolean allSubmitted = gFRS_Annual_EvaluationTriggerUtil.isAllAnnualEvaluationsSubmitted(currentAnnualReport.Funding_Request__c);   
        if(allSubmitted){
            gFRS_Annual_EvaluationTriggerUtil.completeAnnualEvalutionTasksAndCloseRequest(currentAnnualReport.Funding_Request__c);
        }
        else{
            gFRS_Annual_EvaluationTriggerUtil.updateRequestSubStatusToEvalutaion(currentAnnualReport.Funding_Request__c);     
        }   
    }
}