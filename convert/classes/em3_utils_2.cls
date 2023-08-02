public class em3_utils_2 {
    
    GlobalLogging logger = new GlobalLogging('em3_utils_2');
    
    static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
    static String DEFAULT_LOCALE_KEY = 'en_US';
    static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
    static String DEFAULT_LANG_LOC_KEY = 'en_US';
    
    static String STNDRD_USER = 'Standard User';
    static String INFREQUENT_USER_PROF = 'GNE-INFREQUENT-USER';
    public static final String INDIVIDUAL_ROLE_PARTNER_VENDOR = 'Partner';
    public static final String INDIVIDUAL_ROLE_EVENT_COORDINATOR = 'Vendor';
    public static final String ACCOUNT_RECORD_TYPE_PARTNER_VENDOR = 'Partner Vendor';
    public static final String ACCOUNT_RECORD_TYPE_EVENT_COORDINATOR = 'Event Coordinator';
    public static final String ATTENDEE_ROLE_VENDOR = 'Vendor'; 
    public static final String ATTENDEE_ROLE_RQSTTHDPTY = 'Requesting Third Party Organization';
    public static final String ATTENDEE_ROLE_ACCOUNTABLE = 'Accountable';
    public static final String ATTENDEE_ROLE_REQUESTOR = 'Requestor';
    public static final String ATTENDEE_ROLE_PARTNER = 'Partner';
    public static final String ATTENDEE_ROLE_VENDOR_STAFF = 'Vendor Staff'; 
    public static final String ATTENDEE_ROLE_COORDINATOR = 'Coordinator';
    
    public New_Event_Creation_WS.Events_obj tie_evts_to_bur(New_Event_Creation_WS.Events_obj evt_obj, String bureaus){
        
        //Collect the junction object records where the bureau is related to this particular medical event in the web-service
        //and delete them
        List<Event_Bureaus_gne__c> bur_join = [select id from Event_Bureaus_gne__c where Medical_Event_gne__c IN :evt_obj.event_locations for update];
        system.debug(bur_join);
        try {
            delete(bur_join);
        } catch ( System.DmlException e) {          
            System.debug(e.getMessage());               
        }
                                               
        System.debug('EVT_OBJ:'+evt_obj);
        Map<String, Set<String>> burID_to_events_map = new Map<String, Set<String>>();
        
        //splits the bureau string to obtain all bureau ids brought from aprimo
        List<String> aprimo_bur_list = bureaus.split(',');
        
        //will hold all bureaus id's of those bureaus which already exist (checked by using the aprimo external id)
        Set<String> bur_set = new Set<String>();
        List<String> bur_list = new list<String>();
        
        //Populate the bur_set with Speaker_Bureau_gne__c id's that exist in SFDC
        for(Speaker_Bureau_gne__c bur : [select ID, Aprimo_Bureau_ID_gne__c from Speaker_Bureau_gne__c where Aprimo_Bureau_ID_gne__c IN :aprimo_bur_list for update]){
            bur_set.add(bur.id);
            bur_list.add(bur.id);
            evt_obj.bur_obj.aprimoID_to_bur_map.put(bur.Aprimo_Bureau_ID_gne__c,bur);
        }
        System.debug('Event Info:'+evt_obj.event_locations);
        if(evt_obj.event_locations != null && evt_obj.event_locations.size() > 0){
                    
            //retrieve all event_bureaus_gne__c (junctions) records where a records Med. Evt and Evt. bur are within the list of speaker bureaus and medical events 
            List<Event_Bureaus_gne__c> existing_jncns = [select id, Medical_Event_gne__c, Speaker_Bureau_gne__c from Event_Bureaus_gne__c where Medical_Event_gne__c IN :evt_obj.event_locations AND Speaker_Bureau_gne__c IN :bur_set for update];               
            system.debug('BUREAU JUNCTIONS:'+existing_jncns);
            //Populates the burId... map to have every Speaker Bureau SFDC ID mapped to a list of Medical Event              
            for(Event_Bureaus_gne__c jncn : existing_jncns){            
                if (!burID_to_events_map.keySet().contains(jncn.Speaker_Bureau_gne__c)){
                    burID_to_events_map.put(jncn.Speaker_Bureau_gne__c, new set<String>());
                }
                            
                if (burID_to_events_map.get(jncn.Speaker_Bureau_gne__c) != null){
                    burID_to_events_map.get(jncn.Speaker_Bureau_gne__c).add(jncn.Medical_Event_gne__c);
                }           
            }       
            
            //For each Bureau run through all events and first check if the bureau already exists, if so check if it's related
            //medical events are equal to any of the medical events we are currently processing.  If not add the relationship between the
            //bureau and medical event to the junction object.  Otherwise do nothing because the relationship is already established.
            //if the bureau doesn't have any relationship between the medical event being processed then for all events create the relationship
            //between this bureau
            //THIS HAS BEEN DEPRICATED, WE WILL ALWAYS REMOVE EXISTING JUNCTIONS AND REPLACE WITH NEW JUNCTIONS             
            System.debug('EX_JUNCTION:'+existing_jncns);
            /*if(existing_jncns.size() > 0){
                for(Event_Bureaus_gne__c jncn : existing_jncns){                
                    for(integer i=0;i<bur_list.size();i++){
                        if(bur_list[i] == jncn.Speaker_Bureau_gne__c){
                            bur_list.remove(i);
                            break;
                        }                                       
                    }               
                    
                    for(Medical_Event_vod__c evt : evt_obj.event_locations){
                        if(burID_to_events_map.keySet().contains(jncn.Speaker_Bureau_gne__c)){
                            if(!burID_to_events_map.get(jncn.Speaker_Bureau_gne__c).contains(evt.id)){
                                evt_obj.bur_obj.evt_to_bur_jncn.add(new Event_Bureaus_gne__c(Speaker_Bureau_gne__c = jncn.Speaker_Bureau_gne__c, Medical_Event_gne__c = evt.id));
                            }                   
                        }else evt_obj.bur_obj.evt_to_bur_jncn.add(new Event_Bureaus_gne__c(Speaker_Bureau_gne__c = jncn.Speaker_Bureau_gne__c, Medical_Event_gne__c = evt.id));               
                    }
                }
            }*/
        }  
             
        for(integer i=0; i<bur_list.size();i++){
            if(evt_obj.event_locations != null && evt_obj.event_locations.size() > 0){
                for(Medical_Event_vod__c evt : evt_obj.event_locations){                
                    evt_obj.bur_obj.evt_to_bur_jncn.add(new Event_Bureaus_gne__c(Speaker_Bureau_gne__c = bur_list[i], Medical_Event_gne__c = evt.id));                                                                 
                }
            }else{
                evt_obj.bur_obj.evt_to_bur_jncn.add(new Event_Bureaus_gne__c(Speaker_Bureau_gne__c = bur_list[i], Medical_Event_gne__c = evt_obj.parent_event.id));                                        
            }
        }
        System.debug('ENDING:'+evt_obj.bur_obj.evt_to_bur_jncn);        
        return evt_obj;                                                          
    }
    
    public List<Member_Trainings_gne__c> tie_training_to_bureauMember(New_Event_Creation_WS.Events_obj evt_obj, String Curriculums, String bureaus){
        List<Member_Trainings_gne__c> existing_mts = new List<Member_Trainings_gne__c>();       
        Set<ID> Acc_set = new Set<ID>();
        Set<ID> Curric_set = new Set<ID>();
        Set<String> BureauID_set = new Set<String>();
        List<Member_Trainings_gne__c> junctions = new List<Member_Trainings_gne__c>();          
        
        //Create map of accounts to there corresponding speaker traiing record
        //Also adds Accounts to the Acc_set
        Map<ID, List<Speaker_Training_gne__c>> accToTraining_Map = new Map<ID, List<Speaker_Training_gne__c>>();
        for(Speaker_Training_gne__c ea : evt_obj.att_spk_obj.spk_trainings){
            System.debug('****TRAINING:' +ea);
            if(ea.Status_gne__c == 'Occurred' || ea.Status_gne__c == 'Closed'){
                Acc_set.add(ea.Speaker_gne__c);         
                if(!accToTraining_Map.KeySet().Contains(ea.Speaker_gne__c)){
                    accToTraining_Map.put(ea.speaker_gne__c, new List<Speaker_Training_gne__c>());
                }accToTraining_Map.get(ea.Speaker_gne__c).add(ea);          
            }
        }
        
        if(!accToTraining_Map.isEmpty()){
                        
            //Add Bureaus to BureauID_set
            for(String bureau : bureaus.split(',')){BureauID_set.add(bureau);}
            
            //Add Curriculums to the Curric_set
            for(String current_curr : Curriculums.split(',')){          
                Event_Curriculum_gne__c ec = evt_obj.curr_obj.aprimoID_to_curric_map.get(current_curr); 
                Curric_set.add(ec.Id);
            }
                                
            //Retrieve Speaker Bureau's, Related Bureau Memberships and Related Event Curriculum records for all Bureau's in the BureauID_set, all members in the Accc_set
            //and all Curriculums in the Curric_set
            List<Speaker_Bureau_gne__c> relatedBureaus = [select id, (select Bureau_Member_gne__c from Bureau_Memberships__r where Bureau_Member_gne__c IN  :acc_set), 
            (select Event_Curriculum_gne__c from Curriculum_speaker_bureau_s__r where Event_curriculum_gne__c IN :curric_set) from Speaker_Bureau_gne__c
            where Aprimo_Bureau_ID_gne__c IN :bureauID_set for update];                                
            
            System.debug('***relatedBureaus:'+relatedBureaus);
            System.debug('***Acc_set:'+acc_set);
            System.debug('***curric_set:'+curric_set);
            System.debug('***bureauID_set:'+bureauID_set);
            
            Set<ID> existingBureauIDset = new Set<ID>();
            Set<ID> existingTrainingIDset = new Set<ID>();
            
            //Create map of existing member trainings
            for(Speaker_Bureau_gne__c sb : relatedBureaus){
                for(Speaker_Bureau_Membership_gne__c sbm : sb.Bureau_Memberships__r){
                    for(Speaker_Training_gne__c st : accToTraining_Map.get(sbm.Bureau_Member_gne__c)){
                        existingBureauIDset.add(sbm.id);
                        existingTrainingIDset.add(st.id);                       
                    }
                }
            }
             
            //List<Member_Trainings_gne__c> existing_trainings = new List<Member_Trainings_gne__c>();
            Set<String> existingTrainingsSet = new set<String>();
            //Map<String,Member_Trainings_gne__c> existingTrainingsMap = new Map<String, Member_Trainings_gne__c>();
            if(existingBureauIDset.size() > 0 && existingTrainingIDset.size() > 0){
                //existing_trainings = [select ID, Speaker_bureau_membership_gne__c, Speaker_training_gne__c from Member_Trainings_gne__c where
                 //Speaker_Bureau_Membership_gne__c IN :existingBureauIDset AND Speaker_Training_gne__c IN :existingTrainingIDset];
                 
                 for(Member_Trainings_gne__c mt : [select ID, Speaker_bureau_membership_gne__c, Speaker_training_gne__c from Member_Trainings_gne__c where
                 Speaker_Bureau_Membership_gne__c IN :existingBureauIDset AND Speaker_Training_gne__c IN :existingTrainingIDset]){
                    String temp = mt.Speaker_Bureau_Membership_gne__c;
                    temp+= mt.Speaker_Training_gne__c; 
                    existingTrainingsSet.add(temp); 
                 }           
            }
            
            System.debug('***accToTraining_Map:'+accToTraining_Map);
            
            //For all the Speaker Bureau's retrieved previously
            for(Speaker_Bureau_gne__c sb : relatedBureaus){
                Set<ID> curriculumsSet = new Set<ID>();
                
                //For all curriuclums realted to this one Speaker Bureau populate the curriculumsSet
                for(Curriculum_Speaker_Bureau_gne__c csb : sb.Curriculum_speaker_bureau_s__r){
                    curriculumsSet.add(csb.event_curriculum_gne__c);
                }
                
                //If there are memberships associated to this bureau continue
                if(!sb.Bureau_Memberships__r.isEmpty()){
                    
                    //iterate over the bureau memberships related to this speaker bureau
                    for(Speaker_Bureau_Membership_gne__c sbm : sb.Bureau_memberships__r){
                        
                        //iterate over the speaker trainings associated to the account who is a member of this particular bureau
                        for(Speaker_Training_gne__c st : accToTraining_Map.get(sbm.Bureau_Member_gne__c)){
                            system.debug('***TRAINING MAP:'+st);
                            
                            //If the curriculumsSet contains the current curriculum, create a new member training record
                            //and add it to the junctions list          
                            if(curriculumsSet.contains(st.Event_Curriculum_gne__c)){
                                String temp = sbm.id;
                                temp += st.id;
                                if(!existingTrainingsSet.contains(temp)){
                                    System.debug('CREATING NEW MT');                                                                                                        
                                    junctions.add(new Member_Trainings_gne__c(Speaker_Bureau_Membership_gne__c = sbm.id, Speaker_Training_gne__c = st.id));          
                                }
                            }
                        }
                    }
                }else{              
                    //return error that curriculum process was screwed up
                    system.debug('SPEAKER BUREAU CURRICULUM SIZE IS != CURRICULUM SIZE FOR SPEAKER BUREAU:'+ sb.id);                
                }
            }
        }
        return junctions;
    }
    
    
    //static String str2 ;
    public static String getLocation(String str){
        String str2='';
        if(str != null){
            if(str.contains('&amp;')){ 
                str2=str.replaceall('&amp;','&'); 
                str=str2;
            }                                       
            if(str.contains('&apos;')){
                str2=str.replaceall('&apos;','\''); 
                str=str2;
            }
            if(str.contains('&quot;')){ 
                str2=str.replaceall('&quot;','"'); 
                str=str2;
            }
            if(str.contains('&gt;')){ 
                str2=str.replaceall('&gt;','>'); 
                str=str2;
            }                               
            if(str.contains('&lt;')){ 
                str2=str.replaceall('&lt;','<'); 
                str=str2;
            } 
        }
        return str;
    }
    
    public Map<String,Medical_Event_vod__c> map_events(List<Medical_Event_vod__c> event_locations){
        //Map contains mapping for external Aprimo_Event_ID and the medical event object in SFDC
        //these Medical Event's are SITE events which were previously entered into SFDC and the aprimo_event_ID
        //event is used to reference the correct SITE event in SFDC 
        Map<String,Medical_Event_vod__c> eventID_to_events = new Map<String,Medical_Event_vod__c>();
        
        //populate the previously created map 
        for(Medical_event_vod__c medEv : event_locations){
            eventID_to_events.put(medEv.Source_System_ID_gne__c,medEv);
        }
    
        return eventID_to_events;
    }   
    
    public New_Event_Creation_WS.Events_obj add_attendees(New_Event_Creation_WS.New_Event newEvent, New_Event_Creation_WS.Events_obj evt_obj){
        System.debug('MICK: add_attendees was triggered');
        
        //helpers list to avoid inserting records ( account ,contacts , contact_ext_id) in loop
        List<Account> accToInsert = new List<Account>();
        List<Account> existingAcc = new List<Account>();
        List<Contact> contToInsert = new List<Contact>();
        List<Contact_External_Id_gne__c> conExtToInsert = new List<Contact_External_Id_gne__c>();
        
        //List<New_Event_Creation_WS.New_attendee> failuredAttendeesToLog = new List<New_Event_Creation_WS.New_attendee>();
        
        //Collect UNIX_IDs
        Set<String> UNIX_IDs = new Set<String>();
        
        //updating Contact.Account
        //Set<String> contactIdsToCheck = new Set<String>();
        
        //get specified RecordTypes
        RecordType recordType = new RecordType();
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add(ACCOUNT_RECORD_TYPE_EVENT_COORDINATOR);
        recordTypeNames.add(ACCOUNT_RECORD_TYPE_PARTNER_VENDOR);
        Map<String, RecordType> recordTypes = getRecordTypes('Account',recordTypeNames);                      

        for(New_Event_Creation_WS.new_site ns: newEvent.sites_list){
            if(ns.attendees_list != null){
                for(New_Event_Creation_WS.New_Attendee attendee: ns.attendees_list){

                    if(String.isNotEmpty(attendee.UNIX_ID)){
                        UNIX_IDs.add(attendee.UNIX_ID.trim());     
                    }else {                      
                        //attendee is non-Genetech
                        if(String.isNotEmpty(attendee.source_system_id) && String.isNotEmpty(attendee.source_system_attendee_id)){
                            
                            Contact_External_Id_gne__c contactExternalId = contactExternalIdExists(attendee, evt_obj);
                            if(contactExternalId == null){
                                Account account = accountExists(attendee, evt_obj);
                                if(account == null){
                                    //select and set proper RecordType of new Account
                                    if(attendee.role != null && (attendee.role == ATTENDEE_ROLE_PARTNER || attendee.role == ATTENDEE_ROLE_COORDINATOR)) {
                                        account = new Account(Name = attendee.company_name, RecordTypeId = recordTypes.get(ACCOUNT_RECORD_TYPE_PARTNER_VENDOR).Id);
                                        accToInsert.add(account);
                                        evt_obj.addedAccounts.put(account.Name,account);
                                    }
                                    if(attendee.role != null && attendee.role == ATTENDEE_ROLE_VENDOR_STAFF) {
                                        account = new Account(Name = attendee.company_name, RecordTypeId = recordTypes.get(ACCOUNT_RECORD_TYPE_EVENT_COORDINATOR).Id);
                                        accToInsert.add(account);
                                        evt_obj.addedAccounts.put(account.Name,account);
                                    }
                                }
                                else {
                                    existingAcc.add(account);
                                }
                                //if role Partner or Vendor Staff or Coordinator and there is no SFDC_ID
                                if((attendee.role == ATTENDEE_ROLE_PARTNER || attendee.role == ATTENDEE_ROLE_VENDOR_STAFF || attendee.role == ATTENDEE_ROLE_COORDINATOR) && String.isEmpty(attendee.SFDC_ID)){
                                    //create Contact and assign Account
                                    Contact contact = new Contact(firstName = attendee.first_name, lastName = attendee.last_name, Title = account.Name, 
                                                                    Third_Party_gne__c = attendee.source_system_id, Third_Party_Id_gne__c = attendee.source_system_attendee_id);
                                    contToInsert.add(contact);
                                }
                            }else{
                                attendee.SFDC_ID = contactExternalId.Contact_gne__r.id;

                            }
                            System.debug('attendee.SFDC_ID=['+attendee.SFDC_ID+']');                      
                        }else{
                             System.debug('Site('+ns.site_id+') of Event (AprimoId='+evt_obj.parent_event.Aprimo_Event_ID_gne__c+') Attendee has been not added - there was no UnixId, source_system_id and source_system_attendee_id');
                        }
                    }
                }
            }
        }                  

        //MISZE:BUG FIX HD2678172 || code that was added to avoid inserting records in loop
        insert accToInsert;
        accToInsert.addAll(existingAcc);
        System.debug('MICK: accounts was inserted :' +accToInsert);     
        for( Account tmpAcc : accToInsert){ 
            for(Contact tmpCont : contToInsert){
                if(tmpCont.Title == tmpAcc.Name){
                    tmpCont.accountId = tmpAcc.Id;
                    tmpCont.Title = '';
                }
            }
        }
        system.debug('MICK:contToInsert :' + contToInsert);
        insert contToInsert;
        
        for(Contact tmpCont : contToInsert){
            Contact_External_Id_gne__c contactExternalId = new Contact_External_Id_gne__c(
                                                   contact_gne__c = tmpCont.Id,
                                                   Third_Party_gne__c = tmpCont.Third_Party_gne__c,
                                                   Third_Party_Id_gne__c = tmpCont.Third_Party_Id_gne__c,
                                                   Third_Party_Index_gne__c = tmpCont.Third_Party_gne__c+tmpCont.Third_Party_Id_gne__c);
            conExtToInsert.add(contactExternalId); 
        }
        insert conExtToInsert;
        
        system.debug('MICK:conExtToInsert :' + conExtToInsert);
        for(New_Event_Creation_WS.new_site ns: newEvent.sites_list){
            if(ns.attendees_list != null){
                for(New_Event_Creation_WS.New_Attendee attendee: ns.attendees_list){
                    if(String.isEmpty(attendee.UNIX_ID)){                      
                        //attendee is non-Genetech
                        if(String.isNotEmpty(attendee.source_system_id) && String.isEmpty(attendee.source_system_attendee_id)){
                            for(Contact_External_Id_gne__c tmpContExt : conExtToInsert){
                                if( attendee.source_system_id == tmpContExt.Third_Party_gne__c && attendee.source_system_attendee_id == tmpContExt.Third_Party_Id_gne__c){
                                    attendee.SFDC_ID = tmpContExt.contact_gne__c;
                                    system.debug('MICK: PUT this SFDC :' + attendee.SFDC_ID);
                                }
                            } 
                            
                        }
                    }
                }
            }
        }

        //Fillout SFDC_ID in sites_list[].attendees_list[] from SFDC User
        for(User cur_user :  [Select ID, external_id_gne__c from User where external_id_gne__c IN :UNIX_IDs]){
            for(New_Event_Creation_WS.new_site ns: newEvent.sites_list){
                if(ns.attendees_list != null){
                    for(New_Event_Creation_WS.New_Attendee attendee: ns.attendees_list){
                        if(String.isNotEmpty(attendee.UNIX_ID)){
                            if(attendee.UNIX_ID.trim() == cur_user.external_id_gne__c){
                                attendee.SFDC_ID = cur_user.id;
                                break;              
                            }
                        }
                    }
                }
            }
        }                 
        
        for(New_Event_Creation_WS.new_site ns: newEvent.sites_list){
            if(ns.attendees_list != null){
                for(New_Event_Creation_WS.New_Attendee attendee: ns.attendees_list){
                    if(String.isNotEmpty(attendee.SFDC_ID)){
                        if(attendee.SFDC_ID.length() == 18){                                                     
                            attendee.SFDC_ID = attendee.SFDC_ID.substring(0,15);                          
                        }
                        evt_obj.att_obj.attendees.add(attendee.SFDC_ID);                        
                        evt_obj.att_obj.SFDC_to_attendees_map.put(attendee.SFDC_ID+ns.site_id, attendee);
                        //evt_obj.att_obj.SFDC_to_attendees_map.put(attendee.SFDC_ID, attendee);
                        //only putting into the map if they have an sfdc ID now ignoring all others
                        //Changes being made to now have the unique identifier be the Aprimo Event ID + the siteID 08/10/09
                        //ALTERED 09/23/09 TO NO LONGER USE evt_obj.Event_locations[0] but instead evt_obj.Parent_event                                                                                                                                             
                        
                        if(!evt_obj.att_obj.site_to_attendees_map.keySet().contains(evt_obj.Parent_Event.Source_System_ID_gne__c+ ns.site_id)){                            
                            evt_obj.att_obj.site_to_attendees_map.put(evt_obj.Parent_Event.Source_System_ID_gne__c+ns.site_id, new List<New_Event_Creation_WS.New_attendee>());                                                                   
                        }
                        evt_obj.att_obj.site_to_attendees_map.get(evt_obj.Parent_Event.Source_System_ID_gne__c+ns.site_id).add(attendee);                                                                                                                                                                
                    }else if(String.isBlank(attendee.UNIX_ID)){
                        //PP: Add logic to create placeholders here
                        evt_obj.placeh_obj.placeholders.add(attendee.source_system_attendee_id);
                        evt_obj.placeh_obj.ssaIdToPlaceholder.put(attendee.source_system_attendee_id, attendee);
                        if(!evt_obj.placeh_obj.site_to_placeholders_map.keySet().contains(evt_obj.Parent_Event.Source_System_ID_gne__c+ ns.site_id)){                            
                            evt_obj.placeh_obj.site_to_placeholders_map.put(evt_obj.Parent_Event.Source_System_ID_gne__c+ns.site_id, new List<New_Event_Creation_WS.New_attendee>());                                                                   
                        }
                        evt_obj.placeh_obj.site_to_placeholders_map.get(evt_obj.Parent_Event.Source_System_ID_gne__c+ns.site_id).add(attendee);
                        
                        //PP: lines below should be commented once placeholder logic will be done
                        //failuredAttendeesToLog.add(attendee);
                        //logger.error(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, String.valueOf(attendee), 'Site level participant omitted', evt_obj.Parent_Event.Source_System_ID_gne__c);
                    }                   
                }                   
            }
        }
        
        //logger.save();
        //GNE_EM3_Monitoring.insertEventAttendeeLogFailure('Site level participant omitted', failuredAttendeesToLog, newEvent);
        return evt_obj;
    }    
    
    public New_Event_Creation_WS.Events_obj addEventAttendees(New_Event_Creation_WS.New_Event ne, New_Event_Creation_WS.Events_obj evt_obj){
        System.debug('MICK: addEventAttendees was triggered');
        List<New_Event_Creation_WS.New_attendee> failuredAttendeesToLog = new List<New_Event_Creation_WS.New_attendee>(); 
        
        //helpers list to avoid inserting records ( account ,contacts , contact_ext_id) in loop
        List<Account> accToInsert = new List<Account>();
        List<Contact> contToInsert = new List<Contact>();
        List<Account> existingAcc = new List<Account>();
        List<Contact_External_Id_gne__c> conExtToInsert = new List<Contact_External_Id_gne__c>();
        
        //Collect UNIX_IDs
        Set<String> UNIX_IDs = new Set<String>();
        
        //get specified RecordTypes
        RecordType recordType = new RecordType();
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add(ACCOUNT_RECORD_TYPE_EVENT_COORDINATOR);
        recordTypeNames.add(ACCOUNT_RECORD_TYPE_PARTNER_VENDOR);
        Map<String, RecordType> recordTypes = getRecordTypes('Account', recordTypeNames);

        if(ne.attendees_list != null){
            for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                //skip if role is Requesting Third Party Org
                if(attendee.role == ATTENDEE_ROLE_RQSTTHDPTY){
                    continue;
                }
                    
                if(String.isNotEmpty(attendee.UNIX_ID)){
                    UNIX_IDs.add(attendee.UNIX_ID.trim());     
                }else {                      
                    //attendee is non-Genetech
                    if(String.isNotEmpty(attendee.source_system_id) && String.isNotEmpty(attendee.source_system_attendee_id) &&
                       (attendee.role.contains(ATTENDEE_ROLE_ACCOUNTABLE) || attendee.role.contains(ATTENDEE_ROLE_REQUESTOR))){
                        
                        Contact_External_Id_gne__c contactExternalId = contactExternalIdExists(attendee,evt_obj);
                        if(contactExternalId == null){
                            Account account = accountExists(attendee,evt_obj);
                            if(account == null){
                                account = new Account(Name = attendee.company_name, RecordTypeId = recordTypes.get(ACCOUNT_RECORD_TYPE_PARTNER_VENDOR).Id);
                                accToInsert.add(account);
                            }else{
                                existingAcc.add(account);
                            }
                            
                            //create Contact and assign Account
                            Contact contact = new Contact(
                                                  //accountId = account.Name,
                                                  firstName = attendee.first_name,
                                                  lastName = attendee.last_name,
                                                  Comments_frm_gne__c = account.Name,
                                                  Third_Party_gne__c = attendee.source_system_id,
                                                  Third_Party_Id_gne__c = attendee.source_system_attendee_id);
                                contToInsert.add(contact);
                           //assign SFDC_ID
                          //  ne.attendees_list[j].SFDC_ID = contact.id;
                        }else{
                            attendee.SFDC_ID = contactExternalId.Contact_gne__r.id;
                        }
                    }else{
                       // System.debug('Event (AprimoId='+ne.aprimo_event_id+') Attendee has been not added - there was no UnixId, source_system_id and source_system_attendee_id');
                    }
                }
            }
        }
        
        //MISZE:BUG FIX HD2678172 || code that was added to avoid inserting records in loop
        insert accToInsert;
        accToInsert.addAll(existingAcc);
        System.debug('MICK: accounts was inserted :' +accToInsert);             
        for( Account tmpAcc : accToInsert){
            for(Contact tmpCont : contToInsert){
                if(tmpCont.Comments_frm_gne__c == tmpAcc.Name){
                    tmpCont.accountId = tmpAcc.Id;
                    tmpCont.Comments_frm_gne__c = '';
                }
            }
        }
        insert contToInsert;
        
        for(Contact tmpCont : contToInsert){
            Contact_External_Id_gne__c contactExternalId = new Contact_External_Id_gne__c(
                                                   contact_gne__c = tmpCont.Id,
                                                   Third_Party_gne__c = tmpCont.Third_Party_gne__c,
                                                   Third_Party_Id_gne__c = tmpCont.Third_Party_Id_gne__c,
                                                   Third_Party_Index_gne__c = tmpCont.Third_Party_gne__c+tmpCont.Third_Party_Id_gne__c);
            conExtToInsert.add(contactExternalId); 
        }
        insert conExtToInsert;
        
        if(ne.attendees_list != null) {
            for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                //skip if role is Requesting Third Party Org
                if(attendee.role == ATTENDEE_ROLE_RQSTTHDPTY){
                    continue;
                }
                        
                if(String.isEmpty(attendee.UNIX_ID)){
                    //attendee is non-Genetech
                    if(String.isNotEmpty(attendee.source_system_id) && String.isNotEmpty(attendee.source_system_attendee_id) &&
                      (attendee.role.contains(ATTENDEE_ROLE_ACCOUNTABLE) || attendee.role.contains(ATTENDEE_ROLE_REQUESTOR))){
                        for(Contact_External_Id_gne__c tmpContExt : conExtToInsert){
                            if( attendee.source_system_id == tmpContExt.Third_Party_gne__c && attendee.source_system_attendee_id == tmpContExt.Third_Party_Id_gne__c){
                                attendee.SFDC_ID = tmpContExt.contact_gne__c;
                            }
                        } 
                    }
                }
            }
        }
        
        //end of code 
        
        
        /* //check for update Contacts data
        if(!contactIdsToCheck.isEmpty()){
            
            List<Contact> contactsToUpdate = new List<Contact>(); 
            Map<ID, Contact> contactAttendees = new Map<ID, Contact>([select c.id, c.account.Name from Contact c where id IN :contactIdsToCheck]);
            
            if(ne.attendees_list != null){
                for(Integer j=0;j<ne.attendees_list.size();j++){
                    New_Event_Creation_WS.New_Attendee attendee = ne.attendees_list[j];
                    //check if SFDC set and is in contacts to check for update
                    if(attendee.SFDC_ID != null && attendee.SFDC_ID != '' && contactAttendees.containsKey(attendee.SFDC_ID)){
                        Contact contact = contactAttendees.get(attendee.SFDC_ID);
                        if(attendee.company_name != contact.account.name){
                            Account account = evt_obj.addedAccounts.get(attendee.company_name);
                            contact.accountId = account.id; 
                            contactsToUpdate.add(contact);
                        }
                    }
                }
            }
    
            if(!contactsToUpdate.isEmpty()){
                upsert(contactsToUpdate);
            }
        }*/
        
        //Fillout SFDC_ID in ne.attendees_list[] from SFDC User
        for(User cur_user : [Select ID, external_id_gne__c from User where external_id_gne__c IN :UNIX_IDs]){
            if(ne.attendees_list != null){
                for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                    if(attendee.UNIX_ID.trim().equals(cur_user.external_id_gne__c)){
                        attendee.SFDC_ID = cur_user.id;
                        break;              
                    }
                }
            }
        }
                        
        if(ne.attendees_list != null){
            for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                if(attendee.SFDC_ID != null && attendee.SFDC_ID != ''){
                    if(attendee.SFDC_ID.length() == 18){                                                     
                        attendee.SFDC_ID = attendee.SFDC_ID.substring(0,15);                          
                    }
                    //concatenate event attendees roles
                    if(!evt_obj.att_obj.eventAttendeesMap.keySet().contains(attendee.SFDC_ID)){
                        evt_obj.att_obj.eventAttendeesMap.put(attendee.SFDC_ID, attendee);
                    }else{
                        New_Event_Creation_WS.New_Attendee modAttendee = evt_obj.att_obj.eventAttendeesMap.get(attendee.SFDC_ID);
                        modAttendee.role += ';' + attendee.role;
                        evt_obj.att_obj.eventAttendeesMap.put(attendee.SFDC_ID, modAttendee);
                    }
                }else{
                    //Vendor and Third Party are add in other method
                    if(!attendee.role.contains(ATTENDEE_ROLE_VENDOR) && !attendee.role.contains(ATTENDEE_ROLE_RQSTTHDPTY)){
                        failuredAttendeesToLog.add(attendee);
                        logger.error(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, String.valueOf(attendee), 'Event level participant omitted', ne.source_system_id);
                    }
                }                   
            }                   
        }
        
        logger.save(); 
        GNE_EM3_Monitoring.insertEventAttendeeLogFailure('Event level participant omitted', failuredAttendeesToLog, ne);      
        return evt_obj;
    }
    
    public New_Event_Creation_WS.Events_obj createEventAttendees(New_Event_Creation_WS.Events_obj evt_obj,New_Event_Creation_WS.New_Event ne){
    
        List<Event_Attendee_vod__c> attendeesToUpdate = new List<Event_Attendee_vod__c>();
        Set<String> alreadyUpdatedAttendees = new Set<String>();

        //creates list's of all accounts/contacts and user's which are attendees in SITES
        List<Account> accountAttendees = [select id from Account where id IN :evt_obj.att_obj.eventAttendeesMap.keySet()];                                       
        List<Contact> contactAttendees = [select id from Contact where id IN :evt_obj.att_obj.eventAttendeesMap.keySet()];              
        List<User> userAttendees = [select id, External_ID_gne__c from User where id IN :evt_obj.att_obj.eventAttendeesMap.keySet()]; 
        
        Set<String> accountAttendeeIds = new Set<String>();
        Set<String> contactAttendeeIds = new Set<String>();
        Set<String> userAttendeeIds = new Set<String>();
        
        for(Account acc : accountAttendees){
            accountAttendeeIds.add(((String)acc.id).substring(0,15));           
        }                           
        
        for(Contact cont : contactAttendees){
            contactAttendeeIds.add(((String)cont.id).substring(0,15)); 
        }
        
        for(User user : userAttendees){
            userAttendeeIds.add(((String)user.id).substring(0,15)); 
        }           
        
        //each of these maps are used to contain the account/contact/user id and the Event Attendee related to
        Map<String, Event_Attendee_vod__c> eventAttendeeAccountMap = new Map<String,Event_Attendee_vod__c>();
        Map<String, Event_Attendee_vod__c> eventAttendeeContactMap = new Map<String,Event_Attendee_vod__c>();
        Map<String, Event_Attendee_vod__c> eventAttendeeUserMap = new Map<String,Event_Attendee_vod__c>();
        
        //get the event attendee and account id for all medical events and account's that are in the acc_attendee list
        //these accounts are for event attendees to be UPDATED
        for(Event_Attendee_vod__c acc_attend : [select id, Medical_Event_vod__c, Account_vod__c from Event_Attendee_vod__c e where Account_vod__c IN :accountAttendees
        AND e.Medical_Event_vod__c = :evt_obj.parent_event.id]){
            String id = acc_attend.Account_vod__c;
            eventAttendeeAccountMap.put(id.substring(0,15),acc_attend);               
        }
        
        //get the event attendee and contact id for all medical events and contact's that are in the cont_attendee list
        //these contacts are for event attendees to be UPDATED      
        for(Event_Attendee_vod__c cont_attend : [select id, Medical_Event_vod__c, Contact_vod__c from Event_Attendee_vod__c where Contact_vod__c IN :contactAttendees
        AND Medical_Event_vod__c = :evt_obj.parent_event.id]){
            String id = cont_attend.Contact_vod__c;
            eventAttendeeContactMap.put(id.substring(0,15),cont_attend);
        }
        
        //get the event attendee and user id for all medical events and user's that are in the user_attendee list
        //these users are for event attendees to be UPDATED     
        for(Event_Attendee_vod__c user_attend : [select id, Medical_Event_vod__c, User_vod__c from Event_Attendee_vod__c where user_vod__c IN :userAttendees
        AND Medical_Event_vod__c = :evt_obj.parent_event.id]){
            String id = user_attend.User_vod__c;
            eventAttendeeUserMap.put(id.substring(0,15),user_attend);
        }               
        
        List<New_Event_Creation_WS.New_attendee> attendeesToLog = new List<New_Event_Creation_WS.New_attendee>(); 
        
        //go through new_attendee list and prepare it to update
        for(New_Event_Creation_WS.New_attendee currentEventAttendee : evt_obj.att_obj.eventAttendeesMap.values()){
            
            String id = currentEventAttendee.SFDC_ID;

            Event_Attendee_vod__c attendee;
            Boolean attendeeUpdated = false;
            
            //check if Event Attendee with Account exists if yes 
            if(eventAttendeeAccountMap.keySet().contains(id)){
                attendee = eventAttendeeAccountMap.get(id);
                attendeeUpdated = true;
            }
            
            //check if Event Attendee with Contact exists if yes
            if(eventAttendeeContactMap.keySet().contains(id)){
                attendee = eventAttendeeContactMap.get(id);
                attendeeUpdated = true;
            }
            
            //check if Event Attendee with Contact exists if yes
            if(eventAttendeeUserMap.keySet().contains(id)){
                attendee = eventAttendeeUserMap.get(id);
                attendeeUpdated = true;
            }
            
            if(attendeeUpdated){
                if(!alreadyUpdatedAttendees.contains(id)){
                    attendee.Role_gne__c = evt_obj.att_obj.eventAttendeesMap.get(id).role;
                }else{
                    attendee.Role_gne__c = ';'+evt_obj.att_obj.eventAttendeesMap.get(id).role;
                }
                attendee.Status_vod__c = evt_obj.att_obj.eventAttendeesMap.get(id).status;                    
                attendee.Individual_Role_Code_gne__c = evt_obj.att_obj.eventAttendeesMap.get(id).individual_role_code;
            }else{
                attendee = new Event_Attendee_vod__c(
                    Medical_Event_vod__c = evt_obj.parent_event.id,
                    Role_gne__c = currentEventAttendee.role,
                    Status_vod__c = currentEventAttendee.Status,
                    Individual_Role_Code_gne__c = currentEventAttendee.individual_role_code
                );
                
                if(accountAttendeeIds.contains(id)){
                    attendee.Account_vod__c = currentEventAttendee.SFDC_ID;
                }
                if(contactAttendeeIds.contains(id)){
                    attendee.Contact_vod__c = currentEventAttendee.SFDC_ID;
                }
                if(userAttendeeIds.contains(id)){
                    attendee.User_vod__c = currentEventAttendee.SFDC_ID;
                }

                attendeesToLog.add(evt_obj.att_obj.eventAttendeesMap.get(id));
            }
            alreadyUpdatedAttendees.add(id);                    
            attendeesToUpdate.add(attendee);
            
        }
        
        GNE_EM3_Monitoring.insertEventAttendeeLogSuccess(attendeesToLog,ne);
        evt_obj.att_spk_obj.event_attendees_to_update = attendeesToUpdate;
        
        return evt_obj;
    }

    /**
    * Method check if Contact exists for specified attendee by checking if there is entry ContactExternalId table
    * @author: Sebastian Wajrych
    */
    private static Contact_External_Id_gne__c contactExternalIdExists(New_Event_Creation_WS.New_attendee attendee, New_Event_Creation_WS.Events_obj evt_obj){
        
        if(evt_obj.addedContactExternalIds.containsKey(attendee.source_system_id+attendee.source_system_attendee_id)){
            return evt_obj.addedContactExternalIds.get(attendee.source_system_id+attendee.source_system_attendee_id);
        }
        return null;
    }
    
    /**
    * Method check if Account for attendee company aleady exists by checking company_name of attendee
    * @author: Sebastian Wajrych
    */
    private static Account accountExists(New_Event_Creation_WS.New_attendee attendee, New_Event_Creation_WS.Events_obj evt_obj){
        
        if(evt_obj.addedAccounts.containsKey(attendee.company_name)){
            return evt_obj.addedAccounts.get(attendee.company_name);
        }
        
        return null;
    }
    
    /**
    * Get Map<String, RecordType> by specified object name and list of record types names
    * TODO:move it to some global util
    * @author: Sebastian Wajrych
    */
    public static Map<String, RecordType> getRecordTypes(String objTypeName, List<String> recordTypeNames){
    
        Map<String, RecordType> recordTypesMap = new Map<String, RecordType>();
        List<RecordType> recordTypesList;
        if(recordTypeNames != null && recordTypeNames.size()>0){
            recordTypesList = [Select Name,Id From RecordType where Name IN :recordTypeNames AND SObjectType = :objTypeName];
        }else{
            recordTypesList = [Select Name,Id From RecordType where SObjectType = :objTypeName];
        }
        
        for(Integer i=0; i<recordTypesList.size(); i++){
            recordTypesMap.put(recordTypesList[i].Name, recordTypesList[i]);
        }
 
        return recordTypesMap;
    
    }
    
    /**
    * Remove duplicated New_Attendees and concatenate their roles
    * @author: Sebastian Wajrych 
    */
    public List<New_Event_Creation_WS.New_Attendee> compileAttendeeRoles(List<New_Event_Creation_WS.New_Attendee> attendees, List<New_Event_Creation_WS.New_Attendee> eventAttendees){
        
        Map<String, New_Event_Creation_WS.New_Attendee> attendeesMap = new Map<String, New_Event_Creation_WS.New_Attendee>();
        
        for(New_Event_Creation_WS.New_Attendee attendee : attendees){
            String attendeeKey = getAttendeeKey(attendee);
                        
            //add new attendee or just concatenate next role like role1;role2
            if(attendeesMap.containsKey(attendeeKey)){
                attendeesMap.get(attendeeKey).role += ';'+ attendee.role;
                attendeesMap.get(attendeeKey).globalTransactionIdentifier += ';'+ attendee.globalTransactionIdentifier;
            }else{
                attendeesMap.put(attendeeKey, attendee);
            }
        }
                        
        //preparing event lvl attendee
        if(eventAttendees != null) {
            for(New_Event_Creation_WS.New_Attendee eventAttendee : eventAttendees){
                String eventAttendeeKey = getAttendeeKey(eventAttendee);
                if(attendeesMap.containsKey(eventAttendeeKey)){
                    attendeesMap.get(eventAttendeeKey).role += ';'+ eventAttendee.Role;
                    attendeesMap.get(eventAttendeeKey).globalTransactionIdentifier += ';'+ eventAttendee.globalTransactionIdentifier;
                }
                /*
                else{
                    attendeesMap.put(eventAttendeeKey, eventAttendee);
                }
                */
            }
        }
        return attendeesMap.values();
    }
    
    /**
    * Remove duplicated New_Attendees and concatenate their roles
    * @author: Sebatian Wajrych 
    */
    public List<New_Event_Creation_WS.New_Attendee> compileEventAttendeeRoles(List<New_Event_Creation_WS.New_Attendee> attendees){
        if(attendees == null){
            return null;
        }
        Map<String,New_Event_Creation_WS.New_Attendee> attendeesMap = new Map<String,New_Event_Creation_WS.New_Attendee>();
        
        for(New_Event_Creation_WS.New_Attendee attendee : attendees){
            //skip attendee if is Vendor
            if(attendee.role == ATTENDEE_ROLE_VENDOR){
                continue;
            }
            String attendeeKey = getAttendeeKey(attendee);
            //add new attendee or just concatenate next role like role1;role2
            if(attendeesMap.containsKey(attendeeKey)){
                attendeesMap.get(attendeeKey).role += ';'+ attendee.role;
                attendeesMap.get(attendeeKey).globalTransactionIdentifier += ';'+ attendee.globalTransactionIdentifier;
            }else{
                attendeesMap.put(attendeeKey,attendee);
            }
        }
        return attendeesMap.values();
    }
    
    //prepare unic key - for GNE and non-GNE attendee
    private String getAttendeeKey(New_Event_Creation_WS.New_Attendee attendee){
        if(attendee.source_system_id != null && attendee.source_system_attendee_id != null){
            return attendee.source_system_id+attendee.source_system_attendee_id;
        }
        return attendee.UNIX_ID;
    }
    
    /**
    * Method create comma separated list of vendors and place it in event_obj
    */
    public New_Event_Creation_WS.Events_obj addVendors(New_Event_Creation_WS.New_Event ne, New_Event_Creation_WS.Events_obj evt_obj){
        List<New_Event_Creation_WS.New_attendee> successAttendeesToLog = new List<New_Event_Creation_WS.New_attendee>();
        if(ne.attendees_list != null){
            for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                if(attendee.role == ATTENDEE_ROLE_VENDOR){
                    if(evt_obj.vendors != ''){
                        evt_obj.vendors += ', '+ attendee.company_name;
                    }else{
                        evt_obj.vendors = attendee.company_name;
                    }
                    successAttendeesToLog.add(attendee);
                }
            }
        }
        GNE_EM3_Monitoring.insertEventAttendeeLogSuccess(successAttendeesToLog,ne);
        return evt_obj;
    }
    
    public New_Event_Creation_WS.Events_obj prepareExistingContactExternalIdsAndAccounts(New_Event_Creation_WS.New_Event ne, New_Event_Creation_WS.Events_obj evt_obj){
        Set<String> thirdPartyIndexes = new Set<String>();
        Set<String> companyNames = new Set<String>();
        
        //prepare Event level attendees Ids
        if(ne.attendees_list != null){
            for(New_Event_Creation_WS.New_Attendee attendee: ne.attendees_list){
                if(attendee.source_system_id != null && attendee.source_system_attendee_id != null){
                    thirdPartyIndexes.add(attendee.source_system_id+attendee.source_system_attendee_id);
                    companyNames.add(attendee.company_name);
                } 
            }
        }
        
        //prepare Site level attendees Ids
        for(New_Event_Creation_WS.new_site ns: ne.sites_list){
            if(ns.attendees_list != null){
                for(New_Event_Creation_WS.New_Attendee attendee : ns.attendees_list){
                    if(attendee.source_system_id != null && attendee.source_system_attendee_id != null){
                        thirdPartyIndexes.add(attendee.source_system_id+attendee.source_system_attendee_id);
                        companyNames.add(attendee.company_name);
                    }
                }
            }
        }
         
        for(Contact_External_Id_gne__c contactExternalId : [SELECT Contact_gne__r.id, Third_Party_gne__c, Third_Party_Id_gne__c, Third_Party_Index_gne__c  
                                                               FROM Contact_External_Id_gne__c c
                                                               WHERE c.Third_Party_Index_gne__c IN :thirdPartyIndexes]){
            evt_obj.addedContactExternalIds.put(contactExternalId.Third_Party_Index_gne__c, contactExternalId);
        }    
        
        for(Account iAccount : [SELECT Name, Id FROM Account WHERE Name IN :companyNames]){
            evt_obj.addedAccounts.put(iAccount.Name, iAccount);
        }   
        
        return evt_obj;
    }
    
    public Set<String> createUsersByUnixId(New_Event_Creation_WS.New_Event ne){
        Set<String> attIds = new Set<String>();
        Map<String, New_Event_Creation_WS.New_attendee> attendees = collectNonSFDCUsersUnixIds(ne);
        List<Profile> infreqProfs = [Select Id, name from Profile where name = :INFREQUENT_USER_PROF];
        if(infreqProfs.size() < 1){
            //TODO add entry to error log
        }  
        system.debug('XX UserCreation : ' + attendees);
        if(attendees.size()>0){
            List<User> usersToInsert = new List<User>();
            for(String attendeeUnixId : attendees.keySet()){
                try{
                    User newUser = new User();
                    newUser.IsActive = false;
                    newUser.TimeZoneSidKey = DEFAULT_TIME_ZN;
                    newUser.LocaleSidKey = DEFAULT_LOCALE_KEY;
                    newUser.EmailEncodingKey = DEFAULT_EMAIL_KEY;
                    newUser.LanguageLocaleKey = DEFAULT_LANG_LOC_KEY;
                    
                    newUser.firstName = attendees.get(attendeeUnixId).first_name;
                    newUser.lastName = attendees.get(attendeeUnixId).last_name;
                    if(attendeeUnixId.Length() >= 7){
                        newUser.alias = attendeeUnixId.substring(0,7);
                    }
                    else {
                        newUser.alias = attendeeUnixId;
                    }
                    newUser.username = attendeeUnixId +'@gene.com';
                    newUser.email = attendeeUnixId +'@gene.com'; 
                    newUser.FederationIdentifier = attendeeUnixId +'@gene.com'; 
                    // Append Sandbox names to username if in sandbox.
                    if (Utilities.getEnvironmentName() <> 'prod'){
                        newUser.username += '.'+ Utilities.getEnvironmentName();
                    }
                    newUser.CommunityNickname = attendeeUnixId;
                    newUser.ProfileId = infreqProfs[0].Id;
                    usersToInsert.add(newUser);
                }catch (Exception e){
                   System.debug('Exception ' + e);
                }
            }
            
            // Report errors on console
            Database.SaveResult[] insertResults = Database.insert(usersToInsert,false);
            if(insertResults!=null) {
                for (Database.SaveResult result : insertResults) {
                    if(!result.isSuccess()) {
                    Database.Error[] errs = result.getErrors();                     
                    for(Database.Error err : errs) 
                        System.debug('Exception ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            } // End report errors
            
            //MIXED_DML_OPERATION error workaround, role updates are mode in @future method
            //workaround for batch
            attIds = attendees.keySet();
            //em3_utils_2.setRolesToNewUsers(attendees.keySet());            
        }

        return attIds;
    }
    
    private static Map<String, New_Event_Creation_WS.New_attendee> collectNonSFDCUsersUnixIds(New_Event_Creation_WS.New_Event ne){
        Set<String> UNIX_IDs = new Set<String>();
        
        //collect Event level Attendees
        if(ne.attendees_list != null){
            for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                //skip if role is Requesting Third Party Org
                if(attendee.role == 'Requesting Third Party Organization'){
                    continue;
                }
                if(String.isNotEmpty(attendee.UNIX_ID)){
                    UNIX_IDs.add(attendee.UNIX_ID.trim());     
                }
            }
        }
        
        //collect Site level Attendees
        if(ne.sites_list != null){
            for(New_Event_Creation_WS.new_site ns: ne.sites_list){
                if(ns.attendees_list != null){
                    for(New_Event_Creation_WS.New_Attendee attendee : ns.attendees_list){
                        if(String.isNotEmpty(attendee.UNIX_ID)){
                            UNIX_IDs.add(attendee.UNIX_ID.trim());     
                        }
                    }
                }
            }
        }

        //Find users by UNIX_IDs              
        List<User> unixID_list = [Select ID, external_id_gne__c from User where external_id_gne__c IN :UNIX_IDs];
        
        //Check for attendees with UnixID but withour account in SFDC
        Set<String> unixID_list_set = new Set<String>();  
        for(User iUser :unixID_list){
            unixID_list_set.add(iUser.external_id_gne__c);
        }
        
        UNIX_IDs.removeAll(unixID_list_set);        
        
        return assignAttendeesByUnixId(UNIX_IDs, ne);
         
    }
    
    private static Map<String, New_Event_Creation_WS.New_attendee> assignAttendeesByUnixId(Set<String> unixIds, New_Event_Creation_WS.New_Event ne){
        Map<String, New_Event_Creation_WS.New_attendee> attendees = new Map<String, New_Event_Creation_WS.New_attendee>();

        for(String unixId : unixIds){
            //check on Event level
            if(ne.attendees_list != null){
                for(New_Event_Creation_WS.New_Attendee attendee : ne.attendees_list){
                    if(String.isNotEmpty(attendee.UNIX_ID) && attendee.UNIX_ID == unixId){
                        attendees.put(unixId, attendee);
                        break;
                    }
                }
            }
            
            //check on Site level
            if(ne.sites_list != null){
                for(New_Event_Creation_WS.new_site ns: ne.sites_list){
                    if(ns.attendees_list != null){
                        for(New_Event_Creation_WS.New_Attendee attendee : ns.attendees_list){
                            if(String.isNotEmpty(attendee.UNIX_ID) && attendee.UNIX_ID == unixId){
                                attendees.put(unixId, attendee);
                                break;
                            }
                        }
                    }
                }
            }
        }
         
        return attendees;
    }
    
    @future
    public static void setRolesToNewUsersFuture(Set<String> unixIds){
        System.debug('setRolesToNewUsers entry ' + unixIds);
        if (unixIds != null && unixids.size() > 0) {
            List<UserRole> stdRoles = [Select Id, name from UserRole where name = :STNDRD_USER];
            List<User> emptyRoleUsers = [Select id,UserRoleId from User where alias = :unixIds];
            for(User updatedUser : emptyRoleUsers){
                updatedUser.UserRoleId = stdRoles[0].Id;
                System.debug('setRolesToNewUsers update ' + stdRoles[0].Id);
            }
            update emptyRoleUsers;
        }
    }

    //@future
    public static void setRolesToNewUsers(Set<String> unixIds){
        System.debug('setRolesToNewUsers entry ' + unixIds);
        if (unixIds != null && unixids.size() > 0) {
            List<UserRole> stdRoles = [Select Id, name from UserRole where name = :STNDRD_USER];
            List<User> emptyRoleUsers = [Select id,UserRoleId from User where alias = :unixIds];
            for(User updatedUser : emptyRoleUsers){
                updatedUser.UserRoleId = stdRoles[0].Id;
                System.debug('setRolesToNewUsers update ' + stdRoles[0].Id);
            }
            update emptyRoleUsers;
        }
    }
    
    //@future
    public static void populateSpeakersNameField(String sourceSystemId){
        //collect locations
        List<Medical_Event_vod__c> locations = [Select ID,Speakers_Name_gne__c from Medical_Event_vod__c me where me.parent_medical_event_gne__c != null and me.Source_System_ID_gne__c=:sourceSystemId for update];
        
        //get list of attendees
        Map<String,List<Event_Attendee_vod__c>> eventAttendees = new Map<String,List<Event_Attendee_vod__c>>(); 
        for(Event_Attendee_vod__c attendee : [Select e.Role_gne__c, e.Account_vod__c, e.Account_vod__r.Name, e.Contact_vod__c, e.Contact_vod__r.Name, e.Medical_Event_vod__c, e.Medical_Event_vod__r.Id, e.User_vod__c, e.User_vod__r.Name 
                                                from 
                                                    Event_Attendee_vod__c e 
                                                where 
                                                    e.Medical_Event_vod__c IN :locations
                                                    and e.Role_gne__c includes ('Speaker')]){
            if(!eventAttendees.keySet().contains(attendee.Medical_Event_vod__r.Id)){
                eventAttendees.put(attendee.Medical_Event_vod__r.Id, new List<Event_Attendee_vod__c>());                                                           
            } 
            eventAttendees.get(attendee.Medical_Event_vod__r.Id).add(attendee);
        }
        
        for(Medical_Event_vod__c location : locations){
            
            List<Event_Attendee_vod__c> selectedEventAttendees = eventAttendees.get(location.ID);
            if(selectedEventAttendees != null){
                location.Speakers_Name_gne__c = '';
                for(Event_Attendee_vod__c selectedAttendee : selectedEventAttendees){
                    String attendeeName = '';
                    if(selectedAttendee.Contact_vod__c != null){
                        attendeeName = selectedAttendee.Contact_vod__r.Name;
                    }
                    if(selectedAttendee.User_vod__c != null){
                        attendeeName = selectedAttendee.User_vod__r.Name;
                    }
                    if(selectedAttendee.Account_vod__c != null){
                        attendeeName = selectedAttendee.Account_vod__r.Name;
                    }
                    String toCheckSize = location.Speakers_Name_gne__c + attendeeName; 
                    if(toCheckSize.length()+3>255){
                        location.Speakers_Name_gne__c = location.Speakers_Name_gne__c + '...';
                        break;
                    }
                    
                    if(location.Speakers_Name_gne__c == null || location.Speakers_Name_gne__c == ''){
                        location.Speakers_Name_gne__c = attendeeName;
                    }else{
                        location.Speakers_Name_gne__c = location.Speakers_Name_gne__c + '; '+ attendeeName; 
                    }
                }
            }
             
        }        
        upsert(locations);
        System.debug('populateSpeakersNameField');
    }
    
    /*
    private static New_Event_Creation_WS.Events_obj createSiteLevelAccount(New_Event_Creation_WS.New_Attendee attendee, New_Event_Creation_WS.Events_obj evt_obj, Map<String, RecordType> recordTypes){
        
        Account account = accountExists(attendee,evt_obj);
        if(account == null){
            //select and set proper RecordType of new Account
            if(attendee.role != null && (attendee.role == ATTENDEE_ROLE_PARTNER || attendee.role == ATTENDEE_ROLE_VENDOR_STAFF)){
                if(attendee.role == ATTENDEE_ROLE_PARTNER){
                    account = new Account(
                        Name = attendee.company_name,
                        RecordTypeId = recordTypes.get(ACCOUNT_RECORD_TYPE_PARTNER_VENDOR).Id
                    );
                }
                if(attendee.role == ATTENDEE_ROLE_VENDOR_STAFF){
                    account = new Account(
                        Name = attendee.company_name,
                        RecordTypeId = recordTypes.get(ACCOUNT_RECORD_TYPE_EVENT_COORDINATOR).Id
                    );
                }
            }else{
                return null;
            }
            insert account;
            evt_obj.addedAccounts.put(account.Name,account);
        }
        
        return evt_obj;
    
    }*/
   
}