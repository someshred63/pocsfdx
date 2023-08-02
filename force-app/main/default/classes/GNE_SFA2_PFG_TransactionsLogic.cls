public with sharing class GNE_SFA2_PFG_TransactionsLogic
{
    private static Map<String,SFA2_PFG_to_User_Detail_gne__c> pfgToUserDetailDMtoUpsert = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();
    private static Map<String,SFA2_PFG_to_User_Detail_gne__c> pfgToUserDetailsToUpsert = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();
    private static Map<String,SFA2_PFG_to_Account_Detail_gne__c> pfgToAccountDetailsToUpsert  = new Map<String,SFA2_PFG_to_Account_Detail_gne__c>();
    private static Map<String, SFA2_PFG_to_Territory_Detail_gne__c> pfgToTerritoryDetailsToUpsert = new Map<String, SFA2_PFG_to_Territory_Detail_gne__c>();
    private static Map<String,SFA2_Lot_Catalog_gne__c> lotCatalogList;

    public static void onAfterInsert(Map<Id, SFA2_PFG_Transaction_gne__c> triggerNewMap) {
        GNE_SFA2_PFG_Util.cachePfgToUserDetails(triggerNewMap.values());
        GNE_SFA2_PFG_Util.cachePfgToUserDetailsNoLot(triggerNewMap.values());
        GNE_SFA2_PFG_Util.cacheAccLimitExceptions(triggerNewMap.values());
        GNE_SFA2_PFG_Util.cacheProductLimits(triggerNewMap.values());
        GNE_SFA2_PFG_Util.cachePfgToAccountDetails(triggerNewMap.values());
        GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(triggerNewMap.values());
        lotCatalogList = GNE_SFA2_PFG_Util.getLotCatalogList(triggerNewMap.values());
        Map<Id, SFA2_PFG_Transaction_gne__c> triggerOldMap = new Map<Id, SFA2_PFG_Transaction_gne__c>();
        categorizeAndProcessTransactions(triggerNewMap, triggerOldMap);

        // Future call
        reportExceptions();
    }

    public static void onAfterUpdate(Map<Id, SFA2_PFG_Transaction_gne__c> triggerNewMap, Map<Id, SFA2_PFG_Transaction_gne__c> triggerOldMap) {
        List<SFA2_PFG_Transaction_gne__c> allTrans = new List<SFA2_PFG_Transaction_gne__c>();
        allTrans.addAll(triggerNewMap.values());
        allTrans.addAll(triggerOldMap.values());
        GNE_SFA2_PFG_Util.cachePfgToUserDetails(allTrans);
        GNE_SFA2_PFG_Util.cachePfgToUserDetailsNoLot(allTrans);
        GNE_SFA2_PFG_Util.cachePfgToAccountDetails(allTrans);
        GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(allTrans);
        GNE_SFA2_PFG_Util.cacheAccLimitExceptions(triggerNewMap.values());
        GNE_SFA2_PFG_Util.cacheProductLimits(triggerNewMap.values());
        lotCatalogList = GNE_SFA2_PFG_Util.getLotCatalogList(triggerNewMap.values());
        categorizeAndProcessTransactions(triggerNewMap, triggerOldMap);

        // Future call
        reportExceptions();
    }

    private static void categorizeAndProcessTransactions(Map<Id, SFA2_PFG_Transaction_gne__c> newTransactionsMap, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        pfgToUserDetailsToUpsert = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();
        pfgToUserDetailDMtoUpsert = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();
        pfgToAccountDetailsToUpsert =  new Map<String,SFA2_PFG_to_Account_Detail_gne__c>();
        pfgToTerritoryDetailsToUpsert = new Map<String, SFA2_PFG_to_Territory_Detail_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> disbursementTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> dtpOrderTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> allocationTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactionsHO = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactionsDM = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactionsCS = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactionsDtp = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> transferTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> orderTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> returnTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> adjustmentTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        //sorting transactions by transaction type (and in few cases by other requirement) and adding to separeted list grouping transactions
        for(SFA2_PFG_Transaction_gne__c pfgTransaction : newTransactionsMap.values()) {
            String recTypeName = GNE_SFA2_PFG_Util.getTransactionRecordTypeName(pfgTransaction.recordTypeId);
            Boolean isDTP = pfgTransaction.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;

            if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION && (String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c) || isDTP)) {
                allocationTransactions.add(pfgTransaction);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER && (String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c) || isDTP)) {
                if(!isDTP) {
                	Id toUserId = pfgTransaction.To_User_gne__c;

                    if(GNE_SFA2_PFG_Util.checkIsUserManager(toUserId)) {
                        allocationTransferTransactionsHO.add(pfgTransaction);
                    } else if(GNE_SFA2_PFG_Util.checkIsUserDM(toUserId)) {
                        allocationTransferTransactionsDM.add(pfgTransaction);
                    } else if(GNE_SFA2_PFG_Util.checkIsUserCS(toUserId)) {
                        allocationTransferTransactionsCS.add(pfgTransaction);
                    } else {
                    	handleException(new UserRoleNotDefinedException(GNE_SFA2_PFG_Util.getTransactionRecordTypeName(pfgTransaction.RecordTypeId), toUserId));
                    }
                } else {
                	allocationTransferTransactionsDtp.add(pfgTransaction);
                }
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER && String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c)) {
                transferTransactions.add(pfgTransaction);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER && String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c) && pfgTransaction.Received_Quantity_gne__c >0) {
                orderTransactions.add(pfgTransaction);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN && String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c)) {
                returnTransactions.add(pfgTransaction);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT && String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c)) {
            	adjustmentTransactions.add(pfgTransaction);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT && String.isNotBlank(pfgTransaction.Transaction_Ref_Number_gne__c)) {
            	disbursementTransactions.add(pfgTransaction);
            } else if(recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF || recTypeName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER) {
            	dtpOrderTransactions.add(pfgTransaction);
            }
        }
        //checking if system received transactions with specific transaction type and running process for this records
        if(!allocationTransactions.isEmpty()) {
            processAllocations(allocationTransactions, oldTransactionsMap);
        }

        if(!allocationTransferTransactionsHO.isEmpty()) {
            processAllocationTransfers(allocationTransferTransactionsHO, oldTransactionsMap, GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
        }

        if(!allocationTransferTransactionsDM.isEmpty()) {
            processAllocationTransfers(allocationTransferTransactionsDM, oldTransactionsMap, GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
        }

        if(!allocationTransferTransactionsCS.isEmpty()) {
            processAllocationTransfers(allocationTransferTransactionsCS, oldTransactionsMap, GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
        }

        if(!allocationTransferTransactionsDtp.isEmpty()){
            processAllocationTransfers(allocationTransferTransactionsDtp, oldTransactionsMap, GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP);
        }

        if(!transferTransactions.isEmpty()) {
            processTransfers(transferTransactions, oldTransactionsMap);
        }

        if(!orderTransactions.isEmpty()) {
            processOrders(orderTransactions, oldTransactionsMap);
        }

        if(!returnTransactions.isEmpty()) {
            processReturns(returnTransactions, oldTransactionsMap);
        }

        if(!adjustmentTransactions.isEmpty()) {
            processAdjustment(adjustmentTransactions, oldTransactionsMap);
        }

        if(!disbursementTransactions.isEmpty()) {
            processDisbursement(disbursementTransactions, oldTransactionsMap);
        }

        if(!dtpOrderTransactions.isEmpty()) {
            processDtpOrder(dtpOrderTransactions, oldTransactionsMap);
        }

        if(pfgToUserDetailDMtoUpsert != null && !pfgToUserDetailDMtoUpsert.isEmpty()) {
            upsert pfgToUserDetailDMtoUpsert.values();
        }

        if(pfgToUserDetailsToUpsert!=null && !pfgToUserDetailsToUpsert.isEmpty()) {
            upsert pfgToUserDetailsToUpsert.values();
        }

        if(pfgToAccountDetailsToUpsert != null && !pfgToAccountDetailsToUpsert.isEmpty()) {
            upsert pfgToAccountDetailsToUpsert.values();
        }

        if(pfgToTerritoryDetailsToUpsert != null && !pfgToTerritoryDetailsToUpsert.isEmpty()) {
            upsert pfgToTerritoryDetailsToUpsert.values();
        }
    }

    //method for Allocation transactions
    private static void processAllocations(List<SFA2_PFG_Transaction_gne__c> allocationTransactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap) {
        for(SFA2_PFG_Transaction_gne__c trans : allocationTransactions) {
        	SFA2_PFG_Transaction_gne__c transOld = oldTransactionsMap.get(trans.Id);

            if(trans.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
                SFA2_PFG_to_User_Detail_gne__c uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetailNoLotNo(trans.To_User_gne__c, trans.Product_gne__c);
                Boolean somethingChanged = false;

                if(uDetail == null) {
                	//insert scenario for Hand Carry, no update since the use of Transaction Ref # as the lot # guarantees new record creation
                	somethingChanged = true;
                    uDetail = createUserDetail(trans, false, trans.Requested_Quantity_gne__c, trans.Requested_Quantity_gne__c);
                    uDetail.Lot_NO_gne__c = trans.Transaction_Ref_Number_gne__c;
                    GNE_SFA2_PFG_Util.addPfgToUserDetailNoLotToCache(uDetail);
                } else if((transOld==null && trans.Requested_Quantity_gne__c!=0) || (transOld!=null && trans.Requested_Quantity_gne__c!=transOld.Requested_Quantity_gne__c) ||
                          (transOld!=null && String.isBlank(transOld.Transaction_Ref_Number_gne__c))) {
                	somethingChanged = true;
                	Double delta = trans.Requested_Quantity_gne__c - ((transOld == null || String.isBlank(transOld.Transaction_Ref_Number_gne__c)) ? 0.0 : transOld.Requested_Quantity_gne__c);
                	uDetail.Qty_Total_Allocated_gne__c += delta;
                	uDetail.YTD_Allocated_gne__c += delta;
                }

                if(somethingChanged) {
                	addPfgUserDetailToUpsert(uDetail);
                }
            } else if(trans.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP) {
                SFA2_PFG_to_Territory_Detail_gne__c tDetail = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(trans.To_Territory_Name_gne__c, trans.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trans));
                Boolean somethingChanged = false;
                if(tDetail == null) {
                    //insert scenario for DTP
                    somethingChanged = true;
                    tDetail = createTerritoryDetail(trans, false, trans.Requested_Quantity_gne__c, trans.Requested_Quantity_gne__c);
                } else if((transOld==null && trans.Requested_Quantity_gne__c!=0) || (transOld!=null && trans.Requested_Quantity_gne__c!=transOld.Requested_Quantity_gne__c)) {
                	//update scenario for DTP
                	somethingChanged = true;
                	Double delta = trans.Requested_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Requested_Quantity_gne__c);
                	tDetail.Qty_Total_Allocated_gne__c += delta;
                	tDetail.YTD_Allocated_gne__c += delta;
                }

                if(somethingChanged) {
                	addPfgTerritoryDetailToUpsert(tDetail);
                }
            }
        }
    }

    //method for Allocation Transfer transactions
    private static void processAllocationTransfers(List<SFA2_PFG_Transaction_gne__c> allocationTransferTransactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap, String distributionMethod) {
    	for(SFA2_PFG_Transaction_gne__c trans : allocationTransferTransactions) {
        	SFA2_PFG_Transaction_gne__c transOld = oldTransactionsMap.get(trans.Id);

            if(distributionMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
            	processAllocationTransferHc(trans, transOld);

            } else if(distributionMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP) {
            	if((transOld==null && trans.Requested_Quantity_gne__c!=0) || (transOld!=null && trans.Requested_Quantity_gne__c!=transOld.Requested_Quantity_gne__c)) {
            		Double delta = trans.Requested_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Requested_Quantity_gne__c);

            		SFA2_PFG_to_Territory_Detail_gne__c tDetailFrom = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(trans.From_Territory_Name_gne__c, trans.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trans));
                	SFA2_PFG_to_Territory_Detail_gne__c tDetailTo = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(trans.To_Territory_Name_gne__c, trans.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trans));

                	Territory2 fromTerr = GNE_SFA2_PFG_Util.getTerritoryByName(trans.From_Territory_Name_gne__c);
                	Territory2 toTerr = GNE_SFA2_PFG_Util.getTerritoryByName(trans.To_Territory_Name_gne__c);

                	if(fromTerr==null || toTerr==null) {
                		if(fromTerr==null) {
                			handleException(new MissingTerritoryException(GNE_SFA2_PFG_Util.getTransactionRecordTypeName(trans.RecordTypeId), trans.From_Territory_Name_gne__c));
                		}

                		if(toTerr==null) {
                			handleException(new MissingTerritoryException(GNE_SFA2_PFG_Util.getTransactionRecordTypeName(trans.RecordTypeId), trans.To_Territory_Name_gne__c));
                		}
                	} else {
                		Integer fromLevel = GNE_SFA2_PFG_Util.getTerritoryLevel(fromTerr.Id);
                		Integer toLevel = GNE_SFA2_PFG_Util.getTerritoryLevel(toTerr.Id);

                		if(tDetailFrom == null) {
	                    	tDetailFrom = createTerritoryDetail(trans, true, 0.0, 0.0);
            			}

	            		if(tDetailTo == null) {
		                    tDetailTo = createTerritoryDetail(trans, false, 0.0, 0.0);
        	    		}

            			tDetailFrom.Qty_Total_Allocated_gne__c -= delta;
            			tDetailTo.Qty_Total_Allocated_gne__c += delta;

            			if(fromLevel>=toLevel) {
            				tDetailFrom.YTD_Allocated_gne__c -= delta;
            			}

            			if(fromLevel<=toLevel) {
            				tDetailTo.YTD_Allocated_gne__c += delta;
            			}

            			addPfgTerritoryDetailToUpsert(tDetailFrom);
                		addPfgTerritoryDetailToUpsert(tDetailTo);
                	}
            	}
            }
        }
    }

    private static void processAllocationTransferHc(SFA2_PFG_Transaction_gne__c trans, SFA2_PFG_Transaction_gne__c transOld) {
    	if(trans.Generate_Shipment_Flag__c == GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED && transOld.Generate_Shipment_Flag__c != GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED)
        {
            //from user is home office
            SFA2_PFG_to_User_Detail_gne__c uDetailFromUser = GNE_SFA2_PFG_Util.getPfgToUserDetailNoLotNo(trans.From_User_gne__c, trans.Product_gne__c);
            //to user is DM
            SFA2_PFG_to_User_Detail_gne__c uDetailToUser = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.To_User_gne__c, trans.Product_gne__c, trans.Transaction_Ref_Number_gne__c);
            if(uDetailFromUser != null)
            {
                uDetailFromUser.Qty_Total_Allocated_gne__c = uDetailFromUser.Qty_Total_Allocated_gne__c - trans.Requested_Quantity_gne__c;
            }
            else
            {
            	handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE));
            }
            if(uDetailToUser == null)
            {
                //insert scenario
                uDetailToUser = createUserDetail(trans, false, trans.Requested_Quantity_gne__c, trans.Requested_Quantity_gne__c);
                uDetailToUser.Lot_NO_gne__c = trans.Transaction_Ref_Number_gne__c;
                GNE_SFA2_PFG_Util.addPfgToUserDetailToCache(uDetailToUser);
            }
            else
            {
                uDetailToUser.Qty_Total_Allocated_gne__c = uDetailToUser.Qty_Total_Allocated_gne__c + trans.Requested_Quantity_gne__c;
                uDetailToUser.YTD_Allocated_gne__c = uDetailToUser.YTD_Allocated_gne__c + trans.Requested_Quantity_gne__c;
            }
            addPfgUserDetailToUpsert(uDetailFromUser);
            addPfgUserDetailToDmUpsert(uDetailToUser);
        }
        if(trans.Generate_Shipment_Flag__c == GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED && transOld.Generate_Shipment_Flag__c != GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED)
        {
            SFA2_PFG_to_User_Detail_gne__c uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Transaction_Ref_Number_gne__c);
            if(uDetail != null)
            {
                uDetail.Qty_Reserved_gne__c = uDetail.Qty_Reserved_gne__c + trans.Requested_Quantity_gne__c;
            }
            else
            {
            	uDetail = createUserDetail(trans, true, trans.Requested_Quantity_gne__c, trans.Requested_Quantity_gne__c);
            	uDetail.Lot_NO_gne__c = trans.Transaction_Ref_Number_gne__c;
                GNE_SFA2_PFG_Util.addPfgToUserDetailToCache(uDetail);
            }
            addPfgUserDetailToUpsert(uDetail);
        }
        if(trans.Received_Quantity_gne__c != null && trans.Received_Quantity_gne__c >0 && trans.Generate_Shipment_Flag__c != GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED)
        {
            SFA2_PFG_to_User_Detail_gne__c uDetailFromUser = null;
            SFA2_PFG_to_User_Detail_gne__c uDetailToUser = null;
            SFA2_PFG_to_User_Detail_gne__c uDetailFromUserWithLotNo = null;
            if(trans.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC)
            {
                uDetailFromUser = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Transaction_Ref_Number_gne__c);
                if(trans.Lot_NO_gne__c != trans.Transaction_Ref_Number_gne__c)
                {
                    uDetailToUser = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.To_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c);
                    uDetailFromUserWithLotNo = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_No_gne__c);
                }
                if(uDetailToUser == null)
                {
                    //if there is no record for transaction Lot NO check if exist for Transaction Ref Number as a Lot NO - only To User Perspective
                    uDetailToUser = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.To_User_gne__c, trans.Product_gne__c, trans.Transaction_Ref_Number_gne__c);
                }
                if(uDetailFromUser != null && uDetailFromUserWithLotNo != null && uDetailFromUser.Merged_gne__c != true)
                {
                    //merge scenario FROM USER PERSPECTIVE
                    if(transOld!=null)
                    {
                        if(trans.Received_Quantity_gne__c != transOld.Received_Quantity_gne__c)
                        {
                            uDetailFromUser.Merged_gne__c = true;
                            if(trans.Lot_No_gne__c != null && trans.Lot_No_gne__c != '' && trans.Lot_No_gne__c != trans.Transaction_Ref_Number_gne__c)
                            {
                                uDetailFromUserWithLotNo.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                            }
                            uDetailFromUserWithLotNo.Lot_NO_gne__c = trans.Lot_No_gne__c;
                            uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c = uDetailFromUser.Qty_Total_Allocated_gne__c + uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                            uDetailFromUserWithLotNo.Qty_Reserved_gne__c = uDetailFromUser.Qty_Reserved_gne__c + uDetailFromUserWithLotNo.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                            uDetailFromUserWithLotNo.YTD_Allocated_gne__c = uDetailFromUserWithLotNo.YTD_Allocated_gne__c + uDetailFromUser.YTD_Allocated_gne__c;
                            if(uDetailFromUserWithLotNo.Expiration_Date_gne__c != null)
                            {
                                uDetailFromUserWithLotNo.Active_gne__c = uDetailFromUserWithLotNo.Expiration_Date_gne__c >= Date.today();
                            }
                        }
                    }
                    else
                    {
                        uDetailFromUser.Merged_gne__c = true;
                        if(trans.Lot_No_gne__c != null && trans.Lot_No_gne__c != '' && trans.Lot_No_gne__c != trans.Transaction_Ref_Number_gne__c)
                        {
                           uDetailFromUserWithLotNo.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                        }
                        uDetailFromUserWithLotNo.Lot_NO_gne__c = trans.Lot_No_gne__c;
                        uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c = uDetailFromUser.Qty_Total_Allocated_gne__c + uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                        uDetailFromUserWithLotNo.Qty_Reserved_gne__c = uDetailFromUser.Qty_Reserved_gne__c + uDetailFromUserWithLotNo.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                        if(uDetailFromUserWithLotNo.Expiration_Date_gne__c != null)
                        {
                            uDetailFromUserWithLotNo.Active_gne__c = uDetailFromUserWithLotNo.Expiration_Date_gne__c >= Date.today();
                        }
                    }
                    addPfgUserDetailToUpsert(uDetailFromUserWithLotNo);
                }
                else if(uDetailFromUser != null && uDetailFromUserWithLotNo != null && uDetailFromUser.Merged_gne__c == true)
                {
                    if(transOld!=null)
                    {
                        if(trans.Received_Quantity_gne__c != transOld.Received_Quantity_gne__c)
                        {
                            if(trans.Lot_No_gne__c != null && trans.Lot_No_gne__c != '' && trans.Lot_No_gne__c != trans.Transaction_Ref_Number_gne__c)
                            {
                                uDetailFromUserWithLotNo.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                            }
                            uDetailFromUserWithLotNo.Lot_NO_gne__c = trans.Lot_No_gne__c;
                            uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c = uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                            uDetailFromUserWithLotNo.Qty_Reserved_gne__c = uDetailFromUserWithLotNo.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                            if(uDetailFromUser.Expiration_Date_gne__c != null)
                            {
                                uDetailFromUserWithLotNo.Active_gne__c = uDetailFromUserWithLotNo.Expiration_Date_gne__c >= Date.today();
                            }
                        }
                    }
                    else
                    {
                        uDetailFromUserWithLotNo.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                        uDetailFromUserWithLotNo.Lot_NO_gne__c = trans.Lot_No_gne__c;
                        uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c = uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                        uDetailFromUserWithLotNo.Qty_Reserved_gne__c = uDetailFromUserWithLotNo.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                        if(uDetailFromUserWithLotNo.Expiration_Date_gne__c != null)
                        {
                            uDetailFromUserWithLotNo.Active_gne__c = uDetailFromUserWithLotNo.Expiration_Date_gne__c >= Date.today();
                        }
                    }
                    addPfgUserDetailToUpsert(uDetailFromUserWithLotNo);
                }
                else if(uDetailFromUser != null && uDetailFromUser.Merged_gne__c != true)
                {
                    //update scenario FROM USER PERSPECTIVE
                    if(transOld!=null)
                    {
                        if(trans.Received_Quantity_gne__c != transOld.Received_Quantity_gne__c)
                        {
                            if(trans.Lot_No_gne__c != null && trans.Lot_No_gne__c != '' && trans.Lot_No_gne__c != trans.Transaction_Ref_Number_gne__c)
                            {
                                uDetailFromUser.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                            }
                            uDetailFromUser.Lot_NO_gne__c = trans.Lot_No_gne__c;
                            uDetailFromUser.Qty_Total_Allocated_gne__c = uDetailFromUser.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                            uDetailFromUser.Qty_Reserved_gne__c = uDetailFromUser.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                            if(uDetailFromUser.Expiration_Date_gne__c != null)
                            {
                                uDetailFromUser.Active_gne__c = uDetailFromUser.Expiration_Date_gne__c >= Date.today();
                            }
                        }
                    }
                    else
                    {
                        if(trans.Lot_No_gne__c != null && trans.Lot_No_gne__c != '' && trans.Lot_No_gne__c != trans.Transaction_Ref_Number_gne__c)
                        {
                            uDetailFromUser.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                        }
                        uDetailFromUser.Lot_NO_gne__c = trans.Lot_No_gne__c;
                        uDetailFromUser.Qty_Total_Allocated_gne__c = uDetailFromUser.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                        uDetailFromUser.Qty_Reserved_gne__c = uDetailFromUser.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                        if(uDetailFromUser.Expiration_Date_gne__c != null)
                        {
                            uDetailFromUser.Active_gne__c = uDetailFromUser.Expiration_Date_gne__c >= Date.today();
                        }

                    }
                }
                else if(uDetailFromUserWithLotNo != null && transOld!=null &&
                		trans.Received_Quantity_gne__c != transOld.Received_Quantity_gne__c)
                {
                	uDetailFromUserWithLotNo.Expiration_Date_gne__c = lotCatalogList.get(trans.Lot_No_gne__c).Expiration_Date_gne__c;
                	uDetailFromUserWithLotNo.Lot_NO_gne__c = trans.Lot_No_gne__c;
                	uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c = uDetailFromUserWithLotNo.Qty_Total_Allocated_gne__c - trans.Received_Quantity_gne__c;
                	uDetailFromUserWithLotNo.Qty_Reserved_gne__c = uDetailFromUserWithLotNo.Qty_Reserved_gne__c - trans.Received_Quantity_gne__c;
                    if(uDetailFromUserWithLotNo.Expiration_Date_gne__c != null)
                    {
                    	uDetailFromUserWithLotNo.Active_gne__c = uDetailFromUserWithLotNo.Expiration_Date_gne__c >= Date.today();
                    }
                    // Just to include modified User Detail in update
                    uDetailFromUser = uDetailFromUserWithLotNo;
                }
                else
                {
                	//exception - record should exist FROM USER PERSPECTIVE
                	handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_No_gne__c));
                }
                    if(uDetailToUser != null)
                    {
                        //update scenario TO USER PERSPECTIVE
                        if(transOld!=null)
                        {
                            if(trans.Received_Quantity_gne__c != transOld.Received_Quantity_gne__c)
                            {
                                if(uDetailToUser.Expiration_Date_gne__c != null)
                                {
                                    uDetailToUser.Active_gne__c = uDetailToUser.Expiration_Date_gne__c >= Date.today();
                                }
                                uDetailToUser.Lot_NO_gne__c = trans.Lot_NO_gne__c;
                                uDetailToUser.Qty_Total_Allocated_gne__c = uDetailToUser.Qty_Total_Allocated_gne__c + trans.Received_Quantity_gne__c;
                                uDetailToUser.YTD_Allocated_gne__c = uDetailToUser.YTD_Allocated_gne__c + trans.Received_Quantity_gne__c;
                            }
                        }
                        else
                        {
                            if(uDetailToUser.Expiration_Date_gne__c != null)
                            {
                                uDetailToUser.Active_gne__c = uDetailToUser.Expiration_Date_gne__c >= Date.today();
                            }
                            uDetailToUser.Lot_NO_gne__c = trans.Lot_NO_gne__c;
                            uDetailToUser.Qty_Total_Allocated_gne__c = uDetailToUser.Qty_Total_Allocated_gne__c + trans.Received_Quantity_gne__c;
                            uDetailToUser.YTD_Allocated_gne__c = uDetailToUser.YTD_Allocated_gne__c + trans.Received_Quantity_gne__c;
                        }
                    }
                    else
                    {
                        ////insert scenario TO USER PERSPECTIVE
                        uDetailToUser = createUserDetail(trans, false, trans.Received_Quantity_gne__c, trans.Received_Quantity_gne__c);
            	        GNE_SFA2_PFG_Util.addPfgToUserDetailToCache(uDetailToUser);
                    }
            }
            addPfgUserDetailToUpsert(uDetailToUser);
            addPfgUserDetailToUpsert(uDetailFromUser);
        }
    }

    //method for Transfer transactions
    private static void processTransfers (List<SFA2_PFG_Transaction_gne__c> transferTransactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        for(SFA2_PFG_Transaction_gne__c trans : transferTransactions)
        {

            SFA2_PFG_to_User_Detail_gne__c uDetailFromUser = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c);
            SFA2_PFG_to_User_Detail_gne__c uDetailToUser = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.To_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c);
            //process records only From User perspective, for To User perspective no inserts/updates required!
            if(trans.Received_Quantity_gne__c == null || trans.Received_Quantity_gne__c == 0)
            {
                if(uDetailFromUser != null)
                {
                     uDetailFromUser.Qty_Reserved_gne__c = uDetailFromUser.Qty_Reserved_gne__c + trans.Requested_Quantity_gne__c;
                }
                else
                {
                    handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c));
                }
            }
            if(trans.Received_Quantity_gne__c != null && trans.Received_Quantity_gne__c != 0)
            {
                if(uDetailFromUser != null)
                {
                    if(uDetailFromUser.Expiration_Date_gne__c != null)
                    {
                        uDetailFromUser.Active_gne__c = uDetailFromUser.Expiration_Date_gne__c >= Date.today();
                    }
                    uDetailFromUser.Qty_Reserved_gne__c = uDetailFromUser.Qty_Reserved_gne__c - trans.Requested_Quantity_gne__c;
                    uDetailFromUser.Qty_Transferred_Out_gne__c = uDetailFromUser.Qty_Transferred_Out_gne__c + trans.Received_Quantity_gne__c;
                }
                else
                {
                    handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c));
                }
                if(uDetailToUser == null)
                {
                	uDetailToUser = createUserDetail(trans, false, 0.0, 0.0);
                	uDetailToUser.Qty_Transferred_In_gne__c = trans.Received_Quantity_gne__c;
                    GNE_SFA2_PFG_Util.addPfgToUserDetailToCache(uDetailToUser);
                }
                else
                {
                    if(uDetailToUser.Expiration_Date_gne__c != null)
                    {
                        uDetailToUser.Active_gne__c = uDetailToUser.Expiration_Date_gne__c >= Date.today();
                    }
                    uDetailToUser.Qty_Transferred_In_gne__c = uDetailToUser.Qty_Transferred_In_gne__c + trans.Received_Quantity_gne__c;
                }
            }
            addPfgUserDetailToUpsert(uDetailToUser);
            addPfgUserDetailToUpsert(uDetailFromUser);
        }
    }
    //method for Order transactions
    private static void processOrders (List<SFA2_PFG_Transaction_gne__c> orderTransactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        //need to confirm if the User in PFG to User Detail should be From_User or To_User comming from Transaction!!!
        //my assumption is that PFG to User Detail User is To_User as we are operating in CS perspective
        for(SFA2_PFG_Transaction_gne__c trans : orderTransactions)
        {
            SFA2_PFG_to_User_Detail_gne__c uDetail = null;
            if(trans.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC)
            {
                uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.To_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c);
            }
            if(uDetail != null)
            {

                if(uDetail.Expiration_Date_gne__c != null)
                {
                     uDetail.Active_gne__c = uDetail.Expiration_Date_gne__c >= Date.today();
                }
                uDetail.Qty_Total_Allocated_gne__c = uDetail.Qty_Total_Allocated_gne__c + trans.Received_Quantity_gne__c;
                uDetail.YTD_Allocated_gne__c = uDetail.YTD_Allocated_gne__c + trans.Received_Quantity_gne__c;
            }
            else
            {
            	uDetail = createUserDetail(trans, false, trans.Received_Quantity_gne__c, trans.Received_Quantity_gne__c);
                GNE_SFA2_PFG_Util.addPfgToUserDetailToCache(uDetail);
            }
            addPfgUserDetailToUpsert(uDetail);
        }
    }
    //method for Return transactions
    private static void processReturns (List<SFA2_PFG_Transaction_gne__c> returnTransactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        //only for Hand Carry, assumption is that PFG to User Detail Lot# is Transaction Lot#
        //need to confirm if the PFG to User Detail User is From_User or To_User from Transaction
        //my assumption is PFG User is To_User from Transaction as we are operating in CS perspective
        //only update scenario - assumption is that PDG to User Detail exists as CS has had quantity
        for(SFA2_PFG_Transaction_gne__c trans : returnTransactions)
        {
            SFA2_PFG_to_User_Detail_gne__c uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c);
            if(uDetail != null)
            {
                if(uDetail.Expiration_Date_gne__c != null)
                {
                    uDetail.Active_gne__c = uDetail.Expiration_Date_gne__c >= Date.today();
                }
                uDetail.Qty_Returned_gne__c = uDetail.Qty_Returned_gne__c + trans.Requested_Quantity_gne__c;
                addPfgUserDetailToUpsert(uDetail);
            }
            else
            {
                handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_NO_gne__c));
            }
        }
    }
    //methods for Disbursement transactions
    private static void processDisbursement(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        //shell gathering all disbursement processes among diffrent objects
        processDisbursementOnPFGtoUser(transactions, oldTransactionsMap);
        processDisbursementOnPFGtoAccount(transactions, oldTransactionsMap);
    }
    private static void processDisbursementOnPFGtoUser(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        for(SFA2_PFG_Transaction_gne__c trans : transactions)
        {
            SFA2_PFG_to_User_Detail_gne__c uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_No_gne__c);
            if(uDetail!=null)
            {
                if(uDetail.Qty_Disbursed_gne__c == null)
                {
                    uDetail.Qty_Disbursed_gne__c = 0;
                    uDetail.Qty_Disbursed_gne__c = uDetail.Qty_Disbursed_gne__c + trans.Received_Quantity_gne__c;
                }
                else
                {
                    uDetail.Qty_Disbursed_gne__c = uDetail.Qty_Disbursed_gne__c + trans.Received_Quantity_gne__c;
                }

                addPfgUserDetailToUpsert(uDetail);
            }
            else
            {
                handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_No_gne__c));
            }
        }
    }
    private static void processDisbursementOnPFGtoAccount(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        for(SFA2_PFG_Transaction_gne__c trans : transactions)
        {

            SFA2_PFG_to_Account_Detail_gne__c accDetail = GNE_SFA2_PFG_Util.getPfgToAccountDetail(trans);
            if(accDetail == null)
            {
                accDetail = createAccountDetail(trans);
            }
            else
            {
                if(accDetail.Qty_Disbursed_gne__c == null)
                {
                    accDetail.Qty_Disbursed_gne__c = 0;
                    accDetail.Qty_Disbursed_gne__c += trans.Received_Quantity_gne__c;
                }
                else
                {
                    accDetail.Qty_Disbursed_gne__c = accDetail.Qty_Disbursed_gne__c + trans.Received_Quantity_gne__c;
                }
            }
            addPfgAccountDetailToUpsert(accDetail);
        }
    }
    //methods for Adjustment transactions
    private static void processAdjustment(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        //shell gathering all Adjustment processes among diffrent objects
        processAdjustmentOnPFGtoUser(transactions, oldTransactionsMap);
        processAdjustmentOnPFGtoAccount(transactions, oldTransactionsMap);
    }
    private static void processAdjustmentOnPFGtoUser(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        List<SFA2_PFG_Transaction_gne__c> transWithCallId = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> transFromInventory = new List<SFA2_PFG_Transaction_gne__c>();
        for(SFA2_PFG_Transaction_gne__c pfgTrans : transactions)
        {
            if(pfgTrans.Call_PFG_Detail_ID_gne__c != null)
            {
                transWithCallId.add(pfgTrans);
            }
            if(pfgTrans.Inventory_Count_Flag_gne__c == true)
            {
                transFromInventory.add(pfgTrans);
            }
        }
        //HCP driven Adjustment
        if(!transWithCallId.isEmpty())
        {
            Set<String> callIds = GNE_SFA2_PFG_Util.getCallIds(transWithCallId);
            List<SFA2_PFG_Transaction_gne__c> validTransactions = new List<SFA2_PFG_Transaction_gne__c>();
            List<SFA2_PFG_Inventory_Count_gne__c> inventoryCounts = getInventoryCountForDisbursementTransaction(callIds);
            if(inventoryCounts != null && inventoryCounts.size()>0)
            {
                validTransactions = getVaildAdjustmentTransactions(inventoryCounts, transWithCallId);
            }
            else
            {
                validTransactions.addAll(transWithCallId);
            }
            for(SFA2_PFG_Transaction_gne__c trans : validTransactions)
            {
                SFA2_PFG_to_User_Detail_gne__c uDetail = GNE_SFA2_PFG_Util.getPfgToUserDetail(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_No_gne__c);
                if(uDetail != null)
                {

                    if(uDetail.Qty_Disbursed_gne__c != null)
                    {
                    	Double totAvailableQty = uDetail.Qty_Total_Available_gne__c;
                        uDetail.Qty_Disbursed_gne__c = uDetail.Qty_Disbursed_gne__c + Math.min(totAvailableQty, trans.Requested_Quantity_gne__c);
                    }
                    else
                    {
                        uDetail.Qty_Disbursed_gne__c = 0.0;
                    }
                    addPfgUserDetailToUpsert(uDetail);
                }
                else
                {
                    handleException(new MissingDetailRecordException(trans.From_User_gne__c, trans.Product_gne__c, trans.Lot_No_gne__c));
                }
            }
        }
        //Internal driven Adjustment
        if(!transFromInventory.isEmpty())
        {
            for(SFA2_PFG_Transaction_gne__c trxInv : transFromInventory)
            {
                SFA2_PFG_to_User_Detail_gne__c uDetailInv = GNE_SFA2_PFG_Util.getPfgToUserDetail(trxInv.To_User_gne__c, trxInv.Product_gne__c, trxInv.Lot_No_gne__c);
                if(uDetailInv != null)
                {
                	Double totAvailableQty = uDetailInv.Qty_Total_Available_gne__c;
                    uDetailInv.Qty_Adjusted_gne__c = uDetailInv.Qty_Adjusted_gne__c + Math.max(-totAvailableQty, trxInv.Requested_Quantity_gne__c);
                }
                else
                {
                    //insert scenario
                    uDetailInv = createUserDetail(trxInv, false, 0.0, 0.0);
                    uDetailInv.Qty_Adjusted_gne__c = Math.max(0, trxInv.Requested_Quantity_gne__c);

                    if(uDetailInv.Expiration_Date_gne__c != null) {
                        uDetailInv.Active_gne__c = uDetailInv.Expiration_Date_gne__c >= Date.today();
                    }

                    GNE_SFA2_PFG_Util.addPfgToUserDetailToCache(uDetailInv);
                }
                addPfgUserDetailToUpsert(uDetailInv);
            }
        }
    }
    private static void processAdjustmentOnPFGtoAccount(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap)
    {
        for(SFA2_PFG_Transaction_gne__c trans : transactions)
        {
            if(trans.Call_Name_gne__c != null)
            {
                SFA2_PFG_to_Account_Detail_gne__c accDetail = GNE_SFA2_PFG_Util.getPfgToAccountDetail(trans);
                if(accDetail != null)
                {
                	accDetail.Qty_Disbursed_gne__c = accDetail.Qty_Disbursed_gne__c + trans.Requested_Quantity_gne__c;
                	addPfgAccountDetailToUpsert(accDetail);
                }
                else
                {
                    handleException(new MissingDetailRecordException(trans.Account_gne__c, trans.Product_gne__c, String.valueOf(GNE_SFA2_PFG_Util.getYear(trans))));
                }
            }
        }
    }

    private static void processDtpOrder(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap) {
        processDtpOrderOnPFGtoTerritory(transactions, oldTransactionsMap);
        processDtpOrderOnPFGtoAccount(transactions, oldTransactionsMap);
    }

    private static void processDtpOrderOnPFGtoTerritory(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap) {
    	for(SFA2_PFG_Transaction_gne__c trans : transactions) {
        	SFA2_PFG_Transaction_gne__c transOld = oldTransactionsMap.get(trans.Id);
            SFA2_PFG_to_Territory_Detail_gne__c tDetail = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(trans.From_Territory_Name_gne__c, trans.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trans));

            if(tDetail != null) {
            	Boolean somethingChanged = false;

                String newDeliveryStatus = String.isNotBlank(trans.Delivery_Status_gne__c) ? trans.Delivery_Status_gne__c.toUpperCase() : '';
            	String oldDeliveryStatus = (transOld!=null && String.isNotBlank(transOld.Delivery_Status_gne__c)) ? transOld.Delivery_Status_gne__c.toUpperCase() : '';
            	//DTP Canceled
                if(GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES.contains(newDeliveryStatus)) {
                	if(transOld!=null && !GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES.contains(oldDeliveryStatus)) {
                    	if(transOld.Shipped_Quantity_gne__c!=0) {
                    		tDetail.Qty_Shipped_to_Physician_gne__c -= transOld.Shipped_Quantity_gne__c;
                    	} else {
                    		tDetail.Qty_Reserved_gne__c -= transOld.Requested_Quantity_gne__c;
                    	}

                    	somethingChanged = true;
                	}
                } //DTP Shipment
                else if((transOld != null && trans.Shipped_Quantity_gne__c!=transOld.Shipped_Quantity_gne__c) || (transOld==null && trans.Shipped_Quantity_gne__c!=0)) {
                	if(transOld!=null && transOld.Shipped_Quantity_gne__c==0) {
                		tDetail.Qty_Reserved_gne__c -= transOld.Requested_Quantity_gne__c;
                	}

                	Double delta = trans.Shipped_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Shipped_Quantity_gne__c);
                	tDetail.Qty_Shipped_to_Physician_gne__c += delta;
                	somethingChanged = true;
                } //DTP Request
                else if(transOld == null || (trans.Requested_Quantity_gne__c != transOld.Requested_Quantity_gne__c && transOld.Shipped_Quantity_gne__c==0)) {
                	Double delta = trans.Requested_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Requested_Quantity_gne__c);
                	tDetail.Qty_Reserved_gne__c += delta;
                	somethingChanged = true;
                }

                if(somethingChanged) {
                	addPfgTerritoryDetailToUpsert(tDetail);
                }
            } else {
                handleException(new MissingDetailRecordException(trans.From_Territory_Name_gne__c, trans.Product_gne__c, null));
            }
        }
    }

    private static void processDtpOrderOnPFGtoAccount(List<SFA2_PFG_Transaction_gne__c> transactions, Map<Id, SFA2_PFG_Transaction_gne__c> oldTransactionsMap) {
        GNE_SFA2_PFG_Util.cacheOverdueSignatureTransactions(transactions);

        for(SFA2_PFG_Transaction_gne__c trans : transactions) {
        	SFA2_PFG_Transaction_gne__c transOld = oldTransactionsMap.get(trans.Id);
            SFA2_PFG_to_Account_Detail_gne__c accDetail = GNE_SFA2_PFG_Util.getPfgToAccountDetail(trans);
            Boolean somethingChanged = false;
            if(accDetail!=null) {

            	String newDeliveryStatus = String.isNotBlank(trans.Delivery_Status_gne__c) ? trans.Delivery_Status_gne__c.toUpperCase() : '';
            	String oldDeliveryStatus = (transOld!=null && String.isNotBlank(transOld.Delivery_Status_gne__c)) ? transOld.Delivery_Status_gne__c.toUpperCase() : '';
            	//DTP Canceled
                if(GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES.contains(newDeliveryStatus)) {
                	if(transOld!=null && !GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES.contains(oldDeliveryStatus)) {
	                    if(transOld.Received_Quantity_gne__c!=0) {
	                    	accDetail.Qty_Disbursed_gne__c -= transOld.Received_Quantity_gne__c;
	                    } else if(transOld.Shipped_Quantity_gne__c!=0) {
	                    	accDetail.Qty_Disbursed_gne__c -= transOld.Shipped_Quantity_gne__c;
	                    } else {
	                    	accDetail.Qty_to_Fulfill_gne__c -= transOld.Requested_Quantity_gne__c;
	                    }

	                    somethingChanged = true;
                	}
                } //DTP Receipt
                else if((transOld != null && trans.Received_Quantity_gne__c!=transOld.Received_Quantity_gne__c) || (transOld==null && trans.Received_Quantity_gne__c!=0)) {
                	if(transOld!=null && transOld.Received_Quantity_gne__c==0) {
                		accDetail.Qty_Disbursed_gne__c -= transOld.Shipped_Quantity_gne__c;
                	}

                	if(transOld!=null && transOld.Shipped_Quantity_gne__c==0) {
                		accDetail.Qty_to_Fulfill_gne__c -= transOld.Requested_Quantity_gne__c;
                	}

                	Double delta = trans.Received_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Received_Quantity_gne__c);
                	accDetail.Qty_Disbursed_gne__c += delta;

					List<SFA2_PFG_Transaction_gne__c> transactionsWithOverdueSignatures = GNE_SFA2_PFG_Util.getOverdueSignatureTransactions(
							trans.Account_gne__c, trans.Product_gne__c);

                    if(transactionsWithOverdueSignatures != null && !transactionsWithOverdueSignatures.isEmpty()) {
                    	accDetail.Freeze_for_Pending_AOC_gne__c = 'Yes';
                    }

                    somethingChanged = true;
                } //DTP Shipment
                else if((transOld != null && trans.Shipped_Quantity_gne__c!=transOld.Shipped_Quantity_gne__c && transOld.Received_Quantity_gne__c==0) || (transOld==null && trans.Shipped_Quantity_gne__c!=0)) {
                	if(transOld!=null && transOld.Shipped_Quantity_gne__c==0) {
                		accDetail.Qty_to_Fulfill_gne__c -= transOld.Requested_Quantity_gne__c;
                	}

                	Double delta = trans.Shipped_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Shipped_Quantity_gne__c);
                	accDetail.Qty_Disbursed_gne__c += delta;
                	somethingChanged = true;
                }
                //DTP Request
                else if(transOld == null || (trans.Requested_Quantity_gne__c != transOld.Requested_Quantity_gne__c && transOld.Shipped_Quantity_gne__c==0 && transOld.Received_Quantity_gne__c==0))
                {
                	Double delta = trans.Requested_Quantity_gne__c - (transOld == null ? 0.0 : transOld.Requested_Quantity_gne__c);
                	accDetail.Qty_to_Fulfill_gne__c += delta;
                	somethingChanged = true;
                }
            } //DTP Request - new Account Detail Record
            else {
                accDetail = createAccountDetail(trans);
                somethingChanged = true;
            }

            if(somethingChanged) {
            	addPfgAccountDetailToUpsert(accDetail);
            }
        }
    }
    //HCP driven Transactions supporting methods
    //method to get all Inventory Count records where Lot, Product and User are the same as for Disbursement Transactions for given PFG Call Id and Inventory Count Date is less than Disbursement Transaction Date
    private static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountForDisbursementTransaction(Set<String> callIds)
    {
        List<SFA2_PFG_Transaction_gne__c> disbursementTransactions = [Select To_User_gne__c, From_User_gne__c, Product_gne__c, Lot_No_gne__c, Call_PFG_Detail_ID_gne__c, Transaction_Date_gne__c  from SFA2_PFG_Transaction_gne__c where Call_PFG_Detail_ID_gne__c IN : callIds AND Transaction_Type_gne__c =: GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT];
        Set<String> transactionsProducts = GNE_SFA2_PFG_Util.getTransactionsProducts(disbursementTransactions);
        Set<String> transactionsUsers= GNE_SFA2_PFG_Util.getTransactionsUsers(disbursementTransactions);
        Set<String> transactionsLotNOs = GNE_SFA2_PFG_Util.getTransactionsLotNOs(disbursementTransactions);
        List<SFA2_PFG_Inventory_Count_gne__c> tmpInventoryCounts = [Select Inventory_For_gne__c, Lot_gne__c, Product_gne__c, Inventory_Count_Date_gne__c from SFA2_PFG_Inventory_Count_gne__c where Inventory_For_gne__c IN: transactionsUsers AND Lot_gne__c IN: transactionsLotNOs AND Product_gne__c IN: transactionsProducts];
        List<SFA2_PFG_Inventory_Count_gne__c> inventryCounts = new List<SFA2_PFG_Inventory_Count_gne__c>();

        for(SFA2_PFG_Inventory_Count_gne__c incCount : tmpInventoryCounts)
        {
            for(SFA2_PFG_Transaction_gne__c pfgTrans : disbursementTransactions)
            {
                if(incCount.Inventory_For_gne__c == pfgTrans.From_User_gne__c &&  incCount.Lot_gne__c == pfgTrans.Lot_No_gne__c && incCount.Product_gne__c == pfgTrans.Product_gne__c && incCount.Inventory_Count_Date_gne__c < pfgTrans.Transaction_Date_gne__c)
                {
                    inventryCounts.add(incCount);
                }
            }
        }
        return inventryCounts;
    }
    private static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountForAdjustmentWithoutCallId(List<SFA2_PFG_Transaction_gne__c> transactions)
    {
        Set<String> lotNOs = new Set<String>();
        Set<String> transUsersIds = new Set<String>();
        Set<String> productsIds = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c trans : transactions)
        {
            lotNOs.add(trans.Lot_NO_gne__c);
            transUsersIds.add(trans.To_User_gne__c);
            productsIds.add(trans.Product_gne__c);
        }
        List<SFA2_PFG_Inventory_Count_gne__c> tmpInventoryCounts = [Select Lot_gne__c, Product_gne__c, Inventory_For_gne__c, Difference_gne__c from SFA2_PFG_Inventory_Count_gne__c where Lot_gne__c IN: lotNOs AND Inventory_For_gne__c IN: transUsersIds AND Product_gne__c IN: productsIds];
        return tmpInventoryCounts;
    }
    //method to get valid adjustment transactions based on inventory count and all adjustment transactions
    private static List<SFA2_PFG_Transaction_gne__c> getVaildAdjustmentTransactions(List<SFA2_PFG_Inventory_Count_gne__c> inventoryCounts, List<SFA2_PFG_Transaction_gne__c> transactions)
    {
        List<SFA2_PFG_Transaction_gne__c> tmpTransactions = new List<SFA2_PFG_Transaction_gne__c>();
        for(SFA2_PFG_Inventory_Count_gne__c invCount : inventoryCounts)
        {
            for(SFA2_PFG_Transaction_gne__c pfgTrans : transactions)
            {
                if(invCount.Inventory_For_gne__c == pfgTrans.From_User_gne__c &&  invCount.Lot_gne__c == pfgTrans.Lot_No_gne__c && invCount.Product_gne__c == pfgTrans.Product_gne__c)
                {
                    tmpTransactions.add(pfgTrans);
                }
            }
        }
        return tmpTransactions;
    }
    private static Map<SFA2_PFG_Transaction_gne__c, SFA2_PFG_Inventory_Count_gne__c> getInventoryCountPerTransaction(List<SFA2_PFG_Inventory_Count_gne__c> inventoryCounts, List<SFA2_PFG_Transaction_gne__c> transactions)
    {
        Map<SFA2_PFG_Transaction_gne__c, SFA2_PFG_Inventory_Count_gne__c> tmpMap = new Map<SFA2_PFG_Transaction_gne__c, SFA2_PFG_Inventory_Count_gne__c>();
        for(SFA2_PFG_Transaction_gne__c pfgTrans : transactions)
        {
            for(SFA2_PFG_Inventory_Count_gne__c invCount : inventoryCounts)
            {
                if(invCount.Inventory_For_gne__c == pfgTrans.To_User_gne__c &&  invCount.Lot_gne__c == pfgTrans.Lot_No_gne__c && invCount.Product_gne__c == pfgTrans.Product_gne__c)
                {
                    tmpMap.put(pfgTrans, invCount);
                }
            }
        }
        return tmpMap;
    }

    private static void addPfgUserDetailToUpsert(SFA2_PFG_to_User_Detail_gne__c uDetail) {
    	if(uDetail!= null) {
        	pfgToUserDetailsToUpsert.put(GNE_SFA2_PFG_Util.getRecordKey(uDetail), uDetail);
        }
    }

    private static void addPfgUserDetailToDmUpsert(SFA2_PFG_to_User_Detail_gne__c uDetail) {
    	if(uDetail!= null) {
        	pfgToUserDetailDMtoUpsert.put(GNE_SFA2_PFG_Util.getRecordKey(uDetail), uDetail);
        }
    }

    private static void addPfgTerritoryDetailToUpsert(SFA2_PFG_to_Territory_Detail_gne__c tDetail) {
    	if(tDetail!=null) {
    		pfgToTerritoryDetailsToUpsert.put(GNE_SFA2_PFG_Util.getRecordKey(tDetail), tDetail);
    	}
    }

    private static void addPfgAccountDetailToUpsert(SFA2_PFG_to_Account_Detail_gne__c aDetail) {
    	if(aDetail!=null) {
    		pfgToAccountDetailsToUpsert.put(GNE_SFA2_PFG_Util.getRecordKey(aDetail), aDetail);
    	}
    }

    private static SFA2_PFG_to_User_Detail_gne__c createUserDetail(SFA2_PFG_Transaction_gne__c trans, Boolean fromOrToUser,
    		Decimal allocatedQty,  Decimal ytdQty) {
    	SFA2_Lot_Catalog_gne__c lCatalog  = lotCatalogList.get(trans.Lot_No_gne__c);
    	SFA2_PFG_to_User_Detail_gne__c uDetail = new SFA2_PFG_to_User_Detail_gne__c(
    		Active_gne__c = true,
            User_gne__c = (fromOrToUser ? trans.From_User_gne__c : trans.To_User_gne__c),
            Distribution_Method_gne__c = trans.Distribution_Method_gne__c,
            Product_gne__c = trans.Product_gne__c,
            Lot_NO_gne__c = trans.Lot_No_gne__c,
            UOM_gne__c = trans.UOM_gne__c,
            Expiration_Date_gne__c = (lCatalog!=null ? lCatalog.Expiration_Date_gne__c : null),
            Qty_Total_Allocated_gne__c = allocatedQty,
            YTD_Allocated_gne__c = ytdQty,
            Qty_Adjusted_gne__c = 0,
            Qty_Disbursed_gne__c = 0,
            Qty_Last_Physical_Inventory_gne__c = 0,
            Qty_Reserved_gne__c = 0,
            Qty_Returned_gne__c = 0,
            Qty_Shipped_to_Physician_gne__c = 0,
            Qty_Transferred_In_gne__c = 0,
            Qty_Transferred_Out_gne__c = 0);
        return uDetail;
    }

    private static SFA2_PFG_to_Territory_Detail_gne__c createTerritoryDetail(SFA2_PFG_Transaction_gne__c trans, Boolean fromOrToTerritory,
    		Decimal allocatedQty,  Decimal ytdQty) {
    	SFA2_PFG_to_Territory_Detail_gne__c tDetail = new SFA2_PFG_to_Territory_Detail_gne__c(
    		Active_gne__c = true,
            Distribution_Method_gne__c = trans.Distribution_Method_gne__c,
            Lot_NO_gne__c = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE,
            Product_gne__c = trans.Product_gne__c,
            Year_gne__c = GNE_SFA2_PFG_Util.getYear(trans),
            Qty_Total_Allocated_gne__c = allocatedQty,
            YTD_Allocated_gne__c = ytdQty,
            Territory_gne__c = (fromOrToTerritory ? trans.From_User_Territory_gne__c : trans.To_User_Territory_gne__c),
            Territory_Name_gne__c = (fromOrToTerritory ? trans.From_Territory_Name_gne__c : trans.To_Territory_Name_gne__c),
            Territory_Number_gne__c = (fromOrToTerritory ? trans.From_Territory_Number_gne__c : trans.To_Territory_Number_gne__c),
            UOM_gne__c = trans.UOM_gne__c,
            Qty_Adjusted_gne__c = 0,
            Qty_Reserved_gne__c = 0,
            Qty_Shipped_to_Physician_gne__c = 0
    	);

    	GNE_SFA2_PFG_Util.addPfgToTerritoryDetailToCache(tDetail);
    	return tDetail;
    }

    private static SFA2_PFG_to_Account_Detail_gne__c createAccountDetail(SFA2_PFG_Transaction_gne__c trans) {
    	SFA2_PFG_to_Account_Detail_gne__c accDetail = new SFA2_PFG_to_Account_Detail_gne__c(
        	Account_gne__c = trans.Account_gne__c,
            Product_gne__c = trans.Product_gne__c,
            Qty_Disbursed_gne__c = 0,
            Qty_to_Fulfill_gne__c = 0,
            Max_Quantity_gne__c = -1,
            Exception_Quantity_gne__c = 0,
            Exception_Limit_gne__c = false,
            Distribution_Method_gne__c = trans.Distribution_Method_gne__c,
            Freeze_for_Pending_AOC_gne__c = 'No',
            Limit_Year_gne__c = String.valueOf(GNE_SFA2_PFG_Util.getYear(trans))
        );

        if(trans.Received_Quantity_gne__c>0) {
        	accDetail.Qty_Disbursed_gne__c = trans.Received_Quantity_gne__c;
        } else if(trans.Shipped_Quantity_gne__c>0) {
        	accDetail.Qty_Disbursed_gne__c = trans.Shipped_Quantity_gne__c;
        } else {
           	accDetail.Qty_to_Fulfill_gne__c = trans.Requested_Quantity_gne__c;
        }

        SFA2_PFG_Product_Limit_gne__c productLimitYear = GNE_SFA2_PFG_Util.getProductLimit(trans);
        if(productLimitYear != null && productLimitYear.Inactive_gne__c != true) {
        	accDetail.Max_Quantity_gne__c = productLimitYear.Limit_Quantity_gne__c;
        }

        PFG_Staging_Account_Limit_Exception_gne__c accountLimitException = GNE_SFA2_PFG_Util.getAccLimitException(trans);
        if(accountLimitException!=null) {
        	accDetail.Exception_Limit_gne__c = true;
            accDetail.Exception_Quantity_gne__c = accountLimitException.Exception_Quantity_gne__c;
        }

        GNE_SFA2_PFG_Util.addPfgToAccountDetailToCash(accDetail);
        return accDetail;
    }

    public class MissingDetailRecordException extends Exception {
    	public MissingDetailRecordException(String terrOrUserId, String productName, String lotNo) {
    		this(String.format('Detail Record is missing for {0}::{1}' + (lotNo!=null ? '::{2}' : ''), new String[]{terrOrUserId, productName, lotNo}));
    	}
    }

    public class MissingTerritoryException extends Exception {

    	public MissingTerritoryException(String trxType, String terrName) {
    		this(String.format('Territory \'{0}\' is missing for {1}', new String[]{terrName, trxType}));
    	}
    }

    public class UserRoleNotDefinedException extends Exception {

    	public UserRoleNotDefinedException(String trxType, Id userId) {
    		this(String.format('User Role is not defined. User Id: {0}, Transaction: {1}', new String[]{userId, trxType}));
    	}
    }


    public static void handleException(Exception ex) {
    	GNE_SFA2_PFG_Util.handleException(ex);
    }

    public static void reportExceptions() {
    	GNE_SFA2_PFG_Util.reportExceptions();
    }
}