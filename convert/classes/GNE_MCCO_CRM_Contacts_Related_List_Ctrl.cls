global with sharing class GNE_MCCO_CRM_Contacts_Related_List_Ctrl extends GNE_MCCO_CRM_Base_Ctrl {

    global final Account ACCOUNT_OBJ { get; private set; }
    global String contactListJson { get; private set; }
    global Integer contactCount { get; private set; }
    global Boolean hasContacts { get; private set; }
    global String config { get; private set; }
    
    global String interactionObjectPrefix { get; private set; }
    global String surveyObjectPrefix { get; private set; }
    
    global String userTimeZone { get; private set; }
    global Boolean isCCEsbrietUser { get; private set;}

    global Map<String,Schema.DescribeFieldResult> contactFieldsDescribe { get; set; }

    global GNE_MCCO_CRM_Contacts_Related_List_Ctrl(ApexPages.StandardController stdController) {
        ACCOUNT_OBJ = (Account)stdController.getRecord();
        sObjectType = 'Contact';
        
        List<Contact> contactList = getContacts();
        contactListJson = JSON.serializePretty(contactList);
        contactCount = contactList.size();
        config = JSON.serialize(getMergeSectionsConfiguration('MCCOContact', getAppContext()));
        
        if(!contactList.isEmpty()) {
        	hasContacts = true;
        } else {
        	hasContacts = false;
        }
        
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        
        Schema.DescribeSObjectResult interactionDSR = Call2_vod__c.sObjectType.getDescribe();
        Schema.DescribeSObjectResult surveyDSR = Survey_gne__c.sObjectType.getDescribe();
        
        interactionObjectPrefix = interactionDSR.getKeyPrefix();
        surveyObjectPrefix = surveyDSR.getKeyPrefix();
        isCCEsbrietUser = GNE_SFA2_Util.isEsbrietCrmUser();
    }

    global void getContactDescribe() {
        Schema.DescribeSObjectResult contactDescribe = Schema.getGlobalDescribe().get('Contact').getDescribe();
        Map<String, Schema.SObjectField> objectFields = contactDescribe.fields.getMap();
        contactFieldsDescribe = new Map<String,Schema.DescribeFieldResult>();
        for(String fName : objectFields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
            contactFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
        }
    }
    
    public List<Contact> getContacts() {
    	String profileName = getCurrentUserProfileName();
    	if (profileName == 'GNE-MCCO-340B') {
	    	return [SELECT Id, AccountId, LastName, FirstName, Developer_Title_gne__c, X340B_Contact__c, Has_Opted_Out_gne__c, Phone, Email, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, MailingStreet, MailingCity, MailingState, State_Province_gne__c, MailingPostalCode FROM Contact WHERE AccountId =: ACCOUNT_OBJ.Id AND Active_gne__c = true AND X340B_Contact__c = true ORDER BY LastModifiedDate DESC];	
    	}
    	return [SELECT Id, AccountId, Name, Full_Name_gne__c, LastName, FirstName, Developer_Title_gne__c, X340B_Contact__c, Has_Opted_Out_gne__c, Phone, Email, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, MailingStreet, MailingCity, MailingState, State_Province_gne__c, MailingPostalCode FROM Contact WHERE AccountId =: ACCOUNT_OBJ.Id AND Active_gne__c = true ORDER BY LastModifiedDate DESC];	
    }

    public List<Section> getMergeSectionsConfiguration(String recordTypeDeveloperName, AppContext appContext) {
        List<Section> result = new List<Section>();
        
        getContactDescribe();

        List<SFA2_Configuration_Object_gne__c> configObjects = [
            SELECT Name, Section_Header_gne__c, Order_gne__c, Attributes_gne__c,
                (SELECT Name, API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Read_Only_gne__c, Is_Required_gne__c, Order_gne__c, Type_gne__c, Availability_Mode_gne__c 
                 FROM Configuration_Objects__r WHERE Is_Active_gne__c = true
                 ORDER BY Order_gne__c)
            FROM SFA2_Configuration_Object_gne__c
            WHERE Object_Name_gne__c = :sObjectType AND Role_gne__c = :appContext.role AND Brand_gne__c = :appContext.brand AND Application_Type__c = :appContext.appName
                AND Record_Type_gne__c = :recordTypeDeveloperName AND Is_Active_gne__c = true AND Configuration_Type_gne__c = 'Page'
            ORDER BY Order_gne__c]; 
            
        for (SFA2_Configuration_Object_gne__c conf : configObjects) {
            Section section = readSectionConfig(conf);
            if(section != null) {
                result.add(section);
            }
        }

        return result;
    }

    public Section readSectionConfig(SFA2_Configuration_Object_gne__c conf) {
        Section result = null;
        
        if (!conf.Configuration_Objects__r.isEmpty()) {
            if (conf.Configuration_Objects__r.get(0).Type_gne__c == FIELD || conf.Configuration_Objects__r.get(0).Type_gne__c == BLANK_SPACE || conf.Configuration_Objects__r.get(0).Type_gne__c == LINK) {
                List<Field> fields = new List<Field>();
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                    Schema.DescribeFieldResult fieldDescribe = confDetail.Type_gne__c == FIELD && String.isNotBlank(confDetail.API_Name_gne__c) ? contactFieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase()) : null;
                    if(confDetail.Availability_Mode_gne__c.contains('Edit') && confDetail.Type_gne__c == FIELD) {
                        fields.add(new Field(confDetail, null, null, fieldDescribe, sObjectType));    
                    }
                }

                if(!fields.isEmpty()) {
                    result = new Section(conf, fields);
                }
            }
        }
        
        return result;
    }

    @RemoteAction
    @ReadOnly
    global static Map<Id, Contact> getContactsToMerge(Map<String, String> params) {
        Map<Id, Contact> result = new Map<Id, Contact>();
        String fields = params.get('fields');
        List<Id> contactIds = params.get('contactIds').split(',');

        String query = 'SELECT Id, ' + fields + ' FROM Contact WHERE ID IN : contactIds';
        for(Contact c : Database.query(query)) {
            result.put(c.Id, c);
        } 

        return result;
    }

    @RemoteAction
    global static List<Contact> mergeContacts(Map<String, String> params) {
        Map<String, String> mergeContactFields = (Map<String, String>)JSON.deserialize(params.get('mergeContactFields'), Map<String, String>.class);
        List<String> inactiveContacts = (List<String>)JSON.deserialize(params.get('inactiveContacts'), List<String>.class);
        String accountId = params.get('accountId');

        List<SObject> contactsToUpsert = new List<SObject>();

        SObject mergeRecord = (SObject)Type.forName('Contact').newInstance();

        for(String fieldName : mergeContactFields.keySet()) {
                if(fieldName != 'undefined') {
                    if(mergeContactFields.get(fieldName) == 'true' || mergeContactFields.get(fieldName) == 'false') {
                        mergeRecord.put(fieldName, Boolean.valueOf(mergeContactFields.get(fieldName)));
                    } else {
                        mergeRecord.put(fieldName, mergeContactFields.get(fieldName));
                    }
                }
        }

        contactsToUpsert.add(mergeRecord);

        for(String id : inactiveContacts) {
            SObject deactivateRecord = (SObject)Type.forName('Contact').newInstance();
            deactivateRecord.put('Id', id);
            deactivateRecord.put('Active_gne__c', false);
            contactsToUpsert.add(deactivateRecord);
        }

        if(!contactsToUpsert.isEmpty()) {
            update contactsToUpsert;
        }

        return [SELECT Id, LastName, FirstName, X340B_Contact__c, Developer_Title_gne__c, Phone, Email, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name FROM Contact WHERE AccountId =: accountId AND Active_gne__c = true ORDER BY LastModifiedDate DESC];
    }

}