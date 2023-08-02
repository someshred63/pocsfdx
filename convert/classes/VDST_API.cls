public without sharing class VDST_API {
/*/////////////*/
/*/// EVENT ///*/
/*/////////////*/

    // AGGSPENDME-166: Mapping between new and old codes
    private static final Map<String, String> EVT_TXNS_MAPPING = new Map<String, String>{
        VDST_Utils.EVT_HCP_TOTAL_TXN => 'TOTALEVENT',
        VDST_Utils.EVT_HCP_MEALS_TXN => 'EVTMEALS'
    };

    /** @date 4/5/2016
    * @Author Pawel Sprysak
    * @description  Read Event API
    * @return String
    */
    public static String readEventSpendData(String abmEventId) {
        if ( String.isBlank(abmEventId)) {
            return JSON.serialize(new ErrorWrapper('ABM Event Id is required.'));
        }
        try {
            final JsonEventReadWrapper dataContainer = new JsonEventReadWrapper();
            final Set<String> excludedTxns = VDST_Utils.TOTAL_CALC_EXCLUDED_TXNS.get(VDST_Utils.EVT_HCP_TOTAL_TXN).clone();
            excludedTxns.add('TOTALEVENT');
            // Get Event Data
            VDST_Event_gne__c[] eventList = [
                SELECT
                    CurrentStatus_gne__c,
                    TotalAudioVisual_gne__c,
                    (SELECT Id FROM Event_Dates__r),
                    (SELECT VDST_Address_gne__r.PostalCode_gne__c FROM VDST_Event_Sites__r),
                    (
                        SELECT EventTransactionAmount_gne__c, EventTransactionTypeCode_gne__c
                        FROM VDST_Event_Transactions__r WHERE EventTransactionTypeCode_gne__c NOT IN :excludedTxns
                        ORDER BY EventTransactionTypeCode_gne__c
                    )
                FROM VDST_Event_gne__c WHERE ABM_EventId_gne__c = :abmEventId AND IsABMevent_gne__c = true LIMIT 1
            ];

            if (eventList.isEmpty()) {
                return JSON.serialize(new ErrorWrapper('Event was not found.'));
            }
            VDST_Event_gne__c event = eventList[0];
            // AGGSPENDME-139: Total Audio/Video not supported anymore
            // dataContainer.audio_visual  = event.TotalAudioVisual_gne__c;
            dataContainer.event_spends = new List<EventSpends>();
            dataContainer.abm_event_id = String.valueOf(abmEventId);
            dataContainer.summary_spends = new List<EventSummary>();
            dataContainer.event_status = String.valueOf(event.CurrentStatus_gne__c);
            if (event.VDST_Event_Sites__r.size() > 0 && event.VDST_Event_Sites__r.get(0).VDST_Address_gne__r != null) {
                dataContainer.address_zip = event.VDST_Event_Sites__r[0].VDST_Address_gne__r.PostalCode_gne__c;
            }
            // collect transactional data
            for (VDST_EventDate_gne__c evtDate : [
                SELECT
                    EventDate_gne__c,
                    ActualAttendeeRollup_gne__c,
                    ActualConsumedRollup_gne__c,
                    NonHcpActualAttendeeCount_gne__c,
                    NonHcpActualConsumedCount_gne__c,
                    (
                        SELECT NumberOfMeals_gne__c, EventDateTransactionAmount_gne__c
                        FROM VDST_Event_Date_Transactions_del__r
                    )
                FROM VDST_EventDate_gne__c WHERE VDST_Event_gne__r.ABM_EventId_gne__c = :abmEventId
                ORDER BY EventDate_gne__c LIMIT :event.Event_Dates__r.size()
            ]) {
                for (VDST_EventDateTransaction_gne__c evtDateTx : evtDate.VDST_Event_Date_Transactions_del__r) {
                    EventSpends es = new EventSpends();
                    es.spend_date = evtDate.EventDate_gne__c;
                    es.amount = evtDateTx.EventDateTransactionAmount_gne__c;
                    es.number_of_meals = String.valueOf(evtDateTx.NumberOfMeals_gne__c);
                    es.hcp_actual_attendee_count = Integer.valueOf(evtDate.ActualAttendeeRollup_gne__c);
                    es.hcp_actual_consumed_count = Integer.valueOf(evtDate.ActualConsumedRollup_gne__c);
                    es.nonHcp_actual_attendee_count = Integer.valueOf(evtDate.NonHcpActualAttendeeCount_gne__c);
                    es.nonHcp_actual_consumed_count = Integer.valueOf(evtDate.NonHcpActualConsumedCount_gne__c);
                    dataContainer.event_spends.add(es);
                }
            }
            // AGGSPENDME-166: Collect transaction summaries
            for (VDST_EventTransactionSummary_gne__c edt : event.VDST_Event_Transactions__r) {
                EventSummary es = new EventSummary();
                es.code = EVT_TXNS_MAPPING.containsKey(edt.EventTransactionTypeCode_gne__c) ?
                    EVT_TXNS_MAPPING.get(edt.EventTransactionTypeCode_gne__c) : edt.EventTransactionTypeCode_gne__c;
                es.amount = edt.EventTransactionAmount_gne__c;
                dataContainer.summary_spends.add(es);
            }
            return JSON.serialize(dataContainer);
        } catch (Exception ex) {
            return JSON.serialize(new ErrorWrapper('Error while reading Event Spend data: ' + ex.getMessage()));
        }
    }

    /** @date 4/11/2016
    * @Author Pawel Sprysak
    * @description  Validate/Insert Event API
    * @return String
    */
    public static String sendEventJSON (String jsonString) {
        Savepoint sp = Database.setSavepoint();
        try {
            JsonEventWrapper       parsedJSON = parseStringToEventWrapper(jsonString);
            VDST_Event_gne__c       eventData = new VDST_Event_gne__c(EventType_gne__c = 'ADBOARD', IsABMevent_gne__c = true);
            VDST_EventSite_gne__c    siteData = new VDST_EventSite_gne__c();
            VDST_Address_gne__c   addressData = new VDST_Address_gne__c();
            String               brandIdsList = '';
            Map<String, String> nameToCodeMap = getNameToCodeValues();
            String                 fieldError = '';
            String                  errorMsgs = '';
            List<VDST_Event_gne__c>    evList = new List<VDST_Event_gne__c>();

            // Current Status
            if( 'Occurred'.equals(parsedJSON.event_status) || 'OCCURRED'.equals(parsedJSON.event_status) ) {
                eventData.CurrentStatus_gne__c = 'OCCURRED';
            } else if( 'Pending'.equals(parsedJSON.event_status) || 'PENDING'.equals(parsedJSON.event_status) ) {
                eventData.CurrentStatus_gne__c = 'PENDING';
            } else if( 'Cancelled'.equals(parsedJSON.event_status) || 'CANCEL'.equals(parsedJSON.event_status) ) {
                eventData.CurrentStatus_gne__c = 'CANCEL';
            } else if( 'Closed'.equals(parsedJSON.event_status) || 'CLOSED'.equals(parsedJSON.event_status) ) {
                eventData.CurrentStatus_gne__c = 'CLOSED';
            } else {
                errorMsgs += isRequiredValue(VDST_Event_gne__c.CurrentStatus_gne__c, '');
            }
            // ABM Event Id
            errorMsgs += validateAndSetFieldValue(eventData, VDST_Event_gne__c.ABM_EventId_gne__c, parsedJSON.abm_event_id, true);
            // Validate Logistic / Content Vendor data
            List<String> vendorList = new List<String>();
            if( !String.isBlank(parsedJSON.logistic_vendor) ) {
                vendorList.add(parsedJSON.logistic_vendor);
            }
            if( !String.isBlank(parsedJSON.content_vendor) ) {
                vendorList.add(parsedJSON.content_vendor);
            }
            for( VDST_EventProvider_gne__c ep : VDST_Utils.getVendorGroupDataByName(vendorList) ) {
                if( ep.VendorName_gne__c.equals(parsedJSON.content_vendor) ) {
                    eventData.ContentVendor_gne__c = ep.Id;
                }
                if( ep.VendorName_gne__c.equals(parsedJSON.logistic_vendor) ) {
                    eventData.LogisticVendor_gne__c = ep.Id;
                    parsedJSON.logistic_vendor = ep.VendorCode_gne__c;
                }
            }
            errorMsgs += isRequiredValue(VDST_Event_gne__c.ContentVendor_gne__c, eventData.ContentVendor_gne__c);
            errorMsgs += isRequiredValue(VDST_Event_gne__c.LogisticVendor_gne__c, eventData.LogisticVendor_gne__c);
            // Meeting name
            errorMsgs += validateAndSetFieldValue(eventData, VDST_Event_gne__c.EventMeetingName_gne__c, parsedJSON.meeting_name, true);
            // Date validation
            if( parsedJSON.event_start_date != null && parsedJSON.event_end_date != null ) {
                eventData.EventStartDate_gne__c = parsedJSON.event_start_date;
                eventData.EventEndDate_gne__c = parsedJSON.event_end_date;
                if( eventData.EventStartDate_gne__c.year() < 2016 ) {
                    errorMsgs += 'The event must be from 2016 year or later<br/>';
                } else if(eventData.EventStartDate_gne__c > eventData.EventEndDate_gne__c) {
                    errorMsgs += 'Event Start Date cannot be greater than Event End Date<br/>';
                } else if( parsedJSON.address_type != null ) {
                    /*AGGSPENDME-251*/
                    if(!parsedJSON.address_type) {
                        if(eventData.EventStartDate_gne__c.addDays(5) <= eventData.EventEndDate_gne__c) {
                            errorMsgs += 'The difference between Event Start date and Event End Date cannot exceed more than 4 days<br/>';
                        }
                    }
                }
            } else {
                errorMsgs += isRequiredValue(VDST_Event_gne__c.EventStartDate_gne__c, String.valueOf(parsedJSON.event_start_date));
                errorMsgs += isRequiredValue(VDST_Event_gne__c.EventEndDate_gne__c, String.valueOf(parsedJSON.event_end_date));
            }
            // Invitation Send Date
            eventData.InvitationSentDate_gne__c = parsedJSON.invitation_sent_date;
            // Accountable data
            All_User_Hierarchy_gne__c auh = VDST_Utils.getUserData(parsedJSON.accountable_unix_id);
            if(auh != null) {
                eventData.AccountableGNE_FirstName_gne__c = auh.FirstName_gne__c;
                eventData.AccountableGNE_LastName_gne__c = auh.LastName_gne__c;
                eventData.AccountableGNE_UnixID_gne__c = auh.User_External_Id_gne__c;
            } else {
                eventData.AccountableGNE_FirstName_gne__c = '';
                eventData.AccountableGNE_LastName_gne__c = '';
                eventData.AccountableGNE_UnixID_gne__c = '';
            }
            // Genentech Event Id
            errorMsgs += validateAndSetFieldValue(eventData, VDST_Event_gne__c.GNE_EventID_gne__c, parsedJSON.genentech_event_id, false);
            if(! String.isBlank(eventData.GNE_EventID_gne__c) ) {
                List<VDST_Event_gne__c> evExList = [SELECT Id
                                                   FROM VDST_Event_gne__c
                                                   WHERE GNE_EventID_gne__c = :eventData.GNE_EventID_gne__c AND ABM_EventId_gne__c != :eventData.ABM_EventId_gne__c];
                if(evExList.size() > 0) {
                    errorMsgs += 'Genentech Event Id must be unique<br/>';
                }
            }
            // Audio / Visual
            errorMsgs += validateAndSetFieldValue(eventData, VDST_Event_gne__c.TotalAudioVisual_gne__c, String.valueOf(parsedJSON.audio_visual), parsedJSON.audio_visual, false);
            // Planned attendee count
            fieldError = validateFieldLengthAndRequirement(VDST_Event_gne__c.TotPlanAttCntUser_gne__c, String.valueOf(parsedJSON.planned_attendee_count) );
            if( !String.isBlank(fieldError) ) {
                errorMsgs += fieldError;
            } else {
                eventData.TotPlanAttCntUser_gne__c = parsedJSON.planned_attendee_count;
            }
            // Comment
            // errorMsgs += validateAndSetFieldValue(eventData, VDST_Event_gne__c.Comment_gne__c, parsedJSON.comment, false);
            // Brands
            if( !String.isBlank(parsedJSON.brands) ) {
                List<String>      brandsArray = parsedJSON.brands.split(',');
                Set<String>            brands = new Set<String>();
                String               errorStr = '';
                String                 idList = '';
                Map<String, String> brandList = VDST_Utils.getMapOfDrugNames();

                for(String brand: brandsArray) {
                    brands.add(brand);
                }
                if(brands.size() < 6) {
                    for(String brand : brands) {
                        if(brandList.containsKey(brand)) {
                            if( !String.isBlank(idList) ) {
                                idList += ',';
                            }
                            idList += brandList.get(brand);
                        } else {
                            if( !String.isBlank(errorstr) ) {
                                errorstr += ', ';
                            }
                            errorstr += brand;
                        }
                    }
                    if( !String.isBlank(errorstr) ) {
                        errorMsgs += 'Following Brand fields cannot be selected: ' + errorstr + '<br/>';
                    } else {
                        brandIdsList = idList;
                    }
                } else {
                    errorMsgs += 'You can select up to 5 brands for event.<br/>';
                }
            }
            // Address - Site data
            errorMsgs += validateAndSetFieldValue(siteData, VDST_EventSite_gne__c.EventSiteName_gne__c, parsedJSON.address_venue_name, false);
            // Address - City
            errorMsgs += validateAndSetFieldValue(addressData, VDST_Address_gne__c.City_gne__c, parsedJSON.address_city, false);
            // Address - Street Address
            errorMsgs += validateAndSetFieldValue(addressData, VDST_Address_gne__c.StreetAddress_gne__c, parsedJSON.address_street, false);
            // Address - Country
            if( !String.isBlank(parsedJSON.address_country) ) {
                String countryValue = getPicklistValue(VDST_Address_gne__c.Country_gne__c, parsedJSON.address_country, nameToCodeMap);
                fieldError = isRequiredValue(VDST_Address_gne__c.Country_gne__c, countryValue);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else {
                    addressData.Country_gne__c = countryValue;
                }
            } else {
                addressData.Country_gne__c = '';
            }
            // Address - State
            if( !String.isBlank(parsedJSON.address_state) ) {
                if( 'USA'.equals(addressData.Country_gne__c) ) {
                    String stateCode = VDST_Utils.getInverseStatesMap().get(parsedJSON.address_state.toLowerCase());
                    fieldError = isRequiredValue(VDST_Address_gne__c.StateProvince_gne__c, stateCode);
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    } else {
                        addressData.StateProvince_gne__c = stateCode;
                        addressData.StatesNameHolder_gne__c = '';
                    }
                } else {
                    fieldError = validateField(VDST_Address_gne__c.StatesNameHolder_gne__c, parsedJSON.address_state);
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    } else {
                        addressData.StatesNameHolder_gne__c = parsedJSON.address_state;
                        addressData.StateProvince_gne__c = 'ANY';
                    }
                }
            } else {
                addressData.StatesNameHolder_gne__c = '';
                addressData.StateProvince_gne__c = '';
            }
            // Address - ZIP
            if( !String.isBlank(parsedJSON.address_zip) ) {
                if( checkZipCode(parsedJSON.address_zip, addressData.Country_gne__c) ) {
                    addressData.PostalCode_gne__c = parsedJSON.address_zip;
                } else {
                    errorMsgs += isRequiredValue(VDST_Address_gne__c.PostalCode_gne__c, '');
                }
            } else {
                addressData.PostalCode_gne__c = '';
            }
            // Address - Type
            if( parsedJSON.address_type != null ) {
                if(parsedJSON.address_type) {
                    eventData.iAdviseEvent_gne__c = true;
                    addressData.AddressType_gne__c = 'Virtual';
                    if( String.isBlank(addressData.City_gne__c) ) {
                        addressData.Country_gne__c = 'USA';
                        addressData.StreetAddress_gne__c = '1 DNA Way';
                        addressData.City_gne__c = 'South San Francisco';
                        addressData.PostalCode_gne__c = '94080';
                        addressData.StatesNameHolder_gne__c = '';
                        addressData.StateProvince_gne__c = 'CA';
                    }
                } else {
                    eventData.iAdviseEvent_gne__c = false;
                    addressData.AddressType_gne__c = 'Physical';
                }
            } else {
                errorMsgs += isRequiredValue(VDST_Address_gne__c.AddressType_gne__c, '');
            }
            // Spend data
            if( parsedJSON.event_spends != null ) {
                for(EventSpends es : parsedJSON.event_spends) {
                    // Meal Amount
                    fieldError = validateFieldLengthAndRequirement(VDST_EventDateTransaction_gne__c.EventDateTransactionAmount_gne__c, String.valueOf(es.amount) );
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                        es.amount = 0;
                    }
                    // Number of Meals
                    if( !String.isBlank(es.number_of_meals) ) {
                        if( String.isBlank( VDST_Utils.getPickListMap(VDST_EventDateTransaction_gne__c.NumberOfMeals_gne__c.getDescribe()).get(es.number_of_meals) ) ) {
                            errorMsgs += 'Incorrect Number Of Meals value<br/>';
                            es.number_of_meals = null;
                        }
                    }
                    if(es.amount != null && es.amount > 0 && String.isBlank(es.number_of_meals) ) {
                        errorMsgs += 'Number Of Meals is required when Daily Meal Total is greater than zero (0.00)<br/>';
                    }
                    // Actual Attendee Count
                    fieldError = validateFieldLengthAndRequirement(VDST_EventDate_gne__c.NonHcpActualAttendeeCount_gne__c, String.valueOf(es.nonHcp_actual_attendee_count) );
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    }
                    // Actual Consumed Count
                    fieldError = validateFieldLengthAndRequirement(VDST_EventDate_gne__c.NonHcpActualConsumedCount_gne__c, String.valueOf(es.nonHcp_actual_consumed_count) );
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    }
                }
            }
            if( !String.isBlank(errorMsgs) ) {
                return 'Missing Event required fields or incorrect data: <br/>' + errorMsgs;
            } else {
                evList = [SELECT Id, iAdviseEvent_gne__c, VendorEventID_gne__c FROM VDST_Event_gne__c WHERE ABM_EventId_gne__c = :eventData.ABM_EventId_gne__c];
                if(evList.size() > 0) {
                   eventData.VendorEventID_gne__c = evList.get(0).VendorEventID_gne__c;
                   eventData.Id = evList.get(0).Id;
                }
                if( !'PENDING'.equals(eventData.CurrentStatus_gne__c) ) {
                    String eventStatusToValidate = eventData.CurrentStatus_gne__c;
                    if( 'OCCURRED'.equals(eventData.CurrentStatus_gne__c) ) {
                        eventStatusToValidate = 'CLOSED';
                    }
                    errorMsgs += VDST_Validator.validateEventOnStatusChange('ADBOARD', parsedJSON.logistic_vendor,
                                                    (Map<String, Map<String, VDST_EventField_gne__c>>)null, eventStatusToValidate, eventData,
                                                    siteData, addressData, brandIdsList, (List<VDST_EventTransactionSummary_gne__c>)null,
                                                    false, new List<VDST_Utils.EventDateTransactions>() );
                    if( ('CLOSED'.equals(eventStatusToValidate) || 'CANCEL'.equals(eventStatusToValidate)) && evList.size() > 0) {
                        VDST_Validator.ParticipantsValidationInput input = new VDST_Validator.ParticipantsValidationInput();
                        input.status = eventStatusToValidate;
                        input.prtcpntFieldMap = null;
                        input.eventCreateObject = new VDST_Event_gne__c(Id = evList.get(0).Id);
                        VDST_EventDetailCommon commonUtils = new VDST_EventDetailCommon('ADBOARD');
                        // Do validation
                        VDST_Validator.ParticipantsValidationOutput output = VDST_Validator.validateParticipantsOnStatusChange('ADBOARD', parsedJSON.logistic_vendor,
                                                       input, null, null, commonUtils.eventRolesMapById);
                        errorMsgs += output.editErrorMessages;
                    }
                }
            }
            if( !String.isBlank(errorMsgs) ) {
                return errorMsgs;
            }
            if( parsedJSON.isValidation == null ) {
                parsedJSON.isValidation = true;
            }
            if( !parsedJSON.isValidation ) {
                Boolean reopenClosed = false;
                Boolean reopenCancelled = false;
                // Event & Site & Address
                List<VDST_EventSite_gne__c> esList = [SELECT Id, EventSiteName_gne__c, VDST_Event_gne__r.Id, VDST_Address_gne__r.Id,
                                                              VDST_Event_gne__r.TotalAudioVisual_gne__c, VDST_Event_gne__r.CurrentStatus_gne__c, VDST_Event_gne__r.CurrentStatusDate_gne__c,
                                                              VDST_Address_gne__r.AddressType_gne__c, VDST_Address_gne__r.Country_gne__c,
                                                              VDST_Address_gne__r.StreetAddress_gne__c, VDST_Address_gne__r.City_gne__c,
                                                              VDST_Address_gne__r.StatesNameHolder_gne__c, VDST_Address_gne__r.StateProvince_gne__c,
                                                              VDST_Address_gne__r.PostalCode_gne__c
                                                          FROM VDST_EventSite_gne__c
                                                          WHERE VDST_Event_gne__r.ABM_EventId_gne__c = :eventData.ABM_EventId_gne__c AND VDST_Event_gne__r.IsABMevent_gne__c = true];
                if(esList.size() > 0) {
                    eventData.Id = esList.get(0).VDST_Event_gne__r.Id;
                }
                // Creating new event
                if( esList.size() < 1 ) {
                    if( 'OCCURRED'.equals(eventData.CurrentStatus_gne__c) ) {
                        return 'Creating event in Occurred status is not permitted.<br/>';
                    } else if( 'CLOSED'.equals(eventData.CurrentStatus_gne__c) ) {
                        return 'Creating event in Closed status is not permitted.<br/>';
                    } else {
                        eventData.CurrentStatusDate_gne__c = Date.today();
                    }
                // Stay in the same status
                } else if(eventData.CurrentStatus_gne__c.equals(esList.get(0).VDST_Event_gne__r.CurrentStatus_gne__c) ) {
                    if( 'CLOSED'.equals(esList.get(0).VDST_Event_gne__r.CurrentStatus_gne__c) ) {
                        eventData.CurrentStatusDate_gne__c = Date.today();
                        reopenClosed = true;
                    } else if( 'CANCEL'.equals(esList.get(0).VDST_Event_gne__r.CurrentStatus_gne__c) ) {
                        eventData.CurrentStatusDate_gne__c = Date.today();
                        reopenCancelled = true;
                    }
                // Other cases
                } else if( 'CANCEL'.equals(esList.get(0).VDST_Event_gne__r.CurrentStatus_gne__c)  && !'PENDING'.equals(eventData.CurrentStatus_gne__c) ) {
                    return 'Changing status from Cancelled is allowed for Pending status only.<br/>';
                } else if( 'CLOSED'.equals(esList.get(0).VDST_Event_gne__r.CurrentStatus_gne__c)  && !'OCCURRED'.equals(eventData.CurrentStatus_gne__c) ) {
                    return 'Changing status from Closed is allowed for Occurred status only.<br/>';
                } else if( 'OCCURRED'.equals(esList.get(0).VDST_Event_gne__r.CurrentStatus_gne__c)  && !'CLOSED'.equals(eventData.CurrentStatus_gne__c) ) {
                    return 'Changing status from Occurred is allowed for Closed status only.<br/>';
                } else {
                    eventData.CurrentStatusDate_gne__c = Date.today();
                }

                // Event - Re-opening
                if(reopenClosed) {
                    eventData.CurrentStatus_gne__c = 'OCCURRED';
                    upsert eventData ABM_EventId_gne__c;
                } else if(reopenCancelled) {
                    eventData.CurrentStatus_gne__c = 'PENDING';
                    upsert eventData ABM_EventId_gne__c;
                }

                if(esList.size() < 1) {
                    insert eventData;
                    insert addressData;
                    siteData.VDST_Address_gne__c = addressData.Id;
                    siteData.VDST_Event_gne__c = eventData.Id;
                    insert siteData;
                } else {
                    eventData.Id = esList.get(0).VDST_Event_gne__r.Id;
                    update eventData;
                    addressData.Id = esList.get(0).VDST_Address_gne__r.Id;
                    update addressData;
                    siteData.Id = esList.get(0).Id;
                    update siteData;
                }
                // Product Catalog
                List<VDST_EventBrandTopic_gne__c> dataToInsert = new List<VDST_EventBrandTopic_gne__c>();
                Map<Id, VDST_EventBrandTopic_gne__c> existingMap = new Map<Id, VDST_EventBrandTopic_gne__c>();
                for(VDST_EventBrandTopic_gne__c brands: [SELECT Id, Product_Catalog_gne__c, VDST_Event_gne__c
                                                             FROM VDST_EventBrandTopic_gne__c
                                                             WHERE VDST_Event_gne__c = :eventData.Id]) {
                    existingMap.put(brands.Product_Catalog_gne__c, brands);
                }
                if(!String.isBlank(brandIdsList)) {
                    for(Id brandId : brandIdsList.split(',') ) {
                        if( existingMap.get(brandId) == null ) {
                            dataToInsert.add(new VDST_EventBrandTopic_gne__c(VDST_Event_gne__c = eventData.Id, Product_Catalog_gne__c = brandId));
                        } else {
                            existingMap.remove(brandId);
                        }
                    }
                    insert dataToInsert;
                    delete existingMap.values();
                } else if (existingMap.values().size() > 0) {
                    delete existingMap.values();
                }
                // Spend Data - available only for non-Virtual events
                if( parsedJSON.address_type != null ) {
                        Map<Date, VDST_EventDateTransaction_gne__c> transactionMap = new Map<Date, VDST_EventDateTransaction_gne__c>();
                        Map<Date, VDST_EventDate_gne__c>              eventDateMap = new Map<Date, VDST_EventDate_gne__c>();
                        for (VDST_EventDateTransaction_gne__c dateTransaction : [SELECT Id, NumberOfMeals_gne__c, EventDateTransactionAmount_gne__c,
                                                                                        VDST_EventDate_gne__r.EventDate_gne__c, VDST_EventDate_gne__r.Id,
                                                                                        VDST_EventDate_gne__r.VDST_Event_gne__c,
                                                                                        VDST_EventDate_gne__r.NonHcpActualAttendeeCount_gne__c,
                                                                                        VDST_EventDate_gne__r.NonHcpActualConsumedCount_gne__c
                                                                                     FROM VDST_EventDateTransaction_gne__c
                                                                                     WHERE VDST_EventDate_gne__r.VDST_Event_gne__c = :eventData.Id]) {
                            // Event Date Transaction
                            dateTransaction.EventDateTransactionAmount_gne__c = 0;
                            dateTransaction.NumberOfMeals_gne__c = '';
                            transactionMap.put(dateTransaction.VDST_EventDate_gne__r.EventDate_gne__c, dateTransaction);
                            // Event Date data
                            dateTransaction.VDST_EventDate_gne__r.NonHcpActualAttendeeCount_gne__c = 0;
                            dateTransaction.VDST_EventDate_gne__r.NonHcpActualConsumedCount_gne__c = 0;
                            eventDateMap.put(dateTransaction.VDST_EventDate_gne__r.EventDate_gne__c, dateTransaction.VDST_EventDate_gne__r);
                        }
                        if( parsedJSON.event_spends != null ) {
                            for(EventSpends es : parsedJSON.event_spends) {
                                if(es.spend_date >= eventData.EventStartDate_gne__c && es.spend_date <= eventData.EventEndDate_gne__c) {
                                    if( transactionMap.get(es.spend_date) != null ) {
                                        transactionMap.get(es.spend_date).EventDateTransactionAmount_gne__c = es.amount;
                                        transactionMap.get(es.spend_date).NumberOfMeals_gne__c = es.number_of_meals;
                                    }
                                    if( eventDateMap.get(es.spend_date) != null ) {
                                        eventDateMap.get(es.spend_date).NonHcpActualAttendeeCount_gne__c = es.nonHcp_actual_attendee_count;
                                        eventDateMap.get(es.spend_date).NonHcpActualConsumedCount_gne__c = es.nonHcp_actual_consumed_count;
                                    }
                                }
                            }
                        }
                        update transactionMap.values();
                        update eventDateMap.values();
                    } else if(evList.size() > 0 && evList.get(0).iAdviseEvent_gne__c != null) {
                        Map<Date, VDST_EventDateTransaction_gne__c> transactionMap = new Map<Date, VDST_EventDateTransaction_gne__c>();
                        Map<Date, VDST_EventDate_gne__c>              eventDateMap = new Map<Date, VDST_EventDate_gne__c>();
                        for (VDST_EventDateTransaction_gne__c dateTransaction : [SELECT Id, NumberOfMeals_gne__c, EventDateTransactionAmount_gne__c,
                                                                                        VDST_EventDate_gne__r.EventDate_gne__c, VDST_EventDate_gne__r.Id,
                                                                                        VDST_EventDate_gne__r.VDST_Event_gne__c,
                                                                                        VDST_EventDate_gne__r.NonHcpActualAttendeeCount_gne__c,
                                                                                        VDST_EventDate_gne__r.NonHcpActualConsumedCount_gne__c
                                                                                     FROM VDST_EventDateTransaction_gne__c
                                                                                     WHERE VDST_EventDate_gne__r.VDST_Event_gne__c = :eventData.Id]) {
                            // Event Date Transaction
                            if(dateTransaction.EventDateTransactionAmount_gne__c != 0 || !String.isBlank(dateTransaction.NumberOfMeals_gne__c)) {
                                dateTransaction.EventDateTransactionAmount_gne__c = 0;
                                dateTransaction.NumberOfMeals_gne__c = '';
                                transactionMap.put(dateTransaction.VDST_EventDate_gne__r.EventDate_gne__c, dateTransaction);
                            }
                            // Event Date data
                            if(dateTransaction.VDST_EventDate_gne__r.NonHcpActualAttendeeCount_gne__c != 0 || dateTransaction.VDST_EventDate_gne__r.NonHcpActualConsumedCount_gne__c != 0) {
                                dateTransaction.VDST_EventDate_gne__r.NonHcpActualAttendeeCount_gne__c = 0;
                                dateTransaction.VDST_EventDate_gne__r.NonHcpActualConsumedCount_gne__c = 0;
                                eventDateMap.put(dateTransaction.VDST_EventDate_gne__r.EventDate_gne__c, dateTransaction.VDST_EventDate_gne__r);
                            }
                        }
                        if(transactionMap.values().size() > 0) {
                            update transactionMap.values();
                        }
                        if(eventDateMap.values().size() > 0) {
                            update eventDateMap.values();
                        }
                    }

                // Event - Closing back
                if(reopenClosed) {
                    eventData.CurrentStatus_gne__c = 'CLOSED';
                    upsert eventData ABM_EventId_gne__c;
                } else if(reopenCancelled) {
                    eventData.CurrentStatus_gne__c = 'CANCEL';
                    upsert eventData ABM_EventId_gne__c;
                }

                return 'OK';
            }
            return 'OK';
        } catch (Exception ex) {
            Database.rollback(sp);
            return JSON.serialize(new ErrorWrapper('Error while creating/updating Event data: ' + ex.getMessage()));
        }
    }

    // Event Read Wrapper
    virtual class JsonEventReadWrapper {
        // Read Data
        String                         abm_event_id { get; set; }
        Decimal                        audio_visual { get; set; } // AGGSPENDME-139: Total Audio/Video not supported anymore; left for backward compatibility
        String                         event_status { get; set; }
        List<EventSpends>              event_spends { get; set; }
        List<EventSummary>           summary_spends { get; set; } // Only Read
        String                          address_zip { get; set; }
    }

    // Event Write Wrapper
    class JsonEventWrapper extends JsonEventReadWrapper {
        // Flags
        Boolean                        isValidation { get; set; }
        // Fields for Upsert only
        String                      logistic_vendor { get; set; }
        String                       content_vendor { get; set; }
        String                  accountable_unix_id { get; set; }
        String                   genentech_event_id { get; set; }
        String                         meeting_name { get; set; }
        String                               brands { get; set; }
        Date                       event_start_date { get; set; }
        Date                         event_end_date { get; set; }
        Date                   invitation_sent_date { get; set; }
        Boolean                        address_type { get; set; }
        String                   address_venue_name { get; set; }
        String                      address_country { get; set; }
        String                       address_street { get; set; }
        String                         address_city { get; set; }
        String                        address_state { get; set; }
        //String                              comment { get; set; }
        Integer              planned_attendee_count { get; set; }
    }

    class EventSpends {
        Date                             spend_date { get; set; }
        Decimal                              amount { get; set; }
        String                      number_of_meals { get; set; }
        Integer        nonHcp_actual_attendee_count { get; set; }
        Integer        nonHcp_actual_consumed_count { get; set; }
        Integer           hcp_actual_attendee_count { get; set; } // Read Only
        Integer           hcp_actual_consumed_count { get; set; } // Read Only
    }

    class EventSummary {
        String                                 code { get; set; }
        Decimal                              amount { get; set; }
    }

    private static JsonEventWrapper parseStringToEventWrapper(String jsonString){
        return (JsonEventWrapper) System.JSON.deserialize(jsonString, JsonEventWrapper.class);
    }

