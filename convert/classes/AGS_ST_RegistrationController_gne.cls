global without sharing class AGS_ST_RegistrationController_gne {

    Id userId, agsStUserId, acctId; // we have one registration controller, so we don't need this variables as page params

    String ihcpUserId;
    public Boolean useSims = false;
    public String email { get; set; }
    public ReCaptcha reCaptchaObj { get; set; }
    public AGS_ST_User regUser { get; set; }
    public Boolean correctResponse { get; private set; }
    public Boolean requiredCaptcha { get; private set; }
    public List<AGS_ST_QuizQuestionWithAnswers> questions { get; set; }
    public String assistRxSessionId { get; private set; }
    public String quizId { get; set; }
    public Boolean quizSendAvailable { get; set; }
    private List<ResponseRequest> wsLogItems = null;
    public List<SelectOption> physicianTypes { get; set; }
    public String physicianTypeSelected { get; set; }

    public Boolean isToolUsr { get; set; }
    public String availablePortals { get; set; }

    public Integer quizTries = 0;
    public Boolean isRequestAvailable { get; set; }

    public String acctIdRemote { get; set; }

    public String didYouKnow {
        get {
            return AGS_ST_DbUtils.getDidYouKnowText();
        }
        set;
    }

    public static AGS_ST_Settings_gne__c stSetting {
        get {
            return AGS_ST_Utils.getCustomSettingsInSite();
        }
        private set;
    }

    public static String sunshineTrackOrgWideAddress {
        get {
            return AGS_ST_Utils.getSunshineOrgWideAddress();
        }
    }

    public AGS_ST_RegistrationController_gne() {
        correctResponse = false;
        requiredCaptcha = false;
        reCaptchaObj = new ReCaptcha();
        this.regUser = new AGS_ST_User();
        this.quizSendAvailable = true;
        this.physicianTypeSelected = 'MD';
        this.physicianTypes = preparePhysicianTypes();
    }

    public PageReference goToLoginPage() {
        PageReference pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Login_gne');
        pr.setRedirect(true);
        return pr;
    }

    //********* AGS_ST_Landing_Registration_gne.page **************      
    public PageReference landingRegistrationSubmitEmailAction() {
        this.email = ApexPages.currentPage().getParameters().get('regEmail');
        this.regUser.email = this.email;
        System.debug('##Provided email: ' + this.email);
        userId = AGS_ST_DbUtils.findUserIdByEmail(email); // where username = email
        System.debug('##userId : ' + userId);
        availablePortals = '';
        PageReference pr;
        if (userId != null) {
            GNE_CM_IHCP_User__c ihcpUser = AGS_ST_DbUtils.getIHCPUser(userId);
            System.debug('-----ihcpUser : ' + ihcpUser);
            if (ihcpUser != null) {
                ihcpUserId = ihcpUser.Id;
                if (ihcpUser.AGS_ST_Status__c == 'Approved') {
                    isToolUsr = true;
                } else {
                    isToolUsr = false;
                    if (ihcpUser.MPS_Status__c == 'Approved') {
                        availablePortals += 'My Patient Solutions';
                    }
                    if (ihcpUser.LWO_Status__c == 'Approved') {
                        if (!String.isBlank(availablePortals)) {
                            availablePortals += ', ';
                        }
                        availablePortals += 'Lucentis Web Ordering';
                    }
                }
            }
        } else {
            isToolUsr = false;
        }
        System.debug('isToolUsr: ' + isToolUsr);
        System.debug('availablePortals: ' + availablePortals);
        return pr;
    }

    @RemoteAction
    global static SearchAcctWrap findAccountByNpiRemote(String npiParam, String emailAddress) {
        SearchAcctWrap saw = new SearchAcctWrap();
        try {
            System.debug('npiParam-----' + npiParam);

            List<Account> accounts = [SELECT Id, PersonContactId, LastName, DCH_Merge_Status_gne__c, DCH_Action_gne__c, MDMID_gne__c FROM Account WHERE NPI_vod__c = :npiParam];
            System.debug('accounts -----' + accounts);
            if (accounts.size() == 0) {
                saw.errorMsg = 'We could not find data account for provided NPI. Please try different NPI number or contact Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '. The entered NPI can not be located. Please confirm your NPI contact Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
                return saw;
            } else if (accounts.size() > 1) {
                saw = cleanAccounts(accounts, 'NPI');
                if (saw.id == null) {
                    return saw;
                }
            }
            String accId = (saw.id != null) ? saw.id : accounts[0].Id;

            List<User> existingUsersForAccount = [SELECT Id, Email, Username, AccountId FROM User WHERE AccountId = :accId];
            System.debug('existingUsersForAccount: ' + existingUsersForAccount);

            List<User> existingUsersForEmail = [SELECT Id, Email, Username, AccountId FROM User WHERE Username = :emailAddress ORDER BY CreatedDate DESC];

            System.debug('existingUsersForEmail: ' + existingUsersForEmail);
            if (existingUsersForAccount.size() == 1 && emailAddress.equals(existingUsersForAccount.get(0).Username)) {
                GNE_CM_IHCP_User__c ihcpUser = AGS_ST_DbUtils.getIHCPUser(existingUsersForAccount.get(0).Id);
                // user with ihcpUser.AGS_ST_Status__c != 'Approved' will pass the validation
                if (ihcpUser == null || ihcpUser.AGS_ST_Status__c == 'Approved') {
                    saw.errorMsg = 'User already exists for provided NPI. Please contact Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress;
                    return saw;
                }
            }
            // if user exists but its username != providedEmail
            else if (existingUsersForAccount.size() != 0) {
                saw.errorMsg = 'User already exists for provided NPI. Please contact Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
                return saw;
            } else if (existingUsersForEmail.size() != 0) {
                saw.errorMsg = 'User with provided email address already exists but it has different NPI number. Please contact Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
                return saw;
            }
            saw.id = accounts[0].Id;
            saw.lastName = accounts[0].LastName;
            return saw;
        } catch (Exception e) {
            saw.errorMsg = 'There was unexpected error. Please try again later or contact the Help Desk  at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '. ' + e.getMessage();
            return saw;
        }
    }

    @RemoteAction
    global static SearchAcctWrap findAccountByStateLicenseRemote(String licence, String state, String emailAddress) {
        SearchAcctWrap saw = new SearchAcctWrap();
        try {
            List<Prescriber_License_gne__c> licenses = [SELECT Account_gne__c FROM Prescriber_License_gne__c WHERE Name = :licence AND License_State_gne__c = :state];
            Set<String> ids = new Set<String>();
            for (Prescriber_License_gne__c license : licenses) {
                ids.add(license.Account_gne__c);
            }
            List<Account> accounts = [SELECT Id, PersonContactId, LastName, DCH_Merge_Status_gne__c, DCH_Action_gne__c, MDMID_gne__c FROM Account WHERE Id IN :ids];
            if (accounts.size() == 0) {
                saw.errorMsg = 'We could not find data for provided State License details. Please try different State License Number or State License Code or contact the Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
                return saw;
            }
            if (accounts.size() > 1) {
                saw = cleanAccounts(accounts, 'STATE');
                if (saw.id == null) {
                    return saw;
                }
            }
            String accId = (saw.id != null) ? saw.id : accounts[0].Id;

            List<User> existingUsersForAccount = [SELECT Id, Email, Username FROM User WHERE AccountId = :accId];
            System.debug('existingUsersForAccount: ' + existingUsersForAccount);

            List<User> existingUsersForEmail = [SELECT Id, Email, Username, AccountId FROM User WHERE Username = :emailAddress ORDER BY CreatedDate DESC];
            System.debug('existingUsersForEmail: ' + existingUsersForEmail);

            System.debug('existingUsersForEmail: ' + existingUsersForEmail);
            if (existingUsersForAccount.size() == 1 && emailAddress.equals(existingUsersForAccount.get(0).Username)) {
                GNE_CM_IHCP_User__c ihcpUser = AGS_ST_DbUtils.getIHCPUser(existingUsersForAccount.get(0).Id);
                // user with ihcpUser.AGS_ST_Status__c != 'Approved' will pass the validation
                if (ihcpUser == null || ihcpUser.AGS_ST_Status__c == 'Approved') {
                    saw.errorMsg = 'User already exists for data provided. Please try different State License Number or State License Code or contact the Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress;
                    return saw;
                }
            }
            // if user exists but its username != providedEmail
            else if (existingUsersForAccount.size() != 0) {
                saw.errorMsg = 'User already exists for data provided. Please try different State License Number or State License Code or contact the Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
                return saw;
            } else if (existingUsersForEmail.size() != 0) {
                saw.errorMsg = 'User with provided email address already exists but it has different State License Number or State License Code. Please contact Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
                return saw;
            }
            saw.id = accounts[0].Id;
            saw.lastName = accounts[0].LastName;
            return saw;
        } catch (Exception e) {
            saw.errorMsg = 'There was unexpected error. Please try again later or contact the Help Desk  at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '. ' + e.getMessage();
            return saw;
        }
    }

    public static SearchAcctWrap cleanAccounts(List<Account> accountsToClean, String searchType) {
        SearchAcctWrap saw = new SearchAcctWrap();
        String sType = '';
        if ('STATE'.equals(searchType)) {
            sType = 'State License';
        } else if ('NPI'.equals(searchType)) {
            sType = 'NPI';
        }

        List<Account> cleanedAccounts1 = new List<Account>();
        List<Account> cleanedAccounts2 = new List<Account>();

        for (Account acc : accountsToClean) {
            if (acc.MDMID_gne__c != null && acc.MDMID_gne__c != '') {
                cleanedAccounts1.add(acc);
            }
        }
        if (cleanedAccounts1.size() == 0) {
            saw.errorMsg = 'We could not find the correct data for ' + sType + ' provided. Please try different ' + sType + ' or contact the Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
            return saw;
        }
        if (cleanedAccounts1.size() == 1) {
            saw.id = cleanedAccounts1.get(0).Id;
            saw.lastName = cleanedAccounts1.get(0).LastName;
            return saw;
        }

        for (Account acc : cleanedAccounts1) {
            if (acc.DCH_Action_gne__c == 'Winner' && acc.DCH_Merge_Status_gne__c == 'Merge Completed') {
                cleanedAccounts2.add(acc);
            }
        }

        if (cleanedAccounts2.size() == 1) {
            saw.id = cleanedAccounts2.get(0).Id;
            saw.lastName = cleanedAccounts2.get(0).LastName;
        } else if (cleanedAccounts2.size() == 0) {
            saw.errorMsg = 'We could not find the correct data for ' + sType + ' provided. Please try different ' + sType + ' or contact the Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
        } else {
            saw.errorMsg = 'We could not find the correct data for ' + sType + ' provided. Please try different ' + sType + ' or contact the Help Desk at 877-313-5778 or ' + sunshineTrackOrgWideAddress + '.';
        }
        return saw;
    }

    global class SearchAcctWrap {
        public String id;
        public String lastName;
        public String errorMsg;
    }

//********* AGS_ST_Register_gne.page *************************
    public PageReference registerGoToAssistRxAction() {
        System.debug('------acctIdRemote' + acctIdRemote);
        System.debug('------regUser' + regUser);
        this.regUser.trimData();
        Message errorMsg = new Message();
        System.debug('##registerPage email: ' + this.email);
        if (!validateStUserData(errorMsg)) {
            return prepareErrorPage(errorMsg);
        }
        if (!createAgsStUser(errorMsg)) {
            return prepareRegisterErrorPage(errorMsg.text);
        }
        PageReference arxPageRef = Page.AGS_ST_AssistRx_Verification_gne;
        arxPageRef.getParameters().put('accountId', acctIdRemote);
        if (ihcpUserId != null) {
            System.debug('ihcpUser already exists with id=' + ihcpUserId + ', skipping ihcpUser creation');
            arxPageRef.getParameters().put('ihcpUserId', ihcpUserId);
        } else {
            arxPageRef.getParameters().put('ihcpUserId', '000');
        }
        arxPageRef.getParameters().put('agsstuserid', agsStUserId);
        System.debug('Parameter agsstuserid=' + agsStUserId + ' put into arxpageref;');
        arxPageRef.setRedirect(true);
        return arxPageRef;
    }

    private Boolean validateStUserData(Message message) {
        message.text = null;
        AGS_ST_UserValidator userDataValidator = new AGS_ST_UserValidator(this.regUser);
        String msg = userDataValidator.validate();
        if (msg != null) {
            message.text = msg;
            return false;
        }
        if (this.regUser.email != this.email) {
            message.text = 'Provided email address is different from email on the previous page!' + this.regUser.email + ',' + this.email + '.';
            return false;
        }
        return true;
    }

    private Boolean createAgsStUser(Message message) {
        if (!createAgsStUserWithStUser()) {
            message.text = 'There is an unexpected error. If error continues, please contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com';
            return false;
        }
        return true;
    }

    private Boolean createAgsStUserWithStUser() {
        try {
            agsStUserId = AGS_ST_DbUtils.createAgsStUser(this.regUser);
            System.debug('##AGS ST User ID created: ' + agsStUserId);
            return true;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            AGS_ST_Utils.logException('', 'Registration', 'AGS_ST_RegistrationController_gne', e, 'createAgsStUserWithStUser');
            return false;
        }
    }

//********* AGS_ST_Register_gne.page *************************
    public PageReference registerCancelAction() {
        PageReference pr = new PageReference(stSetting.Site_Domain_gne__c + '/SunshineTrackLogin/AGS_ST_Login_gne');
        pr.setRedirect(true);
        return pr;
    }

//********* AGS_ST_AssistRx_Verification_gne.page ************
    public PageReference assistRxVerificationLoadData() {
        this.quizSendAvailable = true;
        isRequestAvailable = true;
        System.debug('Entering assistRxVerificationLoadData(). User = ' + regUser);

        agsStUserId = ApexPages.currentPage().getParameters().get('agsstuserid');
        acctId = ApexPages.currentPage().getParameters().get('accountId');
        ihcpUserId = ApexPages.currentPage().getParameters().get('ihcpUserId');

        if (stSetting.Is_Arx_Skip_gne__c) {
            return checkAndRegisterUser();
        }
        try {
            System.debug('Parameter agsStUserId=' + agsStUserId + ' loaded');
            regUser = AGS_ST_DbUtils.findRegistrationUserData(agsStUserId);
            System.debug('### User found (X1): ' + regUser);
            if (regUser == null) {
                System.debug('AGS ST User not found: ' + agsStUserId);
                AGS_ST_Utils.logStError(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', '', 'We are unable to verify your account. Please call contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com', 'assistRxVerificationLoadData', 'Data');
                return this.prepareRegisterErrorPage('We are unable to verify your account. Please call contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com');
            }
            userId = AGS_ST_DbUtils.findUserIdByEmail(regUser.email);  // where username = email
            if (AGS_ST_DbUtils.isStUserLocked(agsStUserId)) {
                AGS_ST_Utils.logStError(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', '', 'User is locked. Please contact Your helpdesk.', 'assistRxVerificationLoadData', 'Data');
                AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'USR_LOCKED.');
                return this.prepareRegisterErrorPage('You have exceeded the number of log in attempts. Please contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com');
            }
        } catch (Exception e) {
            System.debug(e);
            AGS_ST_Utils.logException(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', e, 'assistRxVerificationLoadData');
            return this.prepareRegisterErrorPage('There is an unexpected error. If error continues, please contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
        }
        try {
            this.wsLogItems = new List<ResponseRequest>();
            AGS_ST_ARX_WsHelper wsHelper = new AGS_ST_ARX_WsHelper();
            AGS_ST_ARX_WebServiceClient.LoginResponse loginResponse = wsHelper.arxRequestLogIn();
            addLogItem(wsHelper);
            if (loginResponse.error != null) {
                AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'ARX_LOGIN_REQUEST_FAILED.');
                logWsItems();
                return this.prepareRegisterErrorPage('Additional information is required. Please  contact Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
            }
            this.assistRxSessionId = loginResponse.session_id;
            AGS_ST_ARX_WsHelper wsHelperQuiz = new AGS_ST_ARX_WsHelper();
            AGS_ST_ARX_WebServiceClient.QuizResponse quizResponse = wsHelperQuiz.arxRequestQuiz(this.assistRxSessionId, regUser);
            addLogItem(wsHelperQuiz);
            logWsItems();
            if (quizResponse.error != null) {
                AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'ARX_QUIZ_REQUEST_FAILED.');
                return this.prepareRegisterErrorPage('Additional information is required. Please  contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
            }
            if (quizResponse.is_identified == 'Y' && quizResponse.error == null) {
                if (quizResponse.quiz_id != null) {
                    System.debug('Quiz data retrieved.');
                    System.debug('---' + questions);
                    this.questions = wsHelperQuiz.convertToQuizQuestionsWithAnswers(quizResponse);
                    this.quizId = quizResponse.quiz_id;
                } else {
                    System.debug('No quiz questions.');
                    this.quizSendAvailable = false;
                    return checkAndRegisterUser();
                }
//AGS_ST_DbUtils.incrementAgsStUserLogTries(agsStUserId);
            }
        } catch (Exception e) {
            System.debug(e);
            AGS_ST_Utils.logException(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', e, 'assistRxVerificationLoadData');
            return this.prepareRegisterErrorPage('There is an unexpected error. If error continues, please call contact Help Desk at 877-313-5778 or SunshineQuestions@gene.com.');
        }
        return null;
    }

    public PageReference assistRxVerificationCheckAndRegisterUserAction() {
        try {
            System.debug('BEFORE checkQuiz');
            if (checkQuiz()) {
                System.debug('Quiz PASSED!');
                return checkAndRegisterUser();
            } else {
                this.quizSendAvailable = true;
                System.debug('Quiz NOT PASSED!');
                quizTries++;
                if (quizTries == 2) {
//addErrorMessage('Unfortunately there was a problem verifying your identify. Please contact sunshinequestions-d@gene.com or call our toll-free hotline at  (877) 313-5778.');
//isRequestAvailable = false;
                    return this.prepareRegisterErrorPage('Unfortunately there was a problem verifying your identify. Please contact ' + sunshineTrackOrgWideAddress + ' or call our toll-free hotline at (877) 313-5778.');
                } else if (quizTries == 1) {
                    addErrorMessage('Unfortunately there was a problem verifying your identify. Please try again with a new set of questions.');
                    this.wsLogItems = new List<ResponseRequest>();
                    AGS_ST_ARX_WsHelper wsHelper = new AGS_ST_ARX_WsHelper();
                    AGS_ST_ARX_WebServiceClient.LoginResponse loginResponse = wsHelper.arxRequestLogIn();
                    addLogItem(wsHelper);
                    if (loginResponse.error != null) {
                        AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'ARX_LOGIN_REQUEST_FAILED.');
                        logWsItems();
                        return this.prepareRegisterErrorPage('Error while executing quiz!');
                    }
                    this.assistRxSessionId = loginResponse.session_id;
                    AGS_ST_ARX_WsHelper wsHelperQuiz = new AGS_ST_ARX_WsHelper();
                    AGS_ST_ARX_WebServiceClient.QuizResponse quizResponse = wsHelperQuiz.arxRequestQuiz(this.assistRxSessionId, regUser);
                    addLogItem(wsHelperQuiz);
                    logWsItems();
                    AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'QUIZ_FAILED.');
                    if (quizResponse.error != null) {
                        AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'ARX_QUIZ_REQUEST_FAILED.');
                        return this.prepareRegisterErrorPage('There is an unexpected error. If error continues, please call contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
                    }
                    if (quizResponse.is_identified == 'Y' && quizResponse.error == null) {
                        if (quizResponse.quiz_id != null) {
                            System.debug('Quiz data retrieved.');
                            System.debug('---' + questions);
                            this.questions = wsHelperQuiz.convertToQuizQuestionsWithAnswers(quizResponse);
                            this.quizId = quizResponse.quiz_id;
                        } else {
                            return checkAndRegisterUser();
                        }
//AGS_ST_DbUtils.incrementAgsStUserLogTries(agsStUserId);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e);
            AGS_ST_Utils.logException(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', e, 'assistRxVerificationCheckAndRegisterUserAction');
            return this.prepareRegisterErrorPage('There is an unexpected error. If error continues, please call contact Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
        }
        return null;
    }

    public Boolean checkQuiz() {
        AGS_ST_User_gne__c tmpStUser = null;
        tmpStUser = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
        if (tmpStUser == null) {
            System.debug('AGS ST User not found: ' + agsStUserId);
            return false;
        }
        AGS_ST_ARX_WsHelper wsHelper = new AGS_ST_ARX_WsHelper();
        System.debug('---' + questions);
        List<AGS_ST_ARX_WebServiceClient.QuestionChoice> questionsChoices = wsHelper.convertFromQuizQuestionsWithAnswers(this.questions);
        List<ResponseRequest> wsLogItems = new List<ResponseRequest>();
        AGS_ST_ARX_WebServiceClient.ScoreQuizResponse scoreQuizResponse = wsHelper.arxRequestScoreQuiz(this.assistRxSessionId, this.quizId, questionsChoices);
        addLogItem(wsHelper);
        logWsItems();
        if (scoreQuizResponse.error == null && scoreQuizResponse.quiz_status == 'PASS') {
            return true;
        } else {
            return false;
        }
    }

    private PageReference checkAndRegisterUser() {
        try {
            System.debug('Entering checkAndRegisterUser...');
            System.debug('Entering checkAndRegisterUser...+agsStUserId' + agsStUserId);
            Message errorMsg = new Message();
            regUser = AGS_ST_DbUtils.findRegistrationUserData(agsStUserId);
            userId = AGS_ST_DbUtils.findUserIdByEmail(regUser.email);  // where username = email
            System.debug('regUser: ' + regUser);
            System.debug('userId: ' + userId);
            if (userId != null) {
                System.debug('User already exists with id=' + userId + ', creating User skipped');
            } else {
                Account acct = AGS_ST_DbUtils.findAccountById(acctId);
                System.debug('PersonContactId: ' + acct.PersonContactId);
                userId = createUser(acct.PersonContactId);
            }
            if (userId != null) {
                AGS_ST_User_gne__c agsStUser = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
                AGS_ST_DbUtils.assignPermissionSetToUser(userId);
                PageReference registrationFinishRef = new PageReference('/apex/AGS_ST_AfterUserCreation?usr=' + userId + '&agsStUserId=' + agsStUserId + '&ihcpUserId=' + ihcpUserId);
                registrationFinishRef.setRedirect(true);
                return registrationFinishRef;
            } else {
                AGS_ST_Utils.logStError(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', '', 'Error while creating new user.', 'checkAndRegisterUser', 'Data');
                return prepareRegisterErrorPage('There is an unexpected error. If error continues, please call contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
            }
        } catch (Exception e) {
            System.debug(e);
            AGS_ST_Utils.logException(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', e, 'checkAndRegisterUser');
            return this.prepareRegisterErrorPage('There is an unexpected error. If error continues, please call contact Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
        }
    }

    public PageReference sendToActivate() {
        try {
            agsStUserId = ApexPages.currentPage().getParameters().get('agsstuserid');
            userId = ApexPages.currentPage().getParameters().get('usr');
            ihcpUserId = ApexPages.currentPage().getParameters().get('ihcpUserId');
            String activationLink = AGS_ST_MailUtil.sendUserActivationEmail(agsStUserId);
            System.debug('-----activationLink' + activationLink);
            if (ihcpUserId == '000') {
                ihcpUserId = AGS_ST_DbUtils.insertIHCPUser('Approved', null, null, '', '', '');
            }
            AGS_ST_DbUtils.updateIHCPStatus(ihcpUserId, userId);
            AGS_ST_DbUtils.updateSTUser(agsStUserId, userId);
            User userForContact = AGS_ST_DbUtils.findUserById(userId);
            AGS_ST_DbUtils.updateContactEmail(userForContact.ContactId, userForContact.Username);
            AGS_ST_MailUtil.sendEmailAboutNewlyRegisteredUserWithDisputes(String.valueOf(agsStUserId));
            AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'Registration successful.');
            PageReference registrationFinishRef = new PageReference(activationLink);
            registrationFinishRef.setRedirect(true);
            return registrationFinishRef;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            AGS_ST_Utils.logException(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', e, 'sendToActivate');
            return this.prepareRegisterErrorPage('There is an unexpected error. If error continues, please call contact the Help Desk at 877-313-5778 or SunshineQuestions-d@gene.com.');
        }
    }

    private Id createUser(Id contactId) {
        try {
            Id tempUserId = AGS_ST_DbUtils.createNewUserNonSSO(this.regUser, this.regUser.email, 'GNE-CM-IHCP-PROFILE', contactId, 'portal.a Customer Person Account');
            return tempUserId;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            AGS_ST_Utils.logException(agsStUserId, 'Registration', 'AGS_ST_RegistrationController_gne', e, 'checkAndRegisterUser');
            return null;
        }
    }

// =========================================================================================================================================
    private PageReference prepareRegisterErrorPage(String errMessage) {
        PageReference pr = Page.AGS_ST_RegisterError_gne;
        pr.setRedirect(true);
        pr.getParameters().put('errMsg', errMessage);
        pr.getParameters().put('agsStUserId', agsStUserId);
        return pr;
    }

    private PageReference prepareErrorPage(Message message) {
        addErrorMessage(message.text);
        return ApexPages.currentPage();
    }

    private void addErrorMessage(String message) {
        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, message);
        ApexPages.addMessage(msg);
    }

    private void addLogItem(AGS_ST_ARX_WsHelper wsHelper) {
        ResponseRequest rr = new ResponseRequest();
        rr.request = wsHelper.lastRequest;
        rr.response = wsHelper.lastResponse;
        rr.status = wsHelper.lastRequestStatus;
        rr.level = wsHelper.lastLevel;
        rr.error = wsHelper.error;
        this.wsLogItems.add(rr);
    }

    private void logWsItems() {
        for (Integer i = 0; i < this.wsLogItems.size(); i++) {
            ResponseRequest rr = this.wsLogItems[i];
            AGS_ST_DbUtils.insertAssistRxManagement(this.agsStUserId, rr.level, rr.error, rr.status, rr.request, rr.response);
        }
    }

    private class Message {
        String text { get; set; }
    }

    private class ResponseRequest {
        String response { get; set; }
        String request { get; set; }
        String status { get; set; }
        String level { get; set; }
        String error { get; set; }
    }

    private List<SelectOption> preparePhysicianTypes() {
        List<SelectOption> pt = new List<SelectOption>();
        pt.add(new SelectOption('MD', 'Medical Doctors (MD)'));
        pt.add(new SelectOption('DO', 'Doctor of Osteopathy (DO)'));
        pt.add(new SelectOption('OD', 'Optometrist (OD)'));
        pt.add(new SelectOption('DPM', 'Podiatrist (DPM)'));
        pt.add(new SelectOption('DDS', 'Dentist (DDS)'));
        pt.add(new SelectOption('DC', 'Licensed Chiropractor (DC)'));
        pt.add(new SelectOption('OTHER', '-- Other --'));
        return pt;
    }

    public List<SelectOption> states {
        get {
            return AGS_ST_Utils.getStates();
        }
        set;
    }
}