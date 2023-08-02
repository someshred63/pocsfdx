/**
 * Misc utilities for IHCP/MPS applications.
 * @author Radek Krawiec
 *
 * Test classes: GNE_CM_IHCP_Utils_Test
 */
public class GNE_CM_IHCP_Utils
{
    private static final String IHCP_PROFILE_NAME = 'GNE-CM-IHCP-PROFILE';
    private static final String MPS_PROFILE_NAME = 'GNE-CM-Physician Profile';
    private static final String IHCP_SITE_PROFILE = 'IHCP Profile';
    private static final String LWO_PROFILE_NAME = 'GNE-LWO-USER';
    public static final String MPS_PERMISSION_SET = 'MPS_Portal_Access';
    public static final String LWO_PERMISSION_SET = 'LWO_Portal_Access';    
    
    public static Boolean isLoggedIn()
    {
        ID profileId = UserInfo.getProfileId();
        Integer profileCount = [SELECT COUNT() FROM Profile WHERE Id = :profileId AND Name = :IHCP_PROFILE_NAME];
        
        return profileCount > 0;
    }
    
    public static String getIHCPPortalProfileName()
    {   
        return IHCP_PROFILE_NAME;
    }
    
    public static String getMPSPortalProfileName()
    {
        return MPS_PROFILE_NAME;
    }
    
    public static String getLWOPortalProfileName()
    {
        return LWO_PROFILE_NAME;
    }
    
    public static String getSiteProfileName()
    {
        return IHCP_SITE_PROFILE;
    }
    
