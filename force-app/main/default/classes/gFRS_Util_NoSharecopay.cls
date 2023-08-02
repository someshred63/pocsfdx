/**
 *  Utility methods that DO NOT USE SHARING RULES.
 *
 *  <p>WARNING: be careful which methods are placed here and verify that they are necessary</p>
 **/
public without sharing class gFRS_Util_NoSharecopay {

    
/**
* Author gFRS CoPay Team
* Date 12/12/2017
* Description Validation rule to prevent CST reviewer from approving without updating the details of required approvers. 
* */
    public static void copayApprovalValidations(Map<Id,gFRS_Copay_Funding_Request__c> newRequestsMap, Map<Id,gFRS_Copay_Funding_Request__c> oldRequestsMap, List<gFRS_Copay_Funding_Request__c> newRequestList){
        
        /*
        *Validation to prevent CST Reviewer from approving record without provinding required Approver Details
        */
        
        Set<Id> requestMissingApprovers = new Set<ID>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Copay_Funding_Request__c');
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
        
        for(gFRS_Copay_Funding_Request__c reqItem : newRequestsMap.values()){
            gFRS_Copay_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.id);
            
            if( reqItem.Sub_Status__c == 'CST Approval' 
               && reqItem.CST_Reviewer_Decision__c == 'Approved')
            {
                if(reqItem.Vendor_Bank_Reviewed__c == False){
                            String outputErrorMessage              = System.Label.gFRS_CoPay_Vendor_Bank_Not_Reviewed_Error;
                                outputErrorMessage                     = outputErrorMessage.replace('{!ID}',reqItem.id);
                                reqItem.addError(outputErrorMessage, false);
                }
                
                gFRS_Copay_Funding_Request__c reqWithLocationInfo = [select Locationcopay__r.Vendor_ID__c, Locationcopay__r.Partner_Bank_Type__c from gFRS_Copay_Funding_Request__c where id = : reqItem.id limit 1];
                
                if(String.isBlank(reqWithLocationInfo.Locationcopay__r.Partner_Bank_Type__c)){
                    String outputErrorMessage              = System.Label.gFRS_CoPay_Bank_info_Missing_Error;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}', reqWithLocationInfo.Locationcopay__r.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!MISSING_FIELD}','bank info');
                    reqItem.addError(outputErrorMessage, false);
                }
                
                if(String.isBlank(reqWithLocationInfo.Locationcopay__r.Vendor_ID__c)){
                  //  string vendor                          = '?retURL=%2Fapex%2FGFRS_Copay_Funding_Request_Read%3Fid%3D' + reqWithLocationInfo.id;
                    string vendor                          = '?retURL=%2F' + reqWithLocationInfo.Locationcopay__r.id;
                    String outputErrorMessage              = System.Label.gFRS_CoPay_Vendor_info_Missing_Error;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}', reqWithLocationInfo.Locationcopay__r.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!MISSING_FIELD}', vendor);
                    reqItem.addError(outputErrorMessage, false);
                }
            
                if(String.isBlank(reqItem.Payment_Automation__c)){
                    String outputErrorMessage              = System.Label.gFRS_CoPay_Missing_Field_Error;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',reqItem.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!MISSING_FIELD}',fieldMap.get('Payment_Automation__c').getDescribe().getLabel());
                    reqItem.addError(outputErrorMessage, false);
                }
                
                if(String.isBlank(reqItem.Payment_Type__c)){
                    String outputErrorMessage              = System.Label.gFRS_CoPay_Missing_Field_Error;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',reqItem.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!MISSING_FIELD}',fieldMap.get('Payment_Type__c').getDescribe().getLabel());
                    reqItem.addError(outputErrorMessage, false);  
                }

                if(reqItem.Total_Approved_Amt__c > 50000000 
                    && String.isNotBlank(reqItem.CST_Approver__c)
                    && String.isNotBlank(reqItem.Finance_Approver__c)
                    && String.isNotBlank(reqItem.VP_Approver__c)
                    && String.isBlank(reqItem.CFO_Approver__c)){
                               
                    String outputErrorMessage           = System.Label.gFRS_CoPay_Missing_Field_Error;
                    outputErrorMessage                  = outputErrorMessage.replace('{!ID}',reqItem.id);
                    outputErrorMessage                  = outputErrorMessage.replace('{!MISSING_FIELD}',fieldMap.get('CFO_Approver__c').getDescribe().getLabel());
                    reqItem.addError(outputErrorMessage, false);
                }
                
                if(String.isBlank(reqItem.VP_Approver__c) || String.isBlank(reqItem.Finance_Approver__c) || String.isBlank(reqItem.CST_Approver__c)){
                    String outputErrorMessage           = System.Label.gFRS_CoPay_Missing_Field_Error;
                    outputErrorMessage                  = outputErrorMessage.replace('{!ID}',reqItem.id);
                    outputErrorMessage                  = outputErrorMessage.replace('{!MISSING_FIELD}',fieldMap.get('CST_Approver__c').getDescribe().getLabel() + ' or ' + 
                                                             fieldMap.get('Finance_Approver__c').getDescribe().getLabel() + ' or ' + fieldMap.get('VP_Approver__c').getDescribe().getLabel());
                    reqItem.addError(outputErrorMessage, false);                
                            
                }
                if(reqItem.Payment_Type__c == 'Partial' && ((reqItem.Total_Paid_Amount__c + reqItem.Total_Payment_Amount__c) >= reqItem.Requested_Amount1__c)){
                    String outputErrorMessage              = System.Label.Full_Amount_is_Being_Processed_With_Payment_Type_value_PARTIAL;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',reqItem.id);
                    reqItem.addError(outputErrorMessage, false);     
                }               
            }
        }

        /*
        *Validation to prevent CST Reviewer from approving record without provinding Approved Amount
        */
        Map<id, List<gFRS_CoPay_Disease_State__c>> mapReqDS = new Map<id, List<gFRS_CoPay_Disease_State__c>>();
        set<id> reqIds = new set<id>();

        for(gFRS_Copay_Funding_Request__c cpr : newRequestList){
            reqIds.add(cpr.id);
        }
        
        for(gFRS_Copay_Funding_Request__c reqItem : [SELECT Id, Name, (Select Id, Name, Copay_Funding_Request__c, Approved_Amount__c, Payment_Amount__c, Internal_Disease_State_Mapping__c FROM gFRS_CoPay_Disease_State__r) FROM gFRS_Copay_Funding_Request__c WHERE ID IN : reqIds ]){
            mapReqDS.put(reqItem.id, reqItem.gFRS_CoPay_Disease_State__r);
        }
        
        for(gFRS_Copay_Funding_Request__c cpr1 : newRequestList){
	
            gFRS_Copay_Funding_Request__c oldCpr1 = oldRequestsMap.get(cpr1.Id);
            
            if((cpr1.Estimated_Current_Revenue_Percent__c > 33) &&
                (  (cpr1.Sub_Status__c == 'CST Approval' && cpr1.CST_Reviewer_Decision__c == 'Approved' && oldCpr1.Estimated_Current_Revenue_Exceeded_33__c == False && cpr1.Summary_PDF_snapshot__c == null)
                || (cpr1.Sub_Status__c == 'Finance Approval' && oldCpr1.Sub_Status__c == 'CST Approval' && cpr1.CST_Approver_Decision__c == 'Approved' && oldCpr1.Estimated_Current_Revenue_Exceeded_33__c == False)
                || (cpr1.Sub_Status__c == 'VP/CAO Approval' && oldCpr1.Sub_Status__c == 'Finance Approval' && cpr1.Finance_Approver_Decision__c == 'Approved' && oldCpr1.Estimated_Current_Revenue_Exceeded_33__c == False)
                || (cpr1.Sub_Status__c == 'CFO Approval' && oldCpr1.Sub_Status__c == 'VP/CAO Approval' && cpr1.VP_Approver_Decision__c == 'Approved' && oldCpr1.Estimated_Current_Revenue_Exceeded_33__c == False)
                || (cpr1.Sub_Status__c == 'Approved' && oldCpr1.Sub_Status__c == 'VP/CAO Approval' && cpr1.VP_Approver_Decision__c == 'Approved' && oldCpr1.Estimated_Current_Revenue_Exceeded_33__c == False)
                || (cpr1.Sub_Status__c == 'Approved' && oldCpr1.Sub_Status__c == 'CFO Approval' && cpr1.CFO_Approver_Decision__c == 'Approved' && oldCpr1.Estimated_Current_Revenue_Exceeded_33__c == False))){
                    String outputErrorMessage              = System.Label.gFRS_CoPay_33_Exceeded_Check_Box_Missing;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',cpr1.id);
                    cpr1.addError(outputErrorMessage, false);
                }
                
            if(cpr1.Sub_Status__c == 'CST Approval' && oldCpr1.Sub_Status__c == 'CST Review' && cpr1.CST_Reviewer_Decision__c == 'Approved' && cpr1.Date_for_33_logic__c == null){
                
                String outputErrorMessage           = System.Label.gFRS_CoPay_Missing_Field_Error;
                outputErrorMessage                  = outputErrorMessage.replace('{!ID}',cpr1.id);
                outputErrorMessage                  = outputErrorMessage.replace('{!MISSING_FIELD}',fieldMap.get('Date_for_33_logic__c').getDescribe().getLabel());
                cpr1.addError(outputErrorMessage, false);  

            }
            
            if(cpr1.Sub_Status__c == 'CST Approval' && cpr1.CST_Reviewer_Decision__c == 'Approved' && cpr1.Summary_PDF_snapshot__c == null){
                
                String DS_Link = '';
                for(gFRS_CoPay_Disease_State__c DS : mapReqDS.get(cpr1.id)){
                    gFRS_Copay_Funding_Request__c currentRequest1 = newRequestsMap.get(cpr1.id);
                    if(DS.Payment_Amount__c == null){
                    //  DS_link = DS_link + ' <a href="/' + DS.id + '/e">' + DS.Name + '</a>,';                 
                        DS_link = DS_link + ' <a href="/' + DS.id + '/e?retURL=%2Fapex%2FGFRS_Copay_Funding_Request_Read%3Fid%3D' + DS.Copay_Funding_Request__c + '">' + DS.Name + '</a>,'; 
                    }
                    if(String.isNotBlank(DS_link)){
                        String outputErrorMessage   = System.Label.gFRS_CoPay_Disease_State_Approved_Amount_Missing_Error;
                        outputErrorMessage  = outputErrorMessage.replace('{!Disease_State_Links}',DS_link.removeEnd(','));
                        currentRequest1.addError(outputErrorMessage, false); 
                    }
                }
                
                String DS_Link_Mapping_Missing = '';
                for(gFRS_CoPay_Disease_State__c DS : mapReqDS.get(cpr1.id)){
                    gFRS_Copay_Funding_Request__c currentRequest1 = newRequestsMap.get(cpr1.id);
                    if(DS.Internal_Disease_State_Mapping__c == null){
                 //       DS_link = DS_link + ' <a href="/' + DS.id + '/e">' + DS.Name + '</a>,';                 
                          DS_Link_Mapping_Missing = DS_Link_Mapping_Missing + ' <a href="/' + DS.id + '/e?retURL=%2Fapex%2FGFRS_Copay_Funding_Request_Read%3Fid%3D' + DS.Copay_Funding_Request__c + '">' + DS.Name + '</a>,'; 
                    }
                    if(String.isNotBlank(DS_Link_Mapping_Missing)){
                        String outputErrorMessage   = System.Label.gFRS_CoPay_Disease_State_Mapping_Missing_Error;
                        outputErrorMessage  = outputErrorMessage.replace('{!Disease_State_Links}',DS_Link_Mapping_Missing.removeEnd(','));
                        currentRequest1.addError(outputErrorMessage, false); 
                    }
                }
                
                    
                if(String.isBlank(cpr1.Recom_Desk__c)){
                    String outputErrorMessage              = System.Label.gFRS_CoPay_Final_Deck_Missing;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',cpr1.id);
                    cpr1.addError(outputErrorMessage, false);
                }
                
            }
        }
        
    }
    

