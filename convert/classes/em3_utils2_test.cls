@isTest
private class em3_utils2_test {

    static testMethod void add_attendees_nonGenetech() {
       
        Em3_utils_2 em3_utils_2 = new Em3_utils_2();
        
        

        New_Event_Creation_WS.Events_obj event = new New_Event_Creation_WS.Events_obj();
        List<Medical_Event_vod__c> medicalEvents = new List<Medical_Event_vod__c>();
        Medical_Event_vod__c medicalEvent = new Medical_Event_vod__c();
        medicalEvent.aprimo_Event_ID_gne__c = 'aprimo_event_id';
        medicalEvents.add(medicalEvent);
        event.event_locations = medicalEvents;
       
        List<New_Event_Creation_WS.new_site> sites = new List<New_Event_Creation_WS.new_site>();
        New_Event_Creation_WS.new_site site = new New_Event_Creation_WS.new_site();
                               
        New_Event_Creation_WS.New_attendee attendeeGenetech = new New_Event_Creation_WS.New_attendee();
        attendeeGenetech.UNIX_ID = 'wajrycs1';
        
        //TODO: How to create user?
        //Profile profile = new Profile();
        //User userGenetech = new User(username='wajrycs1',Profile = profile);
        //userGenetech.Profile_Name_gne__c = 'wajrycs1';
        //insert userGenetech;
        // 
        
        New_Event_Creation_WS.New_attendee attendeeNonGenetechJohn = new New_Event_Creation_WS.New_attendee();
        attendeeNonGenetechJohn.first_name = 'John';
        attendeeNonGenetechJohn.last_name = 'Bean';
        attendeeNonGenetechJohn.source_system_id = 'PW';
        attendeeNonGenetechJohn.source_system_attendee_id = '1234';
        attendeeNonGenetechJohn.company_name = 'Skynet Inc.';
        attendeeNonGenetechJohn.individual_role_code = 'Vendor';
        attendeeNonGenetechJohn.role = 'Vendor Staff';
        
        New_Event_Creation_WS.New_attendee attendeeNonGenetechGary = new New_Event_Creation_WS.New_attendee();
        attendeeNonGenetechGary.first_name = 'Gary';
        attendeeNonGenetechGary.last_name = 'Moveout';
        attendeeNonGenetechGary.source_system_id = 'TSG';
        attendeeNonGenetechGary.source_system_attendee_id = '1235';
        attendeeNonGenetechGary.company_name = 'Skynet Inc.';
        attendeeNonGenetechJohn.role = 'Partner';
        attendeeNonGenetechGary.individual_role_code = 'Partner';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor3 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor3.role = 'Requestor';
        eventAttendeeRequestor3.UNIX_ID = 'beanj';
        
                        
        //attendees.add(attendeeGenetech);
        site.attendees_list = new List<New_Event_Creation_WS.New_attendee>();
        site.attendees_list.add(attendeeNonGenetechJohn);
        site.attendees_list.add(attendeeNonGenetechGary);
        site.attendees_list.add(eventAttendeeRequestor3);
        site.site_id = 'site_id';
        sites.add(site);
        
        New_Event_Creation_WS.New_Event newEvent = new New_Event_Creation_WS.New_Event();
        //newEvent.globalTransactionIdentifier;
        //newEvent.aprimo_event_id;
        //newEvent.Name;
        //newEvent.Event_Planned_date_1; //changed to 1
        //newEvent.Event_Planned_date_2;      
        //newEvent.Event_Planned_date_3;
        //newEvent.Event_Series_name;
        //newEvent.event_Type;
        //newEvent.timing;
        //newEvent.Event_Sub_type_Code;
        //newEvent.curriculum_version_id;
        //newEvent.status;   
        //newEvent.start_date;
        //newEvent.start_time;
        //newEvent.time_zone;
        //newEvent.end_date;
        //newEvent.speaker_bureau_id;
        //newEvent.medium_type;
        //newEvent.method_of_delivery;
        //newEvent.brands; //changed FROM brand_product //is this to be mapped to brands_gne__c?
        //newEvent.indications; //changed FROM indication_product
        //newEvent.therapeutic_areas; //changed FROM therapeutic_product
        //newEvent.requesting_third_party_org;   // same as requesting company
        newEvent.sites_list = sites; 
        //newEvent.source_system;
        //newEvent.source_system_id;
        newEvent.attendees_list = new List<New_Event_Creation_WS.New_attendee>();
        newEvent.attendees_list.add(attendeeNonGenetechJohn);
        newEvent.attendees_list.add(attendeeNonGenetechGary);
        newEvent.attendees_list.add(eventAttendeeRequestor3);
        //newEvent.request_date;
        //newEvent.invitations_sent_date;
        //newEvent.event_created_by; //text field

        Test.StartTest();
        
        event = em3_utils_2.add_attendees(newEvent,event);
        
        Test.StopTest();
        
        
        
    }
    
    
    static testMethod void concatenateAttendeeRoles() {
        
        Em3_utils_2 em3_utils_2 = new Em3_utils_2();
        
        //Site lvl attendees
        List<New_Event_Creation_WS.New_Attendee> attendees = new List<New_Event_Creation_WS.New_Attendee>();
        
        New_Event_Creation_WS.New_attendee attendeeAttendee = new New_Event_Creation_WS.New_attendee();
        attendeeAttendee.role = 'Attendee';
        attendeeAttendee.source_system_id = 'TSG';
        attendeeAttendee.source_system_attendee_id = '1234';
        
        New_Event_Creation_WS.New_attendee attendeeSpeaker = new New_Event_Creation_WS.New_attendee();
        attendeeSpeaker.role = 'Speaker';
        attendeeSpeaker.source_system_id = 'PW';
        attendeeSpeaker.source_system_attendee_id = '4444';
        
        New_Event_Creation_WS.New_attendee attendeeAttendee2 = new New_Event_Creation_WS.New_attendee();
        attendeeAttendee2.role = 'Attendee';
        attendeeAttendee2.UNIX_ID = 'beanj';
        
        attendees.add(attendeeAttendee);
        attendees.add(attendeeSpeaker);
        attendees.add(attendeeAttendee2);
        
        //Event lvl attendees
        List<New_Event_Creation_WS.New_Attendee> eventAttendees = new List<New_Event_Creation_WS.New_Attendee>();
        
        New_Event_Creation_WS.New_attendee eventAttendeeAccountable = new New_Event_Creation_WS.New_attendee();
        eventAttendeeAccountable.role = 'Accountable';
        eventAttendeeAccountable.source_system_id = 'TSG';
        eventAttendeeAccountable.source_system_attendee_id = '1234';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor.role = 'Requestor';
        eventAttendeeRequestor.source_system_id = 'TSG';
        eventAttendeeRequestor.source_system_attendee_id = '1234';
        
        New_Event_Creation_WS.New_attendee eventAttendeeVendor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeVendor.role = 'Vendor';
        eventAttendeeVendor.company_name = 'Vendor Company Name';
        eventAttendeeVendor.source_system_id = 'PW';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor2 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor2.role = 'Requestor';
        eventAttendeeRequestor2.source_system_id = 'PW';
        eventAttendeeRequestor2.source_system_attendee_id = '4444';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor3 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor3.role = 'Requestor';
        eventAttendeeRequestor3.UNIX_ID = 'beanj';
        
        eventAttendees.add(eventAttendeeAccountable);
        eventAttendees.add(eventAttendeeRequestor);
        eventAttendees.add(eventAttendeeVendor);
        eventAttendees.add(eventAttendeeRequestor2);
        eventAttendees.add(eventAttendeeRequestor3);
        
        
        Test.StartTest();
        
        attendees = em3_utils_2.compileAttendeeRoles(attendees,eventAttendees);
                
        Test.StopTest();
        
        System.debug(attendees);
        System.assertEquals(attendees.size(),3);

        for(New_Event_Creation_WS.New_attendee attendee: attendees){
            if(attendee.source_system_id == '1234'){
                System.assertEquals(attendee.role,'Attendee;Accountable;Requestor');
            }
            if(attendee.source_system_id == '4444'){
                System.assertEquals(attendee.role,'Speaker;Requestor');
            }
            if(attendee.UNIX_ID == 'beanj'){
                System.assertEquals(attendee.role,'Attendee;Requestor');
            }
        }
    }
    
