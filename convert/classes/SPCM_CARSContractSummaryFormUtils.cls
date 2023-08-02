public class SPCM_CARSContractSummaryFormUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('CARS_Contract_Summary_Form_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_CARS_Contract_Summary_Form__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('CARS_Contract_Summary_Form__c');
    }
   
    // method to handle approval events (triggered by current approval level field update)
    protected override void HandleApprovalEvents(List<SObject> newRecords, 
        List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig, 
        GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr)
    {

        // loop through records
        for (integer i = 0; i < newRecords.size(); i++)
        {
            string ICFRLogStatus = '';
            Id approver = null;
            Boolean updateIcfrLogs = false;

            // get new record
            SPCM_CARS_Contract_Summary_Form__c newRecord = (SPCM_CARS_Contract_Summary_Form__c)newRecords[i];
            SPCM_CARS_Contract_Summary_Form__c oldRecord = (SPCM_CARS_Contract_Summary_Form__c)oldRecords[i];
        
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

            
            //update ICFR Logs status when CUT is withdrawn, rejected, recalled, new and approved
            if (newRecord.Approval_Status__c == 'Rejected')
            {
                ICFRLogStatus = 'Pending Analyst';
                approver = newRecord.Last_Approver__c;
                updateIcfrLogs = true;
            }
            else if (newRecord.Approval_Status__c == 'Recalled')
            {
                ICFRLogStatus = 'Pending Analyst';
                approver = null;
                updateIcfrLogs = true;
            }
            else if (newRecord.Approval_Status__c == 'Withdrawn')
            {
                ICFRLogStatus = 'Pending Analyst';
                approver = newRecord.Initiated_By__c;
                updateIcfrLogs = true;
            }
            else if (newRecord.Approval_Status__c == 'Approved')
            {
                ICFRLogStatus = newRecord.Group_Manager_Approval_Not_Required__c 
                    ? 'Approved by Level 1' 
                    : 'Approved by Level 2';

                approver = newRecord.Last_Approver__c;
                updateIcfrLogs = true;
            }
            else if (newRecord.Approval_Status__c == 'New')
            {
                ICFRLogStatus = 'Pending Analyst';
                approver = null;
                updateIcfrLogs = true;
            }

			if (newRecord.Appr_Approval_Level__c == 1)
            {

            	newRecord.Initiated_By__c = UserInfo.getUserId();
            	
            	if(newRecord.RCA_Approval_Not_Required__c)
            	{
            		newRecord.Appr_Approval_Level__c += 1;
            	}
            	else
            	{
                    SPCM_Approval_Process_Level__c processLevel = approvalMgr.GetProcessLevelById(
                            newRecord.RCA_Approval_Level__c);
        
                    SetApproverFromLevel(newRecord, processLevel);
                    
                    //update ICFR Logs status when CUT is pending RCM approval
                    ICFRLogStatus = 'Pending Level 1 Approval';
                    approver =  newRecord.Appr_Approver_1__c;
                    updateIcfrLogs = true;
                }

            }
            if (newRecord.Appr_Approval_Level__c == 2)
            {
            	if (newRecord.Group_Manager_Approval_Not_Required__c)
            	{
            		newRecord.Appr_Approval_Level__c += 1;
            	}
            	else
            	{
                    SPCM_Approval_Process_Level__c processLevel = approvalMgr.GetProcessLevelById(
                            newRecord.Group_Manager_Approval_Level__c);
        
                    SetApproverFromLevel(newRecord, processLevel);
                    
                    //update ICFR Logs status when CUT is pending Manager approval
                    ICFRLogStatus = 'Pending Level 2 Approval';
                    approver =  newRecord.Appr_Approver_1__c;
                    updateIcfrLogs = true;
                }
            }



            if (updateIcfrLogs){
                UpdateICFRLogEntries(ICFRLogStatus, approver, newRecord.Id);
            }

        }
    }
    
    public static void UpdateLevelApprover(SPCM_CARS_Contract_Summary_Form__c newRecord, Decimal levelNumber, Id level2Id)
    {
		SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
		GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
		SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager(roleConfig, processConfig);
		
		SPCM_Approval_Process_Level__c processLevel = approvalMgr.GetProcessLevelById(level2Id);
		
		SetApproverFromLevel(newRecord, processLevel);
		
		if (levelNumber == 1) {
			newRecord.RCA_Approval_Level__c = level2Id;
		} else if (levelNumber == 2) {
			newRecord.Group_Manager_Approval_Level__c = level2Id;
		}
		
		update newRecord;
    }

    private static void UpdateICFRLogEntries(string ICFRLogStatus, id approver, Id CUTId)
    {
        List<SPCM_ICFR_Log__c> logEntries = [select id, Status__c, CUT_Approver_Name__c, Expected_Activation_Date__c from SPCM_ICFR_Log__c where CUT_Approval_Id__c = :CUTId];
        for (SPCM_ICFR_Log__c logEntry : logEntries){
            logEntry.Status__c = ICFRLogStatus;
            logEntry.CUT_Approver_Name__c = approver;
        }
        update logEntries;
    }
    
    private static void SetApproverFromLevel(SPCM_CARS_Contract_Summary_Form__c newRecord, SPCM_Approval_Process_Level__c processLevel)
    {
    	//if (processLevel != null && processLevel.User__c != null)
        if (GetErrorsForLevel(processLevel) == null)
       	{
    		// fetch approver Id from process level
	        String approverId = processLevel.User__c;
            		
            newRecord.Appr_Approver_1_Original__c = approverId;
                    
            // check for delegated approver
            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

            // set approver
            if (approverId != null && approverId != '')
            {
            	newRecord.Appr_Approver_1__c = approverId;
            	newRecord.Appr_Approver_1_Process_Level__c = String.valueOf(processLevel.Id);
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

    public static String GetErrorsForLevel(SPCM_Approval_Process_Level__c processLevel)
    {

        if (processLevel == null)
            return 'No process level defined';
        else if (processLevel.User__c == null )
            return 'No user defined for process level';
        else if (GNE_UserDelegationUtils.GetDelegatedUser(processLevel.User__c) == null)
            return 'No delegated approver defined';
            
        return null;
/*
        if (processLevel != null 
            && processLevel.User__c != null 
            && GNE_UserDelegationUtils.GetDelegatedUser(processLevel.User__c) != null)
            return true;
        return false;
        */
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
            SPCM_CARS_Contract_Summary_Form__c newRecord = new SPCM_CARS_Contract_Summary_Form__c(
                Requested_Final_Approval_Date__c = Date.today(),
                Customer_Name__c = testUtils.customerName.Id,
                Customer_Type__c = testUtils.customerType.Id,
                Account_Manager__c = testUtils.accountManager.Id,
                Agreement_Type__c = testUtils.agreementType.Id,
                Market_Type__c = testUtils.marketType.Id,
                Contract_Manager__c = testUtils.contractManager.Id, 
                Contract_Title__c = 'TEST',
                Product__c = 'TEST');
                
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());
            
            // create approval process data
            testUtils.CreateApprovalProcessData(objectType, 'SPCM CARS Contract Summary Form');
            
            newRecord.RCA_Approval_Level__c = [ SELECT Id FROM SPCM_Approval_Process_Level__c 
            	WHERE Approval_Process__r.Approval_Process_Type__c = :objectType 
            	AND Level_Number__c = 1 
            	LIMIT 1 ].Id;
            newRecord.Group_Manager_Approval_Level__c = [ SELECT Id FROM SPCM_Approval_Process_Level__c 
            	WHERE Approval_Process__r.Approval_Process_Type__c = :objectType 
            	AND Level_Number__c = 2 
            	LIMIT 1 ].Id; 
            
            insert(newRecord);
            System.assert(newRecord.Id != null);
   
   			/*         
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());
            
            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
            */
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            List<SPCM_CARS_Contract_Summary_Form__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
            //System.assert(newRecords[0].Appr_Approver_1__c == testUtils.userManager.Id);
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 2;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser2.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate rejection
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Rejected';
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate submission
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
                        
            // update to simulate recall
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Recalled';
            update(newRecord);

            // refresh data and run assertions
            newRecords = [SELECT RecordTypeId FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id = :newRecord.Id];
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
            SPCM_CARS_Contract_Summary_Form__c newRecord = new SPCM_CARS_Contract_Summary_Form__c(
                Requested_Final_Approval_Date__c = Date.today(),
                Customer_Name__c = testUtils.customerName.Id,
                Customer_Type__c = testUtils.customerType.Id,
                Account_Manager__c = testUtils.accountManager.Id,
                Agreement_Type__c = testUtils.agreementType.Id,
                Market_Type__c = testUtils.marketType.Id,
                Contract_Manager__c = testUtils.contractManager.Id,
                Contract_Title__c = 'TEST',
                Product__c = 'TEST');
                            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());
            
            // create approval process data
            testUtils.CreateApprovalProcessData(objectType, 'SPCM CARS Contract Summary Form');
            
            newRecord.RCA_Approval_Level__c = [ SELECT Id FROM SPCM_Approval_Process_Level__c 
            	WHERE Approval_Process__r.Approval_Process_Type__c = :objectType 
            	AND Level_Number__c = 1 
            	LIMIT 1 ].Id;
            newRecord.Group_Manager_Approval_Level__c = [ SELECT Id FROM SPCM_Approval_Process_Level__c 
            	WHERE Approval_Process__r.Approval_Process_Type__c = :objectType 
            	AND Level_Number__c = 2 
            	LIMIT 1 ].Id; 
            
            insert(newRecord);
            System.assert(newRecord.Id != null);
            
            /*
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());
            
            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
            */
            
            /* 
            // create approval manager helper
            SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager();
            
            // update user to remove manager field
            testUtils.analystAUH.All_User_Hierarchy_Level1_gne__c = null;
            update(testUtils.analystAUH);
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
            */
            
            // remove process level roles/users
            testUtils.RemoveApprovalProcessRolesAndUsers(objectType);

            // loop through levels to ensure error
            Boolean exceptionThrown = false;
            for (Integer level = 1; level <= testUtils.GetApprovalLevelCount(objectType); level++)
            {
            
                // update to simulate level movement
                newRecord.Appr_Approval_Level__c = level;
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
                
                System.assertEquals(exceptionThrown, true);
            }
            
            /*            
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
			*/
			
            // stop test
            Test.stopTest();
        }
    }
}