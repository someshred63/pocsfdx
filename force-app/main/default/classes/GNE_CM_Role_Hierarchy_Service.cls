// Last updated by hsingh.
/**06/04/2010 updated by swati dhingra as per offshore request 445 to replace user role staging table with user hierarchy table**/
/** updated 03/06/2009 - jw - set user query for user list profile update to include only active AND profile.name like 'gne-cm%'
  for (User[] userlist : [select id, name, LastName, Username, External_ID_gne__c, Vendor_Name_gne__c, Profile.name
                            from user 
                            where ((Profile.name like 'GNE-CM%') AND (IsActive= true) AND (Profile.name != GNE-CM-Physician Profile)
                                    ((Username in:querylist) or (External_ID_gne__c in:querylist)))])
**/    


global class GNE_CM_Role_Hierarchy_Service {


 global class resultInfo
    {
        WebService string code;
        WebService string message; 
    }

    WebService static resultInfo startProcess()
    {
        resultInfo info = new resultInfo();
      
        try 
        {         
            GNE_CM_LoginHistory.snapshot();         
            processUsers();
            updateUsers();
            info.code = 'true'; 
            info.message = 'SUCCESS';         
            return info; 
        }
        catch (Exception e)
        {
            info.code = 'false';
            info.message =  e.getMessage();
        }
        return info;  
    }
 @future  
webservice static void processUsers()
    {

    string result = '';

    boolean duplicate_status = false;
    boolean unix_found = false;
    Boolean Role_Assigned = false;
    Map<String, String> proccbucket = new Map<String, String>();

    Database.saveresult[] SR_RH;
    Database.deleteresult[] DR_Role_delete;

    Savepoint sp;
    System.Debug('In ProcessUsers');

    List<UserRole> Role_Insert = new List<UserRole>();
    List<User_Hierarchy_gne__c> userstage = new List<User_Hierarchy_gne__c>();
    List<String> distemplunixid = new List<String>();
    string Role_Name;
    integer vCount = 1;
    List<UserRole> Par_Role_Update = new List<UserRole>();
    List<UserRole> user_role_delete = new List<UserRole>();
    List<UserRole> undeleted_roles = new List<UserRole>();
    Map<string, UserRole> map_undelete_role = new Map<string, UserRole>();

    Set<String> querylist = new Set<String>();
    Set<String> roleset = new Set<String>();
    Set<String> Parentroleset = new Set<String>();

    Map<Integer, Map<String, User>> User_Map_Superset = new Map<Integer, Map<String, User>>(); 
    Map<String,User> invalid_munix_Map = new Map<String, User>();
    Map<string, string> level1_users = new Map<string, string>();

    //****************************************************************************************//
    // Declare a savepoint before strting operation.
        sp = Database.setSavepoint();
    //****************************************************************************************//
    System.Debug('*** GNE_TEST: SAVEPOINT SET');
    //****************************************************************************************//
    // Create list for the query against User table.
    //****************************************************************************************//
 List < User_Hierarchy_gne__c > masterstage = ([SELECT User_External_ID_gne__c, Level1_UserId_gne__c,Level1_UserId_gne__r.External_ID_gne__c 
                                    FROM User_Hierarchy_gne__c
                                     WHERE ((User_Profile_Name_gne__c like 'GNE-CM%')AND ( not User_Profile_Name_gne__c like 'GNE-CM-Physician Profile%')   AND (User_External_ID_gne__c <> null))
                                     ORDER BY CreatedDate ASC]);


                            
     system.debug('STAGING TABLE LIST: ' + masterstage +masterstage.size()); 
    
     for (integer i = 0; i < masterstage.size(); i++) 
        {
           if (!querylist.contains(masterstage[i].User_External_ID_gne__c))
            {
                querylist.add(masterstage[i].User_External_ID_gne__c);
                system.debug(masterstage[i].User_External_ID_gne__c);
            }

         if (!querylist.contains(masterstage[i].Level1_UserId_gne__r.External_ID_gne__c ))

            {
                querylist.add(masterstage[i].Level1_UserId_gne__r.External_ID_gne__c);
               system.debug(masterstage[i].Level1_UserId_gne__r.External_ID_gne__c);
            }        
        }
                    

    //****************************************************************************************//
    // Creating master map for the user table .
    //****************************************************************************************//

    result = 'Creating master map for the user table';  
    System.Debug(result);
    for (User[] userlist : [select id, name, LastName, Username, External_ID_gne__c, Vendor_Name_gne__c, Profile.name
                            from user 
                            where ((Profile.name like 'GNE-CM%') AND (not Profile.name like 'GNE-CM-Physician Profile%') AND (IsActive= true) AND ((Username in:querylist) or (External_ID_gne__c in:querylist)))])
    

    {
        
        System.Debug('*** JW_GNE_TEST: Rows Returned USERLIST: ' + userlist.size());
        Map<String,User> User_Map = new Map<String, User>();
        system.debug('*******^ USER COUNT FOR UTILIZATION ^*********' + userList.size());
        for(integer z = 0;z < userlist.size(); z++)
        {
            if(userlist[z].External_ID_gne__c == null)
                {
                    User_Map.put(userlist[z].Username, userlist[z]);
                    system.debug ('Added to user map ' + userlist[z].Username);
                }
            else
                {
                    User_Map.put(userlist[z].External_ID_gne__c,userlist[z]);  
                    system.debug ('Added to user map ' + userlist[z].External_ID_gne__c);
                } 
        }

        User_Map_Superset.put(vCount, User_Map);
        vCount = vCount + 1;

    }
    
    //****************************************************************************************//

    //****************************************************************************************//

    // Creating local list for input data and removing the unwanted values.

    // Put managers not in the User table in the user map so that 

    // roles against them could be created.

    //****************************************************************************************//

    result = 'Creating local list'; 
    System.Debug(result);

     for (integer i = 0; i < masterstage.size(); i++) 

        { 

         if (masterstage[i].Level1_UserId_gne__r.External_ID_gne__c != null && masterstage[i].User_External_ID_gne__c != null)

             userstage.add(masterstage[i]);

          if (masterstage[i].User_External_ID_gne__c != null)

           distemplunixid.add(masterstage[i].User_External_ID_gne__c);
           system.debug('**userstage'+userstage);             

          if (masterstage[i].Level1_UserId_gne__r.External_ID_gne__c != null) 


          {

             for (integer g = 1; g < User_Map_Superset.size() + 1; g++) 

                {
                    unix_found = false;

                    Map<String,User> User_Map = new Map<String, User>(); 

                    User_Map = User_Map_Superset.get(g);

                    if (User_Map.containsKey(masterstage[i].Level1_UserId_gne__r.External_ID_gne__c))

                       {  

                            unix_found = true;
                            system.debug('unix _found: ' +unix_found); 

                            break;

                       }

                }

         if (unix_found == false && !invalid_munix_Map.containsKey(masterstage[i].Level1_UserId_gne__r.External_ID_gne__c))

                {

                    User tmpuser = new user ();

                    tmpuser.LastName = 'NOT IN SFDC';
                   
                  tmpuser.External_ID_gne__c = masterstage[i].User_External_ID_gne__c;

                   invalid_munix_Map.put(masterstage[i].Level1_UserId_gne__r.External_ID_gne__c , tmpuser);
    


                }

          }

        } 
  

      

     //****************************************************************************************//

     // Checking validity of the Seed Unix Id

     //****************************************************************************************//

     String Seed_Role;
     String Other_Role;
     String Other_RoleId;
     String Seed_RoleId;
     String inactive_role;
     String inactive_roleId;
     List<UserRole> tmpuserRole= new List<UserRole>();
     //Get the EV for Base Role i.e. Case Management and Other Role
     List<Environment_Variables__c> Env_base_var = new List<Environment_Variables__c>([select Value__c, key__c from Environment_Variables__c 
                                                                                       WHERE Key__c IN ('GNE-CM-BASE-ROLE-NAME', 'GNE-CM-OTHER-ROLE-NAME', 'GNE-CM-INACTIVE-USER-ROLE-NAME')]);
    

     System.Debug('*** JW_GNE_TEST: Rows Returned ENV_VAR: ' + Env_base_var.size());


    result = 'Checking validity of the Role Name'; 
    System.Debug(result);

     if (Env_base_var.size() > 0)
       { 
        Set<string> EV_Vals = new Set<string>();
        
        for(integer i=0; i<Env_base_var.size(); i++)
        {
            if(Env_base_var[i].Key__c == 'GNE-CM-BASE-ROLE-NAME')
            Seed_Role = Env_base_var[i].Value__c;
            
            if(Env_base_var[i].Key__c == 'GNE-CM-OTHER-ROLE-NAME')
            Other_Role = Env_base_var[i].Value__c;
            
            if(Env_base_var[i].Key__c == 'GNE-CM-INACTIVE-USER-ROLE-NAME')
            inactive_role = Env_base_var[i].Value__c;
            
            EV_Vals.add(Env_base_var[i].value__c);              
        }
                        
        //Get the Role Ids for Case Management and Other's Staff roles
        tmpuserRole = [Select Id, Name from UserRole where name IN :EV_Vals];
        
        for(integer tmp=0; tmp<tmpuserRole.size(); tmp++)
        {
            if(tmpuserRole[tmp].Name == Other_Role)
            Other_RoleID = tmpuserRole[tmp].Id;
            
            if(tmpuserRole[tmp].Name == Seed_Role)
            Seed_RoleID = tmpuserRole[tmp].Id;
            
            if(tmpuserRole[tmp].Name == inactive_role)
            inactive_roleId = tmpuserRole[tmp].Id;
        }

        System.Debug('*** JW_GNE_TEST: Rows Returned tmpuserRole: ' + tmpuserRole.size());            

        if (tmpuserRole.size() < 3)
         {
            result = 'Invalid Base Role / Other Role / Inactive User Role - Does not exist in the UserRole Table.';
        
            System.Debug(result);

            Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='Environment_Variables__c ', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());

            Database.rollback(sp);
            return;
            }                    
       } 
     else
       {
        result = 'Case Management Role Environment Variable GNE-CM-BASE-ROLE-NAME/GNE-CM-OTHER-ROLE-NAME/GNE-CM-INACTIVE-USER-ROLE-NAME not found';
    
        System.Debug(result);

        Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='Environment_Variables__c ', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());

        Database.rollback(sp);
        return;
     
       }

    

    //****************************************************************************************//

    // Loop through the hierarchy table data and create Roles for all

    // users in the Lvel1 user's column in the hierarchy table

    //****************************************************************************************//

    //****************************************************************************************//

    // CREATING NEW ROLES BASED ON Level1 user's UNIX IDs

    //****************************************************************************************//

    

    result = 'Creating new roles based on Manager Unix IDs'; 

    System.Debug(result);


    UserRole[] rolelist = [Select Id, name from UserRole];

    

    System.Debug('*** JW_GNE_TEST: Rows Returned ROLELIST: ' + rolelist.size());

    

    for (integer r=0; r < rolelist.size();r++)

    {

        if (!roleset.contains(rolelist[r].name)) 

            {

                roleset.add(rolelist[r].name);

               


            }

    }

    

    for(integer i = 0;i < userstage.size();i++)

    {
        for (integer g = 1; g < User_Map_Superset.size() + 1; g++)

        {

            Map<String,User> User_Map = new Map<String, User>();

            User_Map = User_Map_Superset.get(g);

         if (User_Map.containsKey(userstage[i].Level1_UserId_gne__r.External_ID_gne__c))

            { 
            if (User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).LastName.Equals('NOT IN SFDC'))
                {
                
                    String strVal;
                    
                    if (User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).External_ID_gne__c.length() > 31)
                        strVal = User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).External_ID_gne__c.substring(0,31); 
                    else 
                        strVal = User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).External_ID_gne__c;         
                    Role_Name = strVal + '\'s Staff';                    

                }

                else

                {
                    String strVal;
                    
                    if (User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).name.length() > 31)
                        strVal = User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).name.substring(0,31); 
                    else 
                        strVal = User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).name;       
                    Role_Name = strVal + '\'s Staff';                    

                }
                
                 //add external ids of users who are at the highest level in the hierarchy
                 if(!level1_users.containskey(Role_Name))
                 {
                    level1_users.put(Role_Name, Role_Name);
                 } 
                
                if (roleset.contains(Role_Name))

                {

                    duplicate_status = true;

                }


              if ((duplicate_status == false) && !proccbucket.ContainsKey(userstage[i].Level1_UserId_gne__r.External_ID_gne__c))
                {    

                     UserRole temprole = new UserRole();

                     temprole.Name = Role_Name;                 

                 proccbucket.put(userstage[i].Level1_UserId_gne__r.External_ID_gne__c,'MANAGER');

                     Role_Insert.add (temprole);

                     temprole = null;

                 }

                duplicate_status = false;

                break;

            }

        }

    }       


    //****************************************************************************************//

    // Commiting NEW ROLES BASED ON Level1 user's UNIX IDs to database.

    //****************************************************************************************//   

    result = 'Commiting new roles to database';    

    SR_RH = Database.insert (Role_Insert, false);  
       

    for(Database.Saveresult srLIST : SR_RH)

    {

        if(!srLIST.isSuccess())

        {

            for(Database.Error err : srLIST.getErrors())

            {
                Database.rollback(sp);
                result = 'Fail to Insert New Role'+ err.getMessage();
                system.debug(result);
                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());

                //insert error;
               
                return;

            }

        

     //   return 'FAILURE: ' + result;

        }
    //    
    } // for loop

   

     result = 'Updating Parent Role Ids to NULL'; 

     //****************************************************************************************//

     // Deleteing the Parent Role Ids for all Roles that are populated

     // through this interface. this effectively destrys the hierarchy

     // and leaves a flat role structure

     //****************************************************************************************//



     List<UserRole> UserRoletable_Update = new list<UserRole>([select Id, Name, ParentRoleId from UserRole where Name != :Seed_Role]);
    
     List<UserRole> UserRoletable_Del = new List<UserRole>(); 

    

     for(Integer i=0; i<UserRoletable_Update.size(); i++)

        {

          if (UserRoletable_Update[i].name.length() > 8)

          {
           
           if(UserRoletable_Update[i].name.substring((UserRoletable_Update[i].name.length()-8)).Equals('\'s Staff'))

               {

                    UserRoletable_Update[i].ParentRoleId = null;

                    UserRoletable_Del.add(UserRoletable_Update[i]);

               }

          }

        }    

   
     //****************************************************************************************//

     // Updating Parent Role Ids to NULL

     //****************************************************************************************//


    system.debug('*****  UPDATING PARENT ROLES ');
    SR_RH = Database.update (UserRoletable_Del, false);

        

    for(Database.Saveresult srLIST : SR_RH)

     {

        if(!srLIST.isSuccess())

          {

            for(Database.Error err : srLIST.getErrors())

              {
                                        
                result = 'Failed to Delete Parent Role Ids'+ err.getMessage();

                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());

                System.Debug(result);

              }   
                Database.rollback(sp);
                return;
          }

     }



     result = 'Creating Role Hierarchy for employees by setting parent'; 
        system.debug(result);
    //****************************************************************************************//

    // Loop through the hierarchy table data and converts level1 user's external id

    // to the corresponding role id for the role created for the manager

    // and converts the Emplyee Unix Id to Role Name

    //****************************************************************************************//

    String Parent_Role_Name;
    String User_Role_Name;

    ID Userroleid ;
    ID parentroleid ;
    ID  User_Id;
    ID Vendor_id;

    User tempuserupdate;

    List<UserRole> UserRoletable_Upd = new List<UserRole>();
    List<User> User_Update_role_vendor = new List<User>();
     Set<ID> Roleid_set = new Set<ID>();
    Map<String, String> emprole_mrole_rel_map = new Map<String, String>();
    Map<String, UserRole> User_Role_Table = new Map<String, UserRole>();
    Map<ID,String> username_map = new Map<ID,String>();
    Map<ID,String> UserVendor_map = new Map<ID,String>();
    Map<ID,ID> UserVendorId_map = new Map<ID,ID>();
    
    // *************************************************************//

    // Create MAP for the GROUPS and obtain Ids for Profiles

    // *************************************************************//
         

    

    for (UserRole[] tempUserRoletable : [select Id, Name, ParentRoleId from UserRole])

    {

        System.Debug('*** JW_GNE_TEST: Rows Returned TEMPUSERROLETABLE: ' + tempuserroletable.size());

        for (integer k=0; k < tempUserRoletable.size(); k++)

        {

            User_Role_Table.put(tempUserRoletable[k].Name, tempUserRoletable[k]);

            UserRoletable_Upd.add(tempUserRoletable[k]);

        }

    }


    for(integer i = 0;i < userstage.size();i++)

      { 

        parentroleid = null;
        User_Role_Name = null;
        User_Id = null;
        Parent_Role_Name = null;
        duplicate_status = false;
        Role_Assigned = false;

        for (integer g = 1; g < User_Map_Superset.size() + 1; g++)

        {

            Map<String,User> User_Map = new Map<String, User>();

            User_Map = User_Map_Superset.get(g);

            system.debug ('Is this manager in user list ' + User_Map.containsKey(userstage[i].Level1_UserId_gne__r.External_ID_gne__c));
            if (User_Map.containsKey(userstage[i].Level1_UserId_gne__r.External_ID_gne__c))
             {     
                    if (User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).LastName.Equals('NOT IN SFDC'))
                    {
                        Parent_Role_Name = User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).External_ID_gne__c + '\'s Staff';                   
                    }
                    else
                    {
                        Parent_Role_Name = User_Map.get(userstage[i].Level1_UserId_gne__r.External_ID_gne__c).name + '\'s Staff';
                    }              
                
                    if (User_Role_Table.containsKey(Parent_Role_Name))
                    {
                        parentroleid = User_Role_Table.get(Parent_Role_Name).Id;                                               
                    }   
               }
                
               if (User_Map.containsKey(userstage[i].User_External_Id_gne__c))
                 {   
                  if (User_Map.get(userstage[i].User_External_Id_gne__c).LastName.Equals('NOT IN SFDC'))
                {
                User_Role_Name = User_Map.get(userstage[i].User_External_Id_gne__c).External_ID_gne__c + '\'s Staff';
                }
                else
                {
                User_Role_Name = User_Map.get(userstage[i].User_External_Id_gne__c).name + '\'s Staff';
                } 
                
                User_Id = User_Map.get(userstage[i].User_External_Id_gne__c).Id;
                                    
               // UserVendor_map.put(User_Id, userstage[i].Vendor_Name_gne__c);           

            }

            system.debug ('THIS USER MANAGER UNDER PROCESS ' + userstage[i].Level1_UserId_gne__r.External_ID_gne__c);
            system.debug ('THIS USER USER UNDER PROCESS ' + userstage[i].User_External_Id_gne__c);
            system.debug ('parentroleid ' + parentroleid);
            system.debug ('User_Role_Name ' + User_Role_Name);
            system.debug ('Parent_Role_Name' + Parent_Role_Name);
            
            if(parentroleid != null && User_Role_Name != null && Role_Assigned == false)

            {

                emprole_mrole_rel_map.put(User_Role_Name, parentroleid);

                Role_Assigned  = true;

            }         

            if(User_Id != null && parentroleid != null && duplicate_status == false)

             {

                username_map.put(User_Id, parentroleid);

                duplicate_status = true;

             }  

             // If all conditions are met; break the loop.

            if (Role_Assigned  == true && duplicate_status == true)

             break;

        } 

      }   

    

    //****************************************************************************************//

    // Create list for updating parent Id on Role table.

    //****************************************************************************************//

    for (integer l = 0; l < UserRoletable_Upd.size(); l++)

    { 

     if (emprole_mrole_rel_map.containskey(UserRoletable_Upd[l].name))

      {

         UserRoletable_Upd[l].ParentRoleId = emprole_mrole_rel_map.get(UserRoletable_Upd[l].name);

         Par_Role_Update.add(UserRoletable_Upd[l]);

      }            

    }

    //****************************************************************************************//

    // Commiting Role Hierarchy for employees to database. Perform DB operations on the

    // list created in previous section.

    //****************************************************************************************//

    result = '******** Commiting Role Hierarchy for employees to database'; 

    system.debug(result);

    SR_RH = Database.update (Par_Role_Update, false);

    for(Database.Saveresult srLIST : SR_RH)

     {

        if(!srLIST.isSuccess())

          {

            for(Database.Error err : srLIST.getErrors())

              {

                result = 'Fail to Update Parent Role Id for New Role'+ err.getMessage();

                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());

                
                System.Debug('Parent Role Update: ' + result);

              }
            Database.rollback(sp);
            return;

          }

     }



    result = '******** Setting role hierarchy by assigning roles to users';     

    System.Debug(result);
   //****************************************************************************************// 

   // Create list to update Role Id and Vendor Name information on the User table.

   //****************************************************************************************//

    for (User[] userlist : [select id, name, Username, External_ID_gne__c, Vendor_Name_gne__c, ProfileId from user 

                            where ((Profile.name like 'GNE-CM%')AND ( not Profile.name like 'GNE-CM-Physician Profile%')  AND (IsActive = true) AND ((Username in:querylist) or (External_ID_gne__c in:querylist)))])
    {
        User_Update_role_vendor.clear();

        for(integer k = 0;k < userlist.size(); k++)
        {
            if (username_map.containskey(userlist[k].Id))
            {
                userlist[k].UserRoleId = username_map.get(userlist[k].Id);

                if (UserVendor_map.containskey(userlist[k].Id))
                {
                    userlist[k].Vendor_Name_gne__c = UserVendor_map.get(userlist[k].Id);
                }

                User_Update_role_vendor.add(userlist[k]);   
            }
            else
            {//assign users to Other's Staff role if they do not have any parent role available in hierarchy
                if(Other_RoleId != null && Other_RoleId != '')
                {
                            userlist[k].UserRoleId = Other_RoleId;
                            User_Update_role_vendor.add(userlist[k]);
                    }
                    else
                    {
                        result = 'Role for Others Staff could not be found.';    
                        System.Debug(result);
                    }                   
             }//Added the other role logic above
        }

       SR_RH = Database.update (User_Update_role_vendor, false); 

       for(Database.Saveresult srLIST : SR_RH)

          {

            if(!srLIST.isSuccess())

              {

                for(Database.Error err : srLIST.getErrors())

                 {
                    result = 'Fail to Update Role Id for User '+ err.getMessage();

                    Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());

                    //insert error;
                    System.Debug('Error User_Update_role_Vendor: ' + result);

                 }

                System.Debug('*****ROLLBACK********');

                Database.rollback(sp);
                return;

              }

          }

    }
