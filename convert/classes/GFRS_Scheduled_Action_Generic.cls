/**
 * Created by pawlowsl on 2017-08-30.
 */

public abstract with sharing class GFRS_Scheduled_Action_Generic implements GFRS_Scheduled_Action_Interface {

    private String emailTemplateName;

    public String getEmailTemplateName() {
        return emailTemplateName;
    }

    private Integer triggerDays;

    public Integer getTriggerDays() {
        return triggerDays;
    }

    private List<String> emailTemplateCC;

    public List<String> getEmailTemplateCC() {
        return emailTemplateCC;
    }

    private String triggerField;

    public String getTriggerField() {
        return triggerField;
    }

    private Boolean invokeOnlyOnTriggerDate;

    public Boolean getInvokeOnlyOnTriggerDate() {
        return invokeOnlyOnTriggerDate;
    }

    protected Date getActionDate(Integer days) {
        return Date.today().addDays(-days);
    }

    public void initialize(GFRS_Scheduled_Actions__c action) {
        emailTemplateName = action.Email_Template__c;
        triggerDays = (Integer)action.Trigger_Days__c;
        emailTemplateCC = action.Email_CC__c != null? action.Email_CC__c.split(',') : null;
        triggerField = action.Trigger_Field__c;
        invokeOnlyOnTriggerDate = action.Invoke_Only_On_Trigger_Date__c;
    }

    public virtual Map<String,Object> prepareMergedFields(SObject fundingRequest) {
        return null;
    }

    public virtual Boolean invokable(SObject sObj) {
        Date triggerDate = (Date)sObj.get(getTriggerField());
        if(getInvokeOnlyOnTriggerDate())
            return triggerDate == getActionDate(getTriggerDays());
        else
            return triggerDate <= getActionDate(getTriggerDays());
    }

    public virtual Id getTargetObject(SObject sObj) {
        return (Id)sObj.get('OwnerId');
    }

    public virtual List<String> getRecipients(SObject sObj) {
        return null;
    }

    public virtual List<String> getBCCRecipients(SObject sObj) {
        return new List<String>{
            GFRS_NotificationUtil.getGFRSCommunicationEmail()
        };
    }

    public virtual SObject invokeChangeRecord(SObject sObj) {
        return null;
    }

    public with sharing class GFRS_Scheduled_Action_Recon_Requested extends GFRS_Scheduled_Action_Generic implements GFRS_Scheduled_Action_Interface {

        public override Boolean invokable(SObject sObj) {
            GFRS_Funding_Request__c fundingRequest = (GFRS_Funding_Request__c)sObj;
            return super.invokable(sObj) && fundingRequest.gFRS_Tasks__r.size() == 0 && fundingRequest.Reconciliation_Required_Status_Date__c == null;
        }

        public override SObject invokeChangeRecord(SObject sObj) {
            GFRS_Funding_Request__c fundingRequest = (GFRS_Funding_Request__c)sObj;
            fundingRequest.Sub_Status__c = 'Reconciliation Required';
            fundingRequest.External_Sub_status__c = 'Reconciliation Required';
            return fundingRequest;
        }

    }

    public with sharing class GFRS_Scheduled_Action_Sunshine_Requested extends GFRS_Scheduled_Action_Generic implements GFRS_Scheduled_Action_Interface {

        public override Boolean invokable(SObject sObj) {
            GFRS_Funding_Request__c fundingRequest = (GFRS_Funding_Request__c)sObj;
            return super.invokable(sObj) && fundingRequest.gFRS_Tasks__r.size() == 0 && fundingRequest.RecordType.Name != GFRS_Util.TYPE_IMED_NAME;
        }

        public override SObject invokeChangeRecord(SObject sObj) {
            GFRS_Funding_Request__c fundingRequest = (GFRS_Funding_Request__c)sObj;
            fundingRequest.Sunshine_Act_Disclosure_Submitted__c = 'No';
            fundingRequest.Sub_Status__c = 'Sunshine Act Disclosure';
            fundingRequest.External_Sub_status__c = 'Sunshine Act Disclosure';
            return fundingRequest;
        }
    }
    
    //HotFix 02/20/21- Scheduled Job Failure
    public with sharing class GFRS_Scheduled_Action_Recon_Remainder_Requested extends GFRS_Scheduled_Action_Generic implements GFRS_Scheduled_Action_Interface {

        public override Boolean invokable(SObject sObj) {
            Date triggerDate = (Date)sObj.get(getTriggerField());
        	if(getInvokeOnlyOnTriggerDate())
            	return triggerDate == getActionDate(getTriggerDays());
        	else
            	return triggerDate <= getActionDate(getTriggerDays());
       }

        public override SObject invokeChangeRecord(SObject sObj) {
			return null;
        }

    }
}