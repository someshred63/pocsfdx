public class SPCM_MCCTrackingSheetUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('MCC_Tracking_Sheet_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_MCC_Tracking_Sheet__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('MCC_Tracking_Sheet__c');
    }
    
    public String GetErrorsForLevel1(List<SPCM_Approval_Process_Level__c> processLevels)
    {
    	
        
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        //TODO: consider add a textbox and use the code below to check given user
        //check if manager exists
        /*
        if (! string.isblank(approver))
        {
	        List<User> userId = [select id from User where external_id_gne__c like :approver];
	        String managerId = approvalMgr.GetUserManagerId(userId);
	        if (managerId != null && managerId != '')
	        	return 'There is no manager for user ' + approver + ' defined.';
	    }
        */
        return null;
    }
    
    // method to handle approval events (triggered by current approval level field update)
    protected override void HandleApprovalEvents(List<SObject> newRecords, 
        List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig, 
        GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr)
    {

        // loop through records
        for (integer i = 0; i < newRecords.size(); i++)
        {
        
            // get new record and old record
            SPCM_MCC_Tracking_Sheet__c newRecord = (SPCM_MCC_Tracking_Sheet__c)newRecords[i];
            SPCM_MCC_Tracking_Sheet__c oldRecord = (SPCM_MCC_Tracking_Sheet__c)oldRecords[i];
        
            // set last approver
            newRecord.Last_Approver__c = UserInfo.getUserId();
  
            // set prior, and reset current, approval fields
            newRecord.Appr_Prior_Approval_Level__c = oldRecord.Appr_Approval_Level__c;
            for (integer fieldNum = 1; fieldNum <= GetMaxConcurrentApprovers(); fieldNum++)
            {
                newRecord.put('Appr_Prior_Approver_' + fieldNum + '__c', 
                    oldRecord.get('Appr_Approver_' + fieldNum + '__c'));
                newRecord.put('Appr_Prior_Approver_' + fieldNum + '_Original__c', 
                    oldRecord.get('Appr_Approver_' + fieldNum + '_Original__c'));
                newRecord.put('Appr_Prior_Approver_' + fieldNum + '_Process_Level__c', 
                    oldRecord.get('Appr_Approver_' + fieldNum + '_Process_Level__c'));
                newRecord.put('Appr_Approver_' + fieldNum + '__c', null);
                newRecord.put('Appr_Approver_' + fieldNum + '_Original__c', null);
                newRecord.put('Appr_Approver_' + fieldNum + '_Process_Level__c', null);
            }
 
            // if approval level 1
            if (newRecord.Appr_Approval_Level__c == 1)
            {

                // update initiated by
                newRecord.Initiated_By__c = UserInfo.getUserId();
            
                // check for single process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                
                    // get manager approver and set as original approver
                    String approverId = approvalMgr.GetUserManagerId(newRecord.Initiated_By__c);
                    newRecord.Appr_Approver_1_Original__c = approverId;
                    
                    // check for delegated approver
                    approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                    
                    // if there is an approver
                    if (approverId != null && approverId != '')
                    {
                    
                        // set approver and level
                        newRecord.Appr_Approver_1__c = approverId;
                        newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                    }
                    else
                    {
                        newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
                            'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
                            'Approval Level: ' + newRecord.Appr_Approval_Level__c);
                    }
                }
                else
                {
                    newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
                        'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
                        'Approval Level: ' + newRecord.Appr_Approval_Level__c);
                }
            }
        }
    }

    // test method for code coverage
    static testMethod void runPositiveTests()
    {
    
        // create test utility class
        SPCM_TestUtils testUtils = new SPCM_TestUtils();
        
        // run as analyst
        System.runAs(testUtils.userAnalyst)
        {
        
            // start test
            Test.startTest();
        
            // create test record
            SPCM_MCC_Tracking_Sheet__c newRecord = new SPCM_MCC_Tracking_Sheet__c(
                Requested_Final_Approval_Date__c = Date.today(),
                Customer_Name__c = testUtils.customerName.Id,
                Customer_Type__c = testUtils.customerType.Id,
                Account_Manager__c = testUtils.accountManager.Id,
                Agreement_Type__c = testUtils.agreementType.Id,
                Additional_Account_Manager__c = 'No',
                CMS_Contract_Id__c = 'TEST',
                MCC_Document_Type__c = 'Notice',
                Contract_Title__c = 'TEST',
                Product__c = 'TEST');
            insert(newRecord);
            System.assert(newRecord.Id != null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());
            
            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            List<SPCM_MCC_Tracking_Sheet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_MCC_Tracking_Sheet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.userManager.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_MCC_Tracking_Sheet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_MCC_Tracking_Sheet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate rejection
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Rejected';
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_MCC_Tracking_Sheet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_MCC_Tracking_Sheet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
                        
            // update to simulate recall
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Recalled';
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_MCC_Tracking_Sheet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // stop test
            Test.stopTest();
            
            // delete record
            delete(newRecord);
        }
    }
    
    // test method for code coverage
    static testMethod void runNegativeTests()
    {
    
        // create test utility class
        SPCM_TestUtils testUtils = new SPCM_TestUtils();
        
        // run as analyst
        System.runAs(testUtils.userAnalyst)
        {
        
            // start test
            Test.startTest();
        
            // create test record
            SPCM_MCC_Tracking_Sheet__c newRecord = new SPCM_MCC_Tracking_Sheet__c(
                Requested_Final_Approval_Date__c = Date.today(),
                Customer_Name__c = testUtils.customerName.Id,
                Customer_Type__c = testUtils.customerType.Id,
                Account_Manager__c = testUtils.accountManager.Id,
                Agreement_Type__c = testUtils.agreementType.Id,
                Additional_Account_Manager__c = 'No',
                CMS_Contract_Id__c = 'TEST',
                MCC_Document_Type__c = 'Notice',
                Contract_Title__c = 'TEST',
                Product__c = 'TEST');
            insert(newRecord);
            System.assert(newRecord.Id != null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());
            
            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
              
            // create approval manager helper
            SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager();
            
            // update analyst AUH to remove manager
            testUtils.analystAUH.All_User_Hierarchy_Level1_gne__c = null;
            update(testUtils.analystAUH);
            
            // update user to remove manager field
            //testUtils.userAnalyst.ManagerId = null;
            //update(testUtils.userAnalyst);
            
            // update to simulate approval submission (level 1)
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            Boolean exceptionThrown = false;
            try
            {
                update(newRecord);
            }
            catch (Exception e)
            {
                exceptionThrown = true;
            }
            
            // run assertion
            System.assert(exceptionThrown);

            // get process level 1
            List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(objectType, 1);
            if (processLevels.size() == 1)
            {
                
                // delete process level
                delete (processLevels[0]);
            }
            
            // update to simulate approval submission (level 1)
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            exceptionThrown = false;
            try
            {
                update(newRecord);
            }
            catch (Exception e)
            {
                exceptionThrown = true;
            }
            
            // run assertion
            System.assert(exceptionThrown);

            // stop test
            Test.stopTest();
        }
    }
}