/**
 * Misc utilities for MPS emails
 * @author Radek Krawiec
 *
 * Test classes: GNE_CM_MPS_Activation_Emails_Test
 */
public with sharing class GNE_CM_MPS_Email_Utils
{
    // TODO RK: get this page address from some custom setting
    private static final String ACTIVATION_PAGE_URL = 'GNE_CM_MPS_Activation';
    private static final String RESET_PASSWORD_PAGE_URL = 'GNE_CM_MPS_ResetPassword';
    private static final String PORTAL_ADDRESS = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Change_Profile_Site_URL__c;
    private static final String ACTIVATION_EMAIL_SUBJECT = 'Activate your My Patient Solutions Account';
    private static final String RESET_PASSWORD_EMAIL_SUBJECT = 'Your My Patient Solutions Account password reset link';
    private static final String CONFIRM_RESET_PASSWORD_EMAIL_SUBJECT = 'Your My Patient Solutions Account password reset confirmation';
    private static final String CONFIRM_SETTINGS_EMAIL_SUBJECT = 'Your My Patient Solutions Account Update';
    
    // contains params ${firstName}, ${link}, ${email}
    private static final String INITIAL_ACTIVATION_EMAIL_BODY = 'Hi ${name},</p><p>As a reminder, a My Patient Solutions account has been registered on your behalf.</p><p>Your account user name is ${email}.  To complete the account activation process, you will need to set up your secure password and answer challenge questions.</p><p><a href="${link}">Click here</a> to complete your registration.</p><p>You will receive reminder emails every week for four weeks until you complete the activation. If you do not complete the activation, or if you have any questions, please call Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions';
    // reminder email is the same as the initial activation email
    private static final String REMINDER_ACTIVATION_EMAIL_BODY = 'Hi ${name},</p><p>As a reminder, ${registeringUser} has requested a My Patient Solutions account on your behalf.</p><p>Your account user name is ${email}. To complete the account activation process, you will need to set up your secure password and answer challenge questions.</p><p><a href="${link}">Click here</a> to complete your registration.</p><p>You will have seven (7) days to complete the activation. If you do not complete the activation, or if you have any questions, please call Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions';
    //private static final String REMINDER_ACTIVATION_EMAIL_BODY = 'Hi ${name},</p><p>As a reminder, a My Patient Solutions account has been registered on your behalf.</p><p>Your account user name is ${email}.  To complete the account activation process, you will need to set up your secure password and answer challenge questions.</p><p><a href="${link}">Click here</a> to complete your registration.</p><p>You will receive reminder emails every week for four weeks until you complete the activation. If you do not complete the activation, or if you have any questions, please call Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions';
    private static final String CHALLENGE_ANSWERS_CHANGED_EMAIL_BODY = 'Dear ${name},</p><p>Your account challenge answers have been updated as per your request.  If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions';
    private static final String CHALLENGE_ANSWERS_CHANGED_SUBJECT = 'Your My Patient Solutions Account Update';
    private static final String RESET_PASSWORD_EMAIL_BODY = '<p>Dear ${name},</p><p>Please click on the following to reset your account password:</p><p><a href="${link}">Reset Your Password</a></p><p>Please reset your password within 7 calendar days of receiving this message, after which the link will expire.  If that occurs, or if you have any questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions</p>';
    private static final String CONFIRM_RESET_PASSWORD_EMAIL_BODY = '<p>Dear ${name},</p><p>Your account password has been updated as per your request.  If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions</p>';
    private static final String CONFIRM_PROFILE_SETTINGS_EMAIL_BODY = '<p>Dear ${name},</p><p> Your account profile has been updated as per your request. </p>First Name: ${fname}<br/>Last Name: ${lname}<br/>Phone: ${phone}<br/>Ext: ${ext}<br/>Email: ${email}<br/>Username: ${uname}<br/><p>If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions</p>';
    private static final String CONFIRM_PASSWORD_SETTINGS_EMAIL_BODY = '<p>Dear ${name},</p><p> Your account password has been updated as per your request. If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions</p>';
    private static final String CONFIRM_QUESTION_SETTINGS_EMAIL_BODY = '<p>Dear ${name},</p><p> Your account challenge answers have been updated as per your request. If you did not request this change, or if you have any further questions, please contact Genentech Access Solutions at (866) 4ACCESS/(866) 422-2377, 6am - 5pm PST, Monday through Friday.</p><p>Thank you,<br/>Genentech Access Solutions</p>';

    /**
     * Prepares activation emails to MPS users.
     * 
     * This method is made public to be used in unit tests.
     * 
     * Test class: GNE_CM_MPS_Activation_Emails_Test
     *
     * @param mpsUserIds - IDs of MPS users to which activation emails will be sent
     * @param updateStatus - tells if the Workflow_State__c field on the MPS user should be updated when the email is sent
     * @author Radek Krawiec
     * @created 07/17/2012
     */
    public static GNE_CM_MPS_Activation_Email_Bundle prepareActivationEmails (List<Id> mpsUserIds, Boolean updateStatus, Boolean isReminder)
    {
        if (mpsUserIds == null || mpsUserIds.isEmpty())
        {
            throw new GNE_CM_Exception('MPS User Id list passed to the method is null or empty');
        }
        
        // select MPS users by IDs
        List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id, Email_address__c, SFDC_User__c, SFDC_User__r.ContactId, SFDC_User__r.Username, Activation_Hash_Number__c, First_Name__c, Last_Name__c FROM GNE_CM_MPS_User__c WHERE Id IN :mpsUserIds];
        
        // list of MPS users that will be updated
        List<GNE_CM_MPS_User__c> updatedMpsUsers = new List<GNE_CM_MPS_User__c>();
        
        // list of emails to send
        Map <Id, Messaging.SingleEmailMessage> emailsByMpsUserId = new Map<Id, Messaging.SingleEmailMessage>();
        
        // get registering users mapped by MPS user ID
        Map<Id, String> registeringUsers = null;
        
        if (isReminder)
        {
            // registering users are only required for reminder e-mails
            registeringUsers = getRegisteringUsers(mpsUserIds);
        }
        
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers)
        {   
            if (updateStatus)
            {
                mpsUser.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
                
                // for reminder emails, hash and send date are not reset
                if (!isReminder)
                {
                    // update the activation e-mail sent date and generate a new hash
                    mpsUser.Activation_Email_Sent_Date__c = System.today();
                    mpsUser.Activation_Hash_Number__c = generateActivationHash(100);
	            	mpsUser.Activation_Server__c = GNE_CM_IHCP_Utils.getPortalServer();
                }
            }
            
            // Prepare an activation email for each MPS user.
            // Be sure to call this method after the new value for the Activation_Hash_Number__c field has been set.
            if (mpsUser.Id == null)
            {
                throw new GNE_CM_Exception('MPS User\'s ID is null for an MPS user to whom activation email is to be sent');
            }
            
            emailsByMpsUserId.put (mpsUser.Id, prepareActivationEmail(mpsUser, isReminder, isReminder ? registeringUsers.get(mpsUser.Id) : null));
            
            updatedMpsUsers.add(mpsUser);
        }
        
        return new GNE_CM_MPS_Activation_Email_Bundle (emailsByMpsUserId, updatedMpsUsers);
    }
    
    /**
     * For each MPS user whose ID is on the list, get the full name of their registering user. Registering user is:
     * - the practice representative, if the MPS user was registered when the practice was created
     * - the administrator user whose added them - if they were added later through the practice administration panel
     */
    private static Map<Id, String> getRegisteringUsers(List<Id> mpsUserIds)
    {
        Map<Id, String> registeringUsers = new Map<Id, String>();
        
        List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id, CreatedById, GNE_CM_MPS_Registration__r.Authorized_Representative_First_Name__c, GNE_CM_MPS_Registration__r.Authorized_Representative_Last_Name__c FROM GNE_CM_MPS_User__c WHERE Id IN :mpsUserIds];
        
        Id practiceGuestUserId = null;
        
        try
        {
            practiceGuestUserId = (Id)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Practice_Registration_Site_Guest_User_Id__c;
        }
        catch (Exception e)
        {
            throw new GNE_CM_Exception('Incorrect value for custom settings field Practice_Registration_Site_Guest_User_Id__c: ' + GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Practice_Registration_Site_Guest_User_Id__c);
        }
        
        List<Id> creatingUserIds = new List<Id>();
        
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers)
        {
            creatingUserIds.add(mpsUser.CreatedById);
        }
        
        Map<Id, User> creatingUsers = new Map<Id, User>([SELECT Id, FirstName, LastName FROM User WHERE Id IN :creatingUserIds]);
        
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers)
        {
            if (mpsUser.GNE_CM_MPS_Registration__c == null)
            {
                throw new GNE_CM_Exception('MPs Registration is null for MPS User with ID = ' + mpsUser.Id);    
            }
            
            String registeringUserName = null;
            if (mpsUser.CreatedById == practiceGuestUserId)
            {
                registeringUserName = mpsUser.GNE_CM_MPS_Registration__r.Authorized_Representative_First_Name__c + ' ' + mpsUser.GNE_CM_MPS_Registration__r.Authorized_Representative_Last_Name__c;
            }
            else
            {
                User creatingUser = creatingUsers.get(mpsUser.CreatedById);
                registeringUserName = creatingUser.FirstName + ' ' + creatingUser.LastName;
            }
            
            registeringUsers.put (mpsUser.Id, registeringUserName);
        }
        
        return registeringUsers;
    }
    
    public static void sendActivationEmails (List<Id> mpsUserIds, Boolean updateStatus, Boolean isReminder)
    {
    	sendActivationEmails (mpsUserIds, updateStatus, isReminder, false);
    }
    
    /**
     * Sends initial/reminder activation emails to MPS users.
     *
     * @param mpsUserIds - IDs of MPS users to which activation emails will be sent
     * @param updateStatus - tells if the Workflow_State__c field on the MPS user should be updated when the email is sent
     * @author Radek Krawiec
     * @created 07/17/2012
     */
    public static void sendActivationEmails (List<Id> mpsUserIds, Boolean updateStatus, Boolean isReminder, Boolean batchSend)
    {   
        try
        {
            // prepare activation emails
            GNE_CM_MPS_Activation_Email_Bundle emailBundle = prepareActivationEmails(mpsUserIds, updateStatus, isReminder);
            
            // select users with LWO access
            List<GNE_LWO_User__c> lwoUsers =  [SELECT Id, SFDC_User__c, SFDC_User__r.ContactId FROM GNE_LWO_User__c WHERE SFDC_User__c IN (SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id IN :mpsUserIds)];
            
            // create a collection of SFDC users with LWO or AGS Sunshine Tool access
            Set<ID> sfdcUsersWithOtherPortalAccess = new Set<ID>();
            
            for (GNE_LWO_User__c lwoUser : lwoUsers)
            {
            	sfdcUsersWithOtherPortalAccess.add(lwoUser.SFDC_User__c);
            }
            
            // find users with AGS ST access
            List<GNE_CM_IHCP_User__c> sunshineUsers = [SELECT SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c IN (SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id IN :mpsUserIds) AND AGS_ST_Status__c = 'Approved'];
            for (GNE_CM_IHCP_User__c sunshineUser : sunshineUsers)
            {
            	sfdcUsersWithOtherPortalAccess.add(sunshineUser.SFDC_User__c);
            }
            
            // if users are to be updated, update them
            if (updateStatus)
            {
                // update users from the bundle (those to which activation emails has just been sent)                
                update emailBundle.mpsUsers;
                
                System.debug('[MPS] Updated MPS users: ' + emailBundle.mpsUsers);
            }
            
            System.debug('[MPS] Sent activation emails to users: ' + emailBundle.mpsUsers);
            
            // NOTE: Depending on the parameter 'isReminder' the 'prepareActivationEmails' method generates different email content.
            // For a reminder email, there is an additional registering user parameter sent in the email, and as it is not bound to the MPS user,
            // it would be difficult to pass it to an email template. For this reason reminder emails are NOT sent as email templates - instead, emails
            // are generated manually.
            // 
            // In this place we decide what types of emails will be sent
            if (isReminder)
            {
            	System.debug('[MPS] Sending activation emails: ' + emailBundle.mpsUsersToEmails.values());
            	// send emails from the bundle
            	
            	// if emails should be sent as batch
            	if (batchSend)
            	{
            		System.debug('Sending activation reminder emails as batch');
            		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	            	GNE_CM_IHCP_Email_Utility email = new GNE_CM_IHCP_Email_Utility('MPS');
            		
            		// build a list of emails to send
            		for (GNE_CM_MPS_User__c mpsUser : emailBundle.mpsUsers) 
	            	{
	            		Boolean dualUser = sfdcUsersWithOtherPortalAccess.contains(mpsUser.SFDC_User__c);
	
		            	//GNE_CM_IHCP_Email_Utility email = new GNE_CM_IHCP_Email_Utility(mpsUser, dualUser);
		            	emails.add(email.getActivationReminderEmail(mpsUser.SFDC_User__r.ContactId, mpsUser.Id));
		            }
		            
		            Messaging.sendEmail(emails);
            	}
            	else
            	{
		            for (GNE_CM_MPS_User__c mpsUser : emailBundle.mpsUsers) 
	            	{
	            		Boolean dualUser = sfdcUsersWithOtherPortalAccess.contains(mpsUser.SFDC_User__c);
	
		            	GNE_CM_IHCP_Email_Utility email = new GNE_CM_IHCP_Email_Utility(mpsUser, dualUser);
		            	email.sendActivationReminderEmail();
		            }
            	}
            }
            else
            {
            	if (batchSend)
            	{
            		System.debug('Sending activation emails as batch');
            		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	            	GNE_CM_IHCP_Email_Utility email = new GNE_CM_IHCP_Email_Utility('MPS');
            		
            		// for each user, send an email using template
		            for (GNE_CM_MPS_User__c mpsUser : emailBundle.mpsUsers) 
	            	{
	            		Boolean dualUser = sfdcUsersWithOtherPortalAccess.contains(mpsUser.SFDC_User__c);
	            		// LWO user is already created.
	            		if (dualUser)
	            		{
	            			mpsUser.Workflow_State__c = 'ACTIVATED';
	            			
	            		}
		            	//GNE_CM_IHCP_Email_Utility email = new GNE_CM_IHCP_Email_Utility(mpsUser, dualUser);
		            	emails.add(email.getActivationEmail(mpsUser.SFDC_User__r.ContactId, mpsUser.Id, dualUser));
		            }
		            
		            Messaging.sendEmail(emails);
            	}
            	else
            	{
	            	// for each user, send an email using template
		            for (GNE_CM_MPS_User__c mpsUser : emailBundle.mpsUsers) 
	            	{
	            		Boolean dualUser = sfdcUsersWithOtherPortalAccess.contains(mpsUser.SFDC_User__c);
	            		// LWO user is already created.
	            		if (dualUser)
	            		{
	            			mpsUser.Workflow_State__c = 'ACTIVATED';
	            			
	            		}
		            	GNE_CM_IHCP_Email_Utility email = new GNE_CM_IHCP_Email_Utility(mpsUser, dualUser);
		            	email.sendActivationEmailEx();
		            }
            	}
            }

            // if users are to be updated, update them - again
            if (updateStatus)
            {
                // update workflow status for dual                
                update emailBundle.mpsUsers;
            }
        }
        catch (Exception e)
        {
            Error_Log_gne__c error = GNE_CM_IHCP_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'sendActivationEmails', 'Apex Code', 'Error sending activation emails: ' + GlobalUtils.getExceptionDescription(e));
            insert error;
        }
    }
    
    private static Messaging.SingleEmailMessage prepareActivationEmail (GNE_CM_MPS_User__c mpsUser, Boolean isReminder, String registeringUser)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject(ACTIVATION_EMAIL_SUBJECT);
        mail.setSenderDisplayName('My Patient Solutions');                          
                                                                    
        String body = isReminder ? REMINDER_ACTIVATION_EMAIL_BODY : INITIAL_ACTIVATION_EMAIL_BODY;
        body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
        
        if (mpsUser.SFDC_User__c == null || mpsUser.SFDC_User__r.Username == null)
        {
            throw new GNE_CM_Exception('Either mpsUser.SFDC_User__r or mpsUser.SFDC_User__r.Username is null');
        }
        
        body = body.replace('${email}', mpsUser.SFDC_User__r.Username);
        body = body.replace('${link}', getActivationLink(mpsUser));
        
        if (isReminder)
        {
            body = body.replace('${registeringUser}', registeringUser);
        }
            
        mail.setHtmlBody(body);
        
        return mail;
    }
    
    /**
     * Return an activation link for the given MPS user.
     */
    private static String getActivationLink (GNE_CM_MPS_User__c mpsUser)
    {
        return PORTAL_ADDRESS + '/' + ACTIVATION_PAGE_URL + '?mpsUserId=' + mpsUser.Id + '&hash=' + mpsUser.Activation_Hash_Number__c;
    }
    
    /**
     * Generates a random alphanumeric (upper- and lowercase) string of the given length.
     */
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
    
    public static void sendResetPasswordEmail(String username)
    {
        List<GNE_CM_MPS_User__c> users = 
            [select id, Email_address__c, Activation_Hash_Number__c, First_name__c, Last_name__c, Reset_Password_Email_Sent_Date__c
             from GNE_CM_MPS_User__c where SFDC_USer__r.username = :username];
                        
        Messaging.SingleEmailMessage mail = prepareResetPasswordEmail(users[0]);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       
    }
    
    public static void sendSettingsConfirmationEmail(GNE_CM_MPS_User__c mpsUser, String action)
    {   
        if(mpsUser != null && action != '')  
        {    
			System.debug('>>>>>> mpsUser=' + mpsUser);        	              
            Messaging.SingleEmailMessage mail = prepareSettingsConfirmationEmail(mpsUser, action);
            
            GNE_CM_IHCP_Email_Utility emailUtility=new GNE_CM_IHCP_Email_Utility('MPS', mpsUser.Id);
            
            if (action=='Password')
            {
            	emailUtility.sendResetPasswordConfirmationEmail();
            }
            else if (action=='Profile')
            {
            	emailUtility.sendResetProfileConfirmationEmail();
            }
            else
            {
            	emailUtility.sendResetQuestionConfirmationEmail();            	
            }
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			System.debug('>>>>>> mail=' + mail);        	              
        }      
    }
    
    private static Messaging.SingleEmailMessage prepareResetPasswordEmail(GNE_CM_MPS_User__c mpsUser)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject(RESET_PASSWORD_EMAIL_SUBJECT);
        mail.setSenderDisplayName('My Patient Solutions');
        
        String hash = generateActivationHash(100);
        mpsUser.Activation_Hash_Number__c = hash;
        mpsUser.Reset_Password_Email_Sent_Date__c = System.now();
        
        String link = getResetPasswordLink(mpsUser);
        
        String body = RESET_PASSWORD_EMAIL_BODY;
        body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
        body = body.replace('${link}', link);
        mail.setHtmlBody(body);
        
        update mpsUser;
        
        return mail;
    }
    
    private static Messaging.SingleEmailMessage prepareSettingsConfirmationEmail(GNE_CM_MPS_User__c mpsUser, String action)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject(CONFIRM_SETTINGS_EMAIL_SUBJECT);
        mail.setSenderDisplayName('My Patient Solutions');
                
        String body = CONFIRM_QUESTION_SETTINGS_EMAIL_BODY;
        if (action == 'Password')
            body = CONFIRM_PASSWORD_SETTINGS_EMAIL_BODY;
        if (action == 'Profile')
        {
            body = CONFIRM_PROFILE_SETTINGS_EMAIL_BODY;
            if(mpsUser.First_name__c != null)
            body = body.replace('${fname}', mpsUser.First_name__c);
            else
            	body = body.replace('${fname}', '');
            if(mpsUser.Last_name__c != null)
            body = body.replace('${lname}', mpsUser.Last_name__c);
            else
            	body = body.replace('${lname}', '');
           	if(mpsUser.Phone_number__c != null)
            body = body.replace('${phone}', mpsUser.Phone_number__c);
            else
            	body = body.replace('${phone}', '');
            if(mpsUser.Phone_number_ext__c != null)
            body = body.replace('${ext}', mpsUser.Phone_number_ext__c);
            else
            	body = body.replace('${ext}', '');
            if(mpsUser.Email_address__c != null)
            body = body.replace('${email}', mpsUser.Email_address__c);
            else
            	body = body.replace('${email}', '');
            body = body.replace('${uname}', Userinfo.getUserName());
        }

        body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
        mail.setHtmlBody(body);
        
        return mail;
    }
    
    /**
     * Sends an email notification to a user who has just changed their challenge questions.
     */
    public static void sendChallengeAnswersChangedEmail(String firstName, String lastName, String email)
    {                       
        Messaging.SingleEmailMessage mail = prepareChallengeAnswersChangedEmail(firstName, lastName, email);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('Sending challenge answers change notification: ' + mail);      
    }
    
    /**
     * Prepares an email notification to a user who has just changed their challenge questions.
     */
    private static Messaging.SingleEmailMessage prepareChallengeAnswersChangedEmail(String firstName, String lastName, String email)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { email });
        mail.setSubject(CHALLENGE_ANSWERS_CHANGED_SUBJECT);
        mail.setSenderDisplayName('My Patient Solutions');
        
        String body = CHALLENGE_ANSWERS_CHANGED_EMAIL_BODY;
        body = body.replace('${name}', firstName + ' ' + lastName);
        mail.setHtmlBody(body);
        
        return mail;
    }

    
    public static void sendResetPasswordConfirmationEmail(String username)
    {
        System.debug('Prepare confirmation email to sent');
        List<GNE_CM_MPS_User__c> users = 
            [select id, Email_address__c, First_name__c, Last_name__c
             from GNE_CM_MPS_User__c where SFDC_USer__r.username = :username];
                        
        Messaging.SingleEmailMessage mail = prepareResetPasswordConfirmationEmail(users[0]);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('Confirmation email sent');        
    }
    
    private static Messaging.SingleEmailMessage prepareResetPasswordConfirmationEmail(GNE_CM_MPS_User__c mpsUser)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { mpsUser.Email_address__c });
        mail.setSubject(CONFIRM_RESET_PASSWORD_EMAIL_SUBJECT);
        mail.setSenderDisplayName('My Patient Solutions');
        
        String body = CONFIRM_RESET_PASSWORD_EMAIL_BODY;
        body = body.replace('${name}', mpsUser.First_name__c + ' ' + mpsUser.Last_name__c);
        mail.setHtmlBody(body);
        
        return mail;
    }
    
    private static String getResetPasswordLink (GNE_CM_MPS_User__c mpsUser)
    {
        return PORTAL_ADDRESS + '/' + RESET_PASSWORD_PAGE_URL + '?mpsUserId=' + mpsUser.Id + '&hash=' + mpsUser.Activation_Hash_Number__c;
    }
}