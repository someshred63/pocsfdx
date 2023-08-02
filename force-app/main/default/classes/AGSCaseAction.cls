public abstract class AGSCaseAction {


    public static final Integer CASE_ACTION_VALUE_DETERMINE_CASE_ACTION_LATENCY = 101;
    public static final Integer CASE_ACTION_VALUE_LATENCY = 102;
    public static final Integer CASE_ACTION_VALUE_LATENCY_EXTENDED = 103;
    public static final Integer CASE_ACTION_VALUE_LATENCY_ESCALATED = 104;
    public static final Integer CASE_ACTION_VALUE_CREATE_INSTANCE_CASE = 105;
    public static final Integer CASE_ACTION_VALUE_REOPEN_CASE_SYSTEM = 106;
    public static final Integer CASE_ACTION_VALUE_USER_VALIDATE_DATA = 107;
    public static final Integer CASE_ACTION_VALUE_USER_VALIDATE_DATA_FOLLOW_UP = 108;
    public static final Integer CASE_ACTION_VALUE_REOPEN_CASE_ANALYST = 109;
    public static final Integer CASE_ACTION_VALUE_CLOSE_CASE_NO_ISSUE = 110;
    public static final Integer CASE_ACTION_VALUE_CLOSE_CASE_ISSUE_RESOLVED = 111;
    public static final Integer CASE_ACTION_VALUE_CLOSE_CASE_HCO_TO_RESOLVE = 112;
    public static final Integer CASE_ACTION_VALUE_USER_CONFIRM_COMPLIANCE = 113;
    public static final Integer CASE_ACTION_VALUE_USER_CONFIRM_COMPLIANCE_ESCALATED = 114;
    public static final Integer CASE_ACTION_VALUE_NOTIFICATION_CUSTOM = 115;
    public static final Integer CASE_ACTION_VALUE_CREATE_AGGREGATION_CASE = 116;
    public static final Integer CASE_ACTION_VALUE_NOTIFICATION_AGGREGATION_LIMIT = 117;
    public static final Integer CASE_ACTION_VALUE_USER_ACKNOWLEDGE_STOP_SPEND_LIMIT = 118;
    public static final Integer CASE_ACTION_VALUE_DETERMINE_PER_INSTANCE_RESPONSE = 119;
    public static final Integer CASE_ACTION_VALUE_DETERMINE_PER_INSTANCE_SEVERITY = 120;
    public static final Integer CASE_ACTION_VALUE_CREATE_MANUAL_CASE = 121; 
    
    public static final String CASE_ACTION_TYPE_FUNCTION = 'Function';
    public static final String CASE_ACTION_TYPE_NOTIFICATION = 'Notification';  
    public static final String CASE_ACTION_TYPE_CASE_CREATION = 'Case Creation';
    public static final String CASE_ACTION_TYPE_APPROVAL = 'Compliance Task';
    
    public static final String ACTION_STATUS_OPEN = 'Open';
    public static final String ACTION_STATUS_CLOSED = 'Closed';
    
    public static final String ACTION_READONLY_RECORD_TYPE = '012R0000000Cq3z';
    public static final String ACTION_EDITABLE_RECORD_TYPE = '012R0000000Cq4T';
    
    /* Case Action Values */
    public static Boolean isLatencyAction(AGS_Case_Action_gne__c  caseAction) {     
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_LATENCY;
    }   
    public static Boolean isLatencyExtendedAction(AGS_Case_Action_gne__c  caseAction) {     
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_LATENCY_EXTENDED;
    }   
    public static Boolean isLatencyEscalatedAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_LATENCY_EXTENDED;
    }           
    public static Boolean isCloseCaseNoIssueAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_CLOSE_CASE_NO_ISSUE;
    }
    public static Boolean isCloseCaseIssueResolvedAction(AGS_Case_Action_gne__c  caseAction) {      
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_CLOSE_CASE_ISSUE_RESOLVED;
    }       
    public static Boolean isCloseCaseHCOToResolveAction(AGS_Case_Action_gne__c  caseAction) {       
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_CLOSE_CASE_HCO_TO_RESOLVE;
    }   
    public static Boolean isCreateInstanceCaseAction(AGS_Case_Action_gne__c  caseAction) {      
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_CREATE_INSTANCE_CASE;
    }   
    public static Boolean isCreateAggregationCaseAction(AGS_Case_Action_gne__c  caseAction) {       
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_CREATE_AGGREGATION_CASE;
    }   
    public static Boolean isCreateManualCaseAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_CREATE_MANUAL_CASE;
    }           
    public static Boolean isReOpenCaseSystemAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_REOPEN_CASE_SYSTEM;
    }
    public static Boolean isReOpenCaseAnalystAction(AGS_Case_Action_gne__c  caseAction) {       
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_REOPEN_CASE_ANALYST;
    }   
    public static Boolean isUserValidateDataAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_USER_VALIDATE_DATA;
    }
    public static Boolean isUserValidateDataFollowUpAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_USER_VALIDATE_DATA_FOLLOW_UP;
    }       
    public static Boolean isUserAcknowledgeStopSpendLimitAction(AGS_Case_Action_gne__c  caseAction) {       
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_USER_ACKNOWLEDGE_STOP_SPEND_LIMIT;
    }   
    public static Boolean isConfirmComplianceAction(AGS_Case_Action_gne__c  caseAction) {       
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_USER_CONFIRM_COMPLIANCE;
    }   
    public static Boolean isConfirmComplianceEscalatedAction(AGS_Case_Action_gne__c  caseAction) {      
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_USER_CONFIRM_COMPLIANCE_ESCALATED;
    }   
    public static Boolean isAggregationLimitNotificationAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_NOTIFICATION_AGGREGATION_LIMIT;
    }
    public static Boolean isCustomNotificationAction(AGS_Case_Action_gne__c  caseAction) {      
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_NOTIFICATION_CUSTOM;
    }   
    public static Boolean isDetermineCaseActionLatencyAction(AGS_Case_Action_gne__c  caseAction) {      
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_DETERMINE_CASE_ACTION_LATENCY;
    }   
    public static Boolean isPerInstanceResponseAction(AGS_Case_Action_gne__c  caseAction) {     
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_DETERMINE_PER_INSTANCE_RESPONSE;
    }
    public static Boolean isDeterminePerInstanceSeverityAction(AGS_Case_Action_gne__c  caseAction) {        
        return Math.roundToLong(caseAction.Action_Value_gne__c) == CASE_ACTION_VALUE_DETERMINE_PER_INSTANCE_SEVERITY;
    }
    
    /* Case Action Types */
    public static Boolean isNotification(AGS_Case_Action_gne__c caseAction) {
        return caseAction.Action_Type_gne__c == CASE_ACTION_TYPE_NOTIFICATION;
    }
    
    public static Boolean isFunction(AGS_Case_Action_gne__c caseAction) {
        return caseAction.Action_Type_gne__c == CASE_ACTION_TYPE_FUNCTION;
    }
    
    public static Boolean isCaseCreation(AGS_Case_Action_gne__c caseAction) {
        return caseAction.Action_Type_gne__c == CASE_ACTION_TYPE_CASE_CREATION;
    }
    
    public static Boolean isSpendUserTask(AGS_Case_Action_gne__c caseAction) {
        return caseAction.Action_Type_gne__c == CASE_ACTION_TYPE_APPROVAL;
    }
    
    /* Case Action Statuses */
    public static Boolean isCaseActionClosed(AGS_Case_Action_gne__c caseAction) {
        return caseAction.Action_Status_internal_gne__c == ACTION_STATUS_CLOSED;
    }           
    public static void setCaseActionClosed(AGS_Case_Action_gne__c caseAction) {
        caseAction.Action_Status_internal_gne__c = ACTION_STATUS_CLOSED;
    }
    public static void setCaseActionOpen(AGS_Case_Action_gne__c caseAction) {
        Boolean wasReadOnly = isCaseActionReadOnly(caseAction);
        if (wasReadOnly) {
            setCaseActionEditable(caseAction);
        }       
        caseAction.Action_Status_internal_gne__c = ACTION_STATUS_OPEN;
        if (wasReadOnly) {
            setCaseActionReadOnly(caseAction);
        }
    }
    public static Boolean isCaseActionOpen(AGS_Case_Action_gne__c caseAction) {
        return caseAction.Action_Status_internal_gne__c == ACTION_STATUS_OPEN;
    }
     
    
    /* Case Action Record Types */
    public static Boolean isCaseActionReadOnly(AGS_Case_Action_gne__c caseAction) {
        // new way to get "Read Only"
        // return boolean evaluation
        return caseAction.RecordTypeId == ACTION_READONLY_RECORD_TYPE;
    }
    
    public static void setCaseActionReadOnly(AGS_Case_Action_gne__c caseAction) {
        caseAction.RecordTypeId = AGSCaseAction.ACTION_READONLY_RECORD_TYPE;
    }
    public static void setCaseActionEditable(AGS_Case_Action_gne__c caseAction) {
        caseAction.RecordTypeId = AGSCaseAction.ACTION_EDITABLE_RECORD_TYPE;
    }
    
    
    public static AGS_Case_Action_gne__c initiateAction(AGS_Case_Action_gne__c caseAction, AGS_Case_gne__c caseInfo) {      
        if (AGSCaseAction.isNotification(caseAction)) {
            AGSNotificationActions.runAction(caseAction, caseInfo);
        } else if (AGSCaseAction.isSpendUserTask(caseAction)) {                 
            if (AGSCaseAction.isConfirmComplianceAction(caseAction)) { 
                //Confirm Compliance Understanding
                //1.  Set the AGS Case Approval Flag to TRUE.  This allows the Approval Process to kick off
                //    a.  Start an approval process for Confirm Compliance
                
                //2.  Send the email Notification to 
                //    a.  the Resolver
                //    b.  The Resolver's User Manager.
                //1.
                agsWorkflow.setAGSCaseApprovalFlagTrue(caseInfo.Id, caseAction.Id);
                //1a.  
                agsWorkflow.startCaseApproval(caseInfo.Id, caseAction);       
                //Call the Compliance Understanding Tasks
                //agsWorkflow.addOpenTaskToAGSCase(Trigger.new[i], caseInfo.Resolver__r.Id);                        
            }  
        }
                
                        
        closeCaseTaskAction(caseAction);
        return caseAction;
    }
    
    public static void closeCaseTaskAction(AGS_Case_Action_gne__c caseAction) {
        //if the Case Action closed, then add that Case Action task saying the Case Action closed itself
        if(AGSCaseAction.isCaseActionClosed(caseAction)){
            agsWorkflow.addClosedTaskToAGSCaseAction(caseAction, 'Closed Case Action');                
        }     
    }
    
    
}