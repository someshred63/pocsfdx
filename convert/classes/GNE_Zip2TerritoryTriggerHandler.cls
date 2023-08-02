public class GNE_Zip2TerritoryTriggerHandler {
    public static void updateUSPSAddress() {
        Set<Id> idsForUpdate = new Set<Id> ();
        String[] zipsForUpdate = collectZipsForUpdate(idsForUpdate);
        Map<String, USPS_Address_gne__c> zip2USPSAddress = fetchUSPSAddress(zipsForUpdate);
        updateRecords(zip2USPSAddress, idsForUpdate);
    }
    
    public static void calculateBrandZip() {
        for(Zip_to_Territory_gne__c z2t : (Zip_to_Territory_gne__c[])Trigger.new ){
            if(isRecordChanged(z2t)){
                z2t.Brand_Zip_Id_gne__c = z2t.STARS_BrandCode_gne__c + '_' + z2t.Zip_Code_gne__c + '_' + z2t.Territory_Number_gne__c;
            }
        }
    }
    
    public static void createOTRDeletedRecordOnDeleted() {
        OTR_Deleted_Record_gne__c[] toInsert = new OTR_Deleted_Record_gne__c[]{};
        for(Zip_to_Territory_gne__c z2t : (Zip_to_Territory_gne__c[])Trigger.old ){
            toInsert.add(createOTRDeletedRecord(z2t));
        } 
        insert toInsert;
    }
    
    public static void deleteOTRDeletedRecordOnUnDeleted() {
        
    }
    
    private static void updateRecords(Map<String, USPS_Address_gne__c> zip2USPSAddress, Set<Id> idsForUpdate) {
        for(Zip_to_Territory_gne__c newRecord  : (Zip_to_Territory_gne__c [])Trigger.new) {
            if(idsForUpdate.contains(newRecord.Id) ){
                if(zip2USPSAddress.containsKey(newRecord.Zip_Code_gne__c)){
                    newRecord.USPS_Address_gne__c = zip2USPSAddress.get(newRecord.Zip_Code_gne__c).Id;
                } else {
                    newRecord.USPS_Address_gne__c = null;
                }
            }
        }
    }
    
    private static Map<String, USPS_Address_gne__c> fetchUSPSAddress(String[] zipsForUpdate) {
        Map<String, USPS_Address_gne__c> result = new Map<String, USPS_Address_gne__c>();
        for(USPS_Address_gne__c uspsAddr : [SELECT Id, Zip_gne__c FROM USPS_Address_gne__c WHERE Zip_gne__c IN : zipsForUpdate]){
            result.put(uspsAddr.Zip_gne__c, uspsAddr);
        }
        return result;
    }
    
    private static String[] collectZipsForUpdate(Set<Id> idsForUpdate ) {
        String[] result = new String[]{};
        for(Zip_to_Territory_gne__c z2t : (Zip_to_Territory_gne__c[])Trigger.new){
            if(Trigger.isInsert && z2t.Zip_Code_gne__c != null) {
                result.add(z2t.Zip_Code_gne__c);
                idsForUpdate.add(z2t.Id);
            } else if(Trigger.isUpdate){
                Zip_to_Territory_gne__c oldRecord = (Zip_to_Territory_gne__c)Trigger.oldMap.get(z2t.Id);
                if(z2t.USPS_Address_gne__c == null || z2t.Zip_Code_gne__c != oldRecord.Zip_Code_gne__c){
                    result.add(z2t.Zip_Code_gne__c);
                    idsForUpdate.add(z2t.Id);
                }
            }
        }
        return result;
    }
    
    private static Boolean isRecordChanged(Zip_to_Territory_gne__c z2t) {
        Boolean result;
        if(Trigger.isInsert){
            result = true;
        } else if(Trigger.isUpdate){
            Zip_to_Territory_gne__c oldZ2t = (Zip_to_Territory_gne__c)Trigger.oldMap.get(z2t.Id);
            result = z2t.STARS_BrandCode_gne__c != oldZ2t.STARS_BrandCode_gne__c || 
                z2t.Zip_Code_gne__c != oldZ2t.Zip_Code_gne__c || 
                z2t.Territory_Number_gne__c != oldZ2t.Territory_Number_gne__c;
        }

        return result;        
    }
    
    private static OTR_Deleted_Record_gne__c createOTRDeletedRecord(Zip_to_Territory_gne__c deletedRecord) {
        return new OTR_Deleted_Record_gne__c(
        	Deleted_Record_Id__c = deletedRecord.Territory_Number_gne__c + '_' + deletedRecord.Zip_Code_gne__c,
            Object_name__c = 'ZipToTerritory_gne'
        );
    }
}