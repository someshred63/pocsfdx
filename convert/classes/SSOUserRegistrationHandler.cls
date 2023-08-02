/**
    Provide logic for inbound just-in-time provisioning of single sign-on users 
    Author: K. Leszek, M. Hrycenko
*/
global class SSOUserRegistrationHandler implements Auth.SamlJitHandler {
    private static final String INFU_PROFILE_NAME            = 'RCanada-SFA-INFU';
    private static final String GNE_INF_PROFILE_NAME         = 'GNE-INFREQUENT-USER';
    private static final String GNE_FIELD_PROFILE_NAME       = 'GNE-Field';
    private static final String GNE_MED_AFFAIRS_PROFILE_NAME = 'GNE-MedAffairs';
    private static final String LDAP_CANADA_LOCATION_NAME    = 'RMS';
    private static final String GROUP_PRF_GRP_US             = 'PRF_GRP_US';
    private static final String CANADA_PROFILE_PREFIX        = 'RCanada(.)+';

    private class JitException extends Exception {}
    
    static final Pattern isProfileApplicablePattern = Pattern.compile(INFU_PROFILE_NAME +'|'+GNE_INF_PROFILE_NAME+'|'+GNE_FIELD_PROFILE_NAME+'|^('+GNE_MED_AFFAIRS_PROFILE_NAME+'-).*');
    static final Pattern isCanadaProfilePattern = Pattern.compile(CANADA_PROFILE_PREFIX);

    private void handleUser(Boolean create, User u, Map<String, String> attributes, String federationIdentifier, Boolean isStandard) {
        if(u.Id != null) {
            updateUser(u);
        } else {
            if (attributes.containsKey('User.Email') && attributes.get('User.Email').contains('roche') && attributes.containsKey('User.LocationCode') && attributes.get('User.LocationCode').equalsIgnoreCase(getCanadaLocation())) {
                if (create && attributes.containsKey('User.Username')) {
                    u.Username = attributes.get('User.FederationIdentifier');
                }
                if (create) {
                    if (attributes.containsKey('User.FederationIdentifier')) {
                        u.FederationIdentifier = attributes.get('User.FederationIdentifier');
                    } else {
                        u.FederationIdentifier = federationIdentifier;
                    }
                }

                if (attributes.containsKey('User.FirstName')) {
                    u.FirstName = attributes.get('User.FirstName');
                }
                if (attributes.containsKey('User.LastName')) {
                    u.LastName = attributes.get('User.LastName');
                } else {
                    u.LastName = attributes.get('User.FirstName');
                }
                if (attributes.containsKey('User.Title')) {
                    u.Title = attributes.get('User.Title');
                }
                if (attributes.containsKey('User.Alias')) {
                    u.Alias = attributes.get('User.Alias');
                    u.External_ID_gne__c = attributes.get('User.Alias');
                }
                if (attributes.containsKey('User.CommunityNickname')) {
                    u.CommunityNickname = attributes.get('User.CommunityNickname');
                }

                u.LocaleSidKey = 'en_US';
                u.EmailEncodingKey = 'ISO-8859-1';
                u.LanguageLocaleKey = 'en_US';
                u.Email = attributes.get('User.Email');
                u.CompanyName = 'Roche';
                u.TimeZoneSidKey = 'America/Panama';
                Profile p = [SELECT Id FROM Profile WHERE Name = :INFU_PROFILE_NAME];
                u.ProfileId = p.Id;
            }
        }
    }
    
    private static void handleGroupAssignment(User userRecord) {
        System.debug(userRecord.Profile_Name_gne__c + ' isUSProfile > '+isUSProfile(userRecord.Profile_Name_gne__c));
        if(isUSProfile(userRecord.Profile_Name_gne__c)) {
            Group group_PRF_GRP_US = [SELECT Id FROM Group WHERE Name = :GROUP_PRF_GRP_US LIMIT 1];
            GroupMember[] groupMembers = [SELECT Id FROM GroupMember WHERE GroupId =:group_PRF_GRP_US.Id AND UserOrGroupId =:userRecord.Id];
            if(groupMembers.isEmpty()) {
                try {
                    insert new GroupMember(GroupId = group_PRF_GRP_US.Id, UserOrGroupId = userRecord.Id);
                } catch(Exception ex) {
                    System.debug(ex.getStackTraceString());
                }
            }
        }
    }

    private static void updateUser(User userRecord) {
        if(isProfileApplicable(userRecord.Profile_Name_gne__c) && userRecord.IsActive != true){
            userRecord.IsActive = true;
            update userRecord;
        }
    }
    
    public static Boolean isProfileApplicable(String profileName) {
        Boolean result = isProfileApplicablePattern.matcher(profileName).matches();
        return result;
    }

    private static Boolean isUSProfile(String profileName) {
        Boolean result = isCanadaProfilePattern.matcher(profileName).matches();
        return !result;
    }

    private static Boolean isGroupAssignmentEnabled() {
        GNE_Foun_Misc_Config_Items_gne__c config = GNE_Foun_Misc_Config_Items_gne__c.getValues('SSO_Jit_GroupAssignmentEnabled');
        return config != null ? Boolean.valueOf(config.Configuration_Value_gne__c) : false;
    }

    private void handleJit(Boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        if (communityId == null && portalId == null) {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {

        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
                federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {

        User u = [SELECT Id, FirstName, ContactId, Profile_Name_gne__c, IsActive FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
         if(isGroupAssignmentEnabled()) {
            handleGroupAssignment(u);
        }
    }

    private String getCanadaLocation() {
        String result = '';
        for(GNE_Foun_Misc_Config_Items_gne__c config : [SELECT Configuration_Value_gne__c FROM GNE_Foun_Misc_Config_Items_gne__c WHERE Name = 'LDAPCanadaLocationCode']) {
            if(String.isNotBlank(config.Configuration_Value_gne__c)) {
                result = config.Configuration_Value_gne__c;
            }
        }

        return String.isNotBlank(result) ? result : LDAP_CANADA_LOCATION_NAME;
    }
}