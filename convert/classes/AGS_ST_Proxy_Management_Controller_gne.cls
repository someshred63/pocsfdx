public without sharing class AGS_ST_Proxy_Management_Controller_gne 
{  
    public Boolean useSims = false;   
         
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
      
    public String currentUser {get; set;}               
    public String respMsg {get; set;}               
    public Boolean isProxy {get; private set;}
    
    public List<AGS_ST_AssignedProxy> allNonPhysicianProxies  {get; set;}
    public List<AGS_ST_AssignedProxy> allPhysicianProxies {get; set;}
    public List<AGS_ST_AssignedProxy> allAssigneePhysicians {get; set;}
    public List<AGS_ST_AssignedProxy> allProxiesPhysicians {get; set;}
      
    private String pageParamProxyId{get {return getPageParam('proxy_id');}}     
    private String pageParamUserId{get {return getPageParam('user_id');}}
    private String pageParamDeleteId{get {return getPageParam('deleteId');}}
    private String pageParamAccountId{get {return getPageParam('acct_id');}}    
    private String pageParamEmail{get {return getPageParam('email');}}    
                                   
    
// #########################################################################################################
// #################################     ACTIONS - BEGIN    ################################################    
// #########################################################################################################
         
    public PageReference loadData() 
    {
        System.debug('loadData: enter');        
        AGS_ST_User_gne__c agsStUser = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId());                              
        this.isProxy = (agsStUser == null);
        System.debug('loadData, isProxy:' + this.isProxy);  
        if(this.isProxy)
        {
            // Check if 'Terms And Conditions' is accepted by proxy.
            AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyByUserId(UserInfo.getUserId());
            if(!proxy.tcAccepted_gne__c)
                return Page.AGS_ST_Proxy_TC_gne;
            
            allProxiesPhysicians = AGS_ST_AssignedProxy.getProxyPhysicians();           
        }
        else
        {
            allNonPhysicianProxies = AGS_ST_AssignedProxy.getNonPhysicianProxies();
            allPhysicianProxies = AGS_ST_AssignedProxy.getPhysicianProxies();
            allAssigneePhysicians = AGS_ST_AssignedProxy.getAssigneePhysicians();           
        }  
        
        User u = AGS_ST_DbUtils.findUserById(UserInfo.getUserId());
        this.currentUser = u.Username;
              
        System.debug('loadData: leave');                      
        return null;
    }
    
    public PageReference createAccountAction()
    {             
        System.debug('createAccountAction: enter');           
        AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyById(this.pageParamProxyId);   
        Id accountId = AGS_ST_DbUtils.insertAccount(proxy.FirstName_gne__c, proxy.LastName_gne__c, this.pageParamEmail);  
        System.debug('createAccountAction: accountId: ' + accountId);   
          
        return AGS_ST_Proxy_Management_PageHelper.prepareProxyCreateUserPage(accountId, this.pageParamProxyId);          
    } 
    
    public PageReference assignUserToProxyAction()
    {            
        System.debug('assignUserToProxyAction: enter');  
                       
        Account account = AGS_ST_DbUtils.findAccountById(this.pageParamAccountId);        
        AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyById(this.pageParamProxyId);
          
        System.debug('assignUserToProxyAction: inserting user...');
        Id physicianUserId = UserInfo.getUserId();         
        if(useSims)
        {
            Id proxyUserId = AGS_ST_DbUtils.insertUser(proxy.FirstName_gne__c, proxy.LastName_gne__c, account.PersonEmail, account.PersonContactId);                      
            System.debug('assignUserToProxyAction: userId: ' + proxyUserId);
            //updateProxy(this.pageParamProxyId, proxyUserId);
            //AGS_ST_MailUtil.sendEmailNewNonPhysicianProxyAssignedSIMS(proxy.id, physicianUserId, account.PersonEmail);                             
            //return AGS_ST_Proxy_Management_PageHelper.prepareSimsPage(proxy.id,proxyUserId);                       
                        
            return AGS_ST_Proxy_Management_PageHelper.prepareUpdateProxyUser(this.pageParamProxyId, proxyUserId, 'sims');
        }
        else
        { 
            Id proxyUserId = AGS_ST_DbUtils.insertUserNonSSO(proxy.FirstName_gne__c, proxy.LastName_gne__c, account.PersonEmail, account.PersonContactId);        
            System.debug('assignUserToProxyAction: userId: ' + proxyUserId);
            //AGS_ST_DbUtils.insertIHCPUser(proxyUserId, 'Submitted', null, null);
            //updateProxy(this.pageParamProxyId, proxyUserId);                    
            //AGS_ST_MailUtil.sendEmailNewNonPhysicianProxyAssigned(proxy.id, physicianUserId, account.PersonEmail);            
            //return AGS_ST_Proxy_Management_PageHelper.prepareProxyMangementPage();
            
            return AGS_ST_Proxy_Management_PageHelper.prepareUpdateProxyUser(this.pageParamProxyId, proxyUserId, '');
        }
    }
    
    public PageReference updateProxyUser()
    {       
        String proxyId = getPageParam('pu_proxy_id'); 
        String proxyUserId = getPageParam('pu_user_id');
        String goToSims = getPageParam('pu_goto_sims');
        
        updateProxy(proxyId, proxyUserId);
        
        if(AGS_ST_Utils.hasValue(goToSims))
            return AGS_ST_Proxy_Management_PageHelper.prepareSimsPage(proxyId, proxyUserId);
        else
            return AGS_ST_Proxy_Management_PageHelper.prepareProxyMangementPage();
    }           
         
    private void updateProxy(String proxyId, String userId) 
    {
        System.debug('updateProxy, proxyId: ' + proxyId + ', userId: ' + userId);
        AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyById(proxyId);
        proxy.User_gne__c = userId;           
        update proxy;
        System.debug('proxy updated.');
    }
    
    public PageReference createSIMSUserAction()
    {
        System.debug('createSIMSUserAction: entered');    
        AGS_ST_SIMS_RegistrationHelper_gne registrationHelper = new AGS_ST_SIMS_RegistrationHelper_gne();       
        Boolean userCreated = registrationHelper.registerProxy(this.pageParamProxyId, this.pageParamUserId); // Send to SIMS to create new user:
        System.debug('createSIMSUserAction  userCreated:' + userCreated);
        
        return AGS_ST_Proxy_Management_PageHelper.prepareCreatePermissionsPage(this.pageParamUserId);            
    }
    
    public PageReference assignPermissionSetToUserAction()
    {
        System.debug('assignPermissionSetToUserAction: enter');               
        Boolean success = AGS_ST_DbUtils.assignPermissionSetToUser(this.pageParamUserId); // check if it is already assigned ?
        System.debug('assignPermissionSetToUser status:' + success);
        
        return AGS_ST_Proxy_Management_PageHelper.prepareProxyMangementPage();          
    }
               
    public PageReference deleteProxyAssociationAction()
    {   
        System.debug('deleteProxyAssociationAction: deleteId: ' + this.pageParamDeleteId);                              
        // Check if non-physician proxy is beeing removed:
        String nonPhysicianProxyId = null; 
        AGS_ST_Proxy_Association_gne__c proxyAssoc = AGS_ST_DbUtils.findProxyAssociationById(this.pageParamDeleteId);    
        Boolean isNonPhysicianProxyToDelete = (proxyAssoc.Proxy_gne__c != null);  
        System.debug('deleteProxyAssociationAction: isNonPhysicianProxyToDelete: ' + isNonPhysicianProxyToDelete);
               
        if(isNonPhysicianProxyToDelete)
        {
            nonPhysicianProxyId = proxyAssoc.Proxy_gne__r.id;
            System.debug('deleteProxyAssociationAction: nonPhysicianProxyId: ' + nonPhysicianProxyId);   
        }
        
        Boolean delSuccess = AGS_ST_DbUtils.deleteProxyAssociation(this.pageParamDeleteId);   
        System.debug('deleteProxyAssociationAction: delSuccess: ' + delSuccess);   
        
        // When non-physician proxy removed: remove permissionset for user.
        if(isNonPhysicianProxyToDelete)
        {           
            boolean hasMoreAssociations = AGS_ST_DbUtils.nonPhysicianProxyHasAssociations(nonPhysicianProxyId);
            if(!hasMoreAssociations)
            {
                AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyById(nonPhysicianProxyId);
                String proxUserId = proxy.User_gne__r.id;
                
                System.debug('removePermissionSetFromUser, proxyUserId' + proxUserId);   
                AGS_ST_DbUtils.removePermissionSetFromUser(proxUserId);
            }            
            // Clear disputes for proxyId
            String disputeOwnerUserId = proxyAssoc.AGS_ST_User_gne__r.SFDC_User__c;
            System.debug('clearProxyForPhysicianDisputes, disputeOwnerUserId:' + disputeOwnerUserId + ', nonPhysicianProxyId: ' + nonPhysicianProxyId);   
            AGS_ST_DbUtils.clearProxyForPhysicianDisputes(disputeOwnerUserId, nonPhysicianProxyId);
        }
        System.debug('deleteProxyAssociationAction: leave');
        return AGS_ST_Proxy_Management_PageHelper.prepareProxyMangementPageForRefresh();       
    }                
            
    public PageReference createProxyAction()
    {
/*
    Short description of user proxy creation process:
    0. Data validation.
    1. User entered firstName, lastName and email in a html form -> Person object containing that data is created (lets call that object: uiPerson). 
    2. Check if physician (stUser) for uiPerson object data (fname, lname, email) exists (lets call the stUser object: uipStUser). 
    3. If uipStUser exists (this is PhysicianAsAProxy case):
         Check if proxy association [stUserLoggedIn, uipStUser] already exists.
            - if proxy association already exist: show message (end).
            - if proxy association doesnt exist: create proxy association for [stUserLoggedIn, uipStUser] and send email notification for users (end).                   
    4. If uipStUser does not exist (this is NonPhysicianProxy case):
         Check if uiPerson (uipNonPhysicianProxy) exists in AGS_ST_Proxy table.
            - if proxy exists (AGS_ST_Proxy table contains uiPerson data):
                Check if proxy association (in AGS_ST_Proxy_Association) exists for [stUserLoggedIn, uipNonPhysicianProxyId]:
                    - if proxy association (nonPhysician proxy association) already exists: show message (end).
                    - if proxy association does NOT exist: create proxy association and send emails for users (end).                    
            - if proxy does NOT exist (AGS_ST_Proxy table does NOT contain uiPerson data):
                Search for User (User table) with uiPerson data:
                    - if user found: create proxy, proxy association, send email notification and add permissions for user (end).
                    - if user NOT found: create proxy, proxy association and create account for uiPerson.               
*/      
        
        String validationMessage = validateFormData();
        if(validationMessage != null)
        {
            return this.prepareMessage(validationMessage);
        }           

        AGS_ST_User_gne__c stUserLoggedIn = AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()); 
        System.debug('Currently logged physician: '+ stUserLoggedIn.Email_address__c);
        if (stUserLoggedIn == null) 
        {           
             return this.showMessageAccountDeleted();
        }       
        if(stUserLoggedIn.Email_address__c == this.email)
        {
            return this.showMessageAssignedLoggedPhysician();
        }
        System.debug('Validation finished.');        
   
        System.debug('User entered form data (uiPerson):' + this.firstName + ' ' + this.lastName + ' ' + this.email);                  
        Person uiPerson = new Person(this.firstName, this.lastName, this.email);    
                                             
        System.debug('Check if stUser with form data: firstName, lastName and email already exists (uipStUser) in AGS_ST_User.');
        AGS_ST_User_gne__c uipStUser = AGS_ST_DbUtils.findAgsStUser(uiPerson.firstName, uiPerson.lastName, uiPerson.email);       
        boolean uipStUserExists = (uipStUser != null);  
        if(uipStUserExists)
        { 
            System.debug('uipStUser exists in AGS_ST_User table: this is PhysicianAsAProxy case.');                     
            
            System.debug('Check if proxy association [stUserLoggedIn, uipStUser] already exists.');
            AGS_ST_Proxy_Association_gne__c assocForPhysicianProxy = AGS_ST_DbUtils.findProxyAssociationForPhisicianProxyST(stUserLoggedIn.id, uipStUser.id);
            boolean isPhysicianAsAProxy = (assocForPhysicianProxy != null);                   
            if(isPhysicianAsAProxy)
            {
                System.debug('Proxy (physician proxy association) already exists -> show message to user (end).');
                return this.showMessageProxyAlreadyExists(uiPerson);
            } 
            else
            { 
                System.debug('Proxy for existing stUser (uipStUser) does NOT exist yet -> create proxy association.');
                AGS_ST_Proxy_Association_gne__c proxyAssociation = AGS_ST_DbUtils.createProxyAssociationForPhysicianST(stUserLoggedIn.id, uipStUser.id);    
                boolean success = (proxyAssociation != null);
                if(success)
                {
                    System.debug('Proxy association created -> send notification for users (end).');  
                    //AGS_ST_MailUtil.sendEmailPhysicianProxyAssigned(stUserLoggedIn.Email_address__c, stUserLoggedIn.First_name__c, stUserLoggedIn.Last_name__c, uipStUser.First_name__c, uipStUser.Last_name__c, uipStUser.Email_address__c);   
                    
                    System.debug('Emails notifications sent for stUserLoggedIn and uipStUser -> refresh page.');
                    return AGS_ST_Proxy_Management_PageHelper.prepareProxyMangementPageForRefresh();                    
                }
            }       
        }
        else
        {
            System.debug('uipStUser does NOT exist in AGS_ST_User table: this is NonPhysicianProxy case.');    
            
            System.debug('Check if uiPerson (uipNonPhysicianProxy) exists in AGS_ST_Proxy table.');
            Id uipNonPhysicianProxyId = AGS_ST_DbUtils.findProxyId(uiPerson.firstName, uiPerson.lastName, uiPerson.email);    
            boolean uipNonPhysicianProxyExists = (uipNonPhysicianProxyId != null);       
            if(uipNonPhysicianProxyExists)
            {
                System.debug('Proxy exists (AGS_ST_Proxy table contains uiPerson data).');  
                
                System.debug('Check if proxy association (in AGS_ST_Proxy_Association) exists for [stUserLoggedIn, uipNonPhysicianProxyId].');
                AGS_ST_Proxy_Association_gne__c association = AGS_ST_DbUtils.findProxyAssociationForProxyST(stUserLoggedIn.id, uipNonPhysicianProxyId);                
                boolean associationForNonPhysicianExists = (association != null);                               
                if(associationForNonPhysicianExists)
                {
                    System.debug('Proxy association (nonPhysician proxy association) already exists -> show message.');
                    return this.showMessageProxyAlreadyExists(uiPerson);
                }               
                else                 
                {
                    System.debug('Proxy association (nonPhysician proxy association) does NOT exists -> create association.');
                    AGS_ST_Proxy_Association_gne__c proxyAssociationForNonPhysician = AGS_ST_DbUtils.createProxyAssociationForNonPhysicianST(stUserLoggedIn.id, uipNonPhysicianProxyId);               
                    boolean proxyAssociationCreated = (proxyAssociationForNonPhysician != null);                                                                                    
                    if(proxyAssociationCreated)
                    {
                        System.debug('Proxy association created for (stUserLoggedIn.id, uipNonPhysicianProxyId)');
                        User proxyUser = AGS_ST_DbUtils.findUserByProxyId(uipNonPhysicianProxyId);                                                      
                        //AGS_ST_MailUtil.sendEmailNonPhysicianProxyAssigned(stUserLoggedIn.Email_address__c, stUserLoggedIn.First_name__c, stUserLoggedIn.Last_name__c, proxyUser.firstname, proxyUser.lastname, proxyUser.Email);
                        
                        System.debug('Email notifications sent for stUserLoggedIn and uipNonPhysicianProxy -> refresh page.');
                        return AGS_ST_Proxy_Management_PageHelper.prepareProxyMangementPageForRefresh();
                    }                                                       
                } 
            }
            else
            {
                System.debug('Proxy does NOT exist (AGS_ST_Proxy table does NOT contain uiPerson data).');  
                
                System.debug('Searching for User (User table) with uiPerson data.');                                         
                User user = AGS_ST_DbUtils.findUser(uiPerson.firstName, uiPerson.lastName, uiPerson.email);
                if(user != null)
                {
                    System.debug('User found for uiPerson -> validate user profile.');
                    Id profileId = AGS_ST_DbUtils.findProfileIdByName('GNE-CM-IHCP-PROFILE');   
                    Boolean userProfileIsValid = (user.IsActive && user.ProfileId == profileId);                    
                    if(userProfileIsValid)
                    {
                        System.debug('User profile is valid -> create new proxy (AGS_ST_Proxy)');                        
                        AGS_ST_Proxy_gne__c newProxy = AGS_ST_DbUtils.insertNewProxy(uiPerson.firstName, uiPerson.lastName, user.Id);                                                                      
                        
                        System.debug('Proxy created -> create new proxy association.');
                        AGS_ST_Proxy_Association_gne__c association = AGS_ST_DbUtils.createProxyAssociationForNonPhysicianST(stUserLoggedIn.Id, newProxy.id);                
                        
                        System.debug('Proxy association created -> send email notification for users.');
                        //AGS_ST_MailUtil.sendEmailNonPhysicianProxyAssigned(stUserLoggedIn.Email_address__c, stUserLoggedIn.First_name__c, stUserLoggedIn.Last_name__c, user.firstname, user.lastname, user.Email);   
                        
                        System.debug('Emails sent -> go to CreatePermissionsPage to continue.');
                        return AGS_ST_Proxy_Management_PageHelper.prepareCreatePermissionsPage(user.id);                                                           
                    }                                   
                }
                else
                {
                    System.debug('User NOT found for uiPerson data -> create new nonPhysicianProxy for NOT existing user.');                                                           
                    AGS_ST_Proxy_gne__c newProxy = AGS_ST_DbUtils.insertNewProxy(uiPerson.firstName, uiPerson.lastName, null);                                                                      
                                        
                    System.debug('New proxy created -> create new proxy association.');
                    AGS_ST_Proxy_Association_gne__c association = AGS_ST_DbUtils.createProxyAssociationForNonPhysicianST(stUserLoggedIn.Id, newProxy.id);                
                    
                    System.debug('Proxy association created -> go to ProxyCreateAccountPage to continue.');
                    return AGS_ST_Proxy_Management_PageHelper.prepareProxyCreateAccountPage(newProxy.id, uiPerson.email);                                                                                           
                }               
            }           
        }                   
        System.debug('createProxyAction:: ERROR PAGE.');                
        return AGS_ST_Proxy_Management_PageHelper.prepareErrorPage();          
    }                                    

