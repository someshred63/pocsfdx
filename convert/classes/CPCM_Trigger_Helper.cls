/*******************************************************************************************
* @Name         CPCM_Trigger_Helper 
* @Author       Raju Manche
* @Date         10/19/2021
* @Group        CPCM
* @Description  This class is used to return the login user's profile name. We are using this class in PCP_Controller class.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Raju Manche      10/19/2021          Initial Creation                                                      
******************************************************************************/
public without sharing class CPCM_Trigger_Helper {
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