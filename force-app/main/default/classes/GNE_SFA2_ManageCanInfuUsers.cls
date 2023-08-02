public with sharing class GNE_SFA2_ManageCanInfuUsers implements Schedulable {

    public void execute(SchedulableContext SC) {
        List<User> canInfuUsers = [SELECT Id, IsActive FROM User WHERE IsActive = true AND Profile_Name_gne__c =: GNE_SFA2_User_Trigger_Helper.CAN_INFU_PROFILE_NAME];
        if(!canInfuUsers.isEmpty()) {
            for(User u : canInfuUsers) {
                u.IsActive = false;
            }

            update canInfuUsers;
        }
    }
}