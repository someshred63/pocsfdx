public without sharing class EDM_Cl_Req_Review_Edit_Create_Ext extends GNE_SFA2_DynamicVFLoader {
    @TestVisible private EDM_Classification_Request_gne__c classificationRequest;
    public Attachment attachmentCV {get; set;}
    public Account acc {get; private set;}

    public Boolean existingRequest {get; private set;}

    public EDM_Cl_Req_Review_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller,'/apex/EDM_Cl_Req_Review_Edit_Create');
        attachmentCV = new Attachment();
    }

    public PageReference initWithAccount() {
        String requestId = ApexPages.currentPage().getParameters().get('Id');

        if (GNE_SFA2_S2S_Util.isFeatureEnabled(EDM_Classification_Request_RestUtil.Feature.ClassifReqRedirectReviewToMA.name())) {
            return new PageReference(EDM_Classification_Request_RestUtil.getUrlForReviewOnMA(requestId));
        }
        if(!EDM_Classification_Request_gne__c.sObjectType.getDescribe().isUpdateable()){
            return GNE_SFA2_Util.redirectToAccessDeniedPage();
        }
        PageReference pr;
        String accountId = ApexPages.currentPage().getParameters().get('accountId');

        if (requestId == null) {
            existingRequest = false;
            recordTypeName = 'Business';
            
            Savepoint sp = Database.setSavepoint();
            createFakeRequestToPrepopulateFormulas(accountId);
            pr = init();
            Database.rollback(sp);
        } else {
            existingRequest = true;

            pr = init();
            if (pr != null) {
                return pr;
            }
            accountId = (Id)myObject.get('EDM_Account_gne__c');
        }

        classificationRequest = (EDM_Classification_Request_gne__c)myObject;

        retrieveAccountObj(accountId);

        return pr;
    }

    private void createFakeRequestToPrepopulateFormulas(Id accountId) {
        if (accountId == null) {
            return;
        }
        String address = EDM_Cl_Req_Edit_Create_Ext.getAddress(accountId);
        classificationRequest = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = accountId,
                EDM_Account_Primary_Address_gne__c = address);
        classificationRequest.EDM_Account_Specialty_gne__c = [SELECT Id,Specialties_gne__c FROM Account WHERE Id=:classificationRequest.EDM_Account_gne__c].Specialties_gne__c;
        EDM_Classification_Request_Email_Notif.isTriggerDisabledForFakeRecords = true;
        insert classificationRequest;
        EDM_Classification_Request_Email_Notif.isTriggerDisabledForFakeRecords = false;

        myObject = classificationRequest;
    }

    private void retrieveAccountObj(Id accountId) {
        List<Account> accs = [select Id, EDM_Clinical_Classification_gne__c, EDM_Business_Classification_gne__c
                from Account where id = :accountId];
        if (accs.isEmpty()) {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Account not found'));
        } else {
            acc = accs.get(0);
        }
    }

    public List<SelectOption> getPossibleActions() {
        List<SelectOption> possibleActions = EDM_Classification_Utils.getPickListValues(EDM_Classification_Request_gne__c.getSObjectType(), 'EDM_Action_Taken_gne__c');
        if (!existingRequest) {
            removePickListValueFrom(possibleActions, 'Decline to Classify');
        }
        return possibleActions;
    }

    private static void removePickListValueFrom(List<SelectOption> selectOptions, String valueToRemove) {
        for(Integer i = 0; i < selectOptions.size(); i++) {
            if (selectOptions.get(i).getValue() == valueToRemove) {
                selectOptions.remove(i);
                break;
            }
        }
    }

    public PageReference cancel() {
        return EDM_Classification_Utils.createPageRef(getReturnURL());
    }

    public PageReference save() {
        Attachment attachmentCVCopy;
        Boolean validationFailed = false;
        if (!existingRequest) {
            attachmentCVCopy = attachmentCV; //copy attachmentCV to not exceeded viewstate when giving response
            attachmentCV = new Attachment();
            
            if(classificationRequest.EDM_Type_of_Classification_gne__c == 'Business' && (classificationRequest.EDM_Business_Role_gne__c == null || classificationRequest.EDM_Business_Role_gne__c == '')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select Business Role'));
                validationFailed = true;
            }
            if(attachmentCVCopy.body == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a CV to upload'));
                validationFailed = true;
            }
        }
        if(existingRequest && classificationRequest.EDM_Action_Taken_gne__c == 'Decline to Classify' 
            && (classificationRequest.EDM_Action_Comments_gne__c == null || classificationRequest.EDM_Action_Comments_gne__c =='') ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please add classification comment'));
            validationFailed = true;
        }
        if(validationFailed){
            return null;
        }
        
        updateClassificationRequest();

        String attachmentLink;
        if (!existingRequest) {
            EDM_Cl_Req_Edit_Create_Ext.insertCvAttachmentAndSaveURL(classificationRequest, attachmentCVCopy);
            attachmentLink = classificationRequest.EDM_CV_Attachment_Link_gne__c;
        } else {
             //this field is not displed
            attachmentLink = retrieveAttachmentLink();
        }

        changeClassificationOnAccount(attachmentLink);

        return EDM_Classification_Utils.createPageRef(getReturnURL());
    }

    private void changeClassificationOnAccount(String attachmentLink) {
        if (classificationRequest.EDM_Action_Taken_gne__c == 'Decline to Classify') {
            //TODO how to notify 
            return;
        }

        if (classificationRequest.EDM_Type_of_Classification_gne__c == 'Business') {
            acc.EDM_Business_Classification_gne__c = classificationRequest.EDM_Action_Taken_gne__c;
            acc.EDM_Business_Classification_Date_gne__c = System.today();
            acc.EDM_Business_Classification_DateTime_gne__c = System.now();
            acc.EDM_Business_Cl_Performed_By_gne__c = UserInfo.getUserId();
            acc.EDM_Business_Classification_CV_gne__c = attachmentLink;

            acc.EDM_Business_Cl_Role_gne__c = classificationRequest.EDM_Business_Role_gne__c;
        } else {
            acc.EDM_Clinical_Classification_gne__c = classificationRequest.EDM_Action_Taken_gne__c;
            acc.EDM_Clinical_Classification_Date_gne__c = System.today();
            acc.EDM_Clinical_Classification_DateTime_gne__c = System.now();
            acc.EDM_Clinical_Cl_Performed_By_gne__c = UserInfo.getUserId();
            acc.EDM_Clinical_Classification_CV_gne__c = attachmentLink;
        }

        update acc;
        
        List<Speaker_Bureau_Membership_gne__c> sbms = [SELECT Speaker_Status_gne__c, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__c, Current_Speaker_Scope_gne__c, Current_Speaker_Scope_Date_gne__c, Current_Exclusion_Status_gne__c, Current_Exclusion_Status_Date_gne__c
                FROM Speaker_Bureau_Membership_gne__c
                WHERE Bureau_Member_gne__c = :acc.Id];
        GNE_SFA2_Spkr_Bur_Mem_Validation_Rules.takeSnapshotClassificationAndExclusion(sbms);
        if(sbms != null)
            update sbms;
    }

    private String retrieveAttachmentLink() {
        List<EDM_Classification_Request_gne__c> classReqAttach = [Select EDM_CV_Attachment_Link_gne__c From EDM_Classification_Request_gne__c where id = :classificationRequest.id LIMIT 1];
        return (!classReqAttach.isEmpty() ? classReqAttach.get(0).EDM_CV_Attachment_Link_gne__c : '');
    }

    private void updateClassificationRequest() {
        classificationRequest.EDM_Status_gne__c = 'Completed';
        classificationRequest.EDM_Reviewer_gne__c = UserInfo.getUserId();
        classificationRequest.EDM_Reviewed_Date_gne__c = System.now();

        if (existingRequest && classificationRequest.EDM_Action_Taken_gne__c != 'Decline to Classify') {
            classificationRequest.EDM_Action_Comments_gne__c = null;
        }

        if (classificationRequest.EDM_Type_of_Classification_gne__c != 'Business') {
            classificationRequest.EDM_Business_Role_gne__c = null;
        }

        if (existingRequest) {
            update classificationRequest;
        } else {
            //fake was rollbacked, need to clone to get copy of values without ids
            classificationRequest = classificationRequest.clone(false, true, false, false);
            String typeOfClassification = classificationRequest.EDM_Type_of_Classification_gne__c;
            Id recTypeId = Schema.SObjectType.EDM_Classification_Request_gne__c.getRecordTypeInfosByName().get(typeOfClassification).getRecordTypeId();
            classificationRequest.RecordTypeId = recTypeId;
            insert classificationRequest;
            //classificationRequest = newClassificationRequest;
        }
    }

    public String getReturnURL() {
        return EDM_Classification_Utils.getReturnURL(classificationRequest.EDM_Account_gne__c);
    }

    public String getStatus(){
        if(existingRequest){
            return [SELECT EDM_Status_gne__c FROM EDM_Classification_Request_gne__c WHERE Id =:classificationRequest.Id].EDM_Status_gne__c;
        }
        return '';
    }
}