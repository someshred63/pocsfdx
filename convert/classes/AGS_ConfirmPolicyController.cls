public with sharing class AGS_ConfirmPolicyController {
    
    private final Id caseActionId;
    
    public Boolean blCheckbox { get; set; }
    
    public Boolean blHasBeenSubmitted { get; private set; }
    
    public static final String QUERY = 'SELECT Action_gne__c, Action_Status_internal_gne__c, {0} ' +
        'FROM AGS_Case_Action_gne__c WHERE Id = {1} LIMIT 1';
    
    public static final Map<String, String> RET_MSG_CODES = new Map<String, String> {
        'Confirm Compliance Understanding' => 'CONFIRM_COMPLIANCE',
        'Please Validate Data - Follow Up' => 'PLEASE_VALIDATE_FOLLOW',
        'Acknowledge Aggregate Spending Limit Reached' => 'ACK_LIMIT_REACHED',
        'Acknowledge Aggregate Legal Spending Limit Reached' => 'ACK_LEGAL_LIMIT_REACHED',
        'Confirm Compliance Understanding - Manager Escalated' => 'CONFIRM_COMPLIANCE_MANGER'
    };
    
    public static final Map<String, String> CHECKBOX_FLDS = new Map<String, String> {
        'Please Validate Data - Follow Up' => 'AGS_VALIDATE_DATA_FOLLOWUP_BOX_GNE__C',
        'Confirm Compliance Understanding' => 'CONFIRM_COMPLIANCE_UNDERSTANDING_GNE__C',
        'Acknowledge Aggregate Spending Limit Reached' => 'ACK_STOP_SPENDING_LIMIT_HIGH_GNE__C',
        'Acknowledge Aggregate Legal Spending Limit Reached' => 'ACK_STOP_SPENDING_LIMIT_HIGH_GNE__C',
        'Confirm Compliance Understanding - Manager Escalated' => 'AGS_ESCALATED_CONFIRM_COMPLIANCE_BOX_GNE__C'
    };
    
    public AGS_ConfirmPolicyController(final ApexPages.StandardController controller) {
        ApexPages.currentPage().getParameters().put('id',
            caseActionId = ApexPages.currentPage().getParameters().get('caseactionid')
        );
        final String usrUnixId = ApexPages.currentPage().getParameters().get('usrUnixId');
        final AGS_Case_Action_gne__c[] actions = getActions();
        blHasBeenSubmitted = actions.isEmpty() || isSubmitted(actions[0]) == true || String.isBlank(usrUnixId) || [
            SELECT External_ID_gne__c FROM User WHERE Id = :UserInfo.getUserId()
        ].External_ID_gne__c != usrUnixId;
        blCheckbox = !actions.isEmpty() && isChecked(actions[0]) == true;

        caseNameToThresholdMinimumMap = new Map<String, Integer>();

        for(AGS_CCO_Case_Reason__c caseReason :[SELECT Name, Threshold_Minimum__c FROM AGS_CCO_Case_Reason__c]) {
            caseNameToThresholdMinimumMap.put(caseReason.Name, Integer.valueOf(caseReason.Threshold_Minimum__c));
        }
    }
    
    public PageReference submitCaseAction() {
        try {
            final AGS_Case_Action_gne__c[] actions = blCheckbox ? getActions() : new AGS_Case_Action_gne__c[]{ };
            if (!(actions.isEmpty() || isChecked(actions[0]) == true || isSubmitted(actions[0]) == true)) {
                actions[0].put(CHECKBOX_FLDS.get(actions[0].Action_gne__c), true);
                update actions[0];
                return Utility.RedirectPage(String.format('/apex/ShowMessage?msgid=INF_USER_{0}', new String[]{
                    RET_MSG_CODES.get(actions[0].Action_gne__c)
                }));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    private AGS_Case_Action_gne__c[] getActions() {
        return (AGS_Case_Action_gne__c[]) Database.query(String.format(QUERY, new String[]{
            String.join(new List<String>(new Set<String>(CHECKBOX_FLDS.values())), ', '),
            caseActionId == null ? null : '\'' + caseActionId + '\''
        }));
    }
    
    private Boolean isChecked(final AGS_Case_Action_gne__c action) {
        try {
            return Boolean.valueOf(action.get(CHECKBOX_FLDS.get(action.Action_gne__c)));
        } catch (Exception e) {
            return null;
        }
    }
    
    private Boolean isSubmitted(final AGS_Case_Action_gne__c action) {
        try {
            return action.get(CHECKBOX_FLDS.get(action.Action_gne__c)) == true ||
                action.Action_Status_internal_gne__c == 'Closed';
        } catch (Exception e) {
            return null;
        }
    }

    public Map<String, Integer> caseNameToThresholdMinimumMap {get;set;}
}