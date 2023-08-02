/** @date 3/28/2016
* @Author Pawel Sprysak
* @description Class for validating data
*/
public without sharing class VDST_Validator {
/*/////////////*/
/*/// EVENT ///*/
/*/////////////*/

    /** @date 3/31/2016
    * @Author Pawel Sprysak
    * @description Method for validating Event data
    * @param String eventType                                                 > Event Type
    * @param String vendorLoggedVal                                           > Logistic Vendor Code
    * @param Map<String, Map<String, VDST_EventField_gne__c>> statusFieldMap  > Fields validation rules (Set null if not available / AdBoard API)
    * @param String status                                                    > Validation status
    * @param VDST_Event_gne__c eventCreateObject                              > Event Data
    * @param VDST_EventSite_gne__c siteObject                                 > Event Site Data
    * @param VDST_Address_gne__c venueObject                                  > Event Address Data
    * @param String newDrugNames                                              > Drug list (comma separated) 
    * @param List<VDST_EventTransactionSummary_gne__c> etsSummary             > Transaction Summary Data (Set null if not available / AdBoard API)
    * @param Boolean hasTravelAndLodgingExpenses                              > Travel and Lodging greater than zero
    * @param List<VDST_Utils.EventDateTransactions> evDateTransList           > Daily Meal Data
    * @return String (Error message)
    */
    public static String validateEventOnStatusChange(String eventType, String vendorLoggedVal, Map<String, Map<String, VDST_EventField_gne__c>> statusFieldMap,   
                                                String status, VDST_Event_gne__c eventCreateObject, VDST_EventSite_gne__c siteObject, VDST_Address_gne__c venueObject, 
                                                String newDrugNames, List<VDST_EventTransactionSummary_gne__c> etsSummary, Boolean hasTravelAndLodgingExpenses,
                                                List<VDST_Utils.EventDateTransactions> evDateTransList) {
        try {
            String errorMsg = '';
            // Primary check
            if( String.isBlank(eventType) || String.isBlank(vendorLoggedVal) || String.isBlank(status)
                || eventCreateObject == null || siteObject == null || venueObject == null || hasTravelAndLodgingExpenses == null ) {
                return 'Event validation - configuration error';
            }
            // Validation Rules for event in Occurred/Closed status
            if( !VDST_Utils.EVENT_STATUS_CANCEL.equals(status) ) {
                if(statusFieldMap == null) {
                    statusFieldMap = VDST_Utils.setStatusFieldsMap(eventType);
                }
                Map<String, VDST_EventField_gne__c> actualMap = statusFieldMap.get(status);
                errorMsg += validateEventRequiredFields(actualMap.values(), eventCreateObject, siteObject, venueObject);
                if(VDST_Utils.EVENT_STATUS_CLOSED.equals(status) && !isValidBrands(newDrugNames)) {
                    errorMsg += ' - Brand(s)<br/>';
                }
                if(etsSummary == null || etsSummary.size() < 1){
                    if( VDST_Utils.isSSEventType(eventType) || VDST_Utils.isNonResearchEventType(eventType) || VDST_Utils.isResearchEventType(eventType) ) {
                        etsSummary = VDST_Utils.getTotalSummaryTransactions(eventCreateObject.Id);
                        if(etsSummary == null || etsSummary.size() < 1 || etsSummary.get(0).VDST_Event_gne__r.ItemAmount_gne__c == 0) {
                            errorMsg += ' - In Event must be at least one Expense Amount greater than zero (0.00)<br/>';
                        }
                    }
                } else if ( etsSummary != null && VDST_Utils.isNonResearchEventType(eventType) ) {
                    if(etsSummary.size() > 0 && (etsSummary.get(0).VDST_Event_gne__r.ItemAmount_gne__c - etsSummary.get(0).EventTransactionAmount_gne__c) != 0) {
                        errorMsg += ' - In Event the Source Amount Balance must be zero (0.00) in order to Submit the Event/Payment<br/>';
                    }
                }
                if( VDST_Utils.EVENT_STATUS_CLOSED.equals(status) && VDST_Utils.isNewStdEventType(eventType) ) {
                    errorMsg += validateNumberOfMeals(evDateTransList);
                }
            // Validation Rules for event in Cancel status
            } else if( VDST_Utils.EVENT_STATUS_CANCEL.equals(status) && VDST_Utils.isNewStdEventType(eventType) ) {
                if(hasTravelAndLodgingExpenses) {
                    errorMsg += validateEventAddress('Travel and Lodging spends.', false, venueObject, siteObject);
                }
                errorMsg += validateNumberOfMeals(evDateTransList);
            }
            // Additional validation Rules
            String editErrorMessages = '';
            if(!''.equals(errorMsg)) {
                editErrorMessages = 'Missing Event required fields or incorrect data: <br/>' + errorMsg;
            }
            // Validate Vendor Event Id
            if(!String.isBlank(eventCreateObject.VendorEventID_gne__c) && !VDST_Utils.isVendorEventIdUnique(vendorLoggedVal, eventCreateObject.VendorEventID_gne__c, eventCreateObject.Id)) {
                editErrorMessages = 'Vendor Event Id value must be unique </br>' + editErrorMessages;
            }
            if(!''.equals(editErrorMessages)) {
                return editErrorMessages;
            } else {
                if(!generateVendorEventId(eventCreateObject, vendorLoggedVal)) {
                    editErrorMessages = 'Vendor Event Id is not unique.';
                    return editErrorMessages;
                }
            }
            return editErrorMessages;
        } catch (Exception ex) {
            return 'Event validation - exception: ' + ex.getMessage();
        }
    }

     /** @date 3/31/2016
    * @Author Pawel Sprysak
    * @description Method for validating Event Required fields
    * @param List<VDST_EventField_gne__c> efList
    * @param VDST_Event_gne__c eventCreateObject
    * @param VDST_EventSite_gne__c siteObject
    * @param VDST_Address_gne__c venueObject
    * @return String
    */
    private static String validateEventRequiredFields(List<VDST_EventField_gne__c> efList, VDST_Event_gne__c eventCreateObject, VDST_EventSite_gne__c siteObject, VDST_Address_gne__c venueObject) {
        String errorMsg = '';
        for(VDST_EventField_gne__c eventFieldDetails : efList) {
            if(eventFieldDetails.IsRequired_gne__c == true) {
                try {
                    Boolean hasAddress = eventFieldDetails.FieldName_gne__c.contains('VDST_Address_gne.');
                    Boolean hasSite = eventFieldDetails.FieldName_gne__c.contains('VDST_EventSite_gne.');
                    String addressFieldValue, siteFieldValue;
                    Boolean isNonUsaStateEmpty = false;
                    if(hasAddress) {
                        String fullAddressFieldName = eventFieldDetails.FieldName_gne__c.removeStart('VDST_Address_gne.') + '__c';
                        addressFieldValue = String.valueOf( venueObject.get(fullAddressFieldName) );
                        isNonUsaStateEmpty= (
                            !'USA'.equals(venueObject.Country_gne__c) &&
                            'StateProvince_gne__c'.equals(fullAddressFieldName) &&
                            String.isBlank(venueObject.StatesNameHolder_gne__c)
                        );
                    }
                    if(hasSite) {
                        siteFieldValue = String.valueOf(siteObject.get(eventFieldDetails.FieldName_gne__c.removeStart('VDST_EventSite_gne.') + '__c') );
                    }
                    if( hasAddress && ( String.isBlank( addressFieldValue ) || isNonUsaStateEmpty ) ) {
                        errorMsg += ' - In Event Address: ' + eventFieldDetails.FieldLabel_gne__c + '<br/>';
                    } else if( hasSite && String.isBlank( siteFieldValue ) ) {
                        errorMsg += ' - In Event Address: ' + eventFieldDetails.FieldLabel_gne__c + '<br/>';
                    } else if(!hasAddress && !hasSite) {
                        String fieldValue = String.valueOf( eventCreateObject.get(eventFieldDetails.FieldName_gne__c + '__c') );
                        if( String.IsBlank(fieldValue) ) {
                           errorMsg += ' - In Event: ' + eventFieldDetails.FieldLabel_gne__c + '<br/>';
                        }
                    }
                } catch(SObjectException soe) {
                    errorMsg += '- Can not find field ' + eventFieldDetails.FieldLabel_gne__c + ' to validate.<br/>';
                }
            }
        }
        return errorMsg;
    }

    /** @date 5/9/2013
    * @Author Pawel Sprysak
    * @description Method for validating Brands
    * @param String newDrugNames (Drug values)
    * @return Boolean
    */
    private static Boolean isValidBrands(String newDrugNames) {
        if(newDrugNames == null || ''.equals(newDrugNames)) {
            return false;
        } else {
            return true;
        }
    }

    /** @date 8/5/2014
    * @Author Pawel Sprysak
    * @description Method for validating Venue Object (Event Address) fields if required
    * @param String validationReason, Boolean fullCheck, VDST_Address_gne__c venueObject, VDST_EventSite_gne__c siteObject
    * @return String
    */
    public static String validateEventAddress(String validationReason, Boolean fullCheck, VDST_Address_gne__c venueObject, VDST_EventSite_gne__c siteObject) {
        String errorMsg = '';
        if( String.isBlank( String.valueOf( venueObject.get('City_gne__c') ) ) ) {
            errorMsg += ' - In Event Address: Venue City is required for ' + validationReason + '<br/>';
        }
        if( String.isBlank( String.valueOf( venueObject.get('Country_gne__c') ) ) ) {
            errorMsg += ' - In Event Address: Venue Country is required for ' + validationReason + '<br/>';
        }
        if( fullCheck && ( String.isBlank( String.valueOf( venueObject.get('PostalCode_gne__c') ) ) ) ) {
            errorMsg += ' - In Event Address: Venue Postal Code is required for ' + validationReason + '<br/>';
        }
        // if not full check then State is required only for US country
        if( (fullCheck || (!fullCheck && 'USA'.equals( String.valueOf( venueObject.get('Country_gne__c') ) ) ) )
            && ( String.isBlank( String.valueOf( venueObject.get('StateProvince_gne__c') ) ) ) ) {
            errorMsg += ' - In Event Address: Venue State/Province is required for ' + validationReason + '<br/>';
        }
        if( fullCheck && ( String.isBlank( String.valueOf( venueObject.get('StreetAddress_gne__c') ) ) ) ) {
            errorMsg += ' - In Event Address: Venue Street Address is required for ' + validationReason + '<br/>';
        }
        if( fullCheck && ( String.isBlank( String.valueOf( siteObject.get('EventSiteName_gne__c') ) ) ) ) {
            errorMsg += ' - In Event Address: Venue Name is required for ' + validationReason + '<br/>';
        }
        return errorMsg;
    }

     /** @date 3/31/2016
    * @Author Pawel Sprysak
    * @description Method for validating Number Of Meals
    * @param List<VDST_Utils.EventDateTransactions> evDateTransList
    * @return String
    */
    private static String validateNumberOfMeals(List<VDST_Utils.EventDateTransactions> evDateTransList) {
        for (VDST_Utils.EventDateTransactions evDateTrans : evDateTransList) {
            if (evDateTrans.totalFaB > 0 && String.isBlank(evDateTrans.numberOfMeals)) {
                return ' - In Event: Number Of Meals is required when Daily Meal Total is greater than zero (0.00)<br/>';
            }
        }
        return '';
    }

     /** @date 11/21/2013
    * @Author Pawel Sprysak
    * @description Method for generating new Vendor Event Id
    * @param VDST_Event_gne__c evnt (Event data)
    * @param String vendorLoggedVal (Logistic Vendor Code)
    * @return Boolean
    */
    private static Boolean generateVendorEventId(VDST_Event_gne__c evnt, String vendorLoggedVal) {
        if(String.isBlank(evnt.VendorEventID_gne__c)) {
            evnt.VendorEventID_gne__c = VDST_Utils.generateFirstFreeVendorEventId(vendorLoggedVal);
        } else if(!evnt.VendorEventID_gne__c.startsWith(vendorLoggedVal + '_') && !evnt.VendorEventID_gne__c.startsWith(vendorLoggedVal + '_')) {
            evnt.VendorEventID_gne__c = vendorLoggedVal + '_' + evnt.VendorEventID_gne__c;
        }
        if(evnt.VendorEventID_gne__c != null) {
            return true;
        } else {
            return false;
        }
    }

/*/////////////*/
/* PARTICIPANT */
/*/////////////*/

    /** @date 3/31/2016
    * @Author Pawel Sprysak
    * @description Method for validating Participant data
    * @param String eventType                                                 > Event Type
    * @param String vendorLoggedVal                                           > Logistic Vendor Code
    * @param ParticipantsValidationInput input                                > 
    * @param List<VDST_EventPrtcpntAccnt_gne__c> participants                 > Participant List (Provide if available / Adboard API)
    * @param List<VDST_EventPrtcpntAccnt_gne__c> participantsWithOrgs         > Participant List with Orgs (Provide if available / Adboard API)
    * @param Map<String, VDST_EventPrtcpntRole_gne__c> eventRolesMapById      > Map Role Code to existing Participant Role object
    * @return ParticipantsValidationOutput
    */
    // commonUtils = new VDST_EventDetailCommon('ADBOARD');
    public static ParticipantsValidationOutput validateParticipantsOnStatusChange(String eventType, String vendorLoggedVal, ParticipantsValidationInput input, 
                                                   List<VDST_EventPrtcpntAccnt_gne__c> participants, List<VDST_EventPrtcpntAccnt_gne__c> participantsWithOrgs, 
                                                   Map<String, VDST_EventPrtcpntRole_gne__c> eventRolesMapById) {
        ParticipantsValidationOutput output = new ParticipantsValidationOutput();
        try {
            output.editErrorMessages = '';
            output.isSuccess = true;
            String errorMsg = '';
            String infoMsg = '';
    
            if( String.isBlank(eventType) || String.isBlank(vendorLoggedVal) || input == null) {
                output.editErrorMessages = 'Participant validation - configuration error';
                output.isSuccess = false;
                return output;
            }
            if(!VDST_Utils.EVENT_STATUS_CANCEL.equals(input.status)) {
                // PARTICIPANT LEVEL: Check participant fields
                if(participants == null) {
                    if(VDST_Utils.isResearchEventType(eventType) || VDST_Utils.isNonResearchEventType(eventType)) {
                        participants = VDST_Utils.getParticipantsFullDataList(input.eventCreateObject.Id, 'ORG');
                    } else {
                        participants = VDST_Utils.getParticipantsFullDataList(input.eventCreateObject.Id);
                    }
                }
                if(input.isFixedParticipantNew) {
                    participants.add( input.participantObject );
                } else if(input.isFixedParticipantToCheck) {
                    for(Integer i = 0; i < participants.size(); i++) {
                        if(participants[i].Id != null && participants[i].Id == input.participantObject.Id) {
                            participants[i] = input.participantObject;
                            break;
                        }
                    }
                }
                if(participants == null || participants.isEmpty()) {
                    errorMsg += ' - Empty Participants List<br/>';
                } else {
                    Boolean isPayee = false;
                    Boolean isPI = false;
                    for(VDST_EventPrtcpntAccnt_gne__c part : participants) {
                        if( String.isBlank( part.EventParticipantRole_gne__c ) ) {
                            errorMsg += ' - In Participant (' + getParticipantNameForError(part) + '): Participant Role<br/>';
                            continue;
                        } else if( VDST_Utils.isResearchEventType(eventType) || VDST_Utils.isNonResearchEventType(eventType) ) {
                            String participantRoleCode = (eventRolesMapById.get(part.EventParticipantRole_gne__c) == null ? 
                                                        '' : eventRolesMapById.get(part.EventParticipantRole_gne__c).EventParticipantRoleCode_gne__c);
                            if('PAYEE'.equals(participantRoleCode) || 'ORG'.equals(participantRoleCode)) {
                                isPayee = true;
                            }
                            if('PI'.equals(participantRoleCode)) {
                                isPI = true;
                            }
                            if('PAYEEPI'.equals(participantRoleCode)) {
                                isPayee = true;
                                isPI = true;
                            }
                        }
                        if(input.prtcpntFieldMap == null) {
                            input.prtcpntFieldMap = VDST_Utils.setPrtcpntRoleFieldsMap(eventType);
                        }
                        if(!input.prtcpntFieldMap.containsKey(part.EventParticipantRole_gne__c)) {
                            errorMsg += ' - Missing configuration for participant role ' + part.EventParticipantRole_gne__c + ' in: '+ getParticipantNameForError(part) +'<br/>';
                            continue;
                        }
                        errorMsg += validateParticipantRequiredFields(input.prtcpntFieldMap.get(part.EventParticipantRole_gne__c).values(), part, input);
                    }
                    if( VDST_Utils.isResearchEventType(eventType) ) {
                        if(!isPayee) {
                            errorMsg += '- Participant with Payee Participant Role is required.<br/>';
                        } else {
                            // Set Payee Address as Event Address
                            for(VDST_EventPrtcpntAccnt_gne__c part : participants) {
                                String participantRoleCode = (eventRolesMapById.get(part.EventParticipantRole_gne__c) == null ? 
                                                            '' : eventRolesMapById.get(part.EventParticipantRole_gne__c).EventParticipantRoleCode_gne__c);
                                if('PAYEE'.equals(participantRoleCode) || 'PAYEEPI'.equals(participantRoleCode)) {
                                    //Payee Address
                                    VDST_Address_gne__c addrTemp = part.VDST_Address_gne__r;
                                    input.venueObject.AddressType_gne__c        = 'Physical';
                                    input.venueObject.City_gne__c               = addrTemp.City_gne__c;
                                    input.venueObject.Country_gne__c            = addrTemp.Country_gne__c;
                                    input.venueObject.PostalCode_gne__c         = addrTemp.PostalCode_gne__c;
                                    input.venueObject.StateProvince_gne__c      = addrTemp.StateProvince_gne__c;
                                    input.venueObject.StatesNameHolder_gne__c   = addrTemp.StatesNameHolder_gne__c;
                                    input.venueObject.StreetAddress_gne__c      = addrTemp.StreetAddress_gne__c;
                                    input.siteObject.EventSiteName_gne__c       = 'Payee Address';
                                    update input.venueObject;
                                    update input.siteObject;
                                }
                            }
                        }
                        if(!isPI) {
                            errorMsg += '- Participant with PI Participant Role is required.<br/>';
                        }
                    }
                    if( VDST_Utils.isNonResearchEventType(eventType) ) {
                        if(!isPayee) {
                            errorMsg += '- Participant with Payee Participant Role is required.<br/>';
                        }
                        if(VDST_Utils.isOOPAmountExist(input.eventCreateObject.Id)) {
                            errorMsg += validateEventAddress('Out Of Pocket HCP Travel and Out Of Pocket HCP Lodging spends.', true, input.venueObject, input.siteObject);
                        }
                        if(String.isNotBlank(input.eventCreateObject.Home_Payment_ID_gne__c) &&
                            input.eventCreateObject.CurrentStatus_gne__c == 'PENDING' &&
                            VDST_Utils.getHomePaymentIdParticipantTransactionByEventId(input.eventCreateObject.Id) == null
                        ) {
                            errorMsg += '- One of the transaction must be assigned to Home Payment ID.<br/>';
                        }
                    }
                }
                if(!''.equals(errorMsg)) {
                    output.editErrorMessages = 'Missing Participants required fields or incorrect data: <br/>' + errorMsg;
                }
            }
            // Validate Vendor Participants Uniqueness 
            if(participantsWithOrgs == null) {
                participants = VDST_Utils.getVendorPrtcpntInfoList(input.eventCreateObject.Id);
            } else {
                participants = participantsWithOrgs;
            }
            if(participants != null && !participants.isEmpty()) {
                Map<String, VDST_EventPrtcpntAccnt_gne__c> prtcpntAccntMap = new Map<String, VDST_EventPrtcpntAccnt_gne__c>();
                for(VDST_EventPrtcpntAccnt_gne__c acc : participants) {
                    if(!String.isBlank(acc.VendorParticipantID_gne__c)) {
                        prtcpntAccntMap.put(acc.VendorParticipantID_gne__c, acc);
                    }
                }
                Id eventId = (input.eventCreateObject == null) ? null : input.eventCreateObject.Id;
                List<String> idsDuplicates = VDST_Utils.notUniqueVendorParticipantIds(vendorLoggedVal, prtcpntAccntMap.keySet(), null, eventId);
                for(String str : idsDuplicates) {
                    if(prtcpntAccntMap.containsKey(str)) {
                        output.editErrorMessages = 'Participant ' + getParticipantNameForError(prtcpntAccntMap.get(str)) + ' has not unique Vendor Participant Id</br>' + output.editErrorMessages;
                    }
                }
            }
            // Show message if error
            if(!''.equals(output.editErrorMessages)) {
                output.isSuccess = false;
            } else {
                if(!generateVendorParticipantIds(participants, vendorLoggedVal)) {
                    output.editErrorMessages = 'Vendor Participant Ids are not unique.';
                    output.isSuccess = false;
                }
            }
            return output;
        } catch (Exception ex) {
            output.editErrorMessages = 'Participant validation - exception: ' + ex.getMessage();
            output.isSuccess = false;
            return output;
        }
    }

    private static String validateParticipantRequiredFields(List<VDST_EventPrtcpntField_gne__c> epfList, VDST_EventPrtcpntAccnt_gne__c part, ParticipantsValidationInput input) {
        String errorMsg = '';
        for(VDST_EventPrtcpntField_gne__c evPrtcpntField : epfList) {
            if(evPrtcpntField.IsRequired_gne__c) {
                try {
                    if('INDV'.equals(part.PartyType_gne__c) && evPrtcpntField.FieldName_gne__c.contains('PRE_ORG.')) {
                        continue;
                    } else if('ORG'.equals(part.PartyType_gne__c) && evPrtcpntField.FieldName_gne__c.contains('PRE_INDV.')) {
                        continue;
                    }
                    String fieldNameVar = evPrtcpntField.FieldName_gne__c.remove('PRE_INDV.').remove('PRE_ORG.');
                    Boolean hasAddress = fieldNameVar.contains('VDST_Address_gne.');
                    if(hasAddress) {
                        VDST_Address_gne__c addrTemp = part.VDST_Address_gne__r;
                        String fullFieldName = fieldNameVar.removeStart('VDST_Address_gne.') + '__c';
                        String valueTemp = String.valueOf( addrTemp.get(fullFieldName) );
                        Boolean isNonUsaStateEmpty = (
                            !'USA'.equals(addrTemp.Country_gne__c) &&
                            'StateProvince_gne__c'.equals(fullFieldName) &&
                            String.isBlank(addrTemp.StatesNameHolder_gne__c)
                        );
                        if( String.isBlank(valueTemp) || isNonUsaStateEmpty ) {
                           errorMsg += ' - In Participant Address (' + getParticipantNameForError(part) + '): ' + evPrtcpntField.FieldLabel_gne__c + '<br/>';
                        }
                    } else if(!hasAddress && String.isBlank( String.valueOf( part.get(fieldNameVar + '__c') ) ) ) {
                        if( !( input.isFixedParticipantNew && 'ParticipantRole_gne'.equals( fieldNameVar ) ) ) {
                            errorMsg += ' - In Participant (' + getParticipantNameForError(part) + '): ' + evPrtcpntField.FieldLabel_gne__c + '<br/>';
                        }
                    }
                } catch(SObjectException soe) {
                    errorMsg += '- Can not find field ' + evPrtcpntField.FieldLabel_gne__c + ' to validate.<br/>';
                }
            }
        }
        return errorMsg;
    }

    /** @date 4/4/2013
    * @Author Pawel Sprysak
    * @description Internal method for returning First and Last Name in validation
    * @param VDST_EventPrtcpntAccnt_gne__c part (Participant record)
    * @return String
    */
    private static String getParticipantNameForError(VDST_EventPrtcpntAccnt_gne__c part) {
        if(!String.isBlank(part.LegalName_gne__c)) {
            return part.LegalName_gne__c;
        } else {
            String name = '';
            if(!String.isBlank(part.FirstName_gne__c)) name += part.FirstName_gne__c + ' ';
            if(!String.isBlank(part.LastName_gne__c)) name += part.LastName_gne__c;
            if(String.isBlank(name)) name += 'No Name provided';
            return name;
        }
    }

    /** @date 11/21/2013
    * @Author Pawel Sprysak
    * @description Method for generating new Vendor Participant Id's
    * @param List<VDST_EventPrtcpntAccnt_gne__c> prtcipnts
    * @param String vendorLoggedVal
    * @return Boolean
    */
    private static Boolean generateVendorParticipantIds(List<VDST_EventPrtcpntAccnt_gne__c> participants, String vendorLoggedVal) {
        // Get Id Lists
        List<VDST_EventPrtcpntAccnt_gne__c> blankParticipants = new List<VDST_EventPrtcpntAccnt_gne__c>();     // Participants with blank Id's
        List<VDST_EventPrtcpntAccnt_gne__c> updatedParticipants = new List<VDST_EventPrtcpntAccnt_gne__c>();
        Set<String> vpartIds = new Set<String>();                                                           // List of Id's to save
        // Fill lists
        Boolean isUpdate = false;
        for(VDST_EventPrtcpntAccnt_gne__c part : participants) {
            if(!String.isBlank(part.VendorParticipantID_gne__c)) {
                if(!part.VendorParticipantID_gne__c.startsWith(vendorLoggedVal + '_')) {
                    part.VendorParticipantID_gne__c = vendorLoggedVal + '_' + part.VendorParticipantID_gne__c;
                    updatedParticipants.add(part);
                }
            } else if(String.isBlank(part.VendorParticipantID_gne__c)) {
                blankParticipants.add(part);
            }
            if( part.VDST_Address_gne__c != null ) {
                isUpdate = true;
            }
        }
        // No Participants with null Id's
        if(updatedParticipants != null && !updatedParticipants.isEmpty() && updatedParticipants.get(0).Id != null && isUpdate) {
            update participants;
        }
        if(blankParticipants.isEmpty()) {
            return true;
        }
        // Generating values
        List<String> generatedIds = VDST_Utils.generateFirstCoupleFreeVendorParticipantId(vendorLoggedVal, blankParticipants.size());
        Integer i = 0;
        for(VDST_EventPrtcpntAccnt_gne__c epa : blankParticipants) {
            epa.VendorParticipantID_gne__c = generatedIds.get(i);
            i++;
        }
        if(blankParticipants != null && !blankParticipants.isEmpty() && blankParticipants.get(0).Id != null && isUpdate) {
            update blankParticipants;
        }
        return true;
    }

    /** @date 7/2/2014
    * @Author Konrad Malinowski
    * @description Input Validation Wrapper Class for Participants
    */
    public class ParticipantsValidationInput {
        public String                           status                  { get; set; }
        public VDST_EventPrtcpntAccnt_gne__c    participantObject       { get; set; }

        public VDST_Event_gne__c                eventCreateObject       { get; set; }
        public VDST_Address_gne__c              venueObject             { get; set; }
        public VDST_EventSite_gne__c            siteObject              { get; set; }
        public Map<String, Map<String, VDST_EventPrtcpntField_gne__c>> prtcpntFieldMap { get; set; }

        public Boolean isFixedParticipantToCheck    { get { return (participantObject != null); } }
        public Boolean isFixedParticipantNew        { get { return (isFixedParticipantToCheck && participantObject.Id == null); } }

        public ParticipantsValidationInput() {
            participantObject = null;
        }
    }

    /** @date 7/2/2014
    * @Author Konrad Malinowski
    * @description Output Validation Wrapper Class for Participants
    */
    public class ParticipantsValidationOutput {
        public Boolean isSuccess { get; set; }
        public String editErrorMessages { get; set; }
    }
}