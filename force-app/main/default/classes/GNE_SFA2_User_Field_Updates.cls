/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-15
*  Description: This is a helper class for GNE_SFA2_User_Trigger for handling User field updates
*  Test class: GNE_SFA2_User_Trigger_Test
*
*  Modification History
*  Date        Name        			Description
*  2012-12-07  kwiatkol    			Change exteral id generation logic
*  2014-07-29  Lukasz Bieniawski	Added logic to set manager after user became active
*  2015-05-11  Tadeusz Hyzy			Change updateContentPermission() method for AM profile and all FRMs profiles
*************************************************************/
public with sharing class GNE_SFA2_User_Field_Updates {

    private static void updateFederationIdentifier(List<User> triggerNew) {
        for (User user : triggerNew) {
            user.FederationIdentifier = user.username;
        }
    }

    private static void updateContentPermission(List<User> triggerNew) {
        for (User user : triggerNew) {
            if (GNE_SFA2_Util.isMccoCrmUser(user) || (user.Profile_Name_gne__c.contains('GNE-MCCO-FRM')) || (user.Profile_Name_gne__c.contains('GNE-SFA-BAM') || (user.Profile_Name_gne__c.contains('GNE-MCCO-Kaiser')))) {
                user.UserPermissionsSFContentUser = true;
                user.UserPreferencesContentNoEmail = false;
                user.UserPreferencesContentEmailAsAndWhen = false;
            }
        }
    }

    private static void updateCompanyName(List<User> triggerNew) {
        for (User user : triggerNew) {
            if ((user.Profile_Name_gne__c.contains('Actemra')) ||
                    (user.Profile_Name_gne__c.contains('Xeloda')) ||
                    (user.Profile_Name_gne__c.contains('Primary')) ||
                    (user.Profile_Name_gne__c.contains('Transplant')) ||
                    (user.Profile_Name_gne__c.contains('MedAffairs')) ||
                    (user.Profile_Name_gne__c.contains('HCV'))) {

                if (user.CompanyName != 'Roche Laboritories') {
                    user.CompanyName = 'Roche Laboratories';
                }
            } else if (! user.Profile_Name_gne__c.contains('GNE-INFREQUENT-USER')) {
                if (user.CompanyName != 'Genentech') {
                    user.CompanyName = 'Genentech';
                }
            }
        }
    }

    private static void fillExternalID(List<User> users) {
        Set<Id> profileIds = new Set<Id>();
        String userType;
        String unixId;
        String username;

        for (User user : users) {
            if (user.UserType == null) {
                profileIds.add(user.ProfileId);
            }
        }

        Map<Id, Profile> profileUserTypes = new Map<Id, Profile>([SELECT UserType FROM Profile WHERE Id IN :profileIds]);

        for (Integer i = 0; i < users.size(); i++) {
            if (users[i].UserType != null) {
                userType = users[i].UserType;
            } else {
                userType = profileUserTypes.get(users[i].ProfileId).UserType;
            }

            username = users[i].Username;

            if (username.indexOf('@') > 0) {
                unixId = username.substringBefore('@');

                // update External Id
                if (userType == 'Standard') {
                    users[i].External_ID_gne__c = unixId;
                } else if(!isChatterFreeUser(users[i].Profile_Name_gne__c)) {
                    users[i].External_ID_gne__c = username;
                }

                // update Alias
                if (unixId != null && unixId.length() > 8) {
                    users[i].Alias = unixId.substring(0, 7);
                } else {
                    users[i].Alias = unixId;
                }
            }
        }
    }

    private static void updateExternalId(List<User> triggerOld, List<User> triggerNew) {
        List<User> usersToUpdate = new List<User>();

        for (Integer i = 0; i < triggerOld.size(); i++) {
            if (triggerOld[i].Username != triggerNew[i].Username) {
                usersToUpdate.add(triggerNew[i]);
            }
        }
        fillExternalID(usersToUpdate);
    }

    private static void generateExternalId(List<User> triggerNew) {
        List<User> usersToUpdate = new List<User>();

        for (Integer i = 0; i < triggerNew.size(); i++) {
            usersToUpdate.add(triggerNew[i]);
        }

        fillExternalID(usersToUpdate);
    }

    private static void updatePFGUncertifiedStatus(List<User> triggerOld, List<User> triggerNew) {
        for (Integer i = 0; i < triggerOld.size(); i++) {
            if (!triggerOld[i].PFG_Uncertified_Flag_gne__c && triggerNew[i].PFG_Uncertified_Flag_gne__c) {
                triggerNew[i].PFG_Uncertified_Start_Date_gne__c = Date.today();
                triggerNew[i].PFG_Uncertified_End_Date_gne__c  = null;
            }

            if (triggerOld[i].PFG_Uncertified_Flag_gne__c && !triggerNew[i].PFG_Uncertified_Flag_gne__c) {
                triggerNew[i].PFG_Uncertified_End_Date_gne__c  = Date.today();
            }
        }
    }

    private static void resetLOAHOOverrideFlag(List<User> triggerOld, List<User> triggerNew) {
        Integer idx = 0;
        for (User uNew : triggerNew) {
            User uOld = triggerOld[idx++];
            if (uNew.LOA_HO_Override_Flag_gne__c == uOld.LOA_HO_Override_Flag_gne__c &&
                    (uNew.LOA_Start_Date_gne__c != uOld.LOA_Start_Date_gne__c || uNew.LOA_End_Date_gne__c != uOld.LOA_End_Date_gne__c)) {

                uNew.LOA_HO_Override_Flag_gne__c = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_NA;
            }
        }
    }

    private static void updateUserPreferencesFields(List<User> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if(!isChatterFreeUser(triggerNew[i].Profile_Name_gne__c)) {
                triggerNew[i].UserPreferencesHideS1BrowserUI = true;
            }
            triggerNew[i].UserPreferencesDisableAllFeedsEmail = true;
            triggerNew[i].UserPreferencesDisableFollowersEmail = true;
            triggerNew[i].UserPreferencesDisableProfilePostEmail = true;
            triggerNew[i].UserPreferencesDisableChangeCommentEmail = true;
            triggerNew[i].UserPreferencesDisableLaterCommentEmail = true;
            triggerNew[i].UserPreferencesDisProfPostCommentEmail = true;
            triggerNew[i].UserPreferencesContentNoEmail = true;
            triggerNew[i].UserPreferencesContentEmailAsAndWhen = true;
            triggerNew[i].UserPreferencesHideCSNGetChatterMobileTask = true;
            triggerNew[i].UserPreferencesDisableMentionsPostEmail = true;
            triggerNew[i].UserPreferencesDisMentionsCommentEmail = true;
            triggerNew[i].UserPreferencesHideCSNDesktopTask = true;
            triggerNew[i].UserPreferencesHideChatterOnboardingSplash = true;
            triggerNew[i].UserPreferencesHideSecondChatterOnboardingSplash = true;
            triggerNew[i].UserPreferencesDisCommentAfterLikeEmail = true;
            triggerNew[i].UserPreferencesDisableMessageEmail = true;
            triggerNew[i].UserPreferencesDisableSharePostEmail = true;
            triggerNew[i].UserPreferencesShowTitleToExternalUsers  = false;
        }
    }
    
    private static void syncUserManager(List<User> triggerOld, List<User> triggerNew) {    	
    	List<User> activatedUsers = new List<User>();
    	List<Id> excludeManagers = new List<Id>();
    	for (Integer i = 0; i < triggerOld.size(); i++) {
            if (!triggerOld[i].IsActive && triggerNew[i].IsActive && String.isNotBlank(triggerNew[i].External_ID_gne__c)) {
               	activatedUsers.add(triggerNew[i]);                	
            } else if (triggerOld[i].IsActive && !triggerNew[i].IsActive) {
               	excludeManagers.add(triggerNew[i].Id);
            }
    	}
    	if (activatedUsers.size() > 0){
    		GNE_SFA2_All_User_Hierarchy_Utils.SyncUserManagerForUsers(activatedUsers, excludeManagers, false);
    	}
    }

    public static Boolean isChatterFreeUser(String profileName){
        return String.isNotBlank(profileName) && profileName.toLowerCase().contains('chatter') ? true : false;
    }

    public static void enrichUserData(List<User> triggerNew){
        try{
            List<Id> usersToEnrich = new List<Id>();
            for(User u :triggerNew){
                if(GNE_SFA2_Peeps_API_Engine.getMatchingProfileIds().contains(u.ProfileId)){
                    usersToEnrich.add(u.Id);
                }
            }
            if(usersToEnrich.size()>0){
                GNE_SFA2_Peeps_API_Engine.enrichUserData(usersToEnrich);
            }
        } catch(Exception ex){
            system.debug('User data enrichment failed: ' + ex);
        }
    }

    public static void checkUserIfCanInfu(List<User> triggerNew) {
        for (User u : triggerNew) {
            if(u.Profile_Name_gne__c.containsIgnoreCase('canada') && u.IsActive == False) {
                u.ProfileId = GNE_SFA2_User_Trigger_Helper.getCanInfuProfileId();
            }
        }
    }

    public static void onBeforeInsert(List<User> triggerNew) {
        generateExternalId(triggerNew);
        updateFederationIdentifier(triggerNew);
        updateCompanyName(triggerNew);
        updateUserPreferencesFields(triggerNew); 
		updateContentPermission(triggerNew);
    }

    public static void onBeforeUpdate(List<User> triggerOld, List<User> triggerNew) {
        updateExternalId(triggerOld, triggerNew);
        updateFederationIdentifier(triggerNew);
        updateCompanyName(triggerNew);
        updatePFGUncertifiedStatus(triggerOld, triggerNew);
        resetLOAHOOverrideFlag(triggerOld, triggerNew);
        syncUserManager(triggerOld, triggerNew);
        updateContentPermission(triggerNew);
        checkUserIfCanInfu(triggerNew);
    }

    public static void onAfterInsert(List<User> triggerNew){
        if(!System.isBatch() && !System.isFuture()){
            enrichUserData(triggerNew);
        }
    }
}