/*/////////////*/
/* PARTICIPANT */
/*/////////////*/

    /** @date 4/8/2016
    * @Author Pawel Sprysak
    * @description  Read Participant API
    * @return String
    */
    public static String readParticipantSpendData(String abmParticipantId) {
        if (String.isBlank(abmParticipantId)) {
            return JSON.serialize(new ErrorWrapper('ABM Participant Id is required.'));
        }
        try {
            JsonParticipantReadWrapper dataContainer = new JsonParticipantReadWrapper();
            dataContainer.abm_participant_id     = abmParticipantId;

            // Get Participant data
            List<VDST_EventPrtcpntAccnt_gne__c> epaList = [SELECT Id, ParticipantContractStatus_gne__c
                                                              FROM VDST_EventPrtcpntAccnt_gne__c
                                                              WHERE ABM_ParticipantId_gne__c = :abmParticipantId AND PartyType_gne__c = 'INDV'];
            if(epaList.size() > 0) {
                if('NTCNTRCTD'.equals(epaList.get(0).ParticipantContractStatus_gne__c)) {
                    dataContainer.contracted = false;
                } else {
                    dataContainer.contracted = true;
                }
            }
            // Get Participant Spend data
            List<ParticipantSpends> psList = new List<ParticipantSpends>();
            Id orgId = null;
            for(VDST_PrtcpntTransaction_gne__c pt: [SELECT TransactionAllocationType_gne__c, TransactionAmount_gne__c, TransactionTypeCode_gne__c, VDST_PaidToParty_gne__c
                                                        FROM VDST_PrtcpntTransaction_gne__c
                                                        WHERE VDST_EventPrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c = :abmParticipantId]) {
                ParticipantSpends ps = new ParticipantSpends();
                ps.code   = pt.TransactionTypeCode_gne__c;
                ps.amount = pt.TransactionAmount_gne__c;
                psList.add(ps);
                if( 'INDIRECT'.equals(pt.TransactionAllocationType_gne__c) ) {
                    orgId = pt.VDST_PaidToParty_gne__c;
                }
            }
            if (psList.isEmpty()) {
                return JSON.serialize(new ErrorWrapper('Participant was not found.'));
            }
            dataContainer.participant_spends = psList;

            // Get Organization data
            if(orgId != null) {
                VDST_EventPrtcpntAccnt_gne__c orgData = [SELECT LegalName_gne__c, TIN_gne__c, Charitable_Organization_gne__c, NPI_gne__c, DEA_gne__c, MDMID_gne__c, VDST_Address_gne__c
                                                            FROM VDST_EventPrtcpntAccnt_gne__c
                                                            WHERE Id = :orgId AND PartyType_gne__c = 'ORG'];
                VDST_Address_gne__c orgAdr =            [SELECT City_gne__c, Country_gne__c, PostalCode_gne__c, StreetAddress_gne__c, StateProvince_gne__c, StatesNameHolder_gne__c
                                                            FROM VDST_Address_gne__c
                                                            WHERE Id = :orgData.VDST_Address_gne__c];
                OrganizationData orgContainer = new OrganizationData();
                orgContainer.org_name         = orgData.LegalName_gne__c;
                orgContainer.tin              = orgData.TIN_gne__c;
                orgContainer.charitable_org   = orgData.Charitable_Organization_gne__c;
                orgContainer.npi              = orgData.NPI_gne__c;
                orgContainer.dea              = orgData.DEA_gne__c;
                orgContainer.mdm_id           = orgData.MDMID_gne__c;
                orgContainer.address_country  = orgAdr.Country_gne__c;
                orgContainer.address_street   = orgAdr.StreetAddress_gne__c;
                orgContainer.address_city     = orgAdr.City_gne__c;
                orgContainer.address_state    = orgAdr.StateProvince_gne__c;
                orgContainer.address_zip      = orgAdr.PostalCode_gne__c;
                if( 'ANY'.equals(orgContainer.address_state) ) {
                    orgContainer.address_state = orgAdr.StatesNameHolder_gne__c;
                }
                dataContainer.organization_data = orgContainer;
            }

            String edmIabpName;
            List<AttData> attDataList = new List<AttData>();
            for(VDST_EventPrtcpntAttendance_gne__c epa : [SELECT AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, MealAmount_gne__c,
                                                          VDST_EventDate_gne__r.EventDate_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.ABM_EventId_gne__c
                                                          FROM VDST_EventPrtcpntAttendance_gne__c
                                                          WHERE Event_PrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c = :abmParticipantId]) {
                AttData ad = new AttData();
                ad.att_status           = epa.AttendanceStatus_gne__c;
                ad.consumption_status   = epa.ParticipantMealConsumptionStatus_gne__c;
                ad.meal_amount          = epa.MealAmount_gne__c;
                ad.event_date           = epa.VDST_EventDate_gne__r.EventDate_gne__c;
                attDataList.add(ad);
                edmIabpName = epa.VDST_EventDate_gne__r.VDST_Event_gne__r.ABM_EventId_gne__c;
            }
            if (String.isNotBlank(edmIabpName)) {
                attDataList = replaceMealAmountValues(edmIabpName, attDataList);
            }
            dataContainer.att_data = attDataList;

            return JSON.serialize(dataContainer);
        } catch (Exception ex) {
            return JSON.serialize(new ErrorWrapper('Error while reading Participant Spend data: ' + ex.getMessage()));
        }
    }

    /** @date 2/26/2020
    * @Author Waldemar Kaczor
    * @description  Jira CFS-349, replace meal amount values for EDM side.
    * @return List<AttData>
    */
    public static List<AttData> replaceMealAmountValues(String edmIabpName, List<AttData> attDataList) {
        Map<Date, EDM_Spend_Attendance_gne__c > dateToAttendance = new Map<Date, EDM_Spend_Attendance_gne__c >();
        for (EDM_Spend_Attendance_gne__c spa : [
                SELECT EDM_Event_Date_gne__c, EDM_Planned_Attendee_HCP_Count_gne__c,
                        EDM_Planned_Attendee_Other_Count_gne__c, EDM_Meal_Total_gne__c
                FROM EDM_Spend_Attendance_gne__c
                WHERE EDM_Parent_IABP_gne__r.Name = :edmIabpName
        ]) {
            dateToAttendance.put(spa.EDM_Event_Date_gne__c, spa);
        }
        for (AttData ad : attDataList) {
            if (dateToAttendance.containsKey(ad.event_date) && ad.consumption_status == 'CONSUMED') {
                EDM_Spend_Attendance_gne__c spa = dateToAttendance.get(ad.event_date);
                ad.meal_amount = spa.EDM_Meal_Total_gne__c / (spa.EDM_Planned_Attendee_HCP_Count_gne__c + spa.EDM_Planned_Attendee_Other_Count_gne__c);
            }
        }
        return attDataList;
    }

    /** @date 5/19/2016
    * @Author Pawel Sprysak
    * @description  Read ALL Participants API
    * @return String
    */
    public static String readAllParticipantsSpendData(String abmEventId) {
        if (String.isBlank(abmEventId)) {
            return JSON.serialize(new ErrorWrapper('ABM Event Id is required.'));
        }
        try {
            Map<String, JsonParticipantReadWrapper> dataContainer = new Map<String, JsonParticipantReadWrapper>();

            // Get Participant data
            for(VDST_EventPrtcpntAccnt_gne__c accnt: [SELECT Id, ParticipantContractStatus_gne__c, ABM_ParticipantId_gne__c
                                                              FROM VDST_EventPrtcpntAccnt_gne__c
                                                              WHERE VDST_Event_gne__r.ABM_EventId_gne__c = :abmEventId AND PartyType_gne__c = 'INDV']) {
                Boolean contractedStatus = true;
                if('NTCNTRCTD'.equals(accnt.ParticipantContractStatus_gne__c)) {
                    contractedStatus = false;
                }
                JsonParticipantReadWrapper jsonRW = new JsonParticipantReadWrapper();
                jsonRW.contracted = contractedStatus;
                jsonRW.abm_participant_id = accnt.ABM_ParticipantId_gne__c;
                jsonRW.participant_spends = new List<ParticipantSpends>();
                jsonRW.att_data = new List<AttData>();
                dataContainer.put( accnt.ABM_ParticipantId_gne__c, jsonRW);
            }

            if(dataContainer.isEmpty()) {
                return JSON.serialize(dataContainer);
            }

            Map<String, String> orgIdsMap = new Map<String, String>();
            for(VDST_PrtcpntTransaction_gne__c pt: [SELECT VDST_EventPrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c, TransactionAllocationType_gne__c, TransactionAmount_gne__c, TransactionTypeCode_gne__c, VDST_PaidToParty_gne__c
                                                        FROM VDST_PrtcpntTransaction_gne__c
                                                        WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.ABM_EventId_gne__c = :abmEventId AND VDST_EventPrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c != null]) {
                ParticipantSpends ps = new ParticipantSpends();
                ps.code   = pt.TransactionTypeCode_gne__c;
                ps.amount = pt.TransactionAmount_gne__c;
                dataContainer.get(pt.VDST_EventPrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c).participant_spends.add(ps);
                if( 'INDIRECT'.equals(pt.TransactionAllocationType_gne__c) ) {
                    orgIdsMap.put(pt.VDST_PaidToParty_gne__c, pt.VDST_EventPrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c);
                }
            }

            for(VDST_EventPrtcpntAttendance_gne__c epa : [SELECT AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, MealAmount_gne__c,
                                                                Event_PrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c, VDST_EventDate_gne__r.EventDate_gne__c
                                                          FROM VDST_EventPrtcpntAttendance_gne__c
                                                          WHERE Event_PrtcpntAccnt_gne__r.VDST_Event_gne__r.ABM_EventId_gne__c = :abmEventId]) {
                AttData ad = new AttData();
                ad.att_status           = epa.AttendanceStatus_gne__c;
                ad.consumption_status   = epa.ParticipantMealConsumptionStatus_gne__c;
                ad.meal_amount          = epa.MealAmount_gne__c;
                ad.event_date           = epa.VDST_EventDate_gne__r.EventDate_gne__c;
                dataContainer.get(epa.Event_PrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c).att_data.add(ad);
            }

            if( !orgIdsMap.isEmpty() ) {
                // address to orgContainer
                Map<String, OrganizationData> odMap = new Map<String, OrganizationData>();

                for( VDST_EventPrtcpntAccnt_gne__c orgData: [SELECT Id, ABM_ParticipantId_gne__c, LegalName_gne__c, TIN_gne__c, Charitable_Organization_gne__c, NPI_gne__c, DEA_gne__c, MDMID_gne__c, VDST_Address_gne__c
                                                                FROM VDST_EventPrtcpntAccnt_gne__c
                                                                WHERE Id IN :orgIdsMap.keySet() AND PartyType_gne__c = 'ORG']) {
                    OrganizationData orgContainer = new OrganizationData();
                    orgContainer.for_participant  = orgData.Id;
                    orgContainer.org_name         = orgData.LegalName_gne__c;
                    orgContainer.tin              = orgData.TIN_gne__c;
                    orgContainer.charitable_org   = orgData.Charitable_Organization_gne__c;
                    orgContainer.npi              = orgData.NPI_gne__c;
                    orgContainer.dea              = orgData.DEA_gne__c;
                    orgContainer.mdm_id           = orgData.MDMID_gne__c;
                    odMap.put(orgData.VDST_Address_gne__c, orgContainer);
                }

                for(VDST_Address_gne__c orgAdr: [SELECT Id, City_gne__c, Country_gne__c, PostalCode_gne__c, StreetAddress_gne__c, StateProvince_gne__c, StatesNameHolder_gne__c
                                                            FROM VDST_Address_gne__c
                                                            WHERE Id IN :odMap.keySet() ]) {
                    odMap.get(orgAdr.Id).address_country  = orgAdr.Country_gne__c;
                    odMap.get(orgAdr.Id).address_street   = orgAdr.StreetAddress_gne__c;
                    odMap.get(orgAdr.Id).address_city     = orgAdr.City_gne__c;
                    odMap.get(orgAdr.Id).address_state    = orgAdr.StateProvince_gne__c;
                    odMap.get(orgAdr.Id).address_zip      = orgAdr.PostalCode_gne__c;
                    if( 'ANY'.equals(orgAdr.StateProvince_gne__c) ) {
                        odMap.get(orgAdr.Id).address_state = orgAdr.StatesNameHolder_gne__c;
                    }
                }

                for(OrganizationData orgData: odMap.values() ) {
                    dataContainer.get(orgIdsMap.get(orgData.for_participant)).organization_data = orgData;
                }
            }

            return JSON.serialize(dataContainer);
        } catch (Exception ex) {
            return JSON.serialize(new ErrorWrapper('Error while reading Participants List: ' + ex.getMessage()));
        }
    }

    /** @date 4/11/2016
    * @Author Pawel Sprysak
    * @description  Validate/Insert Participant API
    * @return String
    */
    public static String sendParticipantJSON(String jsonString) {
        Savepoint sp = Database.setSavepoint();
        try {
            JsonParticipantWrapper              parsedJSON = parseStringToParticipantWrapper(jsonString);
            String                              fieldError = '';
            String                               errorMsgs = '';
            String                      logisticVendorCode = '';
            String                        validationStatus = '';
            String                              abmEventId = '';
            Map<String, String>              nameToCodeMap = getNameToCodeValues();
            Map<String, Decimal>              partSpendMap = new Map<String, Decimal>();
            Map<String, VDST_EventPrtcpntField_gne__c> roleMap;
            List<VDST_PrtcpntTransaction_gne__c>    ptList;
            Map<Date, VDST_EventPrtcpntAttendance_gne__c> attMap = new Map<Date, VDST_EventPrtcpntAttendance_gne__c>();
            VDST_Address_gne__c             addressData    = new VDST_Address_gne__c(AddressType_gne__c = 'Physical');
            VDST_EventPrtcpntAccnt_gne__c   participant    = new VDST_EventPrtcpntAccnt_gne__c(PartyType_gne__c = 'INDV', VDST_Address_gne__r = addressData);
            VDST_Address_gne__c             orgAddressData = new VDST_Address_gne__c(AddressType_gne__c = 'Physical');
            VDST_EventPrtcpntAccnt_gne__c   organization   = new VDST_EventPrtcpntAccnt_gne__c(PartyType_gne__c = 'ORG', VDST_Address_gne__r = orgAddressData,
                                                                    Credential_gne__c = 'PAIDTO', ParticipantProfession_gne__c = 'PAIDTO',
                                                                    ParticipantContractStatus_gne__c = 'CNTRCTD');

            // ABM Event Id
            fieldError = validateFieldLengthAndRequirement(VDST_Event_gne__c.ABM_EventId_gne__c, parsedJSON.abm_event_id);
            if( !String.isBlank(fieldError) ) {
                errorMsgs += fieldError;
            } else {
                abmEventId = parsedJSON.abm_event_id;
            }
            // ABM Participant Id
            fieldError = validateFieldLengthAndRequirement(VDST_EventPrtcpntAccnt_gne__c.ABM_ParticipantId_gne__c, parsedJSON.abm_participant_id);
            if( !String.isBlank(fieldError) ) {
                errorMsgs += fieldError;
            } else {
                participant.ABM_ParticipantId_gne__c = parsedJSON.abm_participant_id;
            }
            if( !String.isBlank(errorMsgs) ) {
                return 'Missing Participant required fields or incorrect data: <br/>' + errorMsgs;
            }

            // Get Event Data
            List<VDST_Event_gne__c> eventList = [SELECT Id, LogisticVendorCode_gne__c, CurrentStatus_gne__c, CurrentStatusDate_gne__c, ABM_EventId_gne__c,
                                                        (SELECT VDST_Address_gne__r.AddressType_gne__c FROM VDST_Event_Sites__r)
                                                    FROM VDST_Event_gne__c
                                                    WHERE ABM_EventId_gne__c = :parsedJSON.abm_event_id AND IsABMevent_gne__c = true];
            if(eventList.size() < 1) {
                return JSON.serialize(new ErrorWrapper('Event was not found.'));
            } else {
                addressData.VDST_Event_gne__c = eventList.get(0).Id;
                participant.VDST_Event_gne__c = eventList.get(0).Id;
                orgAddressData.VDST_Event_gne__c = eventList.get(0).Id;
                organization.VDST_Event_gne__c = eventList.get(0).Id;
                logisticVendorCode = eventList.get(0).LogisticVendorCode_gne__c;
                validationStatus = eventList.get(0).CurrentStatus_gne__c;

                if(!'CANCEL'.equals(validationStatus) && !'PENDING'.equals(validationStatus)) {
                    validationStatus = 'CLOSED';
                }
            }

            if( parsedJSON.isValidation == null ) {
                parsedJSON.isValidation = true;
            }
            if( parsedJSON.isRemoval == null ) {
                parsedJSON.isRemoval = false;
            }

            // REMOVAL VALIDATION / WORK
            if(parsedJSON.isRemoval) {
                if(parsedJSON.isValidation) {
                    return JSON.serialize(new ErrorWrapper('isValidation flag is not available along with isRemoval flag'));
                }
                Savepoint sp_rem = Database.setSavepoint();
                List<VDST_EventPrtcpntAccnt_gne__c> epaList = [SELECT Id, VDST_Event_gne__r.CurrentStatus_gne__c
                                                                  FROM VDST_EventPrtcpntAccnt_gne__c
                                                                  WHERE ABM_ParticipantId_gne__c = :participant.ABM_ParticipantId_gne__c
                                                                        AND VDST_Event_gne__r.ABM_EventId_gne__c = :abmEventId
                                                                        AND PartyType_gne__c = 'INDV'];
                if(epaList.size() == 1) {
                    // Reopen
                    Boolean reopenClosed = false;
                    Boolean reopenCancelled = false;
                    VDST_Event_gne__c event = eventList.get(0);

                    if( 'CLOSED'.equals(event.CurrentStatus_gne__c) ) {
                        reopenClosed = true;
                    } else if( 'CANCEL'.equals(event.CurrentStatus_gne__c) ) {
                        reopenCancelled = true;
                    }

                    // Event - Re-opening
                    if(reopenClosed) {
                        event.CurrentStatus_gne__c = 'OCCURRED';
                        upsert event ABM_EventId_gne__c;
                    } else if(reopenCancelled) {
                        event.CurrentStatus_gne__c = 'PENDING';
                        upsert event ABM_EventId_gne__c;
                    }

                    // Remove Participant
                    VDST_Utils.deleteParticipant(epaList.get(0).Id);

                    // Validate is ok
                    if( 'CLOSED'.equalsIgnoreCase(validationStatus) ) {
                        List<VDST_EventPrtcpntAccnt_gne__c> epaListAfter = [SELECT Id, VDST_Event_gne__r.CurrentStatus_gne__c
                                                                              FROM VDST_EventPrtcpntAccnt_gne__c
                                                                              WHERE VDST_Event_gne__r.ABM_EventId_gne__c = :parsedJSON.abm_event_id];
                        if(epaListAfter.size() < 1) {
                            Database.rollback(sp_rem);
                            return JSON.serialize(new ErrorWrapper('Last Participant cannot be removed in Occurred/Closed statuses'));
                        }
                    }

                    // Close back
                    if(reopenClosed) {
                        event.CurrentStatus_gne__c = 'CLOSED';
                        upsert event ABM_EventId_gne__c;
                    } else if(reopenCancelled) {
                        event.CurrentStatus_gne__c = 'CANCEL';
                        upsert event ABM_EventId_gne__c;
                    }

                    return 'OK';
                } else {
                    return JSON.serialize(new ErrorWrapper('Participant was not found.'));
                }

                return 'OK';
            }

            // UPSERT VALIDATION / WORK
            // First Name
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.FirstName_gne__c, parsedJSON.first_name, true);
            // Last Name
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.LastName_gne__c, parsedJSON.last_name, true);
            // Participant Role
            if( !String.isBlank(parsedJSON.participant_role) ) {
                if('Chair'.equals(parsedJSON.participant_role)) {
                    parsedJSON.participant_role = 'Chairperson';
                }
                Boolean roleFound = false;
                for(VDST_EventPrtcpntRole_gne__c role: VDST_Utils.getVendorCodeList('ADBOARD')) {
                    if(parsedJSON.participant_role.equals(role.EventParticipantRoleName__c)) {
                        roleFound = true;
                        participant.EventParticipantRole_gne__c = role.Id;
                        roleMap = VDST_Utils.setPrtcpntRoleFieldsMap('ADBOARD').get(role.Id);
                        break;
                    }
                }
                if(!roleFound) {
                    errorMsgs += isRequiredValue(VDST_EventPrtcpntAccnt_gne__c.EventParticipantRole_gne__c, '');
                }
            } else {
                errorMsgs += isRequiredValue(VDST_EventPrtcpntAccnt_gne__c.EventParticipantRole_gne__c, '');
            }

            // Suffix
            if( !String.isBlank(parsedJSON.suffix) ) {
                String suffixValue = getPicklistValue(VDST_EventPrtcpntAccnt_gne__c.Suffix_gne__c, parsedJSON.suffix, nameToCodeMap);
                fieldError = isRequiredValue(VDST_EventPrtcpntAccnt_gne__c.Suffix_gne__c, suffixValue);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else {
                    participant.Suffix_gne__c = suffixValue;
                }
            } else {
                participant.Suffix_gne__c = '';
            }
            // Contracted
            if( parsedJSON.contracted != null ) {
                if(parsedJSON.contracted) {
                    participant.ParticipantContractStatus_gne__c = 'CNTRCTD';
                } else {
                    participant.ParticipantContractStatus_gne__c = 'NTCNTRCTD';
                }
            } else {
                participant.ParticipantContractStatus_gne__c = 'CNTRCTD';
            }
            // Credential
            if( !String.isBlank(parsedJSON.credential) ) {
                Map<String, String> picklistValues = VDST_Utils.getPickListMap(VDST_EventPrtcpntAccnt_gne__c.Credential_gne__c.getDescribe());
                if( picklistValues.get(parsedJSON.credential) != null ) {
                    participant.Credential_gne__c = parsedJSON.credential;
                } else {
                    participant.Credential_gne__c = 'Other';
                }
            } else {
                participant.Credential_gne__c = '';
            }
            // Profession
            if( !String.isBlank(parsedJSON.profession) ) {
                String profValue = getPicklistValue(VDST_EventPrtcpntAccnt_gne__c.ParticipantProfession_gne__c, parsedJSON.profession, nameToCodeMap);
                fieldError = isRequiredValue(VDST_EventPrtcpntAccnt_gne__c.ParticipantProfession_gne__c, profValue);
                if( !String.isBlank(fieldError) ) {
                    participant.ParticipantProfession_gne__c = 'OTH';
                } else {
                    participant.ParticipantProfession_gne__c = profValue;
                }
            } else {
                participant.ParticipantProfession_gne__c = '';
            }
            // Affiliation
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.ParticipantAffiliation_gne__c, parsedJSON.affiliation, false);
            // NPI
            if( !String.isBlank(parsedJSON.npi) ) {
                fieldError = validateField(VDST_EventPrtcpntAccnt_gne__c.NPI_gne__c, parsedJSON.npi);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else {
                    if( checkNPI(parsedJSON.npi) ) {
                        participant.NPI_gne__c = parsedJSON.npi;
                    } else {
                        errorMsgs += 'Incorrect format of NPI field<br/>';
                    }
                }
            } else {
                participant.NPI_gne__c = '';
            }
            // DEA
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.DEA_gne__c, parsedJSON.dea, false);
            // MDM Id
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.MDMID_gne__c, parsedJSON.mdm_id, false);
            // SFDC Id
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.GNE_SFDC_ID_gne__c, parsedJSON.sfdc_id, false);
            // License No
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.LicenseNumber_gne__c, parsedJSON.license_number, false);
            // License State
            if( !String.isBlank(parsedJSON.license_state) ) {
                String licenseStateCode = VDST_Utils.getInverseStatesMap().get(parsedJSON.license_state.toLowerCase());
                fieldError = isRequiredValue(VDST_EventPrtcpntAccnt_gne__c.LicenseState_gne__c, licenseStateCode);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else {
                    participant.LicenseState_gne__c = licenseStateCode;
                }
            } else {
                participant.LicenseState_gne__c = '';
            }
            // License State vs License No
            if( !String.isBlank(participant.LicenseNumber_gne__c) && String.isBlank(participant.LicenseState_gne__c) ) {
                errorMsgs += 'License State is required when License Number is provided<br/>';
            }
            if( String.isBlank(participant.LicenseNumber_gne__c) && !String.isBlank(participant.LicenseState_gne__c) ) {
                errorMsgs += 'License Number is required when License State is provided<br/>';
            }
            // Address - City
            errorMsgs += validateAndSetFieldValue(addressData, VDST_Address_gne__c.City_gne__c, parsedJSON.address_city, false);
            // Address - Street
            errorMsgs += validateAndSetFieldValue(addressData, VDST_Address_gne__c.StreetAddress_gne__c, parsedJSON.address_street, false);
            // Address - Street 2
            errorMsgs += validateAndSetFieldValue(addressData, VDST_Address_gne__c.StreetAddress2_gne__c, parsedJSON.address_street2, false);
            // Address - Country
            if( !String.isBlank(parsedJSON.address_country) ) {
                String countryValue = getPicklistValue(VDST_Address_gne__c.Country_gne__c, parsedJSON.address_country, nameToCodeMap);
                fieldError = isRequiredValue(VDST_Address_gne__c.Country_gne__c, countryValue);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else {
                    addressData.Country_gne__c = countryValue;
                }
            } else {
                addressData.Country_gne__c = '';
            }
            // Address - State
            if( !String.isBlank(parsedJSON.address_state) ) {
                if( 'USA'.equals(addressData.Country_gne__c) ) {
                    String stateCode = VDST_Utils.getInverseStatesMap().get(parsedJSON.address_state.toLowerCase());
                    fieldError = isRequiredValue(VDST_Address_gne__c.StateProvince_gne__c, stateCode);
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    } else {
                        addressData.StatesNameHolder_gne__c = '';
                        addressData.StateProvince_gne__c = stateCode;
                    }
                } else {
                    fieldError = validateField(VDST_Address_gne__c.StatesNameHolder_gne__c, parsedJSON.address_state);
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    } else {
                        addressData.StatesNameHolder_gne__c = parsedJSON.address_state;
                        addressData.StateProvince_gne__c = 'ANY';
                    }
                }
            } else {
                addressData.StatesNameHolder_gne__c = '';
                addressData.StateProvince_gne__c = '';
            }
            // Address - ZIP
            if( !String.isBlank(parsedJSON.address_zip) ) {
                if( checkZipCode(parsedJSON.address_zip, addressData.Country_gne__c) ) {
                    addressData.PostalCode_gne__c = parsedJSON.address_zip;
                } else {
                    errorMsgs += isRequiredValue(VDST_Address_gne__c.PostalCode_gne__c, '');
                }
            } else {
                addressData.PostalCode_gne__c = '';
            }
            // Phone
            errorMsgs += validateAndSetFieldValue(participant, VDST_EventPrtcpntAccnt_gne__c.BusinessPhone_gne__c, parsedJSON.phone, false);
            // Email
            if( !String.isBlank(parsedJSON.email) ) {
                fieldError = validateField(VDST_EventPrtcpntAccnt_gne__c.Email_gne__c, parsedJSON.email);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else if( VDST_Utils.validateEmail(parsedJSON.email) ) {
                    participant.Email_gne__c = parsedJSON.email;
                } else {
                    errorMsgs += 'Incorrect format of Email field<br/>';
                }
            } else {
                participant.Email_gne__c = '';
            }
            // ORGANIZATION
            if(parsedJSON.organization_data != null) {
                if(roleMap == null || roleMap.get('hasFees') == null || roleMap.get('hasFees').IsVisible_gne__c == false) {
                    return JSON.serialize(new ErrorWrapper('Organization not available for provided Participant Role.'));
                }
                // ORGANIZATION - Legal Name
                errorMsgs += validateAndSetFieldValue(organization, VDST_EventPrtcpntAccnt_gne__c.LegalName_gne__c, parsedJSON.organization_data.org_name, true);
                // ORGANIZATION - TIN
                fieldError = validateFieldLengthAndRequirement(VDST_EventPrtcpntAccnt_gne__c.TIN_gne__c, parsedJSON.organization_data.tin);
                if( !String.isBlank(fieldError) ) {
                    errorMsgs += fieldError;
                } else {
                    if( checkTIN(parsedJSON.organization_data.tin) ) {
                        organization.TIN_gne__c = parsedJSON.organization_data.tin;
                    } else {
                        errorMsgs += 'Incorrect format of Organization TIN field<br/>';
                    }
                }
                // ORGANIZATION - NPI
                if( !String.isBlank(parsedJSON.organization_data.npi) ) {
                    fieldError = validateField(VDST_EventPrtcpntAccnt_gne__c.NPI_gne__c, parsedJSON.organization_data.npi);
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    } else {
                        if( checkNPI(parsedJSON.organization_data.npi) ) {
                            organization.NPI_gne__c = parsedJSON.organization_data.npi;
                        } else {
                            errorMsgs += 'Incorrect format of Organization NPI field<br/>';
                        }
                    }
                } else {
                    organization.NPI_gne__c = '';
                }
                // ORGANIZATION - DEA
                errorMsgs += validateAndSetFieldValue(organization, VDST_EventPrtcpntAccnt_gne__c.DEA_gne__c, String.valueOf(parsedJSON.organization_data.dea), parsedJSON.organization_data.dea, false);
                // MDM ID
                errorMsgs += validateAndSetFieldValue(organization, VDST_EventPrtcpntAccnt_gne__c.MDMID_gne__c, parsedJSON.organization_data.mdm_id, false);
                // ORGANIZATION - Charitable Org
                if( parsedJSON.organization_data.charitable_org != null ) {
                    organization.Charitable_Organization_gne__c = parsedJSON.organization_data.charitable_org;
                } else {
                    organization.Charitable_Organization_gne__c = false;
                }
                // ORGANIZATION - Address Street
                errorMsgs += validateAndSetFieldValue(orgAddressData, VDST_Address_gne__c.StreetAddress_gne__c, parsedJSON.organization_data.address_street, true);
                // ORGANIZATION - Address City
                errorMsgs += validateAndSetFieldValue(orgAddressData, VDST_Address_gne__c.City_gne__c, parsedJSON.organization_data.address_city, true);
                // ORGANIZATION - Address Country
                if( !String.isBlank(parsedJSON.organization_data.address_country) ) {
                    String countryValue = getPicklistValue(VDST_Address_gne__c.Country_gne__c, parsedJSON.organization_data.address_country, nameToCodeMap);
                    fieldError = isRequiredValue(VDST_Address_gne__c.Country_gne__c, countryValue);
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    } else {
                        orgAddressData.Country_gne__c = countryValue;
                    }
                } else {
                    errorMsgs += isRequiredValue(VDST_Address_gne__c.Country_gne__c, '');
                }
                // ORGANIZATION - Address State
                if( !String.isBlank(parsedJSON.organization_data.address_state) ) {
                    if( 'USA'.equals(orgAddressData.Country_gne__c) ) {
                        String stateCode = VDST_Utils.getInverseStatesMap().get(parsedJSON.organization_data.address_state.toLowerCase());
                        fieldError = isRequiredValue(VDST_Address_gne__c.StateProvince_gne__c, stateCode);
                        if( !String.isBlank(fieldError) ) {
                            errorMsgs += fieldError;
                        } else {
                            orgAddressData.StatesNameHolder_gne__c = '';
                            orgAddressData.StateProvince_gne__c = stateCode;
                        }
                    } else {
                        fieldError = validateField(VDST_Address_gne__c.StateProvince_gne__c, parsedJSON.organization_data.address_state);
                        if( !String.isBlank(fieldError) ) {
                            errorMsgs += fieldError;
                        } else {
                            orgAddressData.StatesNameHolder_gne__c = parsedJSON.organization_data.address_state;
                            orgAddressData.StateProvince_gne__c = 'ANY';
                        }
                    }
                } else {
                    errorMsgs += isRequiredValue(VDST_Address_gne__c.StateProvince_gne__c, '');
                }
                // ORGANIZATION - Address ZIP
                if( !String.isBlank(parsedJSON.organization_data.address_zip) ) {
                    if( checkZipCode(parsedJSON.organization_data.address_zip, orgAddressData.Country_gne__c) ) {
                        orgAddressData.PostalCode_gne__c = parsedJSON.organization_data.address_zip;
                    } else {
                        errorMsgs += isRequiredValue(VDST_Address_gne__c.PostalCode_gne__c, '');
                    }
                } else {
                    errorMsgs += isRequiredValue(VDST_Address_gne__c.PostalCode_gne__c, '');
                }
            }
            // Spend format validation
            Boolean hasTravelAndLodgingExpenses = false;
            if( parsedJSON.participant_spends != null ) {
                if(roleMap == null || roleMap.get('hasTrans') == null || roleMap.get('hasTrans').IsVisible_gne__c == false) {
                    return JSON.serialize(new ErrorWrapper('Spend data not available for provided Participant Role.'));
                }
                for(ParticipantSpends ps: parsedJSON.participant_spends) {
                    if( 'HCP Travel'.equalsIgnoreCase(ps.code) || 'HCPTRVL'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'HCPTRVL';
                        if(ps.amount > 0) {
                            hasTravelAndLodgingExpenses = true;
                        }
                    } else if( 'HCP Lodging'.equalsIgnoreCase(ps.code) || 'HCPLODGNG'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'HCPLODGNG';
                        if(ps.amount > 0) {
                            hasTravelAndLodgingExpenses = true;
                        }
                    } else if( 'HCP Fees'.equalsIgnoreCase(ps.code) || 'HONORARIA'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'HONORARIA';
                    } else if( 'OOP HCP Travel'.equalsIgnoreCase(ps.code) || 'OOPTRVL'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'OOPTRVL';
                        if(ps.amount > 0) {
                            hasTravelAndLodgingExpenses = true;
                        }
                    } else if( 'OOP HCP Lodging'.equalsIgnoreCase(ps.code) || 'OOPLODGNG'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'OOPLODGNG';
                        if(ps.amount > 0) {
                            hasTravelAndLodgingExpenses = true;
                        }
                    } else if( 'OOP HCP Meals'.equalsIgnoreCase(ps.code) || 'OOPMEALS'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'OOPMEALS';
                    } else if( 'OOP HCP Other'.equalsIgnoreCase(ps.code) || 'OOPOTHR'.equalsIgnoreCase(ps.code) ) {
                        ps.code = 'OOPOTHR';
                    } else {
                        errorMsgs += ps.code + ' is incorrect Participant Transaction Code<br/>';
                    }
                    fieldError = validateField(VDST_Event_gne__c.TotalAudioVisual_gne__c, String.valueOf(ps.amount) );
                    if( !String.isBlank(fieldError) ) {
                        errorMsgs += fieldError;
                    }
                    partSpendMap.put(ps.code, ps.amount);
                }
            }
            // Attandance format validation
            if( parsedJSON.att_data != null ) {
                for(AttData ad: parsedJSON.att_data) {
                    // Attandance
                    if( 'ATND'.equalsIgnoreCase(ad.att_status) || 'TRUE'.equalsIgnoreCase(ad.att_status)) {
                        ad.att_status = 'ATND';
                    } else if( 'DNS'.equalsIgnoreCase(ad.att_status) || 'FALSE'.equalsIgnoreCase(ad.att_status) ) {
                        ad.att_status = 'DNS';
                    } else {
                        errorMsgs += ad.att_status + ' is incorrect Attandance Code<br/>';
                    }
                    // Consumption
                    if( 'CONSUMED'.equalsIgnoreCase(ad.consumption_status) || 'Consumed'.equalsIgnoreCase(ad.consumption_status)) {
                        ad.consumption_status = 'CONSUMED';
                    } else if( 'OPTEDOUT'.equalsIgnoreCase(ad.consumption_status) || 'Opted Out'.equalsIgnoreCase(ad.consumption_status) ) {
                        ad.consumption_status = 'OPTEDOUT';
                    } else if( 'NOMLPRVD'.equalsIgnoreCase(ad.consumption_status) || 'No Meal Provided'.equalsIgnoreCase(ad.consumption_status) ) {
                        ad.consumption_status = 'NOMLPRVD';
                    } else if( 'NOTAPPLI'.equalsIgnoreCase(ad.consumption_status) || 'Not Applicable'.equalsIgnoreCase(ad.consumption_status) ) {
                        ad.consumption_status = 'NOTAPPLI';
                    } else {
                        errorMsgs += ad.consumption_status + ' is incorrect Participant Meal Consumption Status Code<br/>';
                    }
                    // Event Date
                    errorMsgs += isRequiredValue(VDST_EventDate_gne__c.EventDate_gne__c, String.valueOf(ad.event_date) );
                    // Attandance Map
                    if(ad.event_date != null) {
                        attMap.put(ad.event_date, new VDST_EventPrtcpntAttendance_gne__c(ParticipantMealConsumptionStatus_gne__c = ad.consumption_status, AttendanceStatus_gne__c = ad.att_status) );
                    }
                }
            }
            // hasTravelAndLodgingExpenses - extra validation
            if(hasTravelAndLodgingExpenses) {
                VDST_EventSite_gne__c siteObject = [SELECT EventSiteName_gne__c, VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.Country_gne__c, VDST_Address_gne__r.PostalCode_gne__c, VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.StreetAddress_gne__c
                                                       FROM VDST_EventSite_gne__c
                                                       WHERE VDST_Event_gne__r.ABM_EventId_gne__c = :abmEventId];
                VDST_Address_gne__c venueObject = new VDST_Address_gne__c(City_gne__c = siteObject.VDST_Address_gne__r.City_gne__c, Country_gne__c = siteObject.VDST_Address_gne__r.Country_gne__c,
                                                       PostalCode_gne__c = siteObject.VDST_Address_gne__r.PostalCode_gne__c, StateProvince_gne__c = siteObject.VDST_Address_gne__r.StateProvince_gne__c,
                                                       StreetAddress_gne__c = siteObject.VDST_Address_gne__r.StreetAddress_gne__c );
                errorMsgs += VDST_Validator.validateEventAddress('Travel and Lodging spends.', false, venueObject, siteObject);
            }

            // If first step validation is valid then do second step validation
            if( !String.isBlank(errorMsgs) ) {
                return 'Missing Participant required fields or incorrect data: <br/>' + errorMsgs;
            } else {
                ptList = [SELECT TransactionAllocationType_gne__c, TransactionAmount_gne__c, TransactionTypeCode_gne__c,
                                       FeePayToPartyType_gne__c, VDST_PaidToParty_gne__c, VDST_EventPrtcpntAccnt_gne__r.VDST_Address_gne__c,
                                       VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.ABM_EventId_gne__c, VDST_EventPrtcpntAccnt_gne__r.VendorParticipantID_gne__c
                                    FROM VDST_PrtcpntTransaction_gne__c
                                    WHERE VDST_EventPrtcpntAccnt_gne__r.ABM_ParticipantId_gne__c = :participant.ABM_ParticipantId_gne__c
                                        OR VDST_PaidToParty_gne__r.ABM_ParticipantId_gne__c = :participant.ABM_ParticipantId_gne__c];
                for(VDST_PrtcpntTransaction_gne__c pt: ptList) {
                    if('ORG'.equals(pt.FeePayToPartyType_gne__c)) {
                        organization.VendorParticipantID_gne__c = pt.VDST_EventPrtcpntAccnt_gne__r.VendorParticipantID_gne__c;
                        organization.Id = pt.VDST_EventPrtcpntAccnt_gne__c;
                    } else {
                        participant.VendorParticipantID_gne__c = pt.VDST_EventPrtcpntAccnt_gne__r.VendorParticipantID_gne__c;
                        participant.Id = pt.VDST_EventPrtcpntAccnt_gne__c;
                    }
                }
                if( !'PENDING'.equals(eventList.get(0).CurrentStatus_gne__c) ) {
                    VDST_Validator.ParticipantsValidationInput input = new VDST_Validator.ParticipantsValidationInput();
                    input.status = validationStatus;
                    input.prtcpntFieldMap = null;
                    input.eventCreateObject = new VDST_Event_gne__c();
                    input.eventCreateObject.Id = participant.VDST_Event_gne__c;
                    VDST_EventDetailCommon commonUtils = new VDST_EventDetailCommon('ADBOARD');
                    List<VDST_EventPrtcpntAccnt_gne__c> participants = new List<VDST_EventPrtcpntAccnt_gne__c>{participant};
                    List<VDST_EventPrtcpntAccnt_gne__c> participantsWithOrgs = new List<VDST_EventPrtcpntAccnt_gne__c>{participant, organization};
                    // Do validation
                    VDST_Validator.ParticipantsValidationOutput output = VDST_Validator.validateParticipantsOnStatusChange('ADBOARD', logisticVendorCode, input,
                                                   participants, participantsWithOrgs, commonUtils.eventRolesMapById);
                    errorMsgs += output.editErrorMessages;
                }
            }
            if( !String.isBlank(errorMsgs) ) {
                return errorMsgs;
            }

            if( !parsedJSON.isValidation ) {
                Boolean reopenClosed = false;
                Boolean reopenCancelled = false;
                VDST_Event_gne__c event = eventList.get(0);

                if( 'CLOSED'.equals(event.CurrentStatus_gne__c) ) {
                    reopenClosed = true;
                } else if( 'CANCEL'.equals(event.CurrentStatus_gne__c) ) {
                    reopenCancelled = true;
                }

                // Event - Re-opening
                if(reopenClosed) {
                    event.CurrentStatus_gne__c = 'OCCURRED';
                    upsert event ABM_EventId_gne__c;
                } else if(reopenCancelled) {
                    event.CurrentStatus_gne__c = 'PENDING';
                    upsert event ABM_EventId_gne__c;
                }

                // Set existing values
                Boolean orgFound = false;
                Boolean orgDelete = false;
                List<VDST_PrtcpntTransaction_gne__c> participantTransactions = new List<VDST_PrtcpntTransaction_gne__c>();
                // Update values for existing transactions
                for(VDST_PrtcpntTransaction_gne__c pt: ptList) {
                    if('ORG'.equals(pt.FeePayToPartyType_gne__c)) {
                        orgFound = true;
                        organization.Id = pt.VDST_EventPrtcpntAccnt_gne__c;
                        orgAddressData.Id = pt.VDST_EventPrtcpntAccnt_gne__r.VDST_Address_gne__c;
                    } else {
                        if( ! abmEventId.equals(pt.VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__r.ABM_EventId_gne__c) ) {
                            return JSON.serialize(new ErrorWrapper('ABM Event Id is not matched with provided ABM Participant Id.<br/>'));
                        }
                        participant.Id = pt.VDST_EventPrtcpntAccnt_gne__c;
                        addressData.Id = pt.VDST_EventPrtcpntAccnt_gne__r.VDST_Address_gne__c;
                    }
                    if( partSpendMap.get(pt.TransactionTypeCode_gne__c) != null ) {
                        pt.TransactionAmount_gne__c = partSpendMap.get(pt.TransactionTypeCode_gne__c);
                    } else {
                        pt.TransactionAmount_gne__c = 0;
                    }
                    if(! ('ORG'.equals(pt.FeePayToPartyType_gne__c) && String.isBlank(organization.LegalName_gne__c)) ) {
                        participantTransactions.add(pt);
                    } else if( 'ORG'.equals(pt.FeePayToPartyType_gne__c) && String.isBlank(organization.LegalName_gne__c) ) {
                        orgDelete = true;
                    }
                }
                // Add to DB - Participant + Organization
                upsert addressData;
                participant.VDST_Address_gne__c = addressData.Id;
                upsert participant;
                if( String.isBlank(organization.LegalName_gne__c) && organization.Id != null ) {
                    delete orgAddressData;
                    delete organization;
                } else if( ! String.isBlank(organization.LegalName_gne__c) ) {
                    upsert orgAddressData;
                    organization.VDST_Address_gne__c = orgAddressData.Id;
                    upsert organization;
                }
                // Create new transactions if new records
                if(participantTransactions.size() < 1) {
                    for(String code : VDST_Utils.EVENT_ADBOAD_TRANSACTIONS) {
                        Decimal transactionAmount = 0;
                        if( partSpendMap.get(code) != null ) {
                            transactionAmount = partSpendMap.get(code);
                        }
                        VDST_PrtcpntTransaction_gne__c prtPT = new VDST_PrtcpntTransaction_gne__c(
                               TransactionAmount_gne__c = transactionAmount,
                               TransactionLevel_gne__c = 'INDV',
                               TransactionTypeCode_gne__c = code,
                               TransactionAllocationType_gne__c = 'DIRECT',
                               FeePayToPartyType_gne__c = 'INDV',
                               VDST_EventPrtcpntAccnt_gne__c = participant.Id,
                               VDST_PaidToParty_gne__c = participant.Id
                        );
                        if( 'HONORARIA'.equals(code) && !String.isBlank(organization.LegalName_gne__c) ) {
                            prtPT.TransactionAllocationType_gne__c = 'INDIRECT';
                            prtPT.VDST_PaidToParty_gne__c = organization.Id;
                            participantTransactions.add(
                               new VDST_PrtcpntTransaction_gne__c(
                                   TransactionAmount_gne__c = transactionAmount,
                                   TransactionLevel_gne__c = 'INDV',
                                   TransactionTypeCode_gne__c = code,
                                   TransactionAllocationType_gne__c = 'DIRECT',
                                   FeePayToPartyType_gne__c = 'ORG',
                                   VDST_EventPrtcpntAccnt_gne__c = organization.Id,
                                   VDST_PaidToParty_gne__c = participant.Id)
                            );
                        }
                        participantTransactions.add(prtPT);
                    }
                // Create Organization transaction if other already exist
                } else if(!orgFound && !String.isBlank(organization.LegalName_gne__c)) {
                    Decimal transactionAmount = 0;
                    if( partSpendMap.get('HONORARIA') != null ) {
                        transactionAmount = partSpendMap.get('HONORARIA');
                    }
                    participantTransactions.add(
                       new VDST_PrtcpntTransaction_gne__c(
                           TransactionAmount_gne__c = transactionAmount,
                           TransactionLevel_gne__c = 'INDV',
                           TransactionTypeCode_gne__c = 'HONORARIA',
                           TransactionAllocationType_gne__c = 'DIRECT',
                           FeePayToPartyType_gne__c = 'ORG',
                           VDST_EventPrtcpntAccnt_gne__c = organization.Id,
                           VDST_PaidToParty_gne__c = participant.Id)
                    );
                    for(VDST_PrtcpntTransaction_gne__c pt : participantTransactions) {
                        if('HONORARIA'.equals(pt.TransactionTypeCode_gne__c) && 'INDV'.equals(pt.FeePayToPartyType_gne__c) ) {
                            pt.TransactionAllocationType_gne__c = 'INDIRECT';
                            pt.VDST_PaidToParty_gne__c = organization.Id;
                        }
                    }
                }
                if(orgDelete) {
                    for(VDST_PrtcpntTransaction_gne__c pt: participantTransactions) {
                        pt.VDST_PaidToParty_gne__c = participant.Id;
                        pt.TransactionAllocationType_gne__c = 'DIRECT';
                    }
                }
                upsert participantTransactions;

                List<VDST_EventPrtcpntAttendance_gne__c> attList = [SELECT Id, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, VDST_EventDate_gne__r.EventDate_gne__c
                                                                        FROM VDST_EventPrtcpntAttendance_gne__c
                                                                        WHERE Event_PrtcpntAccnt_gne__c = :participant.Id];
                for(VDST_EventPrtcpntAttendance_gne__c att: attList) {
                    if( attMap.get(att.VDST_EventDate_gne__r.EventDate_gne__c) != null ) {
                        att.AttendanceStatus_gne__c = attMap.get(att.VDST_EventDate_gne__r.EventDate_gne__c).AttendanceStatus_gne__c;
                        att.ParticipantMealConsumptionStatus_gne__c = attMap.get(att.VDST_EventDate_gne__r.EventDate_gne__c).ParticipantMealConsumptionStatus_gne__c;
                    } else {
                        att.AttendanceStatus_gne__c = 'ATND';
                        att.ParticipantMealConsumptionStatus_gne__c = 'CONSUMED';
                    }
                }
                update attList;

                // Event - Closing back
                if(reopenClosed) {
                    event.CurrentStatus_gne__c = 'CLOSED';
                    upsert event ABM_EventId_gne__c;
                } else if(reopenCancelled) {
                    event.CurrentStatus_gne__c = 'CANCEL';
                    upsert event ABM_EventId_gne__c;
                }

                return 'OK';
            }
            return 'OK';
        } catch (Exception ex) {
            Database.rollback(sp);
            return JSON.serialize(new ErrorWrapper('Error while creating/updating Participant data: ' + ex.getMessage()));
        }
    }

    // Event Participant Wrapper
    virtual class JsonParticipantReadWrapper {
        // Read/Write fields
        String                   abm_participant_id { get; set; }
        OrganizationData          organization_data { get; set; }
        List<ParticipantSpends>  participant_spends { get; set; }
        List<AttData>                      att_data { get; set; }
        Boolean                          contracted { get; set; }
    }

    // Event Participant Wrapper
    class JsonParticipantWrapper extends JsonParticipantReadWrapper {
        // Flags
        Boolean                        isValidation { get; set; }
        Boolean                           isRemoval { get; set; }
        String                         abm_event_id { get; set; }
        // Create/Update data
        String                           first_name { get; set; }
        String                            last_name { get; set; }
        String                     participant_role { get; set; }
        String                               suffix { get; set; }
        String                           credential { get; set; }
        String                           profession { get; set; }
        String                          affiliation { get; set; }
        String                                  npi { get; set; }
        String                                  dea { get; set; }
        String                       license_number { get; set; }
        String                        license_state { get; set; }
        String                      address_country { get; set; }
        String                       address_street { get; set; }
        String                      address_street2 { get; set; }
        String                         address_city { get; set; }
        String                        address_state { get; set; }
        String                          address_zip { get; set; }
        String                                phone { get; set; }
        String                                email { get; set; }
        String                               mdm_id { get; set; }
        String                              sfdc_id { get; set; }
    }

    class ParticipantSpends {
        String                                 code { get; set; }
        Decimal                              amount { get; set; }
    }

    class OrganizationData {
        transient String            for_participant { get; set; }
        String                             org_name { get; set; }
        String                                  tin { get; set; }
        Boolean                      charitable_org { get; set; }
        String                                  npi { get; set; }
        String                                  dea { get; set; }
        String                               mdm_id { get; set; }
        String                      address_country { get; set; }
        String                       address_street { get; set; }
        String                         address_city { get; set; }
        String                        address_state { get; set; }
        String                          address_zip { get; set; }
    }

    class AttData {
        String                           att_status { get; set; }
        String                   consumption_status { get; set; }
        Decimal                         meal_amount { get; set; }
        Date                             event_date { get; set; }
    }

    private static JsonParticipantWrapper parseStringToParticipantWrapper(String jsonString){
        return (JsonParticipantWrapper) System.JSON.deserialize(jsonString, JsonParticipantWrapper.class);
    }

