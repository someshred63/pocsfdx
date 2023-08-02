public without sharing class GNE_CM_IHCP_Email_Utility
{
	
	private String portalName;
    // templates for reseting password
    private String Reset_Password_Template;
    private String Confirm_Reset_Password_Template;
    
    // templates for reseting password for user with both MPS and LWO access
    private String Multiple_Portals_Reset_Password_Template;
    private String Multiple_Portals_Confirm_Reset_Password_Template;
    
    private String Initial_Activation_Template;
    private String Activation_Notification_Template;
    private String Existing_Activation_Template;
    private String Confirm_Profile_Settings_Template;
    private String Confirm_Question_Settings_Template;
    private String Convert_User_Template;
    private String Convert_User_Both_Template;
    private String Multi_Portal_Activation_Template;
    private String Reminder_Activation_Template;
    private String SenderDisplayName;
    private String ReplyTo; 
    private String Change_Profile_Site_URL;
    
    private String contactId;
    private String actualUserId;
    private Boolean dualUser=false;
    private String portal;
    private String OrgWideEmailAddressId;
    private GNE_CM_MPS_User__c mpsUser;
    private GNE_LWO_User__c lwoUser;
       
    public GNE_CM_IHCP_Email_Utility(String portal)
    {
    	System.debug('-------------- email utils ' + portal);
    	portalName = portal;
        if (portal.contains('LWO'))
        {
        	System.debug('-------------- portal name LWO');
            GNE_LWO_Custom_Setting__c cfg=GNE_LWO_CustomSettingsHelper.self().getLWOConfig();
            
            Reset_Password_Template=cfg.Reset_Password_Template__c;
            Multiple_Portals_Reset_Password_Template = cfg.Multi_Portals_Reset_Pwd_Template__c;
    		
            Initial_Activation_Template=cfg.Initial_Activation_Template__c;
            Multi_Portal_Activation_Template=cfg.Multi_Portal_Activation_Template__c;
            Confirm_Reset_Password_Template=cfg.Confirm_Reset_Password_Template__c;
            Confirm_Question_Settings_Template=cfg.Confirm_Question_Settings_Template__c;
            Activation_Notification_Template =cfg.Activation_Notification__c;
            Existing_Activation_Template =cfg.Existing_Activation_Template__c;
            Confirm_Profile_Settings_Template=cfg.Confirm_Profile_Settings_Template__c;            
            ReplyTo=cfg.ReplyTo__c;
            SenderDisplayName=cfg.SenderDisplayName__c;
            Convert_User_Template=cfg.Convert_User_Template__c;
            Convert_User_Both_Template = cfg.Convert_User_Both_Template__c;
            Reminder_Activation_Template = cfg.Reminder_Activation_Template__c;
        }
        else if (portal.contains('MPS'))
        {
        	System.debug('-------------- portal name MPS');
            GNE_CM_MPS_Custom_Setting__c cfgMPS=GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG);
            
            Reset_Password_Template=cfgMPS.Reset_Password_Template__c;
            Initial_Activation_Template=cfgMPS.Initial_Activation_Template__c;
            Confirm_Reset_Password_Template=cfgMPS.Confirm_Reset_Password_Template__c;            
            Confirm_Question_Settings_Template=cfgMPS.Confirm_Question_Settings_Template__c;
            Confirm_Profile_Settings_Template=cfgMPS.Confirm_Profile_Settings_Template__c;
            Multiple_Portals_Confirm_Reset_Password_Template = cfgMPS.Multi_Portals_Confirm_Reset_Pwd_Template__c;
            Multiple_Portals_Reset_Password_Template = cfgMPS.Multi_Portals_Reset_Pwd_Template__c;
            Convert_User_Template = cfgMPS.Convert_User_Template__c;
            Multi_Portal_Activation_Template = cfgMPS.Multi_Portal_Activation_Template__c;
            ReplyTo=cfgMPS.ReplyTo__c;
            SenderDisplayName=cfgMPS.SenderDisplayName__c;
            Convert_User_Both_Template = cfgMPS.Convert_User_Both_Template__c;
            Reminder_Activation_Template = cfgMPS.Reminder_Activation_Template__c;
        } 

		// get the org-wide email address...
		if (ReplyTo!=null) 
		{
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :ReplyTo];
            if (owea.size()>0) 
            {
				OrgWideEmailAddressId=owea[0].Id;
            }
		}
    }
    
    public GNE_CM_IHCP_Email_Utility(GNE_CM_MPS_User__c mpsUser)
    {
        this('MPS');
        contactId = mpsUser.SFDC_User__r.ContactId;
        actualUserId = mpsUser.Id;
        dualUser = [select count() from GNE_LWO_User__c where SFDC_User__c in (SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id=:mpsUser.Id)]>0;
    }
    
    public GNE_CM_IHCP_Email_Utility(GNE_LWO_User__c lwoUser)
    {
        this('LWO');
        contactId = lwoUser.SFDC_User__r.ContactId;
        actualUserId = lwoUser.Id;
        dualUser=[select count() from GNE_CM_MPS_User__c where SFDC_User__c in (SELECT SFDC_User__c FROM GNE_LWO_User__c WHERE Id=:lwoUser.Id)]>0;
    }
    
    public GNE_CM_IHCP_Email_Utility(GNE_CM_MPS_User__c mpsUser, Boolean isDualUser)
    {
        this('MPS');
        contactId = mpsUser.SFDC_User__r.ContactId;
        actualUserId = mpsUser.Id;
        dualUser = isDualUser;
    }
    
    public GNE_CM_IHCP_Email_Utility(GNE_LWO_User__c lwoUser, Boolean isDualUser)
    {
        this('LWO');
        contactId = lwoUser.SFDC_User__r.ContactId;
        actualUserId = lwoUser.Id;
        dualUser = isDualUser;
    }

    
    /**
     * Creates an instance of the utility class.
     * 
     * @param portal The name of the portal, either 'MPS' or 'LWO'
     * @param userId The ID of the portal user (either MPS_User or LWO_User, depending on the portal)
     */
    public GNE_CM_IHCP_Email_Utility (String portal, Id userId)
    {
        this (portal, userId, null);
    }
    
    /**
     * Creates an instance of the utility class.
     * 
     * @param portal The name of the portal, either 'MPS' or 'LWO'
     * @param userId The ID of the portal user (either MPS_User or LWO_User, depending on the portal)
     * @param isDualUser Tells if the user has access to both portals
     */
    public GNE_CM_IHCP_Email_Utility (String portal, Id userId, Boolean isDualUser)
    {
        this(portal);    
        if (portal.contains('MPS'))
        {
            this.portal = 'MPS';            
            List<GNE_CM_MPS_User__c> mpsUserList = [SELECT Id, SFDC_User__r.ContactId FROM GNE_CM_MPS_User__c WHERE Id =: userId];
            if(mpsUserList != null && mpsUserList.size() > 0)
            {
                mpsUser = mpsUserList[0];
                mpsUser.Activation_Server__c = GNE_CM_IHCP_Utils.getPortalServer();
                mpsUser.Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100);              
                contactId = mpsUser.SFDC_User__r.ContactId;
                actualUserId = userId;
                
                // if the dualUser parameter has not been passed to the method, decide it here
                if (isDualUser == null)
                {
                    dualUser = [select count() from GNE_LWO_User__c where SFDC_User__c in (SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id=:mpsUser.Id)] > 0;
                }
                else
                {
                    dualUser = isDualUser;
                }
            }
        }
        else if(portal.contains('LWO'))
        {
            this.portal = 'LWO';
            List<GNE_LWO_User__c> lwoUserList = [SELECT Id, SFDC_User__r.ContactId FROM GNE_LWO_User__c WHERE Id =: userId];
            
            if (lwoUserList != null && lwoUserList.size() > 0)
            {
                lwoUser = lwoUserList[0];
                lwoUser.Activation_Server__c = GNE_CM_IHCP_Utils.getPortalServer();
                lwoUser.Activation_Hash_Number__c = GNE_CM_IHCP_Email_Utility.generateActivationHash(100);          
                contactId = lwoUser.SFDC_User__r.ContactId;
                actualUserId = userId;
                
                // if the dualUser parameter has not been passed to the method, decide it here
                if (isDualUser == null)
                {
                    dualUser = [select count() from GNE_CM_MPS_User__c where SFDC_User__c in (SELECT SFDC_User__c FROM GNE_LWO_User__c WHERE Id=:lwoUser.Id)] > 0;
                }
                else
                {
                    dualUser = isDualUser;
                }
            }
        }       
    }

    public String getTemplateId(String templateName)
    {
        return [SELECT Id,Name FROM EmailTemplate WHERE Name=:templateName].Id;
    }
    
    public void sendResetPasswordEmail(String sfContactId, String portalUserId)
    {
        sendResetPasswordEmail(sfContactId, portalUserId, false);
    }

    public void sendResetPasswordEmail(String sfContactId, String portalUserId, Boolean hasCommonAccess)
    {
        sendEmail(sfContactId, portalUserId, getTemplateID(hasCommonAccess? Multiple_Portals_Reset_Password_Template : Reset_Password_Template));
    }
    
    public void sendResetPasswordEmail (String sfContactId, String portalUserId, List<String> portalNames)
    {
    	sendEmail(sfContactId, portalUserId, getTemplateID(getResetTemplateName(portalNames)));
    }

    public void sendActivationEmailEx()
    {
        sendActivationEmail(contactId, actualUserId, dualUser);
    }
    
    public Messaging.SingleEmailMessage getActivationEmailEx()
    {
        return getActivationEmail(contactId, actualUserId, dualUser);
    }
 
    public void sendActivationEmail(String sfContactId, String portalUserId)
    {   
        //sendEmail(sfContactId, portalUserId, getTemplateID(Initial_Activation_Template));
        sendActivationEmail(sfContactId, portalUserId, dualUser);
    }
    
    public void sendActivationEmail(String sfContactId, String portalUserId, Boolean hasCommonAccess)
    {       
        sendEmail(sfContactId, portalUserId, getTemplateID(hasCommonAccess ? Multi_Portal_Activation_Template : Initial_Activation_Template));
    }
    
    public Messaging.SingleEmailMessage getActivationEmail(String sfContactId, String portalUserId, Boolean hasCommonAccess)
    {       
        return getEmail(sfContactId, portalUserId, getTemplateID(hasCommonAccess ? Multi_Portal_Activation_Template : Initial_Activation_Template));
    }



    public void sendActivationEmail()
    {
        mpsUser.Workflow_State__c = 'ACTIVATION_EMAIL_SENT';
        mpsUser.Activation_Email_Sent_Date__c = System.today();
        update mpsUser; 
        sendEmail(contactId, actualUserId, getTemplateID(Initial_Activation_Template));
    }
    
    public void sendExistingActivationEmail(String sfContactId, String portalUserId)
    {
        sendEmail(sfContactId, portalUserId, getTemplateID(Existing_Activation_Template));
    }
    
    
    public void sendActivationNotificationEmail(String sfContactId, String portalUserId)
    {
        sendEmail(sfContactId, portalUserId, getTemplateID(Activation_Notification_Template));
    }
    
    /**
     * Reminder to Activate
     */
    public void sendActivationReminderEmail()
    {
        sendActivationReminderEmail(contactId, actualUserId);
    }
    
    public Messaging.SingleEmailMessage getActivationReminderEmail()
    {
        return getActivationReminderEmail(contactId, actualUserId);
    }

    public void sendActivationReminderEmail(String sfContactId, String portalUserId)
    {
        sendEmail(sfContactId, portalUserId, getTemplateID(Reminder_Activation_Template));
    }
    
    public Messaging.SingleEmailMessage getActivationReminderEmail(String sfContactId, String portalUserId)
    {
        return getEmail(sfContactId, portalUserId, getTemplateID(Reminder_Activation_Template));
    }
    
    
    public void sendResetPasswordConfirmationEmail()
    {
        sendResetPasswordConfirmationEmail(contactId, actualUserId, dualUser);
    }

    public void sendResetPasswordConfirmationEmail(String sfContactId, String portalUserId)
    {
        sendResetPasswordConfirmationEmail(sfContactId, portalUserId, false);
    }

    public void sendResetPasswordConfirmationEmail(String sfContactId, String portalUserId, Boolean hasCommonAccess)
    {        
        sendEmail(sfContactId, portalUserId, getTemplateID(hasCommonAccess ? Multiple_Portals_Confirm_Reset_Password_Template : Confirm_Reset_Password_Template));
    }
    
    
    

    public void sendResetQuestionConfirmationEmail()
    {        
        sendResetQuestionConfirmationEmail(contactId, actualUserId);
    }    

    public void sendResetQuestionConfirmationEmail(String sfContactId, String portalUserId)
    {        
        sendEmail(sfContactId, portalUserId, getTemplateID(Confirm_Question_Settings_Template));
    }    
    




    public void sendResetProfileConfirmationEmail()
    {        
        sendResetProfileConfirmationEmail(contactId, actualUserId);
    } 

    public void sendResetProfileConfirmationEmail(String sfContactId, String portalUserId)
    {        
        sendEmail(sfContactId, portalUserId, getTemplateID(Confirm_Profile_Settings_Template));
    } 
    
    
    public void sendConvertUserEmail()
    {
        update mpsUser; 
        sendEmail(contactId, actualUserId, getTemplateID(Convert_User_Template));       
    } 
    
    public void sendConvertBothUserEmail()
    {           
        sendEmail(contactId, actualUserId, getTemplateID(Convert_User_Both_Template));
    }
    
    public void sendLWOConvertUserEmail(String sfContactId, String portalUserId)
    {
        update lwoUser;
        sendEmail(sfContactId, portalUserId, getTemplateID(Convert_User_Template));
    }
    
    private Messaging.SingleEmailMessage getEmail (String sfContactId, String portalUserId, String templateId)
    {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setSaveAsActivity(false);
        if (OrgWideEmailAddressId!=null)
        {
        	mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
        }
        else
        {
        	mail.setReplyTo(ReplyTo);
        	mail.setSenderDisplayName(SenderDisplayName); 
        }
        mail.setTemplateID(templateId);
        mail.setTargetObjectId(sfContactId);
        mail.setWhatId(portalUserId);
        
        System.debug('---------- Sending email: ' + ReplyTo + ' ' + templateId);
        
        return mail;	
    }
    
    private void sendEmail(String sfContactId, String portalUserId, String templateId)
    {
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { getEmail(sfContactId, portalUserId, templateId) });
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
    
    private String getResetTemplateName(List<String> portalNames) {
    	// portalNames are sorted
    	String templateName = Reset_Password_Template;
    	Boolean agsstReset = false;
    	Boolean mpsReset = false;
    	Boolean lwoReset = false;
    	
    	for(String pName :portalNames) {
    		if('AGSST'.equals(pName))
    			agsstReset = true;
    		else if('MPS'.equals(pName))
    			mpsReset = true;
    		else if('LWO'.equals(pName))
    			lwoReset = true;
    		
    	}
    	
		if('LWO'.equals(portalName)) {
			if(agsstReset || mpsReset)
				templateName = Multiple_Portals_Reset_Password_Template;
		} else if('MPS'.equals(portalName)) {
			if(lwoReset || agsstReset)
				templateName = Multiple_Portals_Reset_Password_Template;
		}
		
		System.debug('------------ Template Name'  + templateName);
		return templateName;
    }
    
}