    static testMethod void compileEventAttendeeRoles(){
                    
        Em3_utils_2 em3_utils_2 = new Em3_utils_2();
        
        //Event lvl attendees
        List<New_Event_Creation_WS.New_Attendee> eventAttendees = new List<New_Event_Creation_WS.New_Attendee>();
        
        New_Event_Creation_WS.New_attendee eventAttendeeAccountable = new New_Event_Creation_WS.New_attendee();
        eventAttendeeAccountable.role = 'Accountable';
        eventAttendeeAccountable.source_system_id = 'TSG';
        eventAttendeeAccountable.source_system_attendee_id = '1234';
            
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor.role = 'Requestor';
        eventAttendeeRequestor.source_system_id = 'TSG';
        eventAttendeeRequestor.source_system_attendee_id = '1234';
            
        New_Event_Creation_WS.New_attendee eventAttendeeVendor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeVendor.role = 'Vendor';
        eventAttendeeVendor.company_name = 'Vendor Company Name';
        eventAttendeeVendor.source_system_id = 'PW';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor2 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor2.role = 'Requestor';
        eventAttendeeRequestor2.source_system_id = 'PW';
        eventAttendeeRequestor2.source_system_attendee_id = '4444';
            
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor3 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor3.role = 'Requestor';
        eventAttendeeRequestor3.UNIX_ID = 'beanj';
        
        eventAttendees.add(eventAttendeeAccountable);
        eventAttendees.add(eventAttendeeRequestor);
        eventAttendees.add(eventAttendeeVendor);
        eventAttendees.add(eventAttendeeRequestor2);
        eventAttendees.add(eventAttendeeRequestor3);
        
        Test.StartTest();
        
        eventAttendees = em3_utils_2.compileEventAttendeeRoles(eventAttendees);
            
        Test.StopTest();
        
        System.assertEquals(eventAttendees.size(),3);

        for(New_Event_Creation_WS.New_attendee attendee: eventAttendees){
            if(attendee.source_system_id == '1234'){
                System.assertEquals(attendee.role,'Accountable;Requestor');
            }
            if(attendee.source_system_id == '4444'){
                System.assertEquals(attendee.role,'Requestor');
            }
            if(attendee.UNIX_ID == 'beanj'){
                System.assertEquals(attendee.role,'Requestor');
            }
        }
        
    }
    
