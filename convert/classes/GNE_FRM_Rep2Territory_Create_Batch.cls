public without sharing class GNE_FRM_Rep2Territory_Create_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private Set<Id> userIds = new Set<Id>();
    private Set<Id> territoryIds = new Set<Id>();
    private Map<Id, User> id2User;
    private Map<Id, Territory2> id2Territory;
    private Set<String> existingKeys;
    private Boolean runMultipleTimes = true;

    public GNE_FRM_Rep2Territory_Create_Batch(){}

    public GNE_FRM_Rep2Territory_Create_Batch(Boolean runMultipleTimes) {
        this.runMultipleTimes = runMultipleTimes;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query =
            'SELECT Id, UserId, Territory2Id '+
            'FROM UserTerritory2Association '+
            'WHERE UserId IN (SELECT Id FROM User WHERE (Profile.Name like \'GNE-MCCO-FRM%\' OR Profile.Name like \'GNE-CRM%\') AND IsActive = true)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<UserTerritory2Association> scope) {
        init(scope);
        List<UserTerritory2Association> listToCreateRecords = new List<UserTerritory2Association>();
        List<FRM_Rep_2_Terr_gne__c> toUpsert = new List<FRM_Rep_2_Terr_gne__c>();
        fetchRecordsToUpsert(scope, fetchExistingRecordsMap(scope), toUpsert, listToCreateRecords);
        toUpsert.addAll(createListToInsert(listToCreateRecords));

        Database.UpsertResult[] results =  Database.upsert(toUpsert, false);
        String errorMessage = '';
        for(Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
        		for(Database.Error err : sr.getErrors()) {
                    String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+'. Fields that affected this error: ' + err.getFields();
                    System.debug(error);
                    errorMessage += error + '\n';
        		}
    		}
        }
        if(String.isNotBlank(errorMessage)) {
            sendEmailNotification(errorMessage);
        }
    }

    public void finish(Database.BatchableContext BC){
        if(this.runMultipleTimes) {
            GNE_Batch_Runner.scheduleBatchBasedOnSettings(
                    new GNE_FRM_Rep2Territory_Scheduler(),
                    'GNE_FRM_Rep2Territory', 'Process GNE_FRM_Rep2Territory Jobs');
        }
    }

    private void init(List<UserTerritory2Association> scope) {
        fetchIds(scope);
        this.id2User = new Map<Id, User>([
            SELECT Id, External_ID_gne__c
            FROM User
            WHERE Id IN : userIds
        ]);
        this.id2Territory = new Map<Id, Territory2>([
            SELECT Id, Name, Territory_Number_gne__c, Salesforce_SubTeam_Code_gne__c, Salesforce_Code_gne__c
            FROM Territory2
            WHERE Id IN : territoryIds
        ]);
        existingKeys = fetchExistingKeys(scope);
    }

    private FRM_Rep_2_Terr_gne__c[] createListToInsert(List<UserTerritory2Association> scope) {
        List<FRM_Rep_2_Terr_gne__c> recordsToInsert = new List<FRM_Rep_2_Terr_gne__c>();
        for(UserTerritory2Association ut: scope){
            User u = id2User.get(ut.userId);
        	Territory2 territory = id2Territory.get(ut.Territory2Id);
            String key = createKey(u, territory);
            if(!existingKeys.contains(key)){
                recordsToInsert.add(createRecord(ut));
            }
        }
        return recordsToInsert;
    }

    private String createKey(User u,Territory2 territory){
        String teamKey = String.isNotBlank(territory.Salesforce_Code_gne__c) ? territory.Salesforce_Code_gne__c : '';
        String subTeamKey = String.isNotBlank(territory.Salesforce_SubTeam_Code_gne__c) ? territory.Salesforce_SubTeam_Code_gne__c : '';
        return u.External_ID_gne__c + territory.Name + teamKey + subTeamKey;
    }

    private Set<String> fetchExistingKeys(List<UserTerritory2Association> scope) {
        Set<String> existingKeys = new Set<String>();
        Set<String> uniqueKeys = new Set<String>();
        for(UserTerritory2Association ut: scope){
            User u = id2User.get(ut.userId);
        	Territory2 territory = id2Territory.get(ut.Territory2Id);
            String key = createKey(u, territory);
            uniqueKeys.add(key);
        }
        FRM_Rep_2_Terr_gne__c [] rep2terrs = [SELECT Unique_Key_gne__c FROM FRM_Rep_2_Terr_gne__c WHERE Unique_Key_gne__c IN : uniqueKeys];
        for(FRM_Rep_2_Terr_gne__c r2t:rep2terrs){
            existingKeys.add(r2t.Unique_Key_gne__c);
        }
        return existingKeys;
    }

    private void fetchIds(List<UserTerritory2Association> scope) {
        for(UserTerritory2Association ut: scope){
            userIds.add(ut.UserId);
            territoryIds.add(ut.Territory2Id);
        }
    }

    private FRM_Rep_2_Terr_gne__c createRecord(UserTerritory2Association ut) {
        User u = id2User.get(ut.userId);
        Territory2 territory = id2Territory.get(ut.Territory2Id);
        FRM_Rep_2_Terr_gne__c record = new FRM_Rep_2_Terr_gne__c(
            SFDC_TerritoryName_gne__c = territory.Name,
            SFDC_TerritoryNbr_gne__c = territory.Territory_Number_gne__c,
            User_UnixID_gne__c = u.External_ID_gne__c,
            UserID_ref_gne__c = u.Id,
            UserTerritory_Id__c = ut.Id,
            SFDC_SubTeam_Code_gne__c = territory.Salesforce_SubTeam_Code_gne__c,
            SFDC_Team_Code_gne__c = territory.Salesforce_Code_gne__c
        );
        return record;
    }

    private void fetchRecordsToUpsert(List<UserTerritory2Association> scope, Map<Id, FRM_Rep_2_Terr_gne__c> userTerrId2record, List<FRM_Rep_2_Terr_gne__c> toUpsert, List<UserTerritory2Association> listToCreateRecords) {
        for(UserTerritory2Association ut : scope) {
            if(isRecordNotExist(ut.Id, userTerrId2record)) {
                listToCreateRecords.add(ut);
            } else {
                FRM_Rep_2_Terr_gne__c record = userTerrId2record.get(ut.Id);
                if(isRecordChanded(ut, record)){
                    User u = id2User.get(ut.userId);
                    Territory2 territory = id2Territory.get(ut.Territory2Id);
                    String key = createKey(u, territory);
                    if(!existingKeys.contains(key)){
                        record = cleanRecord(ut, record);
                    	toUpsert.add(record);
                    }
                }
            }
        }
    }

    private Set<String> fetchUserTerritoryIds(List<UserTerritory2Association> scope) {
        Set<String> userTerritoryIds = new Set<String>();
        for (UserTerritory2Association record : scope){
            userTerritoryIds.add(record.Id);
        }
        return userTerritoryIds;
    }

    private Map<Id, FRM_Rep_2_Terr_gne__c> fetchExistingRecordsMap(List<UserTerritory2Association> scope) {
        Map<Id, FRM_Rep_2_Terr_gne__c> userTerrId2record = new Map<Id, FRM_Rep_2_Terr_gne__c> ();
        FRM_Rep_2_Terr_gne__c [] rep2terrs = [
            SELECT Id, SFDC_TerritoryName_gne__c, SFDC_TerritoryNbr_gne__c, UserID_ref_gne__c,
                User_UnixID_gne__c, UserTerritory_Id__c, SFDC_SubTeam_Code_gne__c, SFDC_Team_Code_gne__c
            FROM FRM_Rep_2_Terr_gne__c WHERE UserTerritory_Id__c IN : fetchUserTerritoryIds(scope)
        ];
        for(FRM_Rep_2_Terr_gne__c r2t : rep2terrs){
            if(r2t.UserTerritory_Id__c != null){
                userTerrId2record.put(r2t.UserTerritory_Id__c, r2t);
            }
        }
        return userTerrId2record;
    }

    private Boolean isRecordNotExist(Id utId, Map<Id, FRM_Rep_2_Terr_gne__c> userTerrId2record) {
        return !userTerrId2record.containsKey(utId);
    }

    private Boolean isRecordChanded (UserTerritory2Association ut, FRM_Rep_2_Terr_gne__c record){
        User u = id2User.get(ut.userId);
        Territory2 territory = id2Territory.get(ut.Territory2Id);
        return
            record.SFDC_TerritoryName_gne__c != territory.Name ||
            record.SFDC_TerritoryNbr_gne__c  != territory.Territory_Number_gne__c ||
            record.User_UnixID_gne__c        != u.External_ID_gne__c ||
            record.SFDC_Team_Code_gne__c     != territory.Salesforce_Code_gne__c ||
            record.SFDC_SubTeam_Code_gne__c  != territory.Salesforce_SubTeam_Code_gne__c ;
    }

    private FRM_Rep_2_Terr_gne__c cleanRecord(UserTerritory2Association ut, FRM_Rep_2_Terr_gne__c recordToClean) {
        User u = id2User.get(ut.userId);
        Territory2 territory = id2Territory.get(ut.Territory2Id);
        recordToClean.SFDC_TerritoryName_gne__c = territory.Name;
        recordToClean.SFDC_TerritoryNbr_gne__c  = territory.Territory_Number_gne__c;
        recordToClean.User_UnixID_gne__c        = u.External_ID_gne__c;
        recordToClean.SFDC_Team_Code_gne__c     = territory.Salesforce_Code_gne__c;
        recordToClean.SFDC_SubTeam_Code_gne__c  = territory.Salesforce_SubTeam_Code_gne__c;
        return recordToClean;
    }

    private void sendEmailNotification(String message){
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('Batch_FRM_Rep2TerritoryNotifyEmail') == null ||
           String.isBlank(GNE_Foun_Misc_Config_Items_gne__c.getValues('Batch_FRM_Rep2TerritoryNotifyEmail').Configuration_Value_gne__c)
        ) {
            return;
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setPlainTextBody(message);
        email.setSubject('Problem in GNE_FRM_Rep2Territory_Create_Batch at: '+ System.now());
        email.setToAddresses(new List<String>{GNE_Foun_Misc_Config_Items_gne__c.getValues('Batch_FRM_Rep2TerritoryNotifyEmail').Configuration_Value_gne__c});
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		emails.add(email);
		Messaging.sendEmail(emails);
    }
}