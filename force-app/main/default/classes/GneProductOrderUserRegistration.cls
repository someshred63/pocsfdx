public without sharing class GneProductOrderUserRegistration
    {    
        static GneProductOrderGetAccountInfo.AccountInfo accountInfo = null;
        
        static Integer ENV_DEV  = 0;
        static Integer ENV_QA   = 1;
        static Integer ENV_UAT  = 2;
        static Integer ENV_PROD = 3;
        static Integer ENV_ORD  = 4;
        
        static String  defaultLocaleKey = 'en_US';    
        static String  defaultLanguageLocaleKey = 'en_US';   
        static String  defaultEmailEncodingKey = 'ISO-8859-1';    
        static String  defaultEmail = 'lucentisdirect@gene.com';
        static String  defaultAlias    = 'LWOUSER';
        static String  affiliationRole = 'Affiliated with';
        static String  defaultTimeZone = 'America/Los_Angeles'; 
        
        static Integer currentEnv = 0;
        static String  usernameSuffix = null;
        static String  profileId = null;
        static String  recordTypeId = null; 
        static String  sapId = null;
        static String  lwouserId = null;
        static Boolean isaccoutManager=false;
        static Boolean ispractiseManager=true;
        
        
        static
        {
            accountInfo = new GneProductOrderGetAccountInfo.AccountInfo();          
        }       
        
        public class RegistrationMessage
        {
            
            public String message;
            public String code;
            
            public String getCode()
            {
                return code;
            }
            
            public void setCode(String value)
            {
                code = value;
            }
            
            public String getMessage()
            {
                return message;
            }
            
            public void setMessage(String value)
            {
                message = value;
            }
        }
    
    
        public class LWOUserCheck
        {
            public GNE_LWO_User__c lwo_user{get;set;}
            boolean isExist{get;set;} 
        }
    
        public static RegistrationMessage provisionUser(String sapAccountId, String firstName, String lastName, String middleName, 
        String emailAddress, String phone, boolean isPhysician, String role)
        {
            ispractiseManager = isPhysician ? false : true;
            System.debug('inside GneProductOrderUserRegistration ***');        
            System.debug('Firstname'+ firstname+ 'Lastname' + lastname);
            
            sapId = sapAccountId;
            
            if (role == 'Account Manager')
            {
                isAccoutManager=true;
            }
            
            // set username prefix based on env
            currentEnv = getEnv();  
            
            RegistrationMessage msg = new RegistrationMessage();
            
            // get account for this SAP Id
            Account account = getAccountBySapId();
            
            // if account found
            if (account != null)
            {
                String accountId = account.Id;
                Boolean isPersonAccount = account.IsPersonAccount;
                
                recordTypeId = getRecordTypeId();
                
                if (recordTypeId == null)
                {             
                    System.debug('Record Type cannot be found ..............');
                    msg.setCode('false');
                    msg.setMessage('Record Type <LWO HealthCare Professional> cannot be found in SFDC');
                    return msg;
                }
                
                profileId = getProfileId();                     
                if (profileId == null)
                {                
                    System.debug('Profile cannot be found.................');
                    msg.setCode('false');
                    msg.setMessage('Profile <GNE-LWO-USER> cannot be found in SFDC');
                    return msg; 
                }
                
                // get ID of some LWO user with first/last name 'lwouser runas'
                lwouserId = getLWOUserId();                                
                if (lwouserId == null)
                {                
                    System.debug('LWO User Id cannot be found');
                    msg.setCode('false');
                    msg.setMessage('Profile <GNE-LWO-USER Id> cannot be found in SFDC');
                    return msg; 
                }
                
                GNE_CM_IHCP_User__c ihcpUser = getExistingIHCPUser(emailAddress);
                User existingMpsUser = null;
                
                // make sure an IHCP user for username does not already exist
                if (ihcpUser != null)
                {                   
                    if (ihcpUser.LWO_Status__c != 'No Access' && ihcpUser.LWO_Status__c != null && ihcpUser.LWO_Status__c != '')
                    {
                        msg.setCode('false');
                        msg.setMessage('An LWO user with this email already exists.');
                        return msg;
                    }
                    else
                    {
                        existingMpsUser = [SELECT Id, Username, ContactId, IsActive FROM User WHERE Id = :ihcpUser.SFDC_User__c];
                    }
                }
                else
                {
                    // get potential existing MPS users for the given username
                    List<User> matchingMPSUsers = GNE_CM_IHCP_User_Util.getExistingPortalUser(emailAddress, 'MPS');
                    
                    // if there are already some MPS users for this username
                    if (!matchingMPSUsers.isEmpty())
                    {
                        if (matchingMPSUsers.size() > 1)
                        {
                            // there can be at most 1 user for the username
                            throw new GNE_CM_Exception('More than one MPS user found for username ' + emailAddress + '. Users found: ' + matchingMPSUsers);
                        }
                        
                        // select the user again with the contact id
                        existingMpsUser = [SELECT Id, Username, ContactId, IsActive FROM User WHERE Id = :matchingMPSUsers.get(0).Id LIMIT 1];
                    }       
                }
                
                
                // if there are already some MPS users for this username
                if (existingMpsUser != null)
                {   
                    System.debug ('Processing existing MPS user with ID = ' + existingMpsUser.Id);
                    
                    // create an LWO user for the existing SFDC user
                    msg = processExistingUser (existingMpsUser, accountId, firstName, lastName, middleName, emailAddress, phone, ihcpUser);
                    
                    if (ihcpUser == null)
                    {
                        System.debug('Converting existing MPS user (' + existingMpsUser.Id + ') to IHCP');
                        updateUserProfileToIHCP(existingMpsUser.Id);
                        
                        // add the MPS permission set to the converted MPS-SFDC user (@future)
                        GNE_CM_IHCP_User_Util.addMpsPermissionSet(new List<Id> { existingMpsUser.Id }, false);
                    }
                }
                else
                {                                                   
                    // create an new LWO user with a new SFDC user                                                                                               
                    msg = provisionPhysicianUser(accountId, firstName, lastName, middleName, emailAddress, phone);      
                }                               
            } 
            else // account with SAP Id not found
            {
                msg.setCode('false');
                msg.setMessage('Error provisioning ' + emailAddress +' for ' + sapAccountId + ' in SFDC LDD account does not exist in SFDC');                          
            }
            
            System.debug('code=====' + msg.getCode() + ', message ===== ' + msg.getMessage());
            return msg;                                                 
        }
        
        @future
        private static void updateUserProfileToIHCP (Id sfdcUserId)
        {
            try
            {
                List<User> users = [SELECT Id FROM User WHERE Id = :sfdcUserId LIMIT 1];
                if (users.isEmpty())
                {
                    throw new GNE_CM_Exception('No users found for ID = ' + sfdcUserId);
                }
                
                users.get(0).ProfileId = GNE_CM_IHCP_Utils.getIHCPPortalProfileId();
                update users.get(0);
            }
            catch (Exception e)
            {
                GNE_CM_MPS_Utils.insertError('GneProductOrderUserRegistration', 'Error', 'updateUserProfileToIHCP', 'Apex', GlobalUtils.getExceptionDescription(e));
            }
        }
        
        private static GNE_CM_IHCP_User__c getExistingIHCPUser (String username)
        {
            String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
            String potentialUsername = username + ((env != null && env != '' && env != 'PROD') ? '.' + env : '');
            
            system.debug('Potential IHCP UserName: ' + potentialUsername);
            
            List<GNE_CM_IHCP_User__c> ihcpUsers = [SELECT Id, LWO_Status__c, MPS_Status__c, Name, SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE Name = :potentialUsername];
            
            if (ihcpUsers.size() > 1)
            {
                throw new GNE_CM_Exception('More than one IHCP user found with name = ' + username + ': ' + ihcpUsers);
            }
            
            return ihcpUsers.isEmpty() ? null : ihcpUsers.get(0);
        }
        
        private static RegistrationMessage processExistingUser (User usr, String accountId, String firstName, String lastName,
        String middleName, String emailAddress, String phone, GNE_CM_IHCP_User__c existingIHCPUser)
        {
            System.debug('Enter processExistingUser........................');
            RegistrationMessage msg = new RegistrationMessage();
            String userContactId = usr.ContactId;
            
            //check user already exists as a LWO user 
            
            if(checkLWOUserExists(usr))
            {
                msg.setCode('false'); 
                msg.setMessage('An LWO user with this email already exists.');
                return msg;
            }
            //check for Account
            List<Account> accounts = [Select Id, Web_Order_Enabled_gne__c from Account where PersonContactId = :userContactId limit 10];
            
            Integer retCode = 0;            
            Savepoint sp = Database.setSavepoint();
            
            try {
                
                if( accounts!=null && accounts.size() == 0) {
                    
                    //let custOps open a remedy ticket and sysAdmin has to manually investigate whether to create brand new user and assign LWO permission set and create person account and de activate existing user 
                    msg.setCode('false');
                    msg.setMessage('Email already exists. User has no person account. Please check with System Administrator to setup LWO Permission!'); 
                    return msg;   
                }
                else {
                    // User is a Person Account
                    Account obj = accounts.get(0);
                    obj.Web_Order_Enabled_gne__c=true;
                    update obj;
                    String userAccountId = obj.Id;                              
                    retCode = createAffiliation(accountId, userAccountId, true);                    
                }       
                
                if( retCode != 0 )
                Database.rollback(sp);
                
                if( retCode == 1) {
                    msg.setCode('false');
                    msg.setMessage('Cannot find Product Catalog in QueueSobject'); 
                    return msg;                     
                } 
                else if( retCode == 2) {
                    msg.setCode('false');
                    msg.setMessage('Cannot find GNE-LWO-CUSTOPS in Group'); 
                    return msg;                                                                     
                }
                else if( retCode == 3) {
                    msg.setCode('false');
                    msg.setMessage('Failed to create affiliation for the username ' +  emailAddress);
                    return msg;                                                                     
                }
                
                /*usr.firstName = firstName;
                        usr.lastName = lastName;
                        usr.phone = phone;
                        usr.IsActive = true;
                        update usr;*/    
                List<Id> existinguserId = new List<Id>();
                existinguserId.add(usr.Id);
                
                // update IHCP user with access both to LWO and MPS
                createUpdateLWOIHcpUser (usr, emailAddress, existingIHCPUser, true, true);  
                
                //Create LWO User record            
                LWOUserCheck lwo_user_current = createLWOUser(usr);
                
                
                // reuse variable
                if(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c!=null)
                {
                    lwo_user_current.lwo_user.Activation_Server__c= GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c;
                    update lwo_user_current.lwo_user;
                }

                // send email (email stating please use existing credentials );  
                sendActivationEmail(userContactId,lwo_user_current.lwo_user.Id,true);

                //revert back lwo user activation server URL : 
                if(GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c!=null)
                {
                    lwo_user_current.lwo_user.Activation_Server__c = GNE_CM_IHCP_Utils.getPortalServer();               
                }
                //add LWO permission set. 
                if (usr.IsActive)
                {
                    lwo_user_current.lwo_user.Workflow_State__c = 'ACTIVATED';
                    GNE_CM_IHCP_User_Util.addLwoPermissionSetAtFuture(existinguserId, false);  
                }
                update lwo_user_current.lwo_user;
            } catch (Exception e) {
                
                Database.rollback(sp);
                System.debug('error msg============'+ e.getMessage());
                String errorMsg = 'Error provisioning ' + emailAddress + ' for ' + sapId + ' in SFDC';
                errorMsg += ' Unable to affiliate ' + sapId + ' with ' + emailAddress;   
                errorMsg += ' Exception: ' + e.getMessage();
                errorMsg += ' Stack Trace: ' + e.getStackTraceString();
                
                msg.setCode('false');
                msg.setMessage(errorMsg); 
                return msg;
            }
            
            msg.setCode('true');
            msg.setMessage(''); 
            return msg;                                             
        }           
        
        /**
            * Creates a user if the new user's data is the same as the existing account's.
            */
        /*private static RegistrationMessage processUserSameAsSapAccount(String firstName, String lastName, String email, String phone, String contactId)
            {    
                System.debug('Enter processUserSameAsSapAccount');
                
                RegistrationMessage msg = new RegistrationMessage();            
                Savepoint sp = Database.setSavepoint();
                            
                try
                {          
                    // create SFDC user 
                    createPortalUser(firstName, lastName, email, phone, contactId);
                }
                catch(Exception e)
                {                    
                    msg.setCode('false');
                    String errorMsg = 'Error provisioning ' + email + ' for ' + sapId;
                    errorMsg += ' in SFDC Unable create portal user for ' + email + ' in SFDC';    
                    errorMsg += ' Exception: ' + e.getMessage();                         
                    msg.setMessage(errorMsg);
                    Database.rollback(sp);
                    return msg;             
                }
                            
                msg.setCode('true');
                return msg;
            }*/
        
        private static RegistrationMessage provisionPhysicianUser (String accountId, String firstName, String lastName, 
        String middleName, String email, String phone)
        {                    
            System.debug('Enter provisionPhysicianUser');
            
            // search for Accounts
            List<Account> accounts = getPersonAccount(firstName, lastName, email);
            
            String phyAcctId = null;
            String contactId = null;
            Account account = null;
            RegistrationMessage msg = new RegistrationMessage();
            
            Savepoint sp = Database.setSavepoint();
            
            try
            {                    
                if (accounts.size() == 0)
                {    
                    System.debug('create new Account');
                    account = new Account();            
                    account.FirstName = firstName;
                    account.LastName = lastName;
                    account.Middle_vod__c = middleName;
                    account.Phone = phone;
                    account.PersonEmail = email;
                    account.RecordTypeId = recordTypeid;  
                    account.web_order_enabled_gne__c = true;  
                    //account.ownerId = lwouserId;      
                    insert account;
                    
                    account = [select Id, IsPersonAccount, PersonContactId from Account where id = :account.Id limit 10];
                }           
                else
                {
                    msg.setCode('false');
                    msg.setMessage('There exists person account for this user. Please contact System Administrator'); 
                    System.debug('Person account already exists ');
                    System.debug('Account for ' + firstName + ' ' + lastName + ' ' + email + ' already exits.');                
                    //account = accounts[0];
                    return msg;
                }
                
                phyAcctId = account.Id;  
                contactId = account.PersonContactId;
                
                System.debug('New Account Id ========' + phyAcctId + ', PersonContactId ==========' + contactId);                           
                
                try
                {
                    Integer retCode = createAffiliation(accountId, phyAcctId, true);
                    
                    if( retCode != 0 )
                    Database.rollback(sp);
                    
                    if( retCode == 1) {
                        msg.setCode('false');
                        msg.setMessage('Cannot find Product Catalog in QueueSobject'); 
                        return msg;                     
                    }
                    else if( retCode == 2) {
                        msg.setCode('false');
                        msg.setMessage('Cannot find GNE-LWO-CUSTOPS in Group'); 
                        return msg;                                                                     
                    }                   
                    else if( retCode == 3) {
                        msg.setCode('false');
                        msg.setMessage('Failed to create affiliation for the username ' +  email);
                        return msg;                                                                     
                    }                   
                }
                catch(Exception e)
                {
                    msg.setCode('false');
                    String errorMsg = 'Error provisioning ' + email + ' for ' + sapId;
                    errorMsg += ' in SFDC Unable to affiliate user ' + firstName + ' ' + lastName;
                    errorMsg += '  with LDD account ' + sapId + ' in SFDC';
                    errorMsg += ' Exception: ' + e.getMessage();                    
                    msg.setMessage(errorMsg);
                    Database.rollback(sp);
                    return msg;
                }
                
                try
                {      
                    System.debug('creating portal user ' + email + '**contact + ' + contactId);     
                    createPortalUser(firstName, lastName, email, phone, contactId, false, true);
                }
                catch(Exception e) {
                    //******FWANG/NLEBLANC 02/20 12:35PM: UAT TROUBLESHOOTING START
                    System.debug('Create Portal User error msg============'+ e.getMessage());
                    //******FWANG/NLEBLANC 02/20 12:35PM: UAT TROUBLESHOOTING END
                    msg.setCode('false');
                    String errorMsg = 'Error provisioning ' + email + ' for ' + sapId;
                    errorMsg += ' in SFDC Unable create portal user for ' + email + ' in SFDC'; 
                    errorMsg += ' Exception: ' + e.getMessage();
                    errorMsg += ' Stack Trtace: ' + e.getStackTraceString();                                
                    msg.setMessage(errorMsg);
                    Database.rollback(sp);
                    return msg;             
                }
                
                msg.setCode('true');
                msg.setMessage('');
                return msg;
                
            } catch (Exception e) {
                Database.rollback(sp);
                String errorMsg = 'Error provisioning ' + email + ' for ' + sapId + ' in SFDC';
                errorMsg += ' Unable to create Account for ' + email + ' in SFDC';     
                errorMsg += ' Exception: ' + e.getMessage();                         
                msg.setCode('false');
                msg.setMessage(errorMsg); 
                return msg;
            }                                                                      
        }
        
        /*private static RegistrationMessage provisionNonPhysicianUser(String accountId, Boolean isPersonAccount, String firstName, String lastName, 
                String middleName, String email, String phone) {
        
                System.debug('Enter provisionNonPhysicianUser........................');
        
                String masterAcctId = null;
                RegistrationMessage msg = new RegistrationMessage();
                
                Savepoint sp = Database.setSavepoint();
                        
                if( isPersonAccount) {
                    
                    masterAcctId = getMasterContactAcctId();
                    if( masterAcctId == null) {
                        System.debug('Cannot find <LWO Master Account for Contacts> account in SFDC');
                        msg.setCode('false');
                        msg.setMessage('Cannot find <LWO Master Account for Contacts> account in SFDC');
                        return msg;
                    }
                }
                
                try {       
                    
                    String contactId = null;                
                    Boolean createNew = false;
                                    
                    List<Contact> contacts = [select ownerid from Contact where firstName = :firstName and lastName = :lastName and email = :email];
                    if( contacts.size() == 0)
                        createNew = true;
                    else {
                
                        Set<ID> ownerIds = new Set<ID>();
                        for (Contact contactObj : contacts){
                            ownerIds.add(contactObj.ownerid);
                        }
                        
                        List<Profile> profiles = [select Id from Profile where name = 'GNE-LWO-CUSTOPS'];                   
                
                        if( profiles.size() == 0) {
                            msg.setCode('false');
                            msg.setMessage('Cannot find <GNE-LWO-CUSTOPS> Profile');
                            return msg;
                        }
                        else {
                            Profile profileObj = profiles.get(0);
                            String custOpsProfileId = profileObj.Id;
                
                            List<User> users = [select id from User where id in :ownerIds and profileId = :custOpsProfileId];
                            if( users.size() == 0)
                                createNew = true;
                            else {
                                User userObj = users.get(0);
                                String userId = userObj.id;
                                contacts = [select id from Contact where ownerId = :userId];
                                Contact contact = contacts.get(0);
                                contactId = contact.Id;
                            }
                        }
                    }
                
                    if( createNew == true) {
                
                        System.debug('Create new Contact.................');
                        Contact contact = new Contact();
                        contact.FirstName = firstName;
                        contact.LastName = lastName;
                        contact.Email = email;
                        contact.Phone = phone;  
                        
                        // set new Contact owner id that has 'GNE-LWO-CUSTOPS' profile
                        contact.OwnerId = lwouserId;
                        
                        if( isPersonAccount )
                        contact.AccountId = masterAcctId;
                        else        
                        contact.AccountId = accountId;
                        insert contact;
                        
                        contactId = contact.Id;                             
                    }
                    
                    
                    System.debug('New Contact Id ============= ' + contactId);
                    try {
                        Integer retCode = createAffiliation(accountId, contactId, false);
                        
                        if( retCode != 0 )
                        Database.rollback(sp);
                        
                        if( retCode == 1) {
                            msg.setCode('false');
                            msg.setMessage('Cannot find Product Catalog in QueueSobject'); 
                            return msg;                     
                        }
                        else if( retCode == 2) {
                            msg.setCode('false');
                            msg.setMessage('Cannot find GNE-LWO-CUSTOPS in Group'); 
                            return msg;                                                                     
                        }           
                        else if( retCode == 3) {
                            msg.setCode('false');
                            msg.setMessage('Failed to create affiliation for the username ' +  email);
                            return msg;                                                                     
                        }
                                
                    }
                    catch(Exception e) {
                        msg.setCode('false');
                        String errorMsg = 'Error provisioning ' + email + ' for ' + sapId;
                        errorMsg += ' in SFDC Unable to affiliate user ' + firstName + ' ' + lastName;
                        errorMsg += '  with LDD account ' + sapId + ' in SFDC';
                        errorMsg += ' Exception: ' + e.getMessage();                    
                        msg.setMessage(errorMsg);
                        Database.rollback(sp);
                        return msg;
                    }
                    
                    try {     
                        createPortalUser(firstName, lastName, email, phone, contactId);
                                        
                    } catch (Exception e) {
                        msg.setCode('false');
                        String errorMsg = 'Error provisioning ' + email + ' for ' + sapId;
                        errorMsg += ' in SFDC Unable create portal user for ' + email + ' in SFDC';  
                        errorMsg += ' Exception: ' + e.getMessage();                               
                        msg.setMessage(errorMsg);
                        Database.rollback(sp);
                        return msg;             
                    }                               
                    
                    msg.setCode('true');
                    msg.setMessage('');
                    return msg;
                } 
                catch (Exception e) {
                    Database.rollback(sp);
                    String errorMsg = 'Error provisioning ' + email + ' for ' + sapId + ' in SFDC';
                    errorMsg += ' Unable to create Contact for ' + email + ' in SFDC';  
                    errorMsg += ' Exception: ' + e.getMessage();                            
                    msg.setCode('false');
                    msg.setMessage(errorMsg); 
                    return msg;
                }       
            }
                            
        */
    
        private static Integer getEnv() {
          //  String ENV = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().ESB_URL__c;
             String ENV = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().Name;
        
        
            if (ENV.contains('DEV')) {  // old proxy:  sfdcproxy-dev 
                System.debug('DEV environment...........');
                usernameSuffix = '.dev';
                return ENV_DEV;
            }
            else if (ENV.contains('SQA')) {
                System.debug('QA environment...........');
                usernameSuffix = '.sqa';
                return ENV_QA;
            }
            else if (ENV.contains('UAT')) {
                System.debug('UA environment...........');
                usernameSuffix = '.uat';
                return ENV_UAT;
            } 
            else {
                usernameSuffix = '.gene';
                System.debug('PROD environment...........');
                return ENV_PROD;
            }  
           
            
            
           
            
            
            
            
            
        }
        
        // get Account data in SFDC
        public static Account getAccountBySapId()
        {        
            List <Account> accounts= [select Id, IsPersonAccount, PersonContactId, FirstName, LastName, PersonEmail  from Account where sap_id_gne__c  = :sapId limit 10];
            
            if (accounts.size() == 1)
            {
                Account account = accounts.get(0);
                String accountId = account.id;
                
                System.debug('Account Id==========' + accountId + 
                ', IsPersonAccount======' + account.IsPersonAccount +
                ', PersonContactId =======' + account.PersonContactId +
                ', FirstName ====== ' + account.FirstName + 
                ', LastName =======' + account.LastName + 
                ', PersonEmail ===== ' + account.PersonEmail);
                
                return account;
            }           
            
            return null;    
        }
        
        public static String getRecordTypeId()
        {
            //String recordTypeName = 'Professional_vod';       
            String recordTypeName = 'Professional_vod';
            
            List <RecordType> recordTypes = [ select id, name from RecordType where name like :recordTypeName];     
            System.debug('size ================' + recordTypes.size());   
            if( recordTypes.size() == 1) {
                RecordType obj = recordTypes.get(0);            
                System.debug('recordTypeId==========' + obj.Id + ' for ' + recordTypeName);         
                return obj.Id;          
            }
            
            return null;
        }
        
        
        private static String getProfileId() {
            
            //String name = 'GNE-LWO-USER';
            String name ='GNE-CM-IHCP-PROFILE';
            
            List<Profile> profiles = [Select Id from Profile where name = :name];       
            if( profiles.size() == 1) {
                Profile obj = profiles.get(0);
                System.debug('Profile Id =================' + obj.Id + ' for ' + name);
                return obj.Id;          
            }
            return null;        
        }
        
        
        private static String getLWOUserId()
        {    
            List<User> usrs = [Select Id from User where firstname = 'lwouser' and lastname = 'runas' limit 1];       
            if (usrs.size() == 1)
            {
                User obj = usrs.get(0);
                System.debug('LWO User Id =================' + obj.Id);
                return obj.Id;          
            }
            return null;                       
        }        
        
        
        
        //check for existing user ingeneral(MPS etc ) . 
        public static User getUser(String emailAddress)
        {
            List<User> usrs; 
            String username = getFormattedUserName(emailAddress);
            List<GNE_CM_IHCP_User__c> Ihcpusrs = [select Id,SFDC_User__c from  GNE_CM_IHCP_User__c  where SFDC_User__r.contact.email like : emailAddress /*Name=:username*/ limit 10];
            if(Ihcpusrs!=null && Ihcpusrs.size()>0)
            usrs = [select id,ContactId from User where Id=:Ihcpusrs[0].SFDC_User__c];
            if(usrs!=null && usrs.size() == 1)
            {
                User obj = usrs.get(0);
                System.debug('User Id =============' + obj.Id + ', ContactId========='+ obj.ContactId);         
                return obj;
            } 
            return null;
            
        }
        
        // get PersonAccount   
        private static List<Account> getPersonAccount(String firstName, String lastName, String emailAddress) {
            
            List <Account> accounts= [select Id, IsPersonAccount, PersonContactId from Account where firstName = :firstName and lastName = :lastName and PersonEmail = :emailAddress and RecordTypeId = :recordTypeId limit 100];
            System.debug('total accounts ===========' + accounts.size() + ' for "' + firstName + ' ' + lastName +  ' ' + emailAddress + '"');               
            return accounts;
        }
        
        
        private static String getMasterContactAcctId() {
            
            List <Account> accounts = [select id from Account where name = 'LWO Master Account for Contacts' limit 5];
            if( accounts.size() == 1) {
                Account obj = accounts.get(0);
                System.debug('Master Contact Account Id =============' + obj.Id);           
                return obj.Id;
            } 
            return null;
        }                               
        
        // return code: 0  for successful affiliation creation
        //              1  cannot find Product Catalog in QueueSobject
        //              2  cannot find 'GNE-LWO-CUSTOPS' in Group
        //              3  unexpected exception
        public static Integer createAffiliation(String accountId, String toId, Boolean isPhysician)
        {                            
            //check if affiliation already exists
            List<Affiliation_vod__c> affs = null;
            
            //******FWANG/NLEBLANC 02/20 5:00PM: SQA TROUBLESHOOTING START
            if (isPhysician == true)
            {
                affs = [select Id from  Affiliation_vod__c where From_account_vod__c = :accountId and To_Account_vod__c = : toId and Role_vod__c = :affiliationRole and Web_Order_Enabled_gne__c = true limit 1]; 
            }
            else//this should never happen for new LWO users as all user contacts are person contacts . 
            {             
                affs = [select Id from  Affiliation_vod__c where From_account_vod__c = :accountId and To_Contact_vod__c = : toId and Role_vod__c = :affiliationRole and Web_Order_Enabled_gne__c = true limit 1];               
            }      
            
            
            if (affs.size() > 0)
            {
                System.debug('Affiliation already exists.');
                return 0;
            }                               
            
            // create affiliation
            
            Affiliation_vod__c aff = new Affiliation_vod__c();
            aff.Role_vod__c = affiliationRole;          
            aff.From_account_vod__c = accountId;
            //******FWANG/NLEBLANC 02/20 4:00PM: SQA TROUBLESHOOTING START 
            aff.Web_Order_Enabled_gne__c = true;
            //******FWANG/NLEBLANC 02/20 4:00PM: SQA TROUBLESHOOTING END
            
            if (isPhysician == true)
            {
                aff.To_Account_vod__c = toId;
            }
            else//this should never happen for new LWO users (IHCP)
            {
                aff.To_Contact_vod__c = toId;
            }
    
            try
            {
                // needs to find the id for Product Catalog
                List<Group> groups = [select Id from Group where name = 'GNE-LWO-CUSTOPS'];
                if (groups.size() > 0)
                {  
                    String queueId = null;
                    for(Group groupObj:groups)
                    {    
                        queueId = groupObj.id;
                        List<QueueSobject>  queues = [select SobjectType from QueueSobject where queueId= :queueId and SobjectType = 'Product_vod__c'];
                        
                        if( queues.size() > 0)
                        {    
                            System.debug('Found Product Catalog Id id ==========' + queueId);
                            aff.OwnerId = queueId;
                            insert aff;
                            System.debug('Affiliation created successfully >>>>>>>>>>>>>>>>>>>>>>>>>>');
                            return 0;                       
                        }                   
                    }   
                    
                    return 1;                                       
                }
                else
                {
                    return 2;
                }
            }           
            catch (Exception e)
            {
                System.debug('Error ========= ' + e.getMessage());
                return 3;
            }                             
        }
        
        
        private static String getFormattedUserName(String emailAddress)
        {
            if (getEnv() == ENV_PROD)
            {
                return emailAddress;
            }
            else
            {
                return  emailAddress + usernameSuffix;
            }
        }
        
        public static LWOUserCheck  createLWOUser(User user){
            LWOUserCheck lwo_check = new LWOUserCheck();
            //check user exists 
            if(checkLWOUserExists(user))
            {
                //lwo_check.lwo_user=lwoUser[0];
                lwo_check.isExist=true;
                return lwo_check;
            }
            else{
                //insert into LWO user record.          
                GNE_LWO_User__c lwo_user = new GNE_LWO_User__c();
                lwo_user.Name=user.username;
                lwo_user.sap_id__c = sapId;
                lwo_user.SFDC_User__c=user.id;
                lwo_user.Is_Physician__c= !ispractiseManager;
                lwo_user.Activation_Hash_Number__c =  GNE_CM_MPS_Email_Utils.generateActivationHash(100);
                lwo_user.Workflow_State__c='ACTIVATION_EMAIL_SENT';
                lwo_user.Activation_Email_Sent_Date__c=system.today();
                lwo_user.Activation_Server__c=GNE_CM_IHCP_Utils.getPortalServer();
                insert lwo_user;
                
                lwo_check.lwo_user=lwo_user;
                lwo_check.isExist=false;
                return lwo_check;
                //return lwo_user;
            }
        }
        
        
        private static boolean checkLWOUserExists(User usr)
        {
            List<GNE_LWO_User__c> lwoUser = [select SFDC_User__c,Workflow_State__c from  GNE_LWO_User__c  where  SFDC_User__c=:usr.Id];
            if(lwoUser.size()!=null && lwoUser.size()>0){
                return true;
            }
            else
            {
                return false;
            }
        }
        
        private static void createUpdateLWOIHcpUser (User user, String email, GNE_CM_IHCP_User__c existingIHCPUser, Boolean hasMPSAccess, Boolean hasLWOAccess)
        {   
            String lwoStatus = hasLWOAccess ? 'Approved' : 'No Access';
            String mpsStatus = hasMPSAccess ? 'Approved' : 'No Access';
            
            //check for existing users
            if (existingIHCPUser != null)
            {
                List<GNE_CM_IHCP_User__c> existing_ihcp = [select Id, SFDC_User__c, LWO_Status__c from GNE_CM_IHCP_User__c  where Id = :existingIHCPUser.Id];
                
                if (existing_ihcp != null && existing_ihcp.size() > 0)
                {
                    existing_ihcp[0].LWO_Status__c = lwoStatus;
                    //existing_ihcp[0].MPS_Status__c = mpsStatus;
                    update existing_ihcp[0];
                }
                else
                {
                    // this should never happen
                    System.debug('Failed to creatEe/update IHCP User as IHCP user not found');
                }
            }
            //for new users 
            else
            {
                if (user.username == null)
                {
                    throw new GNE_CM_Exception('Username passed to the method is null');
                }
                GNE_CM_IHCP_User__c ihcpUser = new GNE_CM_IHCP_User__c (LWO_Status__c = lwoStatus, MPS_Status__c = mpsStatus, Email_Address__c = email, Name = user.username, SFDC_User__c = user.Id);
                insert ihcpUser;
                System.debug('Inserted IHCP user: ' + ihcpUser);
            }
        }
        
        
        public static void sendActivationEmail(String conId,ID lwo_userId,boolean IsExisting){
            
            GNE_CM_IHCP_Email_Utility lwo_email;
            lwo_email = new GNE_CM_IHCP_Email_Utility('LWO_Configuration');
            System.debug('**about to send emails ');
            System.debug('INSIDE SEND ACTIVATION EMAILS ---> ' + conId + '****lwo user id ' + lwo_userId);
            if(!IsExisting){
                lwo_email.sendActivationEmail(conId,lwo_userId);
            }
            else{
                lwo_email.sendExistingActivationEmail(conId,lwo_userId);
            }
        }
        
        private static void createPortalUser (String firstName, String lastName, String email, String phone, String contactId, Boolean hasMPSAccess, Boolean hasLWOAccess)
        {
            String username; 
            username = getFormattedUserName(email);
            System.debug('inside user creation last name ' + lastName);
            SYstem.debug('contact Id inside user ' + contactId );
            
            User usr = new User();
            usr.firstName = firstName;
            usr.lastName = lastName;
            //commented for change request Id            
            //usr.Alias = firstName + ' ' + lastName;
            usr.alias = defaultAlias;
            usr.UserName = username;
            usr.Email = email!=null ? email : defaultEmail; // PFS-1182
            usr.Phone = phone;
            usr.ContactId = contactId;                                      
            usr.profileId = profileId;    
            usr.Account_Manager__c = isaccoutManager;/*new field to determine LWO  user role for self service Account profile access */
            usr.TimeZoneSidKey = defaultTimeZone; 
            usr.LocaleSidKey = defaultLocaleKey;             
            usr.EmailEncodingKey = defaultEmailEncodingKey;    
            usr.LanguageLocaleKey = defaultLanguageLocaleKey;         
            insert usr;   
            //create IHCP user 
            
            createUpdateLWOIHcpUser (usr, email, null, hasMPSAccess, hasLWOAccess);            
            //Create LWO User recor            
            LWOUserCheck  lwo_user_current = createLWOUser(usr);
            //add LWO permission set. 
            List<Id> newSfdcUserIds = new List<Id>();
            newSfdcUserIds.add(usr.id);
            
            if (!Test.isRunningTest()) 
            {
                GNE_CM_IHCP_User_Util.addLwoPermissionSetAtFuture(newSfdcUserIds, true);
            }

            //send out email notification  
            sendActivationEmail(contactId,lwo_user_current.lwo_user.Id,false);
        }   
        
        
        
        
    }