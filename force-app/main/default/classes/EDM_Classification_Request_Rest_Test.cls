@isTest
private class EDM_Classification_Request_Rest_Test {
	
	@testSetup static void initConfig() {
		insert new List<GNE_SFA2_S2S_Config_Items_gne__c> {
			new GNE_SFA2_S2S_Config_Items_gne__c(Name = 'S2SEnabled', Key_gne__c = 'S2SEnabled', Value_gne__c = 'TRUE', Is_Active_gne__c = true),
			new GNE_SFA2_S2S_Config_Items_gne__c(Name = 'DisabledFeatures', Key_gne__c = 'DisabledFeatures', Value_gne__c = null, Is_Active_gne__c = true)
		};
	}

	@isTest
	public static void shouldReturnEmptyResults() {
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/ClassificationRequests';

		EDM_Classification_Request_RestUtil.ClassificationRequestResults results =
				EDM_Classification_Request_Rest.getClassificationRequests();

		System.debug(results);
		System.assert(results.isSuccess());
		System.assert(results.getRecords().isEmpty());
	}

	@isTest
	public static void shouldReturnAllResults() {
		initData();
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/ClassificationRequests';

		EDM_Classification_Request_RestUtil.ClassificationRequestResults results =
				EDM_Classification_Request_Rest.getClassificationRequests();

		System.debug(results);
		System.assert(results.isSuccess());
		System.assert(!results.getRecords().isEmpty());
	}

	@isTest
	public static void shouldReturnResultsWithPagination() {
		initData();
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/ClassificationRequests';
		RestContext.request.params.put('start', '1');
		RestContext.request.params.put('limit', '2');

		EDM_Classification_Request_RestUtil.ClassificationRequestResults results =
				EDM_Classification_Request_Rest.getClassificationRequests();

		System.debug(results);
		System.assert(results.isSuccess());
		System.assertEquals(2, results.getRecords().size());
		System.assert(String.isNotBlank(results.next));
	}

	private static void initData() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 1; i <= 3; i++) {
			accounts.add(new Account(Name='testAccount' + i));
		}
		insert accounts;

		RecordType rtBusiness = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Business'];
		RecordType rtClinical = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Clinical'];

		List<EDM_Classification_Request_gne__c> classReqs = new List<EDM_Classification_Request_gne__c> {
			prapareTestReviewedClassReq(accounts.get(0), rtBusiness),
			prapareTestReviewedClassReq(accounts.get(0), rtBusiness),
			prapareTestReviewedClassReq(accounts.get(0), rtClinical),
			prapareTestClassReq(accounts.get(0), rtBusiness),
			prapareTestClassReq(accounts.get(0), rtClinical),
			prapareTestClassReq(accounts.get(1), rtBusiness)
		};

		insert classReqs;
	}

	private static EDM_Classification_Request_gne__c prapareTestClassReq(Account acc, RecordType rt) {
		return new EDM_Classification_Request_gne__c(
				EDM_Account_gne__c = acc.Id,
				EDM_Type_of_Classification_gne__c = rt.DeveloperName,
				RecordTypeId = rt.Id,
				EDM_Pending_Days_gne__c = 0
			);
	}

	private static EDM_Classification_Request_gne__c prapareTestReviewedClassReq(Account acc, RecordType rt) {
		EDM_Classification_Request_gne__c classificationRequest = prapareTestClassReq(acc, rt);
		classificationRequest.EDM_Action_Taken_gne__c = 'Global';
		classificationRequest.EDM_Status_gne__c = 'Completed';
		classificationRequest.EDM_Reviewer_gne__c = UserInfo.getUserId();
		return classificationRequest;
	}

	@isTest
	public static void shouldUpdateSBMCurrentClassificationAndExclusion(){
		Account acc = new Account(Name = 'testAcc');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, Speaker_Status_gne__c = 'Pending');
		insert sbm;
		RecordType rtBusiness = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Business'];
		EDM_Classification_Request_gne__c request = prapareTestReviewedClassReq(acc, rtBusiness);
		insert request;
		
		sbm.Speaker_Status_gne__c = 'Nominated';
		update sbm;
		
		RestContext.request = new RestRequest();
		RestContext.request.requestURI = '/ClassificationRequests';

		EDM_Classification_Request_RestUtil.ClassificationRequestResults results =
				EDM_Classification_Request_Rest.getClassificationRequests();

		Speaker_Bureau_Membership_gne__c sbmAfterUpdate = [SELECT Speaker_Status_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE Id = :sbm.Id LIMIT 1];

		System.debug(results);
		System.assert(results.isSuccess());
		System.assertEquals('Nominated', sbmAfterUpdate.Speaker_Status_gne__c);

	}

}