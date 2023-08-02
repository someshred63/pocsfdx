global without sharing class AGS_ST_LoginController_gne {
    public String password { get; set; }
    public String usrname { get; set; }
    public String passwordConfirm { get; set; }
    public String oldPassword { get; set; }
    public String newPassword { get; set; }
    public String verifyNewPassword { get; set; }
    public String confirmationEmail { get; set; }
    public String forgotEmail { get; set; }
    public GNE_CM_IHCP_User__c ihcpActivationUsr { get; set; }
    public GNE_CM_IHCP_User__c ihcpResetPwdUsr { get; set; }

    public String security_Question_Answer_Day_Of_Birth { get; set; }
    public String security_Question_Answer_City_Of_Job { get; set; }
    public String security_Question_Answer_City_Of_Birth { get; set; }
    public Boolean isTCaccepted { get; set; }
    public IhcpAccess ihcpa { get; set; }

    public String cobAnswer { get; set; }
    public String cojAnswer { get; set; }
    public String dobAnswer { get; set; }
    public AGS_ST_User_gne__c stUser { get; set; }
    public String hcpRegistrationUsername { get; set; }

    public String registrationEmail { get; set; }

    public PageReference sysLogout() {
        PageReference pr = new PageReference(Site.getPrefix() + '/secur/logout.jsp');
        pr.setRedirect(true);
        return pr;
    }

    public String didYouKnow {
        get {
            return AGS_ST_DbUtils.getDidYouKnowText();
        }
        set;
    }

    public Boolean isUserLoggedIn {
        get {
            return AGS_ST_Utils.isUserLoggedIn();
        }
        set;
    }

    public String faq_terms {
        get {
            return AGS_ST_DbUtils.getFAQ_SunshineAct();
        }
        private set;
    }

    public String termsAndCoditions {
        get {
            return AGS_ST_DbUtils.getTermsAndConditions();
        }
        private set;
    }

    public static AGS_ST_Settings_gne__c stSetting {
        get {
            return AGS_ST_Utils.getCustomSettingsInSite();
        }
        private set;
    }

    public AGS_ST_LoginController_gne() {
        System.debug('----faq_terms');
        System.debug('----faq_terms' + faq_terms);
    }

    public PageReference goToRegistration() {
        PageReference pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineRegistration?regEmail=' + registrationEmail);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference goToLoginPage() {
        PageReference pr = new PageReference('/AGS_ST_Login_gne');
        pr.setRedirect(true);
        return pr;
    }

    public PageReference goToPaymentsList() {
        PageReference pr = Page.AGS_ST_Home_gne;
        pr.setRedirect(true);
        return pr;
    }

    // Page AGS_ST_User_Activation_gne.page (onLoad action)
    // Activates agsStUser.
    public PageReference activateUser() {
        try {
            System.debug('#User activation start.');
            String agsStUserId = getPageParam('agsStUserId');
            String hash = getPageParam('hash');

            System.debug('#### agsStUserId: ' + agsStUserId);
            System.debug('#### hash: ' + hash);

            Boolean urlParamsExists = AGS_ST_Utils.hasValue(agsStUserId) && AGS_ST_Utils.hasValue(hash);
            if (!urlParamsExists) {
                System.debug('#Invalid url params!');
                return prepareRegisterErrorPage('There was an error while activating the user.');
            }
            System.debug('#Url params are valid.');

            stUser = AGS_ST_DbUtils.findAgsStUser(agsStUserId, hash);
            hcpRegistrationUsername = stUser.SFDC_User__r.Username;
            isTCaccepted = stUser.isTCaccepted__c;
            System.debug('---stUser' + stUser);
            if (stUser == null) {
                System.debug('#No AGS ST USER found!');
                return prepareRegisterErrorPage('There was an error while activating the user. The page is no longer valid.');
            }
            System.debug('#AGS ST USER found: ' + stUser.Id);

            User usr = AGS_ST_DbUtils.findUserById(stUser.SFDC_User__c);
            if (usr == null) {
                System.debug('#No USER found!');
                return prepareRegisterErrorPage('There was an error while activating the user.');
            }
            System.debug('#USER found: ' + usr.Id);

            // Field Last_Password_Modified_Date__c is set later (with a new Date()) on 'ChangePassword' button click handler.
            Boolean isAgsUserActivated = (stUser.Last_Password_Modified_Date__c != null);
            /*if(isAgsUserActivated)
            { 
                system.debug('#User already activated!');           
                return prepareRegisterErrorPage('User already activated!');                     
            } */
            ihcpActivationUsr = AGS_ST_DbUtils.findIHcpUserByUserName(usr.Username);
            System.debug('---ihcpActivationUsr' + ihcpActivationUsr);
            System.debug('---ihcpActivationUsr' + ihcpActivationUsr.Security_Question_Answer_Day_Of_Birth__c);
            security_Question_Answer_Day_Of_Birth = ihcpActivationUsr.Security_Question_Answer_Day_Of_Birth__c;
            security_Question_Answer_City_Of_Job = ihcpActivationUsr.Security_Question_Answer_City_Of_Job__c;
            security_Question_Answer_City_Of_Birth = ihcpActivationUsr.Security_Question_Answer_City_Of_Birth__c;
            ihcpa = new IhcpAccess();
            ihcpa.mpsStatus = ihcpActivationUsr.MPS_Status__c;
            ihcpa.lwoStatus = ihcpActivationUsr.LWO_Status__c;
            System.debug('#User successfully activated.');
            return null;
        } catch (Exception e) {
            return prepareRegisterErrorPage('There was an error while activating the user.');
        }
    }

    // Page AGS_ST_User_Activation_gne.page (buttonClick action)
    // Sets password for user and then performs user logon to the system.
    public PageReference setPasswordAndLogon() {
        try {
            System.debug('Set new password and logon to sfdc.');
            User usr = AGS_ST_DbUtils.findUserById(stUser.SFDC_User__c);
            if (usr == null) {
                System.debug('#No USER found!');
                return prepareRegisterErrorPage('There was a problem with your password. Please try again later.');
            }
            System.debug('#USER found: ' + usr.Id);

            String validationMessage = this.validatePassword(this.password, this.passwordConfirm);
            if (validationMessage != null) {
                System.debug('Password validation error: ' + validationMessage);
                return showErrorOnPage(validationMessage);
            }

            String resultMessage = setPassword(usr.Id, password);
            if (resultMessage != null) {
                System.debug('Password setting error: ' + resultMessage);
                return showErrorOnPage(resultMessage);
            }
            System.debug('----ihcpActivationUsr.' + ihcpActivationUsr);
            ihcpActivationUsr.Security_Question_Answer_Day_Of_Birth__c = security_Question_Answer_Day_Of_Birth;
            ihcpActivationUsr.Security_Question_Answer_City_Of_Job__c = security_Question_Answer_City_Of_Job;
            ihcpActivationUsr.Security_Question_Answer_City_Of_Birth__c = security_Question_Answer_City_Of_Birth;
            update ihcpActivationUsr;
            System.debug('----stUser.' + stUser);
            AGS_ST_User_gne__c tmpStUser = [SELECT isTCaccepted__c,Email_address__c,Id FROM AGS_ST_User_gne__c WHERE Id = :stUser.Id];
            tmpStUser.isTCaccepted__c = isTCaccepted;
            update tmpStUser;
            AGS_ST_DbUtils.updateStUserLastPasswordModifiedDateByUser(usr.Id);
            System.debug('----stUser.' + stUser);
            System.debug('Last password modification date updated.');
            System.debug('---usr.Id' + usr.Id);
            AGS_ST_MailUtil.sendAfterActivationEmail(usr.Id);
            PageReference pageRef = Site.login(usr.Username, password, '/AGS_ST_Registration_Finish');
            return pageRef;
        } catch (Exception e) {
            return prepareRegisterErrorPage('There is a problem in activating your account. Please contact sunshinequestions-d@gene.com or call our toll-free hotline at (877) 313-5778.');
        }
    }

    public PageReference cancelRegistration() {
        System.debug('---------- cancelRegistration');
        User usr = AGS_ST_DbUtils.findUserById(stUser.SFDC_User__c);
        GNE_CM_IHCP_User__c ihcp_usr = AGS_ST_DbUtils.findIHcpUserByUserName(usr.Username);
        System.debug('---------- usr ' + usr);
        System.debug('---------- ihcp_usr ' + ihcp_usr);
        PageReference pr;
        if ((ihcp_usr.LWO_Status__c != '' && ihcp_usr.LWO_Status__c != null) || (ihcp_usr.MPS_Status__c != '' && ihcp_usr.MPS_Status__c != null)) {
            System.debug('---------- access to LWO/MPS');
            ihcp_usr.AGS_ST_Status__c = null;
            update ihcp_usr;
            // Remove permissions
            removePS(usr.Id);
            //pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_RegistrationCancel?ihcpUsrId='+ihcp_usr.id+'&onlySunshine=false');
        } else {

            System.debug('---------- access only to AGSST');
            String timeStamp = Datetime.now().format('YYDDhmmss');
            //User usr = [SELECT Id, Username, FederationIdentifier, IsActive, Email, IsPortalEnabled FROM User WHERE Id = :usrId];
            usr.IsActive = false;
            usr.Username = usr.Username + timeStamp;
            usr.FederationIdentifier = usr.FederationIdentifier + timeStamp;
            //usr.Email =  usr.Email + timestamp;
            //usr.IsPortalEnabled = false;
            update usr;

            deactivateUser(usr.ContactId, usr.AccountId, usr.Username);
            removePS(usr.Id);
            //pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_RegistrationCancel?ihcpUsrId='+ihcp_usr.id+'&onlySunshine=true');
        }
        pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Login_gne');
        System.debug('---------- pr1 ' + pr);
        pr.setRedirect(true);
        return pr;
    }

    @Future
    private static void deactivateUser(String contactId, String accountId, String username) {
        Contact c = [SELECT Id,Email FROM Contact WHERE Id = :contactId];
        c.Email = null;
        update c;
        //AGS_ST_Dbutils.updateContactEmail(contactId, null);
        GNE_CM_IHCP_User__c ihcp_usr = AGS_ST_DbUtils.findIHcpUserByUserName(username);
        // Unassign Account/Contact from User
        //String accntId = getPageParam('accntId');
        Account acct = [SELECT Id, IsCustomerPortal FROM Account WHERE Id = :accountId];
        acct.IsCustomerPortal = false;
        update acct;
        // Remove IHCP User
        delete ihcp_usr;
        // Deactivate User
        //PermissionSetAssignment[] psa = [select id from PermissionSetAssignment where AssigneeId=:userId and PermissionSetId=:AGS_ST_Dbutils.findPermissionSetByName('AGS_ST_PermissionSet_gne').id];
        //if(psa.size()>0) {
        //    delete psa[0]; 
        //}
    }

    @Future
    private static void removePS(String usrId) {
        PermissionSetAssignment[] psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usrId AND PermissionSetId = :AGS_ST_DbUtils.findPermissionSetByName('AGS_ST_PermissionSet_gne').Id];
        if (psa.size() > 0) {
            delete psa[0];
        }

        /*
        if(deactiveUser) {
            User usr = [SELECT Id, IsActive, Username, Email, IsPortalEnabled FROM User WHERE Id = :usrId];
            usr.IsActive = false;
            usr.Username = '_' + usr.Username;
            usr.Email = '_' + usr.Email;
            usr.IsPortalEnabled = false;
            update usr;
        }
        */
    }
