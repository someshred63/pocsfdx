public class EDM_Classification_Request_Reminder{

    //final String REMINDER_TEMPLATE_API = 'EDM_Classification_Request_Reminder';
    final String REMINDER_TEMPLATE_ATTLINK_API = 'EDM_Classification_Req_Reminder_AttLink';
    final String REMINDER_TEMPLATE_CONTACT_API = 'EDM_Classification_Request_Reminder_Cont';
    List<Actual_Working_Days_gne__c> workingDays;
    List<Attachment> attachments;

    public EDM_Classification_Request_Reminder(){
        EDM_Classification_Request_Email_Notif.Reviewers reviewers = new EDM_Classification_Request_Email_Notif.Reviewers();

        List<Actual_Working_Days_gne__c> today = [SELECT Date_gne__c FROM Actual_Working_Days_gne__c WHERE Date_gne__c=TODAY LIMIT 1];
        if(today.size()>0){
            workingDays = [SELECT Date_gne__c FROM Actual_Working_Days_gne__c WHERE Date_gne__c >= LAST_N_DAYS:30 AND Date_gne__c <=TODAY ORDER BY Date_gne__c ];
            List<EDM_Classification_Request_gne__c> classificationsToRemind = new List<EDM_Classification_Request_gne__c>();
            List<EDM_Classification_Request_gne__c> classifications = [SELECT id, CreatedDate, EDM_Pending_Days_gne__c, EDM_Account_Specialty_gne__c, EDM_Business_Role_gne__c, RecordType.Name
                                                                        FROM EDM_Classification_Request_gne__c 
                                                                        WHERE EDM_Status_gne__c IN (null, 'Pending')];
        
            List<Id> classificationsIds= new List<Id>();
            //Updates Pending days field on Classification request object and check if mail has to be sent
            for(EDM_Classification_Request_gne__c classification : classifications){
                Date dateOfRequest = Date.newinstance(classification.createddate.year(), classification.createddate.month(), classification.createddate.day());
                classification.EDM_Pending_Days_gne__c = EDM_Classification_Utils.workingDaysBetweenTwoDates(dateOfRequest,Date.today(),workingDays);
                if(classification.EDM_Pending_Days_gne__c == 5){
                    classificationsToRemind.add(classification);
                    classificationsIds.add(classification.Id);
                }
            }
            update classifications;

            /*Due to HeapSize Limit we won't send attachments, only links*/
            //Send mails to reviewers or managers
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            //Id requestReminderTemplate = [SELECT Id, Name FROM EmailTemplate WHERE developername = :REMINDER_TEMPLATE_API].Id;
            Id requestReminderAttLinkTemplate = [SELECT Id, Name FROM EmailTemplate WHERE developername = :REMINDER_TEMPLATE_ATTLINK_API].Id;
            Id requestReminderContactTemplate = [SELECT Id, Name FROM EmailTemplate WHERE developername = :REMINDER_TEMPLATE_CONTACT_API].Id;


            Id distributionContactId;
            Id businessContactId;
            Id clinicalContactId;
            List<Contact> distributionLists = [SELECT Id, Name, LastName FROM Contact WHERE Name IN ('ClinicalClassificationDL', 'BusinessClassificationDL') OR LastName = 'Classification Request'];
            for(Contact c :distributionLists){
                if(c.Name == 'ClinicalClassificationDL'){
                    clinicalContactId = c.Id;
                } else if (c.Name == 'BusinessClassificationDL') {
                    businessContactId = c.Id;
                } else if (c.LastName == 'Classification Request'){
                    distributionContactId = c.Id;
                }
            }

            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Classification Requests'];
            Id owaId;
            if (owea.size() > 0) {
                owaId = owea[0].Id;
            }

            for(EDM_Classification_Request_gne__c classification : classificationsToRemind){
            
                if(classification.RecordType.Name == 'Clinical'){
                    List<User> clinicalReviewers = reviewers.getReviewersByMedicalUnit(classification.EDM_Medical_Unit_gne__c);
                    if(!clinicalReviewers.isEmpty()){
                        for(User u : clinicalReviewers){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setTargetObjectId(u.Id);
                            email.setWhatId(classification.Id);
                            email.setSaveAsActivity(false);
                            email.setTemplateId(requestReminderAttLinkTemplate);
                            if(owaId != null){
                                email.setOrgWideEmailAddressId(owaId);
                            }
                            emails.add(email);
                        }
                    } else if (clinicalContactId != null && requestReminderContactTemplate != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(clinicalContactId);
                        email.setWhatId(classification.Id);                        
                        email.setSaveAsActivity(false);
                        email.setTemplateId(requestReminderContactTemplate);
                        if(owaId != null){
                            email.setOrgWideEmailAddressId(owaId);
                        }
                        emails.add(email);
                    }
                } else {
                    List<User> bussinessReviewers = reviewers.getReviewersByMedicalUnit(classification.EDM_Medical_Unit_gne__c);
                    if(!bussinessReviewers.isEmpty()){
                        for(User u : bussinessReviewers){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setTargetObjectId(u.Id);
                            email.setWhatId(classification.Id);
                            email.setSaveAsActivity(false);
                            email.setTemplateId(requestReminderAttLinkTemplate);
                            if(owaId != null){
                                email.setOrgWideEmailAddressId(owaId);
                            }
                            emails.add(email);
                        }
                    } else if (businessContactId != null && requestReminderContactTemplate != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(businessContactId);
                        email.setWhatId(classification.Id);                        
                        email.setSaveAsActivity(false);
                        email.setTemplateId(requestReminderContactTemplate);
                        if(owaId != null){
                            email.setOrgWideEmailAddressId(owaId);
                        }
                        emails.add(email);
                    }
                }
                //distribution list:
                if (distributionContactId != null && requestReminderContactTemplate != null && owaId != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(distributionContactId);
                    email.setWhatId(classification.Id);
                    email.setSaveAsActivity(false);
                    email.setTemplateId(requestReminderContactTemplate);
                    email.setOrgWideEmailAddressId(owaId);
                    emails.add(email);
                }
            }

            if(emails.size()>0){
                Messaging.sendEmail(emails);
            } 
        }
    }
}