    static testMethod void addVendors(){
    
        Em3_utils_2 em3_utils_2 = new Em3_utils_2();
        
        New_Event_Creation_WS.New_Event ne = new New_Event_Creation_WS.New_Event(); 
        New_Event_Creation_WS.Events_obj evt_obj = new New_Event_Creation_WS.Events_obj();
        
        //Event lvl attendees
        List<New_Event_Creation_WS.New_Attendee> eventAttendees = new List<New_Event_Creation_WS.New_Attendee>();
        
        New_Event_Creation_WS.New_attendee eventAttendeeAccountable = new New_Event_Creation_WS.New_attendee();
        eventAttendeeAccountable.role = 'Accountable';
        eventAttendeeAccountable.source_system_id = 'TSG';
        eventAttendeeAccountable.source_system_attendee_id = '1234';
            
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor.role = 'Requestor';
        eventAttendeeRequestor.source_system_id = 'TSG';
        eventAttendeeRequestor.source_system_attendee_id = '1234';
            
        New_Event_Creation_WS.New_attendee eventAttendeeVendor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeVendor.role = 'Vendor';
        eventAttendeeVendor.company_name = 'Vendor Company Name';
        eventAttendeeVendor.source_system_id = 'PW';
        
        New_Event_Creation_WS.New_attendee eventAttendeeVendor2 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeVendor2.role = 'Vendor';
        eventAttendeeVendor2.company_name = 'Vendor2 Company Name';
        eventAttendeeVendor2.source_system_id = 'PW';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor2 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor2.role = 'Requestor';
        eventAttendeeRequestor2.source_system_id = 'PW';
        eventAttendeeRequestor2.source_system_attendee_id = '4444';
            
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor3 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor3.role = 'Requestor';
        eventAttendeeRequestor3.UNIX_ID = 'beanj';
        
        eventAttendees.add(eventAttendeeAccountable);
        eventAttendees.add(eventAttendeeRequestor);
        eventAttendees.add(eventAttendeeVendor);
        eventAttendees.add(eventAttendeeVendor2);
        eventAttendees.add(eventAttendeeRequestor2);
        eventAttendees.add(eventAttendeeRequestor3);
        
        ne.attendees_list = eventAttendees;
        
        Test.StartTest();
        evt_obj = em3_utils_2.addVendors(ne,evt_obj);
        Test.StopTest();
        
        System.assertEquals(evt_obj.vendors,'Vendor Company Name, Vendor2 Company Name');
        
    
    }
    
