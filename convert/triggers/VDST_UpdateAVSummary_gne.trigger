/** @date 3/15/2013
* @Author Pawel Sprysak
* @description Trigger for updating AV value on summary object and creating/deleting Event Dates and Creating Event Date Transactions after changing Event Start/End Date
*/
trigger VDST_UpdateAVSummary_gne on VDST_Event_gne__c (after insert, after update, before update) {
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_UpdateAVSummary_gne => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    if (Trigger.isBefore) {
        final Map<Id, AGS_ST_Dispute_Note_and_Attachment_gne__c> newDisputeNotes = new Map<Id, AGS_ST_Dispute_Note_and_Attachment_gne__c>();
        final Map<Id, AGS_Spend_Expense_Transaction_gne__c> disputedTxns = new Map<Id, AGS_Spend_Expense_Transaction_gne__c>();
        final AGS_Expense_Products_Interaction__c[] invalidatedProducts = new List<AGS_Expense_Products_Interaction__c>();
        final Map<Id, AGS_ST_DisputeResolver_gne__c> disputeResolvers = new Map<Id, AGS_ST_DisputeResolver_gne__c>();
        final Map<Id, AGS_ST_Dispute_List_gne__c> newDisputeLists = new Map<Id, AGS_ST_Dispute_List_gne__c>();
        final AGS_ST_DisputeManagement_gne__c[] newDisputes = new List<AGS_ST_DisputeManagement_gne__c>();
        final Map<String, VDST_Event_gne__c> evtsBySrcTxnId = new Map<String, VDST_Event_gne__c>();
        final Map<Id, User> evtOwners = new Map<Id, User>();
        final Note[] newNotes = new List<Note>();
        // collect all supplemented events
        for (VDST_Event_gne__c evt : Trigger.new) {
            if ((
                Trigger.isInsert ||
                evt.AGS_ST_Dispute_Management_gne__c == null &&
                evt.CurrentStatus_gne__c != Trigger.oldMap.get(evt.Id).CurrentStatus_gne__c
            ) && (
                evt.CurrentStatus_gne__c == VDST_Utils.EVENT_STATUS_CLOSED ||
                evt.CurrentStatus_gne__c == 'OCCURRED'
            ) && String.isNotBlank(evt.SourceTransactionID_gne__c)) {
                evtsBySrcTxnId.put(evt.SourceTransactionID_gne__c, evt);
            }
        }
        // collect transactions related to supplemented events
        disputedTxns.putAll(evtsBySrcTxnId.keySet().isEmpty() ? new AGS_Spend_Expense_Transaction_gne__c[]{ } : [
            SELECT
                Form_Of_Payment_gne__c,
                LogicalDeleteFlag_gne__c,
                Source_Transaction_ID_gne__c,
                Allocated_Transaction_Amount_gne__c,
                Nature_Of_Payment_gne__c, (
                    SELECT LogicalDeleteFlag__c, AGS_Brand_gne__r.Brand_Name__c
                    FROM AGS_expense_products_intercations1__r WHERE LogicalDeleteFlag__c = false
                )
            FROM AGS_Spend_Expense_Transaction_gne__c WHERE Source_Transaction_ID_gne__c IN :evtsBySrcTxnId.keySet()
            AND LogicalDeleteFlag_gne__c = false
        ]);
        // deactivate supplemented transactions and their products
        for (AGS_Spend_Expense_Transaction_gne__c txn : disputedTxns.values()) {
            for (AGS_Expense_Products_Interaction__c prod : txn.AGS_expense_products_intercations1__r) {
                prod.LogicalDeleteFlag__c = true;
                invalidatedProducts.add(prod);
            }
            evtOwners.put(evtsBySrcTxnId.get(txn.Source_Transaction_ID_gne__c).OwnerId, new User(Email = ''));
            txn.LogicalDeleteFlag_gne__c = true;
        }
        // collect emails for event owners
        evtOwners.putAll(evtOwners.isEmpty() ? new User[]{ } : [
            SELECT Id, Email FROM User WHERE Id IN :evtOwners.keySet() LIMIT :evtOwners.size()
        ]);
        // instantiate dispute resolvers
        for (Id evtOwnerId : evtOwners.keySet()) {
            disputeResolvers.put(evtOwnerId, new AGS_ST_DisputeResolver_gne__c(OwnerId = evtOwnerId));
        }
        // persist dispute resolvers
        insert disputeResolvers.values();
        // instantiate disputes
        for (AGS_Spend_Expense_Transaction_gne__c txn : disputedTxns.values()) {
            String brandNames = '';
            final Id evtOwnerId = evtsBySrcTxnId.get(txn.Source_Transaction_ID_gne__c).OwnerId;
            // concatenate all active brand names
            for (AGS_Expense_Products_Interaction__c prod : txn.AGS_expense_products_intercations1__r) {
                brandNames += prod.AGS_Brand_gne__r.Brand_Name__c + ',';
            }
            newDisputeLists.put(txn.Id, new AGS_ST_Dispute_List_gne__c(
                Drug_Name_gne__c = String.isBlank(brandNames) ? null : brandNames.substringBeforeLast(','),
                Amount_gne__c = txn.Allocated_Transaction_Amount_gne__c,
                Nature_Of_Payment_gne__c = txn.Nature_Of_Payment_gne__c,
                Form_Of_Payment_gne__c = txn.Form_Of_Payment_gne__c,
                AGS_Spend_Expense_Transaction_gne__c = txn.Id,
                Dispute_Date_gne__c = DateTime.Now(),
                Payment_Date_gne__c = Date.Today(),
                isPrivate_gne__c = true,
                OwnerId = evtOwnerId
            ));
            newDisputes.add(new AGS_ST_DisputeManagement_gne__c(
                Drug_Name_gne__c = String.isBlank(brandNames) ? null : brandNames.substringBeforeLast(','),
                Preferred_communication_value_gne__c = evtOwners.get(evtOwnerId).Email,
                Dispute_Resolver_gne__c = disputeResolvers.get(evtOwnerId).Id,
                Amount_gne__c = txn.Allocated_Transaction_Amount_gne__c,
                Nature_Of_Payment_gne__c = txn.Nature_Of_Payment_gne__c,
                Form_Of_Payment_gne__c = txn.Form_Of_Payment_gne__c,
                Internal_Status_gne__c = 'Resolved with Correction',
                Preferred_communication_method_gne__c = 'Email',
                AGS_Spend_Expense_Transaction_gne__c = txn.Id,
                Dispute_Date_gne__c = DateTime.Now(),
                External_Status_gne__c = 'Resolved',
                Payment_Date_gne__c = Date.Today(),
                Do_Not_Report_Flag_gne__c = true,
                Corrected_gne__c = false,
                OwnerId = evtOwnerId,
                isPrivate__c = true
            ));
        }
        // persist dispute lists (initial dispute snapshots)
        insert newDisputeLists.values();
        // populate references to initial snapshot for disputes
        for (AGS_ST_DisputeManagement_gne__c dm : newDisputes) {
            dm.Dispute_List_gne__c = newDisputeLists.get(dm.AGS_Spend_Expense_Transaction_gne__c).Id;
        }
        // persist disputes
        insert newDisputes;
        // populate reference to created disputes on related events and instantiate custom dispute notes
        for (AGS_ST_DisputeManagement_gne__c dm : newDisputes) {
            evtsBySrcTxnId.get(
                disputedTxns.get(dm.AGS_Spend_Expense_Transaction_gne__c).Source_Transaction_ID_gne__c
            ).AGS_ST_Dispute_Management_gne__c = dm.Id;
            newDisputeNotes.put(dm.Id, new AGS_ST_Dispute_Note_and_Attachment_gne__c(
                AGS_ST_Dispute_Management_gne__c = dm.Id,
                About_gne__c = 'HCP Dispute',
                isPrivate_gne__c = false,
                isHCP_gne__c = true
            ));
        }
        // persist custom dispute notes
        insert newDisputeNotes.values();
        // instantiate standard notes related to custom dispute notes
        for (AGS_ST_DisputeManagement_gne__c dm : newDisputes) {
            newNotes.add(new Note(
                Body = evtsBySrcTxnId.get(
                    disputedTxns.get(dm.AGS_Spend_Expense_Transaction_gne__c).Source_Transaction_ID_gne__c
                ).VendorEventID_gne__c,
                ParentId = newDisputeNotes.get(dm.Id).Id,
                Title = 'HCP Dispute Note',
                IsPrivate = false
            ));
        }
        // persist invalidated / disputed transactions and related invalidated products
        final sObject[] modifiedRecords = new sObject[]{ };
        modifiedRecords.addAll((sObject[]) invalidatedProducts);
        modifiedRecords.addAll((sObject[]) disputedTxns.values());
        update modifiedRecords;
        // persist standard dispute notes
        insert newNotes;
        if (Trigger.isUpdate) {
            VDST_Utils.updateDroppedEventUniqueIds(Trigger.new, Trigger.old);
        }
    }
    if (Trigger.isAfter) {
        try {
            // Prepare list containers
            List<VDST_EventDate_gne__c> eventDateToDelList = new List<VDST_EventDate_gne__c>();
            List<VDST_EventDate_gne__c> eventDateToInsList = new List<VDST_EventDate_gne__c>();
            Map<String, Double> eventIdToAmount = new Map<String, Double>();
            // Prepare list of Event Date objects to Insert or Remove after changing Event Start/End Dates
            // Check and update data
            if (VDST_Utils.prepareEventDateData(eventDateToDelList, eventDateToInsList, eventIdToAmount, Trigger.new, Trigger.newMap, Trigger.oldMap, Trigger.isInsert)) {
                return;
            } else {
                // DB methods
                delete eventDateToDelList;
                insert eventDateToInsList;
            }
            // Create Event Date Transactions
            VDST_Utils.createEventDateTransaction(eventDateToInsList, eventIdToAmount);
            if (Trigger.isUpdate) {
                // Update related values after changing Event data
                VDST_Utils.updateValuesAfterChangingEventData(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            }
            // Update AV transaction value after changing AV on Event
            VDST_Utils.updateAvTransaction(Trigger.new);
        } catch (Exception e) {
            for (VDST_Event_gne__c evt : Trigger.new) {
                evt.addError('Error while creating Event Dates');
            }
        }
    }
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_UpdateAVSummary_gne => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
}