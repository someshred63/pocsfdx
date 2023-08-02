public without sharing class AGS_ST_ContactUs_gne
{
    public Boolean inPortal{get;set;} 
    public String hcpName{get;set;}
    public String hcpEmailAddress{get;set;}
    public String emailSubject{get;set;}
    public String emailBody{get;set;}

    public static AGS_ST_Settings_gne__c stSettingPub { 
        get {
            if(Site.getDomain()!=null)
                return AGS_ST_Utils.getCustomSettingsInSite();
            else
                return AGS_ST_Utils.getCustomSettings();
        }
        private set;
    }

    public AGS_ST_ContactUs_gne()
    {
        Id profId = UserInfo.getProfileId();
        Profile p = [select Name from Profile where id =:profId];
        if(p.Name == 'GNE-CM-IHCP-PROFILE')
        {
            inPortal = true;
        }
        else
            inPortal = false;
        system.debug('----'+p);
    }
    
    public PageReference sendContactUsEmail()
    {
        try
        {	
        	Id st_id;
        	AGS_ST_User_gne__c stUser;
        	if(inPortal)
            {
                stUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
                st_id = stUser.id;
            }
        	AGS_ST_MailUtil.sendContactUsEmail(inPortal, emailSubject, emailBody, hcpName, hcpEmailAddress, stUser);

    		/*
            Id st_id;
            String body = '';
            emailBody = emailBody.replaceAll('\r','<br />').replaceAll('\n','<br />');
            AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
            if(inPortal)
            {
                AGS_ST_User_gne__c stUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
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
            mail.setSenderDisplayName(hcpName);
            mail.setSubject(emailSubject);
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            */
            if(inPortal)
            {
                AGS_ST_HCP_HelpDesk_Comm_gne__c newHelpDeskCommunication = new AGS_ST_HCP_HelpDesk_Comm_gne__c();
                newHelpDeskCommunication.AGS_ST_User_gne__c = st_id;
                newHelpDeskCommunication.Communication_Channel_gne__c = 'Email';
                newHelpDeskCommunication.Communication_Note_gne__c = emailBody; 
                insert newHelpDeskCommunication;
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, 'Thank you. Your message has been sent.'));
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ' There is an unexpected error. If error continues, please contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.'));
            return null;
        }
        return null;
    }
}