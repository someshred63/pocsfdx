@isTest
public with sharing class GNE_SFA2_PFG_IA_Test {
    
    private static Map<String, SFA2_PFG_Transaction_gne__c> transactionCache;
    private static Integer soqlCount;

    private static User prepareEnvWithTerrs(String userName) {
        User result = prepareEnv(userName);
        GNE_SFA2_PFG_TestHelper.prepareTerritoriesForUsers();
        return result;
    }
    
    private static User prepareEnv(String userName) {
        soqlCount = 0;
        return GNE_SFA2_PFG_TestHelper.prepareEnv(userName);
    }
    
    private static void printMetrics() {
        System.debug('[BOS]:: SOQL used queries: ' + soqlCount + '/' + Limits.getLimitQueries());
    }
    
    private static void insertTransactions(String pfgType) {
        insertTransactions(pfgType, new Set<String>{pfgType + '1'}, new Map<String,Integer>{
            'null:HO1' => 500,
            'HO1:DM1' => 200,
            'DM1:CS1' => 100
//            'DM1:CS2' => 50
        });
    }
    
    private static void insertTransactions(String pfgType, String prodName, Map<String,Integer> transactionData) {
        insertTransactions(pfgType, new Set<String>{prodName}, transactionData);
    }
    
    private static void insertTransactions(String pfgType, Set<String> prodNames, Map<String,Integer> transactionData) {
        Integer prevSoqlCount = GNE_SFA2_PFG_TestHelper.soqlCount;
        GNE_SFA2_PFG_TestHelper.insertAllocationTransfers(pfgType, prodNames, transactionData);
        soqlCount += GNE_SFA2_PFG_TestHelper.soqlCount - prevSoqlCount;
    }
    
    private static void generateShipment(Set<String> userNames) {
        GNE_SFA2_PFG_Util.clearPfgToUserCache();
        Set<Id> userIds = new Set<Id>();
        Map<String, User> users = GNE_SFA2_PFG_TestHelper.userHelper.userCache;
        
        for(String userName : userNames) {
            userIds.add(users.get(userName).Id);
        }
        
        List<SFA2_PFG_Transaction_gne__c> handCarryAllocs = GNE_SFA2_PFG_DAO.getTransactions(
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                        new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
                        new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_gne__c', 'IN', userIds),
                        new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED)
                    },
            null
        );
        // Make sure that storage locations are cached for current transactions
        GNE_SFA2_PFG_Util.cacheStorageLocations(handCarryAllocs, true);
        Integer beforeCount = Limits.getQueries();
        Set<Id> invalidIds = GNE_SFA2_PFG_Util.generateShipment(handCarryAllocs);
        soqlCount += Limits.getQueries() - beforeCount;
        System.assertEquals(0,invalidIds.size(),'CS Allocation Transfers are invalid for Generate Shipment action');
    }
    
    private static void virtualReceive(String lotNo, Set<String> userNames, Map<String,Integer> shippedDiff, Map<String,Integer> receiveDiff) {
        GNE_SFA2_PFG_Util.clearPfgToUserCache();
        Set<Id> userIds = new Set<Id>();
        Map<Id,String> userIdToKeyMap = new Map<Id,String>();
        Map<String, User> users = GNE_SFA2_PFG_TestHelper.userHelper.userCache;
        
        for(String userName : userNames) {
            userIds.add(users.get(userName).Id);
            userIdToKeyMap.put(users.get(userName).Id, userName);
        }
        
        List<SFA2_PFG_Transaction_gne__c> handCarryAllocs = GNE_SFA2_PFG_DAO.getTransactions(
            new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                        new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
                        new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_gne__c', 'IN', userIds),
                        new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED)
                    },
            null
        );
        
        Map<Id,SFA2_PFG_Transaction_gne__c> cachedTrns = new Map<Id,SFA2_PFG_Transaction_gne__c>(GNE_SFA2_PFG_TestHelper.allocTransfersCache.values());
        List<SFA2_PFG_Transaction_gne__c> trnsToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
        for (SFA2_PFG_Transaction_gne__c alloc : handCarryAllocs) {
            if(!cachedTrns.containsKey(alloc.Id)) {
                continue;
            }
            
            SFA2_Lot_Catalog_gne__c lot = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).get(alloc.Product_gne__c);
            
            Integer shippedDelta = shippedDiff!=null ? shippedDiff.get(userIdToKeyMap.get(alloc.To_User_gne__c)) : null;
            Integer receiveDelta = receiveDiff!=null ? receiveDiff.get(userIdToKeyMap.get(alloc.To_User_gne__c)) : null;
            
            alloc.Shipped_Quantity_gne__c = alloc.Requested_Quantity_gne__c + (shippedDelta!=null ? shippedDelta : 0);
            alloc.Received_Quantity_gne__c = alloc.Requested_Quantity_gne__c + (receiveDelta!=null ? receiveDelta : 0);
            alloc.Lot_No_gne__c = lot.Name;
            trnsToUpdate.add(alloc);
        }
        Integer beforeCount = Limits.getQueries();
        update trnsToUpdate;
        soqlCount += Limits.getQueries() - beforeCount;
    }
    
    private static void assertTransaction(String pfgType, String fromUserName, String toUserName, String status, String gShipmentFlag, 
            Integer reqQty, Integer shipQty, Integer recQty) {
        assertTransaction(pfgType, fromUserName, toUserName, status, gShipmentFlag, reqQty, shipQty, recQty, true);
    }
    
    private static void assertTransaction(String pfgType, String fromUserName, String toUserName, String status, String gShipmentFlag, 
            Integer reqQty, Integer shipQty, Integer recQty, Boolean fromCache) {
        assertTransaction(pfgType, fromUserName, toUserName, pfgType + '1', status, gShipmentFlag, reqQty, shipQty, recQty, fromCache);
    }
    
    private static void assertTransaction(String pfgType, String fromUserName, String toUserName, String prodName, String status, String gShipmentFlag, 
            Integer reqQty, Integer shipQty, Integer recQty, Boolean fromCache) {
        List<SFA2_PFG_Transaction_gne__c> trxs = null;
        String trxKey = fromUserName + ':' + toUserName + ':' + prodName;
        
        if(fromCache) {
            
            trxs = GNE_SFA2_PFG_DAO.getTransactions(
                new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
                null,
                new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Id', '=', GNE_SFA2_PFG_TestHelper.allocTransfersCache.get(trxKey).Id)
                },
                null);
        } else {
            Map<String, User> users = GNE_SFA2_PFG_TestHelper.userHelper.userCache;
            trxs = GNE_SFA2_PFG_DAO.getTransactions(
                new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
                null,
                new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                            //new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Id', '=', GNE_SFA2_PFG_TestHelper.allocTransfersCache.get(trxKey).Id)
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('From_User_gne__c', '=', users.get(fromUserName).Id),
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_gne__c', '=', users.get(toUserName).Id),
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', gShipmentFlag)
                },
                null);
        }
        
        String recordTypeName = (fromUserName=='null') 
                ? GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION
                : GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER;
        String dMethod = (pfgType=='DTP' ? GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP : 
                                           GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC);
        
        System.assertEquals(1, trxs.size(), '[Assert Transaction] Transaction not found in database.');
        
        SFA2_PFG_Transaction_gne__c trx = trxs[0];
        
        if(!fromCache) {
            GNE_SFA2_PFG_TestHelper.allocTransfersCache.put(fromUserName + ':' + toUserName + '_new:' + prodName, trx);
        }
        
        System.assertEquals(recordTypeName, trx.Transaction_Type_gne__c, '[Assert Transaction] Wrong record type.');
        System.assertEquals(dMethod, trx.Distribution_Method_gne__c, '[Assert Transaction] Wrong distribution method.');
        if(pfgType=='HC') {
        System.assertEquals(toUserName.toUpperCase().startsWith('CS'), trx.To_User_Is_CS_Flag_gne__c, '[Assert Transaction] Wrong To User IS CS Flag.');
        }
        System.assertNotEquals(null, trx.NDC_Number__c, '[Assert Transaction] NDC Number is null.');
        System.assertNotEquals(null, trx.UOM_gne__c, '[Assert Transaction] UOM is null.');
        System.assertNotEquals(null, trx.Lot_No_gne__c, '[Assert Transaction] Lot No is null.');
        
        System.assertEquals(status, trx.Status_gne__c, '[Assert Transaction] Wrong status.');
        System.assertEquals(gShipmentFlag, trx.Generate_Shipment_Flag__c, '[Assert Transaction] Wrong Generate Shipment Flag.');
        System.assertEquals(reqQty, trx.Requested_Quantity_gne__c, '[Assert Transaction] Wrong Requested Quantity.');
        System.assertEquals(shipQty, trx.Shipped_Quantity_gne__c, '[Assert Transaction] Wrong Shipped Quantity.');
        System.assertEquals(recQty, trx.Received_Quantity_gne__c, 'Wrong Received Quantity.');
    }
    
    private static void assertPfgToUserDetail(String userName, String prodName, String lotNo, 
            Integer rsvQty, Integer totalAllocQty, Integer totalAvlQty, Integer ytdQty) {
        assertPfgToUserDetail(userName, prodName, lotNo, rsvQty, totalAllocQty, totalAvlQty, ytdQty, false);
    }
    
    private static void assertPfgToUserDetail(String userName, String prodName, String lotNo, 
            Integer rsvQty, Integer totalAllocQty, Integer totalAvlQty, Integer ytdQty, Boolean isMerged) {
        
        Id userId = GNE_SFA2_PFG_TestHelper.getUser(userName).Id;
        Id prodId = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get(prodName).Id;    
        
        List<SFA2_PFG_to_User_Detail_gne__c> uDets = new List<SFA2_PFG_to_User_Detail_gne__c>();
        
        if(isMerged) {
            uDets.addAll(GNE_SFA2_PFG_DAO.getPFGToUserDetailsByUserAndProductIds(
                new Set<Id>{userId},
                new Set<Id>{prodId}, 
                new Set<String>{lotNO},
                isMerged));
        } else {
            SFA2_PFG_to_User_Detail_gne__c uDet = GNE_SFA2_PFG_Util.getPfgToUserDetail(userId, prodId, lotNO);
            if(uDet!=null) {
                uDets.add(uDet);
            }
        }
            
        System.assertEquals(1, uDets.size(), '[Assert PFG 2 User Detail] Pfg2User Detail not found or there are more than 1 record.');
        
        SFA2_PFG_to_User_Detail_gne__c uDet = uDets[0];
        
        Set<String> zeroQuantityFields = new Set<String> {
            'Qty_Adjusted_gne__c',
            'Qty_Disbursed_gne__c',
            'Qty_Last_Physical_Inventory_gne__c',
            'Qty_Returned_gne__c',
            'Qty_Shipped_to_Physician_gne__c',
            'Qty_Transferred_In_gne__c',
            'Qty_Transferred_Out_gne__c'
        };
        
        for (String fieldName : zeroQuantityFields) {
            System.assertEquals(0, uDet.get(fieldName),'[Assert PFG 2 User Detail] ' + fieldName + ' is not null.');
        }
        
        System.assertEquals(rsvQty, uDet.Qty_Reserved_gne__c, '[Assert PFG 2 User Detail] Wrong Reserved Quantity.');
        System.assertEquals(totalAllocQty, uDet.Qty_Total_Allocated_gne__c, '[Assert PFG 2 User Detail] Wrong Total Allocated Quantity.');
        System.assertEquals(totalAvlQty, uDet.Qty_Total_Available_gne__c, '[Assert PFG 2 User Detail] Wrong Total Available Quantity.');
        System.assertEquals(ytdQty, uDet.YTD_Allocated_gne__c, '[Assert PFG 2 User Detail] Wrong YTD_Allocated Quantity.');
        
        System.assertEquals(isMerged, uDet.Merged_gne__c, '[Assert PFG 2 User Detail] Wrong Merged value.');
        System.assertEquals(true, uDet.Active_gne__c, '[Assert PFG 2 User Detail] Wrong Active value.');
    }
    
    private static void assertPfgToTerritoryDetail(String terrKey, String prodName, 
            Integer rsvQty, Integer totalAllocQty, Integer totalAvlQty, Integer ytdQty) {
        
        String terrName = ((Map<String, Territory2>)GNE_SFA2_PFG_TestHelper.cache.get('territories')).get(terrKey).Name;
        Id prodId = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get(prodName).Id;    
        
        List<SFA2_PFG_to_Territory_Detail_gne__c> tDets = new List<SFA2_PFG_to_Territory_Detail_gne__c>();
        
        SFA2_PFG_to_Territory_Detail_gne__c tDet = GNE_SFA2_PFG_Util.getPfgToTerritoryDetail(terrName, prodId, GNE_SFA2_PFG_TestHelper.allocationYear);
        if(tDet!=null) {
            tDets.add(tDet);
        }
            
        System.assertEquals(1, tDets.size(), '[Assert PFG 2 Territory Detail] Wrong number of Pfg2Territory Details.');
        
        tDet = tDets[0];
        
        Set<String> zeroQuantityFields = new Set<String> {
            'Qty_Adjusted_gne__c',
            'Qty_Shipped_to_Physician_gne__c'
        };
        
        for (String fieldName : zeroQuantityFields) {
            System.assertEquals(0, tDet.get(fieldName),'[Assert PFG 2 Territory Detail] ' + fieldName + ' is not null.');
        }
        
        System.assertEquals(rsvQty, tDet.Qty_Reserved_gne__c, '[Assert PFG 2 Territory Detail] Wrong Reserved Quantity.');
        System.assertEquals(totalAllocQty, tDet.Qty_Total_Allocated_gne__c, '[Assert PFG 2 Territory Detail] Wrong Total Allocated Quantity.');
        System.assertEquals(totalAvlQty, tDet.Qty_Total_Available_gne__c, '[Assert PFG 2 Territory Detail] Wrong Total Available Quantity.');
        System.assertEquals(ytdQty, tDet.YTD_Allocated_gne__c, '[Assert PFG 2 Territory Detail] Wrong YTD_Allocated Quantity.');
        
        System.assertEquals(false, tDet.Merged_gne__c, '[Assert PFG 2 Territory Detail] Wrong Merged value.');
        System.assertEquals(true, tDet.Active_gne__c, '[Assert PFG 2 Territory Detail] Wrong Active value.');
    }
    
    private static void cachePfgToUserDetails() {
        cachePfgToUserDetails(new Set<String>()); 
    }
    
    private static void cachePfgToTerritoryDetails() {
        GNE_SFA2_PFG_Util.clearPfgToTerritoryCache();
        Set<String> terrNames = new Set<String>{GNE_SFA2_PFG_Util.getHoTerritoryId()};
        
        for(Territory2 terr: ((Map<String, Territory2>)GNE_SFA2_PFG_TestHelper.cache.get('territories')).values()) {
            terrNames.add(terr.Name);
        }
        
        Map<String,Product_vod__c> prods = (Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts');
        Set<Id> prodIds = (new Map<Id,Product_vod__c>(prods.values())).keySet();
        
        List<String> terrNamesList = new List<String>();
        List<Id> prodIdsList = new List<Id>();
        
        for(String terrName : terrNames) {
            for(Id prodId : prodIds) {
                terrNamesList.add(terrName);
                prodIdsList.add(prodId);
            }
        }
        
        GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(terrNamesList, prodIdsList, new List<Integer>{GNE_SFA2_PFG_TestHelper.allocationYear});
    }
    
    private static void cachePfgToUserDetails(Set<String> refNos) {
        GNE_SFA2_PFG_Util.clearPfgToUserCache();
        Set<Id> userIdsSet = GNE_SFA2_PFG_TestHelper.userHelper.getUserIds();
        List<Id> userIds = new List<Id>();
        List<Id> prodIds = new List<Id>();
        List<String> lotNos = new List<String>();
        Map<Id,SFA2_Lot_Catalog_gne__c> lotCatalogs = (Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs');
        
        for(Id userId : userIdsSet) {
            for(Id prodId : lotCatalogs.keySet()) {
                userIds.add(userId);
                prodIds.add(prodId);
                lotNos.add(lotCatalogs.get(prodId).Name);
                
                for(String refNo : refNos) {
                    userIds.add(userId);
                    prodIds.add(prodId);
                    lotNos.add(refNo);
                }
            }
        }
        
        GNE_SFA2_PFG_Util.cachePfgToUserDetails(userIds, prodIds, lotNos);
    }
    
    private static User initDtpAllocations(Boolean startStopTestMode) {
        User u = prepareEnvWithTerrs('HO1');
        String pfgType = 'DTP';
        
        System.runAs(u) {
            if(startStopTestMode) {
                Test.startTest();
            }
            
            insertTransactions(pfgType, pfgType + '1', new Map<String,Integer> {
                'null:HO1' => 500,
                'HO1:DM1' => 200,
                'DM1:CS1' => 100
//              'DM1:CS2' => 50
            });
            
            if(startStopTestMode) {
                Test.stopTest();
            }
        }
        
        cachePfgToTerritoryDetails();
        
        return u;
    }
    
    public static testMethod void testDtpAllocation() {
        String pfgType = 'DTP';
        String status = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String shippedFlag = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String dtpLotNo = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE;
        String prodName = pfgType + '1';
        
        User u = initDtpAllocations(true);
        
        System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
        assertTransaction(pfgType, 'null','HO1', status, null, 500, 0, 0);
        assertTransaction(pfgType, 'HO1','DM1', status, null, 200, 200, 200);
        assertTransaction(pfgType, 'DM1','CS1', status, null, 100, 100, 100);
        //assertTransaction(pfgType, 'DM1','CS2', status, null, 50, 50, 50);
        
        System.assertEquals(0, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 0 Pfg2User in database');
        System.assertEquals(3, [SELECT count() FROM SFA2_PFG_to_Territory_Detail_gne__c], 'There should be 3 Pfg2Territory in database');
        assertPfgToTerritoryDetail('HO1', prodName, 0, 300, 300, 500);
        assertPfgToTerritoryDetail('DM1', prodName, 0, 100, 100, 200);
        assertPfgToTerritoryDetail('CS1', prodName, 0, 100, 100, 100);
        //assertPfgToTerritoryDetail('CS2', prodName, 0, 50, 50, 50);
    }
    
    public static testMethod void testDtpAllocationReturn() {
        String pfgType = 'DTP';
        String status = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String shippedFlag = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String dtpLotNo = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE;
        
        User u = initDtpAllocations(false);
        
         System.runAs(u) {
            Test.startTest();
            
            insertTransactions(pfgType, pfgType + '1', new Map<String,Integer> {
                'CS1:DM1' => 20,
                'DM1:HO1' => 50
            });
            Test.stopTest();
            
            System.assertEquals(3+2, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 5 transactions in database');
            assertTransaction(pfgType, 'CS1','DM1', status, null, 20, 20, 20);
            assertTransaction(pfgType, 'DM1','HO1', status, null, 50, 50, 50);
            
            cachePfgToTerritoryDetails();
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_to_Territory_Detail_gne__c], 'There should be 3 Pfg2Territory in database');
            assertPfgToTerritoryDetail('HO1', pfgType + '1', 0, 350, 350, 500);
            assertPfgToTerritoryDetail('DM1', pfgType + '1', 0, 70, 70, 150);
            assertPfgToTerritoryDetail('CS1', pfgType + '1', 0, 80, 80, 80);
            //assertPfgToTerritoryDetail('CS2', pfgType + '1', 0, 50, 50, 50);
         }
    }
    
    public static testMethod void testDtpAllocationMix() {
        String pfgType = 'DTP';
        String status = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String shippedFlag = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String dtpLotNo = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE;
        
        User u = initDtpAllocations(false);
        
         System.runAs(u) {
            Test.startTest();
            
            insertTransactions(pfgType, pfgType + '1', new Map<String,Integer> {
                'CS1:DM1' => 20,
                'DM1:HO1' => 20
        //      'DM1:CS2' => 10
            });
            Test.stopTest();
            
            System.assertEquals(5, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 5 transactions in database');
            assertTransaction(pfgType, 'CS1','DM1', status, null, 20, 20, 20);
            assertTransaction(pfgType, 'DM1','HO1', status, null, 20, 20, 20);
            //assertTransaction(pfgType, 'DM1','CS2', status, null, 10, 10, 10);
            
            cachePfgToTerritoryDetails();
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_to_Territory_Detail_gne__c], 'There should be 3 Pfg2Territory in database');
            assertPfgToTerritoryDetail('HO1', pfgType + '1', 0, 320, 320, 500);
            assertPfgToTerritoryDetail('DM1', pfgType + '1', 0, 100, 100, 180);
            assertPfgToTerritoryDetail('CS1', pfgType + '1', 0, 80, 80, 80);
            //assertPfgToTerritoryDetail('CS2', pfgType + '1', 0, 60, 60, 60);
         }
    }
    
    public static testMethod void testDtpAllocationDifferentYears() {
        String pfgType = 'DTP';
        String status = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String shippedFlag = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String dtpLotNo = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE;
        
        User u = initDtpAllocations(false);
        
         System.runAs(u) {
            Test.startTest();
            GNE_SFA2_PFG_TestHelper.allocationYear += 1;
            insertTransactions(pfgType, pfgType + '1', new Map<String,Integer> {
                'null:HO1' => 50,
                'HO1:DM1' => 50,
                'DM1:CS1' => 20
            //  'DM1:CS2' => 30
            });
            Test.stopTest();
            
            System.assertEquals(3+3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 6 transactions in database');
            assertTransaction(pfgType, 'null','HO1', status, null, 50, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', status, null, 50, 50, 50);
            assertTransaction(pfgType, 'DM1','CS1', status, null, 20, 20, 20);
            //assertTransaction(pfgType, 'DM1','CS2', status, null, 30, 30, 30);
            
            cachePfgToTerritoryDetails();
            System.assertEquals(6, [SELECT count() FROM SFA2_PFG_to_Territory_Detail_gne__c], 'There should be 64 Pfg2Territory in database');
            assertPfgToTerritoryDetail('HO1', pfgType + '1', 0, 0, 0, 50);
            assertPfgToTerritoryDetail('DM1', pfgType + '1', 0, 30, 30, 50);
            assertPfgToTerritoryDetail('CS1', pfgType + '1', 0, 20, 20, 20);
            //assertPfgToTerritoryDetail('CS2', pfgType + '1', 0, 30, 30, 30);
            
            GNE_SFA2_PFG_TestHelper.allocationYear -= 1;
            cachePfgToTerritoryDetails();
            assertPfgToTerritoryDetail('HO1', pfgType + '1', 0, 300, 300, 500);
            assertPfgToTerritoryDetail('DM1', pfgType + '1', 0, 100, 100, 200);
            assertPfgToTerritoryDetail('CS1', pfgType + '1', 0, 100, 100, 100);
            //assertPfgToTerritoryDetail('CS2', pfgType + '1', 0, 50, 50, 50);
         }
    }
    
    public static testMethod void testHcFullGenerateShipment() {
        User u = prepareEnvWithTerrs('HO1');
        String pfgType = 'HC';
        String statusApd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED;
        String statusSub = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String statusSvd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SAVED;
        String shippedFlagNI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String shippedFlagI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED;
        String shippedFlagDP = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED;
        
        String dtpLotNo = GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE;
        
        System.runAs(u) {
            Test.startTest();
            insertTransactions(pfgType);
            String refNo = [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c LIMIT 1].Transaction_Ref_Number_gne__c;
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSvd, shippedFlagNI, 200, 0, 0);
            assertTransaction(pfgType, 'DM1','CS1', statusSvd, shippedFlagNI, 100, 0, 0);
           // assertTransaction(pfgType, 'DM1','CS2', statusSvd, shippedFlagNI, 50, 0, 0);
            System.assertEquals(1, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 1 Pfg2User in database (before generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 500, 500, 500);
            
            generateShipment(new Set<String>{'CS1'});
            
            Test.stopTest();
            printMetrics();
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 0, 0);
           // assertTransaction(pfgType, 'DM1','CS2', statusApd, shippedFlagI, 50, 0, 0);
            System.assertEquals(2, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 2 Pfg2User in database (after generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 300, 300, 500);
            assertPfgToUserDetail('DM1', pfgType + '1', refNo, 100, 200, 100, 200);
        }
    }
    
    public static testMethod void testHcPartialGenerateShipment() {
        User u = prepareEnvWithTerrs('HO1');
        String pfgType = 'HC';
        String statusApd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED;
        String statusSub = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String statusSvd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SAVED;
        String shippedFlagNI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String shippedFlagI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED;
        String shippedFlagDP = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED;
        
        System.runAs(u) {
            insertTransactions('HC');
            String refNo = [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c LIMIT 1].Transaction_Ref_Number_gne__c;
            
            Test.startTest();
            generateShipment(new Set<String>{'CS1'});
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 0, 0);
            //(pfgType, 'DM1','CS2', statusSvd, shippedFlagNI, 50, 0, 0);
           // assertTransaction(pfgType, 'HO1','DM1', statusSvd, shippedFlagNI, 100, 0, 0, false);
            System.assertEquals(2, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 2 Pfg2User in database (after generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 300, 300, 500);
            assertPfgToUserDetail('DM1', pfgType + '1', refNo, 100, 200, 100, 200);
            
           // generateShipment(new Set<String>{'CS2'});
            Test.stopTest();
            printMetrics();
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 0, 0);
        //    assertTransaction(pfgType, 'DM1','CS2', statusApd, shippedFlagI, 50, 0, 0);
        //    assertTransaction(pfgType, 'HO1','DM1_new', statusSub, shippedFlagDP, 100, 100, 100);
            System.assertEquals(2, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 2 Pfg2User in database (after generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 300, 300, 500);
            assertPfgToUserDetail('DM1', pfgType + '1', refNo, 100, 200, 100, 200);
        }
    }
        
    public static testMethod void testHcFullReceiveAfterGenerateShipment() {
        User u = prepareEnvWithTerrs('HO1');
        String pfgType = 'HC';
        String statusApd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED;
        String statusSub = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String statusSvd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SAVED;
        String shippedFlagNI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String shippedFlagI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED;
        String shippedFlagDP = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED;
        Product_vod__c currentProduct = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get(pfgType + '1');
        SFA2_Lot_Catalog_gne__c lot = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).get(currentProduct.Id);
        String lotNo = lot.Name;
        
        System.runAs(u) {
            insertTransactions('HC');
            String refNo = [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c LIMIT 1].Transaction_Ref_Number_gne__c;
            generateShipment(new Set<String>{'CS1'});
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 0, 0);
          //  assertTransaction(pfgType, 'DM1','CS2', statusApd, shippedFlagI, 50, 0, 0);
            System.assertEquals(2, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 2 Pfg2User in database (after generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 300, 300, 500);
            assertPfgToUserDetail('DM1', pfgType + '1', refNo, 100, 200, 100, 200);
            
            Test.startTest();
            virtualReceive(lotNo, new Set<String>{'CS1'}, null,null);
            Test.stopTest();
            printMetrics();
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 100, 100);
           // assertTransaction(pfgType, 'DM1','CS2', statusApd, shippedFlagI, 50, 50, 50);
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 3 Pfg2User in database (after generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 300, 300, 500);
            assertPfgToUserDetail('DM1', pfgType + '1', lotNo, 0, 100, 100, 200);
            assertPfgToUserDetail('CS1', pfgType + '1', lotNo, 0, 100, 100, 100);
            //assertPfgToUserDetail('CS2', pfgType + '1', lotNo, 0, 50, 50, 50);
        }
    }
    
    public static testMethod void testHcPartialReceiveAfterGenerateShipment() {
        User u = prepareEnvWithTerrs('HO1');
        String pfgType = 'HC';
        String statusApd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED;
        String statusSub = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String statusSvd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SAVED;
        String shippedFlagNI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String shippedFlagI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED;
        String shippedFlagDP = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED;
        Product_vod__c currentProduct = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get(pfgType + '1');
        SFA2_Lot_Catalog_gne__c lot = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).get(currentProduct.Id);
        String lotNo = lot.Name;
        
        System.runAs(u) {
            insertTransactions('HC');
            String refNo = [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c LIMIT 1].Transaction_Ref_Number_gne__c;
            generateShipment(new Set<String>{'CS1'});
            Test.startTest();
            virtualReceive(lotNo, new Set<String>{'CS1' },
                new Map<String, Integer> {'CS1' => -10},
                new Map<String, Integer> {'CS1' => -15});
            Test.stopTest();
            printMetrics();
            
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 3 transactions in database');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 90, 85);
           // assertTransaction(pfgType, 'DM1','CS2', statusApd, shippedFlagI, 50, 40, 35);
            System.assertEquals(3, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 3 Pfg2User in database (after generate shipment)');
            cachePfgToUserDetails(new Set<String>{refNo});
            //assertPfgToUserDetail(userName, prodName, lotNo, rsvQty, totalAllocQty, totalAvlQty, ytdQty, isMerged)
            assertPfgToUserDetail('HO1', pfgType + '1', refNo, 0, 300, 300, 500);
            assertPfgToUserDetail('DM1', pfgType + '1', lotNo, 15, 115, 100, 200);
            assertPfgToUserDetail('CS1', pfgType + '1', lotNo, 0, 85, 85, 85);
          //  assertPfgToUserDetail('CS2', pfgType + '1', lotNo, 0, 35, 35, 35);
        }
    }
    
    public static testMethod void testHcDoubleReceiveAfterGenerateShipment() {
        User u = prepareEnvWithTerrs('HO1');
        String pfgType = 'HC';
        String statusApd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED;
        String statusSub = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED;
        String statusSvd = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SAVED;
        String shippedFlagNI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED;
        String shippedFlagI = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED;
        String shippedFlagDP = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_DM_PROCESSED;
        Product_vod__c currentProduct = ((Map<String,Product_vod__c>)GNE_SFA2_PFG_TestHelper.cache.get('pfgProducts')).get(pfgType + '1');
        SFA2_Lot_Catalog_gne__c lot = ((Map<Id,SFA2_Lot_Catalog_gne__c>)GNE_SFA2_PFG_TestHelper.cache.get('lotCatalogs')).get(currentProduct.Id);
        String lotNo = lot.Name;
        
        System.runAs(u) {
            insertTransactions(pfgType);
            String refNo1 = [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c LIMIT 1].Transaction_Ref_Number_gne__c;
            generateShipment(new Set<String>{'CS1'});
            virtualReceive(lotNo, new Set<String>{'CS1'},null,null);
            GNE_SFA2_PFG_Util.clearPfgToUserCache();
            insertTransactions(pfgType);
            Id trxId = GNE_SFA2_PFG_TestHelper.allocTransfersCache.get('null:HO1:HC1').Id;
            String refNo2 = [SELECT Transaction_Ref_Number_gne__c FROM SFA2_PFG_Transaction_gne__c WHERE Id = :trxId LIMIT 1].Transaction_Ref_Number_gne__c;
            generateShipment(new Set<String>{'CS1'});
            
            Test.startTest();
            virtualReceive(lotNo, new Set<String>{'CS1'},null,null);
            Test.stopTest();
            printMetrics();
            
            System.assertEquals(6, [SELECT count() FROM SFA2_PFG_Transaction_gne__c], 'There should be 6 transactions in database (after second virtual receive)');
            assertTransaction(pfgType, 'null','HO1', statusSub, shippedFlagNI, 500, 0, 0);
            assertTransaction(pfgType, 'HO1','DM1', statusSub, shippedFlagDP, 200, 200, 200);
            assertTransaction(pfgType, 'DM1','CS1', statusApd, shippedFlagI, 100, 100, 100);
           // assertTransaction(pfgType, 'DM1','CS2', statusApd, shippedFlagI, 50, 50, 50);
            System.assertEquals(4, [SELECT count() FROM SFA2_PFG_to_User_Detail_gne__c], 'There should be 4 Pfg2User in database (after second virtual receive)');
            cachePfgToUserDetails(new Set<String>{refNo1, refNo2});
            assertPfgToUserDetail('HO1', pfgType + '1', refNo1, 0, 600, 600, 1000);
            assertPfgToUserDetail('DM1', pfgType + '1', refNo2, 100, 200, 100, 200, true); // merged
            assertPfgToUserDetail('DM1', pfgType + '1', lotNo, 0, 200, 200, 400);
            assertPfgToUserDetail('CS1', pfgType + '1', lotNo, 0, 200, 200, 200);
           // assertPfgToUserDetail('CS2', pfgType + '1', lotNo, 0, 100, 100, 100);
        }
    }
    
}