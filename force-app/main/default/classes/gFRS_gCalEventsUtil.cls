/**
* @author ADMD Team
* @date 01/04/2013
* @description gFRS_gCalEventsUtil class - util helper class for adding events to gFRS Events Calendar.
*/

public without sharing class gFRS_gCalEventsUtil {
    
    public static final String FILTER_GCAL = 'Google Calendar';
    public static final String KEY_GCAL_FILTER = 'gcal Footer';
    public static final String EXHIBIT_AVAILABLE = 'Exhibit opportunities are available for a separate fee';
    public static final String EXHIBIT_NOT_AVAILABLE = 'Exhibit opportunities are not available for a separate fee';
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description createMedicalEventForProgram method - method is executed when gfrs program record will be updated.
    * Method checks if event should be CREATED,UPDATED or DELETED in gCalendar 
    */
    
    public static void createMedicalEventForProgram(GFRS_Program__c[] programs, Map<id,GFRS_Program__c> oldMap){
        GFRS_Program__c[] filteredProgramslist = new List<GFRS_Program__c>();
        filterChangedFieldsUnderRecord(programs, oldMap, new String []{'Type__c','Program_Status__c','Benefits_Exchanged_for_Funding__c','Exhibits_or_Displays_Allowed__c','Start_Date__c','End_Date__c','Venue_Name__c','Venue_City__c','Venue_State__c','Venue_Country__c','Venue_Province_Region__c','Venue_Zip_Code__c'}, filteredProgramslist);
        if (filteredProgramslist!= NULL && filteredProgramslist.size()>0 ){
            final GFRS_Content_Translation__c[] headerText = [SELECT TextBlock__c FROM GFRS_Content_Translation__c WHERE GFRS_Content__r.Name = 'Gcal_Header' LIMIT 1];
            List<gFRS_Calendar_Event__c> eventsToUpsert = new List<gFRS_Calendar_Event__c>();
            List<gFRS_Calendar_Event__c> eventsToDelete = new List<gFRS_Calendar_Event__c>();
            //map which aling program ID with gCalEvent id
            Map<Id,gFRS_Calendar_Event__c> programPerEventMap = new Map<Id,gFRS_Calendar_Event__c>();
            
            for(gFRS_Calendar_Event__c gEvent : [SELECT id,ProgramId__c,
                                                    Title__c,Funding_Type__c,
                                                    Request_Name__c,Program_Name__c,
                                                    Venue_City__c,Venue_State__c,
                                                    Venue_Zip_Code__c,Venue_Name__c,
                                                    Therapeutic_Area__c,Disease_State__c,
                                                    Venue_Country__c,Venue_Province_Region__c,
                                                    GcalDescription__c,Start_Date__c,
                                                    End_Date__c,Organization_Name__c
                                                    FROM gFRS_Calendar_Event__c where ProgramId__c in : filteredProgramslist]){
                programPerEventMap.put(gEvent.ProgramId__c,gEvent);
            }
            

            map<Id, GFRS_Funding_Request__c> requestsMap = getRequestMapForPrograms(filteredProgramslist);
            Integer index=0;

            User u = [SELECT FirstName, LastName, Email, Phone from User where Id=:requestsMap.values()[0].OwnerId];
            
            Map<String,String> contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( FILTER_GCAL, UserInfo.getLanguage() );
            String footer_text = ( contentItems != null && contentItems.containsKey( 'Description' ))? contentItems.get( 'Description' ) : null;
             System.debug('footer_text'+footer_text);
            for(GFRS_Program__c program: filteredProgramslist){
                String operationType='';
                GFRS_Funding_Request__c request =requestsMap.get(program.Funding_Request__c);
                if(programPerEventMap.containsKey(program.id)){
                    //event already exist in gCalEvent table need to update or delete
                    operationType=checkIfProgramShouldBeDeletedOrUpdated(program,request.Record_Type_Name__c);
                    if (operationType.equals('DELETE')){
                        eventsToDelete.add(programPerEventMap.get(program.Id));
                    } else if (operationType.equals('UPDATE') && !headerText.isEmpty()) {
                        eventsToUpsert.add(setGCalEventData(program, requestsMap.get(program.Funding_Request__c), footer_text, programPerEventMap.get(program.id), headerText[0].TextBlock__c, u));
                    }
                } else
                if (!programPerEventMap.containsKey(program.Id) && !headerText.isEmpty() &&
                    checkIfProgramShouldBeAddedToGcal(program, request, request.Record_Type_Name__c)
                ) {
                    eventsToUpsert.add(setGCalEventData(program, requestsMap.get(program.Funding_Request__c), footer_text, null, headerText[0].TextBlock__c, u));
                }
            }
            
            if(!eventsToUpsert.isEmpty()){
                upsert eventsToUpsert;
            }
            
            if(!eventsToDelete.isEmpty()){
                delete eventsToDelete;
            }
        }
    }
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description addProgramsToGcalUnderFundingRequest method - method is executed when gfrs funding request record will be updated.
    * Method checks if event should be CREATED,UPDATED or DELETED in gCalendar 
    */
    public static void addProgramsToGcalUnderFundingRequest(Map<id,GFRS_Funding_Request__c> newMap, Map<id,GFRS_Funding_Request__c> oldMap){
        List<GFRS_Funding_Request__c> filteredFundings =new List<GFRS_Funding_Request__c>();
        filterChangedFieldsUnderRecord(newMap.values(), oldMap, new String []{'Event_Project_sub_type__c','LOA_Signed__c','Sub_Status__c','OwnerId','External_Tracking_Code_optional__c','Therapeutic_Area_Parent__c','Therapeutic_Area__c','Event_Project_type__c','Foundation_Classified__c'}, filteredFundings);
        if(filteredFundings.size()>0){
            final GFRS_Content_Translation__c[] headerText = [select TextBlock__c from GFRS_Content_Translation__c where GFRS_Content__r.Name = 'Gcal_Header' LIMIT 1];
            User u = [SELECT FirstName, LastName, Email, Phone from User where Id=:filteredFundings[0].OwnerId];

            List<GFRS_Program__c> programsEvents=[select Id, Name, Funding_Request__c, Program_AutoNumber__c, Start_Date__c, End_Date__c, Program_Status__c, Program_Subtype__c, Is_Registered_With_GCAL__c, Venue_City__c, Venue_State__c, Venue_Zip_Code__c, Geographic_Region__c,
                                                    StateProvinceConversion__c, Support_Purpose_Program_Description__c, Venue_Name__c, Expected_Number_of_Attendees__c,Benefits_Exchanged_for_Funding__c,Type__c,Exhibits_or_Displays_Allowed__c,Venue_Province_Region__c,Venue_Country__c,RecordType.DeveloperName from GFRS_Program__c where Funding_Request__c in : filteredFundings];
            
            Map<ID,List<GFRS_Program__c>> programsEventsForFundingReq =new Map<ID,List<GFRS_Program__c>>();
            if(programsEvents.isEmpty()){
                return;
            }
            
            List<gFRS_Calendar_Event__c> eventsToUpsert = new List<gFRS_Calendar_Event__c>();
            List<gFRS_Calendar_Event__c> eventsToDelete = new List<gFRS_Calendar_Event__c>();
            
            Map<Id,gFRS_Calendar_Event__c> programPerEventMap = new Map<Id,gFRS_Calendar_Event__c>();
            
            for(gFRS_Calendar_Event__c gEvent : [SELECT id,ProgramId__c,
                                                    Title__c,Funding_Type__c,
                                                    Request_Name__c,Program_Name__c,
                                                    Venue_City__c,Venue_State__c,
                                                    Venue_Zip_Code__c,Venue_Name__c,
                                                    Therapeutic_Area__c,Disease_State__c,
                                                    Venue_Country__c,Venue_Province_Region__c,
                                                    GcalDescription__c,Start_Date__c,
                                                    End_Date__c,Organization_Name__c
                                                    FROM gFRS_Calendar_Event__c where ProgramId__c in : programsEvents]){
                programPerEventMap.put(gEvent.ProgramId__c,gEvent);
            }                                            
    
            if(programsEvents.size()>0){
                Map<String,String> contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( FILTER_GCAL, UserInfo.getLanguage() );
                String footer_text = ( contentItems != null && contentItems.containsKey( 'Description' ))? contentItems.get( 'Description' ) : null;
                //populate map of alinged programs to Funding Request
                for(GFRS_Program__c progItem:programsEvents){
                    if(programsEventsForFundingReq.containsKey(progItem.Funding_Request__c)){
                        programsEventsForFundingReq.get(progItem.Funding_Request__c).add(progItem);
                    }else{
                        programsEventsForFundingReq.put(progItem.Funding_Request__c, new GFRS_Program__c [] {progItem} );
                    }
                }
                
                for(Id fundingId: programsEventsForFundingReq.keySet()){
                    String recordTypeName=newMap.get(fundingId).Record_Type_Name__c;
                    if(newMap.containsKey(fundingId) && oldMap.containsKey(fundingId)){
                        //checks if events should be deleted
                        for(GFRS_Program__c prog : programsEventsForFundingReq.get(fundingId)){
                            //event for this program already exist
                            if(programPerEventMap.containsKey(prog.id)){
                                
                                if( !checkIfEventSubTypeMeetCriteria(newMap.get(fundingId).Event_Project_sub_type__c) || newMap.get(fundingId).Foundation_Classified__c == 'TRUE' || newMap.get(fundingId).Sub_Status__c == 'Canceled' || newMap.get(fundingId).Sub_Status__c == 'Denied' || (newMap.get(fundingId).External_Tracking_Code_optional__c != null && (newMap.get(fundingId).External_Tracking_Code_optional__c.toLowerCase().equals('plng') || newMap.get(fundingId).External_Tracking_Code_optional__c.toLowerCase().equals('adv') || newMap.get(fundingId).External_Tracking_Code_optional__c.toLowerCase().equals('fga')) && recordTypeName =='HC Char')){
                                    //here be method which will delete programs form gCal
                                    
                                        //id event exist in db deleted events for this funding request
                                        if(programPerEventMap.containsKey(prog.id)){
                                            eventsToDelete.add(programPerEventMap.get(prog.id));    
                                        } 
                                    
                                    //sendItems=createMedicalEventForProgramExtend(programsForFundingReqInGCal.get(fundingIds), requestsToCalendarMap.get(fundingIds), 'DELETE',sendItems,false,'');    
                                }else if(recordTypeName =='IMED' && newMap.get(fundingId).Roche_Observer__c != 'Yes'){
                                      if(programPerEventMap.containsKey(prog.id)){
                                            eventsToDelete.add(programPerEventMap.get(prog.id));    
                                        }
                                }else{
                                    String taNew=newMap.get(fundingId).Therapeutic_Area_Parent__c;
                                    String taOld=oldMap.get(fundingId).Therapeutic_Area_Parent__c;
                                    String DiseaseNew=newMap.get(fundingId).Therapeutic_Area__c;
                                    String DiseaseOld=oldMap.get(fundingId).Therapeutic_Area__c;
                                    String ownerNew=newMap.get(fundingId).OwnerId;
                                    String ownerOld=oldMap.get(fundingId).OwnerId;
                                    if(taNew != taOld || DiseaseNew != DiseaseOld){
                                        System.debug('TA WAS CHANGE DELETE CREATE ACTION SHOULD BE PERFORMD');
                                        //sendItems=createMedicalEventForProgramExtend(programsForFundingReqInGCal.get(fundingIds), requestsToCalendarMap.get(fundingIds), 'UPDATE',sendItems,true,oldMap.get(fundingIds).Therapeutic_Area__c);
                                        //Updating existing program Events in gCal
                                        //here be method which will delete programs form gCal
                                        //id event exist in db deleted events for this funding request
                                        if(programPerEventMap.containsKey(prog.id) && !headerText.isEmpty()){
    
                                            eventsToUpsert.add(setGCalEventData(prog, newMap.get(fundingId), footer_text, programPerEventMap.get(prog.id), headerText[0].TextBlock__c, u));
                                        } 
                                        
                                    }
                                    if(ownerNew != ownerOld){
                                        //sendItems=createMedicalEventForProgramExtend(programsForFundingReqInGCal.get(fundingIds), requestsToCalendarMap.get(fundingIds), 'UPDATE',sendItems,false,'');
                                        //Updating existing program Events in gCal
                                        if(programPerEventMap.containsKey(prog.id) && !headerText.isEmpty()){
                                            eventsToUpsert.add(setGCalEventData(prog, newMap.get(fundingId), footer_text, programPerEventMap.get(prog.id), headerText[0].TextBlock__c, u));
                                        }
                                    } 
                                }
                            }else{
                                //event for this program is not created yet
                                system.debug('check number od execution '+prog);
                                if(checkIfEventSubTypeMeetCriteria(newMap.get(fundingId).Event_Project_sub_type__c) && checkIfEventProjectTypeMeetCriteria(newMap.get(fundingId).Event_Project_type__c) && newMap.get(fundingId).Foundation_Classified__c == 'FALSE' && newMap.get(fundingId).LOA_Signed__c == 'Yes' && (newMap.get(fundingId).Sub_Status__c != 'Canceled' || newMap.get(fundingId).Sub_Status__c != 'Denied')){
                                    if(recordTypeName == 'HC Char'){
                                        //criteria under funding request For HC Char are met
                                        if(newMap.get(fundingId).External_Tracking_Code_optional__c == null || (newMap.get(fundingId).External_Tracking_Code_optional__c != null && (!newMap.get(fundingId).External_Tracking_Code_optional__c.toLowerCase().equals('plng') && !newMap.get(fundingId).External_Tracking_Code_optional__c.toLowerCase().equals('adv') && !newMap.get(fundingId).External_Tracking_Code_optional__c.toLowerCase().equals('fga')))){
                                            
                                            List<GFRS_Program__c> addProgramsToGcal=new List<GFRS_Program__c>();
                                            
                                           
                                            if (checkVenueCountryOnProgram(prog.Venue_Country__c) && prog.Type__c == 'Live Activity' && prog.Program_Status__c == 'Confirmed' && (prog.Benefits_Exchanged_for_Funding__c !=null && (prog.Benefits_Exchanged_for_Funding__c.contains('Entry into the event') || prog.Benefits_Exchanged_for_Funding__c.contains('Corporate recognition')) || prog.Exhibits_or_Displays_Allowed__c == 'Yes') &&
                                                !headerText.isEmpty()
                                            ){
                                                eventsToUpsert.add(setGCalEventData(prog, newMap.get(fundingId), footer_text, null, headerText[0].TextBlock__c, u)); 
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                                
                    } 
                }
            }
            if(!eventsToDelete.isEmpty()){
              
                delete eventsToDelete;
            }
            
            if(!eventsToUpsert.isEmpty()){
                upsert eventsToUpsert;
            }
        }   
        
    }
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description checkIfProgramShouldBeAddedToGcal method - check if event should be CRETED in gCalendar.
    *   
    */
    
    public static Boolean checkIfProgramShouldBeAddedToGcal(GFRS_Program__c progItem,GFRS_Funding_Request__c tmp,String recordType){
        if(recordType == 'HC Char'){
            if(tmp.Foundation_Classified__c == 'FALSE' && (tmp.Sub_Status__c != 'Canceled' || tmp.Sub_Status__c != 'Denied') && tmp.LOA_Signed__c !=null &&  tmp.LOA_Signed__c == 'Yes' && 
               (tmp.External_Tracking_Code_optional__c == null || tmp.External_Tracking_Code_optional__c != null && (!tmp.External_Tracking_Code_optional__c.toLowerCase().equals('plng') && !tmp.External_Tracking_Code_optional__c.toLowerCase().equals('adv') && !tmp.External_Tracking_Code_optional__c.toLowerCase().equals('fga')))
                && checkIfEventSubTypeMeetCriteria(tmp.Event_Project_sub_type__c) && checkIfEventProjectTypeMeetCriteria(tmp.Event_Project_type__c)){
                    if(checkVenueCountryOnProgram(progItem.Venue_Country__c) && progItem.Type__c == 'Live Activity' && progItem.Program_Status__c !=null && progItem.Program_Status__c.equals('Confirmed') &&  (progItem.Benefits_Exchanged_for_Funding__c !=null && (progItem.Benefits_Exchanged_for_Funding__c.contains('Entry into the event') || progItem.Benefits_Exchanged_for_Funding__c.contains('Corporate recognition')) || progItem.Exhibits_or_Displays_Allowed__c !=null && progItem.Exhibits_or_Displays_Allowed__c == 'Yes')){
                        return true;
                    }
            }
        }
        return false; 
    }
    
    /**
    * @author ADMD Team
    * @date 10/26/2015
    * @description checkIfEventSubTypeMeetCriteria method - check if event/program subtype on request level meet criteria.
    *   
    */
    
    public static Boolean checkIfEventSubTypeMeetCriteria(String subType){
        if (subType != null && (subType.toLowerCase().equals('gala') || subType.toLowerCase().equals('golf tournament') || subType.toLowerCase().equals('sports activity (e.g., walk, climb, bike)') || subType.toLowerCase().equals('other') || subType.toLowerCase().equals('disease education and awareness') ) ) {
            return true;
        }       
        return false;
    }
    
    /**
    * @author ADMD Team
    * @date 10/26/2015
    * @description checkVenueCountryOnProgram method - check country and return true if event should be created.
    *   
    */
    
    public static Boolean checkVenueCountryOnProgram(String venueCountry){
        if(venueCountry != null && (venueCountry.toLowerCase().equals('united states') || venueCountry.toLowerCase().equals('puerto rico') || venueCountry.toLowerCase().equals('guam') || venueCountry.toLowerCase().equals('northern mariana islands') || venueCountry.toLowerCase().equals('virgin islands') || venueCountry.toLowerCase().equals('american samoa') ) ){
            return true;
        }
        return false;       
    }
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description checkIfEventProjectTypeMeetCriteria method - check if event program type is applicable.
    *   
    */
    public static Boolean checkIfEventProjectTypeMeetCriteria(String eventProjectType){
        if(eventProjectType != null && (eventProjectType.toLowerCase().contains('Patient and General Disease Education') || eventProjectType.toLowerCase().contains('fundraiser') )){
            return true;
        }
        return false;
    }           
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description checkIfProgramShouldBeDeletedOrUpdated method - check if event should be deleted or Updated in gCalendar.
    *   
    */
    
    public static String checkIfProgramShouldBeDeletedOrUpdated(GFRS_Program__c progItem,String recordType){
        if(recordType == 'HC Char'){
            if(progItem.Program_Status__c == 'Canceled'  || progItem.Type__c != 'Live Activity'){
                return 'DELETE';
                //createMedicalEventForProgramExtend(addProgramsToGcal, requestsToCalendarMap.get(fundingIds), 'DELETE', 'HC Char');
            }else{
                return 'UPDATE';
            }
        }
        return ''; 
    }
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description filterChangedFieldsUnderRecord method - helper method which tracking if there was any change under fields passed in fieldNames parameter.
    *   
    */
    
    public static void filterChangedFieldsUnderRecord( List<SObject> newList, Map<Id,SObject> oldMap, List<String> fieldNames, List<SObject> resultList ){
        if( resultList == null ) return;
        resultList.clear();
        
        //-- if oldMap is null, then all items must be new
        if( oldMap == null ){
            resultList.addAll( newList );
            return;
        }
        
        SObject old;
        for( SObject obj : newList ){
            if( obj.id != null ){
                if( oldMap.containsKey( obj.id )){
                    old = oldMap.get( obj.id );
                    //System.debug( 'old[' + fieldName + ']:' + old.get(fieldName) + ', ob[]:' + obj.get(fieldName) );
                    for(String fieldName: fieldNames){
                        if( old.get( fieldName ) != obj.get(fieldName ) ){
                            resultList.add( obj );
                            break;
                        }
                    }   
                } else {
                    resultList.add( obj );
                }
            } else {
                resultList.add( obj );
            }
        }
    }
    
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description getRequestMapForPrograms method - helper method which returns map of Funding Request for passed Programs.
    *   
    */
    
    public static Map<Id, GFRS_Funding_Request__c> getRequestMapForPrograms(GFRS_Program__c[] programs){
        Id[] reqIds = new List<Id>();
        for(GFRS_Program__c program : programs){
            reqIds.add(program.Funding_Request__c);
        }
        system.debug(reqIds);
        GFRS_Funding_Request__c[] requests = [SELECT Id, Name, Record_Type_Name__c, Request_AutoNumber__c, Status__c, Organization__c,  Therapeutic_Area__c,Therapeutic_Area_Parent__c,Please_Specify__c, Event_Program_Title__c, Support_Purpose_Program_Description__c,
        Exhibits_or_Displays_Allowed__c, Location__r.Name, Location__r.Vendor_Name__c, Location__r.Address__c, Location__r.Province_Region_Territory__c, Location__r.Address_Line_1__c,  Location__r.Address_Line_2__c,  Location__r.City__c, Location__r.State__c, Location__r.Country_1__c, Location__r.Department_Chapter_Country__c,
        Organization__r.Name, Organization__r.Organization_Name__c, Organization_Name__c, Location__r.Zip__c, Owner.Title, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone,External_Tracking_Code_optional__c,Roche_Observer__c,Sub_Status__c,LOA_Signed__c,Event_Project_type__c,Event_Project_sub_type_other__c,Event_Project_sub_type__c,Foundation_Classified__c
         from GFRS_Funding_Request__c WHERE Id IN :reqIds];
         system.debug(requests);
        map<Id, GFRS_Funding_Request__c> requestsMap = new map<Id, GFRS_Funding_Request__c>();
        for(GFRS_Funding_Request__c r : requests) {
            requestsMap.put(r.id, r);
        }
         system.debug(requestsMap);

        return requestsMap;
    }
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description setGCalEventData method - helper method which setting all fields under event object
    *   
    */
    
    public static gFRS_Calendar_Event__c setGCalEventData(GFRS_Program__c program,GFRS_Funding_Request__c request,String footer_text,gFRS_Calendar_Event__c eventToModify, String headerText, User u){
        Boolean isNewEvent = false;
        if(eventToModify == null){
            isNewEvent=true;
            eventToModify=new gFRS_Calendar_Event__c();    
        }
        system.debug('check values inside method');
        system.debug(program);
        system.debug(request);
        eventToModify.Title__c=request.Event_Program_Title__c;
        eventToModify.Funding_Type__c=request.Record_Type_Name__c == 'IMED'? 'IME':'CEG';
        eventToModify.Request_Name__c=request.Name;
        eventToModify.Program_Name__c=program.Name;
        if(isNewEvent){
            eventToModify.ProgramId__c=program.Id;
        }

        eventToModify.Header_text__c           = headerText;
        eventToModify.Venue_City__c            = program.Venue_City__c;
        eventToModify.Venue_State__c           = program.Venue_State__c;
        eventToModify.Therapeutic_Area__c      = request.Therapeutic_Area_Parent__c;
        eventToModify.Venue_Zip_Code__c        = program.Venue_Zip_Code__c;
        eventToModify.Venue_Name__c            = program.Venue_Name__c;
        eventToModify.Disease_State__c         = request.Therapeutic_Area__c == null? '.' : request.Therapeutic_Area__c;
        eventToModify.Venue_Country__c         = program.Venue_Country__c;
        eventToModify.Venue_Province_Region__c = program.Venue_Province_Region__c;
        eventToModify.GcalDescription__c       = prepareGcalDescriptonMessage(footer_text, program, request, request.Record_Type_Name__c, u);
        eventToModify.Start_Date__c            = program.Start_Date__c;
        eventToModify.End_Date__c              = program.End_Date__c;
        eventToModify.Organization_Name__c     = request.Organization_Name__c;
        System.debug('eventToModify.Organization_Name__c->'+eventToModify.Organization_Name__c);
        System.debug('request.Organization_Name__c->'+request.Organization_Name__c);
        return eventToModify;
        
        
    }
    
     /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description checkIfContainsAllRequiredFields method - helper method which checks if all required fields are filled. 
    *   
    */
    public static Boolean checkIfContainsAllRequiredFields(GFRS_Program__c program){
        if(program.Venue_State__c == null && program.Venue_Province_Region__c == null) return false;            
        if(program.Venue_Country__c == null) return false;
        //if above condition wasn't meet all required fieds are filled
        return true;
    } 
    
    
    /**
    * @author ADMD Team
    * @date 05/02/2015
    * @description getRequestMapForPrograms method - helper method which returns Content of Description Section which will pleaced in gCalendar.
    *   
    */
    public static String prepareGcalDescriptonMessage(String inputDescription,GFRS_Program__c program,GFRS_Funding_Request__c request,String fundType, User u){
        String output='';
        //Dump parameters to log
        
        System.Debug('inputDescription->' + inputDescription);
        System.Debug('program.Id->' + program.Id);
        System.Debug('request.Id->' + request.Id);
        System.Debug('fundType->' + fundType);
        
        System.Debug('### Start building event details');
        System.Debug('### Adding Request details');
        output = AddRequestDetails(inputDescription, request, output, u);
        System.debug('### request output->'+  output); 
        
        System.debug('### Adding Program details');
        output = AddProgramDetails(inputDescription, program, output);
        System.debug('### Venue output->'+  output);
        
        String exhibitsAllowed='';
        if(fundType =='IMED'){
            System.Debug('IMED request.Exhibits_or_Displays_Allowed__c->' +  request.Exhibits_or_Displays_Allowed__c);
            exhibitsAllowed=request.Exhibits_or_Displays_Allowed__c==null ? '' : request.Exhibits_or_Displays_Allowed__c;
            
        }else if(fundType =='HC Char'){
            System.Debug('HC Char program.Exhibits_or_Displays_Allowed__c->' +  program.Exhibits_or_Displays_Allowed__c);
            exhibitsAllowed=program.Exhibits_or_Displays_Allowed__c ==null ? '' : program.Exhibits_or_Displays_Allowed__c;
            System.Debug('exhibitsAllowed->' +  exhibitsAllowed);
        }
         
        output=output.replace('[[SepPrice]]',exhibitsAllowed);
        system.debug(output);
        return output;
        
    }
    
    private static string AddRequestDetails(String inputDescription, GFRS_Funding_Request__c request, String output, User u)
    {   
        System.debug('### Output at the begging of AddRequestDetails->'+output);
        System.Debug('request.Event_Project_type__c->' + request.Event_Project_type__c);
        output=request.Event_Project_type__c ==null? inputDescription.replace('[[Event_Program_Type]]',''):inputDescription.replace('[[Event_Program_Type]]',request.Event_Project_type__c);
        System.debug('### Output after Event_Program_Type replace->'+output);
        
        System.Debug('request.Event_Project_sub_type__c->' + request.Event_Project_sub_type__c);
        output=request.Event_Project_sub_type__c ==null? output.replace('[[Event_Program_SubType]]',''):output.replace('[[Event_Program_SubType]]',request.Event_Project_sub_type__c);
        System.debug('### Output after Event_Program_SubType replace->'+output);
        
        System.Debug('request.Event_Project_sub_type_other__c->' + request.Event_Project_sub_type_other__c);
        output=request.Event_Project_sub_type_other__c ==null? output.replace('[[Event_Program SubType Other]]',''):output.replace('[[Event_Program SubType Other]]',request.Event_Project_sub_type_other__c);
        System.debug('### Output after Event_Program SubType Other replace->'+output);
        
        System.Debug('request.Name->' + request.Name);
        output=request.Name ==null? output.replace('[[Request ID]]',''):output.replace('[[Request ID]]',request.Name);
        System.debug('### Output after Request ID replace->'+output);
        
        System.Debug('request.Therapeutic_Area_Parent__c->' + request.Therapeutic_Area_Parent__c);
        output=request.Therapeutic_Area_Parent__c ==null? output.replace('[[TA]]','') : output.replace('[[TA]]',request.Therapeutic_Area_Parent__c);
        System.debug('### Output after TA replace->'+output);
        
        System.Debug('request.Therapeutic_Area__c->' + request.Therapeutic_Area__c);
        output=request.Therapeutic_Area__c ==null? output.replace('[[Disease]]','') : output.replace('[[Disease]]',request.Therapeutic_Area__c == 'Other' ? request.Therapeutic_Area__c + ' ('+ request.Please_Specify__c+ ')': request.Therapeutic_Area__c);
        System.debug('### Output after Disease replace->'+output);
        
        System.Debug('request.Event_Program_Title__c->' + request.Event_Program_Title__c);
        output=request.Event_Program_Title__c ==null? output.replace('[[ProgTitle]]','') : output.replace('[[ProgTitle]]',request.Event_Program_Title__c);
        System.debug('### Output after ProgTitle replace->'+output);
        
        //Organization replace is not needed as it's not in the description.
        /* 
        System.debug('### Adding Organization');
        output=request.Organization__r.Organization_Name__c ==null? output.replace('[[OrgName]]',''):output.replace('[[OrgName]]',request.Organization__r.Organization_Name__c);
        System.Debug('request.Organization__r.Organization_Name__c->' + request.Organization__r.Organization_Name__c);
        System.debug('### Output after OrgName replace->'+output);
        */
        
        
        
        System.debug('### Adding Owner');
        System.Debug('requestOwnerId->' + request.ownerId);
        
        String ownerName='';
        ownerName+=u.FirstName==null? '' : u.FirstName+' ';
        ownerName+=u.LastName==null? '' : u.LastName;
        
        System.Debug('ownerName->' + ownerName);
        output=ownerName == ''?output.replace('[[OwnerName]]',ownerName) : output.replace('[[OwnerName]]',ownerName);
        System.Debug('output->' + output);
        
        System.Debug('u.Email->' + u.Email);
        output=u.Email ==null? output.replace('[[OwnerEmail]]','') : output.replace('[[OwnerEmail]]',u.Email);
        System.Debug('output->' + output);
        
        System.Debug('u.Phone->' + u.Phone);
        output=u.Phone ==null? output.replace('[[OwnerPhone]]','') : output.replace('[[OwnerPhone]]',u.Phone);
        System.Debug('output->' + output);
        
        return output;
    } 
    
    private static string AddProgramDetails(String inputDescription, GFRS_Program__c program, string output)
    {   
        System.Debug('program.Program_Subtype__c->' + program.Program_Subtype__c);
        output=program.Program_Subtype__c ==null? output.replace('[[Program_SubType]]',''):output.replace('[[Program_SubType]]',program.Program_Subtype__c);
        
        System.Debug('program.Start_Date__c->' + program.Start_Date__c);
        output=program.Start_Date__c ==null? output.replace('[[StartDate]]','') : output.replace('[[StartDate]]',program.Start_Date__c.format());
        
        System.Debug('program.End_Date__c->' + program.End_Date__c);
        output=program.End_Date__c ==null? output.replace('[[EndDate]]','') : output.replace('[[EndDate]]',program.End_Date__c.format());
        
        System.Debug('program.Venue_Name__c->' + program.Venue_Name__c);
        output=program.Venue_Name__c ==null? output.replace('[[Venue Name]]','') : output.replace('[[Venue Name]]',program.Venue_Name__c);
        
        System.Debug('program.Venue_Country__c->' + program.Venue_Country__c);
        output=program.Venue_Country__c ==null? output.replace('[[Venue Country]]','') : output.replace('[[Venue Country]]',program.Venue_Country__c);
        
        System.debug('### Program output->'+  output); 
        
        System.Debug('### Adding Venue details');
        String venueSection='';
        System.Debug('program.Venue_City__c->' + program.Venue_City__c);
        venueSection +=program.Venue_City__c == null? '' : venueSection =='' ? program.Venue_City__c:', '+program.Venue_City__c;
        
        System.Debug('program.Venue_Province_Region__c->' + program.Venue_Province_Region__c);
        venueSection +=program.Venue_Province_Region__c == null? '' : venueSection =='' ?program.Venue_Province_Region__c:', '+program.Venue_Province_Region__c ;
        
        System.Debug('program.Venue_State__c->' + program.Venue_State__c);
        venueSection +=program.Venue_State__c == null? '' : venueSection =='' ? program.Venue_State__c : ', '+program.Venue_State__c;
        
        System.Debug('program.Venue_Zip_Code__c->' + program.Venue_Zip_Code__c);
        venueSection +=program.Venue_Zip_Code__c == null? '' : venueSection =='' ? program.Venue_Zip_Code__c : ', '+program.Venue_Zip_Code__c;
        output=venueSection == ''? output.replace('[[VenueSection]]',venueSection) : output.replace('[[VenueSection]]',venueSection);
        
        System.Debug('program.Benefits_Exchanged_for_Funding__c->' + program.Benefits_Exchanged_for_Funding__c);
        String BenefitsExchangedForFunding = program.Benefits_Exchanged_for_Funding__c == null?'':program.Benefits_Exchanged_for_Funding__c.replace(';',', ');
        if (program.Benefits_Exchanged_for_Funding__c != null && program.RecordType.DeveloperName == 'HC_Char_Program') {//GFRS-745
		    pattern pat = pattern.compile('(, )?((Non-promotional Exhibit Space)(, )?)');
			Matcher matcher = pat.matcher(BenefitsExchangedForFunding);
		    if (matcher.find()) {
		       	BenefitsExchangedForFunding = BenefitsExchangedForFunding.substring(0,matcher.end(2)-matcher.group(2).length()-(matcher.group(1)!=null && matcher.group(4)==null?matcher.group(1).length():0))+BenefitsExchangedForFunding.substring(matcher.end(2));
		    }
        }
        output=program.Benefits_Exchanged_for_Funding__c ==null? output.replace('[[BenefitsExchange]]','') : output.replace('[[BenefitsExchange]]','Benefits Exchanged for Funding: '+BenefitsExchangedForFunding);
        System.Debug('output->' + output);
        
        return output;
    } 
   
    
}