@isTest
private class New_Event_Creation_WS_Test{

	/*static testMethod void newEventSuccessTest(){

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.globalTransactionIdentifier = 'Test';
		newEvent.Name = 'This name field has more than eighty characters to check if it will be splitted!!!';
		newEvent.Event_Planned_date_1 = Date.today();
		newEvent.Event_Planned_date_2 = Date.today();
		newEvent.Event_Planned_date_3 = Date.today();
		newEvent.Event_Series_name = 'Test';
		newEvent.event_Type = 'Test';
		newEvent.timing = 'Test';
		newEvent.Event_Sub_type_Code = 'Test';
		newEvent.curriculum_version_id = 'Test';
		newEvent.status = 'Test';
		newEvent.start_date = Date.today();
		newEvent.start_time = '3311131313113';
		newEvent.time_zone = 'Test';
		newEvent.end_date = Date.today();
		newEvent.speaker_bureau_id = 'Test';
		newEvent.medium_type = 'Test';
		newEvent.method_of_delivery = 'Test';
		newEvent.brands = 'TestBrand1,TestBrand2';
		newEvent.indications = 'TestIndication1,TestIndication2';
		newEvent.therapeutic_areas = 'TestTherapeuticArea1,TestTherapeuticArea2';
		newEvent.requesting_third_party_org = 'Test';
		newEvent.sites_list = new List<New_Event_Creation_WS.New_site>();
		newEvent.source_system = 'Test';
		newEvent.source_system_id = 'Test';
		newEvent.attendees_list = new List<New_Event_Creation_WS.New_attendee>();
		newEvent.request_date = Date.today();
		newEvent.invitations_sent_date = Date.today();
		newEvent.event_created_by = 'Test';

		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		System.assertEquals('SUCCESS',msgs.Status);
		System.assertEquals('',msgs.Message);
	}*/

	static testMethod void newEventEmptySpeakerBuraeuIdTest(){

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.event_Type = 'Speaker Program';
		
		New_Event_Creation_WS.New_site newSite = new New_Event_Creation_WS.New_site();


		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		System.assertEquals('FAILURE',msgs.Status);
		System.assertEquals('Speaker Bureau ID is Required for Speaker Program',msgs.Message);
	}

	static testMethod void newEventDuplicatedAttendeesTest(){

		New_Event_Creation_WS.New_attendee att = new New_Event_Creation_WS.New_attendee();
		att.globalTransactionIdentifier = 'TestIdentifier';
		att.UNIX_ID = 'TestUnixID';
		att.role = 'TestRole';
		att.company_name = 'CMP';

		List<New_Event_Creation_WS.New_attendee> attedees = new List<New_Event_Creation_WS.New_attendee>();
		attedees.add(att);

		New_Event_Creation_WS.New_site site = new New_Event_Creation_WS.New_site();
		site.attendees_list = attedees;

		List<New_Event_Creation_WS.New_site> sites = new List<New_Event_Creation_WS.New_site>();
		sites.add(site);

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.attendees_list = attedees;
		newEvent.sites_list = sites;
		newEvent.source_system_id = 'Id';
		newEvent.start_date = Date.today();
		newEvent.end_date = Date.today();
		newEvent.event_Type = 'Speaker Training';

		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		System.assertEquals('SUCCESS',msgs.Status, msgs.Message);
		System.assertEquals('',msgs.Message);
		System.assertEquals(1,newEvent.sites_list.get(0).attendees_list.size());
		System.assertEquals(1,newEvent.attendees_list.size());     
		System.assertEquals('TestRole;TestRole',newEvent.attendees_list.get(0).role);

	}

	static testMethod void shouldReturnFailureBecauseOfMissingCompanyNameForParentEventCoordinator() {
		//given
		New_Event_Creation_WS.New_attendee att = new New_Event_Creation_WS.New_attendee();
		att.globalTransactionIdentifier = 'TestIdentifier';
		att.UNIX_ID = 'TestUnixID';
		att.role = em3_utils_2.ATTENDEE_ROLE_COORDINATOR;

		List<New_Event_Creation_WS.New_attendee> attedees = new List<New_Event_Creation_WS.New_attendee>();
		attedees.add(att);

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.attendees_list = attedees;
		newEvent.source_system_id = 'Id';
		newEvent.start_date = Date.today();
		newEvent.end_date = Date.today();
		newEvent.event_Type = 'Speaker Training';
		newEvent.attendees_list = attedees;

		//when
		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		//then		
		System.assertEquals('FAILURE', msgs.Status, msgs.Message);
		System.assertEquals('EVENTS ERROR: [company_name] is missing for at least one Coordinator Attendee', msgs.Message);

	}

