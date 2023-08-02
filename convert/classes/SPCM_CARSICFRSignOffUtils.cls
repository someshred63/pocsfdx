public class SPCM_CARSICFRSignOffUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (15);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('CARS_ICFR_Sign_Off_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_CARS_ICFR_Sign_Off__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('CARS_ICFR_Sign_Off__c');
    }


    public String GetErrorsForLevel1(String frequency, SPCM_ApprovalManager approvalMgr)
    {
        List<String> approverIds = new List<String>();
        for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels('SPCM_CARS_ICFR_Sign_Off__c', 1))
            {
                
                // if frequency matches
                if (processLevel.Frequency__c == frequency)
                {
                
                    // get approver
                    String approverId = processLevel.User__c;
                    
                    
                    // check for delegated approver
                    approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                    
                    // add approver to list
                    approverIds.add(approverId);
                    
                }
            }
                
            // if there is between 1 and 15 approvers
            if (approverIds.size() >= 1 && approverIds.size() <= 15)
                return null;
            return 'Approvers number not between 1 and 15. (' + approverIds.size() + ')';
    }

    public String GetErrorsForLevel2(SPCM_ApprovalManager approvalMgr)
    {
        List<String> approverIds = new List<String>();
        for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels('SPCM_CARS_ICFR_Sign_Off__c', 2))
        {
            // get approver
            String approverId = processLevel.User__c;
            
            
            // check for delegated approver
            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
            // add approver to list
            approverIds.add(approverId);
            
        }
        
        // if there is between 1 and 15 approvers
        if (approverIds.size() >= 1 && approverIds.size() <= 15)
            return null;
        return 'Approvers number not between 1 and 15. (' + approverIds.size() + ')';
    }

    public String GetErrorsForLevel3(SPCM_ApprovalManager approvalMgr)
    {
        String approverId = '';
        // ensure one process level
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_ICFR_Sign_Off__c', 3);
        
        if (processLevels.size() != 1)
            return 'There should be exactly one process level for level number 3 (currently: ' + processLevels.size() + ').';
        
        // get approver and process level id
        approverId = processLevels[0].User__c;
        
        // if there is an approver
        if (approverId == null || approverId == '')
            return 'No approver defined for process level';

        return null;
    }

    public String GetErrorsForLevel4(SPCM_ApprovalManager approvalMgr)
    {
        String approverId = '';
        // ensure one process level
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_ICFR_Sign_Off__c', 4);
        
        if (processLevels.size() != 1)
            return 'There should be exactly one process level for level number 4 (currently: ' + processLevels.size() + ').';
        
        // get approver and process level id
        approverId = processLevels[0].User__c;
        
        // if there is an approver
        if (approverId == null || approverId == '')
            return 'No approver defined for process level';

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
        
            // get new and old records
            SPCM_CARS_ICFR_Sign_Off__c newRecord = (SPCM_CARS_ICFR_Sign_Off__c)newRecords[i];
            SPCM_CARS_ICFR_Sign_Off__c oldRecord = (SPCM_CARS_ICFR_Sign_Off__c)oldRecords[i];

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

            // get prior delegated approvers
            Set<String> priorDelApprs = new Set<String>();
            for (integer fieldNum = 1; fieldNum <= GetMaxConcurrentApprovers(); fieldNum++)
            {
                if (newRecord.get('Appr_Prior_Approver_' + fieldNum + '__c') != 
                    newRecord.get('Appr_Prior_Approver_' + fieldNum + '_Original__c'))
                {
                    priorDelApprs.add(String.valueOf(newRecord.get('Appr_Prior_Approver_' + fieldNum + '__c')));
                }
            }

            // approval level 1
            if (newRecord.Appr_Approval_Level__c == 1)
            {

                // update initiated by
                newRecord.Initiated_By__c = UserInfo.getUserId();
            
                // loop through process levels
                List<String> approverIds = new List<String>();
                List<String> origApprIds = new List<String>();
                List<String> processLevelIds = new List<String>();
                for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c))
                {
                    
                    // if frequency matches
                    if (processLevel.Frequency__c == newRecord.Frequency__c)
                    {
                    
                        // get approver
                        String approverId = processLevel.User__c;
                        
                        // add original to list
                        origApprIds.add(approverId);
                        
                        // check for delegated approver
                        approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                        
                        // add approver to list
                        approverIds.add(approverId);
                        
                        // add process level to list
                        processLevelIds.add(processLevel.Id);
                    }
                }
                
                // if there is between 1 and 15 approvers
                if (approverIds.size() >= 1 && approverIds.size() <= 15)
                {
                
                    // loop through approval fields
                    for (integer fieldNum = 1; fieldNum <= 15; fieldNum++)
                    {
                    
                        // get approver, original and process level
                        String approverId = approverIds.size() >= fieldNum ? approverIds[fieldNum - 1] : 
                            approverIds[approverIds.size() - 1];
                        String origApprId = origApprIds.size() >= fieldNum ? origApprIds[fieldNum - 1] : 
                            origApprIds[origApprIds.size() - 1];
                        String processLevelId = processLevelIds.size() >= fieldNum ? processLevelIds[fieldNum - 1] :
                            processLevelIds[processLevelIds.size() - 1];
                            
                        // set approver and process level
                        newRecord.put('Appr_Approver_' + fieldNum + '__c', approverId);
                        newRecord.put('Appr_Approver_' + fieldNum + '_Original__c', origApprId);
                        newRecord.put('Appr_Approver_' + fieldNum + '_Process_Level__c', processLevelId);
                    }
                }
                else
                {
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                        newRecord.Appr_Approval_Level__c));
                }
            }
            // approval level 2
            if (newRecord.Appr_Approval_Level__c == 2)
            {
                
                // loop through process levels
                List<String> approverIds = new List<String>();
                List<String> origApprIds = new List<String>();
                List<String> processLevelIds = new List<String>();
                for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c))
                {
                    
                    // get approver
                    String approverId = processLevel.User__c;
                    
                    // add original to list
                    origApprIds.add(approverId);
                    
                    // check for delegated approver
                    approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                    
                    // add approver to list
                    approverIds.add(approverId);
                    
                    // add process level to list
                    processLevelIds.add(processLevel.Id);
                }
                
                // if there is between 1 and 15 approvers
                if (approverIds.size() >= 1 && approverIds.size() <= 15)
                {
                
                    // loop through approval fields
                    for (integer fieldNum = 1; fieldNum <= 15; fieldNum++)
                    {
                    
                        // get approver, original and process level
                        String approverId = approverIds.size() >= fieldNum ? approverIds[fieldNum - 1] : 
                            approverIds[approverIds.size() - 1];
                        String origApprId = origApprIds.size() >= fieldNum ? origApprIds[fieldNum - 1] : 
                            origApprIds[origApprIds.size() - 1];
                        String processLevelId = processLevelIds.size() >= fieldNum ? processLevelIds[fieldNum - 1] :
                            processLevelIds[processLevelIds.size() - 1];
                            
                        // set approver, original and process level
                        newRecord.put('Appr_Approver_' + fieldNum + '__c', approverId);
                        newRecord.put('Appr_Approver_' + fieldNum + '_Original__c', origApprId);
                        newRecord.put('Appr_Approver_' + fieldNum + '_Process_Level__c', processLevelId);
                    }
                }
                else
                {
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                        newRecord.Appr_Approval_Level__c));
                }
            }
            // approval level 3
            if (newRecord.Appr_Approval_Level__c == 3)
            {
                
                // ensure one process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                    
                    // get approver and process level id
                    String approverId = processLevels[0].User__c;
                    String processLevelId = processLevels[0].Id;
                    
                    // if there is an approver
                    if (approverId != null && approverId != '')
                    {
                    
                        // if approver not prior delegated approver
                        if (!priorDelApprs.contains(approverId))
                        {
                    
                            // set as original
                            newRecord.Appr_Approver_1_Original__c = approverId;
                        
                            // check for delegated approver
                            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                            
                            // set approver and process level
                            newRecord.Appr_Approver_1__c = approverId;
                            newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                        }
                        else
                        {
                        insertSkippedRecord(newRecord, 'Level 3 - Approval', approverId);
                            // skip step
                            newRecord.Appr_Approval_Level__c += 1;
                        }
                    }
                    else
                    {
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                            newRecord.Appr_Approval_Level__c));
                    }
                }
                else
                {
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                        newRecord.Appr_Approval_Level__c));
                }
            }

