public class EDM_Set_Updated_By_Field {

    public static void onBeforeUpdate(Map<Id,EDM_Classification_Request_gne__c> triggerOldMap,List<EDM_Classification_Request_gne__c> triggerNew) {

        for(EDM_Classification_Request_gne__c cr : triggerNew) {
            if(triggerOldMap.get(cr.Id).EDM_Action_Comments_gne__c != cr.EDM_Action_Comments_gne__c) {
                cr.EDM_Commented_By_gne__c = System.UserInfo.getName();
            }
        }

    }
}