	static testMethod void shouldReturnFailureBecauseOfMissingCompanyNameForSiteCoordinator() {
		//given
		New_Event_Creation_WS.New_attendee att = new New_Event_Creation_WS.New_attendee();
		att.globalTransactionIdentifier = 'TestIdentifier';
		att.UNIX_ID = 'TestUnixID';
		att.role = em3_utils_2.ATTENDEE_ROLE_COORDINATOR;

		List<New_Event_Creation_WS.New_attendee> attedees = new List<New_Event_Creation_WS.New_attendee>();
		attedees.add(att);

		New_Event_Creation_WS.New_site site = new New_Event_Creation_WS.New_site();
		site.attendees_list = attedees;

		List<New_Event_Creation_WS.New_site> sites = new List<New_Event_Creation_WS.New_site>();
		sites.add(site);

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.attendees_list = attedees;
		newEvent.sites_list = sites;
		newEvent.source_system_id = 'Id';
		newEvent.start_date = Date.today();
		newEvent.end_date = Date.today();
		newEvent.event_Type = 'Speaker Training';

		//when
		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		//then		
		System.assertEquals('FAILURE', msgs.Status, msgs.Message);
		System.assertEquals('EVENTS ERROR: [company_name] is missing for at least one Coordinator Attendee', msgs.Message);

	}

	static testMethod void shouldReturnSuccessBecauseMissingCompanyNameIsForNonCoordinator() {
		//given
		New_Event_Creation_WS.New_attendee att = new New_Event_Creation_WS.New_attendee();
		att.globalTransactionIdentifier = 'TestIdentifier';
		att.UNIX_ID = 'TestUnixID';
		att.role = 'non-coordinator-with-no-company-name';
		att.last_name = 'non-coordinator-last-name';

		List<New_Event_Creation_WS.New_attendee> attedees = new List<New_Event_Creation_WS.New_attendee>();
		attedees.add(att);

		New_Event_Creation_WS.New_site site = new New_Event_Creation_WS.New_site();
		site.attendees_list = attedees;

		List<New_Event_Creation_WS.New_site> sites = new List<New_Event_Creation_WS.New_site>();
		sites.add(site);

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.attendees_list = attedees;
		newEvent.sites_list = sites;
		newEvent.source_system_id = 'Id';
		newEvent.start_date = Date.today();
		newEvent.end_date = Date.today();
		newEvent.event_Type = 'Speaker Training';

		//when
		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		//then
		System.assertEquals('SUCCESS', msgs.Status, msgs.Message);

	}

	static testMethod void newEventInsertUpdateFailureTest(){

		New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
		newEvent.name = 'TestEvent';
		newEvent.event_Type = 'Speaker Training';

		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(newEvent);

		System.assertEquals('FAILURE',msgs.Status);
		System.assert(msgs.Message.contains('SOURCE SYSTEM ID IS NULL'));

		newEvent.source_system_id = 'TestID';

		msgs = New_Event_Creation_WS.create_new_event(newEvent);

		System.assertEquals('FAILURE',msgs.Status, msgs.Message);
		System.assert(msgs.Message.contains('FAILURE CREATING PARENT EVENT:'));
	}

