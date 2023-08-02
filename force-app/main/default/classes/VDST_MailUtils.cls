/** @date 7/27/2013
* @Author Paweł Sprysak
* @description Mail Util class
*/
public without sharing class VDST_MailUtils {
    private static final String RESET_PASSWORD_EMAIL_SUBJECT = 'Your Genentech Online account password reset link';
    private static final String SET_PASSWORD_EMAIL_SUBJECT = 'Your Genentech Online account password set link';
    private static final String RESET_PASSWORD_PAGE_URL = 'VDST_ManageAccount';
    private static final Integer HASH_VALID_DAYS = 200;

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Send create password email method
    * @param String vdstUserDetailsId
    * @return String
    */
    public static String sendCreatePasswordEmail(String vdstUserDetailsId) {
        VDST_UserDetails_gne__c vdstUser = [SELECT Id, Hash_gne__c, User_gne__c, User_gne__r.username, User_gne__r.firstName, User_gne__r.lastName, User_gne__r.email FROM VDST_UserDetails_gne__c where User_gne__c =: vdstUserDetailsId];
        system.debug('Sending create email to user email: ' + vdstUser.User_gne__r.username);
        String hash = vdstUser.Hash_gne__c;
        String message;
        Messaging.SendEmailResult err;

        if (vdstUser != null) {
            message = '<p>Dear ';
            message += vdstUser.User_gne__r.FirstName + ' ' + vdstUser.User_gne__r.LastName;
            message += '</p><p>Please click on the following link to set your Genentech Online account password:</p><p><a href="';
            message += getSite('VDST_Login').getUrl()+'/'+RESET_PASSWORD_PAGE_URL+'?userId='+vdstUser.id+'&hash='+hash;
            message += '">Set your password link</a></p><p>Your Genentech is '+vdstUser.User_gne__r.username+'</p><p>Please set your password within 7 calendar days of receiving this message, after which the link will expire.</p><p>Thank you,<br/>Genentech</p>';

            err = sendEmail(vdstUser.User_gne__r.Email, '', SET_PASSWORD_EMAIL_SUBJECT, message);
        }
        if(err.isSuccess()) {
            system.debug('Email successfully send to: ' + vdstUser.User_gne__r.username);
            return null;
        } else {
            system.debug('Email NOT send: ' + err);
            return 'Email NOT send: ' + err;
        }
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Send reset password email method
    * @param String vdstUserDetailsId
    * @return String
    */
    public static String sendResetPasswordEmail(String vdstUserDetailsId) {
        VDST_UserDetails_gne__c vdstUser = [SELECT Id, User_gne__c, User_gne__r.username, User_gne__r.firstName, User_gne__r.lastName, User_gne__r.email FROM VDST_UserDetails_gne__c where User_gne__c =: vdstUserDetailsId];

        system.debug('Sending reset email to user email: ' + vdstUser.User_gne__r.username);
        String hash = generateActivationHash(100);
        String message;
        Messaging.SendEmailResult err;

        if (vdstUser != null) {
            message = '<p>Dear ';
            message += vdstUser.User_gne__r.FirstName + ' ' + vdstUser.User_gne__r.LastName;
            message += '</p><p>Please click on the following link to reset your Genentech Online account password:</p><p><a href="';
            message += getSite('VDST_Login').getUrl()+'/'+RESET_PASSWORD_PAGE_URL+'?userId='+vdstUser.id+'&hash='+hash;
            message += '">Reset your password link</a></p><p>Please reset your password within 7 calendar days of receiving this message, after which the link will expire.</p><p>Thank you,<br/>Genentech</p>';

            err = sendEmail(vdstUser.User_gne__r.Email, '', RESET_PASSWORD_EMAIL_SUBJECT, message);

            vdstUser.Hash_gne__c = hash;
            vdstUser.Hash_Valid_Until_gne__c = Date.today().addDays(HASH_VALID_DAYS);
            update vdstUser;
        }
        if(err.isSuccess()) {
            system.debug('Email successfully send to: ' + vdstUser.User_gne__r.username);
            return null;
        } else {
            system.debug('Email NOT send: ' + err);
            return 'Email NOT send: ' + err;
        }
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Get site by name
    * @param String name
    * @return PageReference
    */
    public static PageReference getSite(String name) {
        String domain;//  = 'http://gene.dev.cs12.force.com';
        if(Site.getDomain() == null) {
            domain = VDST_Utils.getCustomSettings().Site_Domain__c;
        } else {
            domain = VDST_Utils.getCustomSettingsInSite().Site_Domain__c;
        }

        Site s = [SELECT status, subdomain, urlPathPrefix FROM Site where name = :name][0];
        PageReference pr = new PageReference(domain + '/' + s.urlPathPrefix);
        System.debug('Site URL created: '+pr.getUrl());
        return pr;
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Send email method
    * @param String emailAddress
    * @param String senderDisplayName
    * @param String subject
    * @param String messageHtmlBody
    * @return Messaging.SendEmailResult
    */
    public static Messaging.SendEmailResult sendEmail(String emailAddress, String senderDisplayName, String subject, String messageHtmlBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {emailAddress};
        mail.setToAddresses(toAddress);
        mail.setSenderDisplayName(senderDisplayName);
        mail.setSubject(subject);
        mail.setHtmlBody(messageHtmlBody);
        return Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail})[0];
    }

    /** @date 7/27/2013
    * @Author Paweł Sprysak
    * @description Generate activation hash method
    * @param Integer length
    * @return Messaging.SendEmailResult
    */
    public static String generateActivationHash(Integer length) {
        String[] chars = new String[] { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };
        String hash = '';
        for (Integer i = 0; i < length; i++) {
            Integer index = null;
            Boolean isLowercase = false;
            do {
                index = Math.round(Math.random() * chars.size());
                isLowercase = Math.random() < 0.5;
            }
            while (index > (chars.size() - 1));

            hash += isLowercase ? chars[index].toLowerCase() : chars[index];
        }
        return hash;
    }
}