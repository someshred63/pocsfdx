global class SCM_UserSecurityAssignment {


    /********************************************************************/
    // Function Name    : getSecurityDirtyGroup
    // Return Type      : SpringCMUserAssignment
    // Description      : This function compiles and returns a list of 
    //                    new Users and updated roles for existing users. 
    //                    The row ids from this list needs to be used in
    //                    the clearSecurityDirtyItems() for clearing the
    //                    Security Dirty condition.
    /********************************************************************/
    
    webService static List<SCM_UserProfileAssignment> getSecurityDirtyGroup()
    { 
        // Obtain list of all Users with Security Dirty condition max 50 records
        List<User> dirtyFlaggedUsersList = [select Id, Security_Dirty__c,
                                               SpringCM2SF__SpringCM_User__c,
                                               ProfileId
                                            from user
                                            where Security_Dirty__c=true Limit 50];

        if (dirtyFlaggedUsersList.size() == 0)
            return null;
       
        //Clear Existing Enteries
        List<String> userIdList= new List<String>();
        for (Integer i = 0; i<dirtyFlaggedUsersList.size(); i++)
            userIdList.add(dirtyFlaggedUsersList[i].Id);
            
        List<SCM_Profile_Assignment__c> deletionList = [select a.id 
                                                     from SCM_Profile_Assignment__c a
                                                     where a.SFDC_User_Id__c in :userIdList]; 
        Database.delete(deletionList);  
        

        // Obtain list of Profile Assignments  
        List<SCM_Profile_Assignment__c>   profileAssignmentList = new List<SCM_Profile_Assignment__c>();
        List<SCM_UserProfileAssignment> returnRoleList = new List<SCM_UserProfileAssignment>(); 
        
        List<String> userProfileIdList = new List<String>();
        for (Integer i = 0; i<dirtyFlaggedUsersList.size(); i++)
            userProfileIdList.add(dirtyFlaggedUsersList[i].ProfileId);
        
        List<SCM_Security_Map__c> mapList = [select  SFDC_Profile_Id__c, SFDC_Profile_Name__c,
                                                     SCM_Group_Id__c, SCM_Group_Name__c
                                             from SCM_Security_Map__c 
                                             where SFDC_Profile_Id__c in :userProfileIdList];
        
        
        // For all Users with Security Dirty condition, create records in SCM_Profile_Assignment_c     
        for(User user : dirtyFlaggedUsersList) 
        {
            SCM_Profile_Assignment__c profileAssignment = new SCM_Profile_Assignment__c();
            profileAssignment.Status__c         = 'Initialized';
            profileAssignment.SFDC_User_Id__c   = user.Id; 
            profileAssignmentList.add(profileAssignment);
        }
 
        List<SCM_Profile_Assignment_Detail__c> detailList = new List<SCM_Profile_Assignment_Detail__c>();
        Database.SaveResult[] insertResults =  Database.Insert(profileAssignmentList);
        Integer index = 0;
        for(Database.SaveResult insertResult:insertResults)
        {
            User user = dirtyFlaggedUsersList[index];
            if(insertResult.isSuccess()) 
            {
               List<SCM_Security_Map__c> currentMapList = new List<SCM_Security_Map__c>();
               for(SCM_Security_Map__c securityMap: mapList)
               {
                    if(securityMap.SFDC_Profile_Id__c == user.ProfileId)
                        currentMapList.add(securityMap);
               }
               String[] groupId = new String[currentMapList.size()];
               Integer groupIdIndex = 0;
               for (SCM_Security_Map__c securityMap: currentMapList )
               {
                    SCM_Profile_Assignment_Detail__c profileAssignmentDetail = new SCM_Profile_Assignment_Detail__c();
                    profileAssignmentDetail.SFDC_Profile_Id__c   = securityMap.SFDC_Profile_Id__c;
                    profileAssignmentDetail.SFDC_Profile_Name__c = securityMap.SFDC_Profile_Name__c;
                    profileAssignmentDetail.SCM_Group_Id__c   = securityMap.SCM_Group_Id__c;
                    profileAssignmentDetail.SCM_Group_Name__c = securityMap.SCM_Group_Name__c;
                    profileAssignmentDetail.SCM_Profile_Assignment__c = insertResult.getId();
                    detailList.add(profileAssignmentDetail);
                    groupId[groupIdIndex]=securityMap.SCM_Group_Id__c;
                    groupIdIndex++;
               }
               
               String rowId = insertResult.getId();
               String userId = user.Id;
               SCM_UserProfileAssignment assignment = 
                          SCM_UserProfileAssignment.getSCM_UserProfileAssignment(rowId,
                                                                                         'Initialized',
                                                                                          userId ,
                                                                                          groupId);
               returnRoleList.add(assignment);
            }
            
            index++;
        }
        
        Database.SaveResult[] saveResult = Database.Insert(detailList ,true);
 
        List<SCM_Profile_Assignment__c> assignmentList =  [select Id,SFDC_User_Id__c,Status__c 
                                                        from SCM_Profile_Assignment__c 
                                                        where Status__c = 'Initialized']; 
                                                        
        for (integer i=0; i<assignmentList.size();i++) {
            assignmentList[i].Status__c = 'Processing';
        }

        //Update database with new status for records in SCM_Profile_Assignment__c
        try {
            Database.update(assignmentList, true);
        } catch (DMLException e){
            System.debug(logginglevel.ERROR,
            'SCM_Profile_Assignment__c update failed'
            + e.getMessage());
        }

       return returnRoleList;
    }

   
   
    /********************************************************************/
    // Function Name    : clearSecurityDirtyItems
    // Argument         : String[]
    // Return Type      : Boolean
    // Description      : This function takes a String array composed of 
    //                    row ids that need to be obtained from the  
    //                    returned list of getSecurityDirtyGroup().  
    //                    Each row id in the String array is clears the
    //                    corresponding record in SCM_Profile_Assignment
    //                    and sets the Security_Dirty__c field on the User
    //                    object to false.
    /********************************************************************/
    
    webService static Boolean clearSecurityDirtyItems(String[] rowIds)
    {
        if (rowIds.size() == 0 )
            return false;
            

        // Query list of records to be deleted in SCM_Profile_Assignment__c  
        List<SCM_Profile_Assignment__c> assignmentList = 
                            [select Id,SFDC_User_Id__c,Status__c 
                            from SCM_Profile_Assignment__c
                            where Id in :rowIds LIMIT 100]; // Database.query(query);
        
        // Query list of Users and set Security_Dirty__c to false
        List<String> sfdcUserIds = new List<String>();
        for (Integer i = 0; i < assignmentList.size(); i++)
            sfdcUserIds.add(assignmentList[i].SFDC_User_Id__c);
       // List<User> undirtyUserList = [select Id,Security_Dirty__c 
       //                               from User 
       //                               where id in :sfdcUserIds];
                
       // for(User undirtyUser : undirtyUserList){
       //         undirtyUser.Security_Dirty__c = false;
       // }


        // Delete from database records in SCM_Profile_Assignment__c 
        try {
            Database.DeleteResult[] DeleteResult =  Database.delete(assignmentList, true);
        } catch (DMLException e) {
            System.debug(logginglevel.ERROR,
            'SCM_Profile_Assignment__c delete failed'
            + e.getMessage());
        }

        // Update database with Security_Dirty__c values set to false
       // try {
       //     Database.update(undirtyUserList);
       // } catch (DMLException e) {
       //     System.debug(logginglevel.ERROR,
       //     'User update failed');
       // }
        return true;
    }



    /********************************************************************/
    // Function Name    : testCoverage()
    // Description      : Test coverage for getSecurityDirtyGroup2() function
    //                    of SpringCMUserSecurityAssignment class
    /********************************************************************/  

    static testMethod void testCoverage(){
        
        //List<User> userList = [ select id,Security_Dirty__c 
        //                        from User 
        //                       where username='gatcfmanagerspring@gene.com.cm' 
        //                        or username = 'intake@gene.com'];
        List<User> dirtyUserList = [ select id,Security_Dirty__c 
                                from User 
                               where Security_Dirty__c=true];
        for(User usr:dirtyUserList)
        {
        	usr.Security_Dirty__c=false;
        }
        Database.update(dirtyUserList);
        
        List<SCM_Profile_Assignment__c> profileAssignments = [Select Id from SCM_Profile_Assignment__c];
        Database.delete(profileAssignments);
        List<SCM_Profile_Assignment_Detail__c> profileAssignmentDetails = [Select Id from SCM_Profile_Assignment_Detail__c];
        Database.delete(profileAssignmentDetails);
        List<User> userList = new List<User>();
        String roleId=[Select Id From UserRole Limit 1].Id;
        String tempProfileId=[Select Id From Profile Where Name='GNE-CM-CASEMANAGER' Limit 1].Id;
        System.debug('RoleId : ' + roleId);
        System.debug('ProfileId : ' + tempProfileId);
        //temp Profile Id : '00e70000000txFhAAI'
        User newUser1 = new User(Alias='test1', Email='email1@gene.com',
        						ProfileId=tempProfileId,Username='email1@gene.com.cm',
        						UserRoleId=roleId,
        						EmailEncodingKey='ISO-8859-1', 
        						LanguageLocaleKey='en_US',
        						LastName='tester',
        						LocaleSidKey='en_US',
        						TimeZoneSidKey='America/Los_Angeles'
        						);
        User newUser2 = new User(Alias='test2', Email='email2@gene.com',
        						ProfileId=tempProfileId,Username='email2@gene.com.cm',
        						UserRoleId=roleId,
        						EmailEncodingKey='ISO-8859-1', 
        						LanguageLocaleKey='en_US',
        						LastName='tester',
        						LocaleSidKey='en_US',
        						TimeZoneSidKey='America/Los_Angeles'
        						);
        userList.add(newUser1);
        userList.add(newUser2);
        
     //   for (User user: userList) {
    //        user.Security_Dirty__c = true;
     //   }

        insert userList;
        System.assert([select Security_Dirty__c from User where username='email1@gene.com.cm'].Security_Dirty__c == true);
        System.assert([select Security_Dirty__c from User where username='email2@gene.com.cm'].Security_Dirty__c == true);

        List<SCM_UserProfileAssignment> testFunctionList = SCM_UserSecurityAssignment.getSecurityDirtyGroup();
        
        List<String> rowIdList = new List<String>();

       // if (testFunctionList.size() > 0){
       //     for (Integer i=0; i<testFunctionList.size(); i++){
       //         rowIdList.add(testFunctionList[i].Row_Id);
       //     }
       //     SCM_UserSecurityAssignment.clearSecurityDirtyItems(rowIdList);
       // }
       // System.assert([select Security_Dirty__c from User where username='email1@gene.com.cm'].Security_Dirty__c == true);
       // System.assert([select Security_Dirty__c from User where username='email2@gene.com.cm'].Security_Dirty__c == true);
    }

}