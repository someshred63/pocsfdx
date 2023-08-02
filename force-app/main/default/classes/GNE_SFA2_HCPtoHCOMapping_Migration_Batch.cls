global without sharing class GNE_SFA2_HCPtoHCOMapping_Migration_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime timeStamp = GNE_Foun_Misc_Config_Items_gne__c.getValues('TimeStampForMappingFromInternalCases') != null ? DateTime.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues('TimeStampForMappingFromInternalCases').get('Configuration_Value_gne__c')): DateTime.newInstance(2016, 3, 1);
        String query = 'SELECT Id, Case_Treating_Physician_gne__c, Address_gne__c, Address_gne__r.Account_vod__c, Case_Treating_Physician_gne__r.Name, Case_Treating_Physician_gne__r.FirstName, Case_Treating_Physician_gne__r.LastName, Case_Treating_Physician_gne__r.Middle_gne__c, Case_Treating_Physician_gne__r.MDMID_gne__c, Case_Treating_Physician_gne__r.MDMID_Status_gne__c, Case_Treating_Physician_gne__r.Status_gne__c, Case_Treating_Physician_gne__r.Phone, Case_Treating_Physician_gne__r.Professional_Type_gne__c, Case_Treating_Physician_gne__r.Credentials_gne__c, Address_gne__r.Name, Address_gne__r.Address_line_2_vod__c, Address_gne__r.City_vod__c, Address_gne__r.State_vod__c, Address_gne__r.Zip_vod__c, Address_gne__r.MDM_Address_Id_gne__c, Address_gne__r.Location_gne__Latitude__s, Address_gne__r.Location_gne__Longitude__s, Product_gne__c FROM Case WHERE Case_Treating_Physician_gne__c != \'0017000000dv76bAAA\' AND Case_Treating_Physician_gne__c != null AND Address_gne__c != null AND CreatedDate > : timeStamp';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        (new GNE_SFA2_HCPtoFRMHCOMappingEngine(true)).init((List<Case>)scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        Id frmHCORecTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO' LIMIT 1].Id;
        List<Address_vod__c> frmHCOAddressesWithoutCoordinates = [SELECT Id, Force_Location_Update_gne__c FROM Address_vod__c WHERE Account_vod__r.RecordTypeId =: frmHCORecTypeId AND (Location_gne__Latitude__s = null OR Location_gne__Longitude__s = null)];
        
        if(!frmHCOAddressesWithoutCoordinates.isEmpty()) {
            for(Address_vod__c addr : frmHCOAddressesWithoutCoordinates) {
                addr.Force_Location_Update_gne__c = true;
            }

            update frmHCOAddressesWithoutCoordinates;
        }
        
        Database.executeBatch(new GNE_SFA2_AddressLocation_Batch(true, true, true), 5);
    }
	
}