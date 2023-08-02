@isTest
private class EDM_IABP_Version_Compare_Ex_Test{

	private static EDM_AABP_gne__c testAABP;
	private static List<EDM_IABP_gne__c> iabps;

	private static void createTestData() {
		testAABP = getNewAAPB();
		insert testAABP;

		iabps = new List<EDM_IABP_gne__c>();
		iabps.add(getNewIABP(testAABP, false, 'IABP 1'));
		iabps.add(getNewIABP(testAABP, false, 'IABP 2'));
		iabps.add(getNewIABP(testAABP, true, 'ExeSum 1'));
		iabps.add(getNewIABP(testAABP, true, 'ExeSum 2'));
		insert iabps;
	}

	private static EDM_AABP_gne__c getNewAAPB() {
		EDM_AABP_gne__c newAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		return newAABP;
	}

	private static EDM_IABP_gne__c getNewIABP(EDM_AABP_gne__c parentAABP, Boolean isExsum, String detail) {
		EDM_IABP_gne__c newIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = parentAABP.Id,
			EDM_Executive_Summary_gne__c = isExsum,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Optional_Detail_gne__c = detail
		);
		if (isExsum) {
			newIABP.EDM_Explanation_of_Att_Changes_gne__c = 'change 1';
		}
		return newIABP;
	}

	@isTest
	public static void shouldShowError() {
		//given
		createTestData();

		//when
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[0]);
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);

		//then
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('The records to compare could not be retrieved.'));
	}

	@isTest
	public static void shouldGoBackToRetUrl(){
		//given
		createTestData();
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[0]);
		ApexPages.currentPage().getParameters().put('retUrl','www.google.com');
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);

		//when
		PageReference pr = ext.goBack();

		//then		
		System.assertEquals('www.google.com',pr.getUrl());
	}

	@isTest
	public static void shouldGoBackToParentIABP(){
		//given
		createTestData();
		Apexpages.currentPage().getParameters().put('idOld',iabps[0].Id);
		Apexpages.currentPage().getParameters().put('idNew',iabps[1].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[1]);
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);

		//when
		PageReference pr = ext.goBack();

		//then
		System.assertEquals('/apex/EDM_IABP_Review_Layout?id=' + iabps[0].Id, pr.getUrl());
	}

	@isTest
	public static void shouldAddIabpRecordFieldsToCompareValues() {
		//given
		createTestData();

		//when
		Apexpages.currentPage().getParameters().put('idOld',iabps[0].Id);
		Apexpages.currentPage().getParameters().put('idNew',iabps[1].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[0]);
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);

		//then
		for(EDM_IABP_Version_Compare_Ex.CompareWrapper diff : ext.Values){
			if(diff.label == 'Type of Event'){
				System.assertEquals(diff.v1,iabps[0].EDM_Type_of_Event_gne__c);
				System.assertEquals(diff.v2,iabps[1].EDM_Type_of_Event_gne__c);
			}
			if(diff.label == 'Optional Detail'){
				System.assertEquals(diff.v1,String.valueOf(iabps[0].EDM_Optional_Detail_gne__c));
				System.assertEquals(diff.v2,String.valueOf(iabps[1].EDM_Optional_Detail_gne__c));
			}
		}
	}

	@isTest
	public static void shouldAddExesumRecordFieldsToCompareValues() {
		//given
		createTestData();

		//when
		Apexpages.currentPage().getParameters().put('idOld',iabps[2].Id);
		Apexpages.currentPage().getParameters().put('idNew',iabps[3].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[2]);
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);

		//then
		for(EDM_IABP_Version_Compare_Ex.CompareWrapper diff : ext.Values){
			if(diff.label == 'Type of Event'){
				System.assertEquals(diff.v1,iabps[2].EDM_Type_of_Event_gne__c);
				System.assertEquals(diff.v2,iabps[3].EDM_Type_of_Event_gne__c);
			}
			if(diff.label == 'Optional Detail'){
				System.assertEquals(diff.v1,String.valueOf(iabps[2].EDM_Optional_Detail_gne__c));
				System.assertEquals(diff.v2,String.valueOf(iabps[3].EDM_Optional_Detail_gne__c));
			}
		}
	}

	@isTest
	public static void shouldCompareRelatedListValues() {
		//given
		createTestData();

		List<EDM_Objective_gne__c> objectives = new List<EDM_Objective_gne__c>();
		objectives.add(
				new EDM_Objective_gne__c(
					EDM_Parent_IABP_gne__c = iabps[0].Id,
					EDM_ID_For_Comparator_gne__c = 'abc',
					EDM_Description_gne__c = 'desc 1'
				)
			);

		objectives.add(
				new EDM_Objective_gne__c(
					EDM_Parent_IABP_gne__c = iabps[0].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Description_gne__c = 'desc 2'
				)
			);

		objectives.add(
				new EDM_Objective_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Description_gne__c = 'desc 3'
				)
			);

		insert objectives;

		//when
		Apexpages.currentPage().getParameters().put('idNew',iabps[0].Id);
		Apexpages.currentPage().getParameters().put('idOld',iabps[1].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[0]);
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);
		Integer count = 0;
		for (EDM_IABP_Version_Compare_Ex.CompareWrapper diff : ext.ValuesRL) {
			if (diff.label == 'Description') {
				count++;
			}
		}

		//then
		System.assertEquals(2, count);
	}

	@isTest
	public static void shouldCompareAgendaValues() {
		//given
		createTestData();

		List<EDM_Session_gne__c> agenda = new List<EDM_Session_gne__c>();
		agenda.add(
				new EDM_Session_gne__c(
					EDM_Parent_IABP_gne__c = iabps[0].Id,
					EDM_ID_For_Comparator_gne__c = 'abc',
					EDM_Title_gne__c = 'desc 1'
				)
			);

		agenda.add(
				new EDM_Session_gne__c(
					EDM_Parent_IABP_gne__c = iabps[0].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Title_gne__c = 'desc 2'
				)
			);

		agenda.add(
				new EDM_Session_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Title_gne__c = 'desc 3'
				)
			);

		insert agenda;

		//when
		Apexpages.currentPage().getParameters().put('idNew',iabps[0].Id);
		Apexpages.currentPage().getParameters().put('idOld',iabps[1].Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(iabps[0]);
		EDM_IABP_Version_Compare_Ex ext = new EDM_IABP_Version_Compare_Ex(sc);
		Integer count = 0;
		for (EDM_IABP_Version_Compare_Ex.CompareWrapper diff : ext.ValuesAgenda) {
			if (diff.label == 'Title') {
				count++;
			}
		}

		//then
		System.assertEquals(2, count);
	}
}