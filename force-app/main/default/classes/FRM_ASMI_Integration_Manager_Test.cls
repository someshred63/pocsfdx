@isTest
private class FRM_ASMI_Integration_Manager_Test {
	private static User nofrmUser;
	private static Account account;
	private static Product_vod__c product;
	private static Call2_vod__c call;
	private static Map<String, Product_Strategy_vod__c> strategies;
	private static List<Call2_Discussion_vod__c> discussions;

	@testSetup
	static void setupCustomSetting() {
		List<SFA2_FRM_ASMI_Mapping__c> mappings = new List<SFA2_FRM_ASMI_Mapping__c>();
        mappings.add(new SFA2_FRM_ASMI_Mapping__c(
            ASMI_Product_Name_gne__c = 'Avastin', 
            Mapping_Type_gne__c = 'PRODUCT', 
            FRM_Product_Name_gne__c = 'Avastin - mCRC', 
            Name = 'Avastin - mCRC'
        ));

		insert mappings;

        List<User> usersToInsertList = new List<User>{
            new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-Field' LIMIT 1].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Email = 'us@gene.com',
                FirstName = 'usUser',
                External_ID_gne__c = 'ustest',
                Alias = 'ustest',
                Username = 'UsTest@gene.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                LastName = 'User',
                IsActive = true
            )
        };

