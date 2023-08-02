public without sharing class EMS_Event_Edit_Create_Ext {

    public Boolean isOldType { get; set; }
    private EMS_Event__c event;
    private Boolean isClone = false;
    private Id oldEventId;
    private Set<String> eventTypes;
    public Boolean disableSpeakerTourFeatures { get; set; }
    private String clonedSubtype = '';

    public EMS_Event_Edit_Create_Ext(ApexPages.StandardController controller) {
        event = (EMS_Event__c) controller.getRecord();
        clonedSubtype = event.Event_Sub_Type_gne__c;

        String cloneId = ApexPages.currentPage().getParameters().get('cloneId');
        isOldType = false;
        disableSpeakerTourFeatures = false;

        if (event.Id == null && (cloneId == null || cloneId == '')) {
            // if this is a new event
            if (event.Status_gne__c == null) {
                event.Status_gne__c = 'Unplanned';
            }
            if (event.Country_gne__c == null) {
                event.Country_gne__c = 'Canada';
            }
            if (event.Event_Requestor_gne__c == null) {
                event.Event_Requestor_gne__c = UserInfo.getUserId();
                event.Event_Requestor_gne__r = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            }
            if (ApexPages.currentPage().getParameters().get('tp') != null) {
                event.Event_Type_gne__c = ApexPages.currentPage().getParameters().get('tp');
            }
            if (ApexPages.currentPage().getParameters().get('sbtp') != null) {
                event.Event_Sub_Type_gne__c = ApexPages.currentPage().getParameters().get('sbtp');
            }
            if (ApexPages.currentPage().getParameters().get('rltid') != null) {
                // related event id is used for Event Tours. Related id - it's a parent
                event.Parent_Speaker_Tour_Event_gne__c = (Id) ApexPages.currentPage().getParameters().get('rltid');
                // Use this variable to forbid any changes, such as Type, Subtype and Speaker Tour checkbox;
                disableSpeakerTourFeatures = true;
            }
        }
        if (event.Parent_Speaker_Tour_Event_gne__c != null) {
            disableSpeakerTourFeatures = true;
        }
        if (event.Id != null && cloneId != null && cloneId != '') {
            isClone = true;
            oldEventId = event.Id;
        }

        eventTypes = new Set<String>();
        for (Schema.PicklistEntry picklistValue : EMS_Event__c.Event_Type_gne__c.getDescribe().getPicklistValues()) {
            eventTypes.add(picklistValue.getValue());
        }
        if (event.Id != null) {
            if (!eventTypes.contains(event.Event_Type_gne__c)) {
                isOldType = true;
            }
        }
    }

    public List<SelectOption> getOLACHESubTypes() {
        Schema.DescribeFieldResult subtypeDescribe = EMS_Event__c.Event_Sub_Type_gne__c.getDescribe();
        List<SelectOption> allowedSubtypes = new List<SelectOption>();
        for (Schema.Picklistentry subtype : subtypeDescribe.getPicklistValues()) {
            if (subtype.getValue().contains('OLA') || subtype.getValue().contains('CHE')) {
                allowedSubtypes.add(new SelectOption(subtype.getValue(), subtype.getLabel()));
            }
        }
        return allowedSubtypes;
    }

    public List<SelectOption> getOwnerTerritories() {
        return EMS_Util.getUserTerritorySelectOptions(event.Event_Owner_gne__c);
    }

    public List<SelectOption> getRequestorTerritories() {
        return EMS_Util.getUserTerritorySelectOptions(event.Event_Requestor_gne__c);
    }

    public List<SelectOption> getCities() {
        List<SelectOption> cities = new List<SelectOption>();
        cities.add(new SelectOption('', '--None--'));

        for (EMS_City_To_Province_Mapping_gne__c mapping : [SELECT City_gne__c, Province_gne__c FROM EMS_City_To_Province_Mapping_gne__c WHERE Province_gne__c = :event.Province_gne__c ORDER BY Order_gne__c NULLS LAST, City_gne__c]) {
            cities.add(new SelectOption(mapping.City_gne__c, mapping.City_gne__c));
        }
        return cities;
    }

    @RemoteAction
    public static String getDescription(String eventType, String eventSubType) {
        String description = '';
        List<EMS_Event_Configuration_gne__c> eventConfiguration = [SELECT Description_gne__c FROM EMS_Event_Configuration_gne__c WHERE Event_Type_gne__c = :eventType AND Event_Sub_Type_gne__c = :eventSubType];
        if (!eventConfiguration.isEmpty()) {
            description = eventConfiguration[0].Description_gne__c;
        }

        return description;
    }

    public Integer getMaxAttendeeCount() {
        Integer maxAttendeeCount;

        List<EMS_Event_Configuration_gne__c> eventConfiguration = [SELECT Max_Attendee_Count_gne__c FROM EMS_Event_Configuration_gne__c WHERE Event_Type_gne__c = :event.Event_Type_gne__c AND Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c];
        if (!eventConfiguration.isEmpty() && eventConfiguration[0].Max_Attendee_Count_gne__c != null) {
            maxAttendeeCount = Integer.valueOf(eventConfiguration[0].Max_Attendee_Count_gne__c);
        }

        return maxAttendeeCount;
    }

    private Boolean verifyUserTerritory() {
        Boolean ownerTerrVerified = false;
        Boolean requestorTerrVerified = false;
        List<SelectOption> ownerTerritories = getOwnerTerritories();
        String ownerTerritory = event.Assigned_To_Territory_Owner_gne__c;
        for (SelectOption ow_ter : ownerTerritories) {
            if (ow_ter.getValue().contains(ownerTerritory.trim())) {
                ownerTerrVerified = true;
            }
        }
        List<SelectOption> requestorTerritories = getRequestorTerritories();
        String requestorTerritory = event.Assigned_To_Territory_Requestor_gne__c;
        for (SelectOption rq_ter : requestorTerritories) {
            if (rq_ter.getValue().contains(requestorTerritory.trim())) {
                requestorTerrVerified = true;
            }
        }
        return ownerTerrVerified && requestorTerrVerified;
    }

    public PageReference saveEvent() {
        if (!verifyUserTerritory()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please verify Assigned To Territory values.'));
            return null;
        }

        if (isClone == false) {
            try {
                upsert event;
            } catch (DMLException ex) {
                return null;
            }
        } else if (isClone == true) {

            Id emsEventRecordTypeId = EMS_Event__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('EMS Event').getRecordTypeId();
            System.Savepoint initialState = Database.setSavepoint();
            try {
                EMS_Event__c clonedEvent = event.clone(false, true, false, false);
                clonedEvent.Status_gne__c = 'Unplanned';
                clonedEvent.RecordTypeId = emsEventRecordTypeId;
                clonedEvent.Budget_Approval_Required_gne__c = false;
                insert clonedEvent;

                String queryString = '';

                //Meeting request
                List<EMS_Meeting_Request_gne__c> clonedMeetingRequests = new List<EMS_Meeting_Request_gne__c>();
                List<EMS_Meeting_Request_gne__c> meetingRequestsToClone = new List<EMS_Meeting_Request_gne__c>();

                queryString = getQueryStringForAllFields('EMS_Meeting_Request_gne__c', null, null);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'';
                meetingRequestsToClone = Database.query(queryString);
                clonedMeetingRequests = meetingRequestsToClone.deepClone(false);
                for (EMS_Meeting_Request_gne__c cmr : clonedMeetingRequests) {
                    cmr.EMS_Event_gne__c = clonedEvent.Id;
                }

                //Budget Allocations
                /*List<EMS_Budget_Allocation_gne__c> clonedBudgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
                List<EMS_Budget_Allocation_gne__c> budgetAllocationsToCheck = new List<EMS_Budget_Allocation_gne__c>();
                List<EMS_Budget_Allocation_gne__c> budgetAllocationsToClone = new List<EMS_Budget_Allocation_gne__c>();

                List<String> additonalFields = new List<String>{'Budget_Balance_gne__c'};

                queryString =  getQueryStringForAllFields('EMS_Budget_Allocation_gne__c', additonalFields);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'';
                budgetAllocationsToCheck = Database.query(queryString);

                for (EMS_Budget_Allocation_gne__c batc : budgetAllocationsToCheck) {
                    if (batc.Budget_Balance_gne__c >= batc.Allocated_Budget_gne__c) { // If budget balance is greater then we can clone, otherwise skipped.
                        budgetAllocationsToClone.add(batc);
                    }
                }
                clonedBudgetAllocations = budgetAllocationsToClone.deepClone(false);
                for (EMS_Budget_Allocation_gne__c cba : clonedBudgetAllocations) {
                    cba.EMS_Event_gne__c = clonedEvent.Id;
                } */ // Too many SOQL queries

                //Product
                List<EMS_Event_Product_gne__c> clonedEventProducts = new List<EMS_Event_Product_gne__c>();
                List<EMS_Event_Product_gne__c> eventProductsToClone = new List<EMS_Event_Product_gne__c>();

                queryString = getQueryStringForAllFields('EMS_Event_Product_gne__c', null, null);
                queryString += ' WHERE Event_gne__c = \'' + oldEventId + '\'';
                eventProductsToClone = Database.query(queryString);
                clonedEventProducts = eventProductsToClone.deepClone(false);
                for (EMS_Event_Product_gne__c cep : clonedEventProducts) {
                    cep.Event_gne__c = clonedEvent.Id;
                }

                //Attendees - roche
                List<EMS_Roche_Attendee_gne__c> clonedRocheAttendees = new List<EMS_Roche_Attendee_gne__c>();
                List<EMS_Roche_Attendee_gne__c> rocheAttendeesToClone = new List<EMS_Roche_Attendee_gne__c>();
                List<EMS_Roche_Attendee_gne__c> rocheAttendeesToUpsert = new List<EMS_Roche_Attendee_gne__c>();
                List<EMS_Roche_Attendee_gne__c> autoCreatedAtt = [SELECT Id, User_gne__c, Territory_Id_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c = :clonedEvent.Id];

                queryString = getQueryStringForAllFields('EMS_Roche_Attendee_gne__c', null, null);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'' ;
                rocheAttendeesToClone = Database.query(queryString);
                clonedRocheAttendees = rocheAttendeesToClone.deepClone(false);
                for (EMS_Roche_Attendee_gne__c cra : clonedRocheAttendees) {
                    if (cra.User_gne__c == autoCreatedAtt.get(0).User_gne__c) {
                        EMS_Roche_Attendee_gne__c tmpRa = autoCreatedAtt.get(0);
                        tmpRa.Territory_Id_gne__c = cra.Territory_Id_gne__c;
                        rocheAttendeesToUpsert.add(tmpRa);
                    } else {
                        cra.EMS_Event_gne__c = clonedEvent.Id;
                        rocheAttendeesToUpsert.add(cra);
                    }
                }

                /*Set<String> fmvFields = new Set<String>{ 'Preparation_Time_1_gne__c', 'Preparation_Time_2_gne__c', 'Preparation_Time_3_gne__c', 'Preparation_Time_4_gne__c', 'Preparation_Time_5_gne__c', 'Preparation_Time_6_gne__c',
                    'Activity_Time_gne__c', 'Activity_Time_1_gne__c', 'Activity_Time_2_gne__c', 'Activity_Time_3_gne__c', 'Activity_Time_4_gne__c', 'Activity_Time_5_gne__c', 'Activity_Time_6_gne__c',
                    'Disturbance_Fee__c', 'km_gne__c', 'Type_of_HCP_other_gne__c', 'HCP_hourly_rate_table_gne__c', 'Type_of_HCP_gne__c', 'Total_Honoraria_gne__c', 'Address_gne__c', 'Email_address_gne__c', 'Event_End_Time_gne__c',
                    'Event_Start_Time_gne__c', 'Name_and_email_of_the_contact_person_gne__c', 'Payable_To_Name_gne__c', 'Preferred_way_to_contact_the_speaker_gne__c', 'Special_Request_additional_inf_gne__c', 'Telephone_number_gne__c', 'Topic_and_Intent_gne__c' };*/

                // When duplicating without changing the sub-type, then FMV values should be preserved.
                Boolean isSubtypeAltered = (clonedSubtype != clonedEvent.Event_Sub_Type_gne__c);

                //Attendees - hcp ihcp watchers
                List<EMS_Attendee_gne__c> clonedEventAttendees = new List<EMS_Attendee_gne__c>();
                List<EMS_Attendee_gne__c> eventAttendeesToClone = new List<EMS_Attendee_gne__c>();

                queryString = getQueryStringForAllFields('EMS_Attendee_gne__c', null, null);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'';
                eventAttendeesToClone = Database.query(queryString);
                clonedEventAttendees = eventAttendeesToClone.deepClone(false);
                for (EMS_Attendee_gne__c cea : clonedEventAttendees) {
                    cea.EMS_Event_gne__c = clonedEvent.Id;
                    if (isSubtypeAltered) {
                        EMS_Attendee_Field_Updates.clearAttendeeFieldsValues(cea);
                    }
                }

                //Attachments
                /*List<EMS_Attachment_gne__c> clonedAttachments = new List<EMS_Attachment_gne__c>();
                List<EMS_Attachment_gne__c> attachmentsToClone = new List<EMS_Attachment_gne__c>();

                queryString =  getQueryStringForAllFields('EMS_Attachment_gne__c', null);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'';
                attachmentsToClone = Database.query(queryString);
                clonedAttachments = attachmentsToClone.deepClone(false);
                for (EMS_Attachment_gne__c ca : clonedAttachments) {
                    ca.EMS_Event_gne__c = clonedEvent.Id;
                }*/

                //Payment requests
                /*List<EMS_Speaker_Role_gne__c> clonedSpeakerRole = new List<EMS_Speaker_Role_gne__c>();
                List<EMS_Speaker_Role_gne__c> speakerRoleToClone = new List<EMS_Speaker_Role_gne__c>();

                queryString =  getQueryStringForAllFields('EMS_Speaker_Role_gne__c', null);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'';
                speakerRoleToClone = Database.query(queryString);
                clonedSpeakerRole = speakerRoleToClone.deepClone(false);
                for (EMS_Speaker_Role_gne__c csr : clonedSpeakerRole) {
                    csr.EMS_Event_gne__c = clonedEvent.Id;
                }*/

                //Travels
                /*List<EMS_Travel_gne__c> clonedTravels = new List<EMS_Travel_gne__c>();
                List<EMS_Travel_gne__c> travelsToClone = new List<EMS_Travel_gne__c>();

                queryString =  getQueryStringForAllFields('EMS_Travel_gne__c', null);
                queryString += ' WHERE EMS_Event_gne__c = \'' + oldEventId + '\'';
                travelsToClone = Database.query(queryString);
                clonedTravels = travelsToClone.deepClone(false);
                for (EMS_Travel_gne__c ct : clonedTravels) {
                    ct.EMS_Event_gne__c = clonedEvent.Id;
                }*/

                if (clonedMeetingRequests.size() > 0) {
                    insert clonedMeetingRequests;
                }
                /*if (clonedBudgetAllocations.size() > 0) {
                    insert clonedBudgetAllocations;
                }*/ // Too many SOQL queries
                if (clonedEventProducts.size() > 0) {
                    insert clonedEventProducts;
                }
                if (rocheAttendeesToUpsert.size() > 0) {
                    upsert rocheAttendeesToUpsert;
                }
                if (clonedEventAttendees.size() > 0) {
                    insert clonedEventAttendees;
                }
                /*if (clonedAttachments.size() > 0) {
                    insert clonedAttachments;
                }*/
                /*if (clonedSpeakerRole.size() > 0) {
                    insert clonedSpeakerRole;
                }*/
                /*if (clonedTravels.size() > 0) {
                    insert clonedTravels;
                }*/

                // clone meeting rooms only when there is meeting request created
                if (clonedMeetingRequests.size() > 0) {
                    //Meeting rooms (there is only one meeting request per event)
                    List<EMS_Meeting_Room_gne__c> clonedMeetingRoom = new List<EMS_Meeting_Room_gne__c>();
                    List<EMS_Meeting_Room_gne__c> meetingRoomsToClone = new List<EMS_Meeting_Room_gne__c>();

                    queryString = getQueryStringForAllFields('EMS_Meeting_Room_gne__c', null, null);
                    queryString += ' WHERE EMS_Meeting_Request_gne__c = \'' + meetingRequestsToClone.get(0).Id + '\'';
                    meetingRoomsToClone = Database.query(queryString);
                    clonedMeetingRoom = meetingRoomsToClone.deepClone(false);
                    for (EMS_Meeting_Room_gne__c cmr : clonedMeetingRoom) {
                        cmr.EMS_Meeting_Request_gne__c = clonedMeetingRequests.get(0).Id;
                    }
                    if (clonedMeetingRoom.size() > 0) {
                        insert clonedMeetingRoom;
                    }
                }

                PageReference pref = new PageReference('/apex/EMS_Event_Layout?id=' + clonedEvent.Id);
                pref.setRedirect(true);
                return pref;

            } catch (Exception ex) {
                Database.rollback(initialState);
                System.debug(LoggingLevel.ERROR, '### Cloning is FAILED: ' + ex.getMessage());
                return null;
            }
        }

        PageReference pref = new PageReference('/apex/EMS_Event_Layout?id=' + event.Id);
        pref.setRedirect(true);
        return pref;
    }

    private String getQueryStringForAllFields(String objectName, List<String> additionalFields, Set<String> excludedFields) {
        String queryString = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.GetGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for (Schema.SObjectField field : objectFields.values()) {
            String fieldName = field.getDescribe().getName().trim();
            if (excludedFields == null || !excludedFields.contains(fieldName)) {
                queryString += fieldName + ', ';
            }
        }

        if (additionalFields != null && additionalFields.size() > 0) {
            for (String addField : additionalFields) {
                queryString += addField + ', ';
            }
        }

        queryString = queryString.removeEnd(', ');
        queryString += ' FROM ' + objectName;

        return queryString;
    }
}