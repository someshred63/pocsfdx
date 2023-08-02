public class AGS_INF_Deactivation extends AGS_AbstractCaseBatch implements Database.Stateful {
    public static final String PROFILE_DEACTIVATION_PREFIX = 'AGS_INF_Deactivation:Profile';
    private final Set<Id> processedUsers = new Set<Id>();

    public AGS_INF_Deactivation() {
        this(getInitQuery());
    }

    public AGS_INF_Deactivation(final String query) {
        super(query);
    }

    private static String getInitQuery() {
        String profiles = getProfileFromConfiguration();
        String absApproversIdsToNotDeactivate = EDM_Deactivate_Utils.getAbsApproversIdsToNotDeactivate();
        String concurUsers = getConcurActivatedUserIds();

        return 'SELECT Id FROM User WHERE (LastLoginDate <= YESTERDAY OR LastLoginDate = null) ' +
                'AND (Profile.Name IN (' + profiles + ') ' +
                (String.isBlank(concurUsers) ? ') ' : 'OR Id IN (' + concurUsers + ')) ') +
                'AND Id NOT IN (' + absApproversIdsToNotDeactivate + ') ' +
                'AND IsActive = true';
    }

    private static String getProfileFromConfiguration() {
        Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
        List<String> profiles = new List<String>();
        for (String settingName : configItemsMap.keySet()) {
            String sValue = configItemsMap.get(settingName).Configuration_Value_gne__c;
            if (settingName.startsWithIgnoreCase(PROFILE_DEACTIVATION_PREFIX)) {
                profiles.add('\'' + sValue + '\'');
            }
        }

        return String.join(profiles, ',') ;
    }

    public override void execute(final Database.BatchableContext ctx, final List<SObject> users) {
        final User[] deactivatedUsers = new User[]{
        };
        final Savepoint savePoint = Database.setSavepoint();
        for (User usr : [SELECT IsActive FROM User WHERE Id IN :users AND IsActive = TRUE LIMIT :users.size()]) {
            deactivatedUsers.add(usr);
            usr.IsActive = false;
            processedUsers.add(usr.Id);
        }
        try {
            update deactivatedUsers;
        } catch (DmlException e) {
            Database.rollback(savePoint);
            throw e;
        }
    }

    public override void finish(final Database.BatchableContext ctx) {
        List<GNE_Concur_User__c> concurUsers = [SELECT Id FROM GNE_Concur_User__c WHERE User_gne__c IN :processedUsers AND Processed_gne__c = FALSE];
        for (GNE_Concur_User__c cu : concurUsers) {
            cu.Processed_gne__c = true;
        }
        Database.update(concurUsers, false);
        super.finish(ctx);
    }

    public static String getConcurActivatedUserIds() {
        List<String> concurUserIds = new List<String>();
        List<GNE_Concur_User__c> concurActivatedUsers = [SELECT User_gne__c FROM GNE_Concur_User__c WHERE Processed_gne__c = FALSE];
        for (GNE_Concur_User__c cu : concurActivatedUsers) {
            concurUserIds.add('\'' + cu.User_gne__c + '\'');
        }
        return String.join(concurUserIds, ',') ;
    }
}