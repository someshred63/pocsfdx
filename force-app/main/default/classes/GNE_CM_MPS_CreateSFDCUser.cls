global class GNE_CM_MPS_CreateSFDCUser
{    
    // Create SFDC User and populate the fields in the SFDC User FROM the values you get in MPS User
    // and return back the SFDCUser ID.
    //
    // What this method does is:
    // - create an SFDC user for each MPS user
    // - create an iHCP user for each MPS user
    // - assign MPS permission set to the newly-created SFDC user (in an @future method)
    //
    // Karanamk 12/18/2011 - Removed the insertion into error logs as this may lead to Mixed DML Exception in the case
    // of creation of User. We are throwing the exception outside in every case.  
    private static String cachedPortalUserName;
    private static String getPortalUserName()
    {
    	if(cachedPortalUserName == null)
    	{
    		initEnvVariables();
    		return cachedPortalUserName;
    	}
    	else
    	{
    		return cachedPortalUserName;
    	}
    }
    
    private static Set<String> cachedValidRecordTypes;
    private static Set<String> getValidRecordTypes()
    {
    	if(cachedValidRecordTypes == null)
    	{
    		initEnvVariables();
    		return cachedValidRecordTypes;
    	}
    	else
    	{
    		return cachedValidRecordTypes;
    	}
    }
    
    private static void initEnvVariables()
    {    	
        Set<String> envVarNameSet = new Set<String>{'GNE-CM-PORTAL-USER-ACCOUNT-RECORD-TYPES', 'Portal_Admin_Username'};
        Map<String, List<Environment_Variables__c>> envVarMultiValues = GNE_CM_MPS_Utils.populateEnvVariables(envVarNameSet);  
        
        List<Environment_Variables__c> envVarPortalUserName = envVarMultiValues.get('Portal_Admin_Username');
        
        if (envVarPortalUserName != null && envVarPortalUserName.size() > 0)
        {
            cachedPortalUserName = envVarPortalUserName[0].Value__c;
        }
        
        List<Environment_Variables__c> envVarPortalUserAccountRT = envVarMultiValues.get('GNE-CM-PORTAL-USER-ACCOUNT-RECORD-TYPES');
        
        cachedValidRecordTypes = new Set<String>();
        if (envVarPortalUserAccountRT != null)
        {
            for(Environment_Variables__c envVar : envVarPortalUserAccountRT)
            {
                cachedValidRecordTypes.add(envVar.Value__c);
            }
        } 
    }
      
    public static Map<Id, Id> createSFDCUser (Map<Id, GNE_CM_MPS_User__c> newMPSUsers)
    {   
        Set<Id> mpsUserIds = newMPSUsers.keySet();
        // get existing users for other portals (only those converted to IHCP)
        Map<Id, Id> mpsUserToExistingSfdcUser = GNE_CM_IHCP_User_Util.getExistingUsersMap(newMPSUsers);
        
        String portalUserName = getPortalUserName(); 
        Set<String> validRecordTypes = getValidRecordTypes();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,String> emailMap = new Map<Id,String>();
        Map<Id,Id> personContactMap = new Map<Id,Id>();
        List<User> userList = new List<User>();
        Map<Id,User> mpsUserToSFDCUserMap = new Map<Id,User>();
        
        System.debug('validRecordTypes: ' + validRecordTypes);
        
        String ext = getUsernameExtension (UserInfo.getUserName(), portalUserName);     
        
        Map<Id,Id> mpsUsersToPAAccounts = new Map<Id,Id>();
        List<User> duplicateUserList = new List<User>();
        Id portalProfileId = GNE_CM_IHCP_Utils.getIHCPPortalProfileId();          
        try
        {       
            System.debug('mpsUsers :' + newMPSUsers.values());              
            if (newMPSUsers.values().size() > 0)
            {
                // select practice agreements for the MPS users
                List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements = [SELECT Account__c,MPS_User__c,MPS_Registration__c FROM GNE_CM_MPS_Practice_Agreement__c WHERE MPS_User__c in :newMPSUsers.values()];
                
                for(GNE_CM_MPS_Practice_Agreement__c pa : practiceAgreements)
                {
                    for (GNE_CM_MPS_User__c mpsUser : newMPSUsers.values())
                    {
                        if (pa.MPS_Registration__c == mpsUser.GNE_CM_MPS_Registration__c && pa.MPS_User__c == mpsUser.Id)
                        {
                            mpsUsersToPAAccounts.put(pa.MPS_User__c, pa.Account__c);
                            emailMap.put (mpsUser.Id, mpsUser.Email_address__c + ext);
                            break;
                        }        
                    }   
                }
                
                System.debug('PA MAP: ' +   mpsUsersToPAAccounts);
                
                if (mpsUsersToPAAccounts.values() != null && mpsUsersToPAAccounts.values().size() > 0)
                {
                    List<Account> accounts = [SELECT id, FirstName, LastName, name, PersonEmail,
                                                Physician_Portal_Username_gne__c,PersonContactId, RecordType.Name, IsPersonAccount, 
                                                OwnerId, Professional_Type_gne__c,GNE_CM_MPS_Product_Shipped__pc,GNE_CM_MPS_BI_Report_Available__pc,
                                                GNE_CM_MPS_Document__pc,GNE_CM_MPS_PAN_Expiring__pc,
                                                GNE_CM_MPS_GATCF_Prescription__pc,GNE_CM_MPS_GATCF_SMN_Expiring__pc,
                                                GNE_CM_MPS_General__pc, GNE_CM_MPS_Features_Services__pc
                                                FROM Account WHERE id in :mpsUsersToPAAccounts.values()];
                                                      
                    for (Account a : accounts)
                    {
                        for (Id mpsUserID : mpsUsersToPAAccounts.keySet())
                        {
                            if (a.Id == mpsUsersToPAAccounts.get(mpsUserId))
                            {
                                accountMap.put(mpsUserID, a);
                                personContactMap.put(mpsUserId, a.PersonContactId);
                                break;
                            }
                        }
                    }
                    System.debug('Account Map: ' + accountMap);
                    
                    system.debug('emailMap: ' + emailMap);
                    system.debug('personContactMap: ' + personContactMap);
                    
                    if (emailMap.values() != null && emailMap.values().size() > 0 && personContactMap.values() != null && personContactMap.values().size() > 0)
                    {
                        userList = [SELECT Id ,IsActive, Username, ContactId  FROM User WHERE username in : emailMap.values() Or (ContactId in: personContactMap.values())];
                        duplicateUserList = [SELECT Id, Username FROM user WHERE Username in: emailMap.values() and isActive = true];  
                    }
                    
                    System.debug('User List' + userList);
                    System.debug('Duplicate User List' + duplicateUserList);
                }
            }
                                                                
        }
        catch(Exception ex)
        {
            System.Debug('Error occurred createSFDCUser.createSFDCUser: ' + GlobalUtils.getExceptionDescription(ex)); 
            throw ex; 
        }
        
        // maps MPS user IDs to SFDC user IDs
        Map<Id,Id> mpsToSfdcUsers = new Map<Id,Id>();
        List<User> usersToEnable = new List<User>();
        List<GNE_CM_MPS_User__c> mpsUsers = new List<GNE_CM_MPS_User__c>();
        
        system.debug('Looking through new MPS users: ' + newMPSUsers);
        system.debug('mpsToExistingSfdcUser: ' + mpsUserToExistingSfdcUser);
        
        // fetch the MPS users for which SFDC users will be created              
        for (GNE_CM_MPS_User__c u : newMPSUsers.values())
        {
            if (mpsUserToExistingSfdcUser.size() == 0 || !mpsUserToExistingSfdcUser.keySet().contains(u.Id))
            {
                mpsUsers.add(u);
            }
        }       
        
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers)
        {
            Id userId = null;
            String Message;
            String userAlias;
            List<User> sfdcUsers = new List<User>();
            
            User SFDCUser = null;         
            
            try
            {
                system.debug('MPS Users' + mpsUsers);                
                system.debug('MPS User ID' + mpsUser.Id );
                system.debug('MPS Registration ID ' + mpsUser.GNE_CM_MPS_Registration__c);
                
                if (mpsUsersToPAAccounts != null && mpsUsersToPAAccounts.containsKey(mpsUser.Id) && accountMap != null && accountMap.containsKey(mpsUser.ID))
                {                	
                    Account act = accountMap.get(mpsUser.Id);
                    system.debug('Account values:' + act);
                    
                    if (act.IsPersonAccount == false)
                    {
                        Message = 'Portal user can only be enabled for Person accounts.'; 
                        system.debug(Message);
                    }
                    else if (!validRecordTypes.contains(act.RecordType.Name))
                    {
                        Message = 'Portal user cannot be enabled for this account type.';
                        system.debug(Message);             
                    }
                    else if (act.PersonContactId != null)
                    {
                        if (act.Professional_Type_gne__c == null)
                        {
                            Message = 'Account must have a role before portal access can be enabled.';
                            system.debug(Message);
                        }
                        else
                        {   
                            //TODO As per malini, it should be queried against username not email address
                            for (User u : userList)
                            {                            	
                                if (u.username.compareTo(mpsUser.Email_address__c + ext) == 0 || u.ContactId == act.PersonContactId)
                                {
                                    sfdcUsers.add(u);
                                }
                            }
                            
                            if (sfdcUsers != null && !sfdcUsers.isEmpty())
                            {
                                for( integer j=0; j<sfdcUsers.size(); j++)
                                {
                                    System.debug('---------User values at starting of for loop - Username: '+sfdcUsers[j].username); 
                                    System.debug('---------User values at starting of for loop - IsActive: '+sfdcUsers[j].isActive);
                                                                         
                                    if (sfdcUsers[j].isActive == true)
                                    {
                                        userId = sfdcUsers[j].Id;
                                        Message = 'User is already setup as a portal user.';
                                        break;    
                                    }
                                    else if (sfdcUsers[j].isActive != true && sfdcUsers[j].ContactId == act.PersonContactId)
                                    {
                                        sfdcUsers[j].isActive = true;  
                                        userId = sfdcUsers[j].Id;
                                        usersToEnable.add(sfdcUsers[j]);
                                        break;  
                                    }
                                }
                            }
                            
                            if (userId == null) 
                            {        
                                User newSfdcUser = new User();
                                userAlias = act.LastName.substring(0, 1);
                                newSfdcUser.FirstName = act.FirstName;
                                newSfdcUser.LastName = act.LastName;
                                
                                Integer FLength = 0; 
                                if (act.FirstName != null)
                                {
                                    FLength = newSfdcUser.FirstName.length();
                                }
                                
                                Integer lnLength = newSfdcUser.LastName.length();
                                
                                if (FLength > lnLength && FLength < 8)
                                {
                                    userAlias = act.LastName.substring(0, 1); 
                                    newSfdcUser.Alias = act.FirstName + userAlias;
                                }
                                else if (lnLength >FLength && lnLength <8)
                                {
                                    if (act.FirstName != null)
                                    userAlias = act.FirstName.substring(0, 1); 
                                    
                                    newSfdcUser.Alias = act.LastName + userAlias;
                                }              
                                else if (lnLength > 8 && FLength >8)
                                {
                                    newSfdcUser.Alias = act.FirstName.substring(0,7);
                                }
                                else
                                {
                                    if (lnLength > 8)
                                    {
                                        newSfdcUser.Alias = act.LastName.substring(0,7);
                                    } 
                                    
                                    if (FLength > 8)
                                    {
                                        newSfdcUser.Alias = act.FirstName.substring(0,7);
                                    }                   
                                }
                                
                                newSfdcUser.FirstName = mpsUser.First_name__c;
                                newSfdcUser.LastName = mpsUser.Last_name__c;
                                newSfdcUser.Phone = mpsUser.Phone_number__c;
                                newSfdcUser.Email = mpsUser.Email_address__c;
                                newSfdcUser.ContactId = act.PersonContactId ;
                                newSfdcUser.Username = mpsUser.Email_address__c + ext;
                                newSfdcUser.isActive = true;
                                newSfdcUser.TimeZoneSidKey = 'America/Los_Angeles';
                                newSfdcUser.LocaleSidKey = 'en_US';
                                newSfdcUser.LanguageLocaleKey = 'en_US';
                                newSfdcUser.EmailEncodingKey = 'UTF-8';
                                newSfdcUser.OverrideSpringCMUserFlag__c = false;
                                newSfdcUser.ProfileId = portalProfileId;
                                
                                newSfdcUser.External_ID_gne__c = mpsUser.Email_address__c + ext;
                                system.debug('External Id value:'+newSfdcUser.External_ID_gne__c);
                                
                                Boolean usernameAlreadyExists = false;
                                                                   
                                for (User u : duplicateUserList)
                                {
                                    if (u.username == newSfdcUser.Username)
                                    {
                                        usernameAlreadyExists = true;
                                        break;
                                    }
                                }
                                 
                                if (!usernameAlreadyExists)
                                {
                                    try
                                    {
                                        mpsUserToSFDCUserMap.put(mpsUser.Id, newSfdcUser); 
                                        // UpdateEmailPerf(act.id,true,portalusername);
                                    }
                                    catch(Exception ex)
                                    {
                                        System.debug('Exception occured' + GlobalUtils.getExceptionDescription(ex));
                                        //Commented the insertion into error logs as this may lead to Mixed DML Exception in the case
                                        /* Error_Log_gne__c errorLog = new Error_Log_gne__c();
                                            errorLog = GNE_CM_MPS_Utils.createError('User', 'Medium', 'GNE_CM_MPS_CreateSFDCUser', 'Apex Class', ex);
                                            Database.insert(errorLog); */
                                        throw ex;     
                                    }        
                                }
                                else
                                {
                                    Message = 'Portal User cannot be enabled for this account because username: '+ newSfdcUser.Username + ' already exists';
                                    System.debug(Message);
                                }
                            }
                            
                        }
                    }
                    else if (act.PersonContactId == null)
                    {
                        Message = 'Portal User cannot be enabled because Contact is missing for this account.';
                        System.debug(Message);
                    }  
                }
            }      
            catch (Exception ex)
            {
                //TODO Missing error logging (error_log_gne__c)
                //Commented the insertion into error logs as this may lead to Mixed DML Exception in the case
                /* Error_Log_gne__c errorLog = new Error_Log_gne__c();
                errorLog = GNE_CM_MPS_Utils.createError('User', 'High', 'GNE_CM_MPS_CreateSFDCUser', 'Apex Class', ex);
                Database.insert(errorLog);*/
                System.Debug('Error occurred createSFDCUser.createSFDCUser: ' + GlobalUtils.getExceptionDescription(ex)); 
                throw ex; 
            }
            
            if (userId != null)
            {            
                mpsToSfdcUsers.put(mpsUser.Id,userId);
            }
        }
        
        
        try
        {         
            if (usersToEnable.size() > 0)
            {                
                List<ID> userIds = new List<ID>();
                for (integer j=0; j<usersToEnable.size(); j++)
                {
                    userIds.add(usersToEnable.get(j).Id);
                }
                EnableUser(userIds);
                //UpdateEmailPerf(act.id,true,portalusername);           
            }
            
            List<Id> sfdcUsersForMPS = new List<Id>();
            // this list will contain ONLY newly created SFDC users, not those that have already existed for other portals
            // and will only be activated for MPS during this process
            List<Id> newSfdcUsersForMPS = new List<Id>();
                      
            if (mpsUserToSFDCUserMap.values().size() > 0)
            {                              
                insert mpsUserToSFDCUserMap.values();
                System.debug('[RK] Inserted SFDC users: ' + mpsUserToSFDCUserMap.values());
                
                // add permission sets to MPS               
                for (User u : mpsUserToSFDCUserMap.values())
                {
                    sfdcUsersForMPS.add(u.Id);
                    newSfdcUsersForMPS.add(u.Id);
                }               
            }
            
            // pull existing IHCP users by email and add SFDC User ids to the list for permission set
            List<GNE_CM_IHCP_User__c> existingIHCPUsers = [SELECT Id, SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c IN :mpsUserToExistingSfdcUser.values()];
            System.debug('Existing IHCP users: ' + existingIHCPUsers); 
            Map<Id, String> existingSfdcUsersToPortal = new Map<id, String>();          
            for(GNE_CM_IHCP_User__c u : existingIHCPUsers)
            {
                sfdcUsersForMPS.add(u.SFDC_User__c);
                existingSfdcUsersToPortal.put(u.Sfdc_User__c, 'MPS');
            }
               
            // call a '@future' method to add permission sets to MPS for the newly-created SFDC users
            if (sfdcUsersForMPS.size() > 0)
            {
                GNE_CM_IHCP_User_Util.addMpsPermissionSet(sfdcUsersForMPS, newSfdcUsersForMPS);
            }
            
            // make sure the agreement ID confirmed for the new users
            GNE_CM_Webservice_UserAgreement.setUserAgreement(newSfdcUsersForMPS, true);
            // make sure the agreement IS confirmed for user that already had LWO access
            GNE_CM_Webservice_UserAgreement.setUserAgreement(mpsUserToExistingSfdcUser.values(), false);
            
            Map<Id, String> sfdcUserToPortal = new Map<Id, String>();
                               
            for (Id mpsUserId : mpsUserToSFDCUserMap.keySet())
            {   
                mpsToSfdcUsers.put(mpsUserId, mpsUserToSFDCUserMap.get(mpsUserId).Id);
                sfdcUserToPortal.put (mpsUserToSFDCUserMap.get(mpsUserId).Id, 'MPS');
            }
            
            // create IHCP users for the newly-created SFDC users and update existing IHCP users if needed
            GNE_CM_IHCP_User_Util.setupIHCPUsers(sfdcUserToPortal, existingSfdcUsersToPortal, existingIHCPUsers, 'Approved');
            
            // add existing mpsUsers
            for (Id mpsUserId : mpsUserToExistingSfdcUser.keySet())
            {
            	mpsToSfdcUsers.put(mpsUserId, mpsUserToExistingSfdcUser.get(mpsUserId));
        	}
            
            List<Id> actIds = new List<Id>();
            for (Id mpsId : mpsToSfdcUsers.keySet())
            {
                if (accountMap.containsKey(mpsId))
                {
                    actIds.add(accountMap.get(mpsId).id);
                }
            } 
                 
            UpdateEmailPerf(actIds,true,portalusername);
        }
        catch(Exception ex)
        {
            System.debug('Exception occured' + GlobalUtils.getExceptionDescription(ex));
            //Commented the insertion into error logs as this may lead to Mixed DML Exception in the case
            /* Error_Log_gne__c errorLog = new Error_Log_gne__c();
            errorLog = GNE_CM_MPS_Utils.createError('User', 'Medium', 'GNE_CM_MPS_CreateSFDCUser', 'Apex Class', ex);
            Database.insert(errorLog); */
            throw ex;     
        }
        
        return mpsToSfdcUsers;
    }

    //TODO Missing Try Catch
    //TODO Missing error logging (error_log_gne__c)
    public static String validateSFDCUser(List<Id> mpsUserIds)
    {
        String users = '';
        Map<Id,Id> paMap = new Map<Id,Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,Boolean> validMap = new Map<Id,Boolean>();
        List<GNE_CM_MPS_User__c> mpsUsers = new List<GNE_CM_MPS_User__c>(); 
        	
        String portalUserName = getPortalUserName();
		String ext = getUsernameExtension (UserInfo.getUserName(), portalUserName); 
        	      
        try
        {
            if (mpsUserIds != null && mpsUserIds.size() > 0)
            {
                mpsUsers = [SELECT Id, First_name__c, Name, Last_name__c, Phone_number__c, 
                			GNE_CM_MPS_Registration__c,Email_address__c,Is_Migrated__c FROM GNE_CM_MPS_User__c WHERE Id in :mpsUserIds];
                if (mpsUsers.size() > 0)
                {
                    List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements = [SELECT Account__c, MPS_User__c, MPS_Registration__c FROM GNE_CM_MPS_Practice_Agreement__c 
                    															WHERE MPS_User__c in :mpsUsers] ;
                    Map<String,Id> emailMap = new Map<String,Id>();
                    for(GNE_CM_MPS_Practice_Agreement__c pa : practiceAgreements)
                    {
                        for(GNE_CM_MPS_User__c mpsUser : mpsUsers)
                        {
                            if (pa.MPS_Registration__c == mpsUser.GNE_CM_MPS_Registration__c && pa.MPS_User__c == mpsUser.Id)
                            {
                                paMap.put(pa.MPS_User__c, pa.Account__c);
                                emailMap.put(mpsUser.Email_address__c + ext, mpsUser.Id);
                                break;
                            }        
                        }   
                    }  
                    List<Account> accounts = [SELECT id, FirstName, LastName, name, PersonEmail,
						                    Physician_Portal_Username_gne__c,PersonContactId, RecordType.Name, IsPersonAccount, 
						                    OwnerId, Professional_Type_gne__c,GNE_CM_MPS_Product_Shipped__pc,GNE_CM_MPS_BI_Report_Available__pc,
						                    GNE_CM_MPS_Document__pc,GNE_CM_MPS_PAN_Expiring__pc,
						                    GNE_CM_MPS_GATCF_Prescription__pc,GNE_CM_MPS_GATCF_SMN_Expiring__pc,
						                    GNE_CM_MPS_General__pc, GNE_CM_MPS_Features_Services__pc
						                    FROM Account WHERE id in :paMap.values()];         
                    for(Account a : accounts)
                    {
                        for(Id mpsUserID : paMap.keySet())
                        {
                            if (a.Id == paMap.get(mpsUserId))
                            {
                                accountMap.put(mpsUserID,a);
                                break;
                            }
                        }
                    }
                    if (emailMap.keySet() != null && emailMap.keySet().size() > 0)
                    {
                        List<User> sfdcUsers = [SELECT ContactId,username FROM User WHERE username in : emailMap.keySet()];
                        for(User u : sfdcUsers)
                        {
                            if (emailMap.containsKey(u.username))
                            {
                                Id userId = emailMap.get(u.username);
                                if (accountMap.containsKey(userId) && u.ContactId != accountMap.get(userId).PersonContactId)
                                {
                                    validMap.put(userId,false);
                                }
                            }
                        }
                    }
                }
            }           
        }
        catch(Exception ex)
        {
            System.Debug('Error occurred createSFDCUser.ValidateSFDCUser: ' + GlobalUtils.getExceptionDescription(ex)); 
            throw ex; 
        }  
        for(GNE_CM_MPS_User__c mpsUser : mpsUsers)
        {   
            if (!validMap.containsKey(mpsUser.Id))
            {
                continue;
            }
            else
            {
                users += mpsUser.Name;
            }
        }
        return users;
    } 

    
    //Karanamk 09/18/2011 - Setting email preferences by default 
    @future
    public static void updateEmailPerf(List<Id> accountids, Boolean value, String portalAdminUser)
    {
        system.debug('Inside Update Email Preferences: '+portalAdminUser);
        List<User> usr = new List<User>();
        string result_msg='SUCCESS';
        usr =[SELECT Id FROM User WHERE username = :portalAdminUser LIMIT 1];
        //TODO Runtime Exception usr != null
        if (usr.size() > 0)
        {
            system.debug('User Size: '+usr.size());
            try
            {
                if (accountids != null && accountids.size() > 0)
                {
                    List<Account> acts = [SELECT Id,GNE_CM_MPS_Product_Shipped__pc,GNE_CM_MPS_BI_Report_Available__pc,
                    GNE_CM_MPS_Document__pc,GNE_CM_MPS_PAN_Expiring__pc,
                    GNE_CM_MPS_GATCF_Prescription__pc,GNE_CM_MPS_GATCF_SMN_Expiring__pc,
                    GNE_CM_MPS_General__pc, GNE_CM_MPS_Features_Services__pc
                    FROM Account WHERE id in :accountids];
                    for(Account act : acts)
                    {
                        act.GNE_CM_MPS_General__pc = act.GNE_CM_MPS_Document__pc = act.GNE_CM_MPS_GATCF_Prescription__pc =  
                        act.GNE_CM_MPS_GATCF_SMN_Expiring__pc = act.GNE_CM_MPS_PAN_Expiring__pc = act.GNE_CM_MPS_Product_Shipped__pc =
                        act.GNE_CM_MPS_BI_Report_Available__pc = act.GNE_CM_MPS_Features_Services__pc = value;
                        system.debug('Boolean value: '+value);
                        act.OwnerId = usr[0].Id;
                    }
                    update acts;
                }
            }
            catch(DMLException ex)
            {
                //TODO Missing error logging (error_log_gne__c)
                System.debug('An error occurred while updating account owner. ERROR: '+ex);
                //Commented the insertion into error logs as this may lead to Mixed DML Exception in the case
                /* Error_Log_gne__c errorLog = new Error_Log_gne__c();
                errorLog = GNE_CM_MPS_Utils.createError('User', 'Medium', 'UpdateEmailPerf', 'Apex Class', ex);
                Database.insert(errorLog); */
                throw ex;                   
            }
        }
        
    }
    
    @future
    public static void updateEmailPrefAsynch(List<Id> mpsUserIds, Boolean value)
    {
        Map<Id,Id> paMap = new Map<Id,Id>();
        List<GNE_CM_MPS_User__c> mpsUsers = new List<GNE_CM_MPS_User__c>();         
        
        try
        {
            if (mpsUserIds != null && mpsUserIds.size() > 0)
            {
                mpsUsers = [SELECT Id, First_name__c, Last_name__c, Phone_number__c, 
                GNE_CM_MPS_Registration__c,Email_address__c,Is_Migrated__c FROM GNE_CM_MPS_User__c WHERE Id in :mpsUserIds];
                if (mpsUsers.size() > 0)
                {
                    List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements = [SELECT Account__c,MPS_User__c,MPS_Registration__c FROM  GNE_CM_MPS_Practice_Agreement__c WHERE MPS_User__c in :mpsUsers] ;
                    for(GNE_CM_MPS_Practice_Agreement__c pa : practiceAgreements)
                    {
                        for(GNE_CM_MPS_User__c mpsUser : mpsUsers)
                        {
                            if (pa.MPS_Registration__c == mpsUser.GNE_CM_MPS_Registration__c && pa.MPS_User__c == mpsUser.Id)
                            {
                                paMap.put(pa.MPS_User__c,pa.Account__c);
                                break;
                            }        
                        }   
                    }
                    if (paMap.values() != null && paMap.values().size() > 0)
                    {  
                        List<Account> accounts = [SELECT GNE_CM_MPS_Product_Shipped__pc,GNE_CM_MPS_BI_Report_Available__pc,
                        GNE_CM_MPS_Document__pc,GNE_CM_MPS_PAN_Expiring__pc,
                        GNE_CM_MPS_GATCF_Prescription__pc,GNE_CM_MPS_GATCF_SMN_Expiring__pc,
                        GNE_CM_MPS_General__pc, GNE_CM_MPS_Features_Services__pc
                        FROM Account WHERE id in :paMap.values()];         
                        for(Account act : accounts)
                        {
                            act.GNE_CM_MPS_General__pc = act.GNE_CM_MPS_Document__pc = act.GNE_CM_MPS_GATCF_Prescription__pc =  
                            act.GNE_CM_MPS_GATCF_SMN_Expiring__pc = act.GNE_CM_MPS_PAN_Expiring__pc = act.GNE_CM_MPS_Product_Shipped__pc =
                            act.GNE_CM_MPS_BI_Report_Available__pc = act.GNE_CM_MPS_Features_Services__pc = value;
                        }  
                        update accounts;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            System.Debug('Error occurred createSFDCUser.UpdateEmailPrefAsynch: ' + GlobalUtils.getExceptionDescription(ex)); 
            throw ex; 
        }   
    } 
    
    @future
    public static void enableDisableUser(List<Id> mpsUserIds,Boolean value)
    {
        Map<Id,Id> paMap = new Map<Id,Id>();
        List<GNE_CM_MPS_User__c> mpsUsers = new List<GNE_CM_MPS_User__c>();
        List<User> users = new List<User>();
        List<Id> sfdcUserIds = new List<Id>();
        try
        {
            if (mpsUserIds != null && mpsUserIds.size() > 0)
            {
                mpsUsers = [SELECT Id, First_name__c, Last_name__c, Phone_number__c, 
                GNE_CM_MPS_Registration__c,Email_address__c,Is_Migrated__c,SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Id in :mpsUserIds];
                for(GNE_CM_MPS_User__c mpsUser : mpsUsers)
                {
                    sfdcUserIds.add(mpsUser.SFDC_User__c);
                }
                if (sfdcUserIds.size() > 0)
                {
                    users = [SELECT isActive, ContactId FROM User WHERE Id in : sfdcUserIds];         
                    for(User user : users)
                    {
                        if (user.isActive != value)
                        {
                            user.isActive = value;                
                        }
                    }
                    update users; 
                }
            }                                                                
        }
        catch(Exception ex)
        {
            System.Debug('Error occurred createSFDCUser.createSFDCUser: ' + GlobalUtils.getExceptionDescription(ex)); 
            throw ex; 
        } 
        
    }

    @future
    public static void updateUserName(ID userId,string username)
    {
        List<User> users = [SELECT isActive, ContactId FROM User WHERE Id = :userId];
        if (users <> null && users.size() == 1)
        {
            try
            {   
                users.get(0).username = username;
                update users.get(0);
            } 
            catch(DMLException ex)  
            {
                //TODO Missing error logging (error_log_gne__c)
                //Commented the insertion into error logs as this may lead to Mixed DML Exception in the case
                /* Error_Log_gne__c errorLog = new Error_Log_gne__c();
                errorLog = GNE_CM_MPS_Utils.createError('User', 'Medium', 'GNE_CM_MPS_CreateSFDCUser', 'Apex Class', ex);
                Database.insert(errorLog);   */             
                System.debug('ERROR: '+ ex); 
                throw ex;     
            }  
            
        }
    }
    @future
    public static void enableUser(List<ID> userIds)
    {
        try
        {
            if (userIds != null && userIds.size() > 0)
            {
                List<User> userList = [SELECT isActive, ContactId FROM User WHERE Id in :userIds];            
                for(User user : userList)
                {
                    if (user.isActive == false)
                    {
                        user.isActive = true;                
                    }
                }               
                update userList;
            }
        } 
        catch(DMLException ex)  
        {
            //wilczekk: we have to consider logging this exception somehow as it might not be thrown to proper thread...
            //TODO Missing error logging (error_log_gne__c)
            //Commented the insertion into error logs as this may lead to Mixed DML Exception in the case
            /* Error_Log_gne__c errorLog = new Error_Log_gne__c();
            errorLog = GNE_CM_MPS_Utils.createError('User', 'Medium', 'GNE_CM_MPS_CreateSFDCUser', 'Apex Class', ex);
            Database.insert(errorLog); */
            System.debug('ERROR: '+ ex); 
            throw ex;     
        }        
    }
    
    /**
     * Returns the username and email extensions for a new user depending on the environment. The extension contains the preceding dot.
     * 
     * @returns For PRD, the username extension will be empty. For other environments, the username extension will be the name of the abbreviation of the
     * environment name, e.g. '.dev', '.uat'
     * 
     */
    private static String getUsernameExtension (String username, String portalUserName)
    {
        String env = '';
        String result = '';
        
        if (username.indexOf('@gene.com') > 0 && username.indexOf('@gene.com.') < 0)
        {      
            env = 'prod';
        }      
        else if (username.indexOf('@gene.com.') > 0)
        {     
            env = username.Substring (username.indexOf('@gene.com.') + 10, username.length());
        }
        
        if (env != 'prod')
        {
            portalUserName = portalUserName + '.' + env;
        }
        
        if (env == 'prod')
        {
            result = '';
        }
        else
        {
            result = '.' + env;
        }
        
        return result;
    }
}