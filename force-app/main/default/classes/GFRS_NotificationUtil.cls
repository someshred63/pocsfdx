/**
 * Created by pawlowsl on 2017-08-21.
 */

public with sharing class GFRS_NotificationUtil {

    private static GFRS_OrgSettings__c orgSettings;

    private static Object getPropertyValue(Schema.SObjectField fld) {
        if(orgSettings == null)
            orgSettings = GFRS_OrgSettings__c.getOrgDefaults();
        return orgSettings.get(String.valueOf(fld));
    }

    private static String getPropertyStringValue(Schema.SObjectField fld) {
        return (String)getPropertyValue(fld);
    }

    private static List<OrgWideEmailAddress> owea;

    private static String senderDisplayName;

    private static String gfrsCommunicationEmail;

    private static Id gfrsCommunicationContactId;

    private static List<Messaging.SingleEmailMessage> emailsCache;

    public static String getGFRSCommunicationEmail() {
        if(gfrsCommunicationEmail==null) {
            gfrsCommunicationEmail = getPropertyStringValue(GFRS_OrgSettings__c.gFRS_Inbound_Email__c);
        }
        return gfrsCommunicationEmail;
    }

    public static Id getGFRSCommunicationContactId() {
        if(gfrsCommunicationContactId==null) {
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Email != NULL LIMIT 1];
            gfrsCommunicationContactId = contacts.size() > 0? contacts[0].Id : null;
        }
        return gfrsCommunicationContactId;
    }

    public static OrgWideEmailAddress getOWEA() {
        if(owea==null) {
            String oweaAddress = getPropertyStringValue(GFRS_OrgSettings__c.Org_Wide_Email_Address__c);
            owea = String.isNotBlank(oweaAddress) ? [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :oweaAddress] : new List<OrgWideEmailAddress>();
        }

        return !owea.isEmpty() ? owea[0] : null;
    }

    public static String getSenderDisplayName() {
        if(senderDisplayName==null) {
            senderDisplayName = getPropertyStringValue(GFRS_OrgSettings__c.Notification_Sender_Display_Name__c);
        }
        return senderDisplayName;
    }

    public static Messaging.SingleEmailMessage prepareEmailMessage(Id whoId, Id whatId, String emailTemplateName,
        Messaging.SingleEmailMessage messageToOverride) {

        return prepareEmailMessage(whoId, whatId, null, emailTemplateName, true, messageToOverride);
    }

    public static Messaging.SingleEmailMessage prepareEmailMessage(Id whoId, Id whatId, List<String> toAddresses, String emailTemplateName,
        Boolean useTemplateId, Messaging.SingleEmailMessage messageToOverride) {

        return prepareEmailMessage(whoId, whatId, toAddresses, emailTemplateName, null, useTemplateId, messageToOverride);
    }

    public static Messaging.SingleEmailMessage prepareEmailMessage(Id whoId, Id whatId, List<String> toAddresses, String emailTemplateName, Map<String,Object> mergedFields,
        Boolean useTemplateId, Messaging.SingleEmailMessage messageToOverride) {

        return prepareEmailMessage(whoId, whatId, toAddresses, null, null, emailTemplateName, mergedFields, useTemplateId, messageToOverride);
    }

    public static Messaging.SingleEmailMessage prepareEmailMessage(Id whoId, Id whatId, List<String> toAddresses, List<String> ccAddresses,
        List<String> bccAddresses, String emailTemplateName, Map<String,Object> mergedFields, Boolean useTemplateId, Messaging.SingleEmailMessage messageToOverride) {

        EmailTemplate eTemplate = getEmailTemplate(emailTemplateName);
        if (eTemplate == null) return null;

        Messaging.SingleEmailMessage mail = messageToOverride == null? new Messaging.SingleEmailMessage() : messageToOverride;
        mail.setTargetObjectId(whoId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTargetObjectId(whoId);

        if(useTemplateId) {
            mail.setTemplateId(eTemplate.Id);
            mail.setWhatId(whatId);
        } else {
            mail.setTemplateId(null);
            mail.setWhatId(null);

            if(mail.getSubject() == null && mail.getHTMLBody() == null && mail.getPlainTextBody() == null) {
                mail.setSubject(eTemplate.Subject);
                mail.setPlainTextBody(eTemplate.Body);
                mail.setHtmlBody(eTemplate.HtmlValue);
            }
        }

        if(mergedFields != null)
            mail = mergeEmailMessage(mail, mergedFields);

        if(toAddresses!=null && !toAddresses.isEmpty()) {
            mail.setToAddresses(toAddresses);
            mail.setTreatTargetObjectAsRecipient(false);
        }

        if(ccAddresses!=null && !ccAddresses.isEmpty()) {
            mail.setCcAddresses(ccAddresses);
        }

        if(bccAddresses!=null && !bccAddresses.isEmpty()) {
            mail.setBccAddresses(bccAddresses);
        }
        
        if(getOWEA()!=null) {
            mail.setOrgWideEmailAddressId(getOWEA().Id);
        } else if(getSenderDisplayName()!=null) {
            mail.setSenderDisplayName(getSenderDisplayName());
        }

        if(messageToOverride == null)
            getEmailsCache().add(mail);
        return mail;
    }

    public static Messaging.SingleEmailMessage prepareEmailMessage(Id whoId, Id whatId, String emailTemplateName) {

        EmailTemplate eTemplate = getEmailTemplate(emailTemplateName);
        if (eTemplate == null) return null;

        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(eTemplate.Id, whoId, whatId);
        mail.setSaveAsActivity(false);

        getEmailsCache().add(mail);

        return mail;
    }

    private static Messaging.SingleEmailMessage mergeEmailMessage(Messaging.SingleEmailMessage mail,  Map<String,Object> mergedFields) {
        String subject = mail.getSubject();
        String htmlBody = mail.getHTMLBody();
        String plainTextBody = mail.getPlainTextBody();

        subject = mergedFields!=null && subject!=null ? fetchMergeFields(subject, mergedFields) : subject;
        mail.setSubject(subject);
        htmlBody = mergedFields!=null && htmlBody != null ? fetchMergeFields(htmlBody, mergedFields) : htmlBody;
        if(htmlBody != null) {
            mail.setHtmlBody(htmlBody);
        }
        plainTextBody = mergedFields!=null && plainTextBody != null ? fetchMergeFields(plainTextBody, mergedFields) : plainTextBody;
        if(plainTextBody != null) {
            mail.setPlainTextBody(plainTextBody);
        }
        return mail;
    }

    @TestVisible
    private static List<Messaging.SingleEmailMessage> getEmailsCache() {
        if(emailsCache==null) {
            emailsCache = new List<Messaging.SingleEmailMessage>();
        }

        return emailsCache;
    }

    public static List<Messaging.SendEmailResult> sendNotifications() {
        return sendNotifications(true);
    }

    public static List<Messaging.SendEmailResult> sendNotifications(Boolean clearMessages) {
        List<Messaging.SendEmailResult> dmlResults = null;

        if(!getEmailsCache().isEmpty()) {

            dmlResults = Messaging.sendEmail(getEmailsCache(), false);
            System.debug(LoggingLevel.ERROR, dmlResults);
            if(clearMessages)
                getEmailsCache().clear();
        }

        return dmlResults;
    }

    public static String fetchMergeFields(String text, Map<String,Object> mergeFieldValues) {
        String result = text;

        for(String mergeField : mergeFieldValues.keySet()) {
            Object val = mergeFieldValues.get(mergeField);
            result = result.replaceAll('\\{\\{' + mergeField + '\\}\\}', val!=null ? formatMergeField(val) : '');
        }

        return result;
    }

    private static String formatMergeField(Object val) {
        return val instanceof Date ? DateTime.newInstance(((Date)val).year(), ((Date)val).month(), ((Date)val).day()).format('dd-MMM-yyyy'):
            val instanceof DateTime ? ((DateTime)val).format('dd-MMM-yyyy') :
                val instanceof Decimal ? ((Decimal)val).format() :
                    String.valueOf(val);
    }

    private static Map<String, EmailTemplate> emailTemplatesMap;

    private static EmailTemplate getEmailTemplate(String emailTemplateName) {
        if(emailTemplatesMap == null || !emailTemplatesMap.containsKey(emailTemplateName)) {
            if(emailTemplatesMap == null)
                emailTemplatesMap = new Map<String, EmailTemplate>();
            List<EmailTemplate> eTemplates = emailTemplateName != null? [SELECT Id, DeveloperName, Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplateName] : null;
            if(eTemplates.size() > 0) {
                emailTemplatesMap.put(emailTemplateName, eTemplates[0]);
            }
        }
        return emailTemplatesMap.containsKey(emailTemplateName)? emailTemplatesMap.get(emailTemplateName) : null;
    }
}