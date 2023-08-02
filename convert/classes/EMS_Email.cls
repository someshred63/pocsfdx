public without sharing class EMS_Email {
    private static final string FOLDER_DEVELOPER_NAME = 'EMS_Canada_Email_Templates';
    private static final string SENDER_DISPLAY_NAME = 'Event Management System';

    private static Folder emsTemplateFolder {
        get {
            if (emsTemplateFolder == null) {
                List<Folder> folderList = [SELECT Id FROM Folder WHERE DeveloperName = :FOLDER_DEVELOPER_NAME];
                if (folderList.size() == 1) {
                    emsTemplateFolder = folderList.get(0);
                } else {
                    throw new EMSTemplateException('"EMS Canada Email Templates" folder does not exist');
                }
            }
            return emsTemplateFolder;
        }
    }

    private static Map<String, EmailTemplate> emsEmailTemplates {
        get {
            if (emsEmailTemplates == null) {
                emsEmailTemplates = new Map<String, EmailTemplate>();
                for (EmailTemplate tmp : [SELECT Id, DeveloperName, Name FROM EmailTemplate WHERE FolderId = :emsTemplateFolder.Id]) {
                    emsEmailTemplates.put(tmp.DeveloperName, tmp);
                    emsEmailTemplates.put(tmp.Name, tmp);
                    emsEmailTemplates.put(tmp.Id, tmp);
                }
            }
            return emsEmailTemplates;
        }
    }

    public static Id getTemplateID(String tName) {
        Id tID = null;
        if (emsEmailTemplates.containsKey(tName)) {
            tID = emsEmailTemplates.get(tName).Id;
        }
        if (tID == null) {
            throw new EMSTemplateException('Template has not been found');
        }
        return tID;
    }

    private static List<Messaging.SingleEmailMessage> singleEmails {
        get {
            if (singleEmails == null) {
                singleEmails = new List<Messaging.SingleEmailMessage>();
            }
            return singleEmails;
        }
    }

    private static void setSingleEamils(Messaging.SingleEmailMessage email) {
        singleEmails.add(email);
    }

    private static Messaging.SingleEmailMessage getEmail() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSaveAsActivity(false);
        email.setSenderDisplayName(SENDER_DISPLAY_NAME);
        return email;
    }

    public static void prepareSingleEmail(String tempName, Id whatID, Id targetObjID) {
        if (String.isBlank(tempName) || String.isBlank(whatID) || String.isBlank(targetObjID)) {
            return;
        }

        Messaging.SingleEmailMessage singleEmail = EMS_Email.getEmail();
        singleEmail.setTemplateId(getTemplateID(tempName));
        singleEmail.setWhatId(whatID);
        singleEmail.setTargetObjectId(targetObjID);

        setSingleEamils(singleEmail);
    }

    public static void prepareSingleEmail(String tempName, Id whatID, List<String> additAddresses) {
        if (String.isBlank(tempName) || String.isBlank(whatID) || additAddresses.isEmpty()) {
            return;
        }

        Messaging.SingleEmailMessage singleEmail = EMS_Email.getEmail();
        singleEmail.setTemplateId(getTemplateID(tempName));
        singleEmail.setWhatId(whatID);
        singleEmail.setTargetObjectId(UserInfo.getUserId()); // Doesn't matter what id is stored here, email will be send to "additAddresses"
        singleEmail.setToAddresses(additAddresses);
        singleEmail.setTreatTargetObjectAsRecipient(false);

        setSingleEamils(singleEmail);
    }
    
    public static void prepareSingleEmail(String tempName, Id whatID, List<String> additAddresses, Messaging.EmailFileAttachment attachment) {
        if (String.isBlank(tempName) || String.isBlank(whatID) || additAddresses.isEmpty() || attachment == null) {
            return;
        }

        Messaging.SingleEmailMessage singleEmail = EMS_Email.getEmail();
        singleEmail.setTemplateId(getTemplateID(tempName));
        singleEmail.setWhatId(whatID);
        singleEmail.setTargetObjectId(UserInfo.getUserId()); // Doesn't matter what id is stored here, email will be send to "additAddresses"
        singleEmail.setToAddresses(additAddresses);
        singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
        singleEmail.setTreatTargetObjectAsRecipient(false);

        setSingleEamils(singleEmail);
    }

    public static List<Messaging.SendEmailResult> send() {
        List<Messaging.SendEmailResult> mailResults = null;
        if (singleEmails == null || singleEmails.isEmpty()) {
            System.debug(LoggingLevel.INFO, '### No Emails were sent');
        } else {
            System.debug(LoggingLevel.INFO, '### Amount of emails to be sent is ' + singleEmails.size());
            for (Messaging.SingleEmailMessage sm: singleEmails) {
                System.debug(LoggingLevel.ERROR, '### sm ' + sm);
            }
            mailResults = Messaging.sendEmail(singleEmails, true);
            for (Messaging.SendEmailResult m :mailResults) {
                if (m.isSuccess() == false) {
                    System.debug(LoggingLevel.ERROR, '### Sending email error: ' + m);
                }
            }
            singleEmails.clear();
        }
        return mailResults;
    }

    public class EMSTemplateException extends Exception {
    }
}