@isTest
public with sharing class GNE_SFA2_Canada_RefreshQueAccBatch_Test {

	@isTest
	public static void testExecuteMethod() {
		String territory = '00AB-Test Territory';
        Territory2 terr = createTerritory('00AB-Test Territory','root;00AB-Test Territory','root');
		User user = [SELECT Id FROM User WHERE Name = 'Marcus Horeak'];
		Questionnaire_gne__c questionnaire;
		System.runAs(user) {
			questionnaire = createQuestionnaire('Per Account', territory);
			System.debug(questionnaire.Id);
			Account account = createAccount('Clinical Nurse Specialist');
			Address_vod__c address = createAddress(account);
			TSF_vod__c tsf = createTSFRecord(account.Id + territory, address.Id, territory, true, account);
			TSF_vod__c accountTsf = [SELECT Id FROM TSF_vod__c WHERE Account_vod__c = :account.Id];
		}
		Account account = [SELECT Id FROM Account WHERE FirstName='Test FName' AND LastName='Test LName'];
		TSF_vod__c accountTsf = [SELECT Id FROM TSF_vod__c WHERE Account_vod__c = :account.Id];
		Product_vod__c product = createProduct();
		Product_vod__c queriedProduct = [SELECT Id FROM Product_vod__c WHERE Id = :product.Id];
		My_Setup_Products_vod__c mySetupProduct = createMySetupProduct(queriedProduct);
		Targets_and_Tiers_can_gne__c tier = createTiers(product.Id, accountTsf, 'LOw', territory);

		Test.startTest();
		GNE_SFA2_Canada_RefreshQueAccountsBatch batchToRun = new GNE_SFA2_Canada_RefreshQueAccountsBatch();
		Database.executeBatch(batchToRun);
		Test.stopTest();

		List<QuestionnaireAccount_gne__c> questionnaireAccounts = [SELECT Id, Questionnaire_gne__c FROM QuestionnaireAccount_gne__c WHERE Account__c = :account.Id];
		System.assertNotEquals(0, questionnaireAccounts.size());
		System.assertEquals(1, questionnaireAccounts.size());
		System.assertEquals(questionnaireAccounts[0].Questionnaire_gne__c, questionnaire.Id);
	}

	private static Questionnaire_gne__c createQuestionnaire(String singleSurveyPerMode, String territories) {
		Questionnaire_gne__c questionnaire = new Questionnaire_gne__c(Single_Survey_per_Mode_gne__c = singleSurveyPerMode, Territories_can_gne__c = territories,
			Freeze_Surveys_gne__c = false, Hide_Surveys_gne__c = false);
		insert questionnaire;
		return questionnaire;
	}

	private static Account createAccount(String accountType) {
		String recTypeId= [select Id, Name, SobjectType from RecordType WHERE SobjectType = 'Account' And Name = 'HCP Canada'].Id;
		Account account = new Account(Account_Type_gne__c = accountType, RecordTypeId = recTypeId,
			FirstName='Test FName',
          	LastName='Test LName',
          	PersonMailingStreet='test@gmail.com',
          	PersonMailingPostalCode='12345',
          	PersonMailingCity='SFO',
          	PersonEmail='test@gmail.com',
          	PersonHomePhone='1234567',
          	PersonMobilePhone='12345678');
		insert account;
		return account;
	}

	private static TSF_vod__c createTSFRecord(String externaId, Id addressId, String territory, Boolean myTarget, Account account) {
		TSF_vod__c tsf = new TSF_vod__c(External_Id_vod__C = externaId , Address_vod__c = addressId, Account_vod__c = account.Id , 
			Territory_vod__c = territory, My_Target_vod__c = myTarget, Account_vod__r = account);
		insert tsf;
		return tsf;
	}

	private static Address_vod__c createAddress(Account account) {
		Address_vod__c address = new Address_vod__c(Name = 'Test Address', Account_vod__c = account.Id, Account_vod__r = account);
		insert address;
		return address;
	}

	private static Targets_and_Tiers_can_gne__c createTiers(Id productId, TSF_vod__c accountTsf, String myTarget, String territory) {
		Targets_and_Tiers_can_gne__c newTier = new Targets_and_Tiers_can_gne__c(Product_Catalog_gne__c = productId, 
			Territory_field_parent_gne__c = accountTsf.Id, Territory_field_parent_gne__r = accountTsf,
			My_Target_gne__c = myTarget, Territory_gne__c = territory);
		insert newTier;
		return newTier;
	}

	private static Product_vod__c createProduct() {
		Product_vod__c product = new Product_vod__c(Name = 'Test', Brand_Code_gne__c = 'TEST');
		insert product;
		return product;
	}

	private static My_Setup_Products_vod__c createMySetupProduct(Product_vod__c product) {
		My_Setup_Products_vod__c mySetupProduct = new My_Setup_Products_vod__c(Product_vod__c = product.Id, Product_vod__r = product);
		insert mySetupProduct;
		return mySetupProduct;
	}
    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId) {
        return createTerritory(territoryName, externalId, parentExternalId, null, null, null);
    }

    static private Territory2 createTerritory(String territoryName, String externalId, String parentExternalId, String description, Date endDate, String source ) {

        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        Territory2 territory;
        Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
        Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;

        System.runAs (thisUser) {
            territory = new Territory2();
            territory.Name = territoryName;
            territory.DeveloperName = 'DM_' + territoryName.replaceAll('[|\\,| |\\.|\\,|\\"|\\:|\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_|\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
            territory.Territory2ModelId = terrModelId;
            territory.Territory2TypeId = terrTypeId;
            territory.external_id_gne__c = externalId;
            territory.parent_external_id_gne__c = parentExternalId;
            territory.Description = description;
            territory.End_Date__c = endDate;
            territory.Source_gne__c = source;

            insert territory;
        }

        return territory;
    }
}