    public static Map<String, Id> getPortalProfileId(List<String> profileNames)
    {
        Map<String, Id> result = new Map<String, Id>();
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Name IN :profileNames])
        {
            result.put(p.Name, p.Id);
        }
        return result;
    }
    
    public static PageReference getLWOHomePage()
    {
        PageReference result;
        String loginPage = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c;
        if(loginPage!=null)
        {
            result = new PageReference(loginPage);          
        }
        else
        {
            result = Page.GNE_LWO_Login_Panel;
        }
        return result;
    }
    
    /**
	 * Insert message into error log with information about patient, medical history and cases.
	 */
	public static void addCaseError (Exception error, String objectName, String SnippetName, String patientId, String medicalHistoryId, string parentCaseId, string childCaseId)
	{
		try
		{
			insert GNE_CM_MPS_Utils.createError(objectName, 'High', SnippetName, 'Apex Class', 'Error for patient Id: ' + patientId + ', medical history Id:' + medicalHistoryId + ', parent case: ' + parentCaseId + ', child case: ' + childCaseId, error);
    	}
		catch (Exception e)
		{
			System.debug('Error inserting error into log: ' + e.getMessage());	
		}
   }
    
    //Jie made teh change for PODIS - LOW integration project
    public static PageReference getLWOHomePage(String portal)
    {
        PageReference result;
        String loginPage;
        
        if(portal == 'LWO')
        loginPage = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().LWO_Login_Page__c;
        else if(portal == 'PODIS') loginPage = GNE_LWO_CustomSettingsHelper.self().getLWOConfig().PODIS_Login_page__c;
        if(loginPage!=null)
        {
            result = new PageReference(loginPage);          
        }
        else
        {
            result = Page.GNE_LWO_Login_Panel;
        }
        return result;
    }
    
    public static Id getIHCPPortalProfileId()
    {
        String profileName = getIHCPPortalProfileName();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
        if (profiles == null || profiles.isEmpty())
        {
            throw new GNE_CM_Exception('No profile with name \'' + profileName + '\' found');
        }
        
        return profiles.get(0).Id;
    }
    
   
    public static Boolean hasMPSPermissionSet()
    {
        return hasPermissionSet(MPS_PERMISSION_SET, UserInfo.getUserId());
    }
    
    public static Boolean hasLWOPermissionSet()
    {
        return hasPermissionSet(LWO_PERMISSION_SET, UserInfo.getUserId());
    }
    
    public static Boolean hasMPSPermissionSet(Id sfdcUserId)
    {
        return hasPermissionSet(MPS_PERMISSION_SET, sfdcUserId);
    }
    
    public static Boolean hasLWOPermissionSet(Id sfdcUserId)
    {
        return hasPermissionSet(LWO_PERMISSION_SET, sfdcUserId);
    }
    
    private static Boolean hasPermissionSet (String permissionSetName, ID userId)
    {
        Integer cnt = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = :permissionSetName)];
        return cnt > 0;
    }
    
    @future
    public static void lockIHCPUserAtFuture (ID ihcpUserId, Boolean isLocked)
    {
        List<GNE_CM_IHCP_User__c> localIhcpUsers = [Select IsLocked__c, Login_Failed__c, Locked_Date_Time__c from GNE_CM_IHCP_User__c WHERE ID =:ihcpUserId];
        
        GNE_CM_IHCP_User__c localIhcpUser = localIhcpUsers.get(0);
        
        if(isLocked)
        {
            localIhcpUser.IsLocked__c = true;
            localIhcpUser.Locked_Date_Time__c=System.now();
            localIhcpUser.Login_Failed__c=0;
        }
        else
        {
            localIhcpUser.IsLocked__c = false;
            localIhcpUser.Locked_Date_Time__c=null;
            localIhcpUser.Login_Failed__c=0;
        }
        
        update localIhcpUser;                                                    
    }
    
    public static void unflagUsersFromConversion(Id sfdcUser, String portal, Id currentSFDCUserId)
    {
        if(portal == 'LWO')
        {
            List<GNE_LWO_User__c> lwoUser = [SELECT Change_Password__c FROM GNE_LWO_User__c WHERE SFDC_User__c =: sfdcUser];
            if(lwoUser != null && lwoUser.size() > 0)
            {
                if(lwoUser[0].Change_Password__c)
                {
                    lwoUser[0].Change_Password__c = false;
                    lwouser[0].Workflow_State__c='ACTIVATED';
                    
                }
                lwoUser[0].SFDC_User__c = currentSFDCUserId;
                update lwoUser;
            }
        }
        else if(portal == 'MPS')
        {            
            List<GNE_CM_MPS_User__c> mpsUser = [SELECT Change_Password__c FROM GNE_CM_MPS_User__c WHERE SFDC_User__c =: sfdcUser];
            if(mpsUser != null && mpsUser.size() > 0)
            {
                if(mpsUser[0].Change_Password__c)
                {
                    mpsUser[0].Change_Password__c = false;
                    mpsUser[0].Workflow_State__c='ACTIVATED';
                }
                mpsUser[0].SFDC_User__c = currentSFDCUserId;
                update mpsUser;
            }
        }
    }
    
    public static Boolean isUserUnconverted(String email, String portal)
    {
        Boolean result = false;
        if(portal == 'MPS')
        {
            List<User> users = [SELECT Profile.Name FROM User WHERE Id IN (SELECT SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Email_address__c =: email)];
            if(users != null && users.size() > 0)
            {
                if(MPS_PROFILE_NAME == users[0].Profile.Name)
                {
                    result = true;
                }
            }
        }
        else if(portal == 'LWO')
        {
            List<User> users = [SELECT Profile.Name FROM User WHERE Id IN (SELECT SFDC_User__c FROM GNE_LWO_User__c WHERE Email__c =: email)];
            if(users != null && users.size() > 0)
            {
                if(LWO_PROFILE_NAME == users[0].Profile.Name)
                {
                    result = true;
                }
            }
        }
        return result;
    }
    
    //the primary key for getting IHCP User is Name field - being salesforce username
    public static GNE_CM_IHCP_User__c getIHCPUser (String sfdcUsername)
    {
        sfdcUsername = sfdcUsername.trim();
        List<GNE_CM_IHCP_User__c> ihcpUsers = 
            [SELECT Id, MPS_Status__c, LWO_Status__c, SFDC_User__r.username,
                IsLocked__c,
                Login_Failed__c,
                Locked_Date_Time__c,
                Email_Address__c,
                Security_Question_Answer_City_Of_Birth__c,
                Security_Question_Answer_City_Of_Job__c,
                Security_Question_Answer_Day_Of_Birth__c //, Security_Question_Answer__c 
            FROM GNE_CM_IHCP_User__c 
            WHERE SFDC_User__r.Username = :sfdcUsername];
        
        if (ihcpUsers == null || ihcpUsers.isEmpty())
        {
            return null;
        }
        
        return ihcpUsers.get(0);
    }
    
    public static GNE_CM_IHCP_User__c getCurrentIHCPUser()
    {
        return getIHCPUser(UserInfo.getUsername());
    }
        
    public static GNE_CM_MPS_User__c getMPSUser(String sfdcUsername)
    {
        System.debug('sfdcusername==='+sfdcUsername);
        // Security_Question_Answer_City_Of_Birth__c, Security_Question_Answer_City_Of_Job__c, Security_Question_Answer_Day_Of_Birth__c,
        List<GNE_CM_MPS_User__c> mpsUsers = 
            [SELECT Id, SFDC_User__c, Activation_Hash_Number__c,  
                First_name__c, Last_name__c, Email_address__c, User_Status__c,  Phone_number__c, Phone_number_ext__c, Change_Password__c
            FROM GNE_CM_MPS_User__c WHERE SFDC_User__c IN (SELECT Id FROM User WHERE Username = :sfdcUsername)];
        
        if (mpsUsers == null || mpsUsers.isEmpty())
        {
            return null;
        }
        
        return mpsUsers.get(0);
    }
    
    public static GNE_LWO_User__c getLWOUser (String sfdcUsername)
    {
        // Security_Question_Answer_City_Of_Birth__c, Security_Question_Answer_City_Of_Job__c, Security_Question_Answer_Day_Of_Birth__c,
        List<GNE_LWO_User__c> lwoUsers = 
            [SELECT Id, Name,
                Activation_Email_Sent_Date__c,
                Activation_Hash_Number__c,
                Activation_Server__c,
                Change_Password__c,                
                Email__c,
                First_Name__c,                
                Is_Physician__c,
                Last_Name__c,
                Last_Password_Modified_Date__c,
                Reset_Password_Email_Sent_Date__c,
                SAP_Id__c,
                SFDC_User__c,
                User_Name__c,
                Workflow_State__c,
                SFDC_User__r.Phone,
                SFDC_User__r.Extension,
                SFDC_User__r.ContactId,
                SFDC_User__r.Contact.Email,
                SFDC_User__r.Contact.Phone,
                SFDC_User__r.Contact.Ext_gne__c
            FROM GNE_LWO_User__c 
            WHERE SFDC_User__r.Username = :sfdcUsername];
        
        if (lwoUsers == null || lwoUsers.isEmpty())
        {
            return null;
        }
        
        return lwoUsers.get(0);
    }
    
    public static GNE_LWO_User__c getLWOUserForProfileSettings (String sfdcUsername)
    {
        // Security_Question_Answer_City_Of_Birth__c, Security_Question_Answer_City_Of_Job__c, Security_Question_Answer_Day_Of_Birth__c,
        List<GNE_LWO_User__c> lwoUsers = 
            [SELECT Id, Name,
                Activation_Email_Sent_Date__c,
                Activation_Hash_Number__c,
                Activation_Server__c,
                Change_Password__c,                
                Email__c,
                First_Name__c,                
                Is_Physician__c,
                Last_Name__c,
                Last_Password_Modified_Date__c,
                Reset_Password_Email_Sent_Date__c,
                SAP_Id__c,
                SFDC_User__c,
                User_Name__c,
                Workflow_State__c,
                SFDC_User__r.Phone,
                SFDC_User__r.Extension,
                SFDC_User__r.ContactId                
            FROM GNE_LWO_User__c 
            WHERE SFDC_User__r.Username = :sfdcUsername];
        
        if (lwoUsers == null || lwoUsers.isEmpty())
        {
            return null;
        }
        
        return lwoUsers.get(0);
    }
    
    public static GNE_CM_MPS_User__c getMPSUserById (Id userId)
    {
        //Security_Question_Answer_City_Of_Birth__c, Security_Question_Answer_City_Of_Job__c, Security_Question_Answer_Day_Of_Birth__c,
        List<GNE_CM_MPS_User__c> mpsUsers = 
            [SELECT Id, SFDC_User__c, Activation_Hash_Number__c,  
                First_name__c, Last_name__c, Email_address__c, User_Status__c,  Phone_number__c, Phone_number_ext__c 
            FROM GNE_CM_MPS_User__c WHERE SFDC_User__c IN (SELECT Id FROM User WHERE Id = :userId)];
        
        if (mpsUsers == null || mpsUsers.isEmpty())
        {
            return null;
        }
        
        return mpsUsers.get(0);
    }
    
    public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, String errorDesc)
    {
        Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = objectName, 
                                                      Error_Level_gne__c = errorLevel,
                                                      Snippet_Name__c = snippetName, 
                                                      Code_Type__c = codeType, 
                                                      Error_Description__c = errorDesc,
                                                      User_Name__c = getUserName());
        return error; 
    }
    
    public static Error_Log_gne__c createError(String objectName, String errorLevel, String snippetName, String codeType, Exception e)
    {
        return createError (objectName, errorLevel, snippetName, codeType, GlobalUtils.getExceptionDescription(e));
    }


    private static String getUserName()
    {
        String userName;
        userName=UserInfo.getUserName();
        
        if(userName.length() > 30)
        {
            userName=userName.subString(0,29);
        }
        return userName;
    }
    
    public static void sendEmailNotification(String body, String toAddress, String subject, String senderDisplayName, String sourceClass, String sourceMethod, Boolean isHtml)
    {                       
        try
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{toAddress});
            mail.setSubject(subject);
            mail.setSenderDisplayName(senderDisplayName);                          
                                                                        
            String mailText = body;
            
            if (isHtml)
            {
                mail.setHtmlBody(mailText);
            }
            else
            { 
                mail.setPlainTextBody(mailText);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('[MPS] Activation confirmation sent to \'' + mail + '\'');
        }
        catch (Exception e)
        {
            Error_Log_gne__c error = createError(sourceClass, 'High', sourceClass + '.' + sourceMethod, 'Apex Code', 'Error sending activation emails: ' + GlobalUtils.getExceptionDescription(e));
            insert error;
        }
    }
   
    /*
    The method returning difference in minutes between two datetime
    */ 
    public static Long subtractDate(DateTime highDate, DateTime lowDate)
    {
      Long timeDiff = highDate.getTime() - lowDate.getTime();
      return timeDiff/60000; // 1000 milliseconds * 60 seconds
     }
    
    public static Boolean isResetPasswordEmailValid(DateTime passwordChange, DateTime emailSent)
    {
        DateTime t = DateTime.now();
        Decimal period = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Reset_Password_Link_Validity_Days__c;
        if (period != null)
        {
            t = t.addDays(-((Integer)period));
        }
        else
        {
            t = t.addDays(-7);
        }
        
        if (t > emailSent)
        {
            return false;
        }
        
        if (passwordChange > emailSent)
        {
            return false;
        }
        return true;
    }
    
    public static String updateMPSUserEmail(String username, String email)
    {
        String msg = '';
        try 
        {                        
            GNE_CM_MPS_User__c existingMpsUser = getMPSUser(username);
            existingMpsUser.Email_address__c = email;
        
            update existingMpsUser;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error: ' + GlobalUtils.getExceptionDescription(e)));
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateMPSUserEmail', 'Apex Class', e);
            insert err;
            return 'Error: ' + GlobalUtils.getExceptionDescription(e);
            
        }
        return msg;    
    }
    
    @future
    public static void updateUserContactEmailsFuture(Map<String, String> mapId2Email)
    {
        try
        {       
            updateUserContactEmails(mapId2Email);
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateUserContactEmailsFuture', 'Apex Class', ex);
            insert err;
        }
    }
    
    public static Map<String, String> getUserId2EmailMap(List<GNE_CM_MPS_User__c> mpsUsers)
    {
        Map<String, String> mapUserIds = new Map<String, String>();    
        // get the user ids and emails
        for (GNE_CM_MPS_User__c u : mpsUsers) {
            if (u.SFDC_User__c!=null && u.Email_address__c!=null) {
                mapUserIds.put(u.SFDC_User__c, u.Email_address__c);
            }
        }
        return mapUserIds;
    }
    
    public static void updateUserContactEmails(Map<String, String> mapId2Email) {
        List<Contact> lstCnt=new List<Contact>();
        
        for (User u : [select Id, Contact.Id, Contact.Email from User where Id in :mapId2Email.keyset() AND ContactId <> null]) {           
                u.Contact.Email = mapId2Email.get(u.Id);
                            
                lstCnt.add(u.Contact);          
        }
        
        update lstCnt;      
    }    
    
    public static String getPortalServer() {        
        return GNE_LWO_CustomSettingsHelper.self().getLWOConfig().Site_Server_Name_HTTPS__c;       
    }
    
    @future
    public static void updateIHCPNameFuture(String newName, String email)
    {
        try
        {
            GNE_CM_IHCP_User__c ihcpUser = GNE_CM_IHCP_Utils.getIHCPUser(newName);            
            if(ihcpUser != null)
            {                
                ihcpUser.Name = newName;
                ihcpUser.Email_Address__c = email;
                update ihcpUser;
            }
        }
        catch(Exception ex)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateIHCPNameFuture', 'Apex Class', ex);
            insert err;
        }
    }
    
    @future
    public static void updateIHCPUserFuture(String email)
    {
        try
        {
            GNE_CM_IHCP_User__c ihcpUser = GNE_CM_IHCP_Utils.getCurrentIHCPUser();

            if(ihcpUser!=null)
            {
                ihcpUser.Email_Address__c = email;
                update ihcpUser;
            }
        }
        catch(Exception ex) 
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateIHCPUserFuture', 'Apex Class', ex);
            insert err;
        }
    }
        
    @future
    public static void updateMPSUserFuture(String fName, String lName, String email, String phone, String ext)
    {        
        try 
        {                        
            GNE_CM_MPS_User__c existingMpsUser = GNE_CM_IHCP_Utils.getMPSUserById(Userinfo.getUserId());
            existingMpsUser.First_Name__c = fName;
            existingMpsUser.Last_Name__c = lName;
            existingMpsUser.Email_address__c = email;
            existingMpsUser.Phone_number__c = phone;
            existingMpsUser.Phone_number_ext__c = ext;        
            update existingMpsUser;
            
            //Confirmation email
            GNE_CM_MPS_Email_Utils.sendSettingsConfirmationEmail(existingMpsUser, 'Profile');
        }
        catch (Exception e)
        {            
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_IHCP_Utils', 'High', 'updateMPSUserFuture', 'Apex Class', e);
            insert err;
        }        
    }
    
    public static GNE_CM_IHCP_User__c getIHCPUserbyMPS(String SFDC_User)
    {
        List<GNE_CM_IHCP_User__c> localIhcpUsers = [Select IsLocked__c, Login_Failed__c, Locked_Date_Time__c from GNE_CM_IHCP_User__c 
                                                     WHERE SFDC_User__c =:SFDC_User];
                                                             
        if(localIhcpUsers.isEmpty())
            return null; 
        return localIhcpUsers.get(0);   
    }
    
    public static string getWACAddress()
    {
        // default to production
        String retURL='https://b2b.gene.com/siteminderagent/forms/accesssolutions/login.fcc?TYPE=33554433&REALMOID=06-0001f069-570e-1f2c-ab9d-95e04822b0a4&GUID=&SMAUTHREASON=0&METHOD=GET&SMAGENTNAME=$SM$g96%2bb4aRfGFtntXZWwhnp%2bDQG%2br%2f3XB2cJwXY8urBIg1mX%2fRCn%2fhD00D3LVoIlU%2f&TARGET=$SM$http%3a%2f%2fmps%2egene%2ecom%2fmypatientsolutions';
        String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
        
        environmentName=environmentName.toLowerCase();
        
        if (environmentName=='sqa') {
            retURL='https://wacqa.gene.com/siteminderagent/forms/accesssolutions/login.fcc?TYPE=33554433&REALMOID=06-000347e5-fae3-1ec1-b23d-8b6b4822b0a4&GUID=&SMAUTHREASON=0&METHOD=GET&SMAGENTNAME=$SM$BN54k1e8k3h0hyiM6Dxak0avi8wnCEWwF3VLlmyrD%2f3cPun8Xedyz6IRvHt1HGBA&TARGET=$SM$http%3a%2f%2fmps-qa%2egene%2ecom%2fmypatientsolutions'; 
        } 
        
        return returl;
    }
}