    static testMethod void prepareExistingContactExternalIdsAndAccounts(){
    
        Em3_utils_2 em3_utils_2 = new Em3_utils_2();
        
        //prepare Accounts
        Account account1 = new Account(Name = 'Company Account 1');
        insert account1;
        Account account2 = new Account(Name = 'Company Account 2');
        insert account2;
        
        Address_vod__c ad = new Address_vod__c(
            Account_vod__c = account1.ID
        );
        insert ad;
        Address_vod__c ad2 = new Address_vod__c(
            Account_vod__c = account2.ID
        );
        insert ad2;

        Contact contact1 = new Contact(
                              accountId = account1.id,
                              firstName = 'John',
                              lastName = 'Bean',
                              Address_gne__c = ad.Id);
        insert contact1;
        
        Contact contact2 = new Contact(
                              accountId = account2.id,
                              firstName = 'John',
                              lastName = 'Smith',
                              Address_gne__c = ad2.Id);
        insert contact2;
        
        //prepare ContactExteranlIds
        Contact_External_Id_gne__c contactExternalId1 = new Contact_External_Id_gne__c();
        contactExternalId1.Contact_gne__c = contact1.id;
        contactExternalId1.Third_Party_gne__c = 'TSG';
        contactExternalId1.Third_Party_Id_gne__c = '1234';
        contactExternalId1.Third_Party_Index_gne__c = 'TSG1234';
        insert contactExternalId1;
        
        //prepare ContactExteranlIds
        Contact_External_Id_gne__c contactExternalId2 = new Contact_External_Id_gne__c();
        contactExternalId2.Contact_gne__c = contact2.id;
        contactExternalId2.Third_Party_gne__c = 'PW';
        contactExternalId2.Third_Party_Id_gne__c = '5678';
        contactExternalId2.Third_Party_Index_gne__c = 'PW5678';
        insert contactExternalId2;
        
        New_Event_Creation_WS.New_Event ne = new New_Event_Creation_WS.New_Event(); 
        New_Event_Creation_WS.Events_obj evt_obj = new New_Event_Creation_WS.Events_obj();
        
        //Event lvl attendees
        List<New_Event_Creation_WS.New_Attendee> eventAttendees = new List<New_Event_Creation_WS.New_Attendee>();
        
        New_Event_Creation_WS.New_attendee eventAttendeeAccountable = new New_Event_Creation_WS.New_attendee();
        eventAttendeeAccountable.company_name = 'Company Account 1';
        eventAttendeeAccountable.role = 'Accountable';
        eventAttendeeAccountable.source_system_id = 'TSG';
        eventAttendeeAccountable.source_system_attendee_id = '1234';
            
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor.company_name = 'Company Account 1';
        eventAttendeeRequestor.role = 'Requestor';
        eventAttendeeRequestor.source_system_id = 'TSG';
        eventAttendeeRequestor.source_system_attendee_id = '1234';
            
        New_Event_Creation_WS.New_attendee eventAttendeeVendor = new New_Event_Creation_WS.New_attendee();
        eventAttendeeVendor.role = 'Vendor';
        eventAttendeeVendor.company_name = 'Vendor Company Name';
        eventAttendeeVendor.source_system_id = 'PW';
        
        New_Event_Creation_WS.New_attendee eventAttendeeVendor2 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeVendor2.role = 'Vendor';
        eventAttendeeVendor2.company_name = 'Vendor2 Company Name';
        eventAttendeeVendor2.source_system_id = 'PW';
        
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor2 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor2.company_name = 'Company Account 2';
        eventAttendeeRequestor2.role = 'Requestor';
        eventAttendeeRequestor2.source_system_id = 'PW';
        eventAttendeeRequestor2.source_system_attendee_id = '5678';
            
        New_Event_Creation_WS.New_attendee eventAttendeeRequestor3 = new New_Event_Creation_WS.New_attendee();
        eventAttendeeRequestor3.role = 'Requestor';
        eventAttendeeRequestor3.UNIX_ID = 'beanj';
        
        eventAttendees.add(eventAttendeeAccountable);
        eventAttendees.add(eventAttendeeRequestor);
        eventAttendees.add(eventAttendeeVendor);
        eventAttendees.add(eventAttendeeVendor2);
        eventAttendees.add(eventAttendeeRequestor2);
        eventAttendees.add(eventAttendeeRequestor3);
        ne.attendees_list = eventAttendees;
        
        List<New_Event_Creation_WS.new_site> sites = new List<New_Event_Creation_WS.new_site>();
        New_Event_Creation_WS.new_site site = new New_Event_Creation_WS.new_site();
        
        //Site lvl attendees
        List<New_Event_Creation_WS.New_Attendee> attendees = new List<New_Event_Creation_WS.New_Attendee>();
        
        New_Event_Creation_WS.New_attendee attendeeAttendee = new New_Event_Creation_WS.New_attendee();
        attendeeAttendee.company_name = 'Company Account 1';
        attendeeAttendee.role = 'Attendee';
        attendeeAttendee.source_system_id = 'TSG';
        attendeeAttendee.source_system_attendee_id = '1234';
        
        New_Event_Creation_WS.New_attendee attendeeSpeaker = new New_Event_Creation_WS.New_attendee();
        attendeeSpeaker.company_name = 'Company Account 2';
        attendeeSpeaker.role = 'Speaker';
        attendeeSpeaker.source_system_id = 'PW';
        attendeeSpeaker.source_system_attendee_id = '5678';
        
        New_Event_Creation_WS.New_attendee attendeeAttendee2 = new New_Event_Creation_WS.New_attendee();
        attendeeAttendee2.company_name = 'Genetech';
        attendeeAttendee2.role = 'Attendee';
        attendeeAttendee2.UNIX_ID = 'beanj';
        
        attendees.add(attendeeAttendee);
        attendees.add(attendeeSpeaker);
        attendees.add(attendeeAttendee2);
        site.attendees_list = attendees;
        sites.add(site);
        ne.sites_list = sites;        
        
        Test.StartTest();
        evt_obj = em3_utils_2.prepareExistingContactExternalIdsAndAccounts(ne,evt_obj);
        Test.StopTest();
        
        System.assertEquals(evt_obj.addedContactExternalIds.size(),2);
        System.assertEquals(evt_obj.addedAccounts.size(),2);
            
    
    }
    
