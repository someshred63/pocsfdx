public without sharing class AGS_ST_RegisterErrorController_gne {
    
    public String didYouKnow
    {
        get
        {
            return AGS_ST_DbUtils.getDidYouKnowText();
        }
        set;
    }
    
    public static AGS_ST_Settings_gne__c stSetting
    { 
        get
        {
            return AGS_ST_Utils.getCustomSettingsInSite();
        }
        private set;
    }
    
    public String errMsg{get;set;}
    
    public String phoneNo {get;set;}
    public String prefferedDate {get;set;}
    public String prefferedTime {get;set;}  
          
    public PageReference sendCallRequest() 
    {
        try
        {            
            //AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
            String agsStUserId = ApexPages.currentPage().getParameters().get('agsStUserId');
            AGS_ST_MailUtil.sendCallRequestEmail(agsStUserId, phoneNo, prefferedDate, prefferedTime);
            
            /*String body = '<p>Dear CCO,</p>';
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
            String[] toAddress = new String[] {stSetting.CCO_Email_gne__c};
            mail.setToAddresses(toAddress );
            mail.setSenderDisplayName('SFDC Administrator');
            mail.setSubject('User contact request');
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            */
            
            if(agsStUserId!=null)
            {
                AGS_ST_HCP_HelpDesk_Comm_gne__c comm = new AGS_ST_HCP_HelpDesk_Comm_gne__c();
                comm.AGS_ST_User_gne__c = agsStUserId;
                comm.Communication_Channel_gne__c = 'Email';
                comm.Communication_Note_gne__c = 'Request to contact: phone no:'+phoneNo+' time '+prefferedTime +' date '+prefferedDate;
                comm.Communication_Reason_gne__c = 'Registration';
                insert comm;
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, 'Your request has been sent.'));
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Your request could not been sent at this time. Please try again later.'));
            return null;
        }
    }
    
    public PageReference goToLoginPage()
    {
        //AGS_ST_Settings_gne__c stSetting = AGS_ST_Utils.getCustomSettingsInSite();
        PageReference pr = new PageReference(stSetting.Site_Domain_gne__c+'/SunshineTrackLogin/AGS_ST_Login_gne');
        pr.setRedirect(true);
        return pr;             
    }
    
    public PageReference refreshWithMsg()
    {
        errMsg = ApexPages.currentPage().getParameters().get('errMsg');
        return null;
    }
}