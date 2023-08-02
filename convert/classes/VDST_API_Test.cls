@isTest
public with sharing class VDST_API_Test {

	static testMethod void readAllParticipantsSpendDataINDV_test(){
		prepareTestData('PENDING', 'INDV', 'INDIRECT', false);

		Test.startTest();

		String response = VDST_API.readAllParticipantsSpendData('testABMEventID'); 
		Boolean cont = response.contains('testABMEventID');
		System.assertEquals(true, cont);

		Test.stopTest();
	}
	static testMethod void readAllParticipantsSpendDataORG_test(){
		prepareTestData('PENDING', 'ORG', 'INDIRECT', true);

		Test.startTest();

		String response = VDST_API.readAllParticipantsSpendData('testABMEventID'); 
		Boolean cont = response.contains('Participants not found.');
		System.assertEquals(false, cont);

		Test.stopTest();
	}
	static testMethod void readAllParticipantsSpendDataEMPTY_test(){
		prepareTestData('PENDING', 'INDV', 'INDIRECT', false);

		Test.startTest();

		String response = VDST_API.readAllParticipantsSpendData('');
		Boolean cont = response.contains('ABM Event Id is required.');
		System.assertEquals(true, cont);

		Test.stopTest();
	}
	//readEventSpendData filledID
	static testMethod void readEventSpendData_test1(){
		prepareTestData('PENDING', 'ORG', 'INDIRECT', false);


		Test.startTest();

		String response = VDST_API.readEventSpendData('testABMEventID');
		Boolean cont = response.contains('testABMEventID');
		System.assertEquals(true, cont);
		Test.stopTest();
	}
	//readEventSpendData not filledID
	static testMethod void readEventSpendData_test2(){
		prepareTestData('PENDING', 'ORG', 'INDIRECT', false);
		Test.startTest();
		String response = VDST_API.readEventSpendData('');
		Test.stopTest();
		System.assertEquals('{"errorMsg":"ABM Event Id is required."}', response);
	}
	//readParticipantSpendData filledID
	static testMethod void readParticipantSpendData_Test(){
		prepareTestData('PENDING', 'ORG', 'DIRECT', false);


		Test.startTest();

		String response = VDST_API.readParticipantSpendData('testABMEventID');
		Boolean cont = response.contains('testABMEventID');
		System.assertEquals(true, cont);
		Test.stopTest();
	}
	static testMethod void readParticipantSpendData_Test1(){
		prepareTestData('PENDING', 'ORG', 'INDIRECT', false);

		Test.startTest();
		
		String response = VDST_API.readParticipantSpendData(VDST_API.readEventSpendData('testABMEventID'));
		Boolean cont = response.contains('Participant was not found.');
		System.assertEquals(true, cont);
		Test.stopTest();
	}
	static testMethod void readParticipantSpendData_Test2(){
		prepareTestData('PENDING', 'ORG', 'INDIRECT', false);
		Test.startTest();
		String response = VDST_API.readParticipantSpendData('');
		Test.stopTest();
		System.assertEquals('{"errorMsg":"ABM Participant Id is required."}', response);
	}

	//sendeventspeddata NOT USA filled city
	static testMethod void sendEventSpendData_Test1(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, true, 'San Francisco','2016-05-13','2016-05-15'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}
	//sendeventspeddata USA filled city
	static testMethod void sendEventSpendData_Test2(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('United States', 'OCCURRED', true, false, 'San Francisco','2016-05-13','2016-05-15'));
		Boolean cont = response.contains('Empty Participants List');
		System.assertEquals(true, cont);

		Test.stopTest();
	}
	//sendeventspeddata USA NOT filled city
	static testMethod void sendEventSpendData_Test3(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('United States', 'CANCEL', false, true, null,'2016-05-13','2016-05-15'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}
	//sendeventspeddata NOT USA NOT filled city
	static testMethod void sendEventSpendData_Test4(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();

		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'CLOSED', false, true, null,'2016-05-13','2016-05-15'));
		Boolean cont = response.contains('Empty Participants List');
		System.assertEquals(true, cont);

		Test.stopTest();
	}

	static testMethod void sendEventSpendData_Test5_CheckCaseInsensitiveCountry(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		String response = VDST_API.sendEventJSON(getEventJson('NoRwAy', 'CANCEL', false, true, null,'2016-05-13','2016-05-15'));
		Test.stopTest();
		VDST_Address_gne__c addressData = [SELECT Country_gne__c FROM VDST_Address_gne__c LIMIT 1];
		System.assertEquals('NOR', addressData.Country_gne__c);
	}

	static testMethod void sendEventSpendData_Test6_CheckDifferenceBetweenDateErr(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, false, 'San Francisco','2016-05-13','2016-05-20'));
		Boolean cont = response.contains('The difference between Event Start date and Event End Date cannot exceed more than 4 days');
		System.assertEquals(true, cont);
		Test.stopTest();
	}
	static testMethod void sendEventSpendData_Test7_CheckDifferenceBetweenDateNotErrAddrTypeTrue(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, true, 'San Francisco','2016-05-13','2016-05-20'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}
	static testMethod void sendEventSpendData_Test8_CheckDifferenceBetweenDateNotErrAddrTypefalse(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, false, 'San Francisco','2016-05-13','2016-05-14'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}
	static testMethod void sendEventSpendData_Test9_CheckDifferenceBetweenDateNotErrAddrTypefaslseDate4DaysBetween(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, false, 'San Francisco','2016-05-13','2016-05-17'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}
	static testMethod void sendEventSpendData_Test10_CheckDifferenceBetweenDateNotErrAddrTypetrueDate4DaysBetween(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, true, 'San Francisco','2016-05-13','2016-05-17'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}
	static testMethod void sendEventSpendData_Test11_CheckDifferenceBetweenDateNotErrAddrTypetrueDateMoreDaysBetween(){
		prepareTestData('CANCEL', 'ORG', 'INDIRECT', false);
		Test.startTest();
		
		String response = VDST_API.sendEventJSON(getEventJson('Norway', 'PENDING', true, true, 'San Francisco','2016-05-13','2016-05-20'));
		System.assertEquals('OK', response);
		Test.stopTest();
	}

	//sendEventNoSpendData not USA validation virtual city filled
	static testMethod void sendEventNoSpendData_Test1(){
		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
		Test.startTest();
        
		String response = VDST_API.sendEventJSON(getEventNoSpendJson('Norway', 'PENDING', true, true, 'San Francisco'));
		System.assertEquals('OK', response);

		Test.stopTest();
	}
	//sendEventNoSpendData USA validation not virtual city NOT filled
	static testMethod void sendEventNoSpendData_Test2(){
		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
		Test.startTest();
        
		String response = VDST_API.sendEventJSON(getEventNoSpendJson('United States', 'OCCURRED', true, false, ''));
		Boolean cont = response.contains('Empty Participants List');
		System.assertEquals(true, cont);
		Test.stopTest();
	}
	//sendEventNoSpendData USA NO validation virtual city filled
	static testMethod void sendEventNoSpendData_Test3(){
		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
		Test.startTest();

		String response = VDST_API.sendEventJSON(getEventNoSpendJson('United States', 'CANCEL', false, true, 'San Francisco'));
		Boolean cont = response.contains('Changing status from Occurred is allowed for Closed status only.');
		System.assertEquals(true, cont);
		Test.stopTest();
	}
	//sendEventNoSpendData not USA validation=null virtual city NOT filled
	static testMethod void sendEventNoSpendData_Test(){
		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
		Test.startTest();
        
		String response = VDST_API.sendEventJSON(getEventNoSpendJson('Norway', 'CLOSED', null, true, ''));
		Boolean cont = response.contains('Empty Participants List');
		System.assertEquals(true, cont);

		Test.stopTest();
	}
	static testMethod void sendParticipantJSONnoRemoval_TestUsaHCPLODGNG(){

		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, null, 'United States', 'HCPLODGNG', true, true));
		System.assertEquals('OK', response);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONnoRemoval_TestNotUsaHCPTRVL(){

		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(false, null, 'Norway', 'HCPTRVL', false, true));
		System.assertEquals('OK', response);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSON_missingCountry(){
		prepareTestData('OCCURRED', 'ORG', 'INDIRECT', false);
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(false, null, '', 'HCPTRVL', false, true));
        Test.stopTest();
		Boolean cont = response.contains('Country');
		System.assert(true, response);
	}
	static testMethod void sendParticipantJSONRemoval_TestUSAOOPTRVL(){

		prepareTestData('OCCURRED', 'INDV', 'INDIRECT', false);
        
		Test.startTest();

		String response = VDST_API.sendParticipantJSON(getPrtJson(true, false, 'United States', 'OOPTRVL', true, true));
		System.assertEquals('OK', response);

        Test.stopTest();
	}
	static testMethod void sendParticipantJSONRemoval_TestNotUsaOOPLODGNG(){

		prepareTestData('OCCURRED', 'INDV', 'INDIRECT', false);
        
		Test.startTest();

		String response = VDST_API.sendParticipantJSON(getPrtJson(false, true, 'Norway', 'OOPLODGNG', true, true));
		Boolean cont = response.contains('Last Participant cannot be removed in Occurred/Closed statuses');
		System.assertEquals(true, cont);

        Test.stopTest();
	}
	static testMethod void sendParticipantJSONRemoval_TestNotUsaOOPMEALS(){

		prepareTestData('OCCURRED', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, true, 'Norway', 'OOPMEALS', true, true));
		Boolean cont = response.contains('isValidation flag is not available along with isRemoval flag');
		System.assertEquals(true, cont);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONClosed_TestUsaValidationNoType(){

		prepareTestData('CLOSED', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(null, false, 'United States', '', false, true));
		Boolean cont = response.contains('is incorrect Participant Transaction Code');
		System.assertEquals(true, cont);

        Test.stopTest();
	}
	static testMethod void sendParticipantJSONClosed_TestUsaNoValidationOOPTRVL(){

		prepareTestData('CLOSED', 'INDV', 'INDIRECT', false);
        
		Test.startTest();

		String response = VDST_API.sendParticipantJSON(getPrtJson(false, true, 'United States', 'OOPTRVL', true, true));
		Boolean cont = response.contains('Last Participant cannot be removed in Occurred/Closed statuses');
		System.assertEquals(true, cont);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONClosed_TestNoUsaNoValidationHCPTRVL(){

		prepareTestData('CLOSED', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, true, 'Norway', 'HCPTRVL', true, true));
		Boolean cont = response.contains('isValidation flag is not available along with isRemoval flag');
		System.assertEquals(true, cont);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONCancel_TestNonUsaOOPTRVL(){

		prepareTestData('CANCEL', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, false, 'Norway', 'OOPTRVL', true, true));
		System.assertEquals('OK', response);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONCancel_TestUsaHCPTRVL(){

		prepareTestData('CANCEL', 'INDV', 'INDIRECT', false);
        
		Test.startTest();

		String response = VDST_API.sendParticipantJSON(getPrtJson(false, true, 'United States', 'HCPTRVL', true, true));
		System.assertEquals('OK', response);

        Test.stopTest();
	}
	static testMethod void sendParticipantJSONCancel_TestNonUsaOOPLODGNG(){

		prepareTestData('CANCEL', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, true, 'Norway', 'OOPLODGNG', false, true));
		Boolean cont = response.contains('isValidation flag is not available along with isRemoval flag');
		System.assertEquals(true, cont);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONnospends_TestNonUSAOOPTRVL(){

		prepareTestData('CANCEL', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, false, 'Norway', 'OOPTRVL', true, false));
		System.assertEquals('OK', response);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONnospends_TestUsaHCPTRVL(){

		prepareTestData('CANCEL', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(false, false, 'United States', 'HCPTRVL', true, false));
		System.assertEquals('OK', response);
        Test.stopTest();
	}
	static testMethod void sendParticipantJSONnospends_TestNonUsaOOPLODGNG(){

		prepareTestData('CANCEL', 'INDV', 'INDIRECT', false);
        
		Test.startTest();
		String response = VDST_API.sendParticipantJSON(getPrtJson(true, false, 'Norway', 'OOPLODGNG', false, false));
		System.assertEquals('OK', response);
        Test.stopTest();
	}
    static testMethod void otherMethodsPositiveCountryValues() {
		Test.startTest();

		Map<String, String> mcountry = VDST_API.getCountryValues();
		System.assertNotEquals(null, mcountry);
		Test.stopTest();
	}
	static testMethod void otherMethodsPositiveStateValues() {
		Test.startTest();

		Map<String, String> mstate = VDST_API.getStateValues();
		System.assertNotEquals(null, mstate);

		Test.stopTest();
	}
	static testMethod void otherMethodsPositiveCheckNPI() {
		Test.startTest();

		Boolean result = VDST_API.checkNPI('1234567890');
		System.assertEquals(true, result);

		Test.stopTest();
	}
	static testMethod void otherMethodsPositiveCheckTIN() {
		Test.startTest();

		Boolean result = VDST_API.checkTIN('12-3456789');
		System.assertEquals(true, result);

		Test.stopTest();
	}
	static testMethod void otherMethodsNegativeCheckNPI() {
		Test.startTest();

		Boolean result = VDST_API.checkNPI('12343244');
		System.assertEquals(false, result);
		Test.stopTest();
	}
	static testMethod void otherMethodsNegativeCheckTIN() {
		Test.startTest();

		Boolean result = VDST_API.checkTIN('123412345531');
		System.assertEquals(false, result);
		
		Test.stopTest();
	}

	static void prepareTestData(String eventStatus, String partyType, String tranType, Boolean noTrans){
        VDST_EventProvider_gne__c evProv = createProvider();
        insert evProv;
        
		VDST_Event_gne__c event = createEvent(eventStatus, evProv.Id);
		insert event;

		VDST_EventDate_gne__c evDate = createEventDate(event.Id);
		insert evDate;

		VDST_Address_gne__c adr = createAddress(event.Id, 'United States');
		insert adr;

		VDST_EventSite_gne__c evSite = createSite(event.Id, adr.Id);
		insert evSite;

		VDST_EventTransactionSummary_gne__c evSumamry = createSummary(event.Id);
		insert evSumamry;

		VDST_EventPrtcpntRole_gne__c role = createRole();
		insert role;

		List<VDST_EventPrtcpntField_gne__c> lfields = createField(role.Id);
		insert lfields;

		VDST_EventPrtcpntAccnt_gne__c evPart =  createPrtAcc(event.Id, adr.Id, role.Id, partyType);
		insert evPart;

		if(!noTrans){
			List<VDST_PrtcpntTransaction_gne__c> ltran = createTransaction(evPart.Id, 'HONORARIA', 'INDV');
			insert ltran;
		}else{
			List<VDST_PrtcpntTransaction_gne__c> ltran = createTransaction(evPart.Id, 'HONORARIA', 'ORG');
			insert ltran;
		}

        Product_vod__c brand = createBrand('Actemra');
        insert brand;
        createMapping(new Map<String, String>{
            'USA' => 'United States',
            'NOR' => 'Norway',
            'JR' => 'Jr'
        });
        insert new VDST_States__c[]{
            new VDST_States__c(Code__c = 'CA', Name = 'California'),
            new VDST_States__c(Code__c = 'NEV', Name = 'Nevada'),
            new VDST_States__c(Code__c = 'TEX', Name = 'Texas')
        };
	}
	
	private static String getState(final String code) {
	    final VDST_States__c[] states = VDST_States__c.getAll().values();
	    for (VDST_States__c state : states) {
	        if (state.Code__c == code) {
	           return state.Name;
	        }
	    }
	    return states.isEmpty() ? '' : states[Math.floor(states.size() * Math.random()).intValue()].Name;
	}
	
	static String getEventJson(String country, String status, Boolean validaton, Boolean adrType, String city,String startEvent,String endEvent){
		String json ='{';
				json +='    "abm_event_id": "testABMEventID",';
				json +='    "accountable_unix_id": "bpter180",';
				json +='    "address_city": "' + city + '",';
				json +='    "address_country": "' + country + '",';
				json +='    "address_state": "' + getState('CA') + '",';
				json +='    "address_street": "testowo",';
				json +='    "address_type": ' + adrType + ',';
				json +='    "address_venue_name": "abcderg",';
				json +='    "address_zip": "12345",';
				// AGGSPENDME-139: Total Audio/Video not supported anymore
				// json +='    "audio_visual": 123.00,';
				json +='    "brands": "Actemra",';
				json +='    "content_vendor": "Creative",';
				json +='    "event_end_date": "'+ endEvent + '",'; //"2016-05-15"
				json +='    "event_spends": [';
				json +='        {';
				json +='            "amount": 99,';
				json +='            "number_of_meals": "1 meal/break",';
				json +='            "spend_date": "2016-05-14",';
				json +='            "nonHcp_actual_consumed_count": 2,';
				json +='            "nonHcp_actual_attendee_count": 2';
				json +='        },';
				json +='        {';
				json +='            "amount": 99,';
				json +='            "number_of_meals": "2 meals/break",';
				json +='            "spend_date": "2016-05-27",';
				json +='            "nonHcp_actual_consumed_count": 2,';
				json +='            "nonHcp_actual_attendee_count": 2  ';
				json +='        },';
				json +='        {';
				json +='            "amount": 99,';
				json +='            "number_of_meals": "1 meal/break",';
				json +='            "spend_date": "2016-05-28",';
				json +='            "nonHcp_actual_consumed_count": 1,';
				json +='            "nonHcp_actual_attendee_count": 1';
				json +='        }';
				json +='    ],';
				json +='    "event_start_date": "'+ startEvent + '",'; //"2016-05-13"
				json +='    "event_status": "' + status + '",';
				json +='    "genentech_event_id": "API-TC-020",';
				json +='    "invitation_sent_date": "2016-01-06",';
				json +='    "isValidation": ' + validaton + ',';
				json +='    "logistic_vendor": "Creative",';
				json +='    "meeting_name": "Meeting name API-TC-020",';
				json +='    "planned_attendee_count": 3';
				json +='}';
		return json;
	}
	static String getEventNoSpendJson(String country, String status, Boolean validaton, Boolean adrType, String city){
		String json ='{';
				json +='    "abm_event_id": "testABMEventID",';
				json +='    "accountable_unix_id": "bpter180",';
				json +='    "address_city": "' + city + '",';
				json +='    "address_country": "' + country + '",';
				json +='    "address_state": "' + getState('CA') + '",';
				json +='    "address_street": "testowo",';
				json +='    "address_type": ' + adrType + ',';
				json +='    "address_venue_name": "abcderg",';
				json +='    "address_zip": "12345",';
				// AGGSPENDME-139: Total Audio/Video not supported anymore
				// json +='    "audio_visual": 123.00,';
				json +='    "brands": "Actemra",';
				json +='    "content_vendor": "Creative",';
				json +='    "event_end_date": "2016-05-15",';
				json +='    "event_start_date": "2016-05-13",';
				json +='    "event_status": "' + status + '",';
				json +='    "genentech_event_id": "API-TC-020",';
				json +='    "invitation_sent_date": "2016-01-06",';
				json +='    "isValidation": ' + validaton + ',';
				json +='    "logistic_vendor": "Creative",';
				json +='    "meeting_name": "Meeting name API-TC-020",';
				json +='    "planned_attendee_count": 3';
				json +='}';

		return json;
	}
	
	static String getPrtJson(Boolean validation, Boolean isRemoval, String country,String hcpcode, Boolean contracted, Boolean spends){
		String json ='{';
				json +='  "isValidation":' + validation + ',';
				if(isRemoval != null){
					json +='"isRemoval":' + isRemoval + ',';
				}
				if(!spends){
					json +='"abm_participant_id":"nonExistingId",';
				}else{
					json +='"abm_participant_id":"testABMEventID",';
				}
				json +='"abm_event_id":"testABMEventID",';
				json +='  "participant_role":"Chair",';
				json +='  "first_name":"John",';
				json +='  "last_name":"Wall",';
				json +='  "credential":"BS",';
				json +='  "profession":"Nurse",';
				json +='  "affiliation":"afil",';
				json +='  "suffix":"Jr",';
				json +='  "email":"mytest31322@gmail.com",';
				json +='  "phone":"1655123123",';
				json +='  "contracted":' + contracted + ',';
				json +='  "license_number":"license-123",';
				json +='  "license_state":"' + getState('NEV') + '",';
				json +='  "mdm_id":"11111",';
				json +='  "dea":"dea-123",';
				json +='  "npi":"4444567890",';
				json +='  "sfdc_id":"sfdc-1-123",';
				json +='  "address_street":"stree1",';
				json +='  "address_city":"cty1",';
				json +='  "address_zip":"31111",';
				json +='  "address_street2":"str2-1",';
				json +='  "address_country":"' + country + '",';
				json +='  "address_state":"' + getState('CA') + '",';
				if(spends){
				json +='  "participant_spends":[';
				json +='    {';
				json +='      "code":"' + hcpcode + '",';
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
				json +='      "att_status":false';
				json +='    },';
				json +='    {';
				json +='      "event_date":"2016-05-27",';
				json +='      "consumption_status":"Consumed",';
				json +='      "att_status":true';
				json +='    }';
				json +='  ],';
				}
				json +='  "organization_data":{';
				json +='    "org_name":"org-xxx-1",';
				json +='    "address_country":"' + country + '",';
				json +='    "address_state":"' + getState('TEX') + '",';
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

	static VDST_Event_gne__c createEvent(String status, Id evProv){
		VDST_Event_gne__c event       = new VDST_Event_gne__c();
		event.TotalAudioVisual_gne__c = 1;
		event.CurrentStatus_gne__c    = status;
		event.ABM_EventId_gne__c      = 'testABMEventID';
		event.IsABMevent_gne__c       = true;
		event.EventStartDate_gne__c   = Date.valueOf('2016-03-23');
		event.EventEndDate_gne__c     = Date.valueOf('2016-03-27');
		event.EventType_gne__c        = 'ADBOARD';
		event.LogisticVendor_gne__c   = evProv;

		return event;
	}

	static VDST_EventDate_gne__c createEventDate (Id eventid){

		VDST_EventDate_gne__c evDate            = new VDST_EventDate_gne__c();
		evDate.VDST_Event_gne__c                = eventid;
		evDate.NonHcpActualAttendeeCount_gne__c = 5;
		evDate.NonHcpActualConsumedCount_gne__c = 5;
		evDate.EventDate_gne__c                 = Date.valueOf('2016-03-23');

		return evDate;
	}
	static VDST_Address_gne__c createAddress(Id eventid, String country){
		VDST_Address_gne__c adr  = new VDST_Address_gne__c();
		adr.PostalCode_gne__c    = '74162';
		adr.VDST_Event_gne__c    = eventid;
		adr.Country_gne__c       = country;
		adr.StateProvince_gne__c = 'State';
        adr.City_gne__c = 'City';
		return adr;
	}
	static VDST_EventSite_gne__c createSite(Id eventid, Id adrid){
		VDST_EventSite_gne__c evSite = new VDST_EventSite_gne__c();
		evSite.VDST_Address_gne__c   = adrid;
		evSite.VDST_Event_gne__c     = eventid;

		return evSite;
	}
	static VDST_EventTransactionSummary_gne__c createSummary(Id eventid){
		VDST_EventTransactionSummary_gne__c evSumamry = new VDST_EventTransactionSummary_gne__c();
		evSumamry.VDST_Event_gne__c                   = eventid;
		evSumamry.EventTransactionAmount_gne__c       = 1;
		evSumamry.EventTransactionLevel_gne__c        = 'EVENT';

		return evSumamry;
	}

	static VDST_EventPrtcpntRole_gne__c createRole(){
		VDST_EventPrtcpntRole_gne__c role    = new VDST_EventPrtcpntRole_gne__c();
		role.EventParticipantRoleCode_gne__c = 'CHAIR';
		role.EventParticipantRoleName__c     = 'Chairperson';
		role.EventType_gne__c                = 'ADBOARD';

		return role;
	}

	static List<VDST_EventPrtcpntField_gne__c> createField(Id roleId){
		List<String> lval        = new List<String>{'hasFees', 'hasTrans'};
		Map<String, String> mVal = new Map<String, String>();
		
        mVal.put('Address', 'VDST_Address_gne.StreetAddress_gne');
        mVal.put('City', 'VDST_Address_gne.City_gne');
        mVal.put('Country', 'VDST_Address_gne.Country_gne');
        mVal.put('Postal Code', 'VDST_Address_gne.PostalCode_gne');
        mVal.put('State/Province', 'VDST_Address_gne.StateProvince_gne');
		List<VDST_EventPrtcpntField_gne__c> lfields = new List<VDST_EventPrtcpntField_gne__c>();

		for(String val : lval){
			VDST_EventPrtcpntField_gne__c field = new VDST_EventPrtcpntField_gne__c();
			field.IsVisible_gne__c              = true;
			field.VDST_EventPrtcpntRole__c      = roleId;
			field.FieldName_gne__c              = val;
            field.IsRequired_gne__c = false;

			lfields.add(field);
		}
        for(String val : mVal.keySet()){
			VDST_EventPrtcpntField_gne__c field = new VDST_EventPrtcpntField_gne__c();
			field.IsVisible_gne__c              = true;
			field.VDST_EventPrtcpntRole__c      = roleId;
			field.FieldLabel_gne__c             = val;
			field.FieldName_gne__c              = mVal.get(val);
			field.IsRequired_gne__c             = true;
            
            lfields.add(field);
        }

		return lfields;
	}

	static VDST_EventPrtcpntAccnt_gne__c createPrtAcc(Id eventid, Id adrid, Id roleId, String partyType){
		VDST_EventPrtcpntAccnt_gne__c evPart = new VDST_EventPrtcpntAccnt_gne__c();
		evPart.VDST_Event_gne__c             = eventid;
		evPart.VDST_Address_gne__c           = adrid;
		evPart.ABM_ParticipantId_gne__c      = 'testABMEventID';
		evPart.PartyType_gne__c              = partyType;//'ORG', indiv;
		evPart.EventParticipantRole_gne__c   = roleId;

		return evPart;
	}
	static List<VDST_PrtcpntTransaction_gne__c> createTransaction(Id evPartid, String allType, String toPArtyType){
		List<String> lTranType = new List<String>{'INDIRECT', 'DIRECT'};
		List<VDST_PrtcpntTransaction_gne__c> lTransactions = new List<VDST_PrtcpntTransaction_gne__c>();
		for(String type : lTranType){
			VDST_PrtcpntTransaction_gne__c evPartTran   = new VDST_PrtcpntTransaction_gne__c ();
			evPartTran.TransactionAllocationType_gne__c = type;
			evPartTran.TransactionAmount_gne__c         = 18 ;
			evPartTran.TransactionTypeCode_gne__c       = allType;
			evPartTran.VDST_PaidToParty_gne__c          = evPartid;
			evPartTran.VDST_EventPrtcpntAccnt_gne__c    = evPartid;
			evPartTran.FeePayToPartyType_gne__c         = toPArtyType;
			lTransactions.add(evPartTran);
		}
		
		return lTransactions;
	}

   static Product_vod__c createBrand(String brandName){
		Product_vod__c brand                     = new Product_vod__c();
		brand.Name                               = brandName;
		brand.Detail_Product_Subtype_Code_gne__c = 'Brand';
		brand.Brand_Code_gne__c                  = brandName.toUpperCase();
		brand.Product_Type_vod__c                = 'Detail';

		return brand;
	}
    static VDST_EventProvider_gne__c createProvider(){
		VDST_EventProvider_gne__c prov   = new VDST_EventProvider_gne__c();
		prov.VendorName_gne__c           = 'Creative';
		prov.VendorCode_gne__c           = 'CREATIVE';
		prov.EventTypeProvideCode_gne__c = 'AdBoard';
        
        return prov;
    }
    static void createMapping(Map<String, String> lcountries){
    	List<VDST_Mapping_gne__c> lmapp = new List<VDST_Mapping_gne__c>();
    	for(String name : lcountries.keySet() ) {
			VDST_Mapping_gne__c mapRec = new VDST_Mapping_gne__c();
			mapRec.Name                = name;
			mapRec.LabelValue_gne__c   = lcountries.get(name);
    		lmapp.add(mapRec);
    	}
    	insert lmapp;
    }
}