// #########################################################################################################
// ###################################     ACTIONS - END    ################################################    
// #########################################################################################################                                                                  
                    
                                           
    private String validateFormData()
    {
        if(!AGS_ST_Utils.hasValue(this.email) && !AGS_ST_Utils.hasValue(this.firstName) && !AGS_ST_Utils.hasValue(this.lastName))
        {
            return 'Fields \'First Name\', \'Last Name\' and \'Email\' must not be empty!';                 
        }               
        if(!AGS_ST_Utils.validateEmail(this.email))
        {
           return 'Invalid e-mail address format!';                
        }          
        if(!AGS_ST_Utils.isAlpha(this.firstName))
        {
            return 'Field \'First Name\' can only contain letters!';               
        }        
        if(!AGS_ST_Utils.isAlpha(this.lastName))
        {
            return 'Field \'Last Name\' can only contain letters!';              
        }
        return null;
    }        
    
    private String getPageParam(String paramName)
    {
        return System.currentPageReference().getParameters().get(paramName);
    }       
                
    private PageReference prepareMessage(String message)
    {
        this.addErrorMessage(message);
        return ApexPages.currentPage();
    }
    
    private PageReference showMessageProxyAlreadyExists(Person person)
    {
        String message = 'Proxy already exists: ' + person.firstName + ' ' + person.lastName;
        this.addErrorMessage(message);
        return ApexPages.currentPage();
    }
    
    private PageReference showMessageAssignedLoggedPhysician()
    {
        String message = 'You cannot assign yourself as a proxy';
        this.addErrorMessage(message);
        return ApexPages.currentPage();
    }
    
    private PageReference showMessageAccountDeleted()
    {
        String message = 'Your physician account have been deleted. Please contact helpdesk';
        this.addErrorMessage(message);
        return ApexPages.currentPage();     
    }
    
    private void addErrorMessage(String message)
    {
        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, message);       
        ApexPages.addMessage(msg);  
    }               
    
    private class Person
    {
        public String firstName {get; private set;}
        public String lastName {get;private set;}       
        public String email {get;private set;}
        
        public Person(String firstName, String lastName, String email)
        {
            this.firstName = trim(firstName);
            this.lastName = trim(lastName);
            this.email = trim(email);
        }   
        
        private String trim(String s)
        {
            if(s == null)
                return null;
            return s.trim();                            
        }   
    }           
}