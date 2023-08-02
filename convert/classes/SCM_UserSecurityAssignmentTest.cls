@isTest 
private class SCM_UserSecurityAssignmentTest
{
    public static testMethod void securityDirty2Test() 
    {

	    String roleId=[Select Id From UserRole Limit 1].Id;
	    String tempProfileId=[Select Id From Profile Where Name='GNE-CM-CASEMANAGER' Limit 1].Id;
		List<User> userList = new List<User>();
		List<User> tempUserList = new List<User>();
		for(Integer i=0;i<15;i++)
		{
			User newUser = new User(Alias='test'+i, 
									Email='script_test_email'+i+'@gene.com',
	        						ProfileId=tempProfileId,
	        						Username='script_test_email'+i+'@gene.com.cm',
	        						UserRoleId=roleId,
	        						EmailEncodingKey='ISO-8859-1', 
	        						LanguageLocaleKey='en_US',
	        						LastName='tester',
	        						LocaleSidKey='en_US',
	        						TimeZoneSidKey='America/Los_Angeles'
	        						);
	        userList.add(newUser);
	        tempUserList.add(newUser);
	        if(userList.size()==50)
	        {
	        	// We insert 50 records at once
	        	insert tempUserList;
	        	tempUserList.clear();
	        }
		}
		insert tempUserList;  
	
        for(Integer i=0;  i<userList.size(); i++){
            System.debug('\nasdfg' + userList[i].Id + '  ' + userList[i].Security_Dirty__c );
        }

        List<SCM_UserProfileAssignment> testFunctionList2 = SCM_UserSecurityAssignment.getSecurityDirtyGroup();
        System.debug ('\ntestFunctionList2.size(): '       + testFunctionList2.size()  + '\n' );

        List<String> rowIdList = new List<String>();
        for (Integer i=0; i<testFunctionList2.size();i++) {
           System.debug ('\ntestFunctionList2[i].Row_ID' + testFunctionList2[i].Row_ID + '\n' );
           rowIdList.add(testFunctionList2[i].Row_ID);
           System.debug ('\ntestFunctionList2[i].Status  '  + testFunctionList2[i].Status  +  '\n' );
           System.debug ('\ntestFunctionList2[i].SFDC_User_Id' + testFunctionList2[i].SFDC_User_Id  + '\n' );
           for(Integer j=0;j<testFunctionList2[i].SCM_Group_Id.size();j++) {
                System.debug ('\ntestFunctionList2[i].SCM_Group_Id' + testFunctionList2[i].SCM_Group_Id[j] + '\n' );
           }
       }
       List<SCM_Profile_Assignment__c> rows =  [Select Id from SCM_Profile_Assignment__c where Id in :rowIdList];
       System.debug ('\nRows Size  '  + rows.size()  +  '\n' );
       System.assert(testFunctionList2.size()>=rows.size(),'Testfunctionlist must have equal or more rows!');
       
      // SCM_UserSecurityAssignment.clearSecurityDirtyItems(rowIdList);
        testFunctionList2 = SCM_UserSecurityAssignment.getSecurityDirtyGroup();
        
        userList = [    select id,UserRoleId, Security_Dirty__c 
                                from User 
                                where username='gatcfmanagerspring@gene.com.cm' 
                                or username = 'intake@gene.com'];       
        
        for(Integer i=0;  i<userList.size(); i++){
            System.debug('\nasdfg' + userList[i].Id + '  ' + userList[i].Security_Dirty__c );
        }           
    }    
}