		insert usersToInsertList;
	}

	static void setupUser() {
		nofrmUser = getNoFRMUser();
	}

	static void setupCallWithDiscussion(String strategyName, Boolean toASMI) {
		
		account = getAccount();
		insert account;
		product = getProduct();
		insert product;
		call = getCall(account);
		insert call;
		strategies = getStrategiesByName();
		insert strategies.values();
		Product_Strategy_vod__c strategy = strategies.get(strategyName);
		discussions = new List<Call2_Discussion_vod__c>();
		discussions.add(getDiscussion(call, product, strategy, toASMI));
		insert discussions;
	}
	
	@isTest 
	static void shouldGenerateASMI() {
		//given
		setupUser();
		System.runAs(nofrmUser) {
			setupCallWithDiscussion('Patient Access Issue – Benefits Verification', true);
		
		//when
			FRM_ASMI_Integration_Manager manager = new FRM_ASMI_Integration_Manager(call, discussions);
			if (manager.shouldCreateMarketInsigts()) {
				manager.createMarketInsigts();
			}
		}
		
		//then
		List<Market_Insight_gne__c> newInsights = [SELECT Id, Product_gne__c FROM Market_Insight_gne__c];
		System.assert(newInsights.size() == 0);
	}

	@isTest 
	static void shouldGenerateASMIwithNormalizedProduct() {
		//given
		setupUser();
		System.runAs(nofrmUser) {
			setupCallWithDiscussion('Patient Access Issue – Benefits Verification', true);
			product.Name = '      Avastin         -        mCRC       ';
			update product;
		
		//when
			FRM_ASMI_Integration_Manager manager = new FRM_ASMI_Integration_Manager(call, discussions);
			if (manager.shouldCreateMarketInsigts()) {
				manager.createMarketInsigts();
			}
		}
		
		//then
		List<Market_Insight_gne__c> newInsights = [SELECT Id, Product_gne__c FROM Market_Insight_gne__c];
		System.assert(newInsights.size() == 0);
	}

	@isTest 
	static void shouldGenerateASMIwithEmptyProduct() {
		//given
		setupUser();
		System.runAs(nofrmUser) {
			setupCallWithDiscussion('Patient Access Issue – Benefits Verification', true);
			product.Name = 'Dummy name';
			update product;
		
		//when
			FRM_ASMI_Integration_Manager manager = new FRM_ASMI_Integration_Manager(call, discussions);
			if (manager.shouldCreateMarketInsigts()) {
				manager.createMarketInsigts();
			}
		}
		
		//then
		List<Market_Insight_gne__c> newInsights = [SELECT Id, Product_gne__c FROM Market_Insight_gne__c];
		System.assert(newInsights.size() == 0);
	}

	@isTest 
	static void shouldNotGenerateASMIBecauseOfUser() {
		//given
		setupUser();
		setupCallWithDiscussion('Patient Access Issue – Benefits Verification', true);
		
		//when
		FRM_ASMI_Integration_Manager manager = new FRM_ASMI_Integration_Manager(call, discussions);
		if (manager.shouldCreateMarketInsigts()) {
			manager.createMarketInsigts();
		}

		//then
		List<Market_Insight_gne__c> newInsights = [SELECT Id FROM Market_Insight_gne__c];
		System.assert(newInsights.size() == 0);
	}
	
	@isTest 
	static void shouldNotGenerateASMIBecauseOfStrategy() {
		//given
		setupUser();
		System.runAs(nofrmUser) {
			setupCallWithDiscussion('Dummy Strategy', true);
			
			//when
			FRM_ASMI_Integration_Manager manager = new FRM_ASMI_Integration_Manager(call, discussions);
			if (manager.shouldCreateMarketInsigts()) {
				manager.createMarketInsigts();
			}
		}
		//then
		List<Market_Insight_gne__c> newInsights = [SELECT Id FROM Market_Insight_gne__c];
		System.assert(newInsights.size() == 0);
	}

	@isTest 
	static void shouldNotGenerateASMIBecauseOfASMIFalse() {
		//given
		setupUser();
		System.runAs(nofrmUser) {
			setupCallWithDiscussion('Patient Access Issue – Benefits Verification', false);
			List<GNE_SFA2_Interaction_Controller.DiscussionWrapper> wrappedDicussions = wrapDicussions(discussions);

			//when
			FRM_ASMI_Integration_Manager manager = new FRM_ASMI_Integration_Manager(call, wrappedDicussions);
			if (manager.shouldCreateMarketInsigts()) {
				manager.createMarketInsigts();
			}
		}
		//then
		List<Market_Insight_gne__c> newInsights = [SELECT Id FROM Market_Insight_gne__c];
		System.assert(newInsights.size() == 0);
	}
	

	private static Account getAccount() {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Professional_vod' limit 1];
		Account acc = new Account();
		acc.RecordTypeId = rt.Id;
		acc.FirstName = 'firstName';
		acc.LastName = 'SomeAccount';
		return acc;
	}

	private static Call2_vod__c getCall(Account acc) {
		Call2_vod__c call2 = new Call2_vod__c();
		call2.Account_vod__c = acc.Id;
		call2.Call_Datetime_vod__c = Datetime.now();
		call2.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Call2_vod__c' limit 1].Id;
		call2.Interaction_Status_gne__c = 'Planned';
		call2.Interaction_Type_gne__c = '1:1 Training/Deck Update';
		call2.Interaction_Method_gne__c = 'Email';
		call2.HCP_Account_Meal_Opt_Out_gne__c = false;
		call2.Meal_Expense_gne__c = false;
		call2.Completed_gne__c = true;
		call2.Date_Completed_gne__c = Date.today();
		return call2;
	}

	private static Call2_Discussion_vod__c getDiscussion(Call2_vod__c call2, Product_vod__c prod, Product_Strategy_vod__c strategy, Boolean toASMI) {
		Call2_Discussion_vod__c diss = new Call2_Discussion_vod__c();
		diss.Call2_vod__c = call2.Id;
		diss.Product_vod__c = prod.Id;
		diss.zvod_Product_Map_vod__c = prod.Name;
		diss.FRM_Team_gne__c = 'BFRM';
		diss.Product_Strategy_vod__c = strategy.Id;
		diss.FRM_Issue_Diagnosed_gne__c = false;
		diss.FRM_Issue_Triaged_gne__c = false;
		diss.FRM_Patients_Impacted_gne__c = 2;
		diss.FRM_Complex_Issue_gne__c = false;
		diss.FRM_Issue_Resolved_gne__c = false;
		diss.FRM_Issue_entered_into_ASMI_gne__c = toASMI;
		return diss;
	}

	private static Product_vod__c getProduct() {
		Product_vod__c prod = new Product_vod__c();
		prod.Name = 'Avastin - mCRC';
		return prod;
	}

	private static Map<String, Product_Strategy_vod__c> getStrategiesByName() {
		Map<String, Product_Strategy_vod__c> strats = new Map<String, Product_Strategy_vod__c>();
		List<String> namesToCreate = new List<String> { 'Dummy Strategy', 'Patient Access Issue – Benefits Verification', 'Patient Access Issue – Claims Processing' };

		for(String name : namesToCreate) {
			strats.put(name, new Product_Strategy_vod__c(Name = name));
		}

		return strats;
	}

	private static List<GNE_SFA2_Interaction_Controller.DiscussionWrapper> wrapDicussions(List<Call2_Discussion_vod__c> discs) {
		List<GNE_SFA2_Interaction_Controller.DiscussionWrapper> wrappedDicussions = new List<GNE_SFA2_Interaction_Controller.DiscussionWrapper>();
		Integer i = 0;
		for (Call2_Discussion_vod__c disc : discs) {
			wrappedDicussions.add(new GNE_SFA2_Interaction_Controller.DiscussionWrapper(i++, disc, 
																						new List<SelectOption>(), 
																						new List<SelectOption>(), 
																						new GNE_SFA2_PREP_Interaction_Controller(new GNE_SFA2_Interaction_Controller())));
		}
		return wrappedDicussions;
	}

	public static User getNoFRMUser() {
		return [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'GNE-Field' LIMIT 1];
	}
}