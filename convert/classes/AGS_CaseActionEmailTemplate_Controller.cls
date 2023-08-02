public class AGS_CaseActionEmailTemplate_Controller {

    public static final String DOMAIN_NAME = 'gene.com';
    
    public static final String INFU_PROFILE_NAME = 'GNE-INFREQUENT-USER';
    
    public static final String VALID_DATA_ACTION = 'Please Validate Data';
    
    public static final String DEFAULT_TRAIN_URL = 'https://comm.gene.com/ags-case-action';
    
    public static final String CONFIR_MGR_ACTION = 'Confirm Compliance Understanding - Manager Escalated';
    
    public static String getEnvironmentName() {
        final String userName = UserInfo.getUserName();
        return userName.endsWith(DOMAIN_NAME) ? 'prod' : userName.indexOf(DOMAIN_NAME) > 0 ? userName.substring(
            userName.indexOf(DOMAIN_NAME) + DOMAIN_NAME.length() + 1
        ) : userName.substringAfterLast('.');
    }
    
    public User caseActionOwner {
        private set; get {
            return caseActionOwner == null ? new User(Profile = new Profile()) : caseActionOwner;
        }
    }
    
    public String caseActionLink {
        private set; get {
            return String.isBlank(caseActionLink) ? System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + (
                caseActionId == null ? sObjectType.AGS_Case_Action_gne__c.keyPrefix + '000000000000' : caseActionId
            ) : caseActionLink;
        }
    }
    
    public String trainingLink {
        private set; get {
            final AGS_Email_Links__c[] emailLinks = AGS_Email_Links__c.getAll().values();
            for (AGS_Email_Links__c emailLink : String.isBlank(trainingLink) ? emailLinks : new AGS_Email_Links__c[]{ }) {
                trainingLink = emailLink.AGS_Training_Link__c;
            }
            return String.isBlank(trainingLink) ? DEFAULT_TRAIN_URL : trainingLink;
        }
    }
    
    public All_User_Hierarchy_gne__c caseActionUser {
        private set; get {
            final All_User_Hierarchy_gne__c[] usrs = caseActionOwner == null || String.isBlank(
                caseActionOwner.External_ID_gne__c
            ) ? new All_User_Hierarchy_gne__c[]{ } : [
                SELECT Active_gne__c FROM All_User_Hierarchy_gne__c
                WHERE User_External_Id_gne__c = :caseActionOwner.External_ID_gne__c AND Active_gne__c = true LIMIT 1
            ];
            return usrs.isEmpty() ? new All_User_Hierarchy_gne__c(Active_gne__c = false) : usrs[0];
        }
    }
    
    public Id caseActionId {
        get; set {
            final Set<String> eventIds = new Set<String>();
            final String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            final AGS_Email_Links__c[] emailLinks = AGS_Email_Links__c.getAll().values();
            try {
                final AGS_Case_Action_gne__c caseAction = [
                    SELECT
                        OwnerId,
                        Action_gne__c,
                        AGS_Case_gne__c,
                        Send_Error_Email__c
                    FROM AGS_Case_Action_gne__c WHERE Id = :(caseActionId = value) LIMIT 1
                ];
                final AGSSpendCCOCase_gne__c[] spends = [
                    SELECT
                        AGS_Spend_Expense_Trans_Infq_User_gne__c,
                        AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c,
                        AGS_Spend_Expense_Transaction_gne__r.Spend_User_gne__c
                    FROM AGSSpendCCOCase_gne__c WHERE AGS_Case_gne__c = :caseAction.AGS_Case_gne__c LIMIT 1000
                ];
                caseActionOwner = [
                    SELECT Name, External_ID_gne__c, Profile.Name FROM User WHERE Id = :caseAction.OwnerId LIMIT 1
                ];
                caseAction.Infrequent_User_Case_Action_gne__c = caseAction.Action_gne__c != CONFIR_MGR_ACTION &&
                    caseActionOwner.Profile.Name == INFU_PROFILE_NAME;
                for (AGSSpendCCOCase_gne__c spend : spends) {
                    caseAction.Infrequent_User_Case_Action_gne__c |= caseAction.Action_gne__c != CONFIR_MGR_ACTION &&
                        spend.AGS_Spend_Expense_Transaction_gne__r.Spend_User_gne__c == caseAction.OwnerId &&
                        spend.AGS_Spend_Expense_Trans_Infq_User_gne__c == 'Yes';
                    eventIds.add(spend.AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c);
                }
                eventIds.remove(null);
                caseAction.Infrequent_User_Case_Action_gne__c |= caseAction.Infrequent_User_Case_Action_gne__c || [
                    SELECT Infrequent_Enabled_Profile__c FROM Infrequent_Interaction_Enabled_Profiles__c
                    WHERE Infrequent_Enabled_Profile__c = :caseActionOwner.Profile.Name LIMIT 1
                ].size() > 0;
                // set owner profile name as GNE-FREQUENT-USER or GNE-INFREQUENT-USER
                caseActionOwner.Profile.Name = INFU_PROFILE_NAME.replace(
                    'IN', caseAction.Infrequent_User_Case_Action_gne__c ? 'IN' : ''
                );
                trainingLink = emailLinks.isEmpty() ? null : caseAction.Infrequent_User_Case_Action_gne__c ?
                    emailLinks[0].AGS_IFU_Training_Link__c : emailLinks[0].AGS_Training_Link__c;
                // in case of error sending action
                if (caseAction.Send_Error_Email__c) {
                    caseActionLink = baseUrl + '/' + caseActionId;
                } else
                // in case of infrequent users or missing CommPortal URL
                if (caseAction.Infrequent_User_Case_Action_gne__c || emailLinks.isEmpty() ||
                    String.isBlank(emailLinks[0].AGS_CommPortal_Link__c)
                ) {
                    final String[] links = new String[]{ };
                    final String envName = getEnvironmentName();
                    final AGS_Environment_Domain_gne__c[] envs = caseAction.Infrequent_User_Case_Action_gne__c ?
                        AGS_Environment_Domain_gne__c.getAll().values() : new AGS_Environment_Domain_gne__c[]{ };
                    for (AGS_Environment_Domain_gne__c env : envs) {
                        if (env.Name.containsIgnoreCase(envName) && String.isNotBlank(env.Site_Domain_gne__c)) {
                            links.add('http://' + env.Site_Domain_gne__c.trim() + '/infu');
                        }
                    }
                    caseActionLink = links.isEmpty() ? baseUrl + '/' + caseActionId : links[0];
                    caseActionLink += '?targetUrl=/apex/' + (
                        caseAction.Action_gne__c == VALID_DATA_ACTION ? 'IRecord' : 'AGS_ConfirmPolicy'
                    );
                    if (!eventIds.isEmpty()) {
                        caseActionLink += '&interactionid=' + new List<String>(eventIds)[0].trim();
                    }
                    caseActionLink += '&spenduser=' + caseActionOwner.External_ID_gne__c;
                    caseActionLink += '&caseid=' + caseAction.AGS_Case_gne__c;
                    caseActionLink += '&caseactionid=' + caseActionId;
                    caseActionLink += '&mode=confirm';
                } else {
                    caseActionLink = String.format(emailLinks[0].AGS_CommPortal_Link__c, new String[]{
                        caseActionId, caseAction.Action_gne__c == VALID_DATA_ACTION ? 'IRecord' : 'AGS_ConfirmPolicy',
                        caseAction.AGS_Case_gne__c, caseActionOwner.External_ID_gne__c, eventIds.isEmpty() ?
                        null : new List<String>(eventIds)[0].trim()
                    });
                }
            } catch (QueryException e) {
                // case action not found
                caseActionOwner = new User();
            }
        }
    }
}