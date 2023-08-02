public with sharing class GNE_SFA2_PFG_Transaction_Field_Update
{
    //Dominik Wasilewski start
    public static final String TO_USER_FIELD = 'To_User_gne__c';
    public static final String FROM_USER_FIELD = 'From_User_gne__c';
    public static final String VENDOR_FIELD = 'Vendor_gne__c';
    public static final String SL_ERROR = 'Storage Location Approval is pending for the User: ';
    private static final String DEFAULT_DESIGNATION = 'MD';

    public static void onBeforeInsert(List<SFA2_PFG_Transaction_gne__c> triggerNew)
    {
        GNE_SFA2_PFG_Util.cacheCallDetails(triggerNew, true);
        GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(
            GNE_SFA2_PFG_Util.callDetailsCache!=null ? GNE_SFA2_PFG_Util.callDetailsCache.values() : new List<Call_PFG_Detail_gne__c>());
        populateTransactionFields(triggerNew, null);
        GNE_SFA2_PFG_Util.clearPfgToTerritoryCache();
        GNE_SFA2_PFG_Util.cacheStorageLocations(triggerNew,false);
        sortAndProcessTransactions(triggerNew, null, null, false);
        setDefaultDesignationForEmptyField(triggerNew);
        truncateZipCode(triggerNew);
        removeNonASCIIcharsFromAddressFields(triggerNew);
    }

    public static void onBeforeUpdate(Map<Id, SFA2_PFG_Transaction_gne__c> triggerNewMap, Map<Id, SFA2_PFG_Transaction_gne__c> triggerOldMap)
    {
    	GNE_SFA2_PFG_Util.cacheCallDetails(triggerNewMap.values(), true);
        populateTransactionFields(triggerNewMap.values(),triggerOldMap);
        GNE_SFA2_PFG_Util.cacheStorageLocations(triggerNewMap.values(),true);
        sortAndProcessTransactions(null,triggerNewMap, triggerOldMap, true);
        setDefaultDesignationForEmptyField(triggerNewMap.values());
        truncateZipCode(triggerNewMap.values());
        removeNonASCIIcharsFromAddressFields(triggerNewMap.values());
    }

    private static void sortAndProcessTransactions(List<SFA2_PFG_Transaction_gne__c> beforeInsertTransactions, Map<Id, SFA2_PFG_Transaction_gne__c> triggerNewMap, Map<Id, SFA2_PFG_Transaction_gne__c> triggerOldMap, Boolean isUpdated) {
        List<SFA2_PFG_Transaction_gne__c> transactionsToProcess = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> transferTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> orderCreatedTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> returnTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> disbursementTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> dtpOrderTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> adjustmentTransactions = new List<SFA2_PFG_Transaction_gne__c>();

        if(triggerOldMap != null && triggerOldMap.size()>0 && isUpdated == true) {
            List<String> compareFields = new List<String>();
            compareFields.add(TO_USER_FIELD);
            compareFields.add(FROM_USER_FIELD);
            compareFields.add(VENDOR_FIELD);
            transactionsToProcess = GNE_SFA2_PFG_Util.compareAndReturnDiff(triggerOldMap, triggerNewMap, compareFields);
            processAddressDetailsForAllocationTransfer(triggerNewMap, triggerOldMap);
        } else if(isUpdated == false) {
            transactionsToProcess = beforeInsertTransactions;
        }

        for(SFA2_PFG_Transaction_gne__c trx : transactionsToProcess) {
        	String recTypeName = GNE_SFA2_PFG_Util.getTransactionRecordTypeName(trx.RecordTypeId);

        	if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER && trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
                allocationTransferTransactions.add(trx);
        	} else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER) {
            	transferTransactions.add(trx);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER && trx.Received_Quantity_gne__c == 0) {
            	orderCreatedTransactions.add(trx);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN) {
            	returnTransactions.add(trx);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT) {
            	disbursementTransactions.add(trx);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF || recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER) {
            	dtpOrderTransactions.add(trx);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT) {
            	adjustmentTransactions.add(trx);
            }
        }

        if(!allocationTransferTransactions.isEmpty()) {
            processAllocationTransfers(allocationTransferTransactions, isUpdated);
        }

        if(!transferTransactions.isEmpty()) {
            processTransfers(transferTransactions);
        }

        if(!orderCreatedTransactions.isEmpty()) {
            processOrders(orderCreatedTransactions);
        }

        if(!returnTransactions.isEmpty()) {
            processReturns(returnTransactions);
        }

        if(!disbursementTransactions.isEmpty()) {
            processDisbursements(disbursementTransactions);
        }

        if(!dtpOrderTransactions.isEmpty()) {
            processDtpOrder(dtpOrderTransactions);
        }

        if(!adjustmentTransactions.isEmpty()) {
            processAdjustments(adjustmentTransactions);
        }

    }
    private static void processAllocationTransfers(List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactions, Boolean isUpdated)
    {
        setLOAandUncertifiedFlags(true, true, allocationTransferTransactions);
        setTerritory(true, true, allocationTransferTransactions);
        setAddressDetails(allocationTransferTransactions, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER , isUpdated);
    }
    private static void processAddressDetailsForAllocationTransfer(Map<Id, SFA2_PFG_Transaction_gne__c> triggerNewMap, Map<Id, SFA2_PFG_Transaction_gne__c> triggerOldMap)
    {
        List<SFA2_PFG_Transaction_gne__c> allocationTransferShipmentInitiated = new List<SFA2_PFG_Transaction_gne__c>();
        for(Id trxId : triggerNewMap.keySet())
        {
            if(GNE_SFA2_PFG_Util.getTransactionRecordTypeName(triggerNewMap.get(trxId).recordTypeId) == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER &&
                triggerNewMap.get(trxId).Generate_Shipment_Flag__c == GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED &&
                triggerOldMap.get(trxId).Generate_Shipment_Flag__c != GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED &&
                triggerOldMap.get(trxId).Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC
              )
            {
                if(!GNE_SFA2_PFG_Util.populateTransactionAddressFromUser(triggerNewMap.get(trxId),triggerNewMap.get(trxId).To_User_gne__c)) {
                    triggerNewMap.get(trxId).addError(SL_ERROR + triggerNewMap.get(trxId).To_User_gne__r.Name);
                }
            }
        }
    }
    private static void processTransfers(List<SFA2_PFG_Transaction_gne__c> transferTransactions)
    {
        List<SFA2_PFG_Transaction_gne__c> transfersCreated = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> transfersReceived = new List<SFA2_PFG_Transaction_gne__c>();
        for(SFA2_PFG_Transaction_gne__c trx : transferTransactions)
        {
            if(trx.Received_Quantity_gne__c == 0)
            {
                transfersCreated.add(trx);
            }
            if(trx.Received_Quantity_gne__c >0)
            {
                transfersReceived.add(trx);
            }
        }
        if(!transfersCreated.isEmpty())
        {
            setLOAandUncertifiedFlags(true, false, transfersCreated);
            setTerritory(true, false, transfersCreated);
        }
        if(!transfersReceived.isEmpty())
        {
            setLOAandUncertifiedFlags(false, true, transfersReceived);
            setTerritory(false, true, transfersReceived);
        }

    }
    private static void processOrders(List<SFA2_PFG_Transaction_gne__c> orderCreatedTransactions)
    {
        setLOAandUncertifiedFlags(false, true, orderCreatedTransactions);
        setTerritory(false, true, orderCreatedTransactions);
        setAddressDetails(orderCreatedTransactions, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER, null);
    }
    private static void processReturns(List<SFA2_PFG_Transaction_gne__c> returnTransactions)
    {
        setLOAandUncertifiedFlags(true, false, returnTransactions);
        setTerritory(true, false, returnTransactions);
    }
    private static void processDisbursements(List<SFA2_PFG_Transaction_gne__c> disbursementTransactions)
    {
        setLOAandUncertifiedFlags(true, false, disbursementTransactions);
        setTerritory(true, false, disbursementTransactions);
    }
    private static void processDtpOrder(List<SFA2_PFG_Transaction_gne__c> dtpOrderTransactions)
    {
        setLOAandUncertifiedFlags(true, false, dtpOrderTransactions);
    }
    private static void processAdjustments(List<SFA2_PFG_Transaction_gne__c> adjustmentTransactions)
    {
        List<SFA2_PFG_Transaction_gne__c> adjustmentsWithCallId = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> adjustmentsFromInventoryCount = new List<SFA2_PFG_Transaction_gne__c>();
        for(SFA2_PFG_Transaction_gne__c trx : adjustmentTransactions)
        {
            if(trx.Inventory_Count_Flag_gne__c == true)
            {
                adjustmentsFromInventoryCount.add(trx);
            }
            else
            {
                adjustmentsWithCallId.add(trx);
            }
        }
        if(!adjustmentsFromInventoryCount.isEmpty())
        {
            setLOAandUncertifiedFlags(false, true, adjustmentsFromInventoryCount);
            setTerritory(false, true, adjustmentsFromInventoryCount);
            setAddressDetails(adjustmentsFromInventoryCount, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT, null);
        }
        if(!adjustmentsWithCallId.isEmpty())
        {
            setLOAandUncertifiedFlags(true, false, adjustmentsWithCallId);
            setTerritory(true, false, adjustmentsWithCallId);
        }
    }
    private static void setLOAandUncertifiedFlags(Boolean fromDirection, Boolean toDirection, List<SFA2_PFG_Transaction_gne__c> transactions)
    {
        for(SFA2_PFG_Transaction_gne__c trx : transactions)
        {
            if(fromDirection == true) {
            	trx.From_CS_on_LOA_Flag__c = GNE_SFA2_PFG_Util.checkIsUserCS(trx.From_User_gne__c) && GNE_SFA2_PFG_Util.checkIsUserLOAOnDate(trx.From_User_gne__c, trx.Transaction_Date_gne__c);
            }

            if(toDirection == true) {
            	trx.To_CS_on_LOA_Flag_gne__c = GNE_SFA2_PFG_Util.checkIsUserCS(trx.To_User_gne__c) && GNE_SFA2_PFG_Util.checkIsUserLOAOnDate(trx.To_User_gne__c, trx.Transaction_Date_gne__c);
            }
        }
    }
    private static void setTerritory(Boolean fromDirection, Boolean toDirection, List<SFA2_PFG_Transaction_gne__c> transactions) {
        for(SFA2_PFG_Transaction_gne__c trx : transactions) {
           	if(fromDirection == true && GNE_SFA2_PFG_Util.checkIsUserCS(trx.From_User_gne__c)) {
          		Id managerId = GNE_SFA2_PFG_Util.getManagerForUser(trx.From_User_gne__c);
                Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryForUser(managerId);
                trx.From_User_Territory_gne__c = terr.Id;
                trx.From_Territory_Number_gne__c = terr.Territory_Number_gne__c;
                trx.From_Territory_Name_gne__c = terr.Name;
          	}

          	if(toDirection == true && GNE_SFA2_PFG_Util.checkIsUserCS(trx.To_User_gne__c)) {
           		Id managerId = GNE_SFA2_PFG_Util.getManagerForUser(trx.To_User_gne__c);
                Territory2 terr = GNE_SFA2_PFG_Util.getTerritoryForUser(managerId);
                trx.To_User_Territory_gne__c = terr.Id;
                trx.To_Territory_Number_gne__c = terr.Territory_Number_gne__c;
                trx.To_Territory_Name_gne__c = terr.Name;
           	}
        }
    }
    private static void setAddressDetails(List<SFA2_PFG_Transaction_gne__c> transactions, String TransactionType, Boolean isUpdate)
    {
        for(SFA2_PFG_Transaction_gne__c trx : transactions)
        {
            if(isUpdate == false && TransactionType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER && GNE_SFA2_PFG_Util.checkIsUserCS(trx.To_User_gne__c) && trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC)
            {
                GNE_SFA2_PFG_Util.populateTransactionAddressFromUser(trx,trx.To_User_gne__c);
            }
            else if(TransactionType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER)
            {
                if(!GNE_SFA2_PFG_Util.populateTransactionAddressFromUser(trx,trx.To_User_gne__c)) {
                	String userName = String.IsNotBlank(trx.To_User_gne__r.Name)
                		? trx.To_User_gne__r.Name : GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.To_User_gne__c).User_gne__r.Name;
                    trx.addError(SL_ERROR + userName);
                }
            }
            else if(TransactionType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT)
            {
                if(!GNE_SFA2_PFG_Util.populateTransactionAddressFromUser(trx,trx.To_User_gne__c)) {
                	String userName = String.IsNotBlank(trx.To_User_gne__r.Name)
                		? trx.To_User_gne__r.Name : GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.To_User_gne__c).User_gne__r.Name;
                    trx.addError(SL_ERROR + userName);
                }
            }
        }
    }
    //Dominik Wasilewski stop

    private static void populateTransactionFields(List<SFA2_PFG_Transaction_gne__c> triggerNew, Map<Id,SFA2_PFG_Transaction_gne__c> triggerOldMap) {
        Boolean isUpdateMode = triggerOldMap!=null;

        Map<Id, SFA2_PFG_Transaction_gne__c> callDetailIdToTransaction = getRelatedTransactionForAdjustments(triggerNew,isUpdateMode);

        for(SFA2_PFG_Transaction_gne__c trxNew : triggerNew) {
            SFA2_PFG_Transaction_gne__c trxOld = isUpdateMode ? triggerOldMap.get(trxNew.Id) : null;
            Boolean isHcpTrx =
                trxNew.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT
             || trxNew.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF;

            if(!isUpdateMode) { // insert mode
                populateTransactionProductFields(trxNew,trxNew.Product_gne__c);
                populateTransactionCsFlags(trxNew);
                populateStatusField(trxNew);
                populateDateFields(trxNew, null);
                populateQuantityFields(trxNew);
                populateVendor(trxNew);

                if(isHcpTrx) {
                    populateFieldsFromCallDetail(trxNew,GNE_SFA2_PFG_Util.getCallDetailById(trxNew.Call_PFG_Detail_ID_gne__c));
                }

                // DTP/Hand Carry fields
                Boolean isDTP = (trxNew.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
                trxNew.Lot_No_gne__c = isDTP ? GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE : trxNew.Lot_No_gne__c;
                trxNew.Generate_Shipment_Flag__c = isDTP ? null : GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;

                if(trxNew.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT) {
                    if(trxNew.Call_PFG_Detail_ID_gne__c==null && trxNew.Inventory_Count_Flag_gne__c!=true) {
                        trxNew.To_User_gne__c = trxNew.From_User_gne__c;
                        trxNew.From_User_gne__c = null;
                        // Stamp the record with inv count flag - with this approach it will be process in Transaction Logic class
                        trxNew.Inventory_Count_Flag_gne__c = true;
                    } else if(trxNew.Call_PFG_Detail_ID_gne__c!=null) {
                        SFA2_PFG_Transaction_gne__c existingTrx = callDetailIdToTransaction.get(trxNew.Call_PFG_Detail_ID_gne__c);
                        if(existingTrx!=null){
                            trxNew.From_User_gne__c = existingTrx.From_User_gne__c;
                            trxNew.To_User_gne__c = existingTrx.To_User_gne__c;
                        }
                    }
                }
            } else { // update mode
                populateDateFields(trxNew, trxOld);

                if(isHcpTrx) {
                    signTransaction(trxNew, GNE_SFA2_PFG_Util.getCallDetailById(trxNew.Call_PFG_Detail_ID_gne__c));
                }
            }
        }
    }

    private static Map<Id, SFA2_PFG_Transaction_gne__c> getRelatedTransactionForAdjustments(List<SFA2_PFG_Transaction_gne__c> trxs, Boolean isUpdateMode) {
        Map<Id, SFA2_PFG_Transaction_gne__c> callDetailIdToTransaction = new Map<Id, SFA2_PFG_Transaction_gne__c>();

        if(!isUpdateMode) { // only in insert mode
            Set<Id> callDetailIds = new Set<Id>();
            for(SFA2_PFG_Transaction_gne__c trx : trxs){
                if(trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT
                && trx.Call_PFG_Detail_ID_gne__c!=null
                && (trx.From_User_gne__c == null || trx.To_User_gne__c==null)) {

                    callDetailIds.add(trx.Call_PFG_Detail_ID_gne__c);
                }
            }

            if(!callDetailIds.isEmpty()) {
                for(SFA2_PFG_Transaction_gne__c trx : GNE_SFA2_PFG_DAO.getTransactionsByInteractionId(callDetailIds)){
                    if(trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT
                    || trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {

                        callDetailIdToTransaction.put(trx.Call_PFG_Detail_ID_gne__c,trx);
                    }
                }
            }
        }

        return callDetailIdToTransaction;
    }

    public static void populateTransactionAddressFromVendor(SFA2_PFG_Transaction_gne__c trx, Vendor_gne__c vdr) {
        if(vdr==null) {
            trx.Vendor_gne__c = null;
            trx.Address_Line_1_gne__c = null;
            trx.Address_Line_2_gne__c = null;
            trx.City_gne__c = null;
            trx.State_gne__c = null;
            trx.Zip_gne__c = null;
        } else {
            trx.Vendor_gne__c = vdr.Id;
            trx.Address_Line_1_gne__c = vdr.Address_Line_1_gne__c;
            trx.Address_Line_2_gne__c = vdr.Address_Line_2_gne__c;
            trx.City_gne__c = vdr.City_gne__c;
            trx.State_gne__c = vdr.State_gne__c;
            trx.Zip_gne__c = vdr.Zip_gne__c;
        }
    }

    public static void populateTransactionProductFields(SFA2_PFG_Transaction_gne__c trx, Id prodId) {
        Product_vod__c prod = prodId!=null ? GNE_SFA2_PFG_Util.getPfgProduct(prodId) : null;

        if(prod!=null) {
            trx.Product_gne__c = prod.Id;
            trx.UOM_gne__c = prod.UOM_gne__c;
            // Paper Order's NDC is set by External REST Interface
            if(trx.Transaction_Type_gne__c != GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER) {
            	trx.NDC_Number__c = prod.NDC_Number_gne__c;
            }
        }
    }

    public static void populateTransactionCsFlags(SFA2_PFG_Transaction_gne__c trx) {
        trx.To_User_Is_CS_Flag_gne__c = (trx.To_User_gne__c!=null && GNE_SFA2_PFG_Util.checkIsUserCS(trx.To_User_gne__c));
        trx.From_User_Is_CS_Flag_gne__c = (trx.From_User_gne__c!=null && GNE_SFA2_PFG_Util.checkIsUserCS(trx.From_User_gne__c));
    }

    public static void populateStatusField(SFA2_PFG_Transaction_gne__c trx) {
        if(trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER) {
            Boolean isHandCarry = (trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
            trx.Status_gne__c = isHandCarry ? GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SAVED : GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;

        } else if(trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT) {
            trx.Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED;
        } else {
            trx.Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        }
    }

    public static void populateQuantityFields(SFA2_PFG_Transaction_gne__c trx) {
        Boolean isDTP = (trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
        String trxType = trx.Transaction_Type_gne__c;

        if((trxType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT && !isDTP && trx.Inventory_Count_Flag_gne__c!=true) ||
           (trxType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT && !isDTP) ||
           (trxType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER && isDTP)) {
            trx.Received_Quantity_gne__c = trx.Shipped_Quantity_gne__c = trx.Requested_Quantity_gne__c;
        } else if((trxType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN && !isDTP) ||
                  (trxType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER && !isDTP)) {
            trx.Shipped_Quantity_gne__c = trx.Requested_Quantity_gne__c;
        }
    }

    public static void populateVendor(SFA2_PFG_Transaction_gne__c trx) {
        Vendor_gne__c vendor = GNE_SFA2_PFG_Util.getVendorForProduct(trx.Product_gne__c);
        trx.Vendor_gne__c = vendor!=null ? vendor.Id : null;
    }

    public static void populateDateFields(SFA2_PFG_Transaction_gne__c trx, SFA2_PFG_Transaction_gne__c trxOld) {
        Date currentDate = System.today();
        String trxType = trx.Transaction_Type_gne__c;

        if(trxOld==null) { // insert mode
            if(trx.Transaction_Date_gne__c==null) {
            	setTransactionDate(trx,currentDate);
            }

            if(trx.Year_gne__c == null || trx.Year_gne__c == 0.0) {
            	trx.Year_gne__c = trx.Transaction_Date_gne__c.year();
            }

            trx.Submitted_Date_gne__c = currentDate;
        } else { // update mode
        	Boolean isDTP = (trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);

            if(!isDTP && trxType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER) {
            	setTransactionDate(trx,currentDate);
            }
        }
    }

    private static void setTransactionDate(SFA2_PFG_Transaction_gne__c trx, Date trxDate) {
    	trx.Transaction_Date_gne__c = trxDate;
        trx.Year_gne__c = trx.Transaction_Date_gne__c.year();
    }

    public static void populateFieldsFromCallDetail(SFA2_PFG_Transaction_gne__c trx, Call_PFG_Detail_gne__c cDetail) {
        if(cDetail!=null) {
            trx.From_User_gne__c = cDetail.Call_gne__r.OwnerId;
            trx.Account_gne__c = cDetail.Account_gne__c;
            trx.Account_Name_gne__c = cDetail.Account_gne__r.Name;
            trx.Account_MDMID_gne__c = cDetail.Account_gne__r.MDMID_gne__c;
            trx.Address_ID_gne__c = cDetail.Call_gne__r.Parent_Address_vod__c;
            trx.Address_Line_1_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.Name;
            trx.Address_Line_2_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.Address_Line_2_vod__c;
            trx.City_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.City_vod__c;
            trx.State_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.State_vod__c;
            trx.Zip_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.Zip_vod__c;
            trx.Designation_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.Designation_gne__c;
            trx.SLN_gne__c = cDetail.Call_gne__r.Parent_Address_vod__r.License_vod__c;
            trx.BDTD_gne__c = cDetail.Call_gne__r.PFG_BDTD_gne__c;
            trx.Submitted_Date_gne__c = cDetail.Date_gne__c;
            trx.HCP_Specialty_gne__c = cDetail.Call_gne__r.HCP_Specialty_gne__c;
            setTransactionDate(trx, cDetail.Date_gne__c);
            signTransaction(trx, cDetail);

            User csUser = GNE_SFA2_PFG_Util.getUser(trx.From_User_gne__c);

            if(csUser!=null) {
	            trx.CS_Id_gne__c = csUser.External_Id_gne__c;
	            trx.CS_First_Name_gne__c = csUser.FirstName;
	            trx.CS_Last_Name_gne__c = csUser.LastName;
	            trx.CS_Email_gne__c = csUser.Email;
            }

            if(trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT) {
                trx.Receipt_Date_gne__c = cDetail.Date_gne__c;
            } else if(trx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) {
                Boolean limitReached  = true;

                for(Territory2 terr : GNE_SFA2_PFG_Util.getTerritoriesForUser(trx.From_User_gne__c)) {
                	if(cDetail.Call_gne__r.Territory_vod__c == terr.Name) {
	                    trx.From_Territory_Name_gne__c = terr.Name;
	                    trx.From_User_Territory_gne__c = terr.Id;
	                    trx.From_Territory_Number_gne__c = terr.Territory_Number_gne__c;

	                    if(GNE_SFA2_PFG_Util.validateTransactionQuantity(trx, new List<Integer>{null,null},true)) {
	                    	limitReached  = false;
	                    }
                	}
                }

                // If limit reached, cancel transaction
                if(limitReached) {
                	trx.Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_CANCELLED;
                	trx.Delivery_Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_CANCELLED;
                	trx.Order_Status_Note_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_ORDER_STATUS_CANCELLED_NOTE;
                	trx.Order_Status_Last_Updated_gne__c = System.now();
                }
            }
        }
    }

    private static void signTransaction(SFA2_PFG_Transaction_gne__c trx, Call_PFG_Detail_gne__c cDetail) {
        if(GNE_SFA2_PFG_CPD_Trigger_Helper.isOtrRequest() && cDetail!=null) {
            Boolean isDTP = trx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
            String reqSig = cDetail.Call_gne__r.Request_Signature_gne__c;
            DateTime reqSigDt = cDetail.Call_gne__r.Request_Signature_Date_gne__c;
            String sig = cDetail.Call_gne__r.Signature_vod__c;
            DateTime sigDt = cDetail.Call_gne__r.Signature_Date_vod__c;
            String disclaimer = cDetail.Call_gne__r.Disclaimer_vod__c;

            if(isDTP) { //DTP
                if(String.isNotBlank(reqSig) && String.isBlank(trx.Request_Signature_gne__c)) { // 1st Signature
                    trx.Request_Signature_gne__c = reqSig;
                    trx.Request_Signature_Date_gne__c = reqSigDt;
                    trx.Shipment_Request_Date_gne__c = reqSigDt!=null ? reqSigDt.date() : null;
                    trx.Signature_Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_INCOMPLETE;
                    trx.Disclaimer_gne__c = disclaimer;
                }

                if(String.isNotBlank(sig) && String.isBlank(trx.Signature_gne__c)) { // 2nd AOC Signature
                    trx.Signature_gne__c = sig;
                    trx.Receipt_Date_gne__c = trx.Signature_Date_gne__c = sigDt;
                    trx.Received_Quantity_gne__c = trx.Shipped_Quantity_gne__c;
                    trx.Signature_Status_gne__c = cDetail.DTP_AOC_Status_gne__c; // Complete
                    trx.Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED;
                }
            } else if(String.isNotBlank(sig) && String.isBlank(trx.Request_Signature_gne__c)) { // Hand Carry
                trx.Request_Signature_gne__c = sig;
                trx.Request_Signature_Date_gne__c = sigDt;
                trx.Signature_Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE;
                trx.Disclaimer_gne__c = disclaimer;
            }
        }
    }
    
    private static void setDefaultDesignationForEmptyField(List<SFA2_PFG_Transaction_gne__c> triggerNew) {
        for(SFA2_PFG_Transaction_gne__c trx : triggerNew) {
            if(String.isEmpty(trx.Designation_gne__c)){
                trx.Designation_gne__c = DEFAULT_DESIGNATION;
            }
        }
    }
    
    private static void truncateZipCode(List<SFA2_PFG_Transaction_gne__c> triggerNew) {
        for(SFA2_PFG_Transaction_gne__c trx : triggerNew) {
            if(String.isEmpty(trx.Zip_gne__c))continue;
            trx.Zip_gne__c = trx.Zip_gne__c.replaceAll('[^0-9]', '');
            if(trx.Zip_gne__c.length() > 5){
                trx.Zip_gne__c = trx.Zip_gne__c.left(5);
            }            
        }
    }
    
    private static void removeNonASCIIcharsFromAddressFields(List<SFA2_PFG_Transaction_gne__c> triggerNew) {
        for(SFA2_PFG_Transaction_gne__c trx : triggerNew) {
            if(String.isNotBlank(trx.Address_Line_1_gne__c) && isStringContainsnonASCII(trx.Address_Line_1_gne__c)){
                trx.Address_Line_1_gne__c = changeNonASCIIToASCII(trx.Address_Line_1_gne__c);
                trx.Address_Line_1_gne__c = removeNonASCIIchars(trx.Address_Line_1_gne__c);
            }
            if(String.isNotBlank(trx.Address_Line_2_gne__c) && isStringContainsnonASCII(trx.Address_Line_2_gne__c)){
                trx.Address_Line_2_gne__c = changeNonASCIIToASCII(trx.Address_Line_2_gne__c);
                trx.Address_Line_2_gne__c = removeNonASCIIchars(trx.Address_Line_2_gne__c);
            }
        }
    }
    
    private static String changeNonASCIIToASCII(String value) {
        Integer[] chars = value.getChars();
        Integer index = 0;
        for(Integer ch : chars){
            if(NONASCII_2_ASCII.get(ch) != null){
                ch = NONASCII_2_ASCII.get(ch);
                chars.set(index, ch);
            }
            index++;
        }
        value = String.fromCharArray(chars);
        return value;
    }
    
    private static String removeNonASCIIchars(String value) {
        value = value.replaceAll('[^\\x00-\\x7F]', '');
        return value;
    }
    
    private static Boolean isStringContainsnonASCII(String toCheck){
        Pattern myPattern = Pattern.compile('[^\\x00-\\x7F]+');
        Matcher myMatcher = myPattern.matcher(toCheck);
        return myMatcher.find();
    }
    
    private static final Map<Integer, Integer> NONASCII_2_ASCII = new Map<Integer, Integer>{
        161 => 105,
        162 => 99,
        163 => 76,
        165 => 89,
        169 => 99,
        174 => 114,
        192 => 65,
        193 => 65,
        194 => 65,
        195 => 65,
        196 => 65,
        197 => 65,
        198 => 65,
        199 => 67,
        200 => 69,
        201 => 69,
        202 => 69,
        203 => 69,
        204 => 73,
        205 => 73,
        206 => 73,
        207 => 73,
        208 => 68,
        209 => 78,
        210 => 79,
        211 => 79,
        212 => 79,
        213 => 79,
        214 => 79,
        216 => 79,
        217 => 85,
        218 => 85,
        219 => 85,
        220 => 85,
        221 => 89,
        223 => 98,
        224 => 97,
        225 => 97,
        226 => 97,
        227 => 97,
        228 => 97,
        229 => 97,
        230 => 97,
        231 => 99,
        232 => 101,
        233 => 101,
        234 => 101,
        235 => 101,
        236 => 105,
        237 => 105,
        238 => 105,
        239 => 105,
        241 => 110,
        242 => 111,
        243 => 111,
        244 => 111,
        245 => 111,
        246 => 111,
        248 => 111,
        249 => 117,
        250 => 117,
        251 => 117,
        252 => 117,
        253 => 121,
        255 => 121,
        128 => 32,
        129 => 32,
        130 => 32,
        131 => 32,
        132 => 32,
        133 => 32,
        134 => 32,
        135 => 32,
        136 => 32,
        137 => 32,
        138 => 32,
        139 => 32,
        140 => 32,
        141 => 32,
        142 => 32,
        143 => 32,
        144 => 32,
        145 => 32,
        146 => 32,
        147 => 32,
        148 => 32,
        149 => 32,
        150 => 32,
        151 => 32,
        152 => 32,
        153 => 32,
        154 => 32,
        155 => 32,
        156 => 32,
        157 => 32,
        158 => 32,
        159 => 32,
        160 => 32
    };
}