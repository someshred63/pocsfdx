global without sharing class AGS_ST_ChangeUserDataController_gne 
{
    public String userNameCurrent {get;set;} 
    public String userNameNew {get;set;} 
    public AGS_ST_User_gne__c st_user {get;set;}
    public Address_vod__c st_addr {get;set;}
    public GNE_CM_IHCP_User__c ihcpUsr{get;set;}
    public String phoneNumber {get;set;}
    public Boolean isPhoneMobile {get;set;}
    public Integer alertNewPaymentsAmount{get;set;}
    
    public Boolean isDobEdit {get;set;}
    public Boolean isCobEdit {get;set;}
    public Boolean isCojEdit {get;set;}
    
    public String dobTxt{get;set;}
    public String cobTxt{get;set;}
    public String cojTxt{get;set;}
    
    public Boolean isMPSusr {get;set;}
    public Boolean isLWOusr {get;set;}
    
    public String userEmail {get;set;} 
    public String contactPreferences {get;set;} 
    public String toolTips
    {
        get
        {
            List<AGS_ST_FAQ_DYK_gne__c> toolTipsList = [SELECT ToolTip_Subject_gne__c, ToolTip_Text_gne__c, ToolTip_Type_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c='ToolTip'];
            return JSON.serialize(toolTipsList);
        }
        set;
    }

    public static AGS_ST_Settings_gne__c stSettingPub { 
        get {
            if(Site.getDomain()!=null)
                return AGS_ST_Utils.getCustomSettingsInSite();
            else
                return AGS_ST_Utils.getCustomSettings();
        }
        private set;
    }

    public PageReference goToHomePage()
    {
        PageReference pr = new PageReference('/apex/AGS_ST_Home_gne');
        pr.setRedirect(true);
        return pr;              
    }
    
    public PageReference sysLogout()
    {
        PageReference pr = new PageReference(Site.getPrefix() + '/secur/logout.jsp');
        pr.setRedirect(true);
        return pr;
    }   
        
    public PageReference pageOnLoadAction()
    {
        this.setupUserCurrentData();  
        isDobEdit = false;
        isCobEdit = false;
        isCojEdit = false;
        return null;
    }
             
    private void setupUserCurrentData()
    {
        this.userNameCurrent = this.getCurrentUserName();  
        st_user = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        alertNewPaymentsAmount = 0;
        if(st_user.Alert_New_Payments_Amount_gne__c != null) {
            alertNewPaymentsAmount = Integer.valueOf(st_user.Alert_New_Payments_Amount_gne__c);
            if(alertNewPaymentsAmount == null) {
            	alertNewPaymentsAmount = 0;
            }
        }
        if(st_user.Phone_number__c != null && st_user.Phone_number__c != '')
        {
            phoneNumber = st_user.Phone_number__c;
            isPhoneMobile = true;
        }
        else if(st_user.Phone_number_ext__c != null && st_user.Phone_number_ext__c != '')
        {
            phoneNumber = st_user.Phone_number_ext__c;
            isPhoneMobile = false;
        }
        st_addr = AGS_ST_DbUtils.getGoldAddressByAccountId(st_user.Mapped_Account__c);
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
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
        userEmail = st_user.Email_address__c;
        contactPreferences = st_user.Dispute_Contact_preferences_gne__c;
        system.debug('----ihcpUsr'+ihcpUsr);
        system.debug('----ihcpUsr.Security_Question_Answer_City_Of_Birth__c'+ihcpUsr.Security_Question_Answer_City_Of_Birth__c);
    }
    
    @RemoteAction
    global static String changeCommData(String phoneNo, Boolean isMobile,String email, String communication)
    {       
        try
        {
            AGS_ST_User_gne__c hcpUsr = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            if(isMobile)
            {
                hcpUsr.Phone_number__c = phoneNo;
                hcpUsr.Phone_number_ext__c = '';
            }
            else
            {
                hcpUsr.Phone_number_ext__c = phoneNo;
                hcpUsr.Phone_number__c = '';
            }
            hcpUsr.Email_address__c = email;
            hcpUsr.Dispute_Contact_preferences_gne__c = communication;
            update hcpUsr;
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Failed' + e.getMessage();
        }
    }
    
    @RemoteAction
    global static String changePassword(String newPassword, String verifyNewPassword)
    {       
        try
        {
            if(newPassword != verifyNewPassword)
                return 'Failed';
            System.setPassword(UserInfo.getUserId(), newPassword);
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Failed';
        }
    }   
    
    @RemoteAction
    global static String changeUserNameAction(String userNameNew)
    {
        try
        {
            system.debug('Changing userName. Current userName: ' + UserInfo.getUserName() + '. New userName:' + userNameNew);   
            String validationMessage = validateUserName(userNameNew);
            if(validationMessage!=null)
            {
                return validationMessage;
            }
            boolean success = updateUserName(userNameNew);
            system.debug('User name change successfull: ' + success);
            userNameNew = '';
            if(success)             
                return 'Your user name has been successfully changed.';
            else
                return 'There is an unexpected error. If error continues, please call contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.';                  
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Failed';
        }
    }
    
    private String getCurrentUserName()
    {       
        return UserInfo.getUserName();      
    }  
    
    public static String validateUserName(String userNameNew)
    {
        if(!AGS_ST_Utils.hasValue(userNameNew))
        {
            return 'User name must not be empty! User name is a required field.';
        }
        boolean isNewUserNameAvailable = checkNewUserNameIsAvailable(userNameNew);        
        if(!isNewUserNameAvailable)
        {
            return 'The username is already used by another user!';
        }
        return null;
    }
    
    @future
    public static void updateUserEmail(String email)
    {
        AGS_ST_User_gne__c agsStUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
        try
        {       
            agsStUser.Email_address__c = email;
            update agsStUser; 
        }
        catch(Exception e)
        {
            system.debug('Error while updating user email. User name: ' + UserInfo.getUserName());
            system.debug('Stacktrace: ' + e.getStackTraceString());
        }
    }
    
    public static Boolean updateUserName(String userNameNew)
    {
        User usr = AGS_ST_DbUtils.findUserById(UserInfo.getUserId());              
        try
        {
            //due to MPS and LWO solutions there is a need to update contact email along with username
            AGS_ST_DbUtils.updateContactEmail(usr.ContactId,userNameNew.trim());
            usr.Username = userNameNew.trim();
            update usr;
            updateUserEmail(userNameNew);
            return true;        
        }
        catch(Exception e)
        {
            system.debug('Error while updating user name. UserName: ' + UserInfo.getUserName() + '.New userName: ' + userNameNew);
            system.debug('Stacktrace: ' + e.getStackTraceString()); 
            return false;
        }               
    }
    
    public static Boolean checkNewUserNameIsAvailable(String userNameNew)
    {
        User usr = AGS_ST_DbUtils.findUserByUserName(userNameNew);
        return usr == null;
    }
    
    public PageReference dobEditAction()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        dobTxt = ihcpUsr.Security_Question_Answer_Day_Of_Birth__c;
        isDobEdit = true;
        return null;
    }
    public PageReference cobEditAction()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        cobTxt = ihcpUsr.Security_Question_Answer_City_Of_Birth__c;
        isCobEdit = true;
        return null;
    }
    public PageReference cojEditAction()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        cojTxt = ihcpUsr.Security_Question_Answer_City_Of_Job__c;
        isCojEdit = true;
        return null;
    }
    
    public PageReference cancelCobEdit()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        isCobEdit = false;
        return null;
    }
    
    public PageReference cancelDobEdit()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        isDobEdit = false;
        return null;
    }

    public PageReference cancelCojEdit()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        isCojEdit = false;
        return null;
    }

    public PageReference dobSave()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        ihcpUsr.Security_Question_Answer_Day_Of_Birth__c = dobTxt;
        update ihcpUsr;
        isDobEdit = false;
        return null;
    }
    public PageReference cobSave()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        ihcpUsr.Security_Question_Answer_City_Of_Birth__c = cobTxt;
        update ihcpUsr;
        isCobEdit = false;
        return null;
    }
    public PageReference cojSave()
    {
        ihcpUsr = AGS_ST_DbUtils.getIHCPUser(UserInfo.getUserId());
        ihcpUsr.Security_Question_Answer_City_Of_Job__c = cojTxt;
        update ihcpUsr;
        isCojEdit = false;
        return null;
    }
    
    @RemoteAction
    global static String updatePaymentActivityAlert(Boolean isNewPaymentAlert, Decimal newPaymentAmount)
    {       
        try
        {
            AGS_ST_User_gne__c tmp_usr = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            tmp_usr.Alert_New_Payments_Amount_gne__c = newPaymentAmount;
            tmp_usr.Alert_New_Payments_gne__c = isNewPaymentAlert;
            update tmp_usr;
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Failed';
        }
    }  
    
    @RemoteAction
    global static String updateActivityDigest(String alertFreq)
    {
        try
        {
            AGS_ST_User_gne__c tmp_usr = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            tmp_usr.Alert_Frequency_gne__c = alertFreq;
            update tmp_usr;
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Failed';
        }
    }
    
    @RemoteAction
    global static String updateDisputeActivityAlert(Boolean isAlertDisputes)
    {
        try
        {
            AGS_ST_User_gne__c tmp_usr = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());
            tmp_usr.Alert_Dispute_Updates_gne__c = isAlertDisputes;
            update tmp_usr;
            return 'Success';
        }
        catch(Exception e)
        {
            return 'Failed';
        }
    }
}