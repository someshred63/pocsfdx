@isTest
private class EDM_Spend_Participant_Test {
	private enum AccountType { HCP, HCO }

	@testSetup
	static void createTestData() {
		Account hcpAccount = createAccount(AccountType.HCP);
		Account hcoAccount = createAccount(AccountType.HCO);
		createAffiliation(hcpAccount, hcoAccount);
		createAddress(hcpAccount);
		createAddress(hcoAccount);
		createMedicalLicense(hcpAccount);
		EDM_AABP_gne__c aabp = createAABP();
		EDM_IABP_gne__c iabp = createIABP(aabp);
		EDM_Attendee_gne__c attendee = createAttendee(iabp, hcpAccount);
	}

	private static Account createAccount(EDM_Spend_Participant_Test.AccountType accountType) {
		Account testAccount = new Account();
		if (accountType == EDM_Spend_Participant_Test.AccountType.HCO) {
			testAccount.Name = 'TestHCO ' + String.valueOf(System.now());
		}
		else if (accountType == EDM_Spend_Participant_Test.AccountType.HCP) {
			testAccount.FirstName = 'TestHCP';
			testAccount.LastName = 'TestHCP ' + String.valueOf(System.now());
			testAccount.MDMID_gne__c = '12345';
			testAccount.Suffix_vod__c = 'JR';
		}
		insert testAccount;
		return testAccount;
	}

	private static EDM_AABP_gne__c createAABP() {
		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2016',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		return testAABP;
	}
	
	private static EDM_IABP_gne__c createIABP(EDM_AABP_gne__c aabp) {
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = aabp.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testIABP;
		return testIABP;
	}

