public with sharing class EMS_GSD_Detail_Ext {

    public EMS_GSD_Detail_Ext(ApexPages.StandardController controller) {

    }

    @RemoteAction
    public static EMS_Remote_Response saveGSDDetail(EMS_GSD_Detail__c gsdDetail) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;

        if (gsdDetail.Id == null && gsdDetail.EMS_Event__c != null) {
            List<EMS_GSD_Detail__c> detail = [select id from EMS_GSD_Detail__c WHERE EMS_Event__c = :gsdDetail.EMS_Event__c];
            if (!detail.isEmpty()) gsdDetail.Id = detail[0].Id;
        }

        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            EMS_GSD_Detail_Validation_Rules.skipValidationRules = true;

            upsert gsdDetail;
        } catch (DmlException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
           		response.addError(ex.getDmlMessage(i));
            }
            response.isSuccess = false;
        } catch (Exception ex) {
            response.isSuccess = false;
            response.addError(ex.getMessage());
        }
        return response;
    }
}