/**
* @Author gFRS CoPay Team
* @date 12/07/2017
* @description stopApprovalIFBADidntAcknowledgeExceededRevenue method - hard stops BA User if approved amount has exceeded the operation budget limit in non-copay funding requests.
*/
    public static void stopApprovalIFBADidntAcknowledgeExceededRevenue(Map<Id,GFRS_Funding_Request__c> newRequestsMap, Map<Id,GFRS_Funding_Request__c> oldRequestsMap){
        Set<Id> requestMeetingCriteria=new Set<ID>();
        for(GFRS_Funding_Request__c reqItem:newRequestsMap.values()){
                GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.id);
                
                //Check for Non Foundation Funding Types
               if( reqItem.Foundation_Classified__c == 'FALSE' 
                    && oldReq.Business_Approver_Decision_Date__c != reqItem.Business_Approver_Decision_Date__c 
                    && reqItem.Business_Approver_Decision_Date__c != null   
                    && ((reqItem.Estimated_Current_Revenue_Percent__c > 33.0) && (reqItem.Acknowledge_Current_Revenue_33__c == False))
                    && reqItem.Business_Approver_Decision__c == 'Approved'){

                    requestMeetingCriteria.add(reqItem.id);
                }
                
        }
        
        try{
            if(requestMeetingCriteria.size()>0){
                for(Id fundId:requestMeetingCriteria){
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    Decimal exceedAmount = currentRequest.Allowed_Operational_Budget__c;
                    String outputErrorMessage              = System.Label.gFRS_ExceedApprovalAmountError;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',currentRequest.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!ExceededAmount}',String.valueOf(currentRequest.Allowed_Operational_Budget__c));
                    currentRequest.addError(outputErrorMessage, false);
                }               
            }   
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }    
    }
    
    
    /**
* @Author gFRS CoPay Team
* @date 12/07/2017
* @description insertComplianceAttachment method - create attachement under copay funding request with ComplianceChecksFlags
*/   
    public static void insertCopayHCComplianceAttachment(String attName, Blob attBody, gFRS_CoPay_Funding_Request__c request){
        Attachment tmpCompDock = new Attachment(Name=attName,body=attBody,parentId=request.id);
        insert tmpCompDock;
        request.HC_Compliance_Flags_PDF__c = tmpCompDock.id;
        request.HC_Compliance_Decision_Date__c = date.today();
        update request;
    }
    
    /**
* @Author gFRS CoPay Team
* @date 12/07/2017
* @description insertComplianceAttachment method - create attachement under copay funding request with ComplianceChecksFlags
*/   
    public static void insertCopayDecisionComplianceAttachment(String attName, Blob attBody, gFRS_CoPay_Funding_Request__c request){
        Attachment tmpCompDock = new Attachment(Name=attName,body=attBody,parentId=request.id);
        insert tmpCompDock;
        request.Decision_Compliance_Flags_PDF__c = tmpCompDock.id;  
        request.Decision_Date__c = date.today();
        update request;
    }
    
    /**
* @Author gFRS CoPay Team
* @date 02/13/2018
* @description insertAllocationPDFAttachment method - create attachement under copay funding request with ComplianceChecksFlags
*/   
    public static void insertAllocationPDFAttachment(String attName, Blob attBody, gFRS_Copay_Funding_Allocation__c request){
        Attachment tmpCompDock = new Attachment(Name=attName,body=attBody,parentId=request.id);
        insert tmpCompDock;
        request.Funding_Allocation_PDF__c = tmpCompDock.id;               
        update request;
    }    
    
    /**
* @Author gFRS CoPay Team
* @date 12/07/2017
* @description SummaryPDF method - create attachement under copay funding request with Request Summary Snapshot
*/   
    public static void insertSummaryPDFAttachment(String attName, Blob attBody, gFRS_CoPay_Funding_Request__c request){
        Attachment tmpCompDock = new Attachment(Name=attName,body=attBody,parentId=request.id);
        insert tmpCompDock;
        request.Summary_PDF_snapshot__c = tmpCompDock.id;               
        update request;
    }
    
        /**
* @Author gFRS CoPay Team
* @date 12/19/2017
* @description upsertRequestSharescopay method - extends access to record for the approvers
*/
     public static void saveLockedFundingRequest( gFRS_copay_Funding_Request__c request ){
        //POC of additionall field on funding request 
        request.IsValidationExternalOnly__c='Yes';
        update request;
    }
    
    /**
* @Author gFRS CoPay Team
* @date 12/07/2017
* @description upsertRequestSharescopay method - extends access to record for the approvers
*/  
    public static void upsertRequestSharescopay(gFRS_copay_Funding_Request__Share[] requestShares){    
        if(requestShares.Size()>0){ 
            Database.upsertResult[] srUpsertList = Database.upsert(requestShares,false);
            String output                        ='';       
            for(Database.upsertResult upsResult:srUpsertList){
                if (!upsResult.isSuccess()) {
                    for(Database.Error err : upsResult.getErrors()) {
                        System.debug('The following error: Exception has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Sharing affected this error: ' + err.getFields());
                        output=err.getStatusCode() + ': ' + err.getMessage();
                    }
                }
            }
            //if there was any problems with adding sharing for any user display message 
            if(output!=''){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'DML insert manual sharing problem. '+ output));
                return;
            }
        }
    }
    
    
    
    public static gFRS_Copay_Task__c[] fetchUserTaskscopay( List<gFRS_copay_Funding_Request__c> listFund,id userId ){
        return( [ SELECT Id,Action_Type__c,  User__c, User__r.Name, gFRS_copay_Funding_Request__c, 
                 GFRS_CoPay_Funding_Request__r.Name, Subject__c, Status__c, Description__c, IsDeleted, 
                 CreatedDate,GFRS_CoPay_Funding_Request__r.CreatedDate, CreatedBy.Name, LastModifiedBy.Name,
                 GFRS_CoPay_Funding_Request__r.Event_Program_Title__c,  
                 GFRS_CoPay_Funding_Request__r.Requested_Amount__c,GFRS_CoPay_Funding_Request__r.External_Sub_status__c,
                 GFRS_CoPay_Funding_Request__r.Information_Needed__c,GFRS_CoPay_Funding_Request__r.Authorized_Signer__c,RFI_Link__c,
                 GFRS_CoPay_Funding_Request__r.CreatedById, Years_Before_Annual_Evaluation__c, GFRS_CoPay_Funding_Request__r.OwnerId,
                 GFRS_CoPay_Funding_Request__r.Reconciliation_Required_Status_Date__c
                 FROM gFRS_Copay_Task__c
                 WHERE gFRS_copay_Funding_Request__c in :listFund 
                 AND ((Action_Type__c !='Status Report' 
                       AND Action_Type__c !='Outcomes' 
                       AND Action_Type__c !='Annual Evaluation' 
                       AND Status__c != :gFRS_Util.TASK_COMPLETED) 
                      OR (Action_Type__c ='Annual Evaluation' 
                          AND Status__c = :gFRS_Util.TASK_NOT_SUBMITTED))      
                 order by CreatedDate desc
                 limit 1000
                ]); //TODO revert changes
    }   
    
    public static void saveLockedFundingRequestInternalPagecopay( gFRS_copay_Funding_Request__c request ){
        update request;
    }
    
     public static void saveLockedFundingRequestcopay( gFRS_copay_Funding_Request__c request ){
        //POC of additionall field on funding request 
        request.IsValidationExternalOnly__c='Yes';
        update request;
    }
     
    public static gFRS_Copay_Task__c[] fetchUserOngoingTaskscopay( List<gFRS_copay_Funding_Request__c> listFund,id userId ){
        return( [ SELECT Id, Action_Type__c, User__c, User__r.Name, gFRS_copay_Funding_Request__c, gFRS_copay_Funding_Request__r.Name,
                 Subject__c, Status__c, Description__c, IsDeleted, CreatedDate,GFRS_copay_Funding_Request__r.CreatedDate, 
                 CreatedBy.Name, LastModifiedBy.Name, GFRS_copay_Funding_Request__r.Event_Program_Title__c,
                 GFRS_copay_Funding_Request__r.Requested_Amount__c,GFRS_copay_Funding_Request__r.External_Sub_status__c,
                 GFRS_copay_Funding_Request__r.Information_Needed__c,GFRS_copay_Funding_Request__r.Authorized_Signer__c,RFI_Link__c,
                 GFRS_copay_Funding_Request__r.CreatedById, GFRS_copay_Funding_Request__r.Reconciliation_Required_Status_Date__c
                 FROM gFRS_Copay_Task__c
                 WHERE ((Action_Type__c ='Status Report') 
                        OR Action_Type__c ='Outcomes') 
                 AND gFRS_copay_Funding_Request__c in :listFund
                 ORDER BY GFRS_copay_Funding_Request__r.Name DESC 
                 LIMIT 1000
                ]);
    }
    
    public static void createAppropriateTask( gFRS_copay_Funding_Request__c[] requests, Map<Id,gFRS_copay_Funding_Request__c> oldMap ){
       

        List<gFRS_copay_Funding_Request__c> changedRequests                  = new List<gFRS_copay_Funding_Request__c>();
        List<gFRS_copay_Funding_Request__c> changedRequestsSecond            = new List<gFRS_copay_Funding_Request__c>();
        List<gFRS_copay_Funding_Request__c> changedRequestsExternalSubStatus = new List<gFRS_copay_Funding_Request__c>();
        //List<gFRS_copay_Funding_Request__c> changedSunshineRequests          = new List<gFRS_copay_Funding_Request__c>();
        //List<gFRS_copay_Funding_Request__c> changedSunshineRequests2         = new List<gFRS_copay_Funding_Request__c>();
        Set<gFRS_copay_Funding_Request__c> requestsToMerge                   = new Set<gFRS_copay_Funding_Request__c>();
        
        Map<Id,gFRS_copay_Funding_Request__c> requestsWithTasks = new Map<Id,gFRS_copay_Funding_Request__c>();
        
        gFRS_ObjectUtil.filterChangedObjects( requests, oldMap, 'Sub_Status__c', changedRequests );
        gFRS_ObjectUtil.filterChangedObjects( requests, oldMap, 'Status__c', changedRequestsSecond );
        gFRS_ObjectUtil.filterChangedObjects( requests, oldMap, 'External_Sub_status__c', changedRequestsExternalSubStatus );
        
        
        requestsToMerge.addAll(changedRequestsSecond);
        requestsToMerge.addAll(changedRequestsExternalSubStatus);
        
        
        for(gFRS_copay_Funding_Request__c item : requestsToMerge)
        {
            Boolean isEqual = false;
            for(gFRS_copay_Funding_Request__c tmpRequest:changedRequests){
                if(tmpRequest.id == item.id){
                    isEqual=true;
                    break;
                }
            }
            if(!isEqual){
                changedRequests.add(item);
            }
        }
        
        
       
        Map<Id,gFRS_copay_Funding_Request__c> lTasks = new Map<Id,gFRS_copay_Funding_Request__c>();
        if(changedRequests.size()>0){ 
            lTasks = new Map<Id,gFRS_copay_Funding_Request__c>(
            [SELECT 
                (SELECT Subject__c,CreatedDate, gFRS_copay_Funding_Request__c, Description__c,Action_Type__c,Status__c 
                    FROM gFRS_Copay_Tasks__r WHERE Status__c!='Closed') 
                FROM gFRS_copay_Funding_Request__c WHERE Id in :changedRequests]);
        }
        
        
        
        Set<gFRS_Copay_Task__c> tasksToClose = new Set<gFRS_Copay_Task__c>();
        Set<gFRS_Copay_Task__c> tasksToAdd   = new Set<gFRS_Copay_Task__c>();
        Id currentUser                  = Userinfo.getUserId();
        for(gFRS_copay_Funding_Request__c item : changedRequests)
        {
            //Add LOA Tasks
            if(item.Sub_Status__c == 'RFI'){
                for(gFRS_Copay_Task__c taskItem: lTasks.get(item.id).gFRS_Copay_Tasks__r ){
                    if(taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'RFI'){
                        tasksToClose.add(taskItem);
                    }
                }
                
                String checkRfi = item.Information_Needed__c==null ? '': item.Information_Needed__c;
                String RfiLink  = '';
                 if(checkRfi.contains(gFRS_Utilcopay.INFO_NEEDED_ORGANIZATION)){
                    string parameters = 'org=' + item.Organization__c + '&ci=2';
                    RfiLink = gFRS_Utilcopay.initializeLinkcopay('/apex/gFRS_Org_InfoCopay', item, parameters);
                }else if(checkRfi.contains(gFRS_Utilcopay.INFO_NEEDED_LOCATION)){
                    string parameters = 'org=' + item.Organization__c + '&ci=4';
                    RfiLink = gFRS_Utilcopay.initializeLinkcopay('/apex/gFRS_Org_InfoCopay', item, parameters);
                }else if(checkRfi.contains(gFRS_Utilcopay.INFO_NEEDED_APPLICATION) || checkRfi.contains('Revenue') || checkRfi.contains('Donation') ){
                    string parameters = 'loc=' + item.Locationcopay__c + 'org=' + item.Organization__c;
                    RfiLink = gFRS_Utilcopay.initializeLinkcopay('/apex/GFRS_ApplicationCopay', item, parameters);
                }else if(checkRfi.contains(gFRS_Utilcopay.INFO_NEEDED_DISEASE_STATE)){
                    RfiLink = gFRS_Utilcopay.initializeLinkcopay('/apex/gFRS_AddDiseaseStateCopay', item, '');
                }else if(checkRfi.contains(gFRS_Utilcopay.INFO_NEEDED_FILE_ATTACHMENTS)){
                    RfiLink = gFRS_Utilcopay.initializeLinkcopay('/apex/gFRS_FileAttachmentCopay', item, '');
                }
                /*else{
                    string parameters = 'org=' + item.Organization__c;
                    RfiLink = gFRS_Utilcopay.initializeLinkcopay('/apex/gFRS_Org_InfoCopay', item, parameters);
                }*/
                tasksToAdd.add(new gFRS_Copay_Task__c( 
                                                     Status__c               = 'Open',
                                                     Subject__c              = 'RFI Required',
                                                     RFI_Link__c             = RfiLink,
                                                     Description__c          = 'Please respond to the RFI for Donation Request: '+item.Name,
                                                     gFRS_copay_Funding_Request__c = item.id,
                                                     User__c                 = currentUser,
                                                     Action_Type__c          ='RFI' 
                                                ));
            }
            if(item.Sub_Status__c !='RFI')
            { 
                for(gFRS_Copay_Task__c taskItem: lTasks.get(item.id).gFRS_Copay_Tasks__r )
                {
                    if(taskItem.Action_Type__c!=null &&   taskItem.Action_Type__c=='RFI')
                    {
                        tasksToClose.add(taskItem);
                    }
                }
            }

        }
        
        if(tasksToClose.size()>0){
            List<gFRS_Copay_Task__c> taskToCloseWithoutDuplicates=new List<gFRS_Copay_Task__c>();
            taskToCloseWithoutDuplicates.addAll(tasksToClose);
            delete  taskToCloseWithoutDuplicates;
        }
        if(tasksToAdd.size()>0){
            List<gFRS_Copay_Task__c> taskToAddWithoutDuplicates=new List<gFRS_Copay_Task__c>();
            taskToAddWithoutDuplicates.addAll(tasksToAdd);
            insert taskToAddWithoutDuplicates;
        }
        
    }

       /**
    * @author GFRS CoPay Dev Team - MG 
    * @date 20/12/2017
    * @description  autoRejectRecord method -  this method automaticly rejects request.  
    * Used in gFRS_FundingRequestReadController
    */
    public static void autoRejectRecord(gFRS_CoPay_Funding_Request__c p_req)
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(System.Label.gFRS_AutomatedRejection);
        req.setAction('Reject');

        Id workItemId = getWorkItemId(p_req.id);
 
        if(workItemId == null)
        {
            p_req.addError('Error Occured in autoRejectRecord. WorkItemId is null');
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for reject
            Approval.ProcessResult result =  Approval.process(req);
        }
    }
    
     /**
    * @author GFRS CoPay Dev Team - MG 
    * @date 20/12/2017
    * @description  getWorkItemId method -  helper method. gets WorkItemId.  
    */
    private static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
 
        for(ProcessInstanceWorkitem workItem  : [SELECT p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId =: targetObjectId])
        {

            retVal  =  workItem.Id;
        }
        return retVal;
    }  
    /**
    * @author GFRS Dev Team 
    * @date 05/09/2013
    * @description checkIsPaymentSuccesfullySubmitted method - checks whether the payment was succesfully submitted.
    */
    public static Boolean checkIsPaymentSuccesfullySubmitted(GFRS_Copay_Funding_Allocation__c fundingAllocation)
    {

        if(fundingAllocation != null && fundingAllocation.Id != null){
            List<GFRS_Copay_Payment_History__c> resultList = gFRS_DAOCopay.getPaymentHistoryByFundingAllocation(fundingAllocation);    
            for(GFRS_Copay_Payment_History__c item : resultList){
                if(item.SAP_Doc_ID__c != null){
                    return true;    
                }
            }
        }
        
        return false;
    }  
    
     /**
      * @author GFRS Dev Team 
      * @date 21/08/2014
      * @description validateCoverageOfPayment method - check payment coverage. Return false if is less than 100%
      */
     public static Boolean validateCoverageOfPayment(List<GFRS_Copay_Funding_Allocation__c> listOfFundingAllocation){

        if(listOfFundingAllocation == null || listOfFundingAllocation.size()<1){
         return false;
       }

       for(GFRS_Copay_Funding_Allocation__c item : listOfFundingAllocation){

         //if( item.Sum_of_Percents__c != 100 ||  item.Sum_of_Amounts__c < item.Payment_Amount__c ){
         System.debug('PN: TEST: item: ' + item);
         System.debug('PN: TEST: item.Pct_Covered__c: ' + item.Pct_Covered__c);
         if(item.Pct_Covered__c != 100){
           if( item.Grant_Request__r.Total_Approved_Amt__c == item.Grant_Request__r.Refundable_Deposit_Amount_if_any__c){
                return true;
                
            }
           return false;    
         }  
         
       }
       return true;
    
     }   
     
     /**
      * @author GFRS Dev Team 
      * @date 21/08/2014
      * @description validatePercentageOfLineItems method - check line item percents
      */
     public static Boolean validatePercentageOfLineItems(List<GFRS_Copay_Funding_Allocation_Line_Item__c> listOfFundingAllocationLineItems){
       
       if(listOfFundingAllocationLineItems == null || listOfFundingAllocationLineItems.size()<1){
         return false;
       }

       for(GFRS_Copay_Funding_Allocation_Line_Item__c item : listOfFundingAllocationLineItems){

         if( ( item.Percent__c == null && item.Amount__c == 0.00) || ( item.Percent__c == 0.00 && item.Amount__c == null)){
           return false;    
         }  
       }

       return true;
    
     }   
     
     public static void saveLockedLocation( GFRS_Location_Copay__c location ){
        upsert location;
    }
     
    /** 
    * @Author ADMD Team
    * @date 07/02/2017
    * @description insertVendorDetailsAttachmentExternal method - create attachment with Vendor Details for external funding requests
    */
    public static void insertVendorDetailsAttachmentExternal(String attName,Blob attBody,GFRS_Copay_Funding_Request__c request){
        Attachment tmpVendorDoc = new Attachment(Name=attName,body=attBody,parentId=request.Id);
        insert tmpVendorDoc;
        request.Vendor_Details_PDF__c = tmpVendorDoc.id;               
        update request;
    }  
    
