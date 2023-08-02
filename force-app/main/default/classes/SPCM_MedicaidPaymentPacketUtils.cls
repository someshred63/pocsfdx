public class SPCM_MedicaidPaymentPacketUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('Medicaid_Payment_Packet_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_Medicaid_Payment_Packet__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('Medicaid_Payment_Packet__c');
    }

    public String GetErrorsForLevel1(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_Approval_Process_Level__c processLevel, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  <= 0)
            return 'There should be one or more process levels.';

        if (processLevel.Comments__c != null && processLevel.Comments__c.startsWith('Fast Track'))
            return null;

        // loop through process levels
        List<String> approverIds = new List<String>();
        List<String> processLevelIds = new List<String>();
        
        approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
        processLevelIds.add(processLevel.Id);
        // if there is exactly one approver and process level
        if (approverIds.size() != 1)
            return 'There should be exactly one approver. Currently :'+ approverIds.size();
        return null;
    }

    public Boolean ValidateFields(List<SPCM_Medicaid_Payment_Packet__c> records) {
        Double fastTrackApprovalAmount = 150000;
        SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
        SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager(roleConfig, processConfig);
        for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), 1)) {
            if (processLevel.Comments__c != null && processLevel.Comments__c.startsWith('Fast')) {
                fastTrackApprovalAmount = processLevel.High_Amount__c;
                break;
            }
        }
        
        for (SPCM_Medicaid_Payment_Packet__c record : records) {
            if (record.Approval_Amount__c <= fastTrackApprovalAmount) {
                record.Fast_Track__c = 'Yes';
            } else {
                record.Fast_Track__c = 'No';
            }
        }
        return true;
    }


    public String GetErrorsForLevel2(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_Approval_Process_Level__c processLevel, SPCM_ApprovalManager approvalMgr)
    {
        
         if(processLevels.size() <= 0)
            return 'There should be one or more process levels.';

        // loop through process levels
        List<String> approverIds = new List<String>();
        String processLevelId = '';
        
        approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
        processLevelId = processLevel.Id;
            
        

        // if there are approvers or there is a process level match
        if ((approverIds.size() > 0 || processLevelId != '') && approverIds.size() != 1)
            return 'There should be exacyly one approver. Currently: ' + approverIds.size();

        return null;
    }



    public String GetErrorsForLevel3456(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_Approval_Process_Level__c processLevel, SPCM_ApprovalManager approvalMgr)
    {
        
         if(processLevels.size() != 1)
            return 'There should be exactly one process level. Currently: ' + processLevels.size();

         // get role approvers
        List<String> approverIds = approvalMgr.GetRoleApprovers('SPCM_Medicaid_Payment_Packet__c', processLevel.Level_Number__c);
        
        if (approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();

        return null;
    }

    
    // method to handle approval events (triggered by current approval level field update)
    protected override void HandleApprovalEvents(List<SObject> newRecords, 
        List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig, 
        GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr)
    {

        // state/region map
        Map<String, String> stateRegionMap = null;

        // loop through records
        for (integer i = 0; i < newRecords.size(); i++)
        {
        
            // get new record
            SPCM_Medicaid_Payment_Packet__c newRecord = (SPCM_Medicaid_Payment_Packet__c)newRecords[i];
            SPCM_Medicaid_Payment_Packet__c oldRecord = (SPCM_Medicaid_Payment_Packet__c)oldRecords[i];

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
String fAppid;

            if (newRecord.Fast_Track__c == 'Yes') {
                if (newRecord.Appr_Approval_Level__c == 1)
                {
                    Double Amount;
                    // update initiated by
                    newRecord.Initiated_By__c = UserInfo.getUserId();


                    // initialize state/region map if not yet initialized
                    if (stateRegionMap == null)
                    {
                        stateRegionMap = InitializeStateRegionMap();
                    }

                    // get region id
                    String regionId = stateRegionMap.get(newRecord.State__c+'_ft');


                    // get process levels
                    List<SPCM_Approval_Process_Level__c> processLevels = new List<SPCM_Approval_Process_Level__c>();
                    for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), newRecord.Appr_Approval_Level__c)) {
                        if (processLevel.Comments__c != null && processLevel.Comments__c.startsWith('Fast Track')) {
                            processLevels.add(processLevel);
                        }
                    }

                    // if region found and there are process levels
                    if (regionId != null && regionId != '' && processLevels.size() > 0)
                    {

                        // loop through process levels
                        List<String> approverIds = new List<String>();
                        List<String> processLevelIds = new List<String>();

                        for (SPCM_Approval_Process_Level__c processLevel : processLevels)
                        {

                            Amount=processLevel.High_Amount__c;
                            // check region against process level region
                            if (regionId == processLevel.Region__c)
                            {

                                // get process level approvers
                                approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                                processLevelIds.add(processLevel.Id);
                            }
                        }

                        // if there is exactly one approver and process level
                        if (approverIds.size() == 1 && processLevelIds.size() == 1)
                        {

                            // get approver and process level
                            String approverId = approverIds[0];
                            String processLevelId = processLevelIds[0];

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
            } else {

            // if approval level 1
            if (newRecord.Appr_Approval_Level__c == 1)
            {
               Double Amount;
                // update initiated by
                newRecord.Initiated_By__c = UserInfo.getUserId();
                
                
                // initialize state/region map if not yet initialized
                if (stateRegionMap == null)
                {
                    stateRegionMap = InitializeStateRegionMap();
                }
   
                // get region id
                String regionId = stateRegionMap.get(newRecord.State__c);
                

                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = new List<SPCM_Approval_Process_Level__c>();
                for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), newRecord.Appr_Approval_Level__c)) {
                    if (processLevel.Comments__c != null && !processLevel.Comments__c.startsWith('Fast Track')) {
                        processLevels.add(processLevel);
                    }
                }
                
                // if region found and there are process levels
                if (regionId != null && regionId != '' && processLevels.size() > 0)
                {
                    
                    // loop through process levels
                    List<String> approverIds = new List<String>();
                    List<String> processLevelIds = new List<String>();
                    
                    for (SPCM_Approval_Process_Level__c processLevel : processLevels)
                    {
                           
                         Amount=processLevel.High_Amount__c;
                        // check region against process level region
                        if (regionId == processLevel.Region__c)
                        {
                        
                            // get process level approvers
                            approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                            processLevelIds.add(processLevel.Id);
                        }
                    }
                    
                    // if there is exactly one approver and process level
                    if (approverIds.size() == 1 && processLevelIds.size() == 1)
                    {
                        
                        // get approver and process level
                        String approverId = approverIds[0];
                        String processLevelId = processLevelIds[0];

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
                
                // if levels exist
                if (processLevels.size() > 0)
                {
                    
                    // loop through process levels
                    List<String> approverIds = new List<String>();
                    String processLevelId = '';
                    for (SPCM_Approval_Process_Level__c processLevel : processLevels)
                    {
                    
                        // get Level 2 medicaid list from level
                        Set<String> StatesLevel2 = new Set<String>();
                        for (String Statesl2 : processLevel.Medicaid_States__c.split(';'))
                        {
                            StatesLevel2.add(Statesl2);
                        }
                        
                        // if process level contains contract type
                        if (StatesLevel2.contains(newRecord.State__c))
                        {
                        
                            
                          if (newRecord.Approval_Amount__c >processLevel.Low_Amount__c)
                           {
                             approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                                processLevelId = processLevel.Id;
                           }
                        
                        }
                    }
                    // if there are approvers or there is a process level match
                    if (approverIds.size() > 0 || processLevelId != '')
                    {
                    
                        // if there is only one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverid!=newRecord.Last_Approver__c &&approverid!=newRecord.Appr_Prior_Approver_1_Original__c)
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
                        
                           
                                 insertSkippedRecord1(newRecord, 'Level 2 - Approval', newRecord.Last_Approver__c);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                           
                          /*else if(approverId == priorDelAppr)
                            {
                                insertSkippedRecord(newRecord, 'Level 2 - Approval', approverId);
                                // skip step
                                newRecord.Appr_Approval_Level__c += 1;
                            }*/
                          
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
                    if (newRecord.Approval_Amount__c > processLevels[0].Low_Amount__c)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver and process level
                            String approverId = approverIds[0];
                            String processLevelId = processLevels[0].Id;
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and process level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                            }
                            else
                            {
                               insertSkippedRecord(newRecord, 'Level 3 -  SPCM Medicaid Associate Director Approval', approverId);
                                
                            
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
                    if (newRecord.Approval_Amount__c > processLevels[0].Low_Amount__c)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver and process level
                            String approverId = approverIds[0];
                            String processLevelId = processLevels[0].Id;
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and process level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                            }
                            else
                            {
                               insertSkippedRecord(newRecord, 'Level 4 - Medicaid Executive Approval', approverId);
                                
                            
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
                    if (newRecord.Approval_Amount__c > processLevels[0].Low_Amount__c)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver and process level
                            String approverId = approverIds[0];
                            String processLevelId = processLevels[0].Id;
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and process level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                            }
                            else
                            {
                            
                               insertSkippedRecord(newRecord, 'Level 5 - SPCM Executive Approval', approverId);

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
                    if (newRecord.Approval_Amount__c > processLevels[0].Low_Amount__c)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver and process level
                            String approverId = approverIds[0];
                            String processLevelId = processLevels[0].Id;
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and process level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                            }
                            else
                            {
                            insertSkippedRecord(newRecord, 'Level 6 - MCCO Executive Approval', approverId);
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
                    if (newRecord.Approval_Amount__c > processLevels[0].Low_Amount__c)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetRoleApprovers(GetObjectType(), 
                            newRecord.Appr_Approval_Level__c);
                        
                        // if there is exactly one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver and process level
                            String approverId = approverIds[0];
                            String processLevelId = processLevels[0].Id;
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and process level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                            }
                            else
                            {
                            insertSkippedRecord(newRecord, 'Level 7 - Chief Executive Officer Approval', approverId);
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
    }
    
    
      private  void insertSkippedRecord(SPCM_Medicaid_Payment_Packet__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.Medicaid_Payment_Packet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c=apprId;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                  newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                  dateTime myDate = dateTime.now(); 
                                newHistoryRecord.End_Date__c= myDate+0.00005;
                               newHistoryRecord.Comments__c='Auto approved due to delegation';
                                insert newHistoryRecord;
                                

    }

  private  void insertSkippedRecord1(SPCM_Medicaid_Payment_Packet__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.Medicaid_Payment_Packet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c=apprId;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                  newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                  dateTime myDate = dateTime.now(); 
                                newHistoryRecord.End_Date__c= myDate+0.00005;
                               newHistoryRecord.Comments__c='Auto approved as previous approver is same as current level approver';
                                insert newHistoryRecord;
                                

    }
private  void insertAutoApprovalRecord(SPCM_Medicaid_Payment_Packet__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.Medicaid_Payment_Packet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c=apprId;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                  newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                  dateTime myDate = dateTime.now(); 
                                newHistoryRecord.End_Date__c= myDate+0.00005;
                               newHistoryRecord.Comments__c='Auto approval - Yes';
                                insert newHistoryRecord;
                                

    }
    // return a map of state/region
    public Map<String, String> InitializeStateRegionMap()
    {
    
        // declaration(s)
        Map<String, String> stateRegionMap = new Map<String, String>();
        
        // loop through states and add to map
        for (SPCM_State__c record : [SELECT Id, State_Abbreviation__c, Region__c FROM SPCM_State__c])
        {
            stateRegionMap.put(record.State_Abbreviation__c, record.Region__c);
        }
        
        // return state/region map
        return (stateRegionMap);    
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
            SPCM_Medicaid_Payment_Packet__c newRecord = new SPCM_Medicaid_Payment_Packet__c(
                Approval_Amount__c = 500000000, State__c = testUtils.state.State_Abbreviation__c);
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_Medicaid_Payment_Packet__c> newRecords = [SELECT Appr_Approver_1__c, State__c,
                RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assertEquals(newRecords.size(), 1);
            System.assertEquals(newRecord.State__c, 'TST_ST');
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
                    RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
                System.assertEquals(newRecords[0].Appr_Approver_1__c, testUtils.busRoleUser.Id);
                System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            }
          
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
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
            SPCM_Medicaid_Payment_Packet__c newRecord = new SPCM_Medicaid_Payment_Packet__c(
                Approval_Amount__c = 500000000);
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_Medicaid_Payment_Packet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assertNotEquals(newRecords[0].Id, null);
            System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            
            // update to simulate level 2
            newRecord.Appr_Approval_Level__c = 2;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // update original approver to simulate delegation skips
            newRecord.Appr_Approver_1_Original__c = testUtils.userManager.Id;
            update(newRecord);
            
            // update to simulate levels with delegation skips
            newRecord.Appr_Approval_Level__c = 3;
            newRecord.Appr_Update_Date__c = DateTime.now();
            newRecord.Approval_Status__c = 'Submitted for Approval';
            newRecord.Submitted_Date__c = Date.today();
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_Medicaid_Payment_Packet__c WHERE Id = :newRecord.Id];
            System.assertEquals(newRecords[0].Appr_Approver_1__c, null);
            
            // update to simulate level 3
            newRecord.Approval_Amount__c = 5;
            newRecord.Appr_Approval_Level__c = 3;
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
            SPCM_Medicaid_Payment_Packet__c newRecord = new SPCM_Medicaid_Payment_Packet__c(
                Approval_Amount__c = 500000000);
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
            SPCM_Medicaid_Payment_Packet__c newRecord = new SPCM_Medicaid_Payment_Packet__c(
                Approval_Amount__c = 500000000);
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