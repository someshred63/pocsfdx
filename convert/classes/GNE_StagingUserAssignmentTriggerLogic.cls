public class GNE_StagingUserAssignmentTriggerLogic {
    public static void updateExternalIdOnUpdate() {
        for(Staging_User_Assignment_gne__c sua : (Staging_User_Assignment_gne__c[]) Trigger.newMap.values()) {
            Staging_User_Assignment_gne__c oldRecord = (Staging_User_Assignment_gne__c) Trigger.OldMap.get(sua.Id);
            if(sua.Activaction_Date_gne__c != oldRecord.Activaction_Date_gne__c || sua.Territory_Key_gne__c != oldRecord.Territory_Key_gne__c) {
                String activationDate = '';
                if(sua.Activaction_Date_gne__c != null){
                    Date da = sua.Activaction_Date_gne__c;
                    activationDate = da.month() +'/' + da.day() +'/'+ da.year() ;
                }
                sua.External_Id_gne__c = sua.User_UnixID_gne__c + '-' + sua.Territory_Key_gne__c + '-' + activationDate;
                sua.External_Id_gne__c = sua.External_Id_gne__c.toUpperCase();                
            }            
        }                
    }
}