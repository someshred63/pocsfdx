/**
 * @author Radek Krawiec
 * @created 01/07/2012
 * Test Class: GNE_CM_IHCP_User_Utils_Test
 */ 
public without sharing class GNE_CM_IHCP_User_Util 
{   
    /**
     * @param userName The name of the existing user
     * @param portal The name of the portal, e.g. 'MPS', 'LWO' etc.
     */
    public static Boolean isExistingPortalUser(String userName, String portal)
    {
        return isExistingPortalUser(userName, portal, null, false);
    }
    
    public static Boolean isExistingPortalUser(String userName, String portal, Id currentSFDCUserId, Boolean execute)
    {
        return !getExistingPortalUser(userName, portal, currentSFDCUserId, execute).isEmpty();
    }
    
    public static List<User> getExistingPortalUser(String userName, String portal)
    {
        return getExistingPortalUser(userName, portal, null, false);
    }
    
    /**
     * @param userName The name of the existing user
     * @param portal The name of the portal, e.g. 'MPS', 'LWO' etc.
     * @param currentSFDCUserId Only needs to be set when execute == true
     * @param execute If true, existing users will be deactivated and unflagged for conversion
     */
    public static List<User> getExistingPortalUser(String userName, String portal, Id currentSFDCUserId, Boolean execute)
    {
        Boolean result = false;
        String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        Integer environmentPosition = userName.indexOf('.' + environmentName);
        String oldProfile;

        if(portal == 'LWO')
        {
            oldProfile = GNE_CM_IHCP_Utils.getLWOPortalProfileName();
        }
        else if(portal == 'MPS')
        {
            oldProfile = GNE_CM_IHCP_Utils.getMPSPortalProfileName();                       
        }
        
        List<User> sfdcUserToDeactivate = new List<User>();
        
        if (portal == 'LWO' || portal == 'MPS')
        {
            if(environmentPosition > -1)
            {
                userName = username.substring(0, environmentPosition);
            }
            userName += '%';
            sfdcUserToDeactivate = [SELECT Id FROM User WHERE Profile.Name =: oldProfile AND username LIKE : userName AND isActive = true];
            if (sfdcUserToDeactivate != null && sfdcUserToDeactivate.size() > 0)
            {
                if (execute)
                {
                    if(portal == 'LWO')
                    {
                        addLWOAffiliation(sfdcUserToDeactivate[0].Id, currentSFDCUserId);
                    }
                    //upon successfull login check if LWO User related to this IHCP User exists and unflag him/her for change password process
                    GNE_CM_IHCP_Utils.unflagUsersFromConversion(sfdcUserToDeactivate[0].Id, portal, currentSFDCUserId);
                    deactivateUser(sfdcUserToDeactivate[0].Id);
                }
            }
        }
        
        return sfdcUserToDeactivate;
    }
    
    private static void addLWOAffiliation(Id sfdcUserToDeactivate, Id currentSFDCUserId)
    {
        List<GNE_LWO_User__c> lwoUsers = [SELECT Id, SFDC_User__r.ContactId, Is_Physician__c FROM GNE_LWO_User__c WHERE SFDC_User__c = :sfdcUserToDeactivate];
        if(lwoUsers != null && lwoUsers.size() > 0)
        {
            Account aff = GNE_LWO_Utils.getAffiliatedAccount(lwoUsers[0].SFDC_User__r.ContactId, lwoUsers[0].Is_Physician__c);
    
            // find person account for the new user
            User newUser = [SELECT AccountId FROM User WHERE Id = :currentSFDCUserId];        
            if (newUser.AccountId == null)
            {
                throw new GNE_CM_Exception('New user\'s account ID is null');
            } 
            
            Integer returnCode = GneProductOrderUserRegistration.createAffiliation(aff.Id, newUser.AccountId, true);    
            if (returnCode != 0)
            {
                throw new GNE_CM_Exception('LWO Affiliation creation error = ' + returnCode);                
            }        
        }
    }
    
    @future
    private static void deactivateUser(Id userId)
    {
        try
        {
            GNE_CM_UnitTestConfig.setSkipTriggersOnlyInTests(false);
            GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_User_PublicGroup_Association');
            
            List<User> u = [SELECT Id FROM User WHERE Id =: userId];
            u[0].isActive = false;
            u[0].IsPortalEnabled = false;
            update u;
            
            // unskip trigger
            GNE_CM_UnitTestConfig.setSkipTriggersOnlyInTests(true);
            GNE_CM_UnitTestConfig.unskipTriggerForTests('GNE_CM_User_PublicGroup_Association');
        }
        catch(Exception ex)     
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_User_Util', 'High', 'deactivateUser', 'Apex Class', ex);
            insert err;
        }
    }
    
    public static void setProfile(Id sfdcUserId, String profileId, String hash)
    { 
        String PUBLIC_SITE_ROOT = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Change_Profile_Site_URL__c;
        String remoteURL = PUBLIC_SITE_ROOT +'/GNE_CM_MPS_SwitchProfile?profileId=' + profileId +'&userId=' +sfdcUserId + '&hash=' + hash; 
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(remoteURL);
        req.setMethod('GET');
        
        HTTPResponse res = new Http().send(req);
    }
    
    public static void revertUserProfileTo(GNE_CM_MPS_User__c existingMpsUser, String profileName)
    {
        List<User> users = [SELECT Id, Profile.Name FROM User WHERE Id =: existingMpsUser.SFDC_User__c];
        if(users != null && users.size() > 0 && users[0].Profile.Name != profileName)
        {
            Profile cmPhysicianProfile = [SELECT Id FROM Profile WHERE Name =: profileName];
            GNE_CM_IHCP_User_Util.setProfile(existingMpsUser.SFDC_User__c, cmPhysicianProfile.Id, existingMpsUser.Activation_Hash_Number__c);
        }       
    }
    
    /**
     * This method takes a collection of new MPS users, and for each user checks if there already exists an iHCP user for them.
     * If it exists, the new MPS user is mapped to the existing SFDC user (through the iHCP user).
     */
    public static Map<Id, Id> getExistingUsersMap(Map<Id, GNE_CM_MPS_User__c> mpsUsers)
    {   
        // get the environment name
        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        String envSuffix = ((env != null && env != '' && env != 'PROD') ? '.' + env : '');
        
        System.debug('Env suffix = ' + envSuffix);
        
        // map MPS user Ids to their emails
        Map<Id, String> userToEmailMap = new Map<Id, String>();     
        for(GNE_CM_MPS_User__c u : mpsUsers.values())
        {
            userToEmailMap.put(u.Id, u.Email_address__c + envSuffix);
        }
        
        System.debug('Searched emails: ' + userToEmailMap.values());
        
        // find iHCP users with emails equal to those of existing MPS users
        Map<String, String> existingEmailsToSfdcUser = new Map<String, String>();
        for(GNE_CM_IHCP_User__c u : [SELECT Name, SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE Name IN: userToEmailMap.values()])
        {
            existingEmailsToSfdcUser.put(u.Name.toLowerCase(), u.SFDC_User__c);
        }
        
        System.debug('EmailsToSFDC ' +  existingEmailsToSfdcUser);
        
        Map<Id, Id> mpsUserIdToSFDCUserId = new Map<Id, Id>();
        
        for (Id mpsUserId : userToEmailMap.keySet())
        {
            if (existingEmailsToSfdcUser.keySet().contains(userToEmailMap.get(mpsUserId).toLowerCase()))
            {
                mpsUserIdToSFDCUserId.put(mpsUserId, existingEmailsToSfdcUser.get(userToEmailMap.get(mpsUserId).toLowerCase()));                                               
            }
        }
        return mpsUserIdToSFDCUserId;
    }
    
    public static void setupIHCPUsers (Map<ID, String> newSfdcUserToPortal, Map<ID, String> existingSfdcUsersToPortal, List<GNE_CM_IHCP_User__c> existingIHCPUsers, String status)
    {
        Set<Id> allSfdcUsers = new Set<Id>();
        allSfdcUsers.addAll(newSfdcUserToPortal.keySet());
        allSfdcUsers.addAll(existingSfdcUsersToPortal.keySet());
        Map<Id, User> sfdcUsers = new Map<Id, User>([SELECT Id, Username, Email FROM User WHERE ID IN :allSfdcUsers]);
        List<GNE_CM_IHCP_User__c> ihcpUsers = new List<GNE_CM_IHCP_User__c>();
        
        //first create ihcp users for newSFDC users
        for (User sfdcUser : sfdcUsers.values())
        {   
            if(newSfdcUserToPortal.keySet().contains(sfdcUser.Id))
            {
                String portal = newSfdcUserToPortal.get(sfdcUser.Id);
                GNE_CM_IHCP_User__c ihcpUser = new GNE_CM_IHCP_User__c();
                ihcpUser.SFDC_User__c = sfdcUser.Id;
                if(portal == 'MPS')
                {
                    ihcpUser.LWO_Status__c = 'No Access';
                    ihcpUser.MPS_Status__c = status;
                }
                else if(portal == 'LWO')
                {
                    ihcpUser.LWO_Status__c = status;
                    ihcpUser.MPS_Status__c = 'No Access';
                }
                
                ihcpUser.Name = sfdcUsers.get(ihcpUser.SFDC_User__c).Username;
                // The value for Email_Address is taken from the username field, because it has to be (?) unique
                // and username guarantees it (unlike User.Email)
                ihcpUser.Email_Address__c = trimEnvironmentSuffix(sfdcUser.Username);
                ihcpUsers.add(ihcpUser);
            }
        }        
        insert ihcpUsers;
        
        System.debug('Existing SFDC users to portal = ' + existingSfdcUsersToPortal);
        
        // then update access for existing ihcp users
        for(GNE_CM_IHCP_User__c u : existingIHCPUsers)
        {           
            if (existingSfdcUsersToPortal.keySet().contains(u.SFDC_User__c))
            {
                String portal = existingSfdcUsersToPortal.get(u.SFDC_User__c);
                if(portal == 'MPS')
                {
                    u.MPS_Status__c = status;
                }
                else if(portal == 'LWO')
                {
                    u.LWO_Status__c = status;
                }
            }
        }
        update existingIHCPUsers;
    }
    
    public static String trimEnvironmentSuffix(String userName)
    {       
        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        if(env != 'PROD')
        {
            userName = userName.toLowerCase();
            env = env.toLowerCase();
            Integer envPosition = userName.indexOf('.' + env);
            if(envPosition > -1)
            {
                userName = userName.substring(0, envPosition);
            }
        }
        return userName;
    }
    
    public static void setupIHCPUserInstantly (Id sfdcUserId, String portal, String cityOfBirth, String dayOfBirth, String cityOfFirstJob)
    {
        setupIHCPUserInstantly(sfdcUserId, portal, cityOfBirth, dayOfBirth, cityOfFirstJob, null);
    }
    
    /**
     * Creates an IHCP user.
     * @param sfcdUserId Id of the SFDC user for which an IHCP user is created
     * @param username The username/email address of the IHCP user. If null, it will be the same as the username of the SFDC user whose ID is passed as the first parameter
     */
    public static void setupIHCPUserInstantly (Id sfdcUserId, String portal, String cityOfBirth, String dayOfBirth, String cityOfFirstJob, String username)
    {
        User u = [SELECT Id, Username, Email FROM User WHERE ID = :sfdcUserId];
        GNE_CM_IHCP_User__c ihcpUser = new GNE_CM_IHCP_User__c();
        ihcpUser.SFDC_User__c = sfdcUserId;
        
        if (portal.contains(','))
        {
            List<String> portals = portal.split(',');
            Map<String, String> portalStates = new Map<String, String>();
            for (String portalState : portals)
            {
                List<String> stateBits = portalState.split('=');
                
                if (stateBits.get(0) == 'MPS')
                {
                    ihcpUser.MPS_Status__c = stateBits.get(1);      
                }
                else if (stateBits.get(0) == 'LWO')
                {
                    ihcpUser.LWO_Status__c = stateBits.get(1);
                }
            }
        }
        else
        {
            ihcpUser.MPS_Status__c = portal == 'MPS' ? 'Submitted' : 'No Access';
            ihcpUser.LWO_Status__c = portal == 'LWO' ? 'Submitted' : 'No Access';
        }
        
        ihcpUser.Name = username != null ? username : u.Username;
        // The value for Email_Address is taken from the username field, because it has to be (?) unique
        // and username guarantees it (unlike User.Email)
        ihcpUser.Email_Address__c = username != null ? username : u.Username;
        
        if (ihcpUser.Email_Address__c!=null)
        {
        	ihcpUser.Email_Address__c=trimEnvironmentSuffix(ihcpUser.Email_Address__c);
        }
        
        if (cityOfBirth != null && cityOfBirth != '')
        {
            ihcpUser.Security_Question_Answer_City_Of_Birth__c = cityOfBirth;
        }
        
        if (dayOfBirth != null && dayOfBirth != '')
        {
            ihcpUser.Security_Question_Answer_Day_Of_Birth__c = cityOfBirth;
        }
        
        if (cityOfFirstJob != null && cityOfFirstJob != '')
        {
            ihcpUser.Security_Question_Answer_City_Of_Job__c = cityOfBirth;
        }
        
        insert ihcpUser;
    }
    
    public static void setupIHCPUserInstantly (Id sfdcUserId, String portal)
    {
        setupIHCPUserInstantly(sfdcUserId, portal, null, null, null);
    }
    
    @future
    public static void setupIHCPUser (Id sfdcUserId, String portal)
    {
        try
        {
            setupIHCPUserInstantly(sfdcUserId, portal);
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_User_Util', 'High', 'setupIHCPUser', 'Apex Class', ex);
            insert err;
        }
    }
    
    @future
    public static void setupIHCPUser (Id sfdcUserId, String portal, String cityOfBirth, String dayOfBirth, String cityOfFirstJob, String username)
    {
        try
        {
            setupIHCPUserInstantly(sfdcUserId, portal, cityOfBirth, dayOfBirth, cityOfFirstJob, username);
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_User_Util', 'High', 'setupIHCPUser', 'Apex Class', ex);
            insert err;
        }
    }
    
    private static PermissionSetInfo getPermissionSetInfo()
    {
        PermissionSetInfo psIds = new PermissionSetInfo();
        
        psIds.permissionSetNames = new List<String>();
        psIds.permissionSetNames.add(GNE_CM_IHCP_Utils.MPS_PERMISSION_SET);
        psIds.permissionSetNames.add(GNE_CM_IHCP_Utils.LWO_PERMISSION_SET);
        
        List<PermissionSet> portalPermissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN :psIds.permissionSetNames];
        ID mpsPermissionSetId;
        ID lwoPermissionSetId; 
        
        for (PermissionSet ps : portalPermissionSets)
        {
            if (ps.Name == GNE_CM_IHCP_Utils.MPS_PERMISSION_SET)
            {
                psIds.MpsPermissionSetId = ps.Id;
            }
            else if (ps.Name == GNE_CM_IHCP_Utils.LWO_PERMISSION_SET)
            {
                psIds.LwoPermissionSetId = ps.Id;   
            }
        }
        
        return psIds;
    }
    
    /**
     * This method assigns permissions sets to SFDC users. Unlike method updateIHCPUserPermissionSets, it does NOT remove any
     * permission set assignments.
     *
     * @param sfdcUsersIds
     *
     */
    @future
    public static void addMpsPermissionSet (List<Id> sfdcUserIds, Boolean deactivateUsers)
    {    	
    	addPermissionSet(sfdcUserIds, deactivateUsers, 'MPS');
    	//wilczekk: removed try/catch as attempt to insert error to error log results in MIXED_DML_EXCEPTION
    	//maybe some refactoring of method calling the addMpsPermissionSet will help so that this method will have no @future annotation
    	//then we can insert @future error log (currently it is not allowed to call @future from @future)
    	/*
        try
        {
        	addPermissionSet(sfdcUserIds, deactivateUsers, 'MPS');    
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_User_Util', 'High', 'addMpsPermissionSet', 'Apex Class', ex);
            insert err;
        }
        */
    }
    
    @future
    public static void addMpsPermissionSet (List<Id> sfdcUserIds, List<Id> sfdcUserIdsToDeactivate)
    {
    	addPermissionSet(sfdcUserIds, sfdcUserIdsToDeactivate, 'MPS');
    	//wilczekk: removed try/catch as attempt to insert error to error log results in MIXED_DML_EXCEPTION
    	//maybe some refactoring of method calling the addMpsPermissionSet will help so that this method will have no @future annotation
    	//then we can insert @future error log (currently it is not allowed to call @future from @future)
    	/*
        try
        {
            addPermissionSet(sfdcUserIds, sfdcUserIdsToDeactivate, 'MPS');
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_User_Util', 'High', 'addMpsPermissionSet', 'Apex Class', ex);
            insert err;
        }
        */
    }
    
    /**
     * This method assigns permissions sets to SFDC users. Unlike method updateIHCPUserPermissionSets, it does NOT remove any
     * permission set assignments.
     *
     * @param sfdcUsersIds
     *
     */
    public static void addLwoPermissionSet (List<Id> sfdcUserIds, Boolean deactivateUsers)
    {
        addPermissionSet(sfdcUserIds, deactivateUsers, 'LWO');
    }
    
    @future
    public static void addLwoPermissionSetAtFuture (List<Id> sfdcUserIds, Boolean deactivateUsers)
    {
	   addPermissionSet(sfdcUserIds, deactivateUsers, 'LWO');
    	//wilczekk: removed try/catch as attempt to insert error to error log results in MIXED_DML_EXCEPTION
    	//maybe some refactoring of method calling the addMpsPermissionSet will help so that this method will have no @future annotation
    	//then we can insert @future error log (currently it is not allowed to call @future from @future)
    	/*
        try
        {
            addPermissionSet(sfdcUserIds, deactivateUsers, 'LWO');
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_User_Util', 'High', 'addLwoPermissionSetAtFuture', 'Apex Class', ex);
            insert err;
        }
        */
    }
    
    private static void addPermissionSet (List<Id> sfdcUserIds, Boolean deactivateUsers, String portal)
    {
        addPermissionSet(sfdcUserIds, deactivateUsers ? sfdcUserIds : new List<Id>(), portal);
    }
    
    private static void addPermissionSet (List<Id> sfdcUserIds, List<Id> sfdcUserIdsToDeactivate, String portal)
    {
        PermissionSetInfo psInfo = getPermissionSetInfo();
        
        Id permissionSetId = null;
        
        if (portal == 'MPS')
        {
            permissionSetId = psInfo.mpsPermissionSetId;
        }
        else if (portal == 'LWO')
        {
            permissionSetId = psInfo.lwoPermissionSetId;
        }
        else
        {
            throw new GNE_CM_Exception('Unsupported portal name \'' + portal + '\'');
        }
        
        // find all permission set assignments for these users and portal permission sets
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, AssigneeId, PermissionSetId
                                                                FROM PermissionSetAssignment 
                                                                WHERE AssigneeId IN :sfdcUserIds AND PermissionSetId = :permissionSetId];
        
        List<PermissionSetAssignment> permissionsSetsToAdd = new List<PermissionSetAssignment>();
        
        // create a permission set assignment for each SFDC user
        for (Id sfdcUserId : sfdcUserIds)
        {
            Boolean assignmentFound = false;
            for (PermissionSetAssignment psa : permissionSetAssignments)
            {
                if (psa.AssigneeId == sfdcUserId && psa.PermissionSetId == permissionSetId)
                {
                    assignmentFound = true;
                    break;
                }
            }
            
            if (!assignmentFound)
            {
                PermissionSetAssignment newPSA = new PermissionSetAssignment();
                newPSA.AssigneeId = sfdcUserId;
                newPSA.PermissionSetId = permissionSetId;
                permissionsSetsToAdd.add(newPSA);
            }
        }
        
        insert permissionsSetsToAdd;
        
        /* Removed due to error in production
    	GNE_CM_UnitTestConfig.setSkipTriggersOnlyInTests(false);
        GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_User_PublicGroup_Association');
        
        if (sfdcUserIdsToDeactivate != null && !sfdcUserIdsToDeactivate.isEmpty())
        {
            // activate users
            List<User> usersToDeactivate = [SELECT Id, IsActive FROM User WHERE Id IN :sfdcUserIdsToDeactivate];
            
            if (usersToDeactivate != null)
            {
                for (User u : usersToDeactivate)
                {
                    u.IsActive = false;
                }
                
                update usersToDeactivate;
            }
        }
        //unskip trigger
        GNE_CM_UnitTestConfig.setSkipTriggersOnlyInTests(true);
        GNE_CM_UnitTestConfig.unskipTriggerForTests('GNE_CM_User_PublicGroup_Association');
        */
    }
    
    public static void updateIHCPUserPermissionSets (List<GNE_CM_IHCP_User__c> ihcpUsers)
    {        
        List<ID> sfdcUserIds = new List<ID>();
        
        for (GNE_CM_IHCP_User__c ihcpUser : ihcpUsers)
        {            
            sfdcUserIds.add(ihcpUser.SFDC_User__c); 
        }
        
        PermissionSetInfo psInfo = getPermissionSetInfo();
        
        // find all permission set assignments for these users and portal permission sets
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, AssigneeId, PermissionSetId
                                                                FROM PermissionSetAssignment 
                                                                WHERE AssigneeId IN :sfdcUserIds AND PermissionSetId IN 
                                                                    (SELECT Id FROM PermissionSet WHERE Name IN :psInfo.permissionSetNames)];
                                                                    
        System.debug('Permission sets = ' + psInfo.permissionSetNames + ', assignments = ' + permissionSetAssignments);
                                                                    
        List<PermissionSetAssignment> permissionsSetsToAdd = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permissionsSetsToDelete = new List<PermissionSetAssignment>();
        
        for (GNE_CM_IHCP_User__c ihcpUser : ihcpUsers)
        {
            // if IHCP user is approved, check if they already have a permission set assignment
            // if not, create one
            if (ihcpUser.MPS_Status__c == 'Approved')
            {
                Boolean assignmentFound = false;
                for (PermissionSetAssignment psa : permissionSetAssignments)
                {
                    if (psa.AssigneeId == ihcpUser.SFDC_User__c && psa.PermissionSetId == psInfo.mpsPermissionSetId)
                    {
                        assignmentFound = true;
                        break;
                    }
                }
                
                if (!assignmentFound)
                {
                    PermissionSetAssignment newPSA = new PermissionSetAssignment();
                    newPSA.AssigneeId = ihcpUser.SFDC_User__c;
                    newPSA.PermissionSetId = psInfo.mpsPermissionSetId;
                    permissionsSetsToAdd.add(newPSA);
                }
            }
            else
            {
                for (PermissionSetAssignment psa : permissionSetAssignments)
                {
                    if (psa.AssigneeId == ihcpUser.SFDC_User__c && psa.PermissionSetId == psInfo.mpsPermissionSetId)
                    {
                        permissionsSetsToDelete.add(psa);
                    }
                }
            }
            
            // if IHCP user is approved, check if they already have a permission set assignment
            // if not, create one
            if (ihcpUser.LWO_Status__c == 'Approved')
            {
                Boolean assignmentFound = false;
                for (PermissionSetAssignment psa : permissionSetAssignments)
                {
                    if (psa.AssigneeId == ihcpUser.SFDC_User__c && psa.PermissionSetId == psInfo.lwoPermissionSetId)
                    {
                        assignmentFound = true;
                        break;
                    }
                }
                
                if (!assignmentFound)
                {
                    PermissionSetAssignment newPSA = new PermissionSetAssignment();
                    newPSA.AssigneeId = ihcpUser.SFDC_User__c;
                    newPSA.PermissionSetId = psInfo.lwoPermissionSetId;
                    permissionsSetsToAdd.add(newPSA);
                }
            }
            else
            {
                for (PermissionSetAssignment psa : permissionSetAssignments)
                {
                    if (psa.AssigneeId == ihcpUser.SFDC_User__c && psa.PermissionSetId == psInfo.lwoPermissionSetId)
                    {
                        permissionsSetsToDelete.add(psa);
                    }
                }
            }
        }
        
        delete permissionsSetsToDelete;
        insert permissionsSetsToAdd;
    }
    
    public static Boolean findUserAndRollbackConversionSteps(String portal, String username)
    {
        Boolean result = false;
        if(portal == 'MPS')
        {           
            GNE_CM_MPS_User__c existingMPSUser = GNE_CM_IHCP_Utils.getMPSUser(getExistingUserName(portal, username));
            if(existingMPSUser != null)
            {
                result = true;
                //convert user profile back to MPS if needed
                GNE_CM_IHCP_User_Util.revertUserProfileTo(existingMpsUser, GNE_CM_IHCP_Utils.getMPSPortalProfileName());
            }           
        }
        if(portal == 'LWO')
        {
            GNE_LWO_User__c existingLWOUser = GNE_CM_IHCP_Utils.getLWOUser(getExistingUserName(portal, username));
            if(existingLWOUser != null)
            {
                result = true;
            }
        }
        return result;
    }
    
    private static String getExistingUserName(String portal, String username)
    {       
        String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        String existingUserName = username;
        if(portal == 'MPS')
        {
            existingUserName += '.gene.mps';
        }
        if(portal == 'LWO')
        {
            existingUserName += '.gene';
        }
        
        if(environmentName != 'PROD')
        {
            existingUserName += '.' + environmentName;
        }       
        return existingUserName;
    }
    
    public static String getCurrentPortalUsername(Id portalUserId, String portal)
    { 
        String userName = '';
        String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        
        if (portal == 'MPS')
        {
            List<GNE_CM_MPS_User__c> mpsUser = [SELECT SFDC_User__r.FederationIdentifier FROM GNE_CM_MPS_User__c WHERE Id =: portalUserId AND SFDC_User__r.FederationIdentifier <> null];      
            if(mpsUser != null && mpsUser.size() > 0)
            {
                userName = mpsUser[0].SFDC_User__r.FederationIdentifier;
                Integer endingPosition = userName.indexOf('.gene.mps');
                if(endingPosition > -1)
                {
                    userName = userName.substring(0, endingPosition);
                }
                if(environmentName != 'PROD')
                {
                    userName += '.' + environmentName;
                }        
            }
        }
        else if (portal == 'LWO')
        {
            List<GNE_LWO_User__c> lwoUser = [SELECT SFDC_User__r.FederationIdentifier FROM GNE_LWO_User__c WHERE Id =: portalUserId AND SFDC_User__r.FederationIdentifier <> null];   
            
            if (lwoUser != null && lwoUser.size() > 0)
            {
                userName = lwoUser[0].SFDC_User__r.FederationIdentifier;
                Integer endingPosition = userName.indexOf('.gene');
                if (endingPosition > -1)
                {
                    userName = userName.substring(0, endingPosition);
                }
                if(environmentName != 'PROD')
                {
                    userName += '.' + environmentName;
                }        
            }
        }
        else
        {
            throw new GNE_CM_Exception('Unsupported portal \'' + portal + '\'');
        }
        
        return userName;
    }
    
    private class PermissionSetInfo
    {
        public Id mpsPermissionSetId { get; set; }
        public Id lwoPermissionSetId { get; set; }
        public List<String> permissionSetNames { get; set; } 
    }

    /**
     * Sets/Clears Spring CM access flags based on whether or not MPS is enabled.
     *
     * @param newUserStatus map of current status from Trigger.new
     * @param newUserSFDCUsers map of current SFDC User Ids from Trigger.new
     * @param oldUserStatus map of current status from Trigger.old, null if insert
     */
    @future
    public static void updateUserSCMFields(
        Map<Id, String> newUserStatus, Map<Id, Id> newUserSFDCUsers, Map<Id, String> oldUserStatus)
    {        
        try 
        {                        
            Set<String> userId2Set=new Set<String>();
            Set<String> userId2Clear=new Set<String>();

            // figure out which users should be set or cleared
            for (String key : newUserStatus.keyset()) 
            {
                boolean MPSStatusChanged = false;

                if (oldUserStatus!=null) 
                {
                    MPSStatusChanged = newUserStatus.get(key) != oldUserStatus.get(key);
                }

                if ((oldUserStatus==null || MPSStatusChanged) && newUserStatus.get(key)=='Approved' && newUserSFDCUsers.get(key)!=null)
                {
                    userId2Set.add(newUserSFDCUsers.get(key));
                } 

                if (MPSStatusChanged && newUserStatus.get(key)!='Approved' && newUserSFDCUsers.get(key)!=null)
                {
                    userId2Clear.add(newUserSFDCUsers.get(key));
                } 
            }


            // set those that need it
            List<User> users2Set=[SELECT Id, Security_Dirty__c, SpringCM2SF__SpringCM_User__c 
                                    FROM User 
                                    WHERE Id IN :userId2Set AND SpringCM2SF__SpringCM_User__c=false];

            for (User u : users2Set) 
            {
                u.OverrideSpringCMUserFlag__c=false;
                u.Security_Dirty__c=true;
                u.SpringCM2SF__SpringCM_User__c=true;
            }
            update users2Set;

            // and clear those that don't
            List<User> users2Clear=[SELECT Id, Security_Dirty__c, SpringCM2SF__SpringCM_User__c, OverrideSpringCMUserFlag__c 
                                        FROM User 
                                        WHERE Id IN :userId2Clear AND SpringCM2SF__SpringCM_User__c=true];

            for (User u : users2Clear) 
            {
                u.OverrideSpringCMUserFlag__c=false;
                u.Security_Dirty__c=false;
                u.SpringCM2SF__SpringCM_User__c=false;
            }
            update users2Clear;        
        }
        catch (Exception e)
        {            
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateUserSCMFields', 'Apex Class', e);
            insert err;
        }        
    }      
}