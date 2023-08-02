/**
 * Different utils for LWO portal.
 *
 * @author Radek Krawiec
 * @created 08/16/2012
 *
 * Test class: GNE_LWO_Utils_Test
 */
public without sharing class GNE_LWO_Utils
{
	public static final String INACTIVE_USER_EMAIL_PREFIX='__inactive__' ;
	
    /**
     * This method converts an existing SFDC user representing an LWO user to an IHCP/LWO users.
     * 
     * Input conditions:
     * - the SFDC user has a contact related to it (through field User.ContactId)
     * - the SFDC user has an affiliation to some HCO user
     * - the SFDC user has a corresponding LWO user (through field GNE_LWO_User__c.SFDC_User__c)
     *
     * What this method does:
     * - creates a brand new person account (i.e. account + contact)
     * - sets password for the new SFDC user
     * 
     */
    public static LWOConversionData convertLWOUserToIHCP (Id sfdcUserId, String password)
    {
        // check preconditions - if anything goes wrong, an exception is thrown
        LWOConversionData conversionData = fetchConversionData(sfdcUserId);
        
        if (conversionData.lwoUser.Change_Password__c != true)
        {
            system.debug('LWO User = ' + conversionData.lwoUser.Id + ' has Change_Password__c set to false - no conversion done');
            return conversionData;
        }
        
        
        
        // check if a person account for the new user's data already exists
        Account existingPersonAccount = null;//getPersonAccount(conversionData.oldContact.FirstName, conversionData.oldContact.LastName, conversionData.oldContact.Email);
        
        Account personAccount = null;
        // if it does not exist, create a new one, otherwise use the existing one
        if (existingPersonAccount == null)
        {
            personAccount = createLWOPersonAccount(conversionData.oldContact.FirstName, conversionData.oldContact.LastName, conversionData.oldContact.Email);
        }
        else
        {
            personAccount = existingPersonAccount;
            
            // The person account is associated with the existing SFDC user, but we want to associate it with a new one.
            // However, since a contact can only be associated with one customer portal user, we need to remove the existing association.
            //conversionData.sfdcUser.ContactId = null;
            //update conversionData.sfdcUser; 
        }
        
        if (personAccount == null)
        {
            throw new GNE_LWO_User_Creation_Exception('Person account not created', 7);
        }
        
        if (personAccount.PersonContactId == null)
        {
            throw new GNE_LWO_User_Creation_Exception('Field PersonContactId on the new person account is null', 8);
        }
        
        conversionData.newContactId = personAccount.PersonContactId;
        
        // create new SFDC user
        conversionData.newSfdcUser = createLWOSFDCUser (sfdcUserId, personAccount.PersonContactId, password);
        
        return conversionData;
    }
    
    public static User createLWOSFDCUser (Id existingSfdcUserId, Id newContactId, String password)
    {
        List<User> existingSfdcUsers = [SELECT Id, Username, FirstName, LastName, Email, Alias, CommunityNickname, LocaleSidKey, TimeZoneSidKey, EmailEncodingKey, LanguageLocaleKey, ProfileId FROM User WHERE Id = :existingSfdcUserId];
        if (existingSfdcUsers.isEmpty())
        {
            throw new GNE_LWO_User_Creation_Exception('No SFDC user found for ID = ' + existingSfdcUserId);
        }
        
        User existingSfdcUser = existingSfdcUsers.get(0);
        
        String oldUsername = existingSfdcUser.Username;
        
        // copy all properties to the new user
        User u = new User(ContactId = newContactId);
        
        u.Username = oldUsername + '.new';
        String email = existingSfdcUser.Email;
        
        //wilczekk: this is fix to strange error with email being N/A for some reason in the context of portal user
        if(email == '#N/A')
        {
            // log a warning
            GNE_CM_MPS_Utils.insertError('GNE_LWO_Utils', 'Medium', 'createLWOSFDCUser', 'Apex', '#N/A value on email field for user ' + u);
            
            // use a default email address
            email = 'lucentisdirect@gene.com';  
            String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
            if (environmentName != 'PROD')
            {
                email += '.' + environmentName;
            }
        }
          
        u.Email = email; 
        u.FirstName = existingSfdcUser.FirstName;
        u.LastName = existingSfdcUser.LastName;
        u.Alias = existingSfdcUser.Alias;
        u.CommunityNickname = getUniqueCommunityNickname(oldUsername);
        u.LocaleSidKey = existingSfdcUser.LocaleSidKey;
        u.TimeZoneSidKey = existingSfdcUser.TimeZoneSidKey;
        u.EmailEncodingKey = existingSfdcUser.EmailEncodingKey;
        u.LanguageLocaleKey = existingSfdcUser.LanguageLocaleKey;
        u.ProfileId = GNE_CM_IHCP_Utils.getIHCPPortalProfileId();
        
        system.debug('Creating user for contact = ' + newContactId);
        
        // insert new user
        insert u;
        
        // set the password for the new user
        System.setPassword(u.Id, password);
        
        return u;
    }
    
    /**
     * Tells if the SFDC user is a physician.
     * It is decided only basing on the user's affiliations.
     */
    public static Boolean isLWOUserPhysician (Id sfdcUserId, Id contactId)
    {
        Id accountId = null;
        Integer accountAffiliationCount = 0;
        
        // find person account associated with the contact
        List<Account> personAccounts = [SELECT Id FROM Account WHERE IsPersonAccount = true AND PersonContactId = :contactId];
        if (personAccounts != null && !personAccounts.isEmpty())
        {
            if (personAccounts.size() > 0)
            {
                // A test query was run on dev and prod that checked that as of 08/21/2012 there are no contacts associated with LWO profile users
                // that are associated with more than one person account. That's why if such situation happens, we can throw an exception.
                throw new GNE_LWO_User_Creation_Exception('More than one person account associated with contact ' + contactId);
            }
            
            accountId = personAccounts.get(0).Id;
            
            // find affiliations to account
            accountAffiliationCount = [SELECT COUNT() FROM Affiliation_vod__c WHERE To_Account_vod__c = :accountId AND Role_vod__c = 'Affiliated with' AND Web_Order_Enabled_gne__c = true];
            
            if (accountAffiliationCount > 0)
            {
                if (accountAffiliationCount == 1)
                {
                    // If this user's account has affiliation to some other account, then we assume this user is a physician.
                    // This assumption is based on how LWO users are created in class GneProductOrderUserRegistration.
                    return true;
                }
                else
                {
                    throw new GNE_LWO_User_Creation_Exception('More than one affiliation found for account ID ' + accountId);
                }
            }
        }
        
        
        // if no affiliations for account has been found, try to find some for contact
        Integer contactAffiliationCount = [SELECT COUNT() FROM Affiliation_vod__c WHERE To_Contact_vod__c = :contactId AND Role_vod__c = 'Affiliated with' AND Web_Order_Enabled_gne__c = true];
        
        if (contactAffiliationCount > 0)
        {
            if (contactAffiliationCount == 1)
            {
                // if user's contact has affiliation to some account, we assume they are not a physician
                return false;
            }
            else
            {
                throw new GNE_LWO_User_Creation_Exception('More than one affiliation found for contact ID ' + contactId);
            }
        }
        
        if (accountAffiliationCount == 0 && contactAffiliationCount == 0)
        {
            throw new GNE_LWO_User_Creation_Exception('User is affiliated neither by its contact nor by its account');
        }
        
        // this place should never be reached
        return true;
    }
    
    /**
     * Get a unique community nickname. It needs to be at most 40 characters long.
     */
    public static String getUniqueCommunityNickname (String username)
    {
        String randomSuffix = String.valueOf(Math.round(Math.random() * 1000000000));
        String newUsername = username + randomSuffix;
        
        while (newUsername.length() > 40 && username.length() > 2)
        {
            // remove the last character from the username
            username = username.substring(0, username.length() - 1);
            newUsername = username + randomSuffix;
        }
        
        return newUsername;
    }
    
    /**
     * Get person account by first name, last name and email address. If an account that is NOT person account is found, null is returned anyway.
     */
    public static Account getPersonAccount (String firstName, String lastName, String email)
    {
        List<Account> accounts = [SELECT Id, FirstName, LastName, IsPersonAccount, PersonContactId FROM Account WHERE IsPersonAccount = true AND FirstName = :firstName AND LastName = :lastName AND PersonEmail = :email LIMIT 1];
        
        if (accounts == null || accounts.isEmpty())
        {
            return null;
        }
        
        return accounts.get(0);
    }
    
    
    /**
     * Removed temp prefix from email.
     */
    public static Account setLWOPersonAccountActive (String accountId)
    {
		// this is the other side of our hack
    	Account lwoAcct=[SELECT Id, IsPersonAccount, PersonContactId, PersonEmail, FirstName, LastName FROM Account WHERE Id=:accountId];
    	
		lwoAcct.PersonEmail=lwoAcct.PersonEmail.replace(GNE_LWO_Utils.INACTIVE_USER_EMAIL_PREFIX,'');
		
		update lwoAcct;
		
		return lwoAcct;
    }
    
        
    /**
     * Creates a new person account for the given data.
     */
    public static Account createLWOPersonAccount (String firstName, String lastName, String email)
    {
        Account a = new Account();         

		// this is a hack to reuse any account created in a previous aborted attempt
    	List<Account> lstExist=[SELECT Id, IsPersonAccount, PersonContactId, PersonEmail, FirstName, LastName FROM Account WHERE FirstName = :firstName AND LastName=:lastName AND PersonEmail=:(INACTIVE_USER_EMAIL_PREFIX + email)];
		if (!lstExist.isEmpty())  
		{
			a=lstExist[0];
		}
		else
		{  	
	        a.FirstName = firstName;
	        a.LastName = lastName;
	        a.PersonEmail = INACTIVE_USER_EMAIL_PREFIX + email;
	        //a.RecordTypeId = getNewLWOUserRecordTypeId(); 
	        a.RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Health Care Professional').getRecordTypeId(); 
	        a.Web_Order_Enabled_gne__c = true;
	        a.ownerId = getLwoOwnerUserId();
	        insert a;
	        // refetch user to retrieve new values for PersonAccountId
	        a = [SELECT Id, IsPersonAccount, PersonContactId, FirstName, LastName FROM Account WHERE Id = :a.Id];
		}        
        return a;
    }
    
    
    
    /*
     * uses wrong type
    private static String getNewLWOUserRecordTypeId()
    {       
        String recordTypeName = 'LWO HealthCare Professional%';                                                                 
        List <RecordType> recordTypes = [ select id, name from RecordType where name like :recordTypeName];     
      
        if (recordTypes.size() == 1)
        {
            return recordTypes.get(0).Id;                     
        }
        else
        {
            throw new GNE_LWO_User_Creation_Exception ('More than one record type for ambiguous name \'' + recordTypeName + '\'', -1);
        }
          
        return null;
    }
    */
    public static Id getLwoOwnerUserId()
    {    
        List<User> users = [Select Id from User where firstname = 'lwouser' and lastname = 'runas' limit 1];       
        if (users.size() == 1)
        {
            return users.get(0).Id;          
        }
        return null;                       
    }
    
    public static LWOConversionData fetchConversionData (Id sfdcUserId)
    {
        List<User> users = [SELECT Id, Email, FirstName, LastName, Username, ContactId, AccountId, ProfileId, Alias, CommunityNickname, LocaleSidKey, TimeZoneSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE Id = :sfdcUserId];
        
        if (users == null || users.isEmpty())
        {
            throw new GNE_LWO_User_Creation_Exception('SFDC with ID = ' + sfdcUserId + ' not found', 1);
        }
        
        User existingUser = users.get(0);
        
        LWOConversionData conversionData = new LWOConversionData();
        conversionData.sfdcUser = existingUser;
        
        // select contact
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :existingUser.ContactId];
        if (contacts == null || contacts.isEmpty())
        {
            throw new GNE_LWO_User_Creation_Exception('No contacts found for ID = ' + existingUser.ContactId, 6);
        }
        conversionData.oldContact = contacts.get(0);
        
		// select physician (person) account if avail
        List<Account> perAccts=[SELECT Id, RecordTypeId, SAP_ID_gne__c FROM Account WHERE IsPersonAccount = true AND Id=:conversionData.sfdcUser.AccountId];
        if (!perAccts.isEmpty())
        {
        	conversionData.lwoPhyAccount=perAccts[0];
        }
        
		// Look for MPS stuff
        users = [SELECT Id, Email, FirstName, LastName, Username, ContactId, AccountId, ProfileId, Alias, CommunityNickname, LocaleSidKey, TimeZoneSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE Username = :getPotentialMpsUsername(conversionData.sfdcUser.Username)];
        
        if (!users.isEmpty())
        {
            conversionData.mpsSfdcUser=users[0];
	        perAccts=[SELECT Id, RecordTypeId, SAP_ID_gne__c FROM Account WHERE IsPersonAccount = true AND Id=:conversionData.mpsSfdcUser.AccountId];
	        if (!perAccts.isEmpty())
	        {
	        	conversionData.mpsPhyAccount=perAccts[0]; 
	        }
        }

        // find LWO user and make sure exactly one exists
        List<GNE_LWO_User__c> lwoUsers = [SELECT Id, SFDC_User__c, Change_Password__c, Is_Physician__c, SFDC_User__r.ContactId FROM GNE_LWO_User__c WHERE SFDC_User__c = :sfdcUserId];
        if (lwoUsers == null || lwoUsers.isEmpty())
        {
            throw new GNE_LWO_User_Creation_Exception('No LWO users found for SFDC user with ID = ' + sfdcUserId, 3);
        }
        else if (lwoUsers.size() > 1)
        {
            throw new GNE_LWO_User_Creation_Exception('More than one (i.e. ' + lwoUsers.size() + ') LWO users found for SFDC user with ID = ' + sfdcUserId, 4);
        }
        
        conversionData.lwoUser = lwoUsers.get(0);
        
        // find affiliated account
        conversionData.affiliationAccount = getAffiliatedAccount(existingUser.ContactId, conversionData.lwoUser.Is_Physician__c);
        if (conversionData.affiliationAccount == null)
        {
            throw new GNE_LWO_User_Creation_Exception('No affilicated account found for contact ID = ' + existingUser.ContactId, 5);
        }
        
        return conversionData;
    }
    
    // TODO - this method needs to be implemented
    public static Account getAffiliatedAccount (Id lwoUserContactId, Boolean isPhysician)
    {
        List<Affiliation_vod__c> affiliations = null;
        
        if (isPhysician == true)
        {
            // find person account for the contact
            List<Account> personAccounts = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = true AND PersonContactId = :lwoUserContactId LIMIT 1];
            if (personAccounts == null || personAccounts.isEmpty())
            {
                system.debug('No person account found for contact ' + lwoUserContactId);
                return null;
            }
            
            affiliations =  [select Id, From_account_vod__c from Affiliation_vod__c where To_Account_vod__c = :personAccounts.get(0).Id and Role_vod__c = 'Affiliated with' and Web_Order_Enabled_gne__c = true];
        }
        else
        {
            affiliations =  [select Id, From_account_vod__c from Affiliation_vod__c where To_Contact_vod__c = : lwoUserContactId and Role_vod__c = 'Affiliated with' and Web_Order_Enabled_gne__c = true];
        }
        
        if (affiliations == null || affiliations.isEmpty())
        {
            return null;
        }
        
        if (affiliations.size() > 1)
        {
            throw new GNE_LWO_User_Creation_Exception('More than one affiliation found for contact ID = ' + lwoUserContactId);
        }
        
        Account affiliatedAccount = [SELECT Id FROM Account WHERE Id = :affiliations.get(0).From_account_vod__c];
        return affiliatedAccount;
    }
    
    /**
     * Creates an LWO User (GNE_LWO_User__c object) for each SFDC user whose ID is on the list.
     * @param sfdcUser List of SFDC users
     * @param deleteIncorrectUsers If set to true, it is checked if already existing LWO users have the isPhysician flag set. If not, such LWO users are deleted.
     */
    public static void createLWOUsers (List<User> sfdcUsers, Boolean deleteIncorrectUsers)
    {   
        Map<Id, GNE_LWO_User__c> existingLwoUsersBySFDCUserId = new Map<Id, GNE_LWO_User__c>();
        
        if (deleteIncorrectUsers)
        {
            List<Id> sfdcUserIds = new List<Id>();
            for (User sfdcUser : sfdcUsers)
            {
                sfdcUserIds.add(sfdcUser.Id);
            }
            
            List<GNE_LWO_User__c> existingLwoUsers = [SELECT Id, SFDC_User__c FROM GNE_LWO_User__c WHERE SFDC_User__c IN :sfdcUserIds];
            
            for (GNE_LWO_User__c lwoUser : existingLwoUsers)
            {
                existingLwoUsersBySFDCUserId.put(lwoUser.SFDC_User__c, lwoUser);
            }
        } 
        
        // get info about which users are physicians
        Map<Id, Boolean> isPhysicianFlags = getIsPhysicianFlag(sfdcUsers);
        System.debug('Retrieved isPhysicianFlags: ' + isPhysicianFlags);
                
        List<GNE_LWO_User__c> newLWOUsers = new List<GNE_LWO_User__c>();
        List<GNE_LWO_User__c> lwoUsersToDelete = new List<GNE_LWO_User__c>();
        
        for (User sfdcUser : sfdcUsers)
        {   
            if (isPhysicianFlags.get(sfdcUser.Id) == null)
            {
                // If the isPhysicianFlag is null, it means that establishing whether this user is a physician was not possible
                // and they won't be converted.
                if (deleteIncorrectUsers && existingLwoUsersBySFDCUserId.containsKey(sfdcUser.Id))
                {
                    lwoUsersToDelete.add(existingLwoUsersBySFDCUserId.get(sfdcUser.Id));
                }
                else
                {
                    //throw new GNE_CM_Exception('IsPhysician flag could not be retrieved for SFDC user ID = ' + sfdcUser.Id);
                    // log a warning
                   	Error_Log_gne__c err = GNE_CM_IHCP_Utils.createError('GNE_LWO_Utils', 'Medium', 'createLWOUsers', 'Apex', 'IsPhysician flag could not be retrieved for SFDC user ID = ' + sfdcUser.Id);
            		insert err;            
                }                
                System.debug('Skipping SFDC user ' + sfdcUser.Id);
                continue;
            }
            
            GNE_LWO_User__c lwoUser = new GNE_LWO_User__c();
            //lwoUser.Name = sfdcUser.FirstName + ' ' + sfdcUser.LastName;
            lwoUser.Name = sfdcUser.Username;//
            lwoUser.Change_Password__c = false;
            lwoUser.SFDC_User__c = sfdcUser.Id;
            lwoUser.Is_Physician__c = isPhysicianFlags.get(sfdcUser.Id);
            System.debug('Created LWO user ' + lwoUser);
            
            newLWOUsers.add(lwoUser);
        }
        
        insert newLWOUsers;
        
        if (deleteIncorrectUsers)
        {
            delete lwoUsersToDelete;
        }
    }
    
    
    /**
     * Creates an LWO User (GNE_LWO_User__c object) for each SFDC user whose ID is on the list.
     * @param sfdcUserIds list of IDs of SFDC users
     */
    public static void createLWOUsers (List<Id> sfdcUserIds, Boolean deleteIncorrectUsers)
    {
        // fetch sfdc users
        List<User> sfdcUsers = [SELECT Id, Username, FirstName, LastName, Email, ContactId FROM User WHERE Id IN :sfdcUserIds];
        createLWOUsers(sfdcUsers, deleteIncorrectUsers);
    }
    
    public static Map<Id, Boolean> getIsPhysicianFlag (List<User> sfdcUsers)
    {
        String affiliationRole = 'Affiliated with';
        Map<Id, Id> contactToUserMap = new Map<Id, Id>();
        Map<Id, Id> accountToUserMap = new Map<Id, Id>();
        
        for (User u : sfdcUsers)
        {
            contactToUserMap.put(u.ContactId, u.Id);
        }
        
        // user ID to affiliation count
        Map<Id, Integer> contactAffiliationCount = new Map<Id, Integer>();
        
        // find affiliations to contacts
        List<Affiliation_vod__c> contactAffiliations = [SELECT Id, To_Contact_vod__c FROM Affiliation_vod__c WHERE To_Contact_vod__c IN :contactToUserMap.keySet() and Role_vod__c = :affiliationRole and Web_Order_Enabled_gne__c = true];
        
        for (Affiliation_vod__c aff : contactAffiliations)
        {
            Id userId = contactToUserMap.get(aff.To_Contact_vod__c);
            
            if (!contactAffiliationCount.containsKey(userId))
            {
                contactAffiliationCount.put(userId, 0); 
            }
            
            // increase the affiliation count
            contactAffiliationCount.put (userId, contactAffiliationCount.get(userId) + 1);
        }
        
        // find person account associated with the contact
        List<Account> personAccounts = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = true AND PersonContactId IN :contactToUserMap.keySet()];
        for (Account personAccount : personAccounts)
        {
            accountToUserMap.put (personAccount.Id, contactToUserMap.get(personAccount.PersonContactId));   
        }
        
        // find affiliations to accounts
        List<Affiliation_vod__c> accountAffiliations = [SELECT Id, To_Account_vod__c FROM Affiliation_vod__c WHERE To_Account_vod__c IN :accountToUserMap.keySet() and Role_vod__c = :affiliationRole and Web_Order_Enabled_gne__c = true];
        
        // user ID to affiliation count
        Map<Id, Integer> accountAffiliationCount = new Map<Id, Integer>();
        
        for (Affiliation_vod__c aff : accountAffiliations)
        {
            Id userId = accountToUserMap.get(aff.To_Account_vod__c);
            
            if (!accountAffiliationCount.containsKey(userId))
            {
                accountAffiliationCount.put(userId, 0); 
            }
            
            // increase the affiliation count
            accountAffiliationCount.put (userId, accountAffiliationCount.get(userId) + 1);
        }
        
        Map<Id, Boolean> isPhysicianFlag = new Map<Id, Boolean>();
        
        for (User sfdcUser : sfdcUsers)
        {
            Integer userContactAffiliations = contactAffiliationCount.get(sfdcUser.Id);
            Integer userAccountAffiliations = accountAffiliationCount.get(sfdcUser.Id);
            userContactAffiliations = userContactAffiliations == null ? 0 : userContactAffiliations;
            userAccountAffiliations = userAccountAffiliations == null ? 0 : userAccountAffiliations;
            //System.debug('****count****'+ (userContactAffiliations + userAccountAffiliations));
            if ((userContactAffiliations + userAccountAffiliations) != 1)
            {
                //throw new GNE_LWO_User_Creation_Exception('Incorrect affiliation setting. User ID = ' + sfdcUser.Id + ', contact affiliation number = ' + userContactAffiliations + ', account affiliation number = ' + userAccountAffiliations);
                isPhysicianFlag.put (sfdcUser.Id, null);
            }
            else
            {
                // If this place has been reached there are either 1 contact affiliation and 0 account affiliations, or the reverse.
                // If user has contact affiliation, they are NOT a physician, otherwise they are.
                isPhysicianFlag.put (sfdcUser.Id, userContactAffiliations == 0);
            }
        }
        
        return isPhysicianFlag;
    }
    
    public static String getPotentialMpsUsername (String username)
    {
        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        String envSuffix = (env != null && env != '' && env != 'PROD') ? '.' + env : '';
        
        // get the last bit of the domain
        return username.toLowerCase().replace('gene' + envSuffix.toLowerCase(), 'gene.mps' + envSuffix.toLowerCase());
    }
    
    public class LWOConversionData
    {
        public User sfdcUser { get; set; }
        public User newSfdcUser { get; set; }
        public User mpsSfdcUser { get; set; }
        public Account affiliationAccount { get; set; }
        public GNE_LWO_User__c lwoUser { get; set; }
        public GNE_CM_MPS_User__c mpsUser { get; set; }
        public Account lwoPhyAccount { get; set; }
        public Account mpsPhyAccount { get; set; }
        public Contact oldContact { get; set; }
        public Id newContactId { get; set; }
    }
}