    static testMethod void addEventAttendees(){
        
        System.debug('sessionid=['+UserInfo.getSessionId() +']');
        /*
        List<User> usersAll = [select u.External_ID_gne__c from User u LIMIT 2000];
        Set<String> usersAllIds = new Set<String>();
        for(User item : usersAll){
            usersAllIds.add(item.External_ID_gne__c);
        }
        List<All_User_Hierarchy_gne__c> nonUsers = [Select a.User_External_Id_gne__c from All_User_Hierarchy_gne__c a where a.User_External_Id_gne__c NOT IN:usersAllIds LIMIT 10];
        //System.debug('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=['+ nonUsers +']');
        */
        
            /*
    webservice static Messages create_new_event(New_Event ne){
        
        
        String INFREQUENT_USER_PROF = 'GNE-INFREQUENT-USER';
        
        
        
        //User myUser = getCaseManagerUser();
        //insert myUser;
        String unixId = 'wajxxxs5';
        
        User newUser = new User();
        setDefKeys(newUser);           
        newUser.firstName = 'John';
        newUser.lastName = 'Test1';
        newUser.alias = unixId;
        newUser.username = unixId +'@'+'gene.com';
        newUser.email = unixId +'@'+'gene.com'; 
        newUser.CommunityNickname = unixId;
        
        
         
        //List<UserRole> stdRoles = [Select Id, name from UserRole where name = :STNDRD_USER];
         
        //if(stdRoles.size() < 1){
        //	System.debug('ERROR_NO_ROLE');
        //}
             
        //newUser.UserRoleId = stdRoles[0].Id;
             
        List<Profile> infreqProfs = [Select Id, name from Profile where name = :INFREQUENT_USER_PROF];
             
        if (infreqProfs.size() < 1){
            System.debug('error no profile');
        }             
        newUser.ProfileId = infreqProfs[0].Id;
        insert newUser;
        
        Test_Object_wajrycs1__c test = new Test_Object_wajrycs1__c();
        insert test;        
        
        Set<String> unixIds = new Set<String>();
        unixIds.add(unixId);
        New_Event_Creation_WS.setRolesToNewUsers(unixIds);
        
        Messages msg = new Messages();
        return msg;
     }
     */
    }
    
}