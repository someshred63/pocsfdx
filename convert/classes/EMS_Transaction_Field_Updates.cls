public without sharing class EMS_Transaction_Field_Updates {

    private static void updateHCPHCOName(List<EMS_Transaction_gne__c> triggerNew) {
        List<Id> paymentRequestIds = new List<Id>();
        for (EMS_Transaction_gne__c trans: triggerNew) {
            paymentRequestIds.add(trans.EMS_Speaker_Role_gne__c);
        }
        Map<Id, EMS_Speaker_Role_gne__c> paymentRequestsMap = new Map<Id, EMS_Speaker_Role_gne__c>();
        for (EMS_Speaker_Role_gne__c paymentRequest : [SELECT Id, Name, HCP_gne__r.Name FROM EMS_Speaker_Role_gne__c WHERE Id IN :paymentRequestIds]) {
            paymentRequestsMap.put(paymentRequest.Id, paymentRequest);
        }
        for (EMS_Transaction_gne__c trans: triggerNew) {
            trans.HCP_HCO_gne__c = paymentRequestsMap.get(trans.EMS_Speaker_Role_gne__c).HCP_gne__r.Name;
        }
    }

    private static void updateIHCPName(List<EMS_Transaction_gne__c> triggerNew) {
        List<Id> paymentRequestIds = new List<Id>();
        for (EMS_Transaction_gne__c trans: triggerNew) {
            paymentRequestIds.add(trans.EMS_Speaker_Role_gne__c);
        }
        Map<Id, EMS_Speaker_Role_gne__c> paymentRequestsMap = new Map<Id, EMS_Speaker_Role_gne__c>();
        for (EMS_Speaker_Role_gne__c paymentRequest : [SELECT Id, Name, EMS_International_Speaker_gne__r.Name FROM EMS_Speaker_Role_gne__c WHERE Id IN :paymentRequestIds]) {
            paymentRequestsMap.put(paymentRequest.Id, paymentRequest);
        }
        for (EMS_Transaction_gne__c trans: triggerNew) {
            trans.iHCP_gne__c = paymentRequestsMap.get(trans.EMS_Speaker_Role_gne__c).EMS_International_Speaker_gne__r.Name;
        }
    }

    public static void onBeforeInsertUpdate(List<EMS_Transaction_gne__c> triggerOld, List<EMS_Transaction_gne__c> triggerNew) {
        updateHCPHCOName(triggerNew);
        updateIHCPName(triggerNew);
    }
}