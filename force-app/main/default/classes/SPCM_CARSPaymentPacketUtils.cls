public class SPCM_CARSPaymentPacketUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    protected override String GetEmailRecallTemplate()
    {
        return ('CARS_Payment_Packet_Recalled');
    }
    protected override String GetObjectType()
    {
        return ('SPCM_CARS_Payment_Packet__c');
    }
    protected override String GetHistoryKeyField()
    {
        return ('CARS_Payment_Packet__c');
    }

    public Boolean ValidateFields(List<SPCM_CARS_Payment_Packet__c> records) {
    	List<SPCM_CARS_Payment_Packet__c> fastTrackPayments = new List<SPCM_CARS_Payment_Packet__c>();
    	for (SPCM_CARS_Payment_Packet__c record : records) {
    		if (record.Fast_Track__c == 'Yes') {
    			fastTrackPayments.add(record);
    		}
    	}
    	
    	if (!fastTrackPayments.isEmpty()) {
 			SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
            GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager(roleConfig, processConfig);
 		 
 		 	for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), 1)) {
            	if (processLevel.Comments__c == 'Fast Track') {
            		for (SPCM_CARS_Payment_Packet__c record : fastTrackPayments) {
            			if (record.Approval_Amount__c > processLevel.High_Amount__c || record.Approval_Amount__c < processLevel.High_Amount__c * -1) {
            				record.addError('Approval Amount exceeded the threshold for Fast Track Approval');
            				return false;
            			}
            		}
            		break;
            	}
            }
 		}
    	return true;
    }
	
   private Boolean isCoPay = false;
   public String GetErrorsForLevel1(String level1Approver, List<SPCM_Approval_Process_Level__c> approvalProcessLevels ) {
        String approverId = '';
        Map<Id, Id> approverMap = null;
        
        List<SPCM_Approval_Process_Level__c> processLevels = new List<SPCM_Approval_Process_Level__c>(); 
        for (SPCM_Approval_Process_Level__c processLevel : approvalProcessLevels ) {
        	if (processLevel.Comments__c != 'Fast Track') {
        		processLevels.add(processLevel);
        	}
        }
        
        // if there is one process level and a approver selected
        if (level1Approver == null || processLevels.size() != 1) {
            return 'There should be only one process level for this level number! Currently: ' + processLevels.size();
        }
        // initialize approver map
        if (approverMap == null) {
            approverMap = InitializeApproverMap();
        }
        // get approver from map
        approverId = approverMap.get(level1Approver);
        // if there is only one approver
        if (approverId == null || approverId == '') {
            return 'There should be only one approver!';
        }
        return null;
   }

    public String GetErrorsForLevel2(String level2Approver, List<SPCM_Approval_Process_Level__c> processLevels ) {  
        String approverId = '';
        Map<Id, Id> approverMap = null;
        // if there is one process level and a approver selected
        if (level2Approver == null || processLevels.size() != 1) {
            return 'There should be only one process level for this level number! Currently: ' + processLevels.size();
        }
        // initialize approver map
        if (approverMap == null) {
            approverMap = InitializeLevel2ApproverMap();
        }
        // get approver from map
        approverId = approverMap.get(level2Approver);
        // if there is only one approver
        if (approverId == null || approverId == '') {
            return 'There should be only one approver!';
        }
        return null;
    }
    
    public String GetErrorsForLevel2(String contractType, List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (contractType == null) {
            contractType = '';
        }
        String processLevelIdRef = '';
        List<String> approverIds = new List<String>();
        
        // if levels exist
        if (processLevels.size() <= 0)
            return 'Process Level doesn\'t exist.';

        // loop through process levels
        for (SPCM_Approval_Process_Level__c processLevel : processLevels)
        {
            // get contract types list from level
            Set<String> contractTypes = new Set<String>();
            for (String c : processLevel.Contract_Type__c.split(';'))
            {
                contractTypes.add(c);
            }
            
            // if process level contains contract type
            if (contractTypes.contains(contractType))
            {
            
                // add approvers
                approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                processLevelIdRef = processLevel.Id;
                
            }
        }
        
        if ((approverIds.size() > 0 || processLevelIdRef != '') && approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();

        return null;
    }
    
    public String GetErrorsForLevel3(String level3Approver, List<SPCM_Approval_Process_Level__c> processLevels ) {  
        String approverId = '';
        Map<Id, Id> approverMap = null;
        // if there is one process level and a approver selected
        if (level3Approver == null || processLevels.size() != 1) {
            return 'There should be only one process level for this level number! Currently: ' + processLevels.size();
        }
        // initialize approver map
        if (approverMap == null) {
            approverMap = InitializeLevel3ApproverMap();
        }
        // get approver from map
        approverId = approverMap.get(level3Approver);
        // if there is only one approver
        if (approverId == null || approverId == '') {
            return 'There should be only one approver!';
        }
        return null;
    }

    public String GetErrorsForLevel3(String contractType, List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        String processLevelIdRef = '';
        List<String> approverIds = new List<String>();

        
        // if levels exist
        if (processLevels.size() <= 0)
            return 'Process Level doesn\'t exist.';

        // loop through process levels
        for (SPCM_Approval_Process_Level__c processLevel : processLevels)
        {
            // get contract types list from level
            Set<String> contractTypes = new Set<String>();
            for (String c : processLevel.Contract_Type__c.split(';'))
            {
                contractTypes.add(c);
            }
            
            // if process level contains contract type
            if (contractTypes.contains(contractType))
            {
                    // add approvers
                    approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                    processLevelIdRef = processLevel.Id;
            }
        }
        
        if ((approverIds.size() > 0 || processLevelIdRef != '') && approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();

        return null;
    }

    public String GetErrorsForLevel4( List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        List<String> approverIds = new List<String>();

        
        // if levels exist
        if (processLevels.size() != 1)
            return 'There should be exactly one process level. Currently: ' + processLevels.size();

        // get role approvers
        approverIds.AddAll(approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]));
                            
        // check approval amount against threshold
        if ( approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();


        return null;
    }

    public String GetErrorsForLevel5(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        List<String> approverIds = new List<String>();
        
        // if levels exist
        if (processLevels.size() != 1)
            return 'There should be exactly one process level. Currently: ' + processLevels.size();

        // get role approvers
        approverIds.AddAll(approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]));
                            
        // check approval amount against threshold
        if ( approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();


        return null;
    }

    public String GetErrorsForLevel6( List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        List<String> approverIds = new List<String>();
        
        // if levels exist
        if (processLevels.size() != 1)
            return 'There should be exactly one process level. Currently: ' + processLevels.size();

        // get role approvers
        approverIds.AddAll(approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]));
                            
        // check approval amount against threshold
        if ( approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();


        return null;
    }

    public String GetErrorsForLevel7(List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        List<String> approverIds = new List<String>();
        
        // if levels exist
        if (processLevels.size() != 1)
            return 'There should be exactly one process level. Currently: ' + processLevels.size();

        // get role approvers
        approverIds.AddAll(approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]));
                            
        // check approval amount against threshold
        if (approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();


        return null;
    }
    
    public String GetErrorsForLevel8(String level2Approver, List<SPCM_Approval_Process_Level__c> processLevels ) {  
        String approverId = '';
        Map<Id, Id> approverMap = null;
        // if there is one process level and a approver selected
        if (level2Approver == null || processLevels.size() != 1) {
            return 'There should be only one process level for this level number! Currently: ' + processLevels.size();
        }
        // initialize approver map
        if (approverMap == null) {
            approverMap = InitializeLevel2ApproverMap();
        }
        // get approver from map
        approverId = approverMap.get(level2Approver);
        // if there is only one approver
        if (approverId == null || approverId == '') {
            return 'There should be only one approver!';
        }
        return null;
    }

    public String GetErrorsForLevel8(String contractType, List<SPCM_Approval_Process_Level__c> processLevels, SPCM_ApprovalManager approvalMgr)
    {
        if (contractType == null) {
            contractType = '';
        }
        String processLevelIdRef = '';
        List<String> approverIds = new List<String>();
        // if levels exist
        if (processLevels.size() <= 0)
            return 'Process Level doesn\'t exist.';

        // loop through process levels
        for (SPCM_Approval_Process_Level__c processLevel : processLevels)
        {
            // get contract types list from level
            Set<String> contractTypes = new Set<String>();
            for (String c : processLevel.Contract_Type__c.split(';'))
            {
                contractTypes.add(c);
            }
            // if process level contains contract type
            if (contractTypes.contains(contractType))
            {
                    // add approvers
                    approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                    processLevelIdRef = processLevel.Id;
            }
        }
        if ((approverIds.size() > 0 || processLevelIdRef != '') && approverIds.size() != 1)
            return 'There should be exactly one approver. Currently: ' + approverIds.size();
        return null;
    }
    
    // method to handle approval events (triggered by current approval level field update)
    protected override void HandleApprovalEvents(List<SObject> newRecords, 
        List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig, 
        GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr)
    {
        system.debug(newRecords);
        system.debug(oldRecords);
        system.debug(processConfig);
        system.debug(roleConfig);
        system.debug(approvalMgr);
        // approver map
        Map<Id, Id> approverMap = null;
        Map<Id, Id> level2ApproverMap = null, level3ApproverMap = null;
    
        // loop through records
        for (integer i = 0; i < newRecords.size(); i++)
        {
        
            // get new and old records
            SPCM_CARS_Payment_Packet__c newRecord = (SPCM_CARS_Payment_Packet__c)newRecords[i];
            SPCM_CARS_Payment_Packet__c oldRecord = (SPCM_CARS_Payment_Packet__c)oldRecords[i];
        
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

            SPCM_CARS_Payment_Packet__c newRec  = [select Payment_Type__r.Name from SPCM_CARS_Payment_Packet__c where id = :newRecord.id];
            isCoPay = 'Co-pay'.equalsIgnoreCase(newRec.Payment_Type__r.Name);
            
            Decimal requestedAmount = newRecord.Approval_Amount__c;

            if(newRecord.Approval_Amount__c < 0)
            {
                requestedAmount = requestedAmount * -1;
            }
            
       
            // if approval level 1
            if (newRecord.Appr_Approval_Level__c == 1)
            {

                // update initiated by
                newRecord.Initiated_By__c = UserInfo.getUserId();

                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = new List<SPCM_Approval_Process_Level__c>(); 
                for (SPCM_Approval_Process_Level__c processLevel : approvalMgr.GetProcessLevels(GetObjectType(), newRecord.Appr_Approval_Level__c)) {
                	if (processLevel.Comments__c != 'Fast Track') {
                		processLevels.add(processLevel);
                	}
                }
                system.debug(newRecord.Level_1_Approver__c);
                system.debug(processLevels);
                // if there is one process level and a approver selected
                if (newRecord.Level_1_Approver__c != null && processLevels.size() == 1)
                {
                
                    // initialize approver map
                    if (approverMap == null)
                    {
                        approverMap = InitializeApproverMap();
                    }
                    
                    // get approver from map
                    String approverId = approverMap.get(newRecord.Level_1_Approver__c);
                    
                    // if there is only one approver
                    if (approverId != null && approverId != '')
                    {
                        
                        // set approver as original
                        newRecord.Appr_Approver_1_Original__c = approverId;
                        newRecord.Original_Approver__c = approverId;
                        system.debug('CHECKING DELEGATED USER !!');
                        // check for delegated approver
                        approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);

                        system.debug('DELEGATED USER ' + approverId);
    
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
            if (newRecord.Appr_Approval_Level__c == 2) {
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                if (newRecord.Level_2_Approver__c != null && processLevels.size() == 1 && !isCoPay) {
                    if (level2ApproverMap == null) {
                        level2ApproverMap = InitializeLevel2ApproverMap();
                    }
                    system.debug(level2ApproverMap);
                    String approverId = level2ApproverMap.get(newRecord.Level_2_Approver__c);
                    if (String.isNotBlank(approverId)) {
                        if (approverId != priorDelAppr) {
	                        // set approver as original
	                        newRecord.Appr_Approver_1_Original__c = approverId;
	                        newRecord.Original_Approver__c = approverId;
	                        // check for delegated approver
	                        approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
	                        // set approver and level
	                        newRecord.Appr_Approver_1__c = approverId;
	                        newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                        } else {
                            insertSkippedRecord(newRecord, 'Level 2 - Approval', approverId);
                            // skip step
                            newRecord.Appr_Approval_Level__c += 1;
                        }
                    } else {
                        system.debug('err 1');
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, newRecord.Appr_Approval_Level__c));
                    }
                } else {
                    // skip step
                    newRecord.Appr_Approval_Level__c += 1;
                }
                 /*else {
	                // if levels exist
	                if (processLevels.size() > 0) {
	                    if (level2ApproverMap == null) {
	                        level2ApproverMap = InitializeLevel2ApproverMap();
	                    }
	                    system.debug(level2ApproverMap);
	                    // loop through process levels
	                    List<String> approverIds = new List<String>();
	                    String processLevelId = '';
	                    for (SPCM_Approval_Process_Level__c processLevel : processLevels) {
	                        // if process level contains contract type
	                        // if approval amount is greater than threshold
	                        if (requestedAmount > processLevel.Low_Amount__c) {
	                            // add approvers
	                            approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
	                            processLevelId = processLevel.Id;
	                        }
	                    }
	                    // if there are approvers or there is a process level match
	                    if ((approverIds.size() > 0 || processLevelId != '') && !isCoPay) {
	                        // if there is only one approver
	                        if (approverIds.size() == 1) {
	                            // get approver
	                            String approverId = approverIds[0];
	                            // if approver not prior delegated approver
	                            system.debug(approverId);
	                            if (approverId != priorDelAppr) {
	                                // set approver as original
	                                newRecord.Appr_Approver_1_Original__c = approverId;
	                                newRecord.Original_Approver__c = approverId;
	                                // check for delegated approver
	                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
	                                // set approver and level
	                                newRecord.Appr_Approver_1__c = approverId;
	                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
	                            } else {
	                                insertSkippedRecord(newRecord, 'Level 2 - C-Ops Channel/Payer Manager Approval', approverId);
	                                // skip step
	                                newRecord.Appr_Approval_Level__c += 1;
	                            }
	                        } else {
	                            newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
	                            newRecord.Appr_Approval_Level__c));
	                        }
	                    } else {
	                        // skip step
	                        newRecord.Appr_Approval_Level__c += 1;
	                    }
	                } else {
	                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c,
	                    newRecord.Appr_Approval_Level__c));
	                }
                }*/
            }
            
            /*
            // approval level 2
            if (newRecord.Appr_Approval_Level__c == 2) {
                system.debug('level 2 ');
                system.debug(newRecord.Approval_Amount__c);
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                // if levels exist
                if (newRecord.Level_2_Approver__c != null && processLevels.size() == 1) {
                    if (level2ApproverMap == null) {
                        level2ApproverMap = InitializeLevel2ApproverMap();
                    }
                    system.debug(level2ApproverMap);
                    String approverId = level2ApproverMap.get(newRecord.Level_2_Approver__c);
                    if (String.isNotBlank(approverId)) {
                        // set approver as original
                        newRecord.Appr_Approver_1_Original__c = approverId;
                        newRecord.Original_Approver__c = approverId;
                        // check for delegated approver
                        approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                        // set approver and level
                        newRecord.Appr_Approver_1__c = approverId;
                        newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                    } else {
                        system.debug('err 1');
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, newRecord.Appr_Approval_Level__c));
                    }
                } else if (newRecord.Approval_Amount__c > 100000 || newRecord.Approval_Amount__c < -100000){
                    system.debug('err 2');
                    newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, newRecord.Appr_Approval_Level__c));
                }
            }*/
            /*
            // approval level 3
            if (newRecord.Appr_Approval_Level__c == 3)
            {
                system.debug('level 3');
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
                    
                        // get contract types list from level
                        Set<String> contractTypes = new Set<String>();
                        for (String contractType : processLevel.Contract_Type__c.split(';'))
                        {
                            contractTypes.add(contractType);
                        }
                        
                        // if process level contains contract type
                        if (contractTypes.contains(newRecord.Contract_Type__c))
                        {
                        
                            // if approval amount is greater than threshold
                            if (requestedAmount > processLevel.Low_Amount__c)
                            {
                                
                                // add approvers
                                approverIds.addAll(approvalMgr.GetProcessLevelRoleApprovers(processLevel));
                                processLevelId = processLevel.Id;
                            }
                        }
                    }
                    
                    // if there are approvers or there is a process level match
                    if ((approverIds.size() > 0 || processLevelId != '') && !isCoPay)
                    {
                    
                        // if there is only one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                                newRecord.Original_Approver__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevelId;
                            }
                            else
                            {
                            insertSkippedRecord(newRecord, 'Level 3 - C-Ops Group Channel/Payer Manager Approval', approverId);
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
            }*/
             // approval level 3
            if (newRecord.Appr_Approval_Level__c == 3) {
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                if (newRecord.Level_3_Approver__c != null && processLevels.size() == 1 && !isCoPay) {
                    if (level3ApproverMap == null) {
                        level3ApproverMap = InitializeLevel3ApproverMap();
                    }
                    system.debug(level3ApproverMap);
                    String approverId = level3ApproverMap.get(newRecord.Level_3_Approver__c);
                    if (String.isNotBlank(approverId)) {
                        if (approverId != priorDelAppr) {
	                        // set approver as original
	                        newRecord.Appr_Approver_1_Original__c = approverId;
	                        newRecord.Original_Approver__c = approverId;
	                        // check for delegated approver
	                        approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
	                        // set approver and level
	                        newRecord.Appr_Approver_1__c = approverId;
	                        newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                        } else {
                            insertSkippedRecord(newRecord, 'Level 3 - Approval', approverId);
                            // skip step
                            newRecord.Appr_Approval_Level__c += 1;
                        }
                    } else {
                        system.debug('err 1');
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, newRecord.Appr_Approval_Level__c));
                    }
                } else {
                    // skip step
                    newRecord.Appr_Approval_Level__c += 1;
                }
            }
            
            
            // approval level 4
            if (newRecord.Appr_Approval_Level__c == 4)
            {
                
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), 
                    newRecord.Appr_Approval_Level__c);
                
                // if exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approval amount against threshold
                    if (requestedAmount > processLevels[0].Low_Amount__c && !isCoPay)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                        
                        // if there is only one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                                newRecord.Original_Approver__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                            }
                            else
                            {
                             insertSkippedRecord(newRecord, 'Level 4 – C-Ops Executive Approval', approverId);
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
                
                // if exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approval amount against threshold
                    if (requestedAmount > processLevels[0].Low_Amount__c && !isCoPay)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                       
                        // if there is only one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                                newRecord.Original_Approver__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                            }
                            else
                            {
                             insertSkippedRecord(newRecord, 'Level 5 – SPCM Executive Approval', approverId);
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
                
                // if exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approval amount against threshold
                    if (requestedAmount > processLevels[0].Low_Amount__c && !isCoPay)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                        
                        // if there is only one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                                newRecord.Original_Approver__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
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
                
                // if exactly one process level
                if (processLevels.size() == 1)
                {
                    
                    // check approval amount against threshold
                    if (requestedAmount > processLevels[0].Low_Amount__c && !isCoPay)
                    {
                    
                        // get role approvers
                        List<String> approverIds = approvalMgr.GetProcessLevelRoleApprovers(processLevels[0]);
                        
                        // if there is only one approver
                        if (approverIds.size() == 1)
                        {
                            
                            // get approver
                            String approverId = approverIds[0];
                            
                            // if approver not prior delegated approver
                            if (approverId != priorDelAppr)
                            {
                            
                                // set approver as original
                                newRecord.Appr_Approver_1_Original__c = approverId;
                                newRecord.Original_Approver__c = approverId;
                
                                // check for delegated approver
                                approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            
                                // set approver and level
                                newRecord.Appr_Approver_1__c = approverId;
                                newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                            }
                            else
                            {
                            insertSkippedRecord(newRecord, 'Level 7 – Chief Executive Officer Approval', approverId);
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
            if (newRecord.Appr_Approval_Level__c == 8) {
                system.debug('level 8');
                // get process levels
                List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels(GetObjectType(), newRecord.Appr_Approval_Level__c);
                
                SPCM_Level_1_Approver__c level1Approver = [SELECT User__c FROM SPCM_Level_1_Approver__c WHERE ID  = :newRecord.Level_1_Approver__c];
                
                if (newRecord.Level_2_Approver__c != null && processLevels.size() == 1 && !isCoPay && requestedAmount > processLevels[0].Low_Amount__c) {
                    if (level2ApproverMap == null) {
                        level2ApproverMap = InitializeLevel2ApproverMap();
                    }
                    String approverId = level2ApproverMap.get(newRecord.Level_2_Approver__c);
                    system.debug('level 8 aprover ids ' + level2ApproverMap);
                    // if there are approvers or there is a process level match
                    if (String.isNotBlank(approverId)) {
                        if (approverId != priorDelAppr) {
                            // set approver as original
                            newRecord.Appr_Approver_1_Original__c = approverId;
                            newRecord.Original_Approver__c = approverId;
                            // check for delegated approver
                            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
                            // set approver and level
                            newRecord.Appr_Approver_1__c = level1Approver.User__c;
                            newRecord.Appr_Approver_1_Process_Level__c = processLevels[0].Id;
                        } else {
                            system.debug('release');
                            insertSkippedRecord(newRecord, 'Release Payment', approverId);
                            // skip step
                            newRecord.Appr_Approval_Level__c += 1;
                        }
                    } else {
                        newRecord.addError(GetApprovalErrorMessage(newRecord.Approval_Type__c, newRecord.Appr_Approval_Level__c));
                    }
                } else {
                    // skip step
                    newRecord.Appr_Approval_Level__c += 1;
                }
            }
        }
    }
    private  void insertSkippedRecord(SPCM_CARS_Payment_Packet__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.CARS_Payment_Packet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c=apprId;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                  newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                  dateTime myDate = dateTime.now();
                                  newHistoryRecord.End_Date__c= myDate+0.00005;
                                newHistoryRecord.Comments__c='Auto approved due to delegation';
                                insert newHistoryRecord;
                                

    }
    // returns map for approvers    
    public Map<Id, Id> InitializeApproverMap()
    {
    
        // declaration(s)
        Map<Id, Id> approverMap = new Map<Id, Id>();
        
        // loop through reviewers and add to map
        for (SPCM_Level_1_Approver__c record : [SELECT Id, User__c FROM SPCM_Level_1_Approver__c])
        {
            approverMap.put(record.Id, record.User__c);
        }
        
        // return map
        return (approverMap);
    }
    
    public Map<Id, Id> InitializeLevel2ApproverMap()
    {
        Map<Id, Id> approverMap = new Map<Id, Id>();
        for (SPCM_Level_2_Approver__c record : [SELECT Id, User__c FROM SPCM_Level_2_Approver__c]) {
            approverMap.put(record.Id, record.User__c);
        }
        return (approverMap);
    }
    
    public Map<Id, Id> InitializeLevel3ApproverMap()
    {
        Map<Id, Id> approverMap = new Map<Id, Id>();
        for (SPCM_Level_3_Approver__c record : [SELECT Id, User__c FROM SPCM_Level_3_Approver__c]) {
            approverMap.put(record.Id, record.User__c);
        }
        return (approverMap);
    }
    
    
    public void level2ApproverHandler(List<SPCM_CARS_Payment_Packet__c> newRecords) {
        SPCM_Approval_Process_Level__c processLevel = [SELECT Id, Low_Amount__c FROM SPCM_Approval_Process_Level__c WHERE Name = 'Level 2 - Approval' AND Approval_Process__r.Name = 'SPCM CARS Payment Packet'];
        if (processLevel != null) {
	        for (SPCM_CARS_Payment_Packet__c carsPayment : newRecords) {
	            if ((carsPayment.Approval_Amount__c >= (-1)*processLevel.Low_Amount__c && carsPayment.Approval_Amount__c <= processLevel.Low_Amount__c && carsPayment.Level_2_Approver__c != null) ||
	            ((carsPayment.Approval_Amount__c > processLevel.Low_Amount__c || carsPayment.Approval_Amount__c < (-1)*processLevel.Low_Amount__c) && carsPayment.Level_2_Approver__c == null)) {
	                carsPayment.addError('Level 2 Approver is required only when Approval Amount is greater than $' +  String.valueOf(processLevel.Low_Amount__c/1000) + 'k or less than -$' +  String.valueOf(processLevel.Low_Amount__c/1000) + 'k');
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
            SPCM_CARS_Payment_Packet__c newRecord = new SPCM_CARS_Payment_Packet__c(
                Approval_Amount__c = 500000000, Contract_Type__c = 'GPO',
                Level_1_Approver__c = testUtils.level1Approver.Id);
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
                    
            // refresh data and run assertions
            List<SPCM_CARS_Payment_Packet__c> newRecords = [SELECT Appr_Approver_1__c,
                RecordTypeId FROM SPCM_CARS_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                    RecordTypeId FROM SPCM_CARS_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_CARS_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_CARS_Payment_Packet__c WHERE Id = :newRecord.Id];
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
                RecordTypeId FROM SPCM_CARS_Payment_Packet__c WHERE Id = :newRecord.Id];
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
            SPCM_CARS_Payment_Packet__c newRecord = new SPCM_CARS_Payment_Packet__c(
                Approval_Amount__c = 500000000, Contract_Type__c = 'GPO');
            insert(newRecord);
            System.assertNotEquals(newRecord.Id, null);
            
            // get object type for use in process lookups
            String objectType = String.valueOf(newRecord.getSObjectType());

            // create approval process data
            testUtils.CreateApprovalProcessData(objectType);
            
            // remove process level roles/users
            testUtils.RemoveApprovalProcessRolesAndUsers(objectType);

            // remove user manager
            testUtils.analystAUH.All_User_Hierarchy_Level1_gne__c = null;
            update(testUtils.analystAUH);
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
                newRecord.Initiated_By__c = null;
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
            SPCM_CARS_Payment_Packet__c newRecord = new SPCM_CARS_Payment_Packet__c(
                Approval_Amount__c = 500000000, Contract_Type__c = 'GPO',
                Level_1_Approver__c = testUtils.level1Approver.Id);
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