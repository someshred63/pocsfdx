/************************************************************
*  @author: Bartosz Osowiecki
*  Date: 2014-02-28
*  Description: This is a helper class for GNE_SFA2_Interaction_Trigger
*  Test class: GNE_SFA2_Interaction_Trigger_Test
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public without sharing class GNE_SFA2_Interaction_Trigger_Helper {
    private static Boolean inInteractionTrig = false;
    private static Boolean isOtrRequest = false;
    private static Boolean isSfdcUiRequest = false;
    private static Boolean isAllowDeleteAttendeeMode = false;
    private static Map<Id,String> userToProfileNameMap;
    
    public static void setInteractionTrig(Boolean a_inInteractionTrig) {
        inInteractionTrig = a_inInteractionTrig;
    }

    public static Boolean inInteractionTrig()  {
        return inInteractionTrig == true;
    }

    public static void setIsOtrRequest(Boolean a_isOtrRequest) {
        isOtrRequest = a_isOtrRequest;
    }

    public static Boolean isOtrRequest()  {
        return isOtrRequest == true;
    }
    
    public static void setIsSfdcUiRequest(Boolean a_isSfdcUiRequest) {
        isSfdcUiRequest = a_isSfdcUiRequest;
    }
    
    public static Boolean isSfdcUiRequest() {
        return isSfdcUiRequest == true;
    }
    
    public static void setIsAllowDeleteAttendeeMode(Boolean a_isAllowDeleteAttendeeMode) {
        isAllowDeleteAttendeeMode = a_isAllowDeleteAttendeeMode;
    }
    
    public static Boolean isAllowDeleteAttendeeMode() {
        return isAllowDeleteAttendeeMode == true;
    }
    
    public static Map<Id,String> getUserToProfileNameMap(Set<Id> userIds) {
        if(userToProfileNameMap==null) {
            userToProfileNameMap = new Map<Id,String>();
        }
        
        Set<Id> newIds = new Set<Id>(userIds);
        newIds.removeAll(userToProfileNameMap.keySet());
        
        if(!newIds.isEmpty()) {
            List<User> users = [SELECT Id, Profile.Name FROM User WHERE Id IN :newIds];
            
            for(User u : users) {
                userToProfileNameMap.put(u.Id, u.Profile.Name);
            }
        }
        
        return userToProfileNameMap;
    }    
}