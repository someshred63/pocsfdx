global without sharing class EMS_Canada_WS {

    global class ExpenseWrapper {
        webservice String eventTransactionId;
        webservice String sourceSystem;
        webservice String documentType;
        webservice Date postingDate;
        webservice String documentNumber;
        webservice Decimal documentLineNumber;
        webservice String costElement;
        webservice String costCenter;
        webservice String vendorId;
        webservice String vendorName;
        webservice Decimal conversionRate;
        webservice Decimal documentExpenseAmount;
        webservice String documentCurrencyKey;
        webservice Decimal countryExpenseAmount;
        webservice String countryCurrencyKey;
        webservice String debitCreditIndicator;
        webservice String concurReportKey;
        webservice String concurLineItemId;
        webservice Date expenseDate;
        webservice String concurExpenseType;
    }

    global class EventWrapper {
        webservice String unixID;
        webservice String emsEventID;
        webservice String costCenter;
        webservice String value;

        global EventWrapper(String unixID, String emsEventID, String costCenter, String value) {
            this.unixID = unixID;
            this.emsEventID = emsEventID;
            this.costCenter = costCenter;
            this.value = value;
        }
    }

    global class InteractionWrapper {
        webservice String unixID;
        webservice String interactionID;
        webservice String value;

        global InteractionWrapper(String unixID, String interactionID, String value) {
            this.unixID = unixID;
            this.interactionID = interactionID;
            this.value = value;
        }
    }

    global class ResultWrapper {
        webservice Integer errorCode;
        webservice String errorMessage;

        global ResultWrapper(Integer errorCode, String errorMessage) {
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }
    }

    private static Integer MAX_LENGTH = 64;
    private static Integer EVENT_SUB_TYPE_MAX_LENGTH = 10;
    private static Integer UNIX_ID_LENGTH = 8;

    private static Map<String, RecordType> getExpenseRecordTypes() {
        Map<String, RecordType> result = new Map<String, RecordType>();
        for (RecordType rt : [SELECT Name, DeveloperName FROM RecordType WHERE sObjectType = 'EMS_Expense_gne__c']) {
            result.put(rt.DeveloperName, rt);
        }

        return result;
    }

    private static Map<Decimal, EMS_Cost_Center_gne__c> getCostCenters() {
        Map<Decimal, EMS_Cost_Center_gne__c> result = new Map<Decimal, EMS_Cost_Center_gne__c>();
        for (EMS_Cost_Center_gne__c costCenter : [SELECT Id, Name FROM EMS_Cost_Center_gne__c]) {
            result.put(Decimal.valueOf(costCenter.Name), costCenter);
        }

        return result;
    }

    private static void notifyRequestorOwner(List<EMS_Expense_gne__c> aribaExpenses) {
        for (EMS_Expense_gne__c exp :aribaExpenses) {
            EMS_Email.prepareSingleEmail('EMS_Payment_Notification', exp.EMS_Transaction_gne__c, exp.EMS_Event_gne__r.Event_Requestor_gne__c);
            EMS_Email.prepareSingleEmail('EMS_Payment_Notification', exp.EMS_Transaction_gne__c, exp.EMS_Event_gne__r.Event_Owner_gne__c);
        }
        EMS_Email.send();
    }

    webservice static List<ResultWrapper> loadExpenses(List<ExpenseWrapper> expenses) {
        Map<String, RecordType> expenseRecordTypes = getExpenseRecordTypes();
        Map<Decimal, EMS_Cost_Center_gne__c> costCenters = getCostCenters();

        List<ResultWrapper> result = new List<ResultWrapper>();
        List<EMS_Expense_gne__c> expensesToAdd = new List<EMS_Expense_gne__c>();

        Set<String> relatedEventsNames = new Set<String>();
        Set<String> relatedTransactionNames = new Set<String>();
        Set<String> relatedInteractionNames = new Set<String>();
        Set<String> relatedTravelNames = new Set<String>();
        Set<String> relatedPaymentRequestNames = new Set<String>();
        Set<String> expenseDocumentNumbers = new Set<String>();

        // fetch related events / transactions
        for (ExpenseWrapper expense : expenses) {
            String eventTransactionId = expense.eventTransactionId; // It would be safer to use trim() here
            if (String.isNotBlank(eventTransactionId)) {
                if (eventTransactionId.startsWith('E')) {
                    // event ID
                    relatedEventsNames.add(expense.eventTransactionId);
                } else if (eventTransactionId.startsWith('I')) {
                    // transaction ID
                    relatedTransactionNames.add(expense.eventTransactionId);
                } else if (eventTransactionId.startsWith('C')) {
                    // interaction ID
                    relatedInteractionNames.add(expense.eventTransactionId);
                } else if (eventTransactionId.startsWith('T')) {
                    // travel ID
                    relatedTravelNames.add(expense.eventTransactionId);
                } else if (eventTransactionId.startsWith('PR')) {
                    // payment request ID
                    relatedPaymentRequestNames.add(expense.eventTransactionId);
                }
            }

            if(String.isNotBlank(expense.documentNumber)) {
                expenseDocumentNumbers.add(expense.documentNumber);
            }
        }

        // query related events
        Map<String, Id> relatedEventsMap = new Map<String, Id>();
        for (EMS_Event__c event : [SELECT Name, Id FROM EMS_Event__c WHERE Name IN :relatedEventsNames]) {
            relatedEventsMap.put(event.Name, event.Id);
        }

        Map<String, Id> relatedTransactionsMap = new Map<String, Id>();
        for (EMS_Transaction_gne__c trans : [SELECT Name, EMS_Event_gne__c FROM EMS_Transaction_gne__c WHERE Name IN :relatedTransactionNames]) {
            relatedEventsMap.put(trans.Name, trans.EMS_Event_gne__c);
            relatedTransactionsMap.put(trans.Name, trans.Id);
        }

        Map<String, Id> relatedInteractionsMap = new Map<String, Id>();
        for (Call2_vod__c interaction : [SELECT Name FROM Call2_vod__c WHERE Name IN :relatedInteractionNames]) {
            relatedInteractionsMap.put(interaction.Name, interaction.Id);
        }

        Map<String, Id> relatedTravelsMap = new Map<String, Id>();
        for (EMS_Travel_gne__c travel : [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Name IN :relatedTravelNames]) {
            relatedEventsMap.put(travel.Name, travel.EMS_Event_gne__c);
            relatedTravelsMap.put(travel.Name, travel.Id);
        }

        Map<String, Id> relatedPaymentRequestsMap = new Map<String, Id>();
        for (EMS_Speaker_Role_gne__c paymentRequst : [SELECT Name, EMS_Event_gne__c FROM EMS_Speaker_Role_gne__c WHERE Name IN :relatedPaymentRequestNames]) {
            relatedEventsMap.put(paymentRequst.Name, paymentRequst.EMS_Event_gne__c);
            relatedPaymentRequestsMap.put(paymentRequst.Name, paymentRequst.Id);
        }

        // select existing expenses to find duplicates
        Map<String, EMS_Expense_gne__c> existingExpensesMap = new Map<String, EMS_Expense_gne__c>();
        for (EMS_Expense_gne__c expense : [SELECT Document_No_gne__c, Document_Line_No_gne__c, Document_Type_gne__c FROM EMS_Expense_gne__c WHERE Document_No_gne__c IN :expenseDocumentNumbers]) {
            existingExpensesMap.put(expense.Document_No_gne__c + expense.Document_Line_No_gne__c + expense.Document_Type_gne__c, expense);
        }

        for (ExpenseWrapper expense : expenses) {
            EMS_Expense_gne__c newExpense;

            if (existingExpensesMap.containsKey(expense.documentNumber + String.valueOf(expense.documentLineNumber) + expense.documentType)) {
                newExpense = existingExpensesMap.get(expense.documentNumber + String.valueOf(expense.documentLineNumber) + expense.documentType);
            } else {
                newExpense = new EMS_Expense_gne__c();
            }

            // set the relationships and appropriate record type
            if (expense.sourceSystem.equalsIgnoreCase('Concur') || expense.sourceSystem.equalsIgnoreCase('SAP JE')) {
                newExpense.RecordTypeId = expenseRecordTypes.get('Concur_Expense').Id;
                // interaction ids
            } else {
                newExpense.RecordTypeId = expenseRecordTypes.get('Ariba_Expense').Id;
            }

            String eventTransactionId = expense.eventTransactionId;
            if (!String.isEmpty(eventTransactionId)) {
                if (eventTransactionId.startsWith('E')) {
                    // event ID
                    newExpense.Event_ID_gne__c = expense.eventTransactionId;
                } else if (eventTransactionId.startsWith('I')) {
                    // transaction ID
                    newExpense.Transaction_ID_gne__c = expense.eventTransactionId;
                } else if (eventTransactionId.startsWith('C')) {
                    // interatcion ID
                    newExpense.Interaction_ID_gne__c = expense.eventTransactionId;
                } else if (eventTransactionId.startsWith('T')) {
                    // travel ID
                    newExpense.Travel_ID_gne__c = expense.eventTransactionId;
                } else if (eventTransactionId.startsWith('PR')) {
                    // Payment Request ID
                    newExpense.Payment_Request_ID_gne__c = expense.eventTransactionId;
                } else {
                    // fill transaction ID for others
                    newExpense.Transaction_ID_gne__c = expense.eventTransactionId;
                }
            }

            // set the related event, transcation, interaction and cost center
            newExpense.EMS_Event_gne__c = relatedEventsMap.get(expense.eventTransactionId);
            newExpense.EMS_Transaction_gne__c = relatedTransactionsMap.get(expense.eventTransactionId);
            newExpense.EMS_Payment_Request_gne__c = relatedPaymentRequestsMap.get(expense.eventTransactionId);
            newExpense.EMS_Travel_gne__c = relatedTravelsMap.get(expense.eventTransactionId);
            newExpense.Call2_vod__c = relatedInteractionsMap.get(expense.eventTransactionId);

            if (costCenters.get(Decimal.valueOf(expense.costCenter)) != null) {
                newExpense.EMS_Cost_Center_gne__c = costCenters.get(Decimal.valueOf(expense.costCenter)).Id;
            }

            // set all other fields
            newExpense.Source_System_gne__c = expense.sourceSystem;
            newExpense.Document_Type_gne__c = expense.documentType;
            newExpense.Posting_Date_gne__c = expense.postingDate;
            newExpense.Document_No_gne__c = expense.documentNumber;
            newExpense.Document_Line_No_gne__c = expense.documentLineNumber;
            newExpense.Cost_Element_GL_Account_gne__c = expense.costElement;
            newExpense.Cost_Center_gne__c = expense.costCenter;
            newExpense.Vendor_ID_gne__c = expense.vendorId;
            newExpense.Recipient_Vendor_Name_gne__c = expense.vendorName;
            newExpense.Conversion_Rate_gne__c = expense.conversionRate;

            newExpense.Debit_Credit_indicator_gne__c = expense.debitCreditIndicator;
            if (expense.debitCreditIndicator == 'H') {
                // the amount should be negative for 'H' expenses
                newExpense.Document_Expense_Amount__c = (expense.documentExpenseAmount - 2 * expense.documentExpenseAmount);
                newExpense.Country_Expense_Amount_gne__c = (expense.countryExpenseAmount - 2 * expense.countryExpenseAmount);
            } else {
                newExpense.Document_Expense_Amount__c = expense.documentExpenseAmount;
                newExpense.Country_Expense_Amount_gne__c = expense.countryExpenseAmount;
            }
            newExpense.Country_Currency_Key_gne__c = expense.countryCurrencyKey;
            newExpense.Document_Currency_Key_gne__c = expense.documentCurrencyKey;
            newExpense.Concur_Report_Key_gne__c = expense.concurReportKey;
            newExpense.Concur_Line_Item_ID_gne__c = expense.concurLineItemId;
            newExpense.Expense_Date_gne__c = expense.expenseDate;
            newExpense.Concur_Expense_Type_gne__c = expense.concurExpenseType;

            expensesToAdd.add(newExpense);
        }
        // skip validation rules
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;

        Database.UpsertResult[] upsertResults;
        if (expensesToAdd.size() > 0) {
            upsertResults = Database.upsert(expensesToAdd, false);
        }

        List<Id> insertedExpenses = new List<Id>();
        List<EMS_Expense_gne__c> failedExpensesToAdd = new List<EMS_Expense_gne__c>();
        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (!upsertResults[i].isSuccess()) {
                expensesToAdd[i].Error_Message_gne__c = EMS_Util.concatenateErrorMessages(upsertResults[i]);
                failedExpensesToAdd.add(expensesToAdd[i]);
                result.add(new ResultWrapper(upsertResults[i].getErrors()[0].getStatusCode().ordinal(), upsertResults[i].getErrors()[0].getMessage()));
            } else {
                result.add(new ResultWrapper(0, null));
                // if the expense was inserted notify event requestor/owner
                insertedExpenses.add(upsertResults[i].getId());
            }
        }
        // loop through failed expenses and clear the references to other objects
        for (EMS_Expense_gne__c expense : failedExpensesToAdd) {
            expense.EMS_Event_gne__c = null;
            expense.EMS_Transaction_gne__c = null;
            expense.EMS_Payment_Request_gne__c = null;
            expense.EMS_Travel_gne__c = null;
            expense.Call2_vod__c = null;
        }
        // re-upsert failed expenses
        if (!failedExpensesToAdd.isEmpty()) {
            Database.upsert(failedExpensesToAdd, false);
        }

        List<EMS_Expense_gne__c> insertedAribaExpenses = [
                SELECT Id, EMS_Transaction_gne__c, EMS_Event_gne__r.Event_Requestor_gne__c, EMS_Event_gne__r.Event_Owner_gne__c
                FROM EMS_Expense_gne__c
                WHERE Id IN :insertedExpenses AND Source_System_gne__c = 'Ariba' AND EMS_Event_gne__c != null AND EMS_Transaction_gne__c != null
        ];

        if (!insertedAribaExpenses.isEmpty()) {
            notifyRequestorOwner(insertedAribaExpenses);
        }

        return result;
    }

    private static String prepareValue(EMS_Event__c event) {
        String eventStartDate = String.valueOf(event.Start_Date_gne__c.month()) + '/' + String.valueOf(event.Start_Date_gne__c.day());
        String eventSubType = event.Event_Sub_Type_gne__c;
        String value = '-' + eventStartDate + '-' + event.Number_Of_Attendees_gne__c + 'Att-';
        Integer remainingCharacters = MAX_LENGTH - value.length();
        if (event.Event_Name_gne__c.length() > (remainingCharacters - EVENT_SUB_TYPE_MAX_LENGTH)) {
            value = event.Event_Name_gne__c.substring(0, remainingCharacters - EVENT_SUB_TYPE_MAX_LENGTH) + value + eventSubType.substring(0, EVENT_SUB_TYPE_MAX_LENGTH);
        } else {
            value = event.Event_Name_gne__c + value;
            remainingCharacters = MAX_LENGTH - value.length();
            if (eventSubType.length() > remainingCharacters) {
                value += eventSubType.substring(0, remainingCharacters);
            } else {
                value += eventSubType;
            }
        }

        return value;
    }

    private static void addLevel2AndLevel3(String unixId, EMS_Event__c event, List<EventWrapper> result) {
        String value = prepareValue(event);
        if (!String.isEmpty(unixId)) {
            if (unixId.length() > UNIX_ID_LENGTH) {
                unixId = unixId.substring(0, UNIX_ID_LENGTH);
            }
            // level 2
            result.add(new EventWrapper(unixId, event.Name, null, value));
            // level 3
            for (EMS_Budget_Allocation_gne__c ba : event.EMS_Budget_Allocations__r) {
                result.add(new EventWrapper(unixId, event.Name, ba.Cost_Center_gne__c, ba.Product_Indication_gne__c + '-' + ba.Percentage_Contribution_gne__c + 'P'));
            }
        }
    }

    @ReadOnly
    webservice static List<EventWrapper> getEMSEvents(Boolean dummy) {
        List<EventWrapper> result = new List<EventWrapper>();
        Set<String> externalIds = new Set<String>();

        List<String> includedStatuses = new List<String>{
                'Med Ops Approved', 'Awaiting Signature from HCP', 'Signed Agreement Received', 'Payment Request Initiated', 'Closed'
        };
        List<String> includedSubTypes = new List<String>();

        // query configuration to check allowed sub-types
        for (EMS_Event_Configuration_gne__c eventConfig : [SELECT Event_Sub_Type_gne__c FROM EMS_Event_Configuration_gne__c WHERE Is_Visible_in_Concur_gne__c = true]) {
            includedSubTypes.add(eventConfig.Event_Sub_Type_gne__c);
        }

        List<EMS_Event__c> validEvents = [
                SELECT Id, Name, Event_Name_gne__c, Start_Date_gne__c, Event_Sub_Type_gne__c, Number_Of_Attendees_gne__c, Event_Owner_gne__r.External_ID_gne__c, Event_Requestor_gne__r.External_ID_gne__c, (SELECT Name, User_gne__r.External_ID_gne__c FROM EMS_Roche_Attendees__r WHERE Is_Watcher_gne__c = false), (SELECT Cost_Center_gne__c, Product_Indication_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocations__r)
                FROM EMS_Event__c
                WHERE Status_gne__c IN :includedStatuses AND Event_Sub_Type_gne__c IN :includedSubTypes AND End_Date_gne__c = THIS_YEAR
        ];
        for (EMS_Event__c event : validEvents) {
            for (EMS_Roche_Attendee_gne__c attendee : event.EMS_Roche_Attendees__r) {
                externalIds.add(attendee.User_gne__r.External_ID_gne__c);
            }

            externalIds.add(event.Event_Owner_gne__r.External_ID_gne__c);
            externalIds.add(event.Event_Requestor_gne__r.External_ID_gne__c);
        }

        for (String unixId : externalIds) {
            // level 1
            // exclude empty external ids
            if (!String.isEmpty(unixId)) {
                if (unixId.length() > UNIX_ID_LENGTH) {
                    unixId = unixId.substring(0, UNIX_ID_LENGTH);
                }
                result.add(new EventWrapper(unixId, null, null, unixId));
            }
        }

        for (EMS_Event__c event : validEvents) {

            Set<String> attendeeExternalIds = new Set<String>();

            for (EMS_Roche_Attendee_gne__c attendee : event.EMS_Roche_Attendees__r) {
                addLevel2AndLevel3(attendee.User_gne__r.External_ID_gne__c, event, result);
                attendeeExternalIds.add(attendee.User_gne__r.External_ID_gne__c);
            }

            // include requestor/owner
            if (!attendeeExternalIds.contains(event.Event_Owner_gne__r.External_ID_gne__c)) {
                addLevel2AndLevel3(event.Event_Owner_gne__r.External_ID_gne__c, event, result);
            }
            if (!attendeeExternalIds.contains(event.Event_Requestor_gne__r.External_ID_gne__c)) {
                addLevel2AndLevel3(event.Event_Requestor_gne__r.External_ID_gne__c, event, result);
            }
        }
        return result;
    }

    @ReadOnly
    webservice static List<InteractionWrapper> getSFDCInteractions(Boolean dummy) {
        List<InteractionWrapper> result = new List<InteractionWrapper>();
        Date prevDays = Date.today().addDays(-90);
        Map<Id, User> ownersMap = new Map<Id, User>([SELECT Id, External_ID_gne__c FROM User]);
        Set<String> ownerExternalIds = new Set<String>();

        List<Call2_vod__c> canadianInteractions = [
                SELECT Name, Attendees_vod__c, Call_Datetime_vod__c,
                        Account_vod__r.Name, Account_vod__c,
                        EMS_International_Speaker_gne__c, EMS_International_Speaker_gne__r.Name, Parent_Call_vod__c,
                        RecordType.Name, OwnerId
                FROM Call2_vod__c
                WHERE Region_Code_gne__c = 2 AND Interaction_Type_gne__c = 'Face to Face'
                AND Parent_Call_vod__c = null AND IsDeleted = false AND Interaction_Status_gne__c = 'Completed'
                //AND Attendees_vod__c > 0
                AND Call_Datetime_vod__c = THIS_YEAR AND (Call_Datetime_vod__c = LAST_90_DAYS OR Call_Datetime_vod__c = NEXT_90_DAYS)
                ORDER BY Call_Datetime_vod__c
        ];

        for (Call2_vod__c interaction : canadianInteractions) {
            ownerExternalIds.add(ownersMap.get(interaction.OwnerId).External_ID_gne__c);
        }

        for (String unixId : ownerExternalIds) {
            // level 1
            // exclude empty external ids
            if (!String.isEmpty(unixId)) {
                if (unixId.length() > UNIX_ID_LENGTH) {
                    unixId = unixId.substring(0, UNIX_ID_LENGTH);
                }
                result.add(new InteractionWrapper(unixId, null, unixId));
            }
        }

        for (Call2_vod__c interaction : canadianInteractions) {
            // level 2
            String interactionDate = String.valueOf(interaction.Call_Datetime_vod__c.month()) + '/' + String.valueOf(interaction.Call_Datetime_vod__c.day());
            String value = interaction.Name + '-' + interactionDate + '-';
            String attendeesPart = '-Att' + interaction.Attendees_vod__c;
            Integer remainingCharacters = MAX_LENGTH - value.length() - attendeesPart.length();
            String accountName;
            if (interaction.EMS_International_Speaker_gne__c != null) {
                accountName = interaction.EMS_International_Speaker_gne__r.Name;
            } else {
                accountName = interaction.Account_vod__r.Name;
            }

            if (accountName.length() > remainingCharacters) {
                value = value + accountName.substring(0, remainingCharacters) + attendeesPart;
            } else {
                value = value + accountName + attendeesPart;
            }
            // exclude empty external ids
            if (!String.isEmpty(ownersMap.get(interaction.OwnerId).External_ID_gne__c)) {
                String unixId = ownersMap.get(interaction.OwnerId).External_ID_gne__c;
                if (unixId.length() > UNIX_ID_LENGTH) {
                    unixId = unixId.substring(0, UNIX_ID_LENGTH);
                }
                result.add(new InteractionWrapper(unixId, interaction.Name, value));
            }
        }
        return result;
    }
}