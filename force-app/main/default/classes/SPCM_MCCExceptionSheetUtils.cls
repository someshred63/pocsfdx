public class SPCM_MCCExceptionSheetUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (2);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('MCC_Exception_Sheet_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_MCC_Exception_Sheet__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('MCC_Exception_Sheet__c');
    }
    
    
    public String GetErrorsForLevel1(List<SPCM_Approval_Process_Level__c> processLevels)
    {
    	
        
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        //TODO: consider adding textbox in UI and execute this query:
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



    public String GetErrorsForLevel2(List<SPCM_Approval_Process_Level__c> processLevels)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        return null;
    }




    //add Team Segment field
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


    public String GetErrorsForLevel4(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  != 2)
            return 'There should be exactly two process levels. Currently: '+ processLevels.size();
        
        return null;

        // get level approvers and check for one max on each level
        List<String> approver1Ids = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
        List<String> approver2Ids = approvalMgr.GetProcessLevelRoleApprovers(processLevels[1]);
        if (approver1Ids.size() != 1 || approver2Ids.size() != 1)
        	return 'There should be one approver for each of two process levels. Currently: '
        		+ processLevels[0] + ': ' +approver1Ids.size() + ', ' +
        		processLevels[1] + ': ' +approver2Ids.size();
        return null;
    }

    public String GetErrorsForLevel5(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
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

    public String GetErrorsForLevel6(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        //TODO: consider adding textbox in UI and perform this check:
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


    public String GetErrorsForLevel7(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        // get process level approvers
        List<String> approverIds = approvalMgr.GetRoleApprovers('SPCM_MCC_Exception_Sheet__c', 7);
    
        // if there is not exactly one approver
        if (approverIds.size() != 1)
        	return 'There should be exactly one approver for this process level. Currently: ' + approverIds.size();

        return null;
    }

	public String GetErrorsForLevel8(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (processLevels.size()  != 1)
            return 'There should be exactly one process level. Currently: '+ processLevels.size();
        
        // get process level approvers
        List<String> approverIds = approvalMgr.GetRoleApprovers('SPCM_MCC_Exception_Sheet__c', 8);
    
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
        
            // get new and old records
            SPCM_MCC_Exception_Sheet__c newRecord = (SPCM_MCC_Exception_Sheet__c)newRecords[i];
            SPCM_MCC_Exception_Sheet__c oldRecord = (SPCM_MCC_Exception_Sheet__c)oldRecords[i];
         
            // set last approver
            newRecord.Last_Approver__c = UserInfo.getUserId();
  
            // set prior fields for use in custom history tracking
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
                    
                    // set approver and level
                    if (approverId != null && approverId != '')
                    {
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
                    
                    // if there is only one approver
                    if (approverIds.size() == 1)
                    {
                        
                        // set approver as original
                        String approverId = approverIds[0];
                        
                        // if approver not prior delegated approver
                        if (!priorDelApprs.contains(approverId))
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
                        if (!priorDelApprs.contains(approverId))
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
        
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = 
                    approvalMgr.GetProcessLevels(GetObjectType(), newRecord.Appr_Approval_Level__c);
                    
                // if there are two process levels
                if (processLevels.size() == 2)
                {
                
                    // get level approvers and check for one max on each level
                    List<String> approver1Ids = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                    List<String> approver2Ids = approvalMgr.GetProcessLevelRoleApprovers(processLevels[1]);
                    if (approver1Ids.size() == 1 && approver2Ids.size() == 1)
                    {
                    
                        // set approvers as original
                        String approver1Id = approver1Ids[0];
                        String approver2Id = approver2Ids[0];
                        newRecord.Appr_Approver_1_Original__c = approver1Id;
                        newRecord.Appr_Approver_2_Original__c = approver2Id;
        
                        // check for delegated approvers
                        approver1Id = GNE_UserDelegationUtils.GetDelegatedUser(approver1Id);
                        approver2Id = GNE_UserDelegationUtils.GetDelegatedUser(approver2Id);
                        
                        // set approvers and levels
                        newRecord.Appr_Approver_1__c = approver1Id;
                        newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                        newRecord.Appr_Approver_2__c = approver2Id;
                        newRecord.Appr_Approver_2_Process_Level__c = processLevels[1].Id;
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
            
                    // get process level approvers
                    List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                    
                    // if there is only one approver
                    if (approverIds.size() == 1)
                    {
                        
                        // set approver as original
                        String approverId = approverIds[0];
                        
                        // if approver not prior delegated approver
                        if (!priorDelApprs.contains(approverId))
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
                          insertSkippedRecord(newRecord, 'Level 5 – SPCM Executive Approval', approverId);

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
                            if (!priorDelApprs.contains(approverId))
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
                    
                    // if exception amount over threshold or if approval required
                    if (newRecord.Exception_Amount__c > processLevels[0].Low_Amount__c ||
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
                            if (!priorDelApprs.contains(approverId))
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
                               insertSkippedRecord(newRecord, 'Level 7 – MCCO Executive Approval', approverId);
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
                    
                    // if exception amount over threshold or if approval required
                    if (newRecord.Exception_Amount__c > processLevels[0].Low_Amount__c ||
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
                            if (!priorDelApprs.contains(approverId))
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
                            insertSkippedRecord(newRecord, 'Level 8 – Chief Executive Officer', approverId);
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
    //method to insert skipped record
private  void insertSkippedRecord(SPCM_MCC_Exception_Sheet__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.MCC_Exception_Sheet__c= newRecord.Id;
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
    private Map<Id, Id> GetLegalApproversMap()
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
            SPCM_MCC_Exception_Sheet__c newRecord = new SPCM_MCC_Exception_Sheet__c(
                Exception_Amount__c = 500000000, Team_Segment__c = 'Channel Strategy Management',
                Legal_Approver__c = testUtils.legalApprover.Id);
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_MCC_Exception_Sheet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_MCC_Exception_Sheet__c WHERE Id = :newRecord.Id];
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
                    RecordTypeId FROM SPCM_MCC_Exception_Sheet__c WHERE Id = :newRecord.Id];
                System.assertEquals(newRecords[0].Appr_Approver_1__c, (level == 1 ? testUtils.userManager.Id : 
                    testUtils.busRoleUser.Id));
                System.assertEquals(newRecords[0].RecordTypeId, testUtils.GetSObjectRecordTypeId(objectType, 'Editable'));
            }
          
            // update to simulate approval
            newRecord.Appr_Approval_Level__c = null;
            newRecord.Appr_Update_Date__c = null;
            newRecord.Approval_Status__c = 'Approved';
            update(newRecord);
            
            // refresh data and run assertions
            newRecords = [SELECT Appr_Approver_1__c, Appr_Prior_Approval_Level__c, Appr_Prior_Approver_1__c,
                RecordTypeId FROM SPCM_MCC_Exception_Sheet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_MCC_Exception_Sheet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_MCC_Exception_Sheet__c WHERE Id = :newRecord.Id];
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
            SPCM_MCC_Exception_Sheet__c newRecord = new SPCM_MCC_Exception_Sheet__c(
                Exception_Amount__c = 500000000, Team_Segment__c = 'Channel Strategy Management',
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
            SPCM_MCC_Exception_Sheet__c newRecord = new SPCM_MCC_Exception_Sheet__c(
                Exception_Amount__c = 500000000, Team_Segment__c = 'Channel Strategy Management',
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