public without sharing class AGS_EX_Exclusion_Utils {
    
    public static String getListViewId(String objectName, String viewLabel) {
        String ListViewId;
        String query = 'SELECT Name FROM ' + objectName + ' LIMIT 1';
        ApexPages.StandardSetController acc = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        List<SelectOption> ListViews = acc.getListViewOptions();

        for(SelectOption w : ListViews ) {
            if(w.getLabel() == viewLabel) {
                ListViewId = w.getValue().left(15);
            }
        }
        return ListViewId;
    }

    public static Messaging.SingleEmailMessage getTemplatedEmail(ID targetObjId, Id whatId, Id templateId) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjId);
        mail.setWhatId(whatId);
        mail.setTemplateId(templateId);
        mail.setSaveAsActivity(false);
        return mail;
    }

    public static Messaging.SingleEmailMessage getTemplatedEmailWithOWA(ID targetObjId, Id whatId, Id templateId, Id owaId) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjId);
        mail.setWhatId(whatId);
        mail.setTemplateId(templateId);
        mail.setOrgWideEmailAddressId(owaId);
        mail.setSaveAsActivity(false);
        return mail;
    }

    public static String getAddress(Id accountId) {
        List<Address_vod__c> addressList = [
                SELECT Name, City_vod__c, State_vod__c, Zip_vod__c
                FROM Address_vod__c
                WHERE Account_vod__c = :accountId 
                ORDER BY Primary_vod__c DESC, GOLD_RECORD_gne__c DESC, LastModifiedDate DESC
                LIMIT 1];

        if (!addressList.isEmpty()) {
            Address_vod__c address = addressList.get(0);
            return  (String.isNotBlank(address.Name) ? address.Name : '') +
                    (String.isNotBlank(address.City_vod__c) ? ', ' + address.City_vod__c : '') +
                    (String.isNotBlank(address.State_vod__c) ? ', ' + address.State_vod__c : '') +
                    (String.isNotBlank(address.Zip_vod__c) ? ' ' + address.Zip_vod__c : '');
        }
        return null;
    }

    public static List<SelectOption> getPickListValues(Schema.sObjectType sObjType, String fieldName) {
        Schema.DescribeSObjectResult descSObjectResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = descSObjectResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();

        for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new selectOption(entry.getLabel(), entry.getValue()));
        }

        return options;
    }

    public static String getReturnURL() {
        return ApexPages.currentPage().getParameters().get('retURL');
    }

    public static String getReturnURL(Id idWhenRetURLIsEmpty) {
        String retURL = getReturnURL();
        if (String.isBlank(retURL)) {
            retURL = '/' + idWhenRetURLIsEmpty;
        }
        return retURL;
    }

    public static PageReference createPageRef(String url) {
        PageReference pr = new PageReference(url);
        pr.setRedirect(true);
        return pr;
    }

    public static String prepareLinkToAttachment(Attachment attach) {
        String viewURL = '/servlet/servlet.FileDownload?file=';
        return viewURL + attach.Id;
    }
    
    public static Boolean insertAttachment(Attachment attach, Id parentId) {
        if(attach.body != null) {
            attach.ParentId = parentId;
            insert attach;
            return true;
        }
        return false;
    }

    public static Boolean createRequest(Account currentAccount) {
        //refresh account status
        Boolean requestSent = false;
        String accountStatus = [SELECT AGS_EX_Exclusion_Status_base_gne__c FROM Account WHERE Id = :currentAccount.Id].AGS_EX_Exclusion_Status_base_gne__c;
        //If no exclusion check request for current account exists
        if (accountStatus == 'Not Checked' || accountStatus == 'Verified and clear' || accountStatus == 'Sanctioned but legal approved' || accountStatus == 'Excluded') {
            Savepoint sp = Database.setSavepoint();
            try { 
                AGS_EX_Exclusion_Request_gne__c newExclusionRequest = new AGS_EX_Exclusion_Request_gne__c();
                newExclusionRequest.AGS_EX_Account_Name_gne__c = currentAccount.id;
                String addr = AGS_EX_Exclusion_Utils.getAddress(currentAccount.Id);
                newExclusionRequest.AGS_EX_Account_Primary_Address_gne__c = (addr == null ? 'No address available' : addr);
                insert newExclusionRequest;

                addNewRequestor(newExclusionRequest.Id);

                currentAccount.AGS_EX_Exclusion_Status_base_gne__c = 'Check pending';
                update currentAccount;
                sendEmails(newExclusionRequest.Id);
                requestSent = true;
            }
            catch (DmlException ex) {
                Database.rollback(sp);
                System.debug('AGS_EX_Exclusion_Utils new request exception: ' + ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not create new request!'));
            }
        }
        //If exclusion check request record already exists (raised by another user) and was not verified by CCO yet
        else if (accountStatus == 'Check pending') {
            try {
                List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c 
                                                                                FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                WHERE 
                                                                                AGS_EX_Request_Status_gne__c = 'Pending'
                                                                                AND AGS_EX_Account_Name_gne__c = :currentAccount.id];
                if (existingExclusionRequests.size() == 0) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There are no existing requests, but the account status is Check pending!'));
                }
                else if (existingExclusionRequests.size() > 1) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There are more than one pending request for this account!'));
                }
                else {
                    addNewRequestor(existingExclusionRequests[0].Id);
                    requestSent = true;
                }
            }
            catch (Exception ex) {
                System.debug('AGS_EX_Exclusion_Utils new requestor to existing request exception: ' + ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not add new requestor!'));
            }
        } else {
            //If exclusion check request already exists (raised by another user) and was already verified by CCO
            requestSent = false;
        }
        return requestSent;
    }

    private static void sendEmails(Id newExclusionRequestId){
        Id newRequestEmailTemplate = [select id,Name from EmailTemplate where developername = 'AGS_EX_New_Exclusion_Request'].id;
                  
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Contact exclusioncheck_d = [SELECT Id, Name, Email FROM Contact WHERE Name = 'Exclusion Check' LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(exclusioncheck_d.Id);
        email.setWhatId(newExclusionRequestId);
        email.setTemplateId(newRequestEmailTemplate);
        email.setSaveAsActivity(false);
        emails.add(email);
        if(emails.size()>0){
            Messaging.sendEmail(emails);
        }
    }

    private static void addNewRequestor(Id exclusionRequestId) {
        Integer existingRequestorCount = [SELECT Count() FROM AGS_EX_Exclusion_Requestor_gne__c WHERE AGS_EX_Exclusion_Request_gne__c = :exclusionRequestId 
                                                                                                    AND AGS_EX_Requestor_Name_gne__c = :UserInfo.getUserId()];
        if(existingRequestorCount == 0){
            AGS_EX_Exclusion_Requestor_gne__c newRequestor = new AGS_EX_Exclusion_Requestor_gne__c();
            newRequestor.AGS_EX_Exclusion_Request_gne__c = exclusionRequestId;
            newRequestor.AGS_EX_Requestor_Name_gne__c = UserInfo.getUserId();
            insert newRequestor;
        }
    }

    public static Integer createMultipleRequests(List<String> accounts) {
        //refresh account status
        List<AGS_EX_Exclusion_Request_gne__c> requests = new List<AGS_EX_Exclusion_Request_gne__c>();
        List<Account> accountsWithoutRequest = [SELECT id,AGS_EX_Exclusion_Status_base_gne__c,Main_Address_gne__r.Address_1_gne__c,
                                         Main_Address_gne__r.City_vod__c,Main_Address_gne__r.State_vod__c,
                                         Main_Address_gne__r.Zip_vod__c 
                                         FROM Account 
                                         WHERE Id in :accounts 
                                         and id not in (select AGS_EX_Account_Name_gne__c from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Request_Status_gne__c = 'Pending')];
        //If no exclusion check request for current account exists
        for(Account a : accountsWithoutRequest){
            if(a.AGS_EX_Exclusion_Status_base_gne__c == 'Not Checked') { 
                AGS_EX_Exclusion_Request_gne__c newExclusionRequest = new AGS_EX_Exclusion_Request_gne__c();
                newExclusionRequest.AGS_EX_Account_Name_gne__c = a.id;
                String addr = (String.isNotBlank(a.Main_Address_gne__r.Address_1_gne__c) ? ' ' + a.Main_Address_gne__r.Address_1_gne__c : '') +
                    (String.isNotBlank(a.Main_Address_gne__r.City_vod__c) ? ' ' + a.Main_Address_gne__r.City_vod__c : '') +
                    (String.isNotBlank(a.Main_Address_gne__r.State_vod__c) ? ', ' + a.Main_Address_gne__r.State_vod__c : '') +
                    (String.isNotBlank(a.Main_Address_gne__r.Zip_vod__c) ? ' ' + a.Main_Address_gne__r.Zip_vod__c : '');
                    
                newExclusionRequest.AGS_EX_Account_Primary_Address_gne__c = (String.isBlank(addr.Trim()) ? 'No address available' : addr);
                requests.add(newExclusionRequest);
                a.AGS_EX_Exclusion_Status_base_gne__c = 'Check pending';
            }              
        }
        List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,AGS_EX_Account_Name_gne__r.AGS_EX_Exclusion_Status_base_gne__c
                                                                           FROM AGS_EX_Exclusion_Request_gne__c 
                                                                           WHERE AGS_EX_Request_Status_gne__c = 'Pending' AND AGS_EX_Account_Name_gne__c in :accounts];
        for(AGS_EX_Exclusion_Request_gne__c er : existingExclusionRequests){
            if (er.AGS_EX_Account_Name_gne__r.AGS_EX_Exclusion_Status_base_gne__c == 'Check pending') {
                requests.add(er);
            }
        }
        upsert requests;
        addNewRequestorForMultipleRequests(requests);
        update accountsWithoutRequest;
        sendEmailsForMultipleRequests(requests);

        //return number of created or updated requests
        return requests.size();
    }

    private static void addNewRequestorForMultipleRequests(List<AGS_EX_Exclusion_Request_gne__c> exclusionRequests) {
        String us = UserInfo.getUserId();
        List<AGS_EX_Exclusion_Requestor_gne__c> newRequestors = new List<AGS_EX_Exclusion_Requestor_gne__c>();
        List<AGS_EX_Exclusion_Requestor_gne__c> existingRequestor = new List<AGS_EX_Exclusion_Requestor_gne__c>([SELECT AGS_EX_Exclusion_Request_gne__c 
                                                                            FROM AGS_EX_Exclusion_Requestor_gne__c 
                                                                            WHERE AGS_EX_Exclusion_Request_gne__c in :exclusionRequests 
                                                                            AND AGS_EX_Requestor_Name_gne__c != :us]);
        Set<Id> excReq = new Set<Id>();
        for(AGS_EX_Exclusion_Requestor_gne__c ereq : existingRequestor){
            excReq.add(ereq.AGS_EX_Exclusion_Request_gne__c);
        }
        for(AGS_EX_Exclusion_Request_gne__c er : exclusionRequests){
            if(!excReq.contains(er.Id)){
                AGS_EX_Exclusion_Requestor_gne__c newRequestor = new AGS_EX_Exclusion_Requestor_gne__c();
                newRequestor.AGS_EX_Exclusion_Request_gne__c = er.Id;
                newRequestor.AGS_EX_Requestor_Name_gne__c = us;
                newRequestors.add(newRequestor);
            }
        }
        insert newRequestors;
    }

    private static void sendEmailsForMultipleRequests(List<AGS_EX_Exclusion_Request_gne__c> exclusionRequests){
        Id newRequestEmailTemplate = [select id,Name from EmailTemplate where developername = 'AGS_EX_New_Exclusion_Request'].id;
        
        List<Id> spReviewersIds = new List<Id>();            
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Contact exclusioncheck_d = [SELECT Id, Name, Email FROM Contact WHERE Name = 'Exclusion Check' LIMIT 1];
        
        for(AGS_EX_Exclusion_Request_gne__c er : exclusionRequests){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(exclusioncheck_d.Id);
            email.setWhatId(er.Id);
            email.setTemplateId(newRequestEmailTemplate);
            email.setSaveAsActivity(false);
            emails.add(email);
        }
        if(emails.size()>0){
            Messaging.sendEmail(emails);
        }
    }
}