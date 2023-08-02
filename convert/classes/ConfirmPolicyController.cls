public class ConfirmPolicyController {
    
    public static final String MODE = 'mode';
    
    public static final String CASE_ID = 'caseid';
    
    public static final String CASEACTION_ID = 'caseactionid';
    
    public static final String INTERACTION_ID = 'interactionid';
    
    public static final String[] URL_PARAM_NAMES = new String[]{
        MODE, CASE_ID, CASEACTION_ID, INTERACTION_ID
    };
    
    public Boolean blConfirmCompliance { get; private set; }
    
    public boolean blCheckboxConfirmCompliance { get; set; }
    
    private final PageReference retUrl;
    
    private final Id caseActionId;
    
    private final String host;
    
    public ConfirmPolicyController() {
        final Map<String, String> params = ApexPages.currentPage().getParameters();
        blConfirmCompliance = !(String.isBlank(caseActionId = params.get(CASEACTION_ID)) ?
            new AGS_Case_Action_gne__c[]{ } : [
            SELECT Id FROM AGS_Case_Action_gne__c WHERE Id = :caseActionId
            AND Action_gne__c = 'Please Validate Data'
            AND Action_Status_gne__c = 'Open' LIMIT 1
        ]).isEmpty();
        host = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
        retUrl = new PageReference(host + '/apex/IRecord');
        for (String paramName : URL_PARAM_NAMES) {
            retUrl.getParameters().put(paramName, paramName == MODE ? 'confirm' : params.get(paramName));
        }

        caseNameToThresholdMinimumMap = new Map<String, Integer>();

        for(AGS_CCO_Case_Reason__c caseReason :[SELECT Name, Threshold_Minimum__c FROM AGS_CCO_Case_Reason__c]) {
            caseNameToThresholdMinimumMap.put(caseReason.Name, Integer.valueOf(caseReason.Threshold_Minimum__c));
        }
    }
    
    public PageReference submitConfirmCompliance() {
        for (AGS_Case_Action_gne__c action : blCheckboxConfirmCompliance ? [
            SELECT AGS_Case_gne__r.Analyst_gne__r.Email FROM AGS_Case_Action_gne__c WHERE Id = :caseActionId
            AND Action_gne__c = 'Please Validate Data' AND Action_Status_gne__c = 'Open' LIMIT 1
        ] : new AGS_Case_Action_gne__c[]{ }) {
            insert new AGS_Case_Action_gne__c(
                RecordTypeId = [
                    SELECT Id FROM RecordType WHERE Name = 'AGS Case Action-ConfirmCompliance-Edit-Rect' LIMIT 1
                ].Id,
                AGS_Case_Analyst_Email_gne__c = action.AGS_Case_gne__r.Analyst_gne__r.Email,
                Action_gne__c = 'Confirm Compliance Understanding',
                Confirm_Compliance_Understanding_gne__c = true,
                AGS_Case_gne__c = action.AGS_Case_gne__c,
                Action_Status_internal_gne__c = 'Open',
                Send_Email__c = true
            );
            action.AGS_Validate_Data_1_box_gne__c = true;
            action.Action_Status_internal_gne__c = 'Open';
            update action;
            return Utility.RedirectPage(retUrl.getUrl());
        }
        return Utility.RedirectPage(host + '/apex/ShowMessage?msgid=INF_USER_PLEASE_VALIDATE');
    }
    
    public PageReference goBack() {
        return Utility.RedirectPage(retUrl.getUrl());
    }

    public Map<String, Integer> caseNameToThresholdMinimumMap {get;set;}
}