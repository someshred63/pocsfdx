public without sharing class AGS_ST_RegistrationHelpDesk 
{
    Id userId, acctId;
    AGS_ST_User regUser;

    public Boolean              showDetails         { get; set; }  
    public String               buttonMsg           { get; set; }
    public Boolean              isEdit              { get; set; } 
    public Boolean              isSecurityCheck     { get; set; }
    public Boolean              isHelpDesk          { get; set; }
    public Boolean              isCreationMode      { get; set; }
    
    public List<AGS_ST_User_gne__c> agsStUsers      { get; set; }
    public AGS_ST_User_gne__c   agsStUserDetail     { get; set; }
    public AGS_ST_User_gne__c   newAgsStUser        { get; set; }
    public AGS_ST_Registration_gne__c newRegistration { get; set; }
    public String               createUserErrMsg    { get; set; }

    public List<AGS_ST_AssistRx_Management_gne__c>          assistRxList                { get; set; }
    public List<AGS_ST_SFDC_Registration_Error_Log_gne__c>  regErrorLog                 { get; set; }
    public List<AGS_ST_SFDC_Registration_Error_Log_gne__c>  loginErrorLog               { get; set; }
    public List<AGS_ST_SFDC_Registration_Error_Log_gne__c>  dispAccSettOther_ErrorLogs  { get; set; }
    public List<AGS_ST_HCP_HelpDesk_Comm_gne__c>            helpDeskCommunicationList   { get; set; }
    
    public AGS_ST_HCP_HelpDesk_Comm_gne__c newHelpDeskCommunication {get;set;}
    public Boolean sendActivationEmailButtonDisabled {get;set;}
    public Boolean resetPasswordButtonDisabled {get;set;}
    public Boolean unlockSTUserButtonDisabled {get;set;}
    public Boolean createUserButtonDisabled {get;set;} 
    public GNE_CM_IHCP_User__c iHcpUser {get;set;} 
    private String pageParamAgsStUsrId{get {return getPageParam('agsStUsrId');}}  
    public String agsStUserId;  
    private String pageParamArxId{get {return getPageParam('arxId');}}    
    private String pageParamErrorId{get {return getPageParam('errorId');}}  

    public String npiSearch{get;set;}
    public String firstNameSearch{get;set;}
    public String lastNameSearch{get;set;}
    public String usernameSearch{get;set;}
    public String citySearch{get;set;}
    public String stateSearch{get;set;}
    public String zipSearch{get;set;}
    public String stateLicenseNoSearch{get;set;}
    public String stateLicenseStateSearch{get;set;}
    public String state{get;set;}
    
    public String usrId {get; private set;}
    public String orgId {get; private set;}
    public String sourceId {get; private set;}
    public String targetURL {get; private set;}
    public String portalId {get; private set;}
    
    private static final String REGISTATION_ADDRESS = AGS_ST_Utils.getCustomSettings().Site_Domain_gne__c + '/SunshineRegistration';
    
    public List<SelectOption> genders 
    {    
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--NONE--'));
            options.add(new SelectOption('F','F'));
            options.add(new SelectOption('M','M'));
            return options;
        }
        set;
    }
    
    public String gender {get;set;}
    
    public AGS_ST_RegistrationHelpDesk(ApexPages.StandardController controller) 
    {
        newHelpDeskCommunication  = new AGS_ST_HCP_HelpDesk_Comm_gne__c (); 
        if(System.currentPageReference().getParameters().get('id') != null)
        {
            agsStUserId = System.currentPageReference().getParameters().get('id');
            isHelpDesk = false;
            goToDetailsAction(); 
        }
        else
        isHelpDesk = true;
        isCreationMode = false;
        orgId = UserInfo.getOrganizationId();
        targetURL = '/apex/AGS_ST_Home_gne';
        portalId = AGS_ST_Utils.getCustomSettings().PortalId__c;
    }

    public PageReference searchAgsStUserAction()
    {
        System.debug('searchAgsStUserAction: start');  
        showDetails = false;
        isEdit = false;
        isSecurityCheck = false;
        isCreationMode = false;
        system.debug('-----'+this.npiSearch+'-firstNameSearch'+firstNameSearch+'-lastNameSearch'+lastNameSearch+'-usernameSearch'+usernameSearch+'-citySearch'+citySearch+'-stateSearch'+stateSearch+'-zipSearch'+zipSearch+'-stateLicenseNoSearch'+stateLicenseNoSearch+'-stateLicenseStateSearch'+stateLicenseStateSearch+'-state'+state+'-gender'+gender);
        if(npiSearch=='' && firstNameSearch== '' && lastNameSearch== '' && usernameSearch== '' && citySearch== '' && zipSearch== '' && stateLicenseNoSearch== '' && stateLicenseStateSearch== '' && state== null)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please define your search.'));
            return null;
        }   
        this.agsStUsers = AGS_ST_DbUtils.getStForHelpDeskSeatch(npiSearch.replace('*','%'),firstNameSearch.replace('*','%'),lastNameSearch.replace('*','%'),usernameSearch.replace('*','%'),citySearch.replace('*','%'),state,zipSearch.replace('*','%'),stateLicenseNoSearch.replace('*','%'),stateLicenseStateSearch.replace('*','%'),gender);
        System.debug('goToErrorDetailsAction: end');        
        return null;
    }

    public PageReference showCreateSunUserForm() {
    	createUserErrMsg = '';
        newAgsStUser = new AGS_ST_User_gne__c(Alert_Dispute_Updates_gne__c = true, Alert_New_Payments_gne__c = true, Dispute_Contact_preferences_gne__c = 'Email', IsLocked_gne__c = false, Registration_Status__c = 'Failed');
        newRegistration = new AGS_ST_Registration_gne__c();
        isCreationMode = true;
        isHelpDesk = false;
        showDetails = false;
        return null;
    }

    public PageReference hideCreateSunUserForm() {
        isCreationMode = false;
        isHelpDesk = true;
        showDetails = false;
        return null;
    }

    public PageReference createSunUserForm() {
    	createUserErrMsg = '';

    	if(String.isBlank(newRegistration.ssn_gne__c) && String.isBlank(String.valueOf(newRegistration.dob_gne__c))) {
    		createUserErrMsg += 'SSN or Date Of Birth must be filled<br/>';
    	}
    	if(String.isBlank(newAgsStUser.NPI_gne__c) && (String.isBlank(newAgsStUser.State_License_gne__c) || String.isBlank(newAgsStUser.State_License_State_gne__c))) {
    		createUserErrMsg += 'State License or #NPI must be filled<br/>';
    	}
        if(String.isBlank(newAgsStUser.First_name__c)) {
            createUserErrMsg += 'First Name must be filled<br/>';
        }
        if(String.isBlank(newAgsStUser.Last_name__c)) {
            createUserErrMsg += 'Last Name must be filled<br/>';
        }
        if(String.isBlank(newAgsStUser.Email_address__c)) {
            createUserErrMsg += 'Email Address must be filled<br/>';
        }
        if(String.isBlank(newRegistration.City_gne__c)) {
            createUserErrMsg += 'City must be filled<br/>';
        }
        if(String.isBlank(newRegistration.State_gne__c)) {
            createUserErrMsg += 'State must be filled<br/>';
        }
        if(String.isBlank(newRegistration.Street_Address_gne__c)) {
            createUserErrMsg += 'Street Address must be filled<br/>';
        }
        if(String.isBlank(newRegistration.Zip_gne__c)) {
            createUserErrMsg += 'Zip Code must be filled<br/>';
        }
        if(!''.equals(createUserErrMsg) || !String.isBlank(createUserErrMsg)) {
        	return null;
        }
        try {
	    	insert newRegistration;
	    	newAgsStUser.AGS_ST_Registration_gne__c = newRegistration.Id;
	    	insert newAgsStUser;
	    	if(newAgsStUser != null) {
	    	   return new PageReference('/'+newAgsStUser.Id);
	    	}
        } catch(QueryException qe) {
        	createUserErrMsg = 'Error while creating Sunshine User data.';
        }
    	return null;
    }

    public PageReference editStUser()
    {
        isEdit = true;
        isSecurityCheck = false;
        return null;
    }
    
    public PageReference checkCheckSeqQuestions()
    {
        GNE_CM_IHCP_User__c tmpiHcpUser = AGS_ST_DbUtils.getIHCPUser(agsStUserDetail.SFDC_User__c);
        if(iHcpUser.Security_Question_Answer_City_Of_Birth__c != tmpiHcpUser.Security_Question_Answer_City_Of_Birth__c || iHcpUser.Security_Question_Answer_City_Of_Job__c!= tmpiHcpUser.Security_Question_Answer_City_Of_Job__c || iHcpUser.Security_Question_Answer_Day_Of_Birth__c!= tmpiHcpUser.Security_Question_Answer_Day_Of_Birth__c)
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Answers for security questions are incorrect.'));
        else
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Answers for security questions are correct.'));
        iHcpUser=tmpiHcpUser;
        return null;
    }
    
    public PageReference cancelSecurityQuestions()
    {
        isSecurityCheck = false;
        iHcpUser = AGS_ST_DbUtils.getIHCPUser(agsStUserDetail.SFDC_User__c);
        return null;
    }
    
    public PageReference editCheckSeqQuestions()
    {
        isSecurityCheck= true;
        isEdit = false;
        return null;
    }
    
    public PageReference saveSeqQuestions()
    {
        try
        {
            update iHcpUser;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Answers for security questions updated.'));
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'There was an error during update answers for security questions.'));
        }
        return null;
    }
    
    public PageReference goToArxPage()
    {
        PageReference arxPageRef = Page.AGS_ST_AssistRx_Verification_HD_gne;
        arxPageRef.getParameters().put('accountId',agsStUserDetail.Mapped_Account__c);
        arxPageRef.getParameters().put('ihcpUserId',iHcpUser.id);
        arxPageRef.getParameters().put('agsstuserid',agsStUserDetail.id);
        arxPageRef.setRedirect(true);
        return arxPageRef;
    }
    
    
    public PageReference saveStUser()
    {
        update agsStUserDetail;
        update agsStUserDetail.AGS_ST_Registration_gne__r;
        if(iHcpUser != null)
        {
            update iHcpUser;
        }
        isEdit = false;
        return null;
    }
    
    public PageReference cancelUpdateStUser()
    {
        agsStUserDetail = AGS_ST_DbUtils.findAgsStUserById(agsStUserDetail.id);  
        isEdit = false;
        return null;
    }
    
    public PageReference sendArxLink()
    {
        iHcpUser = AGS_ST_DbUtils.getIHCPUser(agsStUserDetail.SFDC_User__c);
        String emailBody =+ 'This is the link to your quiz which will verify your data. Please click <a href="'+REGISTATION_ADDRESS+'/AGS_ST_AssistRx_Verification_gne?accountId='+agsStUserDetail.Mapped_Account__c+'&ihcpUserId='+iHcpUser.id+'&agsstuserid='+agsStUserDetail.id+'">here</a>.';
        AGS_ST_MailUtil.sendEmail(agsStUserDetail.Email_address__c,'Sunshine Track admin','Your quiz link',emailBody,AGS_ST_Utils.getSunshineOrgWideAddressID());
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Email has been sent to following email:'+agsStUserDetail.Email_address__c));
        return null;
    }
    
    public PageReference createUserAction() {
        try {
            Account acct = AGS_ST_DbUtils.findAccountById(agsStUserDetail.Mapped_Account__c);
            AGS_ST_User_gne__c agsStUser = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
            List<User> usrList = [SELECT Id, Username, Email, AccountId FROM User WHERE Username = :agsStUser.Email_address__c];
            if(usrList.size() > 0) {
            	if(usrList.get(0).AccountId != acct.Id) {
		            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'SFDC User already exist and User Account doesn\'t match to Mapped Account.'));
		            return null;
            	} else {
                	userId = usrList.get(0).Id;
            	}
            } else {
                userId = createUser(acct.PersonContactId,agsStUserId);
                if(userId != null) {
                	AGS_ST_DbUtils.assignPermissionSetToUser(userId);
                } else {
                	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'SFDC User creation error.'));
                	return null;
                }
            }
            PageReference registrationFinishRef = new PageReference('/apex/AGS_ST_AfterUserCreationFromHd_gne?usr='+userId+'&agsStUserId='+agsStUserId);
            registrationFinishRef.setRedirect(true);
            return registrationFinishRef;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'There was an error with user creation'));
            return null;
        } 
    }

    private Id createUser(Id contactId,Id stUserId)
    {
        try
        {   
            regUser = AGS_ST_DbUtils.findRegistrationUserData(stUserId);
            Id tempUserId = AGS_ST_DbUtils.createNewUserNonSSO(this.regUser, this.regUser.email, 'GNE-CM-IHCP-PROFILE', contactId, 'portal.a Customer Person Account');             
            return tempUserId;              
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, e);    
            AGS_ST_Utils.logException(stUserId,'Registration','AGS_ST_RegistrationController_gne',e, 'checkAndRegisterUser');              
            return null;
        }
    }

    public PageReference sendActivationEmail() {
        try
        {
            userId = agsStUserDetail.SFDC_User__c;
            String ihcpUserId = AGS_ST_DbUtils.getIHCPUser(userId).Id;
            String activationLink = AGS_ST_MailUtil.sendUserActivationEmail(agsStUserId);
            if(ihcpUserId=='000')
            {
                ihcpUserId = AGS_ST_DbUtils.insertIHCPUser('Approved', null, null,'','','');
            }
            AGS_ST_DbUtils.updateIHCPStatus(ihcpUserId,userId);  
            AGS_ST_DbUtils.updateSTUser(agsStUserId, userId);
            //AGS_ST_MailUtil.sendAfterActivationEmail(userId);
            AGS_ST_UserRegLogger.updateRegistrationStatus(agsStUserId, 'Registration successful.');
            AGS_ST_MailUtil.sendSettingSecurityQuestionsEmail(userId, activationLink);
            //PageReference registrationFinishRef = new PageReference(activationLink);
            //registrationFinishRef.setRedirect(true);
            //return registrationFinishRef;
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, e);    
            AGS_ST_Utils.logException(agsStUserId,'Registration','AGS_ST_RegistrationController_gne',e, 'sendSecurityQuestions');
            return null; 
        }
    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Set Security Questions Email has been sent.'));
        return null;
    }

    public PageReference unlockSTUserAction()
    {
        System.debug('unlockSTUserAction: start');      
        AGS_ST_DbUtils.unlockStUser(this.agsStUserDetail);              
        buttonMsg = 'STUser unlocked.';             
        System.debug('unlockSTUserAction: end');
        return null;        
    }  
    
    public PageReference goToArxDetailsAction()
    {
        System.debug('goToArxDetailsAction: start');         
        PageReference pageRef = new PageReference('/'+this.pageParamArxId);
        pageRef.setRedirect(true);      
        System.debug('goToArxDetailsAction: end');
        return pageRef;
    }  
    
    public PageReference goToErrorDetailsAction()
    {
        System.debug('goToErrorDetailsAction: start');
        PageReference pageRef = new PageReference('/'+this.pageParamErrorId);
        pageRef.setRedirect(true);
        System.debug('goToErrorDetailsAction: end');
        return pageRef;
    }
    
    public PageReference goToIhcpUser()
    {
        String ihcpId = System.currentPageReference().getParameters().get('ihcpId');
        PageReference pr = new PageReference('/'+ihcpId);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference saveCommunication()
    {
        newHelpDeskCommunication.AGS_ST_User_gne__c = agsStUserId;
        insert newHelpDeskCommunication;
        newHelpDeskCommunication  = new AGS_ST_HCP_HelpDesk_Comm_gne__c ();
        this.helpDeskCommunicationList = AGS_ST_DbUtils.getHelpDeskCommunicationsForStUsr(agsStUserId);
        return null;
    }
    
    public PageReference goToDetailsAction() {    
        if(System.currentPageReference().getParameters().get('id') == null) {  
            agsStUserId = this.pageParamAgsStUsrId;
        }
        this.agsStUserDetail = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);  
        if(agsStUserDetail.Mapped_Account__c != null) {
            usrId = AGS_ST_DbUtils.findGneUserIdByAccountId(agsStUserDetail.Mapped_Account__c);
        }
        this.iHcpUser = AGS_ST_DbUtils.getIHCPUser(agsStUserDetail.SFDC_User__c);
        this.assistRxList = AGS_ST_DbUtils.getAssistRxManagementForAgsStUserId(agsStUserId); 
        for(AGS_ST_AssistRx_Management_gne__c arx : assistRxList) {
            if(arx.WS_Call_Parameters_Long_gne__c!=null && arx.WS_Call_Parameters_Long_gne__c!= '' && arx.WS_Call_Parameters_Long_gne__c.length() >50) {
                arx.WS_Call_Parameters_Long_gne__c= arx.WS_Call_Parameters_Long_gne__c.substring(0,50)+'...';
            }
            if(arx.WS_Call_Response_Long_gne__c!=null && arx.WS_Call_Response_Long_gne__c!= '' && arx.WS_Call_Response_Long_gne__c.length() >50) {
                arx.WS_Call_Response_Long_gne__c= arx.WS_Call_Response_Long_gne__c.substring(0,50)+'...';
            }
        }
        this.regErrorLog = AGS_ST_DbUtils.getRegistrationErrorLogForStUser(agsStUserId, 'Registration');
        this.loginErrorLog = AGS_ST_DbUtils.getRegistrationErrorLogForStUser(agsStUserId, 'Login');
        this.dispAccSettOther_ErrorLogs = AGS_ST_DbUtils.getRegistrationErrorLogForStUserAndAreaList(agsStUserId, new List<String>{'Dispute Tool', 'Account Settings', 'Other'});
        //this.dispAccSettOther_ErrorLogs = AGS_ST_DbUtils.getRegistrationErrorLogForStUser(agsStUserId, 'Dispute Tool');
        //this.dispAccSettOther_ErrorLogs.addAll(AGS_ST_DbUtils.getRegistrationErrorLogForStUser(agsStUserId, 'Account Settings'));
        //this.dispAccSettOther_ErrorLogs.addAll(AGS_ST_DbUtils.getRegistrationErrorLogForStUser(agsStUserId, 'Other'));
        this.helpDeskCommunicationList = AGS_ST_DbUtils.getHelpDeskCommunicationsForStUsr(agsStUserId);
        sourceId = agsStUserDetail.Mapped_Account__c;
        this.showDetails = true;
        return null;
    }      
    
    private String getPageParam(String paramName)
    {
        return System.currentPageReference().getParameters().get(paramName);
    } 
    
    public List<SelectOption> states
    {    
        get
        {
            return AGS_ST_Utils.getStates();
        }
        set;
    }
    
    public PageReference redirectDestinURL(){
        PageReference pg = new PageReference('/servlet/servlet.su?oid='+orgId+'&suportaluserid='+usrId+'&retURL='+sourceId+'&targetURL='+targetURL+'&suportalid='+portalId);
        return pg;
    }
}