/**************************************************************
     Delete roles whose Parent role id is null
 ***************************************************************/
 
 /*****Create set from list of  roles whose parent role id are updated**/
    for (integer j =0;j<Par_Role_Update.size(); j++)
    {
        Parentroleset.add(Par_Role_Update[j].Id);
        
    }
    
     /*****Create a list of roles whose parent role id  is null **/
    for( integer k = 0; k< UserRoletable_Del.size(); k++)
    {
          if( !Parentroleset.contains(UserRoletable_Del[k].Id))
          user_role_delete.add(UserRoletable_Del[k]);
    }
 
 
    DR_Role_delete = Database.delete(user_role_delete, false);
    Map<Id, Id> RoleIds_undeleted = new Map<Id, Id>();
    for(Database.deleteresult srLIST : DR_Role_delete)
     {
        if(!srLIST.isSuccess())
          {
            RoleIds_undeleted.put(srLIST.getId(), srLIST.getId());
            for(Database.Error err : srLIST.getErrors())
              {
                result = 'Fail to delete user role with parent id as null'+ err.getMessage();
                
                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());
                
                System.Debug('Parent Role delete: ' + result);
              }           
            System.Debug(result);
          }
     }
     
     //Added logic to assign any orphan roles to Case Management which couldn't be deleted in above step 
     //Get a list of all User Roles that haven't been deleted
     for(integer m=0; m<UserRoletable_Upd.size(); m++)
     {
        if(RoleIds_undeleted.containsKey(UserRoletable_Upd[m].Id))
        {
          undeleted_roles.add(UserRoletable_Upd[m]);
        }
     }
     
     //Set the ParentRole Id of undeleted roles to Inactive User Role
     for(integer undel=0; undel<undeleted_roles.size(); undel++)
     {
        if(level1_users.containsKey(undeleted_roles[undel].Name))
        undeleted_roles[undel].ParentRoleId = seed_roleID;  
        else
        {
        undeleted_roles[undel].ParentRoleId = inactive_roleId; 
        Roleid_set.add(undeleted_roles[undel].Id);
        }
        map_undelete_role.put(undeleted_roles[undel].Name.substring(0, undeleted_roles[undel].Name.length() - 8), undeleted_roles[undel]);      
     }
    
     SR_RH = Database.update (undeleted_roles, false);

    for(Database.Saveresult srLIST : SR_RH)
     {
        if(!srLIST.isSuccess())
          {
            for(Database.Error err : srLIST.getErrors())
              {
                result = 'Fail to Update Parent Role Id for Orphan Roles'+ err.getMessage();
                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());
                
                System.Debug('Parent Role Update to Inactive User Role: ' + result);

              }
            Database.rollback(sp);
            return;

          }
     }
     List<User> Update_User = new List<User>(); 
         string temprole_name;
     //Update Role Ids of User's to assign them to Inactive User Role
     for(User[] usr_upd: [Select Id, UserRoleId, Name, isActive from User where ((Name IN :map_undelete_role.keyset()) OR (UserRoleId IN :Roleid_set)) AND( (Profile.name like 'GNE-CM%') AND ( not Profile.name like 'GNE-CM-Physician Profile%')) ])
     {
        Update_User.clear();
        
        for(integer h=0; h<usr_upd.size(); h++)
        {
            temprole_name = usr_upd[h].Name + '\'s Staff';
            if(!level1_users.containsKey(temprole_name) && usr_upd[h].isActive == false)
            usr_upd[h].UserRoleId = inactive_roleId;          
            else if(!level1_users.containsKey(temprole_name) &&  usr_upd[h].isActive == true)
            usr_upd[h].UserRoleId = Other_RoleID;
            else if(usr_upd[h].isActive == true)
            usr_upd[h].UserRoleId = seed_roleId;
            Update_User.add(usr_upd[h]);
        }
       
    SR_RH = Database.update (Update_User, false);

    for(Database.Saveresult srLIST : SR_RH)
     {
        if(!srLIST.isSuccess())
          {
            for(Database.Error err : srLIST.getErrors())
              {
                result = 'Fail to Update User Role Id for Orphan Users'+ err.getMessage();
                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());
                
                System.Debug('Role Update to Inactive User Role: ' + result);

              }
            Database.rollback(sp);
            return;

          }
       }
     }
    
    //****************************************************************************************//

    //*********Call future method to assign any GNE-CM inactive users to Inactive User Role*********//
    
    rolelist.clear();

    proccbucket.clear();

    UserRoletable_Upd.clear();  
 
  }    //end method
 webservice static void updateUsers()
 {
    string result = '';
    String   inactive_role ;
    List<User> InactiveUser_list = new List<User>();
    UserRole usr = new UserRole();
    Id inactiveroleid;
    Database.saveresult[] SR_RH;
    List<Environment_Variables__c> Env_base_var = new List<Environment_Variables__c>([select Value__c, key__c from Environment_Variables__c 
                                                                                       WHERE Key__c IN ('GNE-CM-INACTIVE-USER-ROLE-NAME')]);
     inactive_role = Env_base_var[0].Value__c;
     usr = [Select id , Name from UserRole where Name =:inactive_role limit 1];
      inactiveroleid = usr.id;
          
    for(User[] InactiveUser: [Select Id, UserRoleId, Name, isActive from User where ((isActive = False) AND  (UserRoleId != :inactiveroleid) AND (Profile.name like 'GNE-CM%') AND (not Profile.name like 'GNE-CM-Physician Profile%')) ])
    {
        InactiveUser_list.clear();
        
         for(integer h=0; h<InactiveUser.size(); h++)
        {
            
            InactiveUser[h].UserRoleId = inactiveroleid; 
            InactiveUser_list.add(InactiveUser[h]);
        }        
        
      SR_RH = Database.update (InactiveUser_list, false);

    for(Database.Saveresult srLIST : SR_RH)
     {
        if(!srLIST.isSuccess())
          {
            for(Database.Error err : srLIST.getErrors())
              {
                result = 'Fail to Update User Role Id for Inactive Users'+ err.getMessage();
                Error_Log_gne__c error=new Error_Log_gne__c(Object_Name__c='User_Hierarchy_gne__c', Error_Level_gne__c='High',Snippet_Name__c='GNE_CM_Role_Hierarchy', Code_Type__c='Apex Class', Error_Description__c=result, User_Name__c=UserInfo.getUserName());
                
                System.Debug('Role Update to Inactive User Role: ' + result);           

              }                     
          }
       }
    }
    
 }
  

    @IsTest public static void testMe()
    {
        Test.startTest();
        GNE_CM_Role_Hierarchy_Service.startProcess(); // processUsers();
        
        
        List<UserRole> usrRoleList = [SELECT ID, Name, ParentRoleId from userRole ORDER BY NAME];
        for (UserRole ur : usrRoleList)
        {
            System.Debug('ID: ' + ur.ID + ' Name: ' + ur.Name + ' ParentRoleId: ' + ur.ParentRoleId); 
        } 
        
        
        System.Debug('****ENDED****');
        Test.StopTest();    // is test body
    }  

}  //end class