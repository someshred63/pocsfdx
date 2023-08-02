public with sharing class EMS_Roche_Support_Documentation_Ext {

    public String eventID {
        get {
            return event.ID;
        }
    }
    private EMS_Event__c event;

    public EMS_Roche_Support_Documentation_Ext(ApexPages.StandardController stdController) {
        event = (EMS_Event__c) stdController.getRecord();
    }

    public Boolean getCanEditDocumentation() {
        return EMS_Access.isRocheDocumentationEditable(event);
    }

    @RemoteAction
    public static EMS_Remote_Response agreeWithSupportDocumentation(List<String> statementIDs, String eventID, Boolean isChecked, String statementText) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        Savepoint sp = Database.setSavepoint();
        try {
            List<EMS_Checklist_Response_gne__c> responses = [SELECT Is_Checked_gne__c, Text_gne__c, EMS_Checklist_gne__c FROM EMS_Checklist_Response_gne__c WHERE EMS_Event_gne__c = :eventID AND EMS_Checklist_gne__c = :statementIDs];
            Map<String, EMS_Checklist_Response_gne__c> statementID_response = new Map<String, EMS_Checklist_Response_gne__c>();
            for (EMS_Checklist_Response_gne__c checklistResponse :responses) {
                statementID_response.put(checklistResponse.EMS_Checklist_gne__c, checklistResponse);
            }

            List<EMS_Checklist_Response_gne__c> responsesToUpdate = new List<EMS_Checklist_Response_gne__c>();
            List<EMS_Checklist_Response_gne__c> responsesToInsert = new List<EMS_Checklist_Response_gne__c>();
            // double "for" loop might be avoid by using Map collection, we know that statementIDs is not a large array
            for (String statementID : statementIDs) {
                if (statementID_response.containsKey(statementID)) {
                    EMS_Checklist_Response_gne__c checklistResponse = statementID_response.get(statementID);
                    if (isChecked != null) {
                        checklistResponse.Is_Checked_gne__c = isChecked;
                    }
                    checklistResponse.Text_gne__c = (String.isNotBlank(statementText)) ? statementText : '';
                    //update
                    responsesToUpdate.add(checklistResponse);
                } else {
                    //insert
                    if (isChecked == null) {
                        isChecked = false;
                    }
                    responsesToInsert.add(new EMS_Checklist_Response_gne__c(
                            EMS_Event_gne__c = eventID,
                            EMS_Checklist_gne__c = statementID,
                            Is_Checked_gne__c = isChecked,
                            Text_gne__c = statementText
                    ));
                }
            }
            insert responsesToInsert;
            update responsesToUpdate;

            response.isSuccess = true;
        } catch (DMLException ex) {
            Database.rollback(sp);

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Display an error which is longer than others
                response.addError('Error occured while saving the Roche Support Documentation: ' + ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.addError('Error occured while saving the Roche Support Documentation: ' + ex.getMessage());
            Database.rollBack(sp);
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response prepareSupportDocumentation(String eventType, String eventSubtype, String eventID) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;

        List<EMS_Checklist_gne__c> documentation = [
                SELECT Id, Depends_On_gne__c, Has_Depending_Items_gne__c, Has_Parent_gne__c, Index_gne__c, Is_Checked_gne__c, Is_Note_gne__c, Is_One_Choice_gne__c,
                        Parent_Index_gne__c, Is_All_Choice_gne__c, Is_Multi_Choice_gne__c, Is_Parent_gne__c, Item_gne__c, Requires_Input_gne__c
                FROM EMS_Checklist_gne__c
                WHERE Event_Type_gne__c = :eventType
                AND Event_Sub_Type_gne__c = :eventSubtype
                AND Type_gne__c = 'Documentation for Roche Support'
                AND Is_Active_gne__c = true
                ORDER BY Index_gne__c
        ];

        List<EMS_Checklist_gne__c> documentationNotes = [
                SELECT Item_gne__c
                FROM EMS_Checklist_gne__c
                WHERE Event_Type_gne__c = :eventType
                AND Event_Sub_Type_gne__c = :eventSubtype
                AND Type_gne__c = 'Compliance Checklist'
                AND Is_Note_gne__c = true
                AND Is_Active_gne__c = true
                ORDER BY Index_gne__c
        ];

        List<EMS_Checklist_Response_gne__c> documentationResponses = [SELECT Is_Checked_gne__c, Text_gne__c, EMS_Checklist_gne__c FROM EMS_Checklist_Response_gne__c WHERE EMS_Event_gne__c = :eventID AND EMS_Checklist_gne__c IN :documentation];
        Map<Id, EMS_Checklist_Response_gne__c> responsesMap = new Map<Id, EMS_Checklist_Response_gne__c>();
        for (EMS_Checklist_Response_gne__c dr : documentationResponses) {
            responsesMap.put(dr.EMS_Checklist_gne__c, dr);
        }

        List<EMS_Event_Ext.ComplianceRecord> supportDocumentation = new List<EMS_Event_Ext.ComplianceRecord>();
        for (EMS_Checklist_gne__c doc :documentation) {
            String itemText = '';
            Boolean checked = false;
            if (responsesMap.get(doc.Id) != null) {
                itemText = responsesMap.get(doc.Id).Text_gne__c;
                checked = responsesMap.get(doc.Id).Is_Checked_gne__c;
            }
            supportDocumentation.add(new EMS_Event_Ext.ComplianceRecord(
                    doc,
                    doc.Index_gne__c,
                    doc.Item_gne__c,
                    doc.Is_Parent_gne__c,
                    doc.Has_Parent_gne__c,
                    checked,
                    doc.Is_One_Choice_gne__c,
                    doc.Is_Multi_Choice_gne__c,
                    doc.Is_All_Choice_gne__c,
                    doc.Requires_Input_gne__c,
                    itemText,
                    doc.Depends_On_gne__c,
                    doc.Has_Depending_Items_gne__c,
                    doc.Parent_Index_gne__c
            ));
        }

        if (supportDocumentation.isEmpty() == false) {
            response.isSuccess = true;
            response.supportDocumentation = supportDocumentation;
        } else {
            response.addError('There are no Roche Support Documentation records.');
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response validateSupportDocumentation(String evType, String evSubtype, String evId) {
        List<EMS_Checklist_gne__c> checklist = [
                SELECT Is_Dependent_Required_gne__c, Depends_On_gne__c, Has_Depending_Items_gne__c, Has_Parent_gne__c, Index_gne__c, Is_Checked_gne__c, Is_Note_gne__c,
                        Is_One_Choice_gne__c, Parent_Index_gne__c, Is_All_Choice_gne__c, Is_Multi_Choice_gne__c, Is_Parent_gne__c, Item_gne__c, Requires_Input_gne__c
                FROM EMS_Checklist_gne__c
                WHERE Event_Type_gne__c = :evType
                AND Event_Sub_Type_gne__c = :evSubtype
                AND Type_gne__c = 'Documentation for Roche Support'
                AND Is_Active_gne__c = true
                AND Is_Note_gne__c = false
                ORDER BY Index_gne__c
        ];

        List<EMS_Checklist_Response_gne__c> responses = [
                SELECT Is_Checked_gne__c, Text_gne__c, EMS_Checklist_gne__c
                FROM EMS_Checklist_Response_gne__c
                WHERE EMS_Event_gne__c = :evId AND EMS_Checklist_gne__c IN :checklist
        ];
        Map<Id, EMS_Checklist_Response_gne__c> responsesMap = new Map<Id, EMS_Checklist_Response_gne__c>();
        for (EMS_Checklist_Response_gne__c response : responses) {
            responsesMap.put(response.EMS_Checklist_gne__c, response);
        }

        // prepare record
        List<EMS_Event_Ext.ComplianceRecord> documentation = new List<EMS_Event_Ext.ComplianceRecord>();
        for (EMS_Checklist_gne__c checklistItem : checklist) {
            String itemText = '';
            Boolean checked = false;
            if (responsesMap.get(checklistItem.Id) != null) {
                itemText = responsesMap.get(checklistItem.Id).Text_gne__c;
                checked = responsesMap.get(checklistItem.Id).Is_Checked_gne__c;
            }

            if (checklistItem.Depends_On_gne__c == null || documentation.get(Integer.valueOf(checklistItem.Depends_On_gne__c) - 1).isChecked) {
                documentation.add(new EMS_Event_Ext.ComplianceRecord(
                        checklistItem,
                        checklistItem.Index_gne__c,
                        checklistItem.Item_gne__c,
                        checklistItem.Is_Parent_gne__c,
                        checklistItem.Has_Parent_gne__c,
                        checked,
                        checklistItem.Is_One_Choice_gne__c,
                        checklistItem.Is_Multi_Choice_gne__c,
                        checklistItem.Is_All_Choice_gne__c,
                        checklistItem.Requires_Input_gne__c,
                        itemText,
                        checklistItem.Depends_On_gne__c,
                        checklistItem.Has_Depending_Items_gne__c,
                        checklistItem.Parent_Index_gne__c
                ));
            }
        }

        // perform a validation
        List<String> errorMessages = new List<String>();
        Map<Decimal, List<Boolean>> parentToChildResponses = new Map<Decimal, List<Boolean>>();
        for (EMS_Event_Ext.ComplianceRecord doc : documentation) {
            // Check if required text fields are filled in
            if (!doc.isParent && !doc.hasParent && !doc.isChecked) {
                errorMessages.add('\n"' + doc.name.stripHtmlTags().removeEnd(':').stripHtmlTags() + '" - value should be checked.');
            } else if (doc.hasParent) {
                if (parentToChildResponses.get(doc.parentIndex) == null) {
                    parentToChildResponses.put(doc.parentIndex, new List<Boolean>());
                }
                parentToChildResponses.get(doc.parentIndex).add(doc.isChecked);
            }
            if (doc.checklistItem.Item_gne__c.contains('Additional companies involved') && doc.isChecked == true) {
            	if(String.isBlank(doc.itemText)) {
            		errorMessages.add('"' + doc.name.stripHtmlTags().removeEnd(':').stripHtmlTags() + '" - field should be filled in');
            	} else {
	                Pattern p = Pattern.compile('[1-9]{1}|10');
	                Matcher m = p.matcher(doc.itemText.trim());
	                Boolean isValid = m.matches();
	                if (!isValid) {
	                    errorMessages.add('"' + doc.name.stripHtmlTags().removeEnd(':').stripHtmlTags() + '" - field should be filled in with values from 1 to 10');
	                }
            	}
            }
            if (doc.checklistItem.Item_gne__c.contains('Other body is event organizer') && doc.isChecked == true && String.isBlank(doc.itemText)) {
                errorMessages.add('"' + doc.name.stripHtmlTags().removeEnd(':').stripHtmlTags() + '" - field should be filled in.');
            }
        }

        // loop through the checklist - check parents (only if the validation has not failed yet)
        for (EMS_Event_Ext.ComplianceRecord doc : documentation) {
            String checklistItemName = doc.name.stripHtmlTags();
            if (doc.isParent) {
                if (!doc.isChecked) {
                    errorMessages.add('"' + doc.name.stripHtmlTags().removeEnd(':').stripHtmlTags() + '" - value should be checked.');
                }
                if (doc.isOneChoice) {
                    Boolean combinedValue = false;
                    for (Boolean response : parentToChildResponses.get(doc.index)) {
                        if (combinedValue && response) {
                            errorMessages.add('"' + checklistItemName.stripHtmlTags() + '" - Only one item needs to be checked');
                        }
                        combinedValue = combinedValue || response;
                    }
                    if (!combinedValue) {
                        errorMessages.add('"' + checklistItemName.stripHtmlTags() + '" - At least one item needs to be checked');
                    }
                } else if (doc.isMultiChoice) {
                    Boolean combinedValue = false;
                    for (Boolean response : parentToChildResponses.get(doc.index)) {
                        combinedValue = combinedValue || response;
                    }
                    if (!combinedValue) {
                        errorMessages.add('"' + checklistItemName.stripHtmlTags() + '" - At least one item needs to be checked');
                    }
                } else if (doc.isAllChoice) {
                    for (Boolean response : parentToChildResponses.get(doc.index)) {
                        if (!response) {
                            errorMessages.add('"' + checklistItemName.stripHtmlTags() + '" - All the items need to be checked');
                        }
                    }
                }
            }
        }

        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = (errorMessages.size() == 0);
        response.errorMessages = errorMessages;
        return response;
    }
}