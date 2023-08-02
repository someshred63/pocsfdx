@isTest
public class GNE_FRM_TestUtilities {
    public static Map<String, Id> name2RtId;
    private static Integer s_num = 1;
    private static Territory2Model terrModel;
    private static Territory2Type terrType;

    public static Map<String, Id> getAccountRecordTypes() {
        if (name2RtId != null) {
            return name2RtId;
        }
        name2RtId = new Map<String, Id>();
        RecordType[] typesArray = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Account'];
        for (RecordType rt : typesArray) {
            name2RtId.put(rt.DeveloperName, rt.Id);
        }
        return name2RtId;
    }

    public static Map<String, Id> getProfiles() {
        Map<String, Id> ids2ProfilesMap = new Map<String, Id>();
        Profile[] profilesArray = [SELECT Name FROM Profile WHERE Name = 'System Administrator' OR Name LIKE 'GNE-%' OR Name LIKE 'RCanada%'];
        for (Profile profile : profilesArray) {
            ids2ProfilesMap.put(profile.Name, profile.Id);
        }
        return ids2ProfilesMap;
    }

    public static User createUser(String name, Id profileId, Boolean toInsert) {
        User user = new User(
            Alias = 'standt',
            Email = name + 'user@gene.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = name + 'user@gene.com'
        );
        if (toInsert) insert user;
        return user;
    }

    public static FRM_Rep_2_Terr_gne__c createRep2Terr(Boolean toInsert) {
        FRM_Rep_2_Terr_gne__c record = new FRM_Rep_2_Terr_gne__c();
        return record;
        if (toInsert) insert record;
        return record;
    }

    public static Territory2 createTerritory(String name, Id parentTerritoryId, Boolean toInsert) {
        Territory2 record = new Territory2(
            Name = name,
            DeveloperName = 'DM_' + name.replaceAll('[|\\,|\\.|\\,||"||\\:|\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_|\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ''),
            ParentTerritory2Id = parentTerritoryId,
            Territory2ModelId = getTerrModelId(),
            Territory2TypeId = getTerrTypeId()
        );
        if (toInsert) insert record;
        return record;
    }
    
    private static Id getTerrModelId() {
    	Id result;
    	if (terrModel == null) {
    		terrModel = [SELECT Id FROM Territory2Model LIMIT 1];
    	}
    	
    	result = terrModel.Id;
    	return result;
    }
    
    private static Id getTerrTypeId() {
    	Id result;
    	if (terrType == null) {
    		terrType = [SELECT Id FROM Territory2Type LIMIT 1];
    	}
    	
    	result = terrType.Id;
    	return result;
    }

    public static Account createAccount(String name, String recordTypeName, String typeName, Boolean toInsert) {
        return createAccount(name, recordTypeName, typeName, toInsert, false);
    }

    public static Account createAccount(String name, String recordTypeName, String typeName, Boolean toInsert, Boolean isPersonAccount) {
        Account record = null;
        if (!isPersonAccount) {
            record = new Account(
                Name = name,
                RecordTypeId = getAccountRecordTypes().get(recordTypeName),
                Account_Type_gne__c = typeName
            );
        } else {
            record = new Account(
                FirstName = name.split(' ')[0],
                LastName = name.split(' ')[1],
                RecordTypeId = getAccountRecordTypes().get(recordTypeName),
                Account_Type_gne__c = typeName
            );
        }

        if (toInsert) {
            insert record;
        }

        return record;
    }

    public static Address_vod__c createAddress(String name, Id accId, String city, String state, String zip, Boolean toInsert) {
        Address_vod__c record = new Address_vod__c(
            Name = name,
            Account_vod__c = accId,
            City_vod__c = city,
            State_vod__c = state,
            Zip_vod__c = zip
        );
        if (toInsert) insert record;
        return record;
    }

    public class CalloutMock implements HttpCalloutMock {
        public String response {get; set;}
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(response);
            return res;
        }
    }

    public static String getFakeId(Schema.SObjectType sot) {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
    }

    public static void createSchedulerConfig() {
        Set<String> jobNames = new Set<String>{
                'CRON:GNE_SFA2_AccountShare:1', 'CRON:GNE_SFA2_HCPtoFRMHCOMapping:1', 'CRON:GNE_CRM_HPSM_Create_Incident:1', 'CRON:GNE_CRM_HPSM_Update_Incident:1', 'CRON:GNE_FRM_Sync_Records_MDM:1', 'CRON:GNE_FRM_Rep2Territory:1'
        };

        delete [SELECT Id FROM GNE_Batch_Runner_Config_Items_gne__c WHERE Name IN :jobNames];

        Map<String, List<String>> CRONsForBatch = new Map<String, List<String>>();
        List<GNE_Batch_Runner_Config_Items_gne__c> configToUpsert = new List<GNE_Batch_Runner_Config_Items_gne__c>();

        CRONsForBatch.put('CRON:GNE_SFA2_AccountShare:1', new List<String>{
                '0 0 * * * ?', '0 10 * * * ?', '0 20 * * * ?', '0 30 * * * ?', '0 40 * * * ?', '0 50 * * * ?'
        });

        CRONsForBatch.put('CRON:GNE_SFA2_HCPtoFRMHCOMapping:1', new List<String>{
                '0 0 * * * ?', '0 15 * * * ?', '0 30 * * * ?', '0 45 * * * ?'
        });

        CRONsForBatch.put('CRON:GNE_CRM_HPSM_Create_Incident:1', new List<String>{
                '0 10 * ? * *', '0 40 * ? * *'
        });

        CRONsForBatch.put('CRON:GNE_CRM_HPSM_Update_Incident:1', new List<String>{
                '0 10 * ? * *', '0 40 * ? * *'
        });

        CRONsForBatch.put('CRON:GNE_FRM_Sync_Records_MDM:1', new List<String>{
                '0 0 * * * ?', '0 30 * * * ?'
        });

        CRONsForBatch.put('CRON:GNE_FRM_Rep2Territory:1', new List<String>{
                '0 15 * * * ?', '0 45 * * * ?'
        });

        for (String key : CRONsForBatch.keySet()) {
            Integer scheduleIndex = 1;
            for (String cron : CRONsForBatch.get(key)) {
                GNE_Batch_Runner_Config_Items_gne__c configItem = new GNE_Batch_Runner_Config_Items_gne__c();
                String newKeyCalc = key.removeEnd('1') + scheduleIndex;
                configItem.Name = newKeyCalc;
                configItem.Key_gne__c = newKeyCalc;
                configItem.Value_gne__c = cron;
                configToUpsert.add(configItem);
                scheduleIndex++;
            }
        }

        insert configToUpsert;
    }
}