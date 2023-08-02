public without sharing class EDM_Classification_Request_Email_Notif {
    
    final static String NEW_REQUEST_EMAIL_TEMPLATE = 'EDM_Classification_Request';
    final static String REQUEST_DECLINED_EMAIL_TEMPLATE = 'EDM_Classification_Request_Result_Decl';
    final static String REQUEST_RESULT_EMAIL_TEMPLATE = 'EDM_Classification_Request_Result';
    final static String REQUEST_RECLASSIFIED_EMAIL_TEMPLATE = 'EDM_Classification_Request_Result_ReClasified';
    final static String NEW_REQUEST_EMAIL_TEMPLATE_ATTLINK = 'EDM_Classification_Request_AttLink';

    public static Boolean isTriggerDisabledForFakeRecords = false;

    public static void onAfterUpdate(List<EDM_Classification_Request_gne__c> triggerOld,List<EDM_Classification_Request_gne__c> triggerNew) {
        
        if(!isTriggerDisabledForFakeRecords){
            List<ID> crIds = new List<Id>();
            List<ID> accounts = new List<ID>();
            for(EDM_Classification_Request_gne__c cr : triggerNew){
                crIds.add(cr.Id);
                accounts.add(cr.EDM_Account_gne__c);
            }

            OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Classification Requests' LIMIT 1];

            Id newRequestEmailTemplate = [select id,Name from EmailTemplate where developername = : NEW_REQUEST_EMAIL_TEMPLATE].id;
            Id requestDeclinedTemplate = [select id,Name from EmailTemplate where developername = : REQUEST_DECLINED_EMAIL_TEMPLATE].id;
            Id requestResultTemplate = [select id,Name from EmailTemplate where developername = : REQUEST_RESULT_EMAIL_TEMPLATE].id;
            EmailTemplate requestReclassifiedTemplate = [select id,Name, HtmlValue, Body from EmailTemplate where developername = : REQUEST_RECLASSIFIED_EMAIL_TEMPLATE];
            Id newRequestEmailTemplateAttLink = [select id,Name from EmailTemplate where developername = : NEW_REQUEST_EMAIL_TEMPLATE_ATTLINK].id;
            Map<Id,RecordType> recType = new Map<Id,RecordType>([select Id,DeveloperName, IsActive, Name, SobjectType from RecordType where IsActive = true AND SobjectType ='EDM_Classification_Request_gne__c']);

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            String thisYear = String.valueOf(System.Today().year());
            List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>([select Speaker_Bureau_ID_gne__r.Speaker_Bureau_Lead_gne__c,Bureau_Member_gne__c 
                                                                                                     from Speaker_Bureau_Membership_gne__c 
                                                                                                     where Bureau_Member_gne__c in :accounts AND Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c >= :thisYear]);

            Map<Id, Set<Id>> ablsByAccountID = getABLsByAccountID(accounts);

            Reviewers reviewers = new Reviewers();

            List<EDM_Classification_Request_gne__c> newRequests = new List<EDM_Classification_Request_gne__c>();
            List<Id> newRequestsIds = new List<Id>();

            List<Contact> ClinicalDL = [Select Id from Contact where Name = 'ClinicalClassificationDL' limit 1];
            List<Contact> BusinessDL = [Select Id from Contact where Name = 'BusinessClassificationDL' limit 1];

            Map<Id, Account> objMap = new Map<Id, Account>([
                    SELECT Id, Name
                    FROM Account
                    WHERE Id IN : accounts
            ]);

            for(Integer i=0;i<=triggerOld.size()-1;i++){
                EDM_Classification_Request_gne__c oldCR=triggerOld.get(i);
                EDM_Classification_Request_gne__c newCR=triggerNew.get(i);
                if(oldCR.EDM_CV_Attachment_Link_gne__c == null && newCR.EDM_CV_Attachment_Link_gne__c != null){
                    if(newCR.EDM_Status_gne__c != 'Completed'){
                        newRequests.add(newCr);
                        newRequestsIds.add(newCr.Id);
                    }
                } else {
                    if ( isReviewExitingClassificationRequestMode(oldCR, newCR) || isUpdateClassificationMode(oldCR, newCR)) {

                        if (newCR.EDM_Action_Taken_gne__c != 'Decline To Classify') {
                            List<Id> usersToSendTo = new List<Id>();
                            usersToSendTo.addAll(getSBLList(sbm,newCr.EDM_Account_gne__c));
                            if (ablsByAccountID.containsKey(newCR.EDM_Account_gne__c)) {
                                usersToSendTo.addAll(ablsByAccountID.get(newCR.EDM_Account_gne__c));
                            }
                            
                            //System.debug('##SBLS '+sbls);
                            for(Id uid : usersToSendTo){
                                //System.debug('###SBLS_E: '+uid);
                                if(uid!=null){
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    email.setTargetObjectId(uid);
                                    email.setWhatId(newCR.Id);
                                    email.setTemplateId(requestReclassifiedTemplate.Id);

                                    String accountName = objMap.get(newCR.EDM_Account_gne__c).Name;

                                    String prevClassif = oldCr.EDM_Type_of_Classification_gne__c == 'Clinical' ? oldCR.EDM_Clinical_Classification_gne__c : oldCR.EDM_Business_Classification_gne__c;
                                    String textBody = requestReclassifiedTemplate.Body;
                                    textBody = textBody.replace('{!relatedTo.EDM_Account_gne__r.Name}', accountName);
                                    textBody = textBody.replace('{!relatedTo.EDM_Type_of_Classification_gne__c}', newCR.EDM_Type_of_Classification_gne__c);
                                    textBody = textBody.replace('{!relatedTo.EDM_Action_Taken_gne__c}', newCR.EDM_Action_Taken_gne__c);
                                    textBody = textBody.replace('#EDM_Previous_Classification_gne__c', prevClassif != null ? prevClassif : '');
                                    email.setPlainTextBody(textBody);

                                    String htmlBody = requestReclassifiedTemplate.HtmlValue;
                                    htmlBody = htmlBody.replace('{!relatedTo.EDM_Account_gne__r.Name}', accountName);
                                    htmlBody = htmlBody.replace('{!relatedTo.EDM_Type_of_Classification_gne__c}', newCR.EDM_Type_of_Classification_gne__c);
                                    htmlBody = htmlBody.replace('{!relatedTo.EDM_Action_Taken_gne__c}', newCR.EDM_Action_Taken_gne__c);
                                    htmlBody = htmlBody.replace('#EDM_Previous_Classification_gne__c', prevClassif != null ? prevClassif : '');
                                    email.setHtmlBody(htmlBody);
                                    email.setSaveAsActivity(false);
                                    email.setOrgWideEmailAddressId(owa.Id);
                                    email.setSubject('Account has been Re-Classified');
                                    emails.add(email);
                                }
                            }
                        }

                        if (isReviewExitingClassificationRequestMode(oldCR, newCR)) {
                            if (newCR.EDM_Action_Taken_gne__c != 'Decline To Classify') {
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setTargetObjectId(newCR.EDM_Requestor_gne__c);
                                //System.debug('###NDTC-EMAIL: '+newCR.EDM_Requestor_gne__c);
                                email.setWhatId(newCR.Id);
                                email.setTemplateId(requestResultTemplate);
                                email.setSaveAsActivity(false);
                                email.setOrgWideEmailAddressId(owa.Id);
                                emails.add(email);
                            } else if (newCR.EDM_Action_Taken_gne__c == 'Decline To Classify') {
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setTargetObjectId(newCR.EDM_Requestor_gne__c);
                                //System.debug('###DTC-EMAIL: '+newCR.EDM_Requestor_gne__c);
                                email.setWhatId(newCR.Id);
                                email.setTemplateId(requestDeclinedTemplate);
                                email.setSaveAsActivity(false);
                                email.setOrgWideEmailAddressId(owa.Id);
                                emails.add(email);
                            }
                        }
                    }
                }
            }
            /*Code for new requests was moved to allow send attachments lesser than 3MB*/
            if(newRequests.size()>0){
                List<Attachment> attachments = new List<Attachment>([Select Id, ParentId, Body, BodyLength, ContentType, Name From Attachment Where ParentId in :newRequestsIds]);
                
                for(EDM_Classification_Request_gne__c newCr :newRequests){
                    if(recType.get(newCR.RecordTypeId).Name == 'Clinical'){

                        List<User> clinicalReviewers = reviewers.getReviewersByMedicalUnit(newCR.EDM_Medical_Unit_gne__c);
                         
                        if(!clinicalReviewers.isEmpty()){
                            for(User u : clinicalReviewers){ 
                                List<Messaging.EmailFileAttachment> atList = EDM_Classification_Utils.objectAttachments(newCR.Id,attachments);
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                                email.setTargetObjectId(u.Id);
                                //System.debug('###NR-EMAIL: '+u.Email);
                                email.setWhatId(newCR.Id);
                                email.setSaveAsActivity(false);
                                if(!atList.isEmpty()){
                                    email.setFileAttachments(atList);
                                    email.setTemplateId(newRequestEmailTemplate);
                                } else {
                                    email.setTemplateId(newRequestEmailTemplateAttLink);
                                }
                                emails.add(email);
                            }
                        } else {
                            if(!ClinicalDL.isEmpty()) {
                                List<Messaging.EmailFileAttachment> atList = EDM_Classification_Utils.objectAttachments(newCR.Id,attachments);
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                                    email.setTargetObjectId(ClinicalDL[0].Id);
                                    email.setWhatId(newCR.Id);
                                    email.setSaveAsActivity(false);
                                    if(!atList.isEmpty()){
                                        email.setFileAttachments(atList);
                                        email.setTemplateId(newRequestEmailTemplate);
                                    } else {
                                        email.setTemplateId(newRequestEmailTemplateAttLink);
                                    }
                                    emails.add(email);
                            }
                        }
                    } else if(recType.get(newCR.RecordTypeId).Name == 'Business') {
                        // pickup d-l address from contact and send email
                        if(!BusinessDL.isEmpty()){
                            List<Messaging.EmailFileAttachment> atList = EDM_Classification_Utils.objectAttachments(newCR.Id,attachments);
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                            email.setTargetObjectId(BusinessDL[0].Id);
                            email.setWhatId(newCR.Id);
                            email.setSaveAsActivity(false);
                            if(!atList.isEmpty()){
                                email.setFileAttachments(atList);
                                email.setTemplateId(newRequestEmailTemplate);
                            } else {
                                email.setTemplateId(newRequestEmailTemplateAttLink);
                            }
                            emails.add(email);
                        }
                    }
                }
            }
            //System.debug('###EMAILS: '+ emails);
            if(emails.size()>0){
                Messaging.sendEmail(emails);
            }
        }
    }

    private static Boolean isReviewExitingClassificationRequestMode(EDM_Classification_Request_gne__c oldCR, EDM_Classification_Request_gne__c newCR) {
        return oldCR.EDM_Status_gne__c == 'Pending' && newCR.EDM_Status_gne__c == 'Completed';
    }

    private static Boolean isUpdateClassificationMode(EDM_Classification_Request_gne__c oldCR, EDM_Classification_Request_gne__c newCR) {
        return oldCR.EDM_Status_gne__c == 'Completed' && newCR.EDM_Status_gne__c == 'Completed' && 
            String.isBlank(oldCR.EDM_Action_Taken_gne__c) && String.isNotBlank(newCR.EDM_Action_Taken_gne__c);
    }

    public static List<Id> getSBLList(List<Speaker_Bureau_Membership_gne__c> sbms,Id accId){
        List<Id> sbls = new List<Id>();
        System.debug('#SBMS#: '+sbms);
        for(Speaker_Bureau_Membership_gne__c sbm : sbms){
            if(sbm.Bureau_Member_gne__c==accId){
                sbls.add(sbm.Speaker_Bureau_ID_gne__r.Speaker_Bureau_Lead_gne__c);
            }
        }
        return sbls;
    }

    private static Map<Id, Set<Id>> getABLsByAccountID(List<Id> accountsIdsInTrigger) {
        Map<Id, Set<Id>> ablsByAccountId = new Map<Id, Set<Id>>();
        List<EDM_Attendee_gne__c> attendees = [SELECT Id, EDM_Account_gne__c, EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__c
                                                FROM EDM_Attendee_gne__c
                                                WHERE EDM_Account_gne__c IN :accountsIdsInTrigger
                                                AND EDM_Parent_IABP_gne__r.EDM_Status_gne__c IN 
                                                            ('IABP Not Started', 'IABP In Progress', 'IABP Under Review', 'IABP Submitted for Approval',
                                                             'IABP Approved', 'Revising Approved IABP', 'Re-Reviewing Approved IABP')
                                                AND EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false];
        for (EDM_Attendee_gne__c att : attendees) {
            if (!ablsByAccountId.containsKey(att.EDM_Account_gne__c)) {
                ablsByAccountId.put(att.EDM_Account_gne__c, new Set<Id>());
            }
            ablsByAccountId.get(att.EDM_Account_gne__c).add(att.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__c);
        }

        return ablsByAccountId;
    }

    public class Reviewers {
        private Map<String, List<User>> muToUsers;
        private List<User> allListedUsers;

        public Reviewers() {
            initMuToUser();
        }

        private void initMuToUser() {
            List<EDM_MU_to_User_gne__c> muToUsersList = [SELECT Group_gne__c, User_External_ID_gne__c FROM EDM_MU_to_User_gne__c];
            Map<String, User> usersByExternalId = getUsersByExternalId(muToUsersList);

            muToUsers = new Map<String, List<User>>();

            for (EDM_MU_to_User_gne__c muToUser : muToUsersList) {
                User u = usersByExternalId.get(muToUser.User_External_ID_gne__c);
                if (u != null) {
                    if (!muToUsers.containsKey(muToUser.Group_gne__c.toUpperCase())) {
                        muToUsers.put(muToUser.Group_gne__c.toUpperCase(), new List<User>());
                    }

                    muToUsers.get(muToUser.Group_gne__c.toUpperCase()).add(u);
                }
            }
        }

        private Map<String, User> getUsersByExternalId(List<EDM_MU_to_User_gne__c> muToUsers) {
            Set<String> externalIds = new Set<String>();
            for (EDM_MU_to_User_gne__c muToUser : muToUsers) {
                externalIds.add(muToUser.User_External_ID_gne__c);
            }

            allListedUsers = [SELECT Id, Email, External_ID_gne__c FROM User where External_ID_gne__c in :externalIds];

            Map<String, User> results = new Map<String, User>();
            for (User u : allListedUsers) {
                results.put(u.External_ID_gne__c, u);
            }

            return results;
        }

        public List<User> getReviewersByMedicalUnit(String medicalUnit) {
            List<User> results = new List<User>();

            if(!String.isEmpty(medicalUnit) && muToUsers.containsKey(medicalUnit.toUpperCase())){

                results =  muToUsers.get(medicalUnit.toUpperCase());
            }
            System.debug('getRevierwersByMedicalUnit -> returning ' + results);
            return results;
        }

        public List<User> getAllReviewers() {
            System.debug('getAllReviewers -> returning ' + allListedUsers);
            return new List<User>(allListedUsers);
        }
    }
}