	public static testMethod void testValidRequest(){
		String name = 'Name longer than 80 characters. Name longer than 80 characters. Name longer than 80 characters. (101)';
		String aprimoId = 'alaNieMaKotaKotNieMaAli';
		Date currentDate = Date.today();
		String curriculumName = 'testCurriculum';
		insert new Event_Curriculum_gne__c(Name = curriculumName, Aprimo_Id_gne__c = aprimoId);
		insert new Speaker_Bureau_gne__c();
		New_Event_Creation_WS.New_Event ne = prepareRequest(name, currentDate, currentDate, currentDate, aprimoId, 'Occurred', currentDate, currentDate, '600001', 'ss', 'ssId');
		New_Event_Creation_WS.New_Site site1 = prepareSite('loc1', 'ssId', 'siteId1', 2);
		New_Event_Creation_WS.New_Site site2 = prepareSite('loc2', 'ssId', 'siteId2', 2);
		New_Event_Creation_WS.New_attendee attendee1 = prepareAttendee('siteId1', null, null, 'Speaker', 'ssaId1', 'ssId');
		New_Event_Creation_WS.New_attendee attendee2 = prepareAttendee('siteId1', null, null, 'Speaker', 'ssaId2', 'ssId');
		New_Event_Creation_WS.New_attendee attendee3 = prepareAttendee('siteId2', null, null, 'Speaker', 'ssaId3', 'ssId');
		New_Event_Creation_WS.New_attendee attendee4 = prepareAttendee('siteId2', null, null, 'Speaker', 'ssaId4', 'ssId');
		New_Event_Creation_WS.New_attendee attendee5 = prepareAttendee(null, null, null, 'Speaker', 'ssaId5', 'ssId');
		New_Event_Creation_WS.New_attendee attendee6 = prepareAttendee(null, null, null, 'Speaker', 'ssaId6', 'ssId');
		site1.attendees_list.add(attendee1);
		site1.attendees_list.add(attendee2);
		site2.attendees_list.add(attendee3);
		site2.attendees_list.add(attendee4);

		ne.sites_list.add(site1);
		ne.sites_list.add(site2);
		ne.attendees_list.add(attendee5);
		ne.attendees_list.add(attendee6);

		New_Event_Creation_WS.Messages msgs = New_Event_Creation_WS.create_new_event(ne);
		System.assertEquals('SUCCESS',msgs.Status);

		List<Medical_Event_vod__c> me = [SELECT Name, Id, Description_vod__c, Source_System_ID_gne__c, Site_ID_gne__c FROM Medical_Event_vod__c];
		system.debug(me);
		system.assertEquals(3, me.size());
		Set<String> validValues = new Set<String>();
		//String parentEventExpectedValue = String.valueOf(currentDate) + ' ' + curriculumName + '_ssId_' + null;
		//String locExpectedName = String.valueOf(currentDate) + ' San Francisco ' + curriculumName;
		String parentEventExpectedValue = String.valueOf(currentDate) + ' ' + aprimoId + '_ssId_' + null;
		String locExpectedName = String.valueOf(currentDate) + ' San Francisco ' + aprimoId;
		if(locExpectedName.length() > 80){
			locExpectedName = locExpectedName.substring(0,80);
		}
		validValues.add(parentEventExpectedValue.toUpperCase());
		validValues.add((locExpectedName + '_ssId_siteId1').toUpperCase());
		validValues.add((locExpectedName + '_ssId_siteId2').toUpperCase());
		system.debug('validValues: ' + validValues);
		system.debug('me: ' + me);
		for(Medical_Event_vod__c medEv :me){
			String valueToValidate = medEv.Name + '_' + medEv.Source_System_ID_gne__c + '_' + medEv.Site_ID_gne__c;
			system.assert(validValues.contains(valueToValidate.toUpperCase()), valueToValidate);
			if(medEv.Site_ID_gne__c == null){
				system.assertEquals(medEv.Description_vod__c, name.substring(0,80));
			}
		}

		//system.assertEquals([SELECT Id FROM Event_Attendee_vod__c].size(), 6);
	}