/*
    public PageReference cancelRegUpdateIhcpUser() {
        // Set IHCP User data
        System.debug('---------- cancelRegUpdateIhcpUser');
        String ihcpId = getPageParam('ihcpUsrId');
        GNE_CM_IHCP_User__c ihcp_usr = AGS_ST_Dbutils.getIHCPUserById(ihcpId);
        String onlySunshine = getPageParam('onlySunshine'); 
        System.debug('---------- onlySunshine ' + onlySunshine);
        if(onlySunshine == 'false') {
            ihcp_usr.AGS_ST_Status__c = null;
            update ihcp_usr;
        } else {
            delete ihcp_usr;
        }
        PageReference pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Login_gne');
        pr.setRedirect(true);
        return pr;
    }
*/
    // Page AGS_ST_login_gne.page. (buttonClick action)
    // Performs user logon to the system.
    public PageReference usrLogin() {
        try {
            System.debug('User logon starts.');
            if (this.password.equals('')) {
                return showErrorOnPage('Please enter a password.');
            }
            GNE_CM_IHCP_User__c usr = AGS_ST_DbUtils.findIHcpUserByUserName(this.usrname.trim());
            if (usr == null) {
                System.debug('User not found: ' + this.usrname);
                //return showErrorOnPage('Incorrect user or password. You have to register first before you login.');
                return showErrorOnPage('Your login attempt has failed. Please check that username and password are correct. ');
            }
            if (usr.IsLocked__c) {
                    return showErrorOnPage('The user is locked. Please contact sunshinequestions-d@gene.com or call our toll-free hotline at (877) 313-5778.');
            }
            if (usr.AGS_ST_Status__c == 'Approved') {
                PageReference pageRef = Site.login(usr.User_Name__c, password, '/AGS_ST_User_TC_Page_gne');
                if (pageRef == null) {
                    usr = AGS_ST_DbUtils.updateIhcpUserLockStatus(usr);
                    if (usr.IsLocked__c) {
                        AGS_ST_Utils.logStErrorByUserIdNoFuture(usr.SFDC_User__c, 'Login', 'AGS_ST_LoginController_gne', '', 'User locked.', 'usrLogin', 'User Login Failure');
                        return showErrorOnPage('The user has been locked. Please contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
                    } else {
                        AGS_ST_Utils.logStErrorByUserIdNoFuture(usr.SFDC_User__c, 'Login', 'AGS_ST_LoginController_gne', '', 'Wrong password or user does not exist', 'usrLogin', 'User Login Failure');
                        return showErrorOnPage('Your login attempt has failed. Please check that username and password are correct. ');
                    }

                } else {
                    AGS_ST_Utils.logStErrorByUserIdNoFuture(usr.SFDC_User__c, 'Login', 'AGS_ST_LoginController_gne', '', 'Login success', 'usrLogin', 'User Login Success');
                    AGS_ST_DbUtils.resetIhcpUserLockStatus(usr);
                    System.debug('User logon succeded: ' + usr.User_Name__c);
                    return pageRef;
                }
            } else {
                System.debug('User not found: ' + this.usrname);
                return showErrorOnPage('Incorrect user or password. You have to register first before you login. Please register before login');
            }
        } catch (Exception e) {
            return showErrorOnPage('Your login attempt has failed. Please check that username and password are correct.');
        }
    }

    // Page: AGS_ST_ForgotPassword_gne (buttonClick action) 
    // Checks if a user provided email is valid (user exists) and redirects to AGS_ST_ResetPasswordEmailSent in order to reset user password and send activation link. 
    @RemoteAction
    global static StatusMessage forgotPassword(String emailParam) {
        try {
            StatusMessage sm = new StatusMessage();
            if (emailParam.trim() == '') {
                sm.message = 'Please provide email address!';
                sm.status = 'Failure';
                return sm;
            }
            GNE_CM_IHCP_User__c ihcpUsr = AGS_ST_DbUtils.findIHcpUserByUserName(emailParam.trim());
            if (ihcpUsr.IsLocked__c) {
                sm.message = 'User is locked and you cannot reset your password. Please contact helpdesk.';
                sm.status = 'Failure';
                return sm;
            }
            AGS_ST_User_gne__c agsStUser = AGS_ST_DbUtils.findAgsStUserByUserId(ihcpUsr.SFDC_User__c);
            if (agsStUser == null) {
                sm.message = 'Account with email address ' + emailParam + ' does not exist';
                sm.status = 'Failure';
                return sm;
            }
            AGS_ST_User_gne__c physician = AGS_ST_DbUtils.findAgsStUserById(agsStUser.Id);
            sm = AGS_ST_MailUtil.sendResetPasswordEmail(physician, false);
            if ('Failure'.equals(sm.status)) {
                return sm;
            }

            sm.message = 'Please check your email for the link to reset your password';
            sm.status = 'Success';
            return sm;
        } catch (Exception e) {
            StatusMessage sm = new StatusMessage();
            sm.message = 'There was a problem to reset you password. Account with provided email may not exist.';
            sm.status = 'Failure';
            return sm;
        }
    }

    global class StatusMessage {
        public String message;
        public String status;
    }

    // Page: AGS_ST_ResetPasswordEmailSent.page (onLoad action). 
    // Sends an email to user with a link alowing to set a new password.
    public PageReference resetPasswordEmailSending() {
        this.confirmationEmail = getPageParam('confEmail');
        String agsStUserId = getPageParam('agsStUserId');

        System.debug('#### agsStUserId: ' + agsStUserId);
        System.debug('#### confirmationEmail: ' + this.confirmationEmail);

        Boolean urlParamsExists = AGS_ST_Utils.hasValue(agsStUserId) && AGS_ST_Utils.hasValue(this.confirmationEmail);
        if (!urlParamsExists) {
            System.debug('#Invalid url params!');
            return prepareRegisterErrorPage('There was an error while activating the user.');
        }
        System.debug('#Url params are valid.');
        AGS_ST_User_gne__c physician = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
        AGS_ST_MailUtil.sendResetPasswordEmail(physician, false);
        return ApexPages.currentPage();
    }

    public PageReference checkResetPassword() {
        String hash = getPageParam('hash');
        String agsStUserId = getPageParam('agsStUserId');
        AGS_ST_User_gne__c agsStUsr = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);

        if (agsStUsr.Reset_Password_Email_Sent_Date__c == null) {
            return prepareRegisterErrorPage('Password already reset. Please reset your password again.');
        } if (!hash.equals(agsStUsr.Activation_Hash_Number__c)) {
            return prepareRegisterErrorPage('There was a problem with resetting your password. Please return to the login page and reset your password again.');
        }

        if (!isResetPasswordEmailValid(agsStUsr.Last_Password_Modified_Date__c, agsStUsr.Reset_Password_Email_Sent_Date__c)) {
            return prepareRegisterErrorPage('Reset password link has expired. Please reset your password again.');
        }
        //AGS_ST_Dbutils.updateStUserResetPasswordModifiedDateByUser(agsStUsr);    
        //system.debug('Last password modification date updated.');                     
        return null;
    }

    /*public PageReference checkResetPassword()
    {
        String agsStUserId = getPageParam('agsStUserId');   
        AGS_ST_User_gne__c agsStUsr = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);    
 
        if(agsStUsr.Reset_Password_Email_Sent_Date__c == null)
        {      
            return prepareRegisterErrorPage('Password already reset. Please reset your password again.');                       
        }
        AGS_ST_Dbutils.updateStUserResetPasswordModifiedDateByUser(agsStUsr);    
        system.debug('Last password modification date updated.');                     
        return null;
    }*/

    // Page AGS_ST_ResetPassword_gne.page (buttonClick action).
    // Changes user password (end of forgotPassword procedure).
    public PageReference changePasswordAfterResetPassword() {
        System.debug('#Change user password after password reset: start.');
        // -------------------------------------------------------
        // Input data validation:
        // -------------------------------------------------------
        String agsStUserId = getPageParam('agsStUserId');
        String hash = getPageParam('hash');

        System.debug('#### agsStUserId: ' + agsStUserId);
        System.debug('#### hash: ' + hash);
        Boolean urlParamsExists = AGS_ST_Utils.hasValue(agsStUserId) && AGS_ST_Utils.hasValue(hash);
        if (!urlParamsExists) {
            System.debug('#Invalid url params!');
            return prepareRegisterErrorPage('The link you used is incorrect. Please try to reset password again.');
        }
        System.debug('#Url params are valid.');

        AGS_ST_User_gne__c agsStUsr = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
        if (agsStUsr == null) {
            System.debug('#No AGS ST USER found!');
            return prepareRegisterErrorPage('The link you used is expired. Please try to reset password again.');
        } else if (!hash.equals(agsStUsr.Activation_Hash_Number__c)) {
            System.debug('#No AGS ST USER found!');
            return prepareRegisterErrorPage('This link has already been used. Please try to reset your password again.');
        }

        System.debug('#AGS ST USER found: ' + agsStUsr.Id);

        String validationMessage = this.validatePassword(this.newPassword, this.verifyNewPassword);
        if (validationMessage != null) {
            System.debug('Password validation error: ' + validationMessage);
            return showErrorOnPage(validationMessage);
        }
        // -------------------------------------------------------
        // Challenge questions check:
        // ------------------------------------------------------- 
        Integer correctAnswers = 0;
        ihcpResetPwdUsr = AGS_ST_DbUtils.findIHcpUserByUserName(agsStUsr.SFDC_User__r.Username);
        if (ihcpResetPwdUsr.Security_Question_Answer_City_Of_Birth__c == cobAnswer) {
            System.debug('----------- City of Birth correct');
            correctAnswers++;
        }
        if (ihcpResetPwdUsr.Security_Question_Answer_City_Of_Job__c == cojAnswer) {
            System.debug('----------- City of Job correct');
            correctAnswers++;
        }
        if (ihcpResetPwdUsr.Security_Question_Answer_Day_Of_Birth__c == dobAnswer) {
            System.debug('----------- Day of Birth correct');
            correctAnswers++;
        }
        System.debug('----------- correctAnswers ' + correctAnswers);
        if (correctAnswers < 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please answer two of the three security questions Note: Answers are case sensitive.'));
            return null;
        }
        // -------------------------------------------------------
        // Actual password change:
        // -------------------------------------------------------                  
        String resultMessage = setPassword(agsStUsr.SFDC_User__r.Id, this.newPassword);
        if (resultMessage != null) {
            System.debug('Password setting error: ' + resultMessage);
            return showErrorOnPage(resultMessage);
        } else {
            AGS_ST_DbUtils.updateStUserResetPasswordModifiedDateByUser(agsStUsr);
            System.debug('Last password modification date updated.');
        }

        PageReference pageRef = Site.login(agsStUsr.SFDC_User__r.Username, this.newPassword, '/AGS_ST_User_TC_Page_gne');
        return pageRef;
    }

    public PageReference changePassword() {
        PageReference pref = Site.changePassword(newPassword, verifyNewPassword, oldPassword);
        if (pref != null) {
            return showInfoOnPage('Your password has been changed !');
        }
        return null;
    }

    private PageReference prepareRegisterErrorPage(String errMessage) {
        PageReference pr = Page.AGS_ST_RegisterError_gne;
        pr.setRedirect(true);
        pr.getParameters().put('errMsg', errMessage);
        return pr;
    }

    private PageReference showErrorOnPage(String errorMessage) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        return null;
    }

    private PageReference showInfoOnPage(String infoMessage) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, infoMessage));
        return ApexPages.currentPage();
    }

    private String getPageParam(String paramName) {
        return System.currentPageReference().getParameters().get(paramName);
    }

    private String validatePassword(String password, String passwordConfirm) {
        if (password == null) {
            return 'Please provide Login ID and password.';
        }
        if (password.equals('')) {
            return 'Please provide Login ID and password';
        }
        if (passwordConfirm.equals('')) {
            return 'Please confirm password.';
        }
        if (!password.equals(passwordConfirm)) {
            return 'Please confirm: both password and password confirmation must be the same.';
        } else if (password.length() < 8) {
            return 'Password must be a minimum of 8 characters.';
        }
        return null;
    }

    private String setPassword(Id userId, String newPassword) {
        try {
            System.debug('Setting password for user: ' + userId);
            System.setPassword(userId, newPassword);
            System.debug('Password has been set.');

            return null;
        } catch (Exception e) {
            System.debug('Error while setting new password: ' + e.getStackTraceString());
            return preparePasswordValidationErrorMessage(e.getMessage());
        }
    }

    private String preparePasswordValidationErrorMessage(String fullExceptionMessage) {
        if (fullExceptionMessage == null) {
            return '';
        }

        Integer k = fullExceptionMessage.indexOf(':');
        if (k > 0) {
            return fullExceptionMessage.substring(k + 1);
        }
        return fullExceptionMessage;
    }

    public static Boolean isResetPasswordEmailValid(Datetime passwordChange, Datetime emailSent) {
        Datetime t = Datetime.now();
        //Decimal period = AGS_ST_Utils.getCustomSettings().Reset_Password_Link_Validity_Days__c;
        Decimal period = 7;
        if (period != null) {
            t = t.addDays(-((Integer) period));
        } else {
            t = t.addDays(-7);
        }

        if (t > emailSent) {
            return false;
        }

        if (passwordChange > emailSent) {
            return false;
        }
        return true;
    }

    public class IhcpAccess {
        public String mpsStatus { get; set; }
        public String lwoStatus { get; set; }
    }
}