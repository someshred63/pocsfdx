public class SPCM_GPPaymentPacketUtils extends SPCM_eWorkflowBaseUtils
{
    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('GP_Payment_Packet_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_GP_Payment_Packet__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('GP_Payment_Packet__c');
    }
    
    public String GetErrorsForLevel12345(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr, Integer levelNumber)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        // get role approvers
        List<String> approverIds = approvalMgr.GetRoleApprovers('SPCM_GP_Payment_Packet__c', levelNumber);
        
        // if there is exactly one approver
        if (approverIds.size() != 1)
        	return 'There should be exactly one approver. Currently: '+ approverIds.size();
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
            SPCM_GP_Payment_Packet__c newRecord = (SPCM_GP_Payment_Packet__c)newRecords[i];
            SPCM_GP_Payment_Packet__c oldRecord = (SPCM_GP_Payment_Packet__c)oldRecords[i];
 
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

            // get prior approver
            String priorAppr = newRecord.Appr_Prior_Approver_1__c;
            
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
                
                    // get role approvers
                    List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                    
                    // if there is exactly one approver
                    if (approverIds.size() == 1)
                    {
                        
                        // get approver
                        String approverId = approverIds[0];
    
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
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                    
                // if there is exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approved amount against threshold
                    if (newRecord.Approved_Amount__c > processLevels[0].Low_Amount__c)
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
                            if (approverId == priorDelAppr || priorAppr == approverId)
                            {
                                String comment = priorDelAppr == approverId ?
                                        'Auto approved due to delegation' :
                                        'Auto approved as the previous approver is same as current level approver';
                                insertSkippedRecord(newRecord, 'Level 2 - GP Payment - Group Manager Approval', approverId, comment);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }
                            else
                            {
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;

                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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
            // approval level 3
            if (newRecord.Appr_Approval_Level__c == 3)
            {
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                    
                // if there is exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approved amount against threshold
                    if (newRecord.Approved_Amount__c > processLevels[0].Low_Amount__c)
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
                            if (approverId == priorDelAppr || priorAppr == approverId)
                            {
                                String comment = priorDelAppr == approverId ?
                                        'Auto approved due to delegation' :
                                        'Auto approved as the previous approver is same as current level approver';
                                insertSkippedRecord(newRecord, 'Level 3 - GP Associate Director Approval', approverId, comment);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }
                            else
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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
            // approval level 4
            if (newRecord.Appr_Approval_Level__c == 4)
            {
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                    
                // if there is exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approved amount against threshold
                    if (newRecord.Approved_Amount__c > processLevels[0].Low_Amount__c)
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
                            if (approverId == priorDelAppr || priorAppr == approverId)
                            {
                                String comment = priorDelAppr == approverId ?
                                        'Auto approved due to delegation' :
                                        'Auto approved as the previous approver is same as current level approver';
                                insertSkippedRecord(newRecord, 'Level 4 - GP Executive Approval', approverId, comment);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }
                            else
                            {

                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;

                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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
            // approval level 5
            if (newRecord.Appr_Approval_Level__c == 5)
            {

                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(),
                    newRecord.Appr_Approval_Level__c);

                // if there is exactly one process level
                if (processLevels.size() == 1)
                {

                    // check approved amount against threshold
                    if (newRecord.Approved_Amount__c > processLevels[0].Low_Amount__c)
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
                            if (approverId == priorDelAppr || priorAppr == approverId)
                            {
                                String comment = priorDelAppr == approverId ?
                                        'Auto approved due to delegation' :
                                        'Auto approved as the previous approver is same as current level approver';
                                insertSkippedRecord(newRecord, 'Level 5 - SPCM Executive Approval', approverId, comment);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }
                            else
                            {

                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;

                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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
            // approval level 6
            if (newRecord.Appr_Approval_Level__c == 6)
            {

                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(),
                        newRecord.Appr_Approval_Level__c);

                // if there is exactly one process level
                if (processLevels.size() == 1)
                {

                    // check approved amount against threshold
                    if (newRecord.Approved_Amount__c > processLevels[0].Low_Amount__c)
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
                            if (approverId == priorDelAppr || priorAppr == approverId)
                            {
                                String comment = priorDelAppr == approverId ?
                                        'Auto approved due to delegation' :
                                        'Auto approved as the previous approver is same as current level approver';
                                insertSkippedRecord(newRecord, 'Level 6 - MCCO Executive Approval', approverId, comment);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }
                            else
                            {

                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;

                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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
            // approval level 7
            if (newRecord.Appr_Approval_Level__c == 7)
            {
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                    
                // if there is exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approved amount against threshold
                    if (newRecord.Approved_Amount__c > processLevels[0].Low_Amount__c)
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
                            if (approverId == priorDelAppr || priorAppr == approverId)
                            {
                                String comment = '';
                                if (priorDelAppr == approverId) {
                                    comment = 'Auto approved due to delegation';
                                } else {
                                    comment = 'Auto approved as the previous approver is same as current level approver';
                                }

                                insertSkippedRecord(newRecord, 'Level 7 - Chief Executive Officer Approval', approverId, comment);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }
                            else
                            {

                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;

                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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

           /* // if approval level 6
          //As part of M & E this level has been deleted
            if (newRecord.Appr_Approval_Level__c == 6)
            {
                
                // check for single process level
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                if (processLevels.size() == 1)
                {
                
                    // get role approvers
                    List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                        newRecord.Appr_Approval_Level__c);
                    
                    // if there is exactly one approver
                    if (approverIds.size() == 1)
                    {
                        
                        // get approver
                        String approverId = approverIds[0];
    
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
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, 
                            newRecord.Appr_Approval_Level__c));
                    }
                }
                else
                {
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, 
                            newRecord.Appr_Approval_Level__c));
                }
            }*/
            
            
        }
    }
    private  void insertSkippedRecord(SPCM_GP_Payment_Packet__c newRecord,String apprLevel,String apprId, String comment)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.GP_Payment_Packet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c = newRecord.Last_Approver__c;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                 newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                 dateTime myDate = dateTime.now();
                                 newHistoryRecord.End_Date__c= myDate+0.00005;
                                newHistoryRecord.Comments__c=comment;
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
            SPCM_GP_Payment_Packet__c newRecord = new SPCM_GP_Payment_Packet__c(
                Approved_Amount__c = 500000000);
            insert(newRecord);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_GP_Payment_Packet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate level 2
            newRecord.Appr_Approval_Level__c = 2;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 1);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate level 3
            newRecord.Appr_Approval_Level__c = 3;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 2);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));

            // update to simulate level 4
            newRecord.Appr_Approval_Level__c = 4;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 3);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate level 5
            newRecord.Appr_Approval_Level__c = 5;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 4);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == testUtils.busRoleUser.Id);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 5);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == null);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate rejection
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Rejected';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 5);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == null);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'ReadOnly'));
            
            // update to simulate recalled
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Recalled';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Appr_Prior_Approval_Level__c == 5);
            System.assert(newRecords[0].Appr_Prior_Approver_1__c == String.valueOf(testUtils.busRoleUser.Id));
            System.assert(newRecords[0].Appr_Approver_1__c == null);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // stop test
            Test.stopTest();
            
            // delete record
            delete(newRecord);
        }
    }
    
    // test method for code coverage
    static testMethod void runSkipTests()
    {
    
        // create test utility class
        SPCM_TestUtils testUtils = new SPCM_TestUtils();
        
        // run as analyst
        System.runAs(testUtils.userAnalyst)
        {
        
            // start test
            Test.startTest();
        
            // create test record
            SPCM_GP_Payment_Packet__c newRecord = new SPCM_GP_Payment_Packet__c(
                Approved_Amount__c = 500000000);
            insert(newRecord);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_GP_Payment_Packet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_GP_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assert(newRecords[0].Id != null);
            System.assert(newRecords[0].RecordTypeId == testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate level 1
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // update original approver to simulate delegation skips
            newRecord.Appr_Approver_1_Original__c = testUtils.userAnalyst.Id;
            update(newRecord);
            
            // update to simulate level delegation skips
            newRecord.Appr_Approval_Level__c = 2;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // update to simulate level 1
            newRecord.Approved_Amount__c = 5;
            newRecord.Appr_Approval_Level__c = 1;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // update to simulate level threshold skips
            newRecord.Appr_Approval_Level__c = 2;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // stop test
            Test.stopTest();
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
            SPCM_GP_Payment_Packet__c newRecord = new SPCM_GP_Payment_Packet__c(
                Approved_Amount__c = 100000000);
            insert(newRecord);
            
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
                System.assert(exceptionThrown);       
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
            SPCM_GP_Payment_Packet__c newRecord = new SPCM_GP_Payment_Packet__c(
                Approved_Amount__c = 100000000);
            insert(newRecord);
            
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
                System.assert(exceptionThrown);       
            }
 
            // stop test
            Test.stopTest();
        }
    }
}