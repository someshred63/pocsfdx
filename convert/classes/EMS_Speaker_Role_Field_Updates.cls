public without sharing class EMS_Speaker_Role_Field_Updates {

    private static void updateHCPHCOiHCPName(List<EMS_Speaker_Role_gne__c> triggerNew) {
        Set<Id> hcpIds = new Set<Id>();
        Set<Id> ihcpIds = new Set<Id>();

        Map<Id, String> hcpNames = new Map<Id, String>();
        Map<Id, String> ihcpNames = new Map<Id, String>();

        for (EMS_Speaker_Role_gne__c speakerRole : triggerNew) {
            if (speakerRole.HCP_gne__c != null) {
                hcpIds.add(speakerRole.HCP_gne__c);
            }

            if (speakerRole.EMS_International_Speaker_gne__c != null) {
                ihcpIds.add(speakerRole.EMS_International_Speaker_gne__c);
            }
        }

        for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :hcpIds]) {
            hcpNames.put(acc.Id, acc.Name);
        }

        for (EMS_International_Speaker_gne__c ihcp : [SELECT Id, Name FROM EMS_International_Speaker_gne__c WHERE Id IN :ihcpIds]) {
            ihcpNames.put(ihcp.Id, ihcp.Name);
        }

        for (EMS_Speaker_Role_gne__c speakerRole : triggerNew) {
            if (speakerRole.EMS_International_Speaker_gne__c != null) {
                speakerRole.HCP_HCO_iHCP_gne__c = ihcpNames.get(speakerRole.EMS_International_Speaker_gne__c);
            } else if (speakerRole.HCP_gne__c != null) {
                speakerRole.HCP_HCO_iHCP_gne__c = hcpNames.get(speakerRole.HCP_gne__c);
            }
        }
    }

    public static void onBeforeInsertUpdate(List<EMS_Speaker_Role_gne__c> triggerNew) {
        updateHCPHCOiHCPName(triggerNew);
    }
}