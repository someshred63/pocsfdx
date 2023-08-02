public class MassApprovalRejectionController {

    //Method to fetch all the records which are submitted for approval
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(){
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        set<id> applicationIds = new set<id>();
        Map<id,id> workItemIds = new Map<id,id>();
        Map<Id,gFRS_Ltng_Application__c> applicationMap= new Map<Id,gFRS_Ltng_Application__c>();        
        /*List<ProcessInstance> processList=[SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,LastActorId,LastActor.Name,(SELECT Id, ActorId,ProcessInstanceId FROM Workitems WHERE OriginalActorId=:UserInfo.getUserId()),(SELECT OriginalActor.Name FROM Steps  WHERE OriginalActorId=:UserInfo.getUserId())                                       
                                            FROM ProcessInstance where TargetObject.Type='gFRS_Ltng_Application__c'  AND Status='Pending' ];*/
        List<ProcessInstanceWorkitem> workItems = [SELECT Id,CreatedDate,ProcessInstance.LastActor.Name,OriginalActorId,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Name,ProcessInstanceId FROM ProcessInstanceWorkitem 
                                                   WHERE ActorId=:UserInfo.getUserId() and ProcessInstance.Status = 'Pending' And ProcessInstance.TargetObject.Type='gFRS_Ltng_Application__c'];
        
        for(ProcessInstanceWorkitem psw1 : workItems){
            workItemIds.put(psw1.ProcessInstance.TargetObjectId,psw1.Id);
            applicationIds.add(psw1.ProcessInstance.TargetObjectId);
        }        
        for(gFRS_Ltng_Application__c app:[select id,Name,Event_Program_Title__c,Approved_Amount__c,Organization_Names__c,Record_Type__c,Program_Start_Date_Min__c from gFRS_Ltng_Application__c where id IN:applicationIds]) {
            if(app.Record_Type__c=='Community Giving' || app.Record_Type__c=='Education Focused Giving Graduate and Post-Graduate' || app.Record_Type__c=='Education Focused Giving K-12' || app.Record_Type__c=='Patient and Health Focused Giving' ||app.Record_Type__c=='Scientific and Research Focused Giving' ||app.Record_Type__c=='Foundation Undergraduate' ||app.Record_Type__c=='Foundation Safety Net Support'){
                applicationMap.put(app.Id,app);
            }
        } 
        for(ProcessInstanceWorkitem ps : workItems){ 
            List<SubmittedRecordsWrapper> lstSubmissionWrapper1 = new List<SubmittedRecordsWrapper>();            
            if(applicationMap.containsKey(ps.ProcessInstance.TargetObjectId)){                  
                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.lastActor=ps.ProcessInstance.LastActor.Name;
                objSubmittedRecordsWrapper.workItemId = ps.Id; //workItemIds.get(ps.TargetObjectId);//WorkItems[0].Id;
                objSubmittedRecordsWrapper.recordId = ps.ProcessInstance.TargetObjectId;
                objSubmittedRecordsWrapper.recordName = ps.ProcessInstance.TargetObject.Name;
                objSubmittedRecordsWrapper.eventProgramTitle = applicationMap.get(ps.ProcessInstance.TargetObjectId).Event_Program_Title__c;
                objSubmittedRecordsWrapper.orgName = applicationMap.get(ps.ProcessInstance.TargetObjectId).Organization_Names__c;
                objSubmittedRecordsWrapper.approvedAmount = applicationMap.get(ps.ProcessInstance.TargetObjectId).Approved_Amount__c;
                objSubmittedRecordsWrapper.recordType = applicationMap.get(ps.ProcessInstance.TargetObjectId).Record_Type__c;
                objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                objSubmittedRecordsWrapper.programMinDate = applicationMap.get(ps.ProcessInstance.TargetObjectId).Program_Start_Date_Min__c;
                objSubmittedRecordsWrapper.submittedBy = ps.OriginalActorId;
               /* if(!ps.steps.isEmpty()){
                    objSubmittedRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                    lstSubmissionWrapper1.add(objSubmittedRecordsWrapper);
                }*/
               
                lstSubmissionWrapper1.add(objSubmittedRecordsWrapper);                 
                lstSubmissionWrapper.addAll(lstSubmissionWrapper1); 
            }
            
        }
        return lstSubmissionWrapper;
    }
    
    public static String getObjectName(String recordId){
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0,3);
        String objectName = '';
        Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
        for(String obj : sobjectTypeMap.keySet()){
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if(sobjectResult.getKeyPrefix() == keyPrefix){
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }
    
    //Method to Approve or Reject the selected records
    @AuraEnabled
    public static String processRecords(List<String> lstWorkItemIds,String processType,String approvecomments){
        String message = '';
        Integer recordsProcessed = 0;
        System.debug('1'+lstWorkItemIds);
        System.debug('2'+processType);
        System.debug('3'+approvecomments);
      //  String comments = processType == 'Approve' ? 'Approved' : 'Rejected';
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            objWorkItemRequest.setComments(approvecomments);
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        List<String> processedApplicationId = new List<String>();
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){
                recordsProcessed++;
                if (processResult.getInstanceStatus() == 'Rejected'){
                processedApplicationId.add(processResult.getEntityId());
                }
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        
        if (!processedApplicationId.isEmpty()){
            
        	List<gFRS_Ltng_Application__c> appsToUpdateStatus = new List<gFRS_Ltng_Application__c>();

            for (gFRS_Ltng_Application__c gfapp : [Select id, Status__c, Sub_Status__c, External_Status__c  from gFRS_Ltng_Application__c
                                                   where id =: processedApplicationId ]){
                	gfapp.Status__c = 'Closed';
                	gfapp.Sub_Status__c = 'Denied';
                	gfapp.External_Status__c = 'Not Funded';
                	appsToUpdateStatus.add(gfapp);
            }
            
            update appsToUpdateStatus;
        }
        
        if(recordsProcessed == lstWorkItemIds.size()){
            if (processType == 'Approve'){
            message = lstWorkItemIds.size() + ' Record(s) were approved';
            }else{
            message = lstWorkItemIds.size() + ' Record(s) were Denied';    
            }
        }
        System.debug('-->'+message);
        return message;
    }
    
    //Wrapper class to store the column values of data table
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String eventProgramTitle;
        @AuraEnabled public String orgName;
        @AuraEnabled public Decimal approvedAmount;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public String recordType;
        @AuraEnabled public Date submittedDate;
        @AuraEnabled public Date programMinDate;
        @AuraEnabled public String lastActor;
    }
}