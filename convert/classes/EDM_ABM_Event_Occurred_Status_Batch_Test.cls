@isTest
private class EDM_ABM_Event_Occurred_Status_Batch_Test{

	@isTest
	public static void shouldNotChangeIABPStatusToOccuredWhenEndDateIsTomorrow() {
		insertTestIABP('IABP Approved', Date.today(), Date.today() + 1);

		Test.startTest();
		EDM_ABM_Event_Occurred_Status_Batch b = new EDM_ABM_Event_Occurred_Status_Batch();
		database.executebatch(b);
		Test.stopTest();

		assertIABPinStatus('IABP Approved');
	}

	@isTest
	public static void shouldChangeIABPStatusToOccuredWhenEndDateIsToday() {
		insertTestIABP('IABP Approved', Date.today() - 1, Date.today());

		Test.startTest();
		EDM_ABM_Event_Occurred_Status_Batch b = new EDM_ABM_Event_Occurred_Status_Batch();
		database.executebatch(b);
		Test.stopTest();

		assertIABPinStatus('Event Occurred');
	}

	private static void insertTestIABP(String status, Date startDate, Date endDate) {
		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2016',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;

		insert new EDM_IABP_gne__c(
			EDM_IABP_Version_gne__c = 1,
			EDM_Status_gne__c = status,
			EDM_Start_Date_gne__c = startDate,
			EDM_End_Date_gne__c = endDate,
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Type_of_Event_gne__c = 'TestEvent'
		);
	}

	private static void assertIABPinStatus(String status) {
		List<EDM_IABP_gne__c> iabps = [Select EDM_Status_gne__c, EDM_Type_of_Event_gne__c,EDM_IABP_Version_gne__c  From EDM_IABP_gne__c];
		System.assertEquals(2, iabps.size());
		System.assertEquals(status, iabps.get(0).EDM_Status_gne__c);
	}

	public static testMethod void batchTest(){

		List<EDM_IABP_gne__c> IABPs = new List<EDM_IABP_gne__c>();

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		IABPs.add(new EDM_IABP_gne__c(
			EDM_IABP_Version_gne__c = 1,
			EDM_Status_gne__c = 'IABP Not Started',
			EDM_Start_Date_gne__c = Date.today()-5,
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Type_of_Event_gne__c = 'TestEvent'
		));
		IABPs.add(new EDM_IABP_gne__c(
			EDM_IABP_Version_gne__c = 1,
			EDM_Status_gne__c = 'IABP Not Started',
			EDM_Start_Date_gne__c = Date.today(),
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Type_of_Event_gne__c = 'TestEvent'
		));
		insert IABPs;

		EDM_IABP_gne__c historyIABP1 = new EDM_IABP_gne__c(
			EDM_IABP_Version_gne__c = 10,
			EDM_Status_gne__c = 'IABP Approved',
			EDM_Start_Date_gne__c = Date.today(),
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Type_of_Event_gne__c = 'OldTestEvent',
			EDM_History_Parent_IABP_gn__c = IABPs[0].Id
		);
		insert historyIABP1;
		
		EDM_IABP_gne__c historyIABP2 = new EDM_IABP_gne__c(
			EDM_IABP_Version_gne__c = 11,
			EDM_Status_gne__c = 'IABP Approved',
			EDM_Start_Date_gne__c = Date.today(),
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Type_of_Event_gne__c = 'OldTestEvent',
			EDM_History_Parent_IABP_gn__c = IABPs[1].Id
		);
		insert historyIABP2;

        EDM_ABM_Event_Occurred_Status_Batch b = new EDM_ABM_Event_Occurred_Status_Batch();
        database.executebatch(b);

        List<EDM_IABP_gne__c> historyIABPs = [Select EDM_Status_gne__c, EDM_Type_of_Event_gne__c,EDM_IABP_Version_gne__c  From EDM_IABP_gne__c Where id in (:historyIABP1.Id,:historyIABP2.Id)];

        System.assertEquals('OldTestEvent',historyIABPs[0].EDM_Type_of_Event_gne__c);
        System.assertEquals('OldTestEvent',historyIABPs[1].EDM_Type_of_Event_gne__c);
        System.assertEquals(10,historyIABPs[0].EDM_IABP_Version_gne__c);
        System.assertEquals(11,historyIABPs[1].EDM_IABP_Version_gne__c);
    }

}