public without sharing class GNE_AAR_Trigger_Helper {
    private static Map<Id, String> userIdToProfileNameMap = null;
    /**
*    Methods return Profile Name of Current User
*/
    public static String getCurrentUserProfileName() {
        system.debug('Profile Name'+getUserProfileName(UserInfo.getUserId()));
        return getUserProfileName(UserInfo.getUserId());
    }
    public static String getUserProfileName(Id userId) {
        if (userIdToProfileNameMap == null){
            userIdToProfileNameMap = new Map<Id, String>();
        }
        if (!userIdToProfileNameMap.containsKey(userId)){
            String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1].Profile.Name;
            userIdToProfileNameMap.put(userId, userProfileName);
        }
        return userIdToProfileNameMap.get(userId);
    }
    
    
}