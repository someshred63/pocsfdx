/***********************************************
    * Project Name          : Infrequent User Interaction Record
    * File                  : UserManager.cls
    * Version               : 1.0 
    * Description           : Handles the creation and activation of user accounts
    *                             
    *************************************************/
global without sharing class UserManager{
 
     static String ERROR_UNIX_ID_NOT_UNIQUE = 'Error: UnixId submitted is not unique in this instance of Salesforce.com. User cannot be activated.';     
     static String ERROR_UNIX_ID_NOT_FOUND = 'Error: UnixId submitted is not found in this instance of Salesforce.com. User cannot be activated.';
          
     static String ERROR_NO_ROLE = 'Error: Could not find Standard Role to assign to new user.';
     static String ERROR_NO_PROFILE = 'Error: Could not find Infrequent_User profile to assign to new user.';
     static String ERROR_CREATE_FAILED = 'Error: Create of new user account failed.';
     static String ERROR_ALL_USER_RETRIVAL_FAILED = 'Error: Create of new user account failed due to no user found in All User Hierarchy.';
         
     static String AT_GENE_COM = '@gene.com';
     static String STNDRD_USER = 'Standard User';
     public static String INFREQUENT_USER_PROF = 'GNE-INFREQUENT-USER';
     
     static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
     static String DEFAULT_LOCALE_KEY = 'en_US';
     static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
     static String DEFAULT_LANG_LOC_KEY = 'en_US';
     
     public static Boolean runTriggerFlag = true;
    // Below code commented for test    
    /** Query identifies users records ready to be deactivated */
    // static String QRY_FIND_USERS_TO_DEACTIVATE = 'select Id, Username, Name,  IsActive, LastLoginDate, Profile.name, External_ID_gne__c, Ready_for_deactivate_gne__c from User   where ((lastlogindate <= YESTERDAY or lastlogindate= null) and profile.name = :INFREQUENT_USER_PROF) or Ready_For_Deactivate_gne__c = true';
      
     /** Query identifies users records ready to be deactivated */
     static String QRY_FIND_USERS_TO_DEACTIVATE = 'select Id, Username, Name,  IsActive, LastLoginDate, Profile.name, External_ID_gne__c from User   where ((lastlogindate <= YESTERDAY or lastlogindate= null) and profile.name = :INFREQUENT_USER_PROF) AND IsActive = true';
 
     /**
      * setDefKeys
      *
      * Assign default values to keys which are required for User object. Generally location based keys defaulting to SSF Campus
      */
     private static void setDefKeys(User u){
       u.TimeZoneSidKey = DEFAULT_TIME_ZN;
       u.LocaleSidKey = DEFAULT_LOCALE_KEY;
       u.EmailEncodingKey = DEFAULT_EMAIL_KEY;
       u.LanguageLocaleKey = DEFAULT_LANG_LOC_KEY;
     }
 

 


     /**
      * activateSFUser
      * 
      * Activate a user instance. If instance does not exist create, otherwise update with name and unixId variables 
      * as the parameters indicate. If record does not exist create as infrequent user type.
      *
      * @return: Profile string of user indexed by unixId
      */
     WebService  static String activateSFUser(String UnixID, Boolean bActivate){
     
         List<User> users = [Select id, name, External_id_gne__c, isActive, profile.name from user where External_Id_gne__c = :UnixID]; 
         
         if (users.size() == 0){
             String strResult = CreateINFUUser(UnixID);
             System.debug(strResult);             
             return strResult;
                
         }else if (users.size() == 1){
             if (users[0].isActive != bActivate){
                 users[0].isActive = bActivate;
                 update users[0];
                // return users[0].Id; 
             System.debug('we came here 2nd time');    
             }
         }else if (users.size() > 1){
             System.debug(ERROR_UNIX_ID_NOT_UNIQUE);
             return ERROR_UNIX_ID_NOT_UNIQUE;
         }    
         
         String UserId = users[0].Id;
         return UserId; 

      }/* activateSFDCUser() */

    /**
     * Deactivate all users flagged as ready for deactivate
     */
    WebService static Integer deactivateUsersReadyForDeactivate(){
    
       List<User> users2Deactivate = Database.query(QRY_FIND_USERS_TO_DEACTIVATE);
       
       if (users2Deactivate.size()< 1)
         return 0;
        
       for (User u: users2Deactivate){
         System.debug('User to Deactivate: '+u);
         u.isActive = false;
      //   u.Ready_For_Deactivate_gne__c = false;         
       }
        
       update users2Deactivate;
      
       return users2Deactivate.size();
    }
    
     /**
     * Deactivate all users flagged as ready for deactivate
     */
    @future
    public static void disableUsersReadyForDeactivate(){
        
        runTriggerFlag = false;
        
        List<User> users2Deactivate = Database.query(QRY_FIND_USERS_TO_DEACTIVATE);
        
        for (User u: users2Deactivate){
            //System.debug('User to Deactivate: '+u);
            u.isActive = false;
          //  u.Ready_For_Deactivate_gne__c = false;
        }
        update users2Deactivate;
               
    }
    
        
    public List<User> getUsersForDeactivate(){
        List<User> users2Deactivate = Database.query(QRY_FIND_USERS_TO_DEACTIVATE);
        return users2Deactivate;
    }
    
    
    //Testing Purpose
    public static String CreateINFUUser(String UnixId){
        
        //boolean bActivate = true;

        List<All_User_Hierarchy_gne__c> allUsers = [Select id,email_id__c, FirstName_gne__c, LastName_gne__c, Active_gne__c  from All_User_Hierarchy_gne__c where User_External_Id_gne__c = :UnixID and Active_gne__c = true]; 

        try
         {
            if (allUsers.size() == 1){
                // This is a new userto be added
                User newUser = new User();
                setDefKeys(newUser);           
                newUser.firstName = allUsers[0].FirstName_gne__c;
                newUser.lastName = allUsers[0].LastName_gne__c;
                //newUser.External_Id_gne__c = 
                newUser.alias = UnixId;
                string [] user_Name_Temp = allUsers[0].email_id__c.split('@');
                newUser.username = UnixId +'@'+user_Name_Temp[1];
                newUser.email = allUsers[0].email_id__c; 
                //newUser.username = allUsers[0].email_id__c;
                //newUser.email = allUsers[0].email_id__c;           
                // Append Sandbox names to username if in sandbox.
                if (Utilities.getEnvironmentName() <> 'prod')
                {
                  newUser.username += '.'+ Utilities.getEnvironmentName();
                 //  newUser.email += '.'+ Utilities.getEnvironmentName();
                }
                newUser.CommunityNickname = UnixId;
                 
                List<UserRole> stdRoles = [Select Id, name from UserRole where name = :STNDRD_USER];
                 
                if (stdRoles.size() < 1){
                    return ERROR_NO_ROLE;
                }
                     
                newUser.UserRoleId = stdRoles[0].Id;
                     
                List<Profile> infreqProfs = [Select Id, name from Profile where name = :INFREQUENT_USER_PROF];
                     
                if (infreqProfs.size() < 1){
                    return ERROR_NO_PROFILE;
                }             
                newUser.USERPERMISSIONSMOBILEUSER = false;  
                newUser.ProfileId = infreqProfs[0].Id;
                insert newUser;
                return newUser.Id;                            
            }
            else
            {             
                return ERROR_ALL_USER_RETRIVAL_FAILED;
         } 
        }catch (Exception e){
           System.debug('Exception '+e);
           return ERROR_CREATE_FAILED;
        }
      }/* CreateINFUUser() */    
     /* Commented and added the 'UpdateURL' method to add redirection URL on user object on June 22 2010 
      @future   
      public static void InsertRedirectURL(String sUnixId, String sTargetURL, String UserId){
                User_Redirect_Info_gne__c userRedirectInfo = new User_Redirect_Info_gne__c(); 
                userRedirectInfo.Unix_Id_gne__c = sUnixId;
                userRedirectInfo.Redirect_URL_gne__c = sTargetURL;
                userRedirectInfo.Redirect_User_gne__c = UserId;
                insert userRedirectInfo;      
      }
      */
      //Added on June 22 2010 to updated the URL on USER Object 
      /***
      * Iserts the redirect URL on USER Object
      ***/
      
      public static void UpdateURL(String sUnixId, String sTargetURL){
        
          List<User> usersRedirectUrl = [Select id, name, External_id_gne__c, isActive,AGS_Redirect_Url__c from user where External_Id_gne__c = :sUnixId]; 
          usersRedirectUrl[0].AGS_Redirect_Url__c = sTargetURL;
          system.debug('This from UpdateURL in usermanager');
          update usersRedirectUrl;  
      }
      
    WebService  static String findSFUser(String UnixID){
      String UserId ;
         List<User> users = [Select id, name, External_id_gne__c, isActive, profile.name from user where External_Id_gne__c = :UnixID]; 
         
         if (users.size() == 0){
             String strResult = CreateINFUUserinactive(UnixID);
             System.debug(strResult);             
             return strResult;
                
         }else if (users.size() == 1){
             UserId = users[0].Id;
               
         }else if (users.size() > 1){
             System.debug(ERROR_UNIX_ID_NOT_UNIQUE);
             return ERROR_UNIX_ID_NOT_UNIQUE;
         }    
         
        return UserId;   

      }
      
     public static String CreateINFUUserinactive(String UnixId){
        
        //boolean bActivate = true;
        List<All_User_Hierarchy_gne__c> allUsers = [Select id,email_id__c, FirstName_gne__c, LastName_gne__c, Active_gne__c  from All_User_Hierarchy_gne__c where User_External_Id_gne__c = :UnixID and Active_gne__c = true]; 
        try{
            if (allUsers.size() == 1){
                // This is a new userto be added
                User newUser = new User();
                setDefKeys(newUser);           
                newUser.firstName = allUsers[0].FirstName_gne__c;
                newUser.lastName = allUsers[0].LastName_gne__c;
                newUser.IsActive=false;
                //newUser.External_Id_gne__c = 
                newUser.alias = UnixId;
                string [] user_Name_Temp = allUsers[0].email_id__c.split('@');
                newUser.username = UnixId +'@'+user_Name_Temp[1];
                newUser.email = allUsers[0].email_id__c; 
                //newUser.username = allUsers[0].email_id__c;
                //newUser.email = allUsers[0].email_id__c;           
                // Append Sandbox names to username if in sandbox.
                if (Utilities.getEnvironmentName() <> 'prod')
                {
                  newUser.username += '.'+ Utilities.getEnvironmentName();
                 //  newUser.email += '.'+ Utilities.getEnvironmentName();
                }
                newUser.CommunityNickname = UnixId;
                 
                List<UserRole> stdRoles = [Select Id, name from UserRole where name = :STNDRD_USER];
                 
                if (stdRoles.size() < 1){
                    return ERROR_NO_ROLE;
                }
                     
                newUser.UserRoleId = stdRoles[0].Id;
                     
                List<Profile> infreqProfs = [Select Id, name from Profile where name = :INFREQUENT_USER_PROF];
                     
                if (infreqProfs.size() < 1){
                    return ERROR_NO_PROFILE;
                }             
                newUser.USERPERMISSIONSMOBILEUSER = false;  
                newUser.ProfileId = infreqProfs[0].Id;
                system.debug('---newUser'+newUser);
                insert newUser;
                return newUser.Id;                            
            }else{             
                return ERROR_ALL_USER_RETRIVAL_FAILED;
         } 
        }catch (Exception e){
           System.debug('Exception '+e);
           return ERROR_CREATE_FAILED +'\n'+e ;
        }
      }      
}/* class UserManager*/