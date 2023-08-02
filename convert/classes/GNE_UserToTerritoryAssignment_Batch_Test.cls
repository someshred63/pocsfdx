/**

 */
@isTest
private class GNE_UserToTerritoryAssignment_Batch_Test {

private static final String RECORD_NEW_STATE = 'Loaded';
private static final String RECORD_ERROR_STATE = 'Error Processing';
private static final String RECORD_SUCCESS_STATE = 'Processed';
private static final String TEST_PROFILE_PATTERN = 'GNE-SFA-%-CS';

    static testMethod void noRecordsTest() {
         BatchableContextImplementation context =
            new BatchableContextImplementation(UserInfo.getUserID(), UserInfo.getUserID());
         Staging_User_Assignment_gne__c tmpRecord = new Staging_User_Assignment_gne__c();
            tmpRecord.User_UnixID_gne__c = 'testFakeUser';
            tmpRecord.Territory_Key_gne__c = 'testFakeTerr';
            tmpRecord.Activaction_Date_gne__c = Date.Today().addYears(1);
            tmpRecord.Status_gne__c = RECORD_NEW_STATE;
        insert tmpRecord;

        Test.StartTest();
            GNE_UserToTerritoryAssignment_Batch subscribe = new GNE_UserToTerritoryAssignment_Batch(false, null);
            Database.QueryLocator queryLocator = subscribe.start(context);
            List<Staging_User_Assignment_gne__c> scope = (List<Staging_User_Assignment_gne__c>) Database.query(queryLocator.getQuery());

            System.assertEquals(0, scope.size());

            subscribe.execute(context, scope);
            subscribe.finish(context);

        Test.StopTest();
    }

    static testMethod void assignUserToTerritoryInPreviewModeTest() {
        BatchableContextImplementation context =
            new BatchableContextImplementation(UserInfo.getUserID(), UserInfo.getUserID());

        Staging_User_Assignment_gne__c tmpRecord = new Staging_User_Assignment_gne__c();
        tmpRecord.User_UnixID_gne__c = GNE_SFA2_Util.selectSFA2User().External_ID_gne__c;
        tmpRecord.Territory_Key_gne__c = [SELECT External_Id_gne__c FROM Territory2 WHERE Name like 'L2MA03-%' LIMIT 1].External_Id_gne__c;
        tmpRecord.Activaction_Date_gne__c = Date.Today() - 1;
        tmpRecord.Status_gne__c = RECORD_NEW_STATE;
        insert tmpRecord;
        List<Staging_User_Assignment_gne__c > suList = new List<Staging_User_Assignment_gne__c>();
        suList.add(tmpRecord);

        Test.StartTest();
            DateTime startDate = System.now();
            GNE_UserToTerritoryAssignment_Batch subscribe = new GNE_UserToTerritoryAssignment_Batch(true, null);
            subscribe.execute(context, suList);
            List<Staging_User_Assignment_gne__c> scope = [select Id,SFDC_UserTerritory_gne__c, Status_gne__c from Staging_User_Assignment_gne__c where User_UnixID_gne__c = :tmpRecord.User_UnixID_gne__c and Territory_Key_gne__c = :tmpRecord.Territory_Key_gne__c];

            System.assertEquals(1, scope.size());
            System.assertEquals(RECORD_NEW_STATE, scope.get(0).Status_gne__c);
        Test.StopTest();
    }

    static testMethod void assignUserToTerritoryTest() {
        BatchableContextImplementation context =
            new BatchableContextImplementation(UserInfo.getUserID(), UserInfo.getUserID());

         Staging_User_Assignment_gne__c tmpRecord = new Staging_User_Assignment_gne__c();
            tmpRecord.User_UnixID_gne__c = GNE_SFA2_Util.selectSFA2User().External_ID_gne__c;
            tmpRecord.Territory_Key_gne__c = [SELECT External_Id_gne__c FROM Territory2 WHERE Name like 'L2MA03-%' LIMIT 1].External_Id_gne__c;
            tmpRecord.Activaction_Date_gne__c = Date.Today() - 1;
            tmpRecord.Status_gne__c = RECORD_NEW_STATE;
        insert tmpRecord;
        List<Staging_User_Assignment_gne__c > suList = new List<Staging_User_Assignment_gne__c>();
        suList.add(tmpRecord);

        Test.StartTest();
            DateTime startDate = System.now();
            GNE_UserToTerritoryAssignment_Batch subscribe = new GNE_UserToTerritoryAssignment_Batch(false, null);
            Database.executeBatch(subscribe);
        Test.StopTest();
            
        List<Staging_User_Assignment_gne__c> scope = [select Id, Comment_gne__c, SFDC_UserTerritory_gne__c, Status_gne__c from Staging_User_Assignment_gne__c where User_UnixID_gne__c = :tmpRecord.User_UnixID_gne__c and Territory_Key_gne__c = :tmpRecord.Territory_Key_gne__c];
        system.debug(scope);
        System.assertEquals(1, scope.size());
        System.assertEquals(RECORD_SUCCESS_STATE, scope.get(0).Status_gne__c);
    }


