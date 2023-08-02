@isTest
public with sharing class GNE_SFA2_PREP_InteractionCtrl_Test {
	private static void init() {
		GNE_SFA2_PREP_Test_Helper.init();
		GNE_SFA2_PREP_Test_Helper.insertEducationalItems();
		GNE_SFA2_PREP_Test_Helper.insertPrepInteractionCOs();
	}
	
	private static void init(String userRole, Integer accountSize) {
		GNE_SFA2_PREP_Test_Helper.init(userRole, accountSize);
		GNE_SFA2_PREP_Test_Helper.insertPrepInteractionCOs();
	}
	
	private static List<Call2_vod__c> insertCalls(Id accId, Set<Id> attedessIds) {
		Address_vod__c addr = GNE_SFA2_PREP_Test_Helper.accountHelper.accountsCache.get(accId).Address_vod__r[0];
		Id recTypeId = new List<Id>(GNE_SFA2_PREP_Util.getPrepInteractionRecordTypeIds())[0];
		Id ownerId = GNE_SFA2_PREP_Test_Helper.getCurrentUser().Id;
		List<Call2_vod__c> calls = new List<Call2_vod__c>();
		calls.add(new Call2_vod__c(OwnerId = ownerId, RecordTypeId = recTypeId, 
				Account_vod__c = accId, Parent_Address_vod__c = addr.Id,
				Address_vod__c = (addr.Name + ', ' + addr.City_vod__c), 
				Call_Datetime_vod__c = System.now(),
				Interaction_Type_gne__c = 'Dinner Program',
				Interaction_Status_gne__c = 'Planned',
				Interaction_Length_gne__c = '30-60 min',
				PREP_Follow_Up_With_gne__c = 'SONY CORLEONE'
		));
		
		insert calls;
		
		List<Product_vod__c> prepProds = GNE_SFA2_PREP_Test_Helper.prepProds;
		
		Map<Id,SFA2_PREP_MBO_gne__c> mbos = new Map<Id,SFA2_PREP_MBO_gne__c>();
		
		for(SFA2_PREP_MBO_gne__c mbo : GNE_SFA2_PREP_Test_Helper.mbos) {
			if(!mbos.containsKey(mbo.Testing_Strategy_ref_gne__r.Product_gne__c)) {
				mbos.put(mbo.Testing_Strategy_ref_gne__r.Product_gne__c, mbo);
			}
		}
		
		Map<Id,Product_vod__c> eduItems = new Map<Id,Product_vod__c>();
		
		for(Product_vod__c eduItem : GNE_SFA2_PREP_Test_Helper.eduItems) {
			if(!eduItems.containsKey(eduItem.Parent_Product_vod__c)) {
				eduItems.put(eduItem.Parent_Product_vod__c, eduItem);
			}
		}
		
		List<Call2_vod__c> attCalls = new List<Call2_vod__c>();
		List<Call2_Detail_vod__c> callDetails = new List<Call2_Detail_vod__c>();
		List<Call2_Discussion_vod__c> callDiscs = new List<Call2_Discussion_vod__c>();
		List<Call2_Sample_vod__c> callSamples = new List<Call2_Sample_vod__c>();
		List<Call_PREP_MBO_gne__c> callMbos = new List<Call_PREP_MBO_gne__c>();
		
		for(Call2_vod__c mainCall : calls) {
			for(Id hcpId : attedessIds) {
				Call2_vod__c attCall = mainCall.clone(false);
				attCall.Account_vod__c = hcpId;
				attCall.Parent_Call_vod__c = mainCall.id;
				attCall.Attendee_Type_vod__c = 'Person_Account_vod';
				attCalls.add(attCall);
			}
			
			Integer prio = 0;
			for(Product_vod__c prepProd : prepProds) {
				Call2_Detail_vod__c cDetail = new Call2_Detail_vod__c(Detail_Priority_vod__c = prio++, Call2_vod__c = mainCall.Id, Product_vod__c = prepProd.Id);
				Call2_Discussion_vod__c cDisc = new Call2_Discussion_vod__c(Detail_Priority_gne__c = prio++, Call2_vod__c = mainCall.Id, Product_vod__c = prepProd.Id,
						Account_vod__c = accId,
						PREP_MBO_gne__c = mbos.get(prepProd.Id).Id
				);
				
				callDetails.add(cDetail);
				callDiscs.add(cDisc);
			}
			
			for(Product_vod__c eduItem : eduItems.values()) {
				Call2_Sample_vod__c cSample = new Call2_Sample_vod__c(Call2_vod__c = mainCall.Id, Product_vod__c = eduItem.Id, 
						Account_vod__c = attCalls[0].Account_vod__c, Quantity_vod__c = 1
				);
				
				callSamples.add(cSample);
			}
			
			List<SFA2_PREP_MBO_gne__c> mboList = mbos.values();
			callMbos.add(new Call_PREP_MBO_gne__c(Call_gne__c = mainCall.Id, MBO_gne__c = mboList[0].Id));
			callMbos.add(new Call_PREP_MBO_gne__c(Call_gne__c = mainCall.Id, MBO_gne__c = mboList[1].Id));
		}
		
		insert attCalls;
		insert callDetails;
		insert callDiscs;
		insert callSamples;
		insert callMbos;
		
		return calls;
	}
	
	private static String getPageMessagesSummary(ApexPages.Message[] msgs) {
		List<String> summaries = new List<String>();
		
		for(ApexPages.Message msg : msgs) {
			summaries.add(msg.getSummary());
		}
		
		return String.join(summaries,'\n');
	} 
	
	private  static void testInitViewMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		Set<Id> attIds = GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP');
		List<Call2_vod__c> calls = insertCalls(accId, attIds);
			
		GNE_SFA2_Interaction_Controller ctrl;
		PageReference pRef;

		Test.startTest();
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_Interaction_Layout;
			pageRef.getParameters().put('id', calls[0].id);
			Test.setCurrentPage(pageRef);
			ctrl = new GNE_SFA2_Interaction_Controller();
        	pRef = ctrl.init();
		}
       	Test.stopTest();
		
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.prepController, 'PREP Controller is null');
		System.assert(ctrl.prepController.isPrepAvailable, 'PREP feature is not available');
		System.assertNotEquals(null, ctrl.prepController.selectedMboIds, 'MBOs (Next Steps) not selected');
		System.assertNotEquals(null, ctrl.call.PREP_MBOs_gne__c, 'MBOs (Next Steps) not selected (View Mode)');
		System.assertEquals([SELECT count() FROM SFA2_PREP_MBO_gne__c] + 2, ctrl.prepController.mboShortDescriptionsMap.size(), 'Wrong number of MBO Short Descriptions');
		System.assertEquals([SELECT Product_gne__c FROM SFA2_PREP_Testing_Strategy_gne__c GROUP BY Product_gne__c].size() + 2, ctrl.prepController.productToMboMap.size(), 'Wrong number of PREP Products');
	}
	
	private TestMethod static void testSaveEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		List<Id> attIds = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'));
		List<Call2_vod__c> calls = insertCalls(accId, new Set<Id>{attIds[0]});
		
		GNE_SFA2_Interaction_Controller ctrl;
		PageReference pRef;
		List<String> queryLimits = new List<String>();
		Id id1;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			queryLimits.add('limitsAfterRunAs = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
			PageReference pageRef = Page.GNE_SFA2_Interaction_Edit_Create;
			pageRef.getParameters().put('id', calls[0].id);
			Test.setCurrentPage(pageRef);
			ctrl = new GNE_SFA2_Interaction_Controller();
			queryLimits.add('limitsAfterCtrlCreate = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        	pRef = ctrl.init();
        	queryLimits.add('limitsAfterCtrlInit = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        	ctrl.prepController.selectedMboIds = ctrl.prepController.selectedMboIds.split(';')[0];
        	
        	Account newAttAcc = GNE_SFA2_PREP_Test_Helper.accountHelper.accountsCache.get(attIds[1]);
        	List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> newAttendees = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>{
        		new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(newAttAcc, newAttAcc.Address_vod__r[0])
        	};
        	
        	//Account acc = [ SELECT isPersonAccount FROM Account WHERE Id = :accId ];
        	//acc.isPersonAccount = true;
        	//update acc;
        	ctrl.selectedAccountsJSON = JSON.serialize(newAttendees);
        	ctrl.addAttendees();
        	queryLimits.add('limitsBeforeTestStart = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        	Test.startTest();
        	queryLimits.add('limitsAfterTestStart = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        	queryLimits.add('limitsBeforeSaveAndComplete = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        	pRef = ctrl.saveAndComplete();
        	queryLimits.add('limitsAfterSaveAndComplete = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
			Test.stopTest();
			queryLimits.add('limitsAfterTestStop = ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
			id1 = UserInfo.getProfileId();
		}
		
		//System.assert(false, 'Limits timestamps: ' + String.join(queryLimits,'\n'));
		System.assertNotEquals(null, pRef, 'PageReference is null. Raised Errors: ' );
		System.assert(ctrl.prepController.isPrepAvailable, 'PREP feature is not available');
		System.assertNotEquals(null, ctrl.prepController.selectedMboIds, 'MBOs (Next Steps) not selected');
		System.assertEquals(2, [SELECT count() FROM Call2_vod__c WHERE Parent_Call_vod__c = :ctrl.call.Id], 'Two Call Attendees should be in Database. Page URL: ' + pRef.getURL());
		System.assertEquals(1, [SELECT count() FROM Call_PREP_MBO_gne__c WHERE Call_gne__c = :ctrl.call.Id], 'Only one Call MBO (Next Steps) should be in Database. Page URL: ' + pRef.getURL());
	}
	
	private  static void testCaclulateAttendeePrepType() {
		init();
		List<Id> attIds = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'));
		List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> hcpWrappers = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
		
		for(Id hcpId : attIds) {
			Account newAttAcc = GNE_SFA2_PREP_Test_Helper.accountHelper.accountsCache.get(hcpId);
			hcpWrappers.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(newAttAcc, newAttAcc.Address_vod__r[0]));
		}
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			Test.startTest();
			GNE_SFA2_PREP_Interaction_Controller.onGetAffiliatedAccounts(hcpWrappers);
			Test.stopTest();
		}
		
		for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper hcpWrapper : hcpWrappers) {
			System.assertEquals('HCP - Other', hcpWrapper.recordType, 'Wrong HCP Wrapper Type');
		}
	}
	
	private  static void testAddAffiliatedHcpEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		Set<Id> attIds = GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP');
		List<Call2_vod__c> calls = insertCalls(accId, attIds);
		
		GNE_SFA2_Interaction_Controller ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_Interaction_Edit_Create;
			pageRef.getParameters().put('id', calls[0].id);
			Test.setCurrentPage(pageRef);
			ctrl = new GNE_SFA2_Interaction_Controller();
			pRef = ctrl.init();
			Test.startTest();
			pRef = ctrl.prepController.affiliatedAccountSelected(0);
			Test.stopTest();
        	
		}
		
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		
		for(GNE_SFA2_Interaction_Controller.AttendeeWrapper attWrapper : ctrl.attendees) {
			System.assertEquals('HCP - Other', attWrapper.attendeeType, 'Wrong Attendee Wrapper Type');
		}
	}
	
	private  static void testDiscussionMboChangeEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		Set<Id> attIds = GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP');
		List<Call2_vod__c> calls = insertCalls(accId, attIds);
		
		GNE_SFA2_Interaction_Controller ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_Interaction_Edit_Create;
			pageRef.getParameters().put('id', calls[0].id);
			Test.setCurrentPage(pageRef);
			ctrl = new GNE_SFA2_Interaction_Controller();
			pRef = ctrl.init();
			Test.startTest();
			ctrl.prepController.discussionIndex = 0;
			ctrl.prepController.productMboParam = null;
			ctrl.prepController.postPrepMboValue();
			Test.stopTest();
        	
		}
		
		System.assertEquals(null, ctrl.discussions[0].callDiscussion.PREP_MBO_gne__c, 'First Test Discussion\'s MBO should be null');
		System.assertNotEquals(null, ctrl.discussions[1].callDiscussion.PREP_MBO_gne__c, 'Second Test Discussion\'s MBO should be set');
	}
}