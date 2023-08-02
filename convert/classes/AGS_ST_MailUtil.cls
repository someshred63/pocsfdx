public without sharing class AGS_ST_MailUtil
{
	private static final String RESET_PASSWORD_EMAIL_SUBJECT = 'Sunshine Track Password Reset';
    private static final String RESET_PASSWORD_PAGE_URL = 'AGS_ST_ResetPassword_gne';

    public static AGS_ST_LoginController_gne.StatusMessage sendResetPasswordEmail(AGS_ST_User_gne__c physician, Boolean sendFromInternal)
    {
        AGS_ST_LoginController_gne.StatusMessage sm = new AGS_ST_LoginController_gne.StatusMessage();

        String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();
        String oweaAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
        //System.debug('---------------- customSettings ' + AGS_ST_Utils.getCustomSettingsIntExt());
        //System.debug('------------ oweaID = ' + oweaId);
        //system.debug('Sending reset email to user email: ' + physician.SFDC_User__r.username);
        String hash = generateActivationHash(100);
        String message;
        Messaging.SendEmailResult err;

        if (physician != null)
        {
            message = 'Dear Dr. ' + physician.Last_name__c + ',<br/><br/>';
            message += 'Please click the following link to reset your Sunshine Track account password: <a href="';
            if(sendFromInternal != true)
                message += AGS_ST_DbUtils.getSite('AGS_ST_Login_Site_gne').getUrl()+'/'+RESET_PASSWORD_PAGE_URL+'?agsStUserId='+physician.id+'&hash='+hash;
            else
                message += AGS_ST_Utils.getDefaultCustomSettings().Site_Domain_gne__c +'/SunshineTrackLogin/'+RESET_PASSWORD_PAGE_URL+'?agsStUserId='+physician.id+'&hash='+hash;
            message += '">Reset your password link</a><br/><br/>';
            Boolean isMPSusr = false;
            Boolean isLWOusr = false;
            GNE_CM_IHCP_User__c ihcpUsr = AGS_ST_DbUtils.getIHCPUser(physician.SFDC_User__c);
            if (ihcpUsr != null)
            {
                if(ihcpUsr.MPS_Status__c =='Approved')
                {
                    isMPSusr = true;
                }
                if(ihcpUsr.LWO_Status__c =='Approved')
                {
                    isLWOusr = true;
                }
            }
            if(isMPSusr || isLWOusr)
                message += '<b>Please note: your password is shared among other Genentech applications (LWO, MPS) so changing your Sunshine Track password will also change your LWO and/or MPS password.</b><br/><br/>';

            message += 'Please reset your password within 7 calendar days of receiving this message, after which the link will expire. If that occurs, or if you have any questions, please contact the Genentech Sunshine Help Desk at <a href="mailto:'+oweaAddress+'">'+oweaAddress+'</a> or (877) 313-5778 between 8am and 5pm Pacific Time, Monday through Friday.<br/><br/>Thank you,<br/>The Genentech Sunshine Help Desk Team<br/>';

            String userName = physician.SFDC_User__r.username;
            String envSufix = AGS_ST_Utils.getEnvNameForUsername(userName);
            if(!String.isBlank(envSufix))
            	userName = userName.removeEnd('.' + envSufix);
            err = sendEmail(userName, 'Genentech Sunshine Help Desk', RESET_PASSWORD_EMAIL_SUBJECT, message, oweaId);

            physician.Activation_Hash_Number__c = hash;
            physician.Reset_Password_Email_Sent_Date__c = System.now();
            update physician;
        } else {
            sm.status = 'Failure';
            sm.message = 'Account with provided email may not exist.';
            return sm;
        }

        if(err.isSuccess())
        {
            sm.status = 'Success';
            sm.message ='Email successfully send to: ' + physician.SFDC_User__r.username;
            system.debug('Email successfully send to: ' + physician.SFDC_User__r.username);
        }
        else
        {
            sm.status = 'Failure';
            sm.message = 'Email NOT send: ' + err;
            system.debug('Email NOT send: ' + err);
        }
        return sm;
    }

    public static String sendUserActivationEmail(Id agsStUserId)
    {
        System.debug('sendUserActivationEmail('+agsStUserId+')');
        AGS_ST_User_gne__c physician = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
        if(physician == null)
        {
            system.debug('Physician not found(no email sent): ' + agsStUserId);
            return '';
        }
        system.debug('Sending reset email to user email: ' + physician.Email_address__c);
        String hash = generateActivationHash(100);
        String activationUrl;
        if (physician != null)
        {
            activationUrl = AGS_ST_DbUtils.getSite('AGS_ST_Login_Site_gne').getUrl() + '/AGS_ST_User_Activation_gne?agsStUserId='+physician.id+'&hash='+hash;
            physician.Activation_Hash_Number__c = hash;
            update physician;
        }
        return activationUrl;
    }

    @future
    public static void sendAfterActivationEmail(String userId)
    {
        try
        {
        	String sunshineOrgWideAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
            System.debug('------------ userId' +userId );
            User usr = AGS_ST_DbUtils.findUserById(userId);
            //send email that user is succesfully activated like in GNE_CM_MPS_Activation_Controller line 184. with similar text
            String body = 'Dear Dr. ' + usr.lastname +',<br/><br/>';
            String PORTAL_ADDRESS_InSite = '';
            if(UserInfo.getUsername().contains('force.com'))
                PORTAL_ADDRESS_InSite  = 'https://' + UserInfo.getUsername().substring(UserInfo.getUsername().indexof('@')+1) + '/SunshineTrackLogin/AGS_ST_Login_gne';
            else
                PORTAL_ADDRESS_InSite  = AGS_ST_Utils.getCustomSettings().Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Login_gne';
            body += 'Thank you for activating your Genentech Sunshine Track account. Your user name is: ' + usr.Username + '. ';
            body += 'Sunshine Track can be accessed at <a href="'+PORTAL_ADDRESS_InSite+'">sunshine.gene.com</a>.<br/><br/>';
            body += 'If you have any questions, please contact the Genentech Sunshine Help Desk at <a href="mailto:'+sunshineOrgWideAddress+'">'+sunshineOrgWideAddress+'</a> or (877) 313-5778 between 8am and 5pm Pacific Time, Monday through Friday.<br/><br/>';
            body += 'Thank you,<br/>';
            body += 'The Genentech Sunshine Help Desk Team<br/>';
            System.debug('------------ PORTAL_ADDRESS_InSite ' +  PORTAL_ADDRESS_InSite);
            System.debug('------------ usr.Username sunshineOrgWideAddress ' + usr.Username + ' ' +sunshineOrgWideAddress);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[] {usr.Username, sunshineOrgWideAddress};
            mail.setToAddresses(toAddress );
            String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();
            if(!String.isBlank(oweaId))
        		mail.setOrgWideEmailAddressId(oweaId);
        	else
        		mail.setSenderDisplayName('SFDC Administrator');
            mail.setSubject('Sunshine Track Account Activation Confirmation');
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('#####Activation confirmation sent to \'' + mail + '\'');
        }
        catch (Exception e)
        {
            system.debug('---'+e.getmessage());
        }
    }

    public static void sendSettingSecurityQuestionsEmail(String userId, String linkVal)
    {
        try
        {
        	String sunshineOrgWideAddress = AGS_ST_Utils.getSunshineOrgWideAddress();

            User usr = AGS_ST_DbUtils.findUserById(userId);
            String body = 'Dear Dr. ' + usr.lastname +',<br/><br/>';

            body += 'Thank you for registering with Sunshine Track. Your user name is: ' + usr.Username + '.<br/><br/>';
            body += 'Please click <a href="'+linkVal+'">here</a> to complete your registration by creating your password and answers to security questions.<br/><br/>';
            body += 'If you have any questions, please contact the Genentech Sunshine Help Desk at <a href="mailto:'+sunshineOrgWideAddress+'">'+sunshineOrgWideAddress+'</a> or (877) 313-5778 between 8am and 5pm Pacific Time, Monday through Friday.<br/><br/>';
            body += 'Thank you,<br/>';
            body += 'The Genentech Sunshine Help Desk Team<br/>';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[] {usr.Username,sunshineOrgWideAddress};
            mail.setToAddresses(toAddress );
            String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();
            if(!String.isBlank(oweaId))
        		mail.setOrgWideEmailAddressId(oweaId);
        	else
        		mail.setSenderDisplayName('SFDC Administrator');
            mail.setSubject('Set Account Security Questions');
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('#####Security Questions link sent to \'' + mail + '\'');
        }
        catch (Exception e)
        {
            system.debug('---'+e.getmessage());
        }
    }

    public static void sendSaveDisputeEmail(AGS_ST_User_gne__c sunshineUser, String disputeName, String amount,String method,String reason,String brand, String hcpNote) {
    	String hcpName = sunshineUser.First_name__c + ' ' + sunshineUser.Last_name__c;
        String body = 'Dear Dr. '+ sunshineUser.Last_name__c +',<br/><br/>';
        body += 'We received the dispute you submitted on ' + Datetime.now().format('M/d/yyyy') + '. A member of the Genentech Sunshine Help Desk Team will respond to you within 2 business days.<br/><br/>';
        body += 'Dispute ID: '+disputeName+'<br/>';
        body += 'Here is the information/suggested value(s) you submitted:<br/>';
        if(amount != '' && amount != null)
        	body += 'Amount:$'+amount+'<br/>';
        if(method != '' && method != null)
        	body += 'Form of Payment:'+method+'<br/>';
        if(reason != '' && reason != null)
        	body += 'Nature of Payment:'+reason+'<br/>';
        if(brand != '' && brand != null)
        	body += 'Brand:'+brand+'<br/>';
        if(hcpNote != '' && hcpNote != null)
        	body += 'Dispute Note:'+hcpNote+'<br/>';
        body += '<br/>';
        body += 'Thank you,<br/>';
        body += 'The Genentech Sunshine Help Desk Team<br/>';
        String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {sunshineUser.Email_address__c};
        mail.setToAddresses(toAddress);
        if(!String.isBlank(oweaId))
        	mail.setOrgWideEmailAddressId(oweaId);
        else
        	mail.setSenderDisplayName('Genentech Sunshine Track Support');
        mail.setSubject('Dispute received - Dispute ID ' + disputeName);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public static void sendSaveDisputeNoteEmail(AGS_ST_User_gne__c sunshineUser, String disputeID, String noteTxt) {
    	String sunshineOrgWideAddress = AGS_ST_Utils.getSunshineOrgWideAddress();

    	String hcpName = sunshineUser.First_name__c + ' ' + sunshineUser.Last_name__c;
        String body = '<p>Dear CCO,</p>';
        body += '<p></p>';
        AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
        body += '<p>HCP '+hcpName+' sent a message about <a href="'+ stSetting.Domain_gne__c +'/'+disputeID+'">dispute</a> with following text:</p>';
        body += '<p>'+noteTxt+'</p>';
        body += '<p></p>';
        body += '<p>If you want to see user details click <a href="'+ stSetting.Domain_gne__c +'/'+sunshineUser.id+'">here</a>.</p>';
        body += '<p>Thank you</p>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {sunshineOrgWideAddress};
        mail.setToAddresses(toAddress);
        mail.setInReplyTo(UserInfo.getUserName());
        // email from hcp so we are not using org wide
        mail.setSenderDisplayName(hcpName);
        mail.setSubject('HCP message about dispute');
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public static void sendCallRequestEmail(String agsStUserId, String phoneNo, String prefferedDate, String prefferedTime) {
    	String sunshineOrgWideAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
        String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();

        AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
    	String body = '<p>Dear CCO,</p>';
        body += '<p></p>';
        body += '<p>HCP sent a request to contact him with following phone number: ' + phoneNo + '.</p>';
        if(prefferedDate != null)
            body += '<p>Preffered date to call him is: '+prefferedDate+'</p>';
        if(prefferedTime != null)
            body += '<p>Preffered time to call him is: '+prefferedTime+'</p>';
        if(agsStUserId!=null)
            body += '<p>Go to user details <a href="'+ stSetting.Domain_gne__c +'/'+agsStUserId+'">here</a> before you contact HCP.</p>';
        else
            body += '<p>There can be multiple reasons why the user is getting error - Page In Maintenance, Site bandwith limit exceeded, Authorization required or the page cannot be found. Please contact IT team to resolve the problem.</p>';
        body += '<p>Thank you,</p>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {sunshineOrgWideAddress};
        mail.setToAddresses(toAddress);
        if(!String.isBlank(oweaId))
        	mail.setOrgWideEmailAddressId(oweaId);
        else
        	mail.setSenderDisplayName('Genentech Sunshine Track Support');
        mail.setSubject('User contact request');
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public static void sendContactUsEmail(Boolean inPortal, String emailSubject, String emailBody, String hcpName, String hcpEmailAddress, AGS_ST_User_gne__c stUser) {
    	Id st_id;
        String body = '';
        emailBody = emailBody.replaceAll('\r','<br />').replaceAll('\n','<br />');
        AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
        if(inPortal)
        {
            st_id = stUser.id;
            hcpName = stUser.First_name__c + ' ' + stUser.Last_name__c;
            hcpEmailAddress = UserInfo.getUserName();
            body = '<p>'+emailBody+'</p>';
            body += '<p></p>';
            body += '<p>-------You can reply to this message. Before you reply remove the below statement.-------</p>';
            body += '<p>This HCP is a user of SunshineTrack. Go to user details <a href="'+ stSetting.Domain_gne__c +'/'+st_id+'">here</a> before you contact HCP.</p>';
        }
        else
        {
            body = '<p>HCP '+hcpName+' sent a email with following body: </p>';
            body += '<p>'+emailBody+'</p>';
            body += '<p>HCP\'s email is '+hcpEmailAddress+'</p>';
        }
        body += '<p>Thank you</p>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String sunshineAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
        String[] toAddress = new String[] {sunshineAddress};
        mail.setToAddresses(toAddress);
        mail.setInReplyTo(hcpEmailAddress);
        if(inPortal)
        	mail.setSenderDisplayName(hcpName);
        else
        	mail.setOrgWideEmailAddressId(AGS_ST_Utils.getSunshineOrgWideAddressID());
        mail.setSubject(emailSubject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public static Messaging.SendEmailResult sendEmail(String emailAddress, String senderDisplayName, String subject, String messageHtmlBody, String orgWideEmailId)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {emailAddress};
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);
        mail.setHtmlBody(messageHtmlBody);
        if(!String.isBlank(orgWideEmailId))
        	mail.setOrgWideEmailAddressId(orgWideEmailId);
        else
        	mail.setSenderDisplayName(senderDisplayName);

        return Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail})[0];
    }

    public static Messaging.SendEmailResult sendEmail(String emailAddress, String senderDisplayName, String subject, String messageHtmlBody)
    {
    	return sendEmail(emailAddress, senderDisplayName, subject, messageHtmlBody, null);
    }

    public static Messaging.SendEmailResult sendExternalEmail(AGS_ST_Email_Templates_gne template, String emailBody, String emailSubject, Messaging.EmailFileAttachment efa,AGS_ST_DisputeManagement_gne__c orgDispute,List<String> emailRecipients)
    {
    	String sunshineOrgWideAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
        String PORTAL_ADDRESS = AGS_ST_Utils.getCustomSettings().Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Login_gne';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {sunshineOrgWideAddress};
        toAddress.addAll(emailRecipients);
        String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();

        //OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Commercial Compliance Operations' LIMIT 1];
        if (oweaId != null) {
            mail.setOrgWideEmailAddressId(oweaId);
        }
        mail.setToAddresses(toAddress);
        //mail.setSenderDisplayName('Genentech Sunshine Support');
        if(template == null)
            mail.setSubject(emailSubject);
        else
            mail.setSubject(template.subject);
        emailBody =+ emailBody.replaceAll('\r\n','<br />');

        emailBody =+ emailBody.replace(orgDispute.Dispute_List_gne__r.Name,'<a href="'+PORTAL_ADDRESS+'/?url='+orgDispute.Dispute_List_gne__c+'">'+orgDispute.Dispute_List_gne__r.Name+'</a>');
        mail.setHtmlBody(emailBody);

        if(efa != null)
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        return Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail})[0];
    }

    public static String generateActivationHash(Integer length)
    {
        String[] chars = new String[] { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

        String hash = '';

        for (Integer i = 0; i < length; i++)
        {
            Integer index = null;
            Boolean isLowercase = false;
            do
            {
                index = Math.round(Math.random() * chars.size());
                isLowercase = Math.random() < 0.5;
            }
            while (index > (chars.size() - 1));

            hash += isLowercase ? chars[index].toLowerCase() : chars[index];
        }

        return hash;
    }

    private static List<String> getPortalNames(GNE_CM_IHCP_User__c ihcpUser) {
        // returns sorted portal names
        List<String> portalNames = new List<String>();
        if(ihcpUser.LWO_Status__c == 'Approved')
            portalNames.add('LWO');
        if(ihcpUser.AGS_ST_Status__c == 'Approved')
            portalNames.add('AGSST');
        if(ihcpUser.MPS_Status__c == 'Approved')
            portalNames.add('MPS');
        return portalNames;
    }

    @future
    public static void sendEmailAboutNewlyRegisteredUserWithDisputes(String agsStUserId) {
        AGS_ST_User_gne__c stUser = [
            SELECT  Id, Name, Mapped_Account_MDM_Id__c, Mapped_Account__c, Mapped_Account__r.FirstName, Mapped_Account__r.LastName
            FROM    AGS_ST_User_gne__c
            WHERE   Id = :agsStUserId
        ];
        if (stUser == null) {
            return;
        }
        String sunshineOrgWideAddress = AGS_ST_Utils.getSunshineOrgWideAddress();
        String stUserFirstName = (stUser.Mapped_Account__r.FirstName != null ? stUser.Mapped_Account__r.FirstName + ' ' : '');
        String stUserLastName = (stUser.Mapped_Account__r.LastName != null ? stUser.Mapped_Account__r.LastName : '');
        String stUserName = stUserFirstName + stUserLastName;
        String disputes = '';
        Boolean hasDisputes = false;
        if(stUser.Mapped_Account_MDM_Id__c == null) {
        	return;
        }
        for (AGS_ST_DisputeManagement_gne__c dm : [
            SELECT  Id, Name
            FROM    AGS_ST_DisputeManagement_gne__c
            WHERE   AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_MDM_ID_gne__c = :stUser.Mapped_Account_MDM_Id__c
                OR  AGS_Spend_Expense_Transaction_gne__r.Secondary_Recipient_MDM_ID_gne__c = :stUser.Mapped_Account_MDM_Id__c 
            ORDER BY Name
        ]) {
            disputes += dm.Name + '<br/>';
            hasDisputes = true;
        }

        if(!hasDisputes) {
            return;
        }

        String subject = 'New SST User with Dispute';
        String body = 'The below User has newly registered on Sunshine Track and has disputes associated to their account.<br/>';
        body += stUserName + '<br/>';
        body += stUser.Name + '<br/>';
        body += disputes;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses( new String[]{ sunshineOrgWideAddress } );
        mail.setInReplyTo( UserInfo.getUserName() );
        mail.setSenderDisplayName(stUserName);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
    }

    public static void sendEmailWithCorrectedPendingSsrDisputes(List<AGS_ST_DisputeManagement_gne__c> disputes) {
        String oweaId = AGS_ST_Utils.getSunshineOrgWideAddressID();
        String oweaAddress = AGS_ST_Utils.getSunshineOrgWideAddress();

        if( disputes.isEmpty() || String.isBlank(oweaId) || String.isBlank(oweaAddress)) {
            return;
        }

        String subject = 'Dispute status is Corrected Pending SSR for three (3) days or more.';
        String body = 'The below Dispute(s) have been in the status of Corrected Pending SSR for three (3) or more business days.<br/>';
        body += '<br/>';
        for(AGS_ST_DisputeManagement_gne__c d : disputes) {
            String owner = String.isBlank(d.Owner.Name) ? '' : d.Owner.Name;
            String resolver = String.isBlank(d.Dispute_Resolver_gne__r.Owner.Name) ? '' : d.Dispute_Resolver_gne__r.Owner.Name;
            body += d.Name + ': ' + owner + (String.isBlank(owner) || String.isBlank(resolver) ? '' : ', ') + resolver + '<br/>';
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses( new String[]{ oweaAddress } );
        mail.setInReplyTo( UserInfo.getUserName() );
        mail.setOrgWideEmailAddressId(oweaId);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
    }
}