    static testMethod void bigAmountDataTest() {
	      BatchableContextImplementation context =
	            new BatchableContextImplementation(UserInfo.getUserID(), UserInfo.getUserID());
	
	     // Create test data from existing users and territories
	
	     List<User> ActiveUsers = [Select Id,External_ID_gne__c from User where isActive = true and Profile.Name like :TEST_PROFILE_PATTERN and External_ID_gne__c != null  limit 200];
	     List<Territory2> TerritoriesToAssign = [Select Id, Name, External_Id_gne__c from Territory2 WHERE External_Id_gne__c != null limit 200];
	
	     List<Staging_User_Assignment_gne__c > Stg_User_Assignemnt = new List<Staging_User_Assignment_gne__c >();
	
	     for(User tmpUser : ActiveUsers) {
	        Integer terrNumber = Integer.valueOf( math.random() * 100 );
	
	        Staging_User_Assignment_gne__c tmpRecord = new Staging_User_Assignment_gne__c();
	        tmpRecord.User_UnixID_gne__c = tmpUser.External_ID_gne__c;
	        if(tmpRecord.User_UnixID_gne__c.length() > 40) {
                tmpRecord.User_UnixID_gne__c = tmpRecord.User_UnixID_gne__c.substring(10 , tmpRecord.User_UnixID_gne__c.length());
	        }
	        tmpRecord.Territory_Key_gne__c = TerritoriesToAssign[terrNumber].External_Id_gne__c;
	        tmpRecord.Activaction_Date_gne__c = Date.Today();
	        tmpRecord.Status_gne__c = RECORD_NEW_STATE;
	
	        if(tmpUser.External_ID_gne__c.startsWith('a') ||tmpUser.External_ID_gne__c.startsWith('s') || tmpUser.External_ID_gne__c.startsWith('t') || tmpUser.External_ID_gne__c.startsWith('m') )
	            tmpRecord.Unalign_Date_gne__c = Date.Today();
	
	        // Random choose fake unix user Id
	        if(math.random() > 0.8) {
	            tmpRecord.User_UnixID_gne__c += 'FAKE';
	            if(tmpRecord.User_UnixID_gne__c.length() > 40) {
	                tmpRecord.User_UnixID_gne__c = tmpRecord.User_UnixID_gne__c.substring(20 , tmpRecord.User_UnixID_gne__c.length());
	            }
	        }
	
	        if(math.random() > 0.7 && math.random() < 0.8 ) {
	            tmpRecord.Territory_Key_gne__c += 'FAKE';
	        }
	        Stg_User_Assignemnt.add(tmpRecord);
	     }
	
	    insert Stg_User_Assignemnt;
	
	    // Run batch process in order to assign values to output fields
	    Test.StartTest();
	      GNE_UserToTerritoryAssignment_Batch subscribe = new GNE_UserToTerritoryAssignment_Batch(false, null);
	
	      subscribe.execute(context, Stg_User_Assignemnt);
	      subscribe.finish(context);
	
	    Test.StopTest();
	
	    for(Staging_User_Assignment_gne__c tmp :Stg_User_Assignemnt) {
	        //check if user is fake and status is correct
	        if(tmp.User_UnixID_gne__c.contains('FAKE')) {
	            System.assertEquals(RECORD_ERROR_STATE, tmp.Status_gne__c);
	        }
	        
	        if(tmp.Territory_Key_gne__c.contains('FAKE')) {
	            System.assertEquals(RECORD_ERROR_STATE, tmp.Status_gne__c);
	        }
	    }
    }

    public class BatchableContextImplementation implements Database.BatchableContext {
	    private ID childJob, job;

	    public BatchableContextImplementation(ID job, ID childJob) {
	        this.job = job;
	        this.childJob = childJob;
	    }

	    public ID getChildJobID() {
	        return childJob;
	    }

	    public ID getJobID(){
	        return job;
	    }
	}
}