/*         
         /**
    * @author GFRS Dev Team 
    * @date 02/12/2014
    * @description stopApprovalIFBADidntAcknowledgeExceededRevenue method - method method stopping approval process if  BA didn't set Appoval Amount and approved request
   
     
     public static void stopApprovalIFBADidntAcknowledgeExceededRevenue(Map<Id,GFRS_Funding_Request__c> newRequestsMap, Map<Id,GFRS_Funding_Request__c> oldRequestsMap){
        
        Set<Id> requestMeetingCriteria=new Set<ID>();
        
        for(GFRS_Funding_Request__c reqItem:newRequestsMap.values()){
                GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.id);
                
                //Check for Non Foundation Funding Types
                if( reqItem.Foundation_Classified__c == 'FALSE' 
                    && oldReq.Business_Approver_Decision_Date__c != reqItem.Business_Approver_Decision_Date__c 
                    && reqItem.Business_Approver_Decision_Date__c != null   
                    && (reqItem.Approved_Amount__c == null || reqItem.Approved_Amount__c <= 0) 
                    && reqItem.Business_Approver_Decision__c == 'Approved'){

                    requestMeetingCriteria.add(reqItem.id);
                }
                //Check for Foundation Funding Types
                if(reqItem.Foundation_Classified__c == 'TRUE' 
                    && oldReq.Business_Reviewer_Decision_Date__c != reqItem.Business_Reviewer_Decision_Date__c 
                    && reqItem.Business_Reviewer_Decision_Date__c != null   
                    && (reqItem.Approved_Amount__c == null || reqItem.Approved_Amount__c <= 0) 
                    && reqItem.Business_Reviewer_Decision__c == 'Approved'){

                    requestMeetingCriteria.add(reqItem.id);
                }
                
        }
        try{
            if(requestMeetingCriteria.size()>0){
                for(Id fundId:requestMeetingCriteria){

                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage              = System.Label.gFRS_ApprovedAmtZeroError;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}',currentRequest.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!Name}',currentRequest.name); 
                    currentRequest.addError(outputErrorMessage, false);
                }               
            }   
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
            
     }
*/
        public static void paymentSuccessUpdates(List<GFRS_Copay_Payment_History__c> newRequestList, Map<Id,GFRS_Copay_Payment_History__c> oldMap) {
            set<ID> phId = new set<Id>();
            for(GFRS_Copay_Payment_History__c phlist : newRequestList){
                phid.add(phlist.id);
            }
            GFRS_Copay_Payment_History__c PH = [select id, Status__c, SAP_Payment_Document_ID__c, Funding_Allocation__c, Grant__c FROM GFRS_Copay_Payment_History__c where id in :phid limit 1];
            if(PH.Status__c == 'Success' && PH.SAP_Payment_Document_ID__c == null && PH.Status__c != oldMap.get(PH.id).Status__c){
                list<gFRS_CoPay_Disease_State__c> DiseaseSt = new list<gFRS_CoPay_Disease_State__c>();
                list<gFRS_CoPay_Disease_State__c> DisSt = new list<gFRS_CoPay_Disease_State__c>();
                List<EmailTemplate> emailTemplateForIntenttoDonate       = null;
                string intentToDonateEmailBody                           = null;
                string intentToDonateEmailSubject                        = null;
                string ccEmailAddress                                    = System.Label.gFRS_Intent_to_Donate_CC_Mail_Id;
                User recipient;
                
                gFRS_Copay_Funding_Request__c fundReq = [ select Id, Name, OwnerId, Organization__r.Organization_Name__c, Funding_Type__c, Decision_Date__c, Decision_Date_Temp__c, Total_Approved_Amt__c, Total_Payment_Amount__c, Total_Paid_Amount__c, gCOI_Pending_Actions__c, Refundable_Deposit_Amount_if_any__c,  Status__c, Sub_Status__c, Revenue_Exceeded_33_Temp__c, Estimated_Current_Revenue_Exceeded_33__c,  Organization__r.Id, Request_AutoNumber__c, Payment_Email_Notification__c, LOA_Signed__c, Locationcopay__r.Vendor_Id__c, Locationcopay__r.Payment_Method__c, Locationcopay__r.Partner_Bank_Type__c, Event_Program_Title__c, Requested_Amount__c, Record_Type_Name__c, Delivery_Method__c, Payment_Method__c, Unix_ID__c, Building__c, Send_By_FedEx_cost_center_will_be_charg__c, Attention_To__c, Payment_Call_Counter__c, Payment_Type__c, Payment_Type_Temp__c, Payment_Automation__c, Payment_Automation_Temp__c, Recom_Desk__c, CST_Approver__c, Finance_Approver__c, VP_Approver__c, CFO_Approver__c
                            FROM GFRS_Copay_Funding_Request__c where id = :PH.Grant__c limit 1];
                
                gFRS_Copay_Funding_Allocation__c fundAlloc = [select id, Payment_Amount__c, Paid_Amount__c, Amount_Paid_Flag__c FROM gFRS_Copay_Funding_Allocation__c where id = :PH.Funding_Allocation__c];
                fundAlloc.Paid_Amount__c = fundAlloc.Payment_Amount__c;
                fundAlloc.Amount_Paid_Flag__c = 'Yes';
                
                update fundAlloc;
                
                DiseaseSt = [Select id, Disease_State_Fund_Name__c, Approved_Amount__c, Payment_Amount__c, PmtAmtTemp__c FROM gFRS_CoPay_Disease_State__c WHERE Copay_Funding_Request__c =:fundReq.id ];
                
                emailTemplateForIntenttoDonate=[SELECT TemplateType, Subject, Name, Body,HtmlValue 
                                                FROM EmailTemplate 
                                                WHERE Name = 'Intent to Donate'
                                                AND Folder.DeveloperName='gFRS_Templates'
                                                ORDER BY Name ASC ];
                recipient=[SELECT Id, FirstName, LastName, Name, Email 
                                        FROM User WHERE Id =:fundReq.OwnerId].get(0);                                           
                
                if(emailTemplateForIntenttoDonate.size()>0 && fundReq.Payment_Automation__c == 'Automated'){
                        intentToDonateEmailBody    = replaceEmailBody(emailTemplateForIntenttoDonate[0].Body, fundReq, DiseaseSt) ;
                        intentToDonateEmailSubject = replaceEmailSubject(emailTemplateForIntenttoDonate[0].Subject,fundReq.name);
                        intentToDonateEmailBody   +='\n\n'+'[ref:'+fundReq.id+']';
                        sendIntentToDonateEmail(recipient, intentToDonateEmailSubject, ccEmailAddress, intentToDonateEmailBody);
                }               
                
                for(gFRS_CoPay_Disease_State__c DS : DiseaseSt){
                    DS.PmtAmtTemp__c = DS.Payment_Amount__c;
                    DS.Approved_Amount__c += DS.Payment_Amount__c;
                    DS.Payment_Amount__c = null;                
                    DisSt.add(DS);
                }
                update DisSt;
                
                list<gFRS_CoPay_Disease_State__c> DiSt = new list<gFRS_CoPay_Disease_State__c>();
                DiSt = [Select id, Approved_Amount__c, Payment_Amount__c FROM gFRS_CoPay_Disease_State__c WHERE Copay_Funding_Request__c =:fundReq.id ];

                fundReq.Total_Paid_Amount__c = 0;
                for(gFRS_CoPay_Disease_State__c DS1 : DiSt){
                    fundReq.Total_Paid_Amount__c += DS1.Approved_Amount__c;
                }
                
                if(fundReq.Payment_Type__c != 'Full'){
               //     if(fundReq.Payment_Type_Temp__c == ''){
                    if(string.isblank(fundReq.Payment_Type_Temp__c)){                    
                        fundReq.External_Sub_status__c  = 'Intent to Donate';                   
                    }
                    fundReq.Payment_Type_Temp__c         = fundReq.Payment_Type__c;
                    fundReq.Payment_Automation_Temp__c   = fundReq.Payment_Automation__c;
                    fundReq.Revenue_Exceeded_33_Temp__c  = fundReq.Estimated_Current_Revenue_Exceeded_33__c;  
                    fundReq.Decision_Date_Temp__c        = fundReq.Decision_Date__c;                                      
                    
                    fundReq.Payment_Type__c         = '';
               //     fundReq.Payment_Automation__c   = '';
                    fundReq.Recom_Desk__c           = '';
               //     fundReq.Sub_Status__c           = 'Process Payment';
                    fundReq.External_Status_Temp__c   = 'Intent to Donate';                 
                    fundReq.CST_Reviewer_Decision__c          = null;
                    fundReq.CST_Reviewer_Decision_Date__c     = null;
                    fundReq.CST_Approver__c                   = null;
                    fundReq.CST_Approver_picklist__c          = null;                    
                    fundReq.CST_Approver_Decision__c          = null;
                    fundReq.CST_Approver_Decision_Date__c     = null;
                    fundReq.Finance_Approver__c               = null;
                    fundReq.Finance_Approver_picklist__c      = null;                    
                    fundReq.Finance_Approver_Decision__c      = null;
                    fundReq.Finance_Approver_Decision_Date__c = null;
                    fundReq.VP_Approver__c                    = null;
                    fundReq.VP_Approver_picklist__c           = null;                    
                    fundReq.VP_Approver_Decision__c           = null;
                    fundReq.VP_Approver_Decision_Date__c      = null;
                    fundReq.CFO_Approver__c                   = null;
                    fundReq.CFO_Approver_picklist__c          = null;                    
                    fundReq.CFO_Approver_Decision__c          = null;
                    fundReq.CFO_Approver_Decision_Date__c     = null;
                    fundReq.Decision_Date__c                  = null;
                    fundReq.Decision_Compliance_Flags_PDF__c  = null;
                    fundReq.Summary_PDF_snapshot__c           = null;
                    fundReq.Vendor_Bank_Reviewed__c           = false;
                    fundReq.Estimated_Current_Revenue_Exceeded_33__c = false;
                }
                else{
                    if(string.isblank(fundReq.Payment_Type_Temp__c)){
                        fundReq.External_Sub_status__c  = 'Intent to Donate';                   
                    }               
                    fundReq.Payment_Type_Temp__c         = fundReq.Payment_Type__c;
                    fundReq.Payment_Automation_Temp__c   = fundReq.Payment_Automation__c;  
                    fundReq.Revenue_Exceeded_33_Temp__c  = fundReq.Estimated_Current_Revenue_Exceeded_33__c;  
                    fundReq.Decision_Date_Temp__c        = fundReq.Decision_Date__c;                                    
                    fundReq.Sub_Status__c                = 'Process Payment'; 
                }
                update fundReq;         
                           
            }
        }
            
        /** 
    * @Author gFRS CoPay Team
    * @date 26/02/2018
    * @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
    * 
    */
        public static String replaceEmailBody(String emailBody, gFRS_Copay_Funding_Request__c fundReq, list<gFRS_CoPay_Disease_State__c> DiseaseSt){
            
            String outputBody = '';
            String DisStateDetails = '';
            
            if(emailBody != null){
                outputBody           = emailBody.replace('<<G-#####>>', fundReq.Name);            
                outputBody           = outputBody.replace('<<Foundation name>>', fundReq.Organization__r.Organization_Name__c);  
                for(gFRS_CoPay_Disease_State__c DS : DiseaseSt){
                    Decimal pA = DS.Payment_Amount__c;
                    List<String> args = new String[]{'0','number','##,###,##0'};
                    String pmtAmt = String.format(pA.format(), args);                    
                    DisStateDetails     =   DisStateDetails + DS.Disease_State_Fund_Name__c + ':  $' + pmtAmt + '\n';
                }
                outputBody           = outputBody.replace('<<Disease area: amount for each donation line item>>', DisStateDetails); 
            }
            
            return outputBody;
        }

            /** 
    * @Author gFRS CoPay Team
    * @date 26/02/2018
    * @description replaceEmailSubject method replace dynamic values defined in subject of emailTemplate
    * 
    */
        public static String replaceEmailSubject(String emailSub, string fundReqName){
            if(emailSub != null){
                return EmailSub.replace('<<G-#####>>', fundReqName);
            }
            return '';      
            
        }   
        
         /** 
    * @Author gFRS CoPay Team
    * @date 26/02/2018
    * @description sendIntentToDonateEmail method - Method used to send intent to donate email
    */
        public static void sendIntentToDonateEmail(user recipient, string intentToDonateEmailSubject, string ccEmailAddress, string intentToDonateEmailBody){
            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                string bccEmailAddress;
                GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
                bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;

                mail.setBccAddresses(new List < String > {bccEmailAddress});
                mail.setToAddresses(new List<String>{recipient.Email});
                mail.setSubject( intentToDonateEmailSubject );     
                mail.setCcAddresses(new List<String>{ccEmailAddress});
                
                mail.setPlainTextBody(intentToDonateEmailBody);
                mail.setOrgWideEmailAddressId([SELECT Id, Address 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
                
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }catch(Exception ex){
                
            }  
        }       
        
    /**
    * @author Copay Dev Team
    * @date 16/03/2018
    * @description CheckESBPaymentUpdate method - update Payment/Refund history record staus to Success
    *  if ESB populated SAP_Doc_ID__c field on gFRS_Payment_History__c object.
    *
    */
     public static void CheckESBPaymentUpdate(GFRS_Copay_Payment_History__c[] newPaymenList,Map<Id,GFRS_Copay_Payment_History__c> oldMap)
     {
        
        
        for(GFRS_Copay_Payment_History__c currentPayment: newPaymenList)
         {
            GFRS_Copay_Payment_History__c oldItem = oldMap.get(currentPayment.id);
            if (currentPayment.SAP_Doc_ID__c !=null && currentPayment.SAP_Doc_ID__c != oldItem.SAP_Doc_ID__c)
            {
                //update status to Success.
                currentPayment.Status__c = 'Success';
                
                //set the payment/refund date to today's date
                currentPayment.Date__c = Date.today();
            }

         }
     }
     
     
     public static void clearDSPaymentAmounts(Map<Id,gFRS_Copay_Funding_Request__c> oldRequestsMap, List<gFRS_Copay_Funding_Request__c> newRequestList){
        
        List<gFRS_CoPay_Disease_State__c> diseaseStateList = new List<gFRS_CoPay_Disease_State__c>();
        List<gFRS_Copay_Funding_Request__c> reqList = new List<gFRS_Copay_Funding_Request__c >();        
        set<id> reqIds = new set<id>();

        for(gFRS_Copay_Funding_Request__c cpr : newRequestList){
            
            gFRS_Copay_Funding_Request__c oldCpr = oldRequestsMap.get(cpr.id);
            
            if(((cpr.CST_Reviewer_Decision__c != oldCpr.CST_Reviewer_Decision__c) && cpr.CST_Reviewer_Decision__c == 'Rejected') ||
            ((cpr.CST_Approver_Decision__c != oldCpr.CST_Approver_Decision__c) && cpr.CST_Approver_Decision__c == 'Rejected') ||
            ((cpr.Finance_Approver_Decision__c != oldCpr.Finance_Approver_Decision__c) && cpr.Finance_Approver_Decision__c == 'Rejected') ||
            ((cpr.VP_Approver_Decision__c != oldCpr.VP_Approver_Decision__c) && cpr.VP_Approver_Decision__c == 'Rejected') ||
            ((cpr.CFO_Approver_Decision__c != oldCpr.CFO_Approver_Decision__c) && cpr.CFO_Approver_Decision__c == 'Rejected')){
                
                reqIds.add(cpr.id);
                for(gFRS_Copay_Funding_Request__c copayReq : [select id, name, Payment_Type__c,Payment_Automation__c,Recom_Desk__c,CST_Reviewer_Decision__c,CST_Reviewer_Decision_Date__c,CST_Approver__c,CST_Approver_picklist__c,CST_Approver_Decision__c,CST_Approver_Decision_Date__c,Finance_Approver__c,Finance_Approver_picklist__c,Finance_Approver_Decision__c,Finance_Approver_Decision_Date__c,VP_Approver__c,VP_Approver_picklist__c,VP_Approver_Decision__c,VP_Approver_Decision_Date__c,CFO_Approver__c,CFO_Approver_picklist__c,CFO_Approver_Decision__c,CFO_Approver_Decision_Date__c,Decision_Date__c,Decision_Compliance_Flags_PDF__c,Summary_PDF_snapshot__c,Vendor_Bank_Reviewed__c,Estimated_Current_Revenue_Exceeded_33__c FROM gFRS_Copay_Funding_Request__c Where Id = :cpr.id]){
                 
                    copayReq.Payment_Type__c                   = '';
                    copayReq.Payment_Automation__c             = '';
                    copayReq.Recom_Desk__c                     = '';                 
               //     copayReq.CST_Reviewer_Decision__c          = null;
                    copayReq.CST_Reviewer_Decision_Date__c     = null;
                    copayReq.CST_Approver__c                   = null;
                    copayReq.CST_Approver_picklist__c          = null;                    
                    copayReq.CST_Approver_Decision__c          = null;
                    copayReq.CST_Approver_Decision_Date__c     = null;
                    copayReq.Finance_Approver__c               = null;
                    copayReq.Finance_Approver_picklist__c      = null;                    
                    copayReq.Finance_Approver_Decision__c      = null;
                    copayReq.Finance_Approver_Decision_Date__c = null;
                    copayReq.VP_Approver__c                    = null;
                    copayReq.VP_Approver_picklist__c           = null;                    
                    copayReq.VP_Approver_Decision__c           = null;
                    copayReq.VP_Approver_Decision_Date__c      = null;
                    copayReq.CFO_Approver__c                   = null;
                    copayReq.CFO_Approver_picklist__c          = null;                    
                    copayReq.CFO_Approver_Decision__c          = null;
                    copayReq.CFO_Approver_Decision_Date__c     = null;
                 //   copayReq.Decision_Date__c                  = null;
                    copayReq.Decision_Compliance_Flags_PDF__c  = null;
                    copayReq.Summary_PDF_snapshot__c           = null;
                    copayReq.Vendor_Bank_Reviewed__c           = false;
                    copayReq.Estimated_Current_Revenue_Exceeded_33__c = false;               
                    
                    reqList.add(copayReq);
                }               
                
            }
            
        }
        
        update reqList;
        
        for(gFRS_Copay_Funding_Request__c reqItem : [SELECT Id, Name, (Select Id, Name, Copay_Funding_Request__c, Approved_Amount__c, Payment_Amount__c, Internal_Disease_State_Mapping__c FROM gFRS_CoPay_Disease_State__r) FROM gFRS_Copay_Funding_Request__c WHERE ID IN : reqIds ]){
            diseaseStateList.addAll(reqItem.gFRS_CoPay_Disease_State__r);
        }
        
        for(gFRS_CoPay_Disease_State__c diseaseState : diseaseStateList){
                diseaseState.Payment_Amount__c = null;
        } 
        
         update diseaseStateList;
         
     }
          
}