/*
            // approval level 4-Removed this level as part of M & E
            if (newRecord.Appr_Approval_Level__c == 4)
            {
                
                // loop through process levels
                List<String> approverIds = new List<String>();
                List<String> origApprIds = new List<String>();
                List<String> processLevelIds = new List<String>();
                for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c))
                {
                    
                    // get approver
                    String approverId = processLevel.User__c;
                    
                    // add original to list
                    origApprIds.add(approverId);
                    
                    // check for delegated approver
                    approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                    
                    // add approver to list
                    approverIds.add(approverId);
                    
                    // add process level to list
                    processLevelIds.add(processLevel.Id);
                }
                
                // if there are exactly 2 approvers
                if (approverIds.size() == 2)
                {
                
                    // loop through approval fields
                    for (integer fieldNum = 1; fieldNum <= 2; fieldNum++)
                    {
                    
                        // get approver, original and process level
                        String approverId = approverIds[fieldNum - 1];
                        String origApprId = origApprIds[fieldNum - 1];
                        String processLevelId = processLevelIds[fieldNum - 1];
                        
                        // set approver, original and process level
                        newRecord.put('Appr_Approver_' + fieldNum + '__c', approverId);
                        newRecord.put('Appr_Approver_' + fieldNum + '_Original__c', origApprId);
                        newRecord.put('Appr_Approver_' + fieldNum + '_Process_Level__c', processLevelId);
                    }
                }
                else
                {
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                        newRecord.Appr_Approval_Level__c));
                }
            }*/
            // approval level 4
            if (newRecord.Appr_Approval_Level__c == 4)
            {

                // ensure one process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                    
                    // get approver and process level id
                    String approverId = processLevels[0].User__c;
                    String processLevelId = processLevels[0].Id;
                    
                    // if there is an approver
                    if (approverId != null && approverId != '')
                    {
                    
                        // if approver not prior delegated approver
                        if (!priorDelApprs.contains(approverId))
                        {
                    
                            // set as original
                            newRecord.Appr_Approver_1_Original__c = approverId;
                        
                            // check for delegated approver
                            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                            
                            // set approver and process level
                            newRecord.Appr_Approver_1__c = approverId;
                            newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                        }
                        else
                        {
                        insertSkippedRecord(newRecord, 'Level 4 - C-Ops Executive Approval', approverId);
                            // skip step
                            newRecord.Appr_Approval_Level__c += 1;
                        }
                    }
                    else
                    {
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                            newRecord.Appr_Approval_Level__c));
                    }
                }
                else
                {
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
                        newRecord.Appr_Approval_Level__c));
                }
            }
        }
    }
    //method to insert skipped record
    private  void insertSkippedRecord(SPCM_CARS_ICFR_Sign_Off__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.CARS_ICFR_Sign_Off__c= newRecord.Id;
                                newHistoryRecord.Approval_Status__c = 'Approved';
                                newHistoryRecord.Actual_Approver__c=apprId;
                                newHistoryRecord.Original_Approver__c=apprId;
                                newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                               dateTime myDate = dateTime.now();
                                newHistoryRecord.End_Date__c= myDate+0.00005;
                                newHistoryRecord.Comments__c='Auto approved due to delegation';
                                insert newHistoryRecord;
                                

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
            SPCM_CARS_ICFR_Sign_Off__c newRecord = new SPCM_CARS_ICFR_Sign_Off__c(Frequency__c = 'Monthly');
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_CARS_ICFR_Sign_Off__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_ICFR_Sign_Off__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Id != null);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate level 1
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_ICFR_Sign_Off__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // simulate submission through all levels
            for (Integer level = 1; level <= testUtils.GetApprovalLevelCount(objectType); level++)
            {
            
                // update to simulate level movement
                newRecord.Appr_Approval_Level__c = level;
                newRecord.Appr_Update_Date__c = DateTime.now();
                newRecord.Approval_Status__c = 'Submitted for Approval';
                newRecord.Submitted_Date__c = Date.today();
                update(newRecord);

                // refresh data and run assertions
                newRecords = [SELECT Appr_Approver_1__c, Appr_Approver_2__c,
                    RecordTypeId FROM SPCM_CARS_ICFR_Sign_Off__c WHERE Id = :newRecord.Id];
                if (level == 4)
                {
                    System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id ||
                        newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser2.Id);
                    System.assert(newRecords[0].Appr_Approver_2__c == testUtils.busRoleUser.Id ||
                        newRecords[0].Appr_Approver_2__c == testUtils.busRoleUser2.Id);
                }
                else
                {
                    System.assertEquals(newRecords[0].Appr_Approver_1__c, testUtils.busRoleUser.Id);
                }
                System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            }
            
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_ICFR_Sign_Off__c WHERE Id = :newRecord.Id];
            System.assertEquals(newRecords[0].Appr_Prior_Approval_Level__c, testUtils.GetApprovalLevelCount(objectType));
            System.assertEquals(newRecords[0].Appr_Prior_Approver_1__c, String.valueOf(testUtils.busRoleUser.Id));
            System.assertEquals(newRecords[0].Appr_Approver_1__c, null);
            System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate rejection
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Rejected';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_ICFR_Sign_Off__c WHERE Id = :newRecord.Id];
            System.assertEquals(newRecords[0].Appr_Prior_Approval_Level__c, testUtils.GetApprovalLevelCount(objectType));
            System.assertEquals(newRecords[0].Appr_Prior_Approver_1__c, String.valueOf(testUtils.busRoleUser.Id));
            System.assertEquals(newRecords[0].Appr_Approver_1__c, null);
            System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate recalled
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Recalled';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_ICFR_Sign_Off__c WHERE Id = :newRecord.Id];
            System.assertEquals(newRecords[0].Appr_Prior_Approval_Level__c, testUtils.GetApprovalLevelCount(objectType));
            System.assertEquals(newRecords[0].Appr_Prior_Approver_1__c, String.valueOf(testUtils.busRoleUser.Id));
            System.assertEquals(newRecords[0].Appr_Approver_1__c, null);
            System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // stop test
            Test.stopTest();
            
            // delete record
            delete(newRecord);
        }
    }
   
    // test method for code coverage
    static testMethod void runUserNegativeTests()
    {
    
        // create test utility class
        SPCM_TestUtils testUtils = new SPCM_TestUtils();
        
        // run as analyst
        System.runAs(testUtils.userAnalyst)
        {
        
            // start test
            Test.startTest();
        
            // create test record
            SPCM_CARS_ICFR_Sign_Off__c newRecord = new SPCM_CARS_ICFR_Sign_Off__c(Frequency__c = 'Monthly');
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
            
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
                
                // run assertion
                //System.assertEquals(exceptionThrown, true);
            }
 
            // stop test
            Test.stopTest();
        }
    }
    
    // test method for code coverage
    static testMethod void runProcessLevelNegativeTests()
    {
    
        // create test utility class
        SPCM_TestUtils testUtils = new SPCM_TestUtils();
        
        // run as analyst
        System.runAs(testUtils.userAnalyst)
        {
        
            // start test
            Test.startTest();
        
            // create test record
            SPCM_CARS_ICFR_Sign_Off__c newRecord = new SPCM_CARS_ICFR_Sign_Off__c(Frequency__c = 'Monthly');
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);

            // get level count
            Decimal levelCount = testUtils.GetApprovalLevelCount(objectType);

            // delete process levels
            testUtils.DeleteApprovalProcessLevels(objectType);

            // get approval manager helper
            SPCM_ApprovalManager appMgr = new SPCM_ApprovalManager();

            // loop through levels to ensure error
            Boolean exceptionThrown = false;
            for (Integer level = 1; level <= levelCount; level++)
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
                
                // run assertion
                System.assertEquals(exceptionThrown, true);       
            }
 
            // stop test
            Test.stopTest();
        }
    }
}