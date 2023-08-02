global class New_Event_Creation_WS {

    global class Messages {
        webservice String Status;
        webservice String Message;
    }

    global class New_attendee {
        webservice String globalTransactionIdentifier;
        webservice String site_id;
        webservice String UNIX_ID;
        webservice String SFDC_ID;
        webservice String role; //can have multiple roles so change logic to reflect this
        webservice String status;
        webservice String first_name;
        webservice String last_name;
        webservice String company_name;
        webservice String individual_role_code;
        webservice String source_system_attendee_id;
        webservice String source_system_id;
        webservice String meal_consumption_status;
        webservice String street_address;
        webservice String city_name;
        webservice String state_province_code;
        webservice String country_code;
        webservice String zip_code;
        webservice DateTime participant_added_date_time;
    }

    global class New_site {
        webservice String location;
        webservice String parent_event_id; //changed FROM parent_site_id
        webservice String site_id; //webservice String aprimo_event_id_gne;
        webservice String event_medium_type;
        webservice Boolean catered_event_flag;
        webservice String Street_Address; //changed FROM primary_street_address
        webservice String City_Name;
        webservice String State_Province_Code;
        webservice String zip_code;
        webservice String country_code; //also grab country codes to add as picklist values for the field this maps too
        webservice Integer total_attendee_count;
        webservice String roster;
        webservice List<New_attendee> attendees_list;
        webservice String event_roster_status_code;
        webservice Date event_roster_status_lastupdate_date ;
        webservice String sign_in_sheet_status;
        webservice Date sign_in_sheet_date;
        webservice Integer site_total_planned_attendee_count;
        webservice Integer site_final_planned_attendee_opt_out_count;
        webservice Integer venue_guaranteed_count;
        webservice Integer site_roster_attendee_count;
        webservice Integer site_roster_attendee_opt_out_count;
        webservice Date request_date;
        webservice Date invitations_sent_date;
   }

   global class New_Event {
        webservice String globalTransactionIdentifier;
    //    webservice String aprimo_event_id;
        webservice String Name;
        webservice Date Event_Planned_date_1; //changed to 1
        webservice Date Event_Planned_date_2;
        webservice Date Event_Planned_date_3;
        webservice String Event_Series_name;
        webservice String event_Type;
        webservice String timing;
        webservice String Event_Sub_type_Code;
        webservice String curriculum_version_id;
        webservice String status;
        webservice Date start_date;
        webservice String start_time;
        webservice String time_zone;
        webservice Date end_date;
        webservice String speaker_bureau_id;
        webservice String medium_type;
        webservice String method_of_delivery;
        webservice String brands; //changed FROM brand_product //is this to be mapped to brands_gne__c?
        webservice String indications; //changed FROM indication_product
        webservice String therapeutic_areas; //changed FROM therapeutic_product
        webservice String requesting_third_party_org;   // same as requesting company
        webservice List<New_site> sites_list;
        webservice String source_system;
        webservice String source_system_id;
        webservice List<New_attendee> attendees_list; //to keep accontable / requestors
        webservice Date request_date;
        webservice Date invitations_sent_date;
        webservice String event_created_by; //text field

        webservice Date event_status_date;
        webservice String event_status_time;
        webservice DateTime event_created_date_time;
        webservice String canceled_by;
        webservice String cancelation_reason;
        webservice String cancelation_explanation;
   }

    public class Attendees_obj {
        //set to contain all Aprimo_Event_ID's for each attendee sent to the web-service
        public Set<String> attendees = new Set<String>();
        //Map to hold all external Aprimo_Event_ID ID and it's attendees
        public Map<String, List<New_Event_Creation_WS.New_attendee>> site_to_attendees_map = new Map<String, List<New_Event_Creation_WS.New_attendee>>();
        public Map<String, New_Event_Creation_WS.New_attendee> SFDC_to_attendees_map = new Map<String, New_Event_Creation_WS.New_attendee>();
        public Map<String, New_Event_Creation_WS.New_attendee> UNIX_to_attendees_map = new Map<String, New_Event_Creation_WS.New_attendee>();
        public Map<String, New_Event_Creation_WS.New_attendee> eventAttendeesMap = new Map<String, New_Event_Creation_WS.New_attendee>();
        public Curriculum_obj curr_obj = new Curriculum_obj();
    }

    public class Placeholders_obj {
        //set to contain all source_system_attendee_ids for each placeholder sent to the web-service
        public Set<String> placeholders = new Set<String>();
        //Map to hold all external ID and it's attendees
        public Map<String, List<New_Event_Creation_WS.New_attendee>> site_to_placeholders_map = new Map<String, List<New_Event_Creation_WS.New_attendee>>();
        public Map<String, New_Event_Creation_WS.New_attendee> ssaIdToPlaceholder = new Map<String, New_Event_Creation_WS.New_attendee>();
    }

    public class Curriculum_obj {
        public List<Event_Curriculum_Join_gne__c> evt_to_curr_jncn = new List<Event_Curriculum_Join_gne__c>();
        public Map<String, Event_Curriculum_gne__c> aprimoID_to_curric_map = new Map<String, Event_Curriculum_gne__c>();
    }

    public class Bureau_obj {
        public List<Event_Bureaus_gne__c> evt_to_bur_jncn = new List<Event_Bureaus_gne__c>();
        public Map<String, Speaker_Bureau_gne__c> aprimoID_to_bur_map = new Map<String, Speaker_Bureau_gne__c>();
    }

    public class Att_and_spk_obj {
        public List<Speaker_Training_gne__c> spk_trainings = new List<Speaker_training_gne__c>();
        public List<Event_Attendee_vod__c> attendees_to_update = new List<Event_Attendee_vod__c>();
        public List<Event_Attendee_vod__c> event_attendees_to_update = new List<Event_Attendee_vod__c>();
        public List<EDM_Event_Attendee_Placeholder_gne__c> event_att_placeholders_to_update = new List<EDM_Event_Attendee_Placeholder_gne__c>();
    }

    public class Events_obj {
        public List<Member_Trainings_gne__c> memberTrainings = new List<Member_Trainings_gne__c>();
        public Medical_Event_vod__c parent_event = new Medical_Event_vod__c();
        public List<Medical_Event_vod__c> event_locations = new List<Medical_Event_vod__c>();
        public List<Event_Attendee_vod__c> attendee_to_update = new List<Event_Attendee_vod__c>();
        public List<EDM_Event_Attendee_Placeholder_gne__c> placeholder_to_upsert = new List<EDM_Event_Attendee_Placeholder_gne__c>();
        public String vendors = '';
        public Placeholders_obj placeh_obj = new Placeholders_obj();
        public Attendees_obj att_obj = new Attendees_obj();
        public Att_and_spk_obj att_spk_obj = new Att_and_spk_obj();
        public Curriculum_obj curr_obj = new Curriculum_obj();
        public Bureau_obj bur_obj = new Bureau_obj();
        public Map<String,Medical_Event_vod__c> eventID_to_events = new Map<String,Medical_Event_vod__c>();
        public Messages msgs = new Messages();
        public Boolean accountable = true;

        public Map<String,Contact_External_Id_gne__c> addedContactExternalIds = new Map<String,Contact_External_Id_gne__c>();
        public Map<String,Account> addedAccounts = new Map<String,Account>();
    }

    //Contains all the logic to capture medical events, sites and attendees.
    //Creates Medical event related sites and attendees objects in SFDC and also creates Speaker Training Objects for each attendee
    //involved in a medical event who is a speaker

    public static Boolean futureSupported = true;
    public static Set<String> attendeeIds = null;

    webservice static Messages create_new_event(New_Event ne){
        Em3_utils_2 em3utils2 = new Em3_utils_2();
        attendeeIds = em3utils2.createUsersByUnixId(ne);
        if (futureSupported) {
            em3_utils_2.setRolesToNewUsersFuture(attendeeIds);
        }

        Messages msg = new Messages();

        if(String.isNotEmpty(ne.brands)){
            ne.brands = ne.brands.replace(',',';');
        }
        if(ne.Name != null && ne.Name.length() > 80){
            ne.Name = ne.Name.substring(0,80);
        }
        if(String.isNotEmpty(ne.indications)){
            ne.indications = ne.indications.replace(',',';');
        }
        if(String.isNotEmpty(ne.therapeutic_areas)){
            ne.therapeutic_areas = ne.therapeutic_areas.replace(',',';');
        }
        Events_obj evt_obj = new Events_obj();

       // Commented due to Mercury Quality Center ticket no:18021
       // previously was  : if((ne.event_Type == 'Speaker Training' || ne.Event_Type == 'Speaker Program')
       if(ne.Event_Type == 'Speaker Program' && String.isEmpty(ne.speaker_bureau_id)){
            GNE_EM3_Monitoring.insertTransactionLogFailure('Speaker Bureau ID is Required for '+ne.Event_Type, ne);
            msg.status = 'FAILURE';
            msg.message = 'Speaker Bureau ID is Required for '+ne.Event_Type;
            return msg;
        }

        if (isCompanyNameMissingForAnyCoordinator(ne)) {
            msg.status = 'FAILURE';
            msg.message = 'EVENTS ERROR: [company_name] is missing for at least one Coordinator Attendee';
            return msg;
        }

        //Concatenate Roles (remove duplicated attendee entry)
        if(ne.sites_list != null){
            for(New_site ns: ne.sites_list){
                if(ns.attendees_list != null){
                    ns.attendees_list = em3utils2.compileAttendeeRoles(ns.attendees_list, ne.attendees_list);
                    system.debug('ns.attendees_list: ' + ns.attendees_list);
                }
            }
        }

        //prepare vendors list
        evt_obj = em3utils2.addVendors(ne, evt_obj);

        //Concatenate Event level Attendees Roles
        ne.attendees_list = em3utils2.compileEventAttendeeRoles(ne.attendees_list);
        system.debug('ne.attendees_list: '+ ne.attendees_list);

        //holds all event locations related to the parent medical event or (also known as the site)
        evt_obj = em3_utils.ins_upd_Events(ne, evt_obj);
        if(evt_obj.msgs.Status == 'FAILURE'){
            return evt_obj.msgs;
        }

        //Create/Update the medical event locations
        if(ne.sites_list != null && !ne.sites_list.isEmpty() && evt_obj.event_locations != null && !evt_obj.event_locations.isEmpty()){
            //clear empty site FROM sites_list
            List<Medical_Event_vod__c> clearMedicalEvents = new List<Medical_Event_vod__c>();
            for(Medical_Event_vod__c medicalEvent : evt_obj.event_locations){
                if(medicalEvent.id != medicalEvent.parent_medical_event_gne__c){
                    clearMedicalEvents.add(medicalEvent);
                }
            }
            evt_obj.event_locations = clearMedicalEvents;

            try {
                List<Database.upsertResult> uResults = Database.upsert(evt_obj.event_locations);
                delete em3_utils.removeSitesWithAttendes(uResults);
            } catch (System.DmlException e) {
                GNE_EM3_Monitoring.insertTransactionLogFailure('EVENTS ERROR:'+e.getMessage(), ne);
                evt_obj.msgs.status = 'FAILURE';
                evt_obj.msgs.message = 'EVENTS ERROR:'+e.getMessage();
                return evt_obj.msgs;
            }

            /*PP: Actually this part of code is probably deprecated - from the input I've got from the discussion with Prem
            *   we never get status = 'Deleted' for an attendee and this is what em3_utils.del_attendees method bases on.
            *   We may try to confirm it with ESB team if they plan to send to-delete-attendee in request at all and then delete
            *   below code. As per discussion with Prem currently we are deleting only attendees, that weren't specified in request.
            */
            //Remove deleted attendees
            try{
                delete em3_utils.del_attendees(ne.sites_list);
            } catch (System.DmlException e){
                GNE_EM3_Monitoring.insertTransactionLogFailure('ATTENDEE DELETE ERROR:'+e.getMessage(), ne);
                evt_obj.msgs.status = 'FAILURE';
                evt_obj.msgs.message = 'ATTENDEE DELETE ERROR:'+e.getMessage();
                System.debug(e.getMessage());
            }
            //PP: end of probably redundant code*/
            evt_obj = em3utils2.prepareExistingContactExternalIdsAndAccounts(ne, evt_obj);
            evt_obj = em3utils2.add_attendees(ne, evt_obj);
            evt_obj = em3utils2.addEventAttendees(ne, evt_obj);

            if (evt_obj.msgs != null && evt_obj.msgs.status == 'FAILURE') {
                return evt_obj.msgs;
            }
        }
        List<String>aprimo_curr_list;
        if(String.isNotEmpty(ne.curriculum_version_id)){
            aprimo_curr_list = ne.curriculum_version_id.split(',');
            evt_obj = em3_utils.tie_evts_to_curr(evt_obj, aprimo_curr_list);
        }else{
            aprimo_curr_list = new List<String>();
        }

        //upsert the curriculum to medical event relationship records for the junction object
        try {
            if(!evt_obj.curr_obj.evt_to_curr_jncn.isEmpty()){
                upsert evt_obj.curr_obj.evt_to_curr_jncn;
            }
            delete em3_utils.removeCurrJoin(evt_obj, aprimo_curr_list);
        } catch (System.DmlException e) {
            System.debug(e.getMessage());
            GNE_EM3_Monitoring.insertTransactionLogFailure('EVT TO CURR ERROR:'+e.getMessage(), ne);
            evt_obj.msgs.status = 'FAILURE';
            evt_obj.msgs.message = 'EVT TO CURR ERROR:'+e.getMessage();
            return evt_obj.msgs;
        }

        if(ne.speaker_bureau_id != null && ne.speaker_bureau_id.length() >0){
            evt_obj = em3utils2.tie_evts_to_bur(evt_obj,ne.speaker_bureau_id);
        }

        //retrieves any related curriculum to the parent event
        List<Event_Curriculum_Join_gne__c> curricName = [SELECT ID, Name_gne__c, Name FROM Event_Curriculum_Join_gne__c WHERE Medical_Event_gne__c = :evt_obj.parent_event.id LIMIT 1];

        for(Medical_Event_vod__c location : evt_obj.event_locations){
            //String to hold the event name
            String eventName;

            //goes through the start date and all event planned dates until a date is reached
            if(location.Start_Date_vod__c != null){
                eventName = String.valueOf(location.start_date_vod__c);
            }else if(location.Event_Planned_Date_1_gne__c != null){
                eventName = String.valueOf(location.Event_Planned_Date_1_gne__c);
            }else if(location.Event_Planned_Date_2_gne__c != null){
                eventName = String.valueOf(location.Event_Planned_Date_2_gne__c);
            }else if(location.Event_Planned_Date_3_gne__c != null){
                eventName = String.valueOf(location.Event_Planned_Date_3_gne__c);
            }

            //retrieves the city name
            if(location.City_Name_gne__c != null || location.City_Name_gne__c == ''){
                eventName += ' '+location.City_Name_gne__c;
            }
            //Retrieves the name of the related curriculum
            if(!curricName.isEmpty()){
                eventName += ' '+curricName[0].Name_gne__c;
            }
            //appends the newly created eventName to the parent event name
            if(eventName != null && eventName.length() > 80){
                location.Name = eventName.substring(0,80);
            }else{
                location.Name = eventName;
            }
        }

        //ADDED 09/23/09 UPDATES THE PARENT MEDICAL EVENT
        //goes through the start date and all event planned dates until a date is reached

        //update the parent events name
        update(evt_obj.event_locations);

        //Map contains mapping for external Aprimo_Event_ID and the medical event object in SFDC
        //these Medical Event's are SITE events which were previously entered into SFDC and the aprimo_event_ID
        //event is used to reference the correct SITE event in SFDC
        Map<String, Medical_Event_vod__c> eventID_to_events = em3utils2.map_events(evt_obj.event_locations);

        if(ne.sites_list != null && !ne.sites_list.isEmpty()){
            if(evt_obj.event_locations != null && evt_obj.event_locations.size() > 0){
                //PP: here we are creating/updating attendees specified in request
                evt_obj = em3_utils.create_attendees(evt_obj,ne);  //we have prepared list of attendees that needs to be updated or created
                evt_obj = em3utils2.createEventAttendees(evt_obj,ne); //it's for parent event attendees

                if(evt_obj.msgs.status == 'FAILURE'){
                    return evt_obj.msgs;
                }

                //this is site attendee
                try {
                    System.debug('evt_obj.att_spk_obj.attendees_to_update: '+evt_obj.att_spk_obj.attendees_to_update);
                    List<Database.upsertResult> uResults = Database.upsert(evt_obj.att_spk_obj.attendees_to_update);
                    delete em3_utils.removeAttendeesAfterUpsert(uResults);
                } catch (System.DmlException e) {
                    System.debug(e.getMessage());
                    GNE_EM3_Monitoring.insertTransactionLogFailure('ATTENDEES ERROR:' + e.getMessage(), ne);
                    evt_obj.msgs.status = 'FAILURE';
                    evt_obj.msgs.message = 'ATTENDEES ERROR:' + e.getMessage();
                    return evt_obj.msgs;
                }

                //this is parent event attendee
                try {
                    System.debug('evt_obj.att_spk_obj.event_attendees_to_update: '+evt_obj.att_spk_obj.event_attendees_to_update);
                    List<Database.upsertResult> uResults = Database.upsert(evt_obj.att_spk_obj.event_attendees_to_update);
                    delete em3_utils.removeEventAttendeesAfterUpsert(uResults);
                } catch (System.DmlException e) {
                    System.debug(e.getMessage());
                    GNE_EM3_Monitoring.insertTransactionLogFailure('EVENT ATTENDEES ERROR:' + e.getMessage(), ne);
                    evt_obj.msgs.status = 'FAILURE';
                    evt_obj.msgs.message = 'EVENT ATTENDEES ERROR:' + e.getMessage();
                    return evt_obj.msgs;
                }

                //placeholder logic
                try {
                    System.debug('evt_obj.att_spk_obj.event_attendees_to_update: '+evt_obj.att_spk_obj.event_att_placeholders_to_update);
                    List<Database.upsertResult> uResults = Database.upsert(evt_obj.att_spk_obj.event_att_placeholders_to_update);
                    delete em3_utils.removePlaceholdersAfterUpsert(uResults, evt_obj);
                } catch (System.DmlException e) {
                    System.debug(e.getMessage());
                    GNE_EM3_Monitoring.insertTransactionLogFailure('EVENT ATTENDEES ERROR:' + e.getMessage(), ne);
                    evt_obj.msgs.status = 'FAILURE';
                    evt_obj.msgs.message = 'EVENT ATTENDEES ERROR:' + e.getMessage();
                    return evt_obj.msgs;
                }

                try {
                    //sfa-553
                    system.debug(evt_obj.att_spk_obj.spk_trainings);
                    List<Database.upsertResult> uResults = Database.upsert(evt_obj.att_spk_obj.spk_trainings);
                    delete em3_utils.removeSpkTrainingsAfterUpsert(uResults, evt_obj.parent_event.id);

                    //SFA-2685
                    List<Id> currIdList = getCurriculumsIdFromSpeakerTrainings(evt_obj.att_spk_obj.spk_trainings);
                    List<EDM_CurriculumSuccessorCrawler.CurriculumsToProcessListItem> curriculumsToProcessList = new List<EDM_CurriculumSuccessorCrawler.CurriculumsToProcessListItem>();
                    for (Id curriculumId : currIdList) {
                        curriculumsToProcessList.add(new EDM_CurriculumSuccessorCrawler.CurriculumsToProcessListItem(curriculumId, true));
                    }
                    System.enqueueJob(new EDM_CurriculumSuccessorCrawler(curriculumsToProcessList));
                } catch (System.DmlException e) {
                    System.debug(e.getMessage());
                    GNE_EM3_Monitoring.insertTransactionLogFailure('SPEAKER TRAINING ERROR:' + e.getMessage(), ne);
                    evt_obj.msgs.status = 'FAILURE';
                    evt_obj.msgs.message = 'SPEAKER TRAINING ERROR:' + e.getMessage();
                    return evt_obj.msgs;
                }
            }
        }

        try {
            upsert(evt_obj.bur_obj.evt_to_bur_jncn);
        } catch(System.DmlException e){
            System.debug(e.getMessage());
            GNE_EM3_Monitoring.insertTransactionLogFailure('EVT TO BUR ERROR:' + e.getMessage(), ne);
            evt_obj.msgs.status = 'FAILURE';
            evt_obj.msgs.message = 'EVT TO BUR ERROR:' + e.getMessage();
            return evt_obj.msgs;
        }

        if(ne.event_Type == 'Speaker Training' && ne.status == 'Occurred' && ne.speaker_bureau_id != null && ne.speaker_bureau_id.length() > 0){
            evt_obj.memberTrainings = em3utils2.tie_training_to_bureauMember(evt_obj, ne.curriculum_version_id, ne.speaker_bureau_id);
            if(!evt_obj.memberTrainings.isEmpty()){
                try{
                    upsert(evt_obj.memberTrainings);
                }catch (System.DmlException e) {
                    System.debug(e.getMessage());
                    GNE_EM3_Monitoring.insertTransactionLogFailure('FAILURE ON MEMBER TRAININGS:' + e.getMessage(), ne);
                    evt_obj.msgs.message = 'FAILURE ON MEMBER TRAININGS:' + e.getMessage();
                    return evt_obj.msgs;
                }
            }
        }
        try{
            em3_utils_2.populateSpeakersNameField(ne.source_system_id);
        }catch(System.DmlException e){
            System.debug(e.getMessage());
            GNE_EM3_Monitoring.insertTransactionLogFailure('POPULATING SPEAKERS NAME ERROR' + e.getMessage(), ne);
            evt_obj.msgs.status = 'FAILURE';
            evt_obj.msgs.message = 'POPULATING SPEAKERS NAME ERROR' + e.getMessage();
            return evt_obj.msgs;
        }
        GNE_EM3_Monitoring.insertTransactionLogSuccess(ne);
        msg.Status = 'SUCCESS';
        msg.Message = '';
        return msg;
    }

    public static void afterCreation(Set<String> attIds) {
        System.debug('afterCreation');
        em3_utils_2.setRolesToNewUsers(attIds);
    }

    public static New_attendee cloneNew_attendee(New_attendee org) {
        if (org == null) {
            return null;
        }

        New_attendee result = new New_attendee();

        result.globalTransactionIdentifier = org.globalTransactionIdentifier;
        result.site_id =                     org.site_id;
        result.UNIX_ID =                     org.UNIX_ID;
        result.SFDC_ID =                     org.SFDC_ID;
        result.role =                        org.role;
        result.status =                      org.status;
        result.first_name =                  org.first_name;
        result.last_name =                   org.last_name;
        result.company_name =                org.company_name;
        result.individual_role_code =        org.individual_role_code;
        result.source_system_attendee_id =   org.source_system_attendee_id;
        result.source_system_id =            org.source_system_id;
        result.meal_consumption_status =     org.meal_consumption_status;
        result.street_address =              org.street_address;
        result.city_name =                   org.city_name;
        result.state_province_code =         org.state_province_code;
        result.country_code =                org.country_code;
        result.zip_code =                    org.zip_code;
        if (org.participant_added_date_time != null) {
            result.participant_added_date_time = Datetime.newInstance(org.participant_added_date_time.getTime());
        }

        return result;
    }

    private static Boolean isCompanyNameMissingForAnyCoordinator(New_Event newEvent) {
        if (newEvent.attendees_list != null) {
            for (New_Attendee attendee : newEvent.attendees_list) {
                if (attendee.role == em3_utils_2.ATTENDEE_ROLE_COORDINATOR && String.isBlank(attendee.company_name)) {
                    return true;
                }
            }
        }

        for (New_Attendee attendee : getAttendeesFromAllSites(newEvent)) {
            if (attendee.role == em3_utils_2.ATTENDEE_ROLE_COORDINATOR && String.isBlank(attendee.company_name)) {
                return true;
            }
        }

        return false;
    }

    private static List<New_Attendee> getAttendeesFromAllSites(New_Event newEvent) {
        List<New_Attendee> result = new List<New_Attendee>();

        if (newEvent.sites_list != null) {
            for (New_site eventSite : newEvent.sites_list) {
                if (eventSite.attendees_list != null) {
                    result.addAll(eventSite.attendees_list);
                }
            }
        }

        return result;
    }

    private static List<Id> getCurriculumsIdFromSpeakerTrainings(List<Speaker_Training_gne__c> spkrList) {
        Set<Id> currSet = new Set<Id>();

        for (Speaker_Training_gne__c spkr : spkrList) {
            currSet.add(spkr.Event_Curriculum_gne__c);
        }

        return new List<Id>(currSet);
    }
}