	private static New_Event_Creation_WS.New_Event prepareRequest(String name, Date evPlannedDate1, Date evPlannedDate2, Date evPlannedDate3, String curriculumAprimoId, String status, 
					Date startDate, Date endDate, String speakerBureauId, String sourceSystem, String sourceSystemId){
		New_Event_Creation_WS.New_Event eventRequest = new New_Event_Creation_WS.New_Event();
		eventRequest.globalTransactionIdentifier = '12345';
		eventRequest.Name = name;
		eventRequest.Event_Planned_date_1 = evPlannedDate1;
		eventRequest.Event_Planned_date_2 = evPlannedDate2;
		eventRequest.Event_Planned_date_3 = evPlannedDate3;
		eventRequest.Event_Series_name = 'defaultSeriesName';
		eventRequest.event_Type = 'Speaker Training';
		eventRequest.timing = 'Lunch';
		eventRequest.Event_Sub_type_Code = 'HCP Program';
		eventRequest.curriculum_version_id = curriculumAprimoId;
		eventRequest.status = status;   
		eventRequest.start_date = startDate;
		eventRequest.start_time = startDate == null ? null : '11:11:11';
		eventRequest.time_zone = 'PST';
		eventRequest.end_date = endDate;
		eventRequest.speaker_bureau_id = speakerBureauId;
		eventRequest.medium_type = 'Live Program';
		eventRequest.method_of_delivery = 'Didactic';
		eventRequest.brands = 'Actemra;Avastin'; 
		eventRequest.indications = 'FDA Label Pending';
		eventRequest.therapeutic_areas = 'Oncology - General Oncology';
		eventRequest.requesting_third_party_org = 'US Oncology Incorporated';   // same as requesting company
		eventRequest.sites_list = new List<New_Event_Creation_WS.New_site>(); 
		eventRequest.source_system = sourceSystem;
		eventRequest.source_system_id = sourceSystemId;
		eventRequest.attendees_list = new List<New_Event_Creation_WS.New_attendee>(); //to keep accontable / requestors
		eventRequest.request_date = system.today();
		eventRequest.invitations_sent_date = system.today();
		eventRequest.event_created_by = 'PP';
		eventRequest.event_status_date = Date.today();
		eventRequest.event_status_time = '10:10:10';
		eventRequest.canceled_by = 'PP';
		eventRequest.cancelation_reason = 'Cancelation Reason';
		eventRequest.cancelation_explanation = 'Cancelation Explanation';

		return eventRequest;
	}

	private static New_Event_Creation_WS.New_Site prepareSite(String location, String parentEventId, String siteId, Integer totalAttendeeCount){
		New_Event_Creation_WS.New_site newSite = new New_Event_Creation_WS.New_site();
		newSite.location = location;
		newSite.parent_event_id = parentEventId; //changed FROM parent_site_id
		newSite.site_id = siteId; //webservice String aprimo_event_id_gne;
		newSite.event_medium_type = 'Live Program';
		newSite.catered_event_flag = null;
		newSite.Street_Address = 'DNA Way 3';
		newSite.City_Name = 'San Francisco';
		newSite.State_Province_Code = 'CA';
		newSite.zip_code = '12345';
		newSite.country_code = 'US';
		newSite.total_attendee_count = totalAttendeeCount;
		newSite.roster = null;
		newSite.attendees_list = new List<New_Event_Creation_WS.New_attendee>();
		newSite.event_roster_status_code = null; 
		newSite.event_roster_status_lastupdate_date = null; 
		newSite.sign_in_sheet_status = null;
		newSite.sign_in_sheet_date = null;
		newSite.site_total_planned_attendee_count = 3;
		newSite.site_final_planned_attendee_opt_out_count = 2;
		newSite.venue_guaranteed_count = 1;
		newSite.site_roster_attendee_count =1;
		newSite.site_roster_attendee_opt_out_count = 1;
		newSite.request_date = system.today();
		newSite.invitations_sent_date = system.today();

		return newSite;
	}

	private static New_Event_Creation_WS.New_attendee prepareAttendee(String siteId, String unixId, String sfdcId, String role, String ssaId, String ssId){
		New_Event_Creation_WS.New_attendee newAttendee = new New_Event_Creation_WS.New_attendee();
		newAttendee.globalTransactionIdentifier = '12345';
		newAttendee.site_id = siteId;
		newAttendee.UNIX_ID = unixId;
		newAttendee.SFDC_ID = sfdcId;      
		newAttendee.role = role;
		newAttendee.status = 'Attended'; 
		newAttendee.first_name = 'John';
		newAttendee.last_name = 'Smith';
		newAttendee.company_name = 'Genentech';
		newAttendee.individual_role_code = 'Medical Doctor';
		newAttendee.source_system_attendee_id = ssaId;
		newAttendee.source_system_id = ssId; 
		newAttendee.meal_consumption_status = 'Opted Out';
		newAttendee.street_address = 'DNA Way 1';
		newAttendee.city_name = 'South San Francisco';
		newAttendee.state_province_code = 'CA';
		newAttendee.country_code = 'US';
		newAttendee.zip_code = '12345';

		return newAttendee;
	}

	
}