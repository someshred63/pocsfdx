global with sharing class gFRS_FundingRequestDenialBatch implements Database.Batchable<GFRS_Funding_Request__c>, Database.Stateful{
    private List<String> fundingIds;
    private List<String> itcsToUpdate;
    private List<String> fundingIdsToPass;
    private List<String> fundingIdsFailed;
    private Integer executeSize;
    private String debugId;
    public static final String SET_INTERNAL_TRACKING_CODE = 'Set internal tracking code';
    public static final String SET_QCO_REVIEW_STATUS = 'Set QCO review status';
    public static final String SUBMIT_APPROVAL_PROCESS_FOUNDATION_CLASSIFIED = 'Submit approval process foundation classified';
    public static final String REJECT_APPROVAL_PROCESS = 'Reject approval process';
    public static final String CLOSE_FUNDING_REQUEST = 'Close funding request';
    public List<String> batchTasks = new List<String>{SET_INTERNAL_TRACKING_CODE, SET_QCO_REVIEW_STATUS, SUBMIT_APPROVAL_PROCESS_FOUNDATION_CLASSIFIED, REJECT_APPROVAL_PROCESS, CLOSE_FUNDING_REQUEST};
    private String currentTask;
    private List<gFRS_Debug_Log__c> logs = new List<gFRS_Debug_Log__c>();
    public static final String STATUS_DENIAL = 'Denial';
    public static final String STATUS_DENIED = 'Denied';
    public static final String LIMITED_FUNDING_AVAILABILITY = 'Limited Funding Availability';
    public static final String EMAIL_TEMPLATE_LFA = 'Limited_Funding_Availability';
    public static final String EMAIL_TEMPLATE_LFA_CAPP = 'Limited_Funding_Availability_CAPP';

    global gFRS_FundingRequestDenialBatch(List<String> fundingIds, List<String> itcsToUpdate, String bt, Integer executeSize, String debugId){
        this.fundingIds = fundingIds;
        this.itcsToUpdate = itcsToUpdate;
        this.currentTask = bt;
        this.executeSize = executeSize;
        this.debugId = debugId;
        this.fundingIdsToPass = new List<String>();
        this.fundingIdsFailed = new List<String>();
    }

    global Iterable<GFRS_Funding_Request__c> start(Database.BatchableContext BC){
        List<GFRS_Funding_Request__c> frs = [
                SELECT Id, Name, Internal_Tracking_Code_optional__c, Sub_Status__c, RecordType.Name,
                        Foundation_Classified__c, Owner.Email, Event_Program_Title__c, Owner.FirstName, Owner.LastName
                FROM GFRS_Funding_Request__c
                WHERE Id IN :fundingIds
        ];
        return frs;
    }

    global void execute(Database.BatchableContext BC, List<GFRS_Funding_Request__c> scope){
        try{
            if(currentTask == SET_INTERNAL_TRACKING_CODE){
                setInternalTrackingCode(scope);
                updateAndLogErrors(scope);
            }

            if(currentTask == SET_QCO_REVIEW_STATUS){
                setSubStatus(scope);
                updateAndLogErrors(scope);
            }

            if(currentTask == SUBMIT_APPROVAL_PROCESS_FOUNDATION_CLASSIFIED){
                submitApprovalProcess(scope);
            }

            if(currentTask == REJECT_APPROVAL_PROCESS){
                rejectApprovalProcess(scope);
            }

            if(currentTask == CLOSE_FUNDING_REQUEST){
                closeFundingRequests(scope);
                updateAndLogErrors(scope);
            }
        }
        catch (Exception e){
            logs.add(new gFRS_Debug_Log__c(Record_Id__c = debugId, Error_Description__c = e.getMessage() + ' ' + e.getStackTraceString()));
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(!fundingIdsToPass.isEmpty()){
            gFRS_Debug_Log__c log = new gFRS_Debug_Log__c();
            log.Record_Id__c = debugId;
            log.Error_Description__c = currentTask + ';';
            for(String id : fundingIdsToPass){
                log.Error_Description__c += id + ';';
            }
            logs.add(log);
        }
        if(!fundingIdsFailed.isEmpty()){
            gFRS_Debug_Log__c log = new gFRS_Debug_Log__c();
            log.Record_Id__c = debugId;
            log.Error_Description__c = currentTask + ';';
            for(String id : fundingIdsFailed){
                log.Error_Description__c += id + ';';
            }
            logs.add(log);
        }
        if(!logs.isEmpty()){
            insert logs;
        }
        if(currentTask != SET_INTERNAL_TRACKING_CODE && currentTask != CLOSE_FUNDING_REQUEST){
            Integer taskIndex = batchTasks.indexOf(currentTask);
            taskIndex++;
            Database.executeBatch(new gFRS_FundingRequestDenialBatch(fundingIdsToPass, itcsToUpdate, batchTasks.get(taskIndex), executeSize, debugId + '_' + taskIndex), executeSize);
        }
    }

    private void setInternalTrackingCode(List<GFRS_Funding_Request__c> frs){
        for(GFRS_Funding_Request__c fr : frs){
            Set<String> currentValues = new Set<String>();
            if(fr.Internal_Tracking_Code_optional__c != null){
                currentValues = new Set<String>(fr.Internal_Tracking_Code_optional__c.split(';'));
            }
            for(String itc : itcsToUpdate){
                currentValues.add(itc);
            }
            fr.Internal_Tracking_Code_optional__c = String.join(new List<String>(currentValues), ';');
        }
    }

    private void setSubStatus(List<GFRS_Funding_Request__c> frs){
        for(GFRS_Funding_Request__c fr : frs){
            if(!(fr.Foundation_Classified__c == 'TRUE' && (fr.RecordType.Name == gFRS_Util.TYPE_FELLOWSHIPS_NAME ||
                    fr.RecordType.Name == gFRS_Util.TYPE_HC_CHAR_NAME || fr.RecordType.Name == gFRS_Util.TYPE_PHILANTHROPIC_NAME))){
                fr.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_CCO;
            }
        }
    }

    private void submitApprovalProcess(List<GFRS_Funding_Request__c> frs){
        List<Approval.ProcessSubmitRequest> psrs = new List<Approval.ProcessSubmitRequest>();
        for(GFRS_Funding_Request__c fr : frs){
            if(!Approval.isLocked(fr.Id)){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(fr.Id);
                req.setSkipEntryCriteria(true);
                if((fr.RecordType.Name == gFRS_Util.TYPE_FELLOWSHIPS_NAME || fr.RecordType.Name == gFRS_Util.TYPE_HC_CHAR_NAME || fr.RecordType.Name == gFRS_Util.TYPE_PHILANTHROPIC_NAME) && fr.Foundation_Classified__c == 'TRUE'){
                    req.setProcessDefinitionNameOrId('Foundation_Process_2');
                }
                else if((fr.RecordType.Name == gFRS_Util.TYPE_FELLOWSHIPS_NAME || fr.RecordType.Name == gFRS_Util.TYPE_HC_CHAR_NAME || fr.RecordType.Name == gFRS_Util.TYPE_PHILANTHROPIC_NAME || fr.RecordType.Name == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) && fr.Foundation_Classified__c == 'FALSE'){
                    req.setProcessDefinitionNameOrId('CAPP_DEV_Approval_Process');
                }
                else if(fr.RecordType.Name == gFRS_Util.TYPE_IMED_NAME){
                    req.setProcessDefinitionNameOrId('IMED_Approval_Process');
                }
                else{
                    req.setProcessDefinitionNameOrId('Corp_Mem_Field_Exhbt_Other_Promo');
                }
                psrs.add(req);
            }
            else{
                fundingIdsToPass.add(fr.Id);
            }
        }
        Approval.ProcessResult[] prList = Approval.process(psrs, false);
        for(Approval.ProcessResult pr : prList){
            if(pr.isSuccess()){
                fundingIdsToPass.add(pr.getEntityId());
            }
            else{
                for(Database.Error err : pr.getErrors()){
                    fundingIdsFailed.add(pr.getEntityId() + '_' + err.getStatusCode() + '_' + err.getMessage());
                }
            }
        }
    }

    private void rejectApprovalProcess(List<GFRS_Funding_Request__c> frs){
        List<Id> newWorkItemIds = new List<Id>();
        Set<Id> frIds = new Map<Id, GFRS_Funding_Request__c>(frs).keySet();
        List<Approval.ProcessWorkitemRequest> pwrs = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstance> processInstances = [SELECT (SELECT Id FROM Workitems) FROM ProcessInstance WHERE TargetObjectId IN :frIds];
        for (ProcessInstance pi : processInstances) {
            for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                for (ProcessInstanceWorkitem wi : wis ) {
                    newWorkItemIds.add(wi.id);
                }
            }
        }

        for(Id workItemId : newWorkItemIds){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Reject');
            req.setWorkitemId(workItemId);
            pwrs.add(req);
        }
        Approval.ProcessResult[] prList = Approval.process(pwrs, false);
        for(Approval.ProcessResult pr : prList){
            if(pr.isSuccess()){
                fundingIdsToPass.add(pr.getEntityId());
            }
            else{
                for(Database.Error err : pr.getErrors()){
                    fundingIdsFailed.add(pr.getEntityId() + '_' + err.getStatusCode() + '_' + err.getMessage());
                }
            }
        }
    }

    private void closeFundingRequests(List<GFRS_Funding_Request__c> frs){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<String> templates = new List<String>{EMAIL_TEMPLATE_LFA, EMAIL_TEMPLATE_LFA_CAPP};
        List<EmailTemplate> emailTemplates = [SELECT TemplateType, Subject, Name, DeveloperName, Body,HtmlValue
                                                FROM EmailTemplate
                                                WHERE DeveloperName IN :templates];
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        List<OrgWideEmailAddress> orgWideAddress = [SELECT Id, Address
                                                        FROM OrgWideEmailAddress
                                                        WHERE Address=: customSettings.Org_Wide_Email_Address__c limit 1];
        for(GFRS_Funding_Request__c fr : frs){
            fr.Decision_Reasons__c = LIMITED_FUNDING_AVAILABILITY;
            fr.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
            fr.Sub_Status__c = STATUS_DENIED;
            fr.External_Sub_status__c = STATUS_DENIED;
            //Workflow 'gFRS Foundation Denied - Limited Funding Availability' workaround
            if(fr.Foundation_Classified__c == 'FALSE'){
                emailsToSend.add(createClosingEmail(fr, emailTemplates, orgWideAddress[0], customSettings.gFRS_Inbound_Email__c));
            }
        }
        Messaging.sendEmail(emailsToSend);
    }

    private Messaging.SingleEmailMessage createClosingEmail(GFRS_Funding_Request__c fr, List<EmailTemplate> emailTemplates, OrgWideEmailAddress orgWideAddress, String bccEmail){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailBody;
        String emailSubject;
        String emailTemplateToUse;

        if(fr.RecordType.Name == gFRS_Util.TYPE_IMED_NAME){
            emailTemplateToUse = EMAIL_TEMPLATE_LFA;
        }else{
            emailTemplateToUse = EMAIL_TEMPLATE_LFA_CAPP;
        }

        for(EmailTemplate et: emailTemplates){
            if(et.DeveloperName == emailTemplateToUse){
                emailBody = et.Body.replace('<<G-#####>>', fr.Name)
                        .replace('<<Program/Event Title>>', checkNull(fr.Event_Program_Title__c))
                        .replace('<<First Name Last Name>>', checkNull(fr.Owner.FirstName) + ' ' + checkNull(fr.Owner.LastName));
                emailBody +='\n\n'+'[ref:' + fr.id + ']';
                emailSubject = et.Subject.replace('<<G-#####>>', fr.Name);
                break;
            }
        }

        mail.setToAddresses(new List<String>{fr.Owner.Email});
        mail.setSubject(emailSubject);
        mail.setBccAddresses(new List<String>{bccEmail});
        mail.setPlainTextBody(emailBody);
        mail.setOrgWideEmailAddressId(orgWideAddress.id);
        return mail;
    }

    private String checkNull( String v ){
        return( v == null || v == 'null' ? '' : v );
    }

    private void updateAndLogErrors(List<GFRS_Funding_Request__c> scope){
        Database.SaveResult[] srList = Database.update(scope, false);
        for(Integer i = 0; i < srList.size(); i++){
            if(srList.get(i).isSuccess()){
                fundingIdsToPass.add(srList.get(i).getId());
            }
            else{
                for(Database.Error err : srList.get(i).getErrors()){
                    fundingIdsFailed.add(scope.get(i).Id + '_' + err.getStatusCode() + '_' + err.getMessage());
                }
            }
        }
    }

}