/*////////*/
/* COMMON */
/*////////*/

    public static Map<String, String> getCountryValues() {
        Map<String, String> picklistValues = VDST_Utils.getPickListMap(VDST_Address_gne__c.Country_gne__c.getDescribe());
        Map<String, String> mappingValues = getCodeToNameValues();
        for( String key: picklistValues.keySet() ) {
            picklistValues.put(key, mappingValues.get(key) );
        }
        return picklistValues;
    }

    public static Map<String, String> getStateValues() {
        return VDST_Utils.getStatesMap();
    }

    // Error Wrapper
    private class ErrorWrapper {
        private String errorMsg { get; set; }
        /*
         * Constructs newly allocated error with given message.
         */
        private ErrorWrapper(final String err) {
            errorMsg = err;
        }
    }

    private static String validateAndSetFieldValue(sObject myObject, sObjectField objectField, String fieldValue, Boolean isRequired) {
        return validateAndSetFieldValue(myObject, objectField, fieldValue, fieldValue, isRequired);
    }

    private static String validateAndSetFieldValue(sObject myObject, sObjectField objectField, String fieldValue, Object value, Boolean isRequired) {
        String fieldError = '';
        if(isRequired) {
            fieldError = validateFieldLengthAndRequirement(objectField, fieldValue);
        } else {
            fieldError = validateField(objectField, fieldValue);
        }
        if( !String.isBlank(fieldError) ) {
           return fieldError;
        } else {
            myObject.put(objectField.getDescribe().getSobjectField(), value);
            return '';
        }
    }

    private static String validateField(sObjectField objectField, String fieldValue) {
        if(objectField != null && fieldValue != null) {
            if( 'STRING'.equals(String.valueOf(objectField.getDescribe().getType())) || 'TEXTAREA'.equals(String.valueOf(objectField.getDescribe().getType())) ) {
                if( fieldValue.length() > objectField.getDescribe().getLength() ) {
                    return 'Field value is longer than field length. Field: ' + objectField.getDescribe().getLabel() + ' (Length: ' + objectField.getDescribe().getLength() + ')<br/>';
                }
            } else if ( 'CURRENCY'.equals(String.valueOf(objectField.getDescribe().getType())) ) {
                if( fieldValue.split('\\.').get(0).length() > (objectField.getDescribe().getPrecision() - objectField.getDescribe().getScale()) ) {
                    return 'Field value is longer than field length. Field: ' + objectField.getDescribe().getLabel() + ' (Length: ' + (objectField.getDescribe().getPrecision()-objectField.getDescribe().getScale()) + ')<br/>';
                }
            } else if ( 'DOUBLE'.equals(String.valueOf(objectField.getDescribe().getType())) ) {
                if( fieldValue.length() > objectField.getDescribe().getPrecision() ) {
                    return 'Field value is longer than field length. Field: ' + objectField.getDescribe().getLabel() + ' (Length: ' + objectField.getDescribe().getPrecision() + ')<br/>';
                }
            }
        }
        return '';
    }

    private static String validateFieldLengthAndRequirement(sObjectField objectField, String fieldValue) {
        String errorMsg1 = validateField(objectField, fieldValue);
        String errorMsg2 = isRequiredValue(objectField, fieldValue);
        if( !String.isBlank(errorMsg1) && !String.isBlank(errorMsg2) ) {
            return errorMsg1 + '<br/>' + errorMsg2;
        }
        return errorMsg1 + errorMsg2;
    }

    private static Map<String, String> getNameToCodeValues() {
        Map<String, String> nameToCodeMap = new Map<String, String>();
        for(VDST_Mapping_gne__c mapValue : VDST_Mapping_gne__c.getAll().values()) {
            nameToCodeMap.put(mapValue.LabelValue_gne__c, mapValue.Name);
        }
        return nameToCodeMap;
    }

    private static Map<String, String> getCodeToNameValues() {
        Map<String, String> nameToCodeMap = new Map<String, String>();
        for(VDST_Mapping_gne__c mapValue : VDST_Mapping_gne__c.getAll().values()) {
            nameToCodeMap.put(mapValue.Name, mapValue.LabelValue_gne__c);
        }
        return nameToCodeMap;
    }

    private static String getPicklistValue(sObjectField objectField, String fieldValue, Map<String, String> nameToCodeMap) {
        final Map<String, String> picklistValues = normalizeMap(VDST_Utils.getPickListMap(objectField.getDescribe()));
        if (fieldValue != null && picklistValues.get(fieldValue.toLowerCase()) != null) {
            return picklistValues.get(fieldValue.toLowerCase());
        }
        final String codeValue = fieldValue == null ? null : normalizeMap(nameToCodeMap).get(fieldValue.toLowerCase());
        if (codeValue != null && picklistValues.get(codeValue) != null) {
            return picklistValues.get(codeValue);
        }
        return '';
    }

    private static String isRequiredValue(sObjectField objectField, String fieldValue) {
        if( String.isBlank(fieldValue) ) {
            return objectField.getDescribe().getLabel() + ' field missing or incorrect format<br/>';
        }
        return '';
    }

    private static Map<String, String> normalizeMap(final Map<String, String> values) {
        for (String key : values.keySet()) {
            values.put(key.toLowerCase(), values.get(key));
        }
        return values;
    }

    private static Boolean checkZipCode(String zipcodetocheck, String country) {
        Boolean zipOk = false;
        if((country == 'USA' || country == 'PRI') && Pattern.matches('^[0-9]{5}||[0-9]{5}-{1}[0-9]{4}$', zipcodetocheck)) {
            zipOk = true;
        } else if((country != 'USA' && country != 'PRI') && Pattern.matches('^[0-9a-zA-Z\\-\\s]+$', zipcodetocheck) ) {
            zipOk = true;
        }
        return zipOk;
    }

    public static Boolean checkNPI(String npiToCheck) {
        Boolean npiOk = false;
        if(Pattern.matches('^[0-9]{10}$', npiToCheck)) {
            npiOk = true;
        }
        return npiOk;
    }

    public static Boolean checkTIN(String tinToCheck){
        Boolean tinOk = false;
        if(Pattern.matches('^[0-9]{2}-[0-9]{7}$', tinToCheck)) {
            tinOk = true;
        }
        return tinOk;
    }
}