	private static EDM_Attendee_gne__c createAttendee(EDM_IABP_gne__c iabp, Account account) {
		EDM_Attendee_gne__c attendee = new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_System_Type_gne__c = 'Advisor',
			EDM_Role_gne__c = 'Advisor',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = account.Id

		);
		insert attendee;
		return attendee;
	}

	private static Affiliation_vod__c createAffiliation(Account fromAcc, Account toAcc) {
		Affiliation_vod__c affiliation = new Affiliation_vod__c();
		affiliation.From_Account_vod__c = fromAcc.Id;
		affiliation.To_Account_vod__c = toAcc.Id;
		insert affiliation;
		return affiliation;
	}

	private static Address_vod__c createAddress(Account account) {
		Address_vod__c address = new Address_vod__c();
		address.Name = 'Address ' + String.valueOf(System.now());
		address.Account_vod__c = account.Id;
		address.City_vod__c = 'test city';
		address.State_vod__c = 'test state';
		address.Postal_Code_can_gne__c = 'A0A 1B1';
		insert address;
		return address;
	}

	private static CORE_Pub_License__c createMedicalLicense(Account account) {
		CORE_Pub_Party__c party = new CORE_Pub_Party__c(
							Party_Id_gne__c = '12345', 
							MDM_Id_gne__c = account.MDMID_gne__c,
							Status_gne__c = 'A',
							FirstName_gne__c = 'SOMENAME',
							MiddleName_gne__c = 'MIDDLE',
							LastName_gne__c = 'SOMELAST',
							Salutation_gne__c = 'Dr.',
							Suffix_gne__c = 'V',
							Gender_gne__c = 'F', 
							PDRP_Opt_Out_gne__c = 'Y');
		party.Mdm_Updt_Date_gne__c = DateTime.newInstance(2015, 7, 12, 15, 20, 35);
		party.Birthdate_gne__c = Date.newInstance(1982, 1, 1);
		party.PDRP_Opt_Out_Date_gne__c = Date.newInstance(2014, 1, 14);
		party.Type_gne__c='IND';
		party.Prof_Type_json_gne__c = '[{"Code" : "MD"}, {"Code" : "CLNCL"}, {"Code" : "PSCR"}]';
		party.Education_json_gne__c = '[{"Code" : "MD"}, {"Code" : "LVT"}]';
		party.Comm_Channel_json_gne__c = '[{"Code" : "BUS_PHN", "Value" : "6505231432"}, {"Code" : "EML", "Value" : "test@test.com"}, {"Code" : "PGR",  "Value" : "5231234321"}]';
		party.Credentials_json_gne__c = '[{"Code" : "MD"}, {"Code" : "MBA"}, {"Code" : "MPT"}]';
		party.Specialties_json_gne__c = '[{"Code" : "A"}, {"Code" : "DEN"}, {"Code" : "ACA"}]';
		party.Alt_Names_json_gne__c = '[{"Value" : "SOMENAME MIDDLE" }]';
		party.Do_Not_Contact_gne__c = 'Y';
		insert party;

		CORE_Pub_License__c license = new CORE_Pub_License__c(
					Party_Id_gne__c='12345', 
					License_Number_gne__c='A115513', 
					License_State_gne__c='CA', 
					Grace_Period_gne__c='90', 
					Designation_gne__c='MD', 
					License_Status_gne__c='Valid', 
					Smpl_Ovrl_Elig_Flag_gne__c='Y',
					Party_Id_ref_gne__c = party.Id);
		license.Adj_Lic_Exp_Date_gne__c =  Date.newInstance(2017, 3, 31);
		license.Exp_Date_gne__c = Date.newInstance(2017, 12, 31);
		license.External_Id_gne__c = license.Party_Id_gne__c + license.License_Number_gne__c;  
		insert license; 
		return license;
	}

	
	@isTest 
	static void shouldPopulateAttendeeData() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), new EDM_VDST_ParticipantMockAPI(iabp));

		//then
		System.assertEquals(2, participant.attendance.size());
		System.assert(participant.feeOrg != null);
		System.assertEquals('Organization', participant.hcpFeesPaidTo);
	}

	@isTest 
	static void shouldSetProffessionAndCredentialToOther() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), new EDM_VDST_ParticipantMockAPI(iabp));

		//then
		System.assertEquals('Other', participant.account.Credentials_gne__c);
		System.assertEquals('Other', participant.account.Professional_Type_gne__c);
	}

	@isTest 
	static void shouldGetProperAmount() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), new EDM_VDST_ParticipantMockAPI(iabp));

		//then
		System.assertEquals(15, participant.getTotalAttendanceAmount());
	}

	@isTest 
	static void shouldGetConvertedAttData() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), new EDM_VDST_ParticipantMockAPI(iabp));

		//then
		System.assertEquals(2, participant.getConvertedAttData().size());
	}

	@isTest 
	static void shouldFilterAttendeeToDeleteFromGSSP() {
		//given
		EDM_Attendee_gne__c att = getAttendee();

		//when
		Set<Id> attSetIds = new Set<Id> { att.Id };

		//then
		System.assertEquals(0, EDM_Spend_Participant.filterAttendeeToDeleteFromGSSP(attSetIds).size());
	}

	@isTest 
	static void shouldGetProperUpdatedBy() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), new EDM_VDST_ParticipantMockAPI(iabp));

		//then
		System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' (' + UserInfo.getUserEmail() + ')', participant.getLastUpdatedByFormatted());
	}

	@isTest 
	static void shouldNotPopulateProperties() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant();

		//then
		System.assertEquals(new EDM_Attendee_gne__c(), participant.attendee);
		System.assertEquals(new Address_vod__c(), participant.primaryAddress);
	}

	@isTest 
	static void shouldGetFormattedDateFromAttendence() {
		//given
		EDM_Spend_Participant.Attendance attendance = new EDM_Spend_Participant.Attendance(Date.today(), 10);

		//then
		System.assertEquals(Date.today().format(), attendance.getDateFormatted());
	}

	@isTest 
	static void shouldPopulateJsonParticipantWrapper() {
		//given
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();
		Account hcp = getHCP();
		Account hco = getHCO();
		Address_vod__c address = getAddress(hcp);
		CORE_Pub_License__c license = getLicense();

		//when
		EDM_Spend_Participant.JsonParticipantWrapper wrapper1 = new EDM_Spend_Participant.JsonParticipantWrapper(iabp.Id, att, hcp, address, license, hco);
		EDM_Spend_Participant.JsonParticipantWrapper wrapper2 = new EDM_Spend_Participant.JsonParticipantWrapper(iabp.Id, att.Id);

		//then
		System.assert(wrapper1.toJSON().containsIgnoreCase('"first_name":"TestHCP"'));
		System.assert(wrapper1.toJSON().containsIgnoreCase('"suffix":"jr"'));
		System.assert(wrapper2.toJSON().containsIgnoreCase('"abm_participant_id":"' + att.Id + '"'));
	}

	@isTest
	static void shouldPopulateAttendance() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();
		List<EDM_Spend_Ex.DailyMeals> dailyMeals = new List<EDM_Spend_Ex.DailyMeals>();
		dailyMeals.add(new EDM_Spend_Ex.DailyMeals(Date.today(), new EDM_Spend_Attendance_gne__c()));

		//when
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), new EDM_VDST_ParticipantMockAPI(iabp));
		List<EDM_Spend_Participant.Attendance> attendance = participant.populateAttendance(dailyMeals);

		//then
		System.assertEquals(1, attendance.size());
	}

	@isTest
	static void shouldReturnTrueWhenResultOK() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();
		List<EDM_Spend_Ex.DailyMeals> dailyMeals = new List<EDM_Spend_Ex.DailyMeals>();
		dailyMeals.add(new EDM_Spend_Ex.DailyMeals(Date.today(), new EDM_Spend_Attendance_gne__c()));

		//when
		EDM_VDST_ParticipantMockAPI vdstMock = new EDM_VDST_ParticipantMockAPI(iabp);
		vdstMock.result = 'OK';
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), vdstMock);

		//then
		System.assertEquals(true, participant.saveToVDST(iabp.Id));
	}

	@isTest
	static void shouldReturnFalseWhenResultNotOK() {
		//given
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Attendee_gne__c att = getAttendee();
		List<EDM_Spend_Ex.DailyMeals> dailyMeals = new List<EDM_Spend_Ex.DailyMeals>();
		dailyMeals.add(new EDM_Spend_Ex.DailyMeals(Date.today(), new EDM_Spend_Attendance_gne__c()));

		//when
		EDM_VDST_ParticipantMockAPI vdstMock = new EDM_VDST_ParticipantMockAPI(iabp);
		vdstMock.result = 'Error';
		EDM_Spend_Participant participant = new EDM_Spend_Participant(String.valueOf(att.Id), new List<EDM_Spend_Ex.DailyMeals>(), vdstMock);

		//then
		System.assertEquals(false, participant.saveToVDST(iabp.Id));
	}

	//@isTest
	//static void shouldCoverDrawloopConstructor() {
	//	new EDM_Spend_Participant(getAttendee(), getHCP(), new EDM_Spend_Participant.JsonParticipantReadWrapper());
	//}

	@isTest
	static void shouldCoverTriggerMethods() {
		EDM_Attendee_gne__c att = getAttendee();
		Map<Id, EDM_Attendee_gne__c> attMap = new Map<Id, EDM_Attendee_gne__c>();
		attMap.put(att.Id, att);
		EDM_Spend_Participant.sendForRemovalInGSSP(attMap, new EDM_VDST_ParticipantMockAPI(getIABP()));
	}

	private static EDM_IABP_gne__c getIABP() {
		return [SELECT Id FROM EDM_IABP_gne__c LIMIT 1];
	}

	private static EDM_Attendee_gne__c getAttendee() {
		return [SELECT Id, Name, EDM_Role_gne__c FROM EDM_Attendee_gne__c LIMIT 1];
	}

	private static Account getHCP() {
		return [SELECT Id, FirstName, LastName, Suffix_vod__c, NPI_vod__c, Credentials_gne__c, Professional_Type_gne__c, Phone, MDMID_gne__c
				 FROM Account WHERE isPersonAccount = true LIMIT 1];
	}

	private static Account getHCO() {
		return [SELECT Id, Name FROM Account WHERE isPersonAccount = false LIMIT 1];
	}

	private static Address_vod__c getAddress(Account account) {
		return [SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, DEA_vod__c, Country_gen__c, Email_gne__c 
					FROM Address_vod__c WHERE Account_vod__c = :account.Id LIMIT 1];
	}

	private static CORE_Pub_License__c getLicense() {
		return [SELECT Id, License_Number_gne__c, License_State_gne__c, Party_Id_ref_gne__r.Mdm_Id_gne__c
				FROM CORE_Pub_License__c LIMIT 1];
	}

	private static VDST_Event_gne__c createVdstEventFor(EDM_IABP_gne__c iabp) {
		VDST_Event_gne__c vdstEvent = new VDST_Event_gne__c();
		vdstEvent.ABM_EventId_gne__c = iabp.Id;
		vdstEvent.IsABMevent_gne__c = true;
		vdstEvent.EventStartDate_gne__c = Date.today();
		vdstEvent.EventEndDate_gne__c = Date.today().addDays(1);
		insert vdstEvent;
		return vdstEvent;
	}	

	public class EDM_VDST_ParticipantMockAPI implements EDM_Spend_Participant.IEDM_VDST_Participant {
		EDM_IABP_gne__c iabp;
		public String result { get; set; }

		public EDM_VDST_ParticipantMockAPI(EDM_IABP_gne__c iabp) {
			this.iabp = iabp;
		}

        public String readParticipantSpendData(String attendeeId) {
            return getPrtJson(iabp, attendeeId);
        }

        public String sendParticipantJSON(String participantWrapperJSON) {
            return result;
        }

        private String getPrtJson(EDM_IABP_gne__c iabp, Id attendeeId) {
			String json ='{';
					json +='  "isValidation":' + false + ',';
					json +='"isRemoval": false,';
					json +='"abm_participant_id":"' + attendeeId + '",';
					json +='"abm_event_id":"' + iabp.Id + '",';
					json +='  "participant_role":"Advisor",';
					json +='  "first_name":"John",';
					json +='  "last_name":"Wall",';
					json +='  "credential":"BS",';
					json +='  "profession":"Nurse",';
					json +='  "affiliation":"afil",';
					json +='  "suffix":"Jr",';
					json +='  "email":"mytest31322@gmail.com",';
					json +='  "phone":"1655123123",';
					json +='  "contracted": true,';
					json +='  "license_number":"license-123",';
					json +='  "license_state":"Nevada",';
					json +='  "mdm_id":"11111",';
					json +='  "dea":"dea-123",';
					json +='  "npi":"4444567890",';
					json +='  "sfdc_id":"sfdc-1-123",';
					json +='  "address_street":"stree1",';
					json +='  "address_city":"cty1",';
					json +='  "address_zip":"31111",';
					json +='  "address_street2":"str2-1",';
					json +='  "address_country":"United States",';
					json +='  "address_state":"California",';
					json +='  "participant_spends":[';
					json +='    {';
					json +='      "code":"HCPLODGNG",';
					json +='      "amount":1200';
					json +='    },';
					json +='    {';
					json +='      "code":"HONORARIA",';
					json +='      "amount":111';
					json +='    }';
					json +='  ],';
					json +='  "att_data":[';
					json +='    {';
					json +='      "event_date":"2016-05-26",';
					json +='      "consumption_status":"Opted Out",';
					json +='      "att_status":false,';
					json +='	  "meal_amount": 5';
					json +='    },';
					json +='    {';
					json +='      "event_date":"2016-05-27",';
					json +='      "consumption_status":"Consumed",';
					json +='      "att_status":true,';
					json +='	  "meal_amount": 10';
					json +='    }';
					json +='  ],';
					json +='  "organization_data":{';
					json +='    "org_name":"org-xxx-1",';
					json +='    "address_country":"United States",';
					json +='    "address_state":"Texas",';
					json +='    "address_zip":"56664",';
					json +='    "address_city":"orgcity",';
					json +='    "address_street":"orgs",';
					json +='    "npi":"1234557899",';
					json +='    "mdm_id":"79893",';
					json +='    "dea":"dea-1231",';
					json +='    "tin":"12-4454454",';
					json +='    "charitable_org":false';
					json +='  }';
					json +='}';

			return json;
		}
    }
}