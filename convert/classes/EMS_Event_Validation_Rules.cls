public without sharing class EMS_Event_Validation_Rules {
    private static Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private static Map <String, Schema.SObjectField> objectFieldsMap = schemaMap.get('EMS_Event__c').getDescribe().fields.getMap();
    private static Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.EMS_Event__c.getRecordTypeInfosById();

    public static boolean onBeforeUpdate(Map<ID, EMS_Event__c> triggerOldMap, List<EMS_Event__c> triggerNew) {
        boolean result = false;
        if (EMS_Event_Trigger_Helper.skipTriggerValidationRules == FALSE) {
            result = (runValidationRulesOnUpdate(triggerOldMap, triggerNew));
        }
        return result;
    }

    public static boolean onBeforeInsert(List<EMS_Event__c> triggerNew) {
        boolean result = false;
        if (EMS_Event_Trigger_Helper.skipTriggerValidationRules == FALSE) {
            result = (runValidationRulesOnInsert(triggerNew));
        }
        return result;
    }

    public static boolean onBeforeDelete(Map<Id, EMS_Event__c> triggerOldMap) {
        boolean result = false;
        if (EMS_Event_Trigger_Helper.skipTriggerValidationRules == FALSE) {
            result = (runValidationRulesOnDelete(triggerOldMap));
        }
        return result;
    }

    private static boolean runValidationRulesOnDelete(Map<Id, EMS_Event__c> triggerOldMap) {
        boolean result = false;
        List<EMS_Event__c> expensesForEvent = EMS_Event_Trigger_Helper.getExpensesForEvent(triggerOldMap.keySet());
        for (EMS_Event__c event: expensesForEvent) {
            if (event.EMS_Expenses__r != null && event.EMS_Expenses__r.size() > 0) {
                triggerOldMap.get(event.Id).addError(System.label.Remove_Related_Expenses);
                result = true;
            }
        }
        return result;
    }

    private static boolean runValidationRulesOnInsert(List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event: triggerNew) {
            if (validateStatus(event)) {
                return true;
            } else if (validateStartEndDate(null, event)) {
                return true;
            } else if (validateNonHCPCount(event)) {
                return true;
            } else if (validateTA(null, event)) {
                return true;
            } else if (validateDatesOrder(null, event)) {
            	return true;
            }
        }
        return false;
    }

    private static boolean runValidationRulesOnUpdate(Map<ID, EMS_Event__c> triggerOldMap, List<EMS_Event__c> triggerNew) {
        Map<Id, List<EMS_Attendee_gne__c>> attendeesForEvent = EMS_Event_Trigger_Helper.getAttendeeForEvents(triggerOldMap.keySet());
        Map<Id, List<EMS_Attachment_gne__c>> attachmentsForEvent = EMS_Event_Trigger_Helper.getAttachmentsForEvents(triggerOldMap.keySet());

        for (EMS_Event__c event : triggerNew) {
            if (validateAtendee(event, triggerOldMap.get(event.Id), attendeesForEvent.containsKey(event.Id))) {
                return true;
            } else if (validateBudgetAllocation(event, triggerOldMap.get(event.Id))) {
                return true;
            } else if (validateAttachments(event, triggerOldMap.get(event.Id), attachmentsForEvent)) {
                return true;
            } else if (validateStartEndDate(triggerOldMap.get(event.Id), event)) {
                return true;
            } else if (validateClosureDate(triggerOldMap.get(event.Id), event)) {
                return true;
            } else if (validateCanCancel(triggerOldMap.get(event.Id), event)) {
                return true;
            } else if (validateForbidEditingEvent(triggerOldMap.get(event.Id), event)) {
                return true;
            } else if (validateNonHCPCount(event)) {
                return true;
            } else if (validateTA(triggerOldMap.get(event.Id), event)) {
                return true;
            } else if (validateDatesOrder(triggerOldMap.get(event.Id), event)) {
            	return true;
            }
        }
        return false;
    }

    private static boolean validateForbidEditingEvent(EMS_Event__c oldEvent, EMS_Event__c newEvent) {
        String rtName = rtMap.get(oldEvent.RecordTypeId).getName();
        String userRole = EMS_Util.getUserRole();

        if (rtName == 'EMS Cancelled Event' || rtName == 'EMS Closed Event') {
            if (userRole == 'Admin') {
                return false;
            } else {
                Boolean showError = FALSE;
                Set<String> fieldsToCheck = new Set<String>{
                        'event_name_gne__c', 'event_owner_gne__c', 'start_date_gne__c', 'event_type_gne__c', 'event_sub_type_gne__c', 'assigned_to_territory_requestor_gne__c',
                        'end_date_gne__c', 'investment_gne__c', 'agenda_comments_gne__c', 'planned_expenses_gne__c', 'non_hcp_attendees_gne__c', 'facility_name_venue_gne__c', 'city_gne__c', 'event_website_gne__c',
                        'meeting_room_names_gne__c', 'address_gne__c', 'province_gne__c', 'contact_name_phone_number_gne__c', 'hours_of_event_gne__c'
                };

                for (String fieldname : fieldsToCheck) {
                    if (oldEvent.get(objectFieldsMap.get(fieldname)) != (newEvent.get(objectFieldsMap.get(fieldname)))) {
                        showError = TRUE;
                    }
                }

                if (showError) {
                    newEvent.addError('You cannot edit Event with this status.');
                    return true;
                }
                return false;
            }

        } else if (rtName == 'EMS Locked Event' || rtName == 'EMS Med Ops Approved Event' || rtName == 'EMS Owner Approved Event' || rtName == 'EMS Signed Agreement Received Event') {
            if (EMS_Access.isAdmin() || EMS_Access.isBPS()) {
                return false;

            } else if (EMS_Access.isMPUser()) {
                Boolean showError = FALSE;
                Set<String> fieldsToCheck = new Set<String>{
                        'event_name_gne__c', 'event_owner_gne__c', 'start_date_gne__c', 'event_type_gne__c', 'event_sub_type_gne__c', 'assigned_to_territory_requestor_gne__c',
                        'end_date_gne__c', 'investment_gne__c', 'agenda_comments_gne__c', 'planned_expenses_gne__c'
                }; // Without Lcoation fields

                for (String fieldname : fieldsToCheck) {
                    if (oldEvent.get(objectFieldsMap.get(fieldname)) != (newEvent.get(objectFieldsMap.get(fieldname)))) {
                        showError = TRUE;
                    }
                }

                if (showError) {
                    newEvent.addError('You cannot edit Event with this status.');
                    return true;
                }
                return false;

            } else {
                Boolean showError = FALSE;
                Set<String> fieldsToCheck = new Set<String>{
                        'event_name_gne__c', 'event_owner_gne__c', 'start_date_gne__c', 'event_type_gne__c', 'event_sub_type_gne__c', 'assigned_to_territory_requestor_gne__c',
                        'end_date_gne__c', 'investment_gne__c', 'agenda_comments_gne__c', 'planned_expenses_gne__c', 'facility_name_venue_gne__c', 'city_gne__c', 'event_website_gne__c',
                        'meeting_room_names_gne__c', 'address_gne__c', 'province_gne__c', 'contact_name_phone_number_gne__c', 'hours_of_event_gne__c'
                };

                for (String fieldname : fieldsToCheck) {
                    if (oldEvent.get(objectFieldsMap.get(fieldname)) != (newEvent.get(objectFieldsMap.get(fieldname)))) {
                        showError = TRUE;
                    }
                }

                if (showError) {
                    newEvent.addError('You cannot edit Event with this status.');
                    return true;
                }
                return false;
            }
        }
        return false;
    }

    private static boolean validateStatus(EMS_Event__c event) {
        if (event.Status_gne__c == 'Closed') {
            event.addError('You cannot create new Event with "Closed" status');
            return true;
        }
        return false;
    }

    private static boolean validateClosureDate(EMS_Event__c oldEvent, EMS_Event__c event) {
        if (event.Status_gne__c != oldEvent.Status_gne__c && event.Status_gne__c == 'Closed' && event.End_Date_gne__c > System.today()) {
            event.addError(System.Label.EMS_Close_Event_Future_End_Date);
            return true;
        }
        return false;
    }

    private static boolean validateCanCancel(EMS_Event__c oldEvent, EMS_Event__c newEvent) {
        if (newEvent.Status_gne__c == 'Cancelled' && oldEvent.Status_gne__c == 'Payment Request Initiated') {
            newEvent.addError(System.Label.EMS_Cancel_Event_Payment_Initiated);
            return true;
        }
        return false;
    }

    private static boolean validateStartEndDate(EMS_Event__c oldEvent, EMS_Event__c newEvent) {
        Boolean shatusHasChanged = (oldEvent == null || (oldEvent != null && oldEvent.Status_gne__c != newEvent.Status_gne__c));
        if (shatusHasChanged && newEvent.Status_gne__c == 'Closed' && newEvent.End_Date_gne__c > System.today()) {
            newEvent.addError(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date);
            return true;
        }
        return false;
    }
    
    private static boolean validateDatesOrder(EMS_Event__c oldEvent, EMS_Event__c newEvent) {
    	if (newEvent.End_Date_gne__c < newEvent.Start_Date_gne__c) {
            newEvent.addError(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date);
            return true;
        }
        return false;
    }

    private static boolean validateProvince(EMS_Event__c event) {
        System.debug(LoggingLevel.ERROR ,'Validate province: ' + event.Province_gne__c);

        if (String.isEmpty(event.Province_gne__c) &&
            event.Event_Sub_Type_gne__c != 'Institutional/Clinic Session - Product Training' &&
            event.Event_Sub_Type_gne__c != 'OLA/Accredited CHE Development' &&
            event.Event_Type_gne__c != 'GD' &&
            event.Event_Type_gne__c != 'Sponsorship' &&
            event.Event_Type_gne__c != 'Grants' &&
            event.Event_Type_gne__c != 'Donation' &&
            event.Event_Type_gne__c != 'Sponsorships' &&
            event.Event_Type_gne__c != 'Individual Conference Support' &&
            event.Event_Sub_Type_gne__c != 'RAMA - Health Economics'
        ) {
            System.debug(event.Event_Type_gne__c);
            event.Province_gne__c.addError(System.Label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Event__c.fields.Province_gne__c.label);
            return true;
        }
        return false;
    }

    private static boolean validateAtendee(EMS_Event__c newEvent, EMS_Event__c oldEvent, boolean existAtendees) {
        if (newEvent.Is_GSD_Event_gne__c == FALSE && newEvent.Status_gne__c == 'Closed' && oldEvent.Status_gne__c != 'Closed' && !existAtendees) {
            newEvent.addError('You cannot close the event without attendees.');
            return true;
        }
        return false;
    }

    private static boolean validateNonHCPCount(EMS_Event__c event) {
        if (event.Non_HCP_Attendees_gne__c < 0) {
            event.addError('# Non-Physician Attendees must be 0 or more.');
            return true;
        }
        return false;
    }


    private static boolean validateBudgetAllocation(EMS_Event__c newEvent, EMS_Event__c oldEvent) {
        if (newEvent.Status_gne__c.contains('Pending') && !oldEvent.Status_gne__c.contains('Pending') && (newEvent.Planned_Expenses_gne__c != newEvent.Total_Budget_Allocated_gne__c)) {
            newEvent.addError(System.Label.EMS_Planned_Allocated);
            return true;
        } else if (newEvent.Status_gne__c.contains('Pending') && !oldEvent.Status_gne__c.contains('Pending') && (newEvent.Planned_Expenses_gne__c == 0)) {
            newEvent.addError('Total budget allocated must be greater than zero.');
            return true;
        }
        return false;
    }

    private static boolean validateAttachments(EMS_Event__c newEvent, EMS_Event__c oldEvent, Map<Id, List<EMS_Attachment_gne__c>> attachments) {
        Boolean eventSubmitted = newEvent.Status_gne__c.contains('Pending') && !oldEvent.Status_gne__c.contains('Pending');
        if(!eventSubmitted) {
            return false;
        }

        if(newEvent.Event_Type_gne__c == 'Collaboration') {
            if (attachments.get(newEvent.Id) != null) {
                for (EMS_Attachment_gne__c attachement : attachments.get(newEvent.Id)) {
                    if (attachement.Type_gne__c == 'Collaboration Document') {
                        return false;
                    }
                }
            }

            newEvent.addError(String.format(System.Label.Attach_Collaboration_Document, new List<String> {newEvent.Event_Sub_Type_gne__c}));

            return true;
        } else if (newEvent.Is_GSD_Event_gne__c) {
            if (attachments.get(newEvent.Id) != null) {
                for (EMS_Attachment_gne__c attachement : attachments.get(newEvent.Id)) {
                    if (attachement.Type_gne__c == 'Letter of Request') {
                        return false;
                    }
                }
            }

            if(newEvent.Event_Sub_Type_gne__c == 'Journal Club / Post Congress'
                || newEvent.Event_Sub_Type_gne__c == 'Journal Club / Post Congress / In Kind'
                || newEvent.Event_Sub_Type_gne__c == 'Journal Club'
            ) {
                newEvent.addError(String.format(System.Label.Attach_Letter_Of_Request, new List<String> {newEvent.Event_Sub_Type_gne__c}));
            } else {
                newEvent.addError(String.format(System.Label.Attach_Letter_Of_Request, new List<String> {'GSD'}));
            }

            return true;
        } else if(newEvent.Event_Sub_Type_gne__c == 'Institutional/Clinic Session - Product Training') {
            if (attachments.get(newEvent.Id) != null) {
                for (EMS_Attachment_gne__c attachement : attachments.get(newEvent.Id)) {
                    if (attachement.Type_gne__c == 'Letter of Intent') {
                        return false;
                    }
                }
            }

            newEvent.addError(String.format(System.Label.Attach_Letter_Of_Intent, new List<String> {newEvent.Event_Sub_Type_gne__c}));

            return true;

        } else if(newEvent.Event_Type_gne__c == 'Consulting' || newEvent.Event_Type_gne__c == 'Learning Programs') {
            if (attachments.get(newEvent.Id) != null) {
                for (EMS_Attachment_gne__c attachement : attachments.get(newEvent.Id)) {
                    if (attachement.Type_gne__c == 'Documentation Checklist') {
                        return false;
                    }
                }
            }

            newEvent.addError(String.format(System.Label.Attach_Documentation_Checklist, new List<String> {newEvent.Event_Sub_Type_gne__c}));

            return true;

        }

        return false;
    }

    private static boolean validateTA(EMS_Event__c oldEvent, EMS_Event__c newEvent) {
        if (newEvent.Event_Type_gne__c == 'Grants' && ((oldEvent == null && newEvent.Therapeutic_Area_gne__c == null) || (oldEvent != null && (oldEvent.Therapeutic_Area_gne__c != newEvent.Therapeutic_Area_gne__c) && newEvent.Therapeutic_Area_gne__c == null))) {
            newEvent.Therapeutic_Area_gne__c.addError(System.label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Event__c.fields.Therapeutic_Area_gne__c.label);
            return true;
        }
        return false;
    }
}