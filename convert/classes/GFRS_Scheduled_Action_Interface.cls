/**
 * Created by pawlowsl on 2017-08-30.
 */

public interface GFRS_Scheduled_Action_Interface {

    void initialize(GFRS_Scheduled_Actions__c action);

    Boolean invokable(SObject sObj);

    SObject invokeChangeRecord(SObject sObj);

    String getEmailTemplateName();

    List<String> getEmailTemplateCC();

    List<String> getBCCRecipients(SObject sObj);

    Id getTargetObject(SObject sObj);

    List<String> getRecipients(SObject sObj);

    Map<String,Object> prepareMergedFields(SObject sObj);

}