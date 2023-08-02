public class SPCM_MCCApprovalSheetUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('MCC_Approval_Sheet_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_MCC_Approval_Sheet__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('MCC_Approval_Sheet__c');
    }

    public String GetErrorsForLevel1(List<SPCM_Approval_Process_Level__c> processLevels)
    {
        
        
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        //check if manager exists
        /*
        if (! string.isblank(username))
        {
            List<User> userId = [select id from User where external_id_gne__c like :username];
            String managerId = approvalMgr.GetUserManagerId(userId);
            if (managerId != null && managerId != '')
                return 'There is no manager for user ' + username + ' defined.';
        }
        */
        return null;
    }

    public String GetErrorsForLevel3(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_Approval_Process_Level__c processLevel, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  == 0)
            return 'There is no process level defined for this level number.';
        
        List<String> approverIds = new List<String>();
        approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
        if (approverIds.size() != 1)
            return 'There should be exactly one approver for this process level. Currently: ' + approverIds.size();

        return null;
    }






    public String GetErrorsForLevel5(List<SPCM_Approval_Process_Level__c> processLevels)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();

        return null;
    }

    public String GetErrorsForLevel6(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        //check if legal approver exists
        /*
        if (!string.isBlank(legalApprover))
        {
            public Map<Id, Id> approversMap = GetLegalApproversMap();
            String approverId = legalApproverMap.get(legalApprover);
            // if there is exactly one approver
            if (approverId != null && approverId != '')
                return 'There should be exactly one approver for this process level. Currently: ' + approverIds.size();
        }
        */
        
        return null;
    }


    public String GetErrorsForLevel2478(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        // get process level approvers
        List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
    
        // if there is not exactly one approver
        if (approverIds.size() != 1)
            return 'There should be exactly one approver for this process level. Currently: ' + approverIds.size();

        return null;
    }

    // method to handle approval events (triggered by current approval level field update)
    protected override void HandleApprovalEvents(List<SObject> newRecords, 
        List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig, 
        GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr)
    {

        // legal approver map
        Map<Id, Id> legalApproverMap = null;

        // loop through records
        for (integer i = 0; i < newRecords.size(); i++)
        {
        
            // get new record and old records
            SPCM_MCC_Approval_Sheet__c newRecord = (SPCM_MCC_Approval_Sheet__c)newRecords[i];
            SPCM_MCC_Approval_Sheet__c oldRecord = (SPCM_MCC_Approval_Sheet__c)oldRecords[i];
        
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

            // get prior delegated approver
            String priorDelAppr = newRecord.Appr_Prior_Approver_1__c == newRecord.Appr_Prior_Approver_1_Original__c ?
                null : newRecord.Appr_Prior_Approver_1__c;

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

                    // get manager approver
                    String approverId = approvalMgr.GetUserManagerId(newRecord.Initiated_By__c);
                    if (approverId != null && approverId != '')
                    {
                    
                        // set as original approver
                        newRecord.Appr_Approver_1_Original__c = approverId;
                        
                        // check for delegated approver
                        approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                        
                        // set approver and level
                        newRecord.Appr_Approver_1__c = approverId;
                        newRecord.Appr_Approver_1_Process_Level__c = 
                            approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c);
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
            // approval level 2
            if (newRecord.Appr_Approval_Level__c == 2)
            {
                
                // check for single process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                    
                    // get process level approvers
                    List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                
                    // if there is exactly one approver
                    if (approverIds.size() == 1)
                    {
                        
                        // get approver
                        String approverId = approverIds[0];
    
                        // if approver not prior delegated approver
                        if (approverId != priorDelAppr)
                        {
                        
                            // set approver as original
                            newRecord.Appr_Approver_1_Original__c = approverId;
            
                            // check for delegated approver
                            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
        
                            // set approver and level
                            newRecord.Appr_Approver_1__c = approverId;
                            newRecord.Appr_Approver_1_Process_Level__c = 
                                approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c);
                        }
                        else
                        {
                        

                            insertSkippedRecord(newRecord, 'Level 2 - MCC Executive Approval', approverId);
                            // skip level
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
            // approval level 3
            if (newRecord.Appr_Approval_Level__c == 3)
            {
                
                // if team segment defined
                if (newRecord.Team_Segment__c != 'N/A')
                {
                
                    // loop through process levels
                    List<String> approverIds = new List<String>();
                    String processLevelId = '';
                    for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c))
                    {
                        
                        // if account team matches
                        if (processLevel.Account_Team__c == newRecord.Team_Segment__c)
                        {
                        
                            // add process level approvers
                            approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                            processLevelId = processLevel.Id;
                        }
                    }
                
                    // if there is exactly one approver
                    if (approverIds.size() == 1)
                    {

                        // get approver
                        String approverId = approverIds[0];
                        
                        // if approver not prior delegated approver
                        if (approverId != priorDelAppr)
                        {
                        
							// set approver as original
							newRecord.Appr_Approver_1_Original__c = approverId;
            
							// check for delegated approver
							approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
        
							// set approver and level
                            newRecord.Appr_Approver_1__c = approverId;
                            newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                        }
                        else
                        {
                        
                                if (newRecord.Team_Segment__c =='Customer Operations')
                                {

                                insertSkippedRecord(newRecord, 'Level 3 - Customer Operations Executive Approval', approverId);

                                }
                                else if (newRecord.Team_Segment__c =='Access Solutions')
                               {

                                insertSkippedRecord(newRecord, 'Level 3 - Access Solutions Executive Approval', approverId);

                                }
                                else if (newRecord.Team_Segment__c == 'Access & Channel Management')
                                {
                                insertSkippedRecord(newRecord, 'Level 3 - Access & Channel Mgmt Executive Approval', approverId);
                            }
                                
                            // skip level
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
                
                    // skip level
                    newRecord.Appr_Approval_Level__c += 1;
                }
            }
            // approval level 4
            if (newRecord.Appr_Approval_Level__c == 4)
            {
                
                // check for single process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                
                    // get process level approvers
                    List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                
                    // if there is exactly one approver
                    if (approverIds.size() == 1)
                    {
                        
                        // get approver
                        String approverId = approverIds[0];
                        
                        // if approver not prior delegated approver
                        if (approverId != priorDelAppr)
                        {
                        
                            // set approver as original
                            newRecord.Appr_Approver_1_Original__c = approverId;
            
                            // check for delegated approver
                            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
        
                            // set approver and level
                            newRecord.Appr_Approver_1__c = approverId;
                            newRecord.Appr_Approver_1_Process_Level__c = 
                                approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c);
                        }
                        else
                        {
                        
                            insertSkippedRecord(newRecord, 'Level 4 - SPCM Executive Approval', approverId);
                            // skip level
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
            // approval level 5
            if (newRecord.Appr_Approval_Level__c == 5)
            {
                
                // check for single process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                
                    // get approver
                    String approverId = newRecord.Initiated_By__c;
                    
                    // if there is exactly one approver
                    if (approverId != null && approverId != '')
                    {
                    
                        // set approver as original
                        newRecord.Appr_Approver_1_Original__c = approverId;
        
                        // set approver and level
                        newRecord.Appr_Approver_1__c = approverId;
                        newRecord.Appr_Approver_1_Process_Level__c = 
                            approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c);
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
            // approval level 6
            if (newRecord.Appr_Approval_Level__c == 6)
            {
                
                // if legal approver specified
                if (newRecord.Legal_Approver__c != null)
                {
                
                    // check for single process level
                    List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                    if (processLevels.size() == 1)
                    {
            
                        // initialize legal approver map if not yet initialized
                        if (legalApproverMap == null)
                        {
                            legalApproverMap = GetLegalApproversMap();
                        }
                    
                        // get approver
                        String approverId = legalApproverMap.get(newRecord.Legal_Approver__c);
                        
                        // if there is exactly one approver
                        if (approverId != null && approverId != '')
                        {
                        
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = 
                                    approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c);
                            }
                            else
                            {
                               insertSkippedRecord(newRecord, 'Level 6 - Managed Care Legal Approval', approverId);
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
                else
                {
                
                    // skip step
                    newRecord.Appr_Approval_Level__c += 1;
                }
            }
            // approval level 7
            if (newRecord.Appr_Approval_Level__c == 7)
            {
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                    
                // if there is exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // if proposed payments over threshold or if approval required
                    if (newRecord.Proposed_Payment__c > processLevels[0].Low_Amount__c ||
                        newRecord.Require_MCCO_Executive_Approval__c == 'Yes')
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                            }
                            else
                            {
                            insertSkippedRecord(newRecord, 'Level 7 � MCCO Executive Approval', approverId);
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
            // approval level 8
            if (newRecord.Appr_Approval_Level__c == 8)
            {                
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                    
                // if there is exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // if proposed payments over threshold or if approval required
                    if (newRecord.Proposed_Payment__c > processLevels[0].Low_Amount__c ||
                        newRecord.Require_CEO_Approval__c == 'Yes')
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                            }
                            else
                            {
                            insertSkippedRecord(newRecord, 'Level 8 � Chief Executive Officer Approval', approverId);
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
            
        }

        
    }

   private  void insertSkippedRecord(SPCM_MCC_Approval_Sheet__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.MCC_Approval_Sheet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c=apprId;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                  newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                  dateTime myDate = dateTime.now();
                                  
                                  newHistoryRecord.End_Date__c= myDate+0.00005;
                                  newHistoryRecord.Comments__c='Auto approved due to delegation';
                                insert newHistoryRecord;
                                

    }
    // returns map for legal approvers
    public Map<Id, Id> GetLegalApproversMap()
    {
    
        // declaration(s)
        Map<Id, Id> legalApproverMap = new Map<Id, Id>();
        
        // loop through legal approvers and add to map
        for (SPCM_Legal_Approver__c record : [SELECT Id, User__c FROM SPCM_Legal_Approver__c])
        {
            legalApproverMap.put(record.Id, record.User__c);
        }
        
        // return legal approver map
        return (legalApproverMap);
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
            SPCM_MCC_Approval_Sheet__c newRecord = new SPCM_MCC_Approval_Sheet__c(
                Proposed_Payment__c = 500000000, Team_Segment__c = 'Channel Strategy Management',
                Legal_Approver__c = testUtils.legalApprover.Id);
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_MCC_Approval_Sheet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_MCC_Approval_Sheet__c WHERE Id = :newRecord.Id];
            System.assertEquals(newRecords.size(), 1);
            System.assertNotEquals(newRecords[0].Id, null);
            System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
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
                newRecords = [SELECT Appr_Approver_1__c,
                    RecordTypeId FROM SPCM_MCC_Approval_Sheet__c WHERE Id = :newRecord.Id];
                System.assertEquals(newRecords[0].Appr_Approver_1__c, (level == 1 ? testUtils.userManager.Id : 
                    (level == 5 ? testUtils.userAnalyst.Id : testUtils.busRoleUser.Id)));
                System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            }
          
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_MCC_Approval_Sheet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_MCC_Approval_Sheet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_MCC_Approval_Sheet__c WHERE Id = :newRecord.Id];
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
            SPCM_MCC_Approval_Sheet__c newRecord = new SPCM_MCC_Approval_Sheet__c(
                Proposed_Payment__c = 500000000, Team_Segment__c = 'Channel Strategy Management',
                Legal_Approver__c = testUtils.legalApprover.Id);
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
            
            // remove process level roles/users
            testUtils.RemoveApprovalProcessRolesAndUsers(objectType);

            // update analyst AUH to remove manager
            testUtils.analystAUH.All_User_Hierarchy_Level1_gne__c = null;
            update(testUtils.analystAUH);

            // remove user manager
            //testUtils.userAnalyst.ManagerId = null;
            //update(testUtils.userAnalyst);
            
            // remove legal user
            testUtils.legalApprover.User__c = null;
            update(testUtils.legalApprover);
            
            // remove initiator
            newRecord.Initiated_By__c = null;
            update(newRecord);

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
                System.assertEquals(exceptionThrown, true);
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
            SPCM_MCC_Approval_Sheet__c newRecord = new SPCM_MCC_Approval_Sheet__c(
                Proposed_Payment__c = 500000000, Team_Segment__c = 'Channel Strategy Management',
                Legal_Approver__c = testUtils.legalApprover.Id);
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