public with sharing class GNE_SFA2_PFG_Util {

    public static final String TRANSACTION_DISCTRIBUTION_METHOD_DTP = 'DTP';
    public static final String TRANSACTION_DISCTRIBUTION_METHOD_HC = 'Hand Carry';
    public static final String TRANSACTION_GENERATE_SHIPMENT_REQUESTED = 'Requested';
    public static final String TRANSACTION_REASON_OTHER = 'Other';
    public static final String TRANSACTION_STATUS_COMPLETED = 'Completed';
    public static final String TRANSACTION_STATUS_APPROVED = 'Approved';
    public static final String TRANSACTION_STATUS_SUBMITTED = 'Submitted';
    public static final String TRANSACTION_STATUS_SAVED = 'Saved';
    public static final String TRANSACTION_STATUS_CANCELLED = 'Cancelled';
    public static final String TRANSACTION_RECORD_TYPE_ALLOCATION = 'Allocation';
    public static final String TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER = 'Allocation Transfer';
    public static final String TRANSACTION_RECORD_TYPE_ADJUSTMENT = 'Adjustment';
    public static final String TRANSACTION_RECORD_TYPE_RETURN = 'Return';
    public static final String TRANSACTION_RECORD_TYPE_ORDER = 'Order';
    public static final String TRANSACTION_RECORD_TYPE_RECEIPT = 'Receipt';
    public static final String TRANSACTION_RECORD_TYPE_TRANSFER ='Transfer';
    public static final String TRANSACTION_RECORD_TYPE_RFF = 'Request for Fulfillment';
    public static final String TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER = 'DTP Paper Order';
    public static final String TRANSACTION_RECORD_TYPE_DISBURSEMENT = 'Disbursement';
    public static final String TRANSACTION_SHIPMENT_NOT_INITIATED = 'Not Initiated';
    public static final String TRANSACTION_SHIPMENT_INITIATED = 'Initiated';
    public static final String TRANSACTION_SHIPMENT_DM_PROCESSED = 'DM Processed';
    public static final String TRANSACTION_DELIVERY_CANCELLED = 'Cancelled';
    public static final String TRANSACTION_DELIVERY_REJECTED = 'Rejected';
    public static final Set<String> TRANSACTION_DELIVERY_ABORT_STATUSES = new Set<String>{
    		TRANSACTION_DELIVERY_CANCELLED.toUpperCase(),
    		TRANSACTION_DELIVERY_REJECTED.toUpperCase()
    };
    public static final String TRANSACTION_ORDER_STATUS_CANCELLED_NOTE = 'Auto cancelled due to user exceeding allocated inventory limit';
    public static final String TRANSACTION_SIGNATURE_COMPLETE = 'Complete';
    public static final String TRANSACTION_SIGNATURE_INCOMPLETE = 'Incomplete';
    public static final String TRANSACTION_SIGNATURE_PENDING = 'Pending';
    public static final String USER_ROLE_MANAGER = 'PFG-Management';
    public static final String USER_ROLE_RM = 'Manager';
    public static final String USER_ROLE_DM = 'DM';
    public static final String USER_ROLE_CS = 'CS';
    public static final String LOT_NO_NA_VALUE = 'DTP-NA';
    public static final String OVERDUE_TYPE_15_30 = 'Reminder 15-30';
    public static final String OVERDUE_TYPE_31_45 = 'Reminder 31-45';
    public static final String OVERDUE_TYPE_FREEZ = 'Freez';
    public static final String OVERDUE_REMINDER_15_30 = 'Overdue - Reminder 15-30 days late';
    public static final String OVERDUE_REMINDER_31_45 = 'Overdue - Reminder 31-45 days late';
    public static final String OVERDUE_REMINDER_MORE_45 = 'Overdue - Freeze 60 days or greater late';
    public static final String STORAGE_LOCATION_APPROVED_ACTION = 'Approve';
    public static final String STORAGE_LOCATION_REJECTED_ACTION = 'Reject';
    public static final String STORAGE_LOCATION_APPROVED_COMMENT = 'Approving request.';
    public static final String STORAGE_LOCATION_REJECTED_COMMENT = 'Rejecting request.';
    public static final String STORAGE_LOCATION_30DAYS_REJECTED_COMMENT = 'Storage Location rejected - submission is over 30 days old, and has now expired. Please resubmit the request.';
    public static final String APPROVAL_STATUS_PENDING = 'Pending';
    public static final String APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String STORAGE_LOCATION_STATUS_SUBMITTED = 'Submitted';
    public static final String STORAGE_LOCATION_STATUS_APPROVED = 'Approved';
    public static final String STORAGE_LOCATION_STATUS_REJECTED = 'Rejected';
    public static final String PROCESS_STATUS_APPROVED = 'Approved';
    public static final String PROCESS_STATUS_REJECTED = 'Rejected';
    public static final String PROCESS_STATUS_PENDING = 'Pending';
    public static final String INVENTORY_STATUS_SUBMITTED = 'Submitted';
    public static final String USER_LOA_HO_OVERRIDE_FLAG_NA = 'NA';
    public static final String USER_LOA_HO_OVERRIDE_FLAG_TRUE = 'True';
    public static final String USER_LOA_HO_OVERRIDE_FLAG_FALSE = 'False';
    public static final String PRODUCT_TYPE = 'PFG';
    public static final String SFA_APP_TYPE = 'SFA-US';
    public static final String FREEZE_FOR_PENDING_AOC_YES = 'Yes';
    public static final String ADDRESS_SLN_VALID = 'Valid';

    private static Map<String, SFA2_PFG_to_User_Detail_gne__c> pfgToUserDetailsCache;
    private static Map<String, SFA2_PFG_to_User_Detail_gne__c> pfgToUserDetailsCacheNoLot;
    @TestVisible private static Map<String, SFA2_PFG_to_Account_Detail_gne__c> pfgToAccountDetailsCache;
    @TestVisible private static Map<String, SFA2_PFG_to_Territory_Detail_gne__c> pfgToTerritoryDetailsCache;
    private static Map<String, List<SFA2_PFG_Transaction_gne__c>> pfgOverdueSignatureTransactions;
    private static List<IC_Calc_Sales_Roster_gne__c> salesRostersCache;
    private static Map<String, Set<Id>> brandToPFGProductCache;
    private static Map<Id, Product_vod__c> pfgProductsCache;
    private static Map<String, Id> pfgProductNameToIdCache;
    private static Map<String, Set<Id>> pfgDistMethodToProductIdsCache;
    private static Map<Id, Set<String>> pfgProductToDistMethodsCache;
    private static Map<String, Map<String,List<SFA2_User_Sales_Roster_gne__c>>> usersByBrandAndRoleCache;
    private static Map<String, List<SFA2_User_Sales_Roster_gne__c>> usersByRoleCache;
    private static Map<Id, SFA2_User_Sales_Roster_gne__c> userSalesRosterCache;
    private static Map<String, Id> userUnixIdToIdCache;
    private static Map<String, Map<Id, SFA2_PFG_Transaction_gne__c>> pfgAllocationTransactionsCache;
    public static Map<Id, List<Id>> usersHierarchyCache;
    public static Map<Id, Id> userManagersCache;
    private static Map<Id, SFA2_PFG_Storage_Location_gne__c> storageLocationCache;
    private static Map<Id, List<SFA2_PFG_Storage_Location_gne__c>> storageLocationByUserIdCache;
    private static Map<String, PFG_Staging_Account_Limit_Exception_gne__c> pfgAccLimitExceptionsCache;
    private static Map<String, SFA2_PFG_Product_Limit_gne__c> pfgProductsLimitsCache;
    private static Map<String, SFA2_Lot_Catalog_gne__c> lotNoToLotCatsMapCache;
    private static Map<Id, Set<Id>> userIdToTerritoryIdsCache;
    private static Map<Id, Set<Id>> terrIdToUserIdsCache;
    private static Map<Id, Territory2> terrIdToTerritoryCache;
    private static Map<String, Id> terrNameToIdCache;
    private static Map<String, Id> terrNumberToIdCache;
    private static Map<Id, Set<Id>> territoryHierarchyCache;
    private static Map<Id, Integer> territoryLevelCache;
    private static Map<Id, String> transactionRecTypeIdToNameCache;
    private static Map<String, Id> transactionNameToRecTypeIdCache;
    public static Map<Id,Call_PFG_Detail_gne__c> callDetailsCache;
    public static Map<String, SFA2_PFG_Inventory_Count_gne__c> inventoryCountCache;
    private static Map<Id, Map<Id,SFA2_PFG_to_User_Detail_gne__c>> pfgToUserDetailsForUsersCache;
    private static Map<String, Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>> pfgToTerrDetailsForUsersCache;
    @TestVisible private static Map<Id, Vendor_gne__c> vendorsByIdCache;
    private static Map<String, Vendor_gne__c> vendorsByNameCache;
    private static Map<String, Set<String>> brandToVendorsCache;
    private static Map<String, Set<String>> vendorToBrandsCache;
    @TestVisible private static Map<Id,SFA2_PFG_Transaction_gne__c> callDetailTransactionsCache;
    // To get salesforce codes and subCodes by brand name (from Brand_2_Salesforce_gne__c)
    private static Map<String, Map<String, Set<String>>> brandToSalesforceCodesCache;
    // To get root territories by salesforce code (from Territory)
    // To get salesforce codes by userId and territories to which he is assigned (from Territoy)
    private static Map<Id, Map<String, Set<String>>> salesforceCodesByUserTerritoryCache;
    private static Map<Id,Set<String>> userToBrandNamesByTerritory;
    private static Set<String> profilesWithPermissionToPfgCache;

    public static String getHoTerritoryId() {
        return GNE_SFA2_PFG_Config.HO_TERRITORY_NAME;
    }

    public static void cacheHoTerritoryId() {
        // deprecated - remove usage of this method
    }

//User Territory methods

	public static Territory2 getHoTerritory() {
    	return getTerritory(null);
    }

	// DEPRECATED, new method: getFirstTerritoryForUserBySalesforceCodes
    public static Territory2 getTerritoryForUser(Id userId) {
        cacheSalesRosters();
        Territory2 result = null;
        // Get first existing territory
        if(userIdToTerritoryIdsCache.containsKey(userId)) {
            for(Id terrId : userIdToTerritoryIdsCache.get(userId)) {
                result = terrIdToTerritoryCache.get(terrId);
                break;
            }
        }

        return result;
    }

    public static Set<Territory2> getTerritoriesForUser(Id userId) {
        cacheSalesRosters();
        Set<Territory2> result = new Set<Territory2>();

        if(userIdToTerritoryIdsCache.containsKey(userId)) {
            for(Id terrId : userIdToTerritoryIdsCache.get(userId)) {
                result.add(terrIdToTerritoryCache.get(terrId));
            }
        }

        return result;
    }

    public static Territory2 getFirstTerritoryForUserBySalesforceCodes(Id userId, Map<String, Set<String>> salesforceCodes) {
        cacheSalesRosters();
        Territory2 result = null;
        // Get first existing territory
        if(userIdToTerritoryIdsCache.containsKey(userId)) {
            for(Id terrId : userIdToTerritoryIdsCache.get(userId)) {
            	Territory2 territory = terrIdToTerritoryCache.get(terrId);
            	if (checkTerritoryBySalesforceCodes(territory, salesforceCodes)){
            		result = territory;
                	break;
            	}
            }
        }

        return result;
    }

    // DEPRECATED, new method: getChildTerritoriesForUserBySalesforceCodes
    public static Set<Territory2> getChildTerritoriesForUser(Id userId) {
        cacheSalesRosters();
        Set<Territory2> result = new Set<Territory2>();

        if(userIdToTerritoryIdsCache.containsKey(userId)) {
            for(Id terrId : userIdToTerritoryIdsCache.get(userId)) {
                result.addAll(getChildTerritories(terrId));
            }
        }

        return result;
    }

     public static Set<Territory2> getChildTerritoriesForUserBySalesforceCodes(Id userId, Map<String, Set<String>> salesforceCodes) {
        cacheSalesRosters();
        Set<Territory2> result = new Set<Territory2>();
        if(userIdToTerritoryIdsCache.containsKey(userId)) {
            for(Id terrId : userIdToTerritoryIdsCache.get(userId)) {
            	Territory2 childTerritory = terrIdToTerritoryCache.get(terrId);
            	if (checkTerritoryBySalesforceCodes(childTerritory, salesforceCodes)){
                	result.addAll(getChildTerritoriesBySalesforceCodes(terrId, salesforceCodes));
            	}
            }
        }

        return result;
    }

    public static Set<String> getBrandNamesForTerritory(Id terrId){
    	cacheSalesRosters();
    	Set<String> result = new Set<String>();
    	if (territoryHierarchyCache.containsKey(terrId)){
    		Territory2 terr = terrIdToTerritoryCache.get(terrId);
    		String salesforceCode = terr.Salesforce_Code_gne__c;
    		String salesforceSubCode = terr.Salesforce_SubTeam_Code_gne__c;
    		result = GNE_SFA2_PFG_Util.getBrandNameBySalesforceCodes(salesforceCode, salesforceSubCode);
    	}
    	return result;
    }

    public static Set<Territory2> getChildTerritories(Id terrId) {
        cacheSalesRosters();
        Set<Territory2> result = new Set<Territory2>();

        if(territoryHierarchyCache.containsKey(terrId)) {
            for(Id childTerrId : territoryHierarchyCache.get(terrId)) {
                result.add(terrIdToTerritoryCache.get(childTerrId));
            }
        }

        return result;
    }

    public static Set<Territory2> getChildTerritoriesBySalesforceCodes(Map<String, Set<String>> salesforceCodes){
    	cacheSalesRosters();
    	Set<Territory2> result = new Set<Territory2>();
    	if (salesforceCodes == null || salesforceCodes.isEmpty()){
    		return result;
    	}
    	for (String salesforceCodeToFind : salesforceCodes.keyset()) {
    		for (String salesforceSubCodeToFind : salesforceCodes.get(salesforceCodeToFind)) {
    			result.addAll(getChildTerritoriesBySalesforceCodes(null,salesforceCodeToFind, salesforceSubCodeToFind));
    		}
    	}
    	return result;
    }

    public static Set<Territory2> getChildTerritoriesBySalesforceCodes(Id terrId, String salesforceCode, String salesforceSubCode) {
        cacheSalesRosters();
        Set<Territory2> result = new Set<Territory2>();

        if(territoryHierarchyCache.containsKey(terrId)) {
            for(Id cTerrId : territoryHierarchyCache.get(terrId)) {
            	Territory2 cTerr = terrIdToTerritoryCache.get(cTerrId);
            	 if (cTerr.Salesforce_Code_gne__c == salesforceCode && (String.isBlank(salesforceSubCode) || cTerr.Salesforce_SubTeam_Code_gne__c == salesforceSubCode)){
                	result.add(cTerr);
            	 }
            }
        }
        return result;
    }

    public static Set<Territory2> getChildTerritoriesBySalesforceCodes(Id terrId, Map<String, Set<String>> salesforceCodes) {
        cacheSalesRosters();
        Set<Territory2> result = new Set<Territory2>();
        if(territoryHierarchyCache.containsKey(terrId) && salesforceCodes != null && !salesforceCodes.isEMpty()) {
            for(Id childTerrId : territoryHierarchyCache.get(terrId)) {
            	Territory2 childTerritory = terrIdToTerritoryCache.get(childTerrId);
            	if (checkTerritoryBySalesforceCodes(childTerritory, salesforceCodes)){
            		result.add(childTerritory);
            	}
            }
        }

        return result;
    }

    public static Set<Territory2> getAllChildTerritoriesBySalesforceCodes(Id terrId, Map<String, Set<String>> salesforceCodes) {
    	Set<Territory2> allChildTerrs = new Set<Territory2>();
    	Set<Territory2> childTerrs = terrId==null ? getChildTerritoriesBySalesforceCodes(salesforceCodes) : getChildTerritoriesBySalesforceCodes(terrId, salesforceCodes);
    	allChildTerrs.addAll(childTerrs);

    	for(Territory2 child : childTerrs) {
    		allChildTerrs.addAll(getAllChildTerritoriesBySalesforceCodes(child.Id,salesforceCodes));
    	}

    	return allChildTerrs;
    }

    public static Set<Territory2> getAllChildTerritories(Id terrId) {
        Set<Territory2> result = getChildTerritories(terrId);

        for(Territory2 terr : result) {
            result.addAll(getAllChildTerritories(terr.Id));
        }

        return result;
    }

    public static Set<Territory2> getAllCsTerritories() {
        cacheSalesRosters();

        Set<Territory2> result = new Set<Territory2>();

        for(Territory2 rmTerr : getChildTerritories(null)) {
            for(Territory2 dmTerr : getChildTerritories(rmTerr.Id)) {
            	result.addAll(getChildTerritories(dmTerr.Id));
            }
        }

        return result;
    }

    public static Set<Id> getRootTerritoryIds() {
        cacheSalesRosters();
        return new Set<Id>(territoryHierarchyCache.get(null));
    }

    public static Territory2 getParentTerritory(Id terrId) {
        cacheSalesRosters();
        return terrIdToTerritoryCache.get(terrIdToTerritoryCache.get(terrId).ParentTerritory2Id);
    }

    public static Territory2 getTerritory(Id terrId) {
        cacheSalesRosters();
        return terrIdToTerritoryCache.get(terrId);
    }

    public static Territory2 getTerritoryByName(String terrName) {
    	cacheSalesRosters();
    	String terrNameUp = terrName.toUpperCase();
        return terrNameToIdCache.containsKey(terrNameUp) ? terrIdToTerritoryCache.get(terrNameToIdCache.get(terrNameUp)) : null;
    }

    public static Territory2 getTerritoryByNumber(String terrNumber) {
    	cacheSalesRosters();
    	String terrNumberUp = terrNumber.toUpperCase();
        return terrNumberToIdCache.containsKey(terrNumberUp) ? terrIdToTerritoryCache.get(terrNumberToIdCache.get(terrNumberUp)) : null;
    }

    public static Integer getTerritoryLevel(Id terrId) {
    	cacheSalesRosters();
    	return territoryLevelCache.get(terrId);
    }

    public static Set<String> getTerritoryNamesForUser(Id userId) {
        cacheSalesRosters();
        Set<String> result = new Set<String>();
        if(checkIsUserManager(userId)) {
        	Territory2 hoTerr = getHoTerritory();
            result.add(hoTerr.Name);

            for(Territory2 terr : getAllChildTerritories(null)) {
                result.add(terr.Name);
            }
        } else {
            for(Territory2 terr : getTerritoriesForUser(userId)) {
                result.add(terr.Name);
                for(Territory2 childTerr : getAllChildTerritories(terr.Id)) {
                    result.add(childTerr.Name);
                }
            }
        }

        return result;
    }

    public static Set<Id> getUsersForTeritory(Id terrId) {
        cacheSalesRosters();
        return (terrIdToUserIdsCache.containsKey(terrId) ? terrIdToUserIdsCache.get(terrId) : new Set<Id>());
    }

	//User detail methods
    public static void clearPfgToUserCache() {
        pfgToUserDetailsCache = null;
        pfgToUserDetailsCacheNoLot = null;
    }

    public static void cachePfgToUserDetails(List<SFA2_PFG_Transaction_gne__c> transactions) {
        List<Id> userIds = new List<Id>();
        List<Id> productIds = new List<Id>();
        List<String> lotNos = new List<String>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions){
        	if(String.isNotBlank(trans.Product_gne__c) && isProductHandCarry(trans.Product_gne__c)) {
        		if(String.isNotBlank(trans.Lot_No_gne__c)) {
	        		if(String.isNotBlank(trans.From_User_gne__c)) {
	        			userIds.add(trans.From_User_gne__c);
	                	productIds.add(trans.Product_gne__c);
	                	lotNos.add(trans.Lot_No_gne__c);
	        		}

	        		if(String.isNotBlank(trans.To_User_gne__c)) {
	        			userIds.add(trans.To_User_gne__c);
	                	productIds.add(trans.Product_gne__c);
	                	lotNos.add(trans.Lot_No_gne__c);
	        		}
        		}

        		if(String.isNotBlank(trans.Transaction_Ref_Number_gne__c)) {
	        		if(String.isNotBlank(trans.From_User_gne__c)) {
	        			userIds.add(trans.From_User_gne__c);
	                	productIds.add(trans.Product_gne__c);
	                	lotNos.add(trans.Transaction_Ref_Number_gne__c);
	        		}

	        		if(String.isNotBlank(trans.To_User_gne__c)) {
	        			userIds.add(trans.To_User_gne__c);
	                	productIds.add(trans.Product_gne__c);
	                	lotNos.add(trans.Transaction_Ref_Number_gne__c);
	        		}
        		}
        	}
        }

        cachePfgToUserDetails(userIds, productIds, lotNos);
    }

    public static void cachePfgToUserDetails(List<Call_PFG_Detail_gne__c> cDetails, Id userId) {
        List<Id> userIds = new List<String>();
        List<Id> productIds = new List<Id>();
        List<String> lotNos = new List<String>();

        for(Call_PFG_Detail_gne__c cDetail : cDetails) {
            if(String.isNotBlank(cDetail.Product_gne__c) && String.isNotBlank(cDetail.Lot_No_gne__c) && isProductHandCarry(cDetail.Product_gne__c)) {
            	Id cDetailUserId = userId!=null ? userId : cDetail.Owner_calc_gne__c;

            	if(cDetailUserId!=null) {
            		userIds.add(cDetailUserId);
	               	productIds.add(cDetail.Product_gne__c);
	               	lotNos.add(cDetail.Lot_No_gne__c);
            	}
            }
        }

        cachePfgToUserDetails(userIds, productIds, lotNos);
    }

    public static void cachePfgToUserDetailsNoLot(List<SFA2_PFG_Transaction_gne__c> transactions) {

        List<Id> userIds = new List<Id>();
        List<Id> productIds = new List<Id>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions){
        	if(String.isNotBlank(trans.Product_gne__c) && isProductHandCarry(trans.Product_gne__c)) {
        		if(String.isNotBlank(trans.From_User_gne__c)) {
	        		userIds.add(trans.From_User_gne__c);
	               	productIds.add(trans.Product_gne__c);
	            }

	        	if(String.isNotBlank(trans.To_User_gne__c)) {
	        		userIds.add(trans.To_User_gne__c);
	               	productIds.add(trans.Product_gne__c);
	            }

	            if(trans.OwnerId != null) {
	        		userIds.add(trans.OwnerId);
	               	productIds.add(trans.Product_gne__c);
	            }
        	}
        }

        cachePfgToUserDetailsNoLot(userIds, productIds);
    }

    public static Map<String,SFA2_Lot_Catalog_gne__c> getLotCatalogList(List<SFA2_PFG_Transaction_gne__c> transactions) {
        if(lotNoToLotCatsMapCache==null) {
            lotNoToLotCatsMapCache = new Map<String,SFA2_Lot_Catalog_gne__c>();
        }
        Set<String> lotNumbers = new Set<String>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions) {
            if(trans.Lot_No_gne__c != null && !lotNoToLotCatsMapCache.containsKey(trans.Lot_No_gne__c)) {
                lotNumbers.add(trans.Lot_No_gne__c);
            }
        }

        return getLotCatalogList(lotNumbers);
    }

    public static Map<String,SFA2_Lot_Catalog_gne__c> getLotCatalogList(List<SFA2_PFG_to_User_Detail_gne__c> uDetails) {
        if(lotNoToLotCatsMapCache==null) {
            lotNoToLotCatsMapCache = new Map<String,SFA2_Lot_Catalog_gne__c>();
        }
        Set<String> lotNumbers = new Set<String>();

        for(SFA2_PFG_to_User_Detail_gne__c uDetail : uDetails) {
            if(uDetail.Lot_No_gne__c != null && !lotNoToLotCatsMapCache.containsKey(uDetail.Lot_NO_gne__c)) {
                lotNumbers.add(uDetail.Lot_NO_gne__c);
            }
        }

        return getLotCatalogList(lotNumbers);
    }

    public static Map<String,SFA2_Lot_Catalog_gne__c> getLotCatalogList(List<SFA2_PFG_Inventory_Count_gne__c> invCounts) {
        if(lotNoToLotCatsMapCache==null) {
            lotNoToLotCatsMapCache = new Map<String,SFA2_Lot_Catalog_gne__c>();
        }
        Set<String> lotNumbers = new Set<String>();

        for(SFA2_PFG_Inventory_Count_gne__c ic : invCounts) {
            if(ic.Lot_gne__c != null && !lotNoToLotCatsMapCache.containsKey(ic.Lot_gne__c)) {
                lotNumbers.add(ic.Lot_gne__c);
            }
        }

        return getLotCatalogList(lotNumbers);
    }

    public static Map<String,SFA2_Lot_Catalog_gne__c> getLotCatalogList(List<Call_PFG_Detail_gne__c> cDetails) {
        if(lotNoToLotCatsMapCache==null) {
            lotNoToLotCatsMapCache = new Map<String,SFA2_Lot_Catalog_gne__c>();
        }
        Set<String> lotNumbers = new Set<String>();

        for(Call_PFG_Detail_gne__c cDetail : cDetails) {
            if(cDetail.Lot_No_gne__c != null && !lotNoToLotCatsMapCache.containsKey(cDetail.Lot_NO_gne__c)) {
                lotNumbers.add(cDetail.Lot_NO_gne__c);
            }
        }

        return getLotCatalogList(lotNumbers);
    }

    public static Map<String,SFA2_Lot_Catalog_gne__c> getLotCatalogList(Set<String> lotNumbers) {
        if(lotNoToLotCatsMapCache==null) {
            lotNoToLotCatsMapCache = new Map<String,SFA2_Lot_Catalog_gne__c>();
        }
        // All Lot No are already cached - no need to query on database
        if(lotNoToLotCatsMapCache.keySet().containsAll(lotNumbers)) {
            return lotNoToLotCatsMapCache;
        }

        if(!lotNumbers.isEmpty()) {
            List<SFA2_Lot_Catalog_gne__c>  lotCatalogsList = GNE_SFA2_PFG_DAO.getLotCatalogsForLotNumber(lotNumbers);
            for(SFA2_Lot_Catalog_gne__c lotCatObj : lotCatalogsList){
                lotNoToLotCatsMapCache.put(lotCatObj.Name, lotCatObj);
            }
        }

        // we need to remember lot numbers which are not in lot catalog
        for(String lotNo : lotNumbers) {
            if(!lotNoToLotCatsMapCache.containsKey(lotNo)) {
                lotNoToLotCatsMapCache.put(lotNo, null);
            }
        }

        return lotNoToLotCatsMapCache;
    }

    public static SFA2_Lot_Catalog_gne__c getLotCatalog(String lotNumber) {
    	return lotNoToLotCatsMapCache!=null ? lotNoToLotCatsMapCache.get(lotNumber) : null;
    }

    public static void cachePfgToUserDetails(List<Id> userIds, List<Id> productIds, List<String> lotNOs) {
        if(pfgToUserDetailsCache == null) {
            pfgToUserDetailsCache = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();
        }

        Set<String> existingKeys = pfgToUserDetailsCache.keySet();
        Set<String> newKeys = new Set<String>();

        Integer idx = 0;
        Boolean isSingleProduct = productIds.size()==1;
        Boolean isSingleLotNo = lotNOs.size()==1;
        for(Id userId : userIds) {
            newKeys.add(userId + '_' + (isSingleProduct ? productIds[0] : productIds[idx]) + '_' + (isSingleLotNo ? lotNOs[0] : lotNOs[idx]));
            idx++;
        }

        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,SFA2_PFG_to_User_Detail_gne__c> newUserDetails = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();

            for(SFA2_PFG_to_User_Detail_gne__c uDetail : GNE_SFA2_PFG_DAO.getPFGToUserDetailsByUserAndProductIds(
            		new Set<Id>(userIds), new Set<Id>(productIds), new Set<String>(lotNOs))) {
                String extId = getRecordKey(uDetail);
                newUserDetails.put(extId,uDetail);
            }

            for(String key : newKeys) {
                pfgToUserDetailsCache.put(key,newUserDetails.get(key));
            }
        }
    }

    public static void addPfgToUserDetailToCache(SFA2_PFG_to_User_Detail_gne__c uDetail) {
        String extId = getRecordKey(uDetail);
        pfgToUserDetailsCache.put(extId,uDetail);
    }

    public static void addPfgToUserDetailNoLotToCache(SFA2_PFG_to_User_Detail_gne__c uDetail) {
        String extId = getRecordKey(uDetail, false);
        pfgToUserDetailsCacheNoLot.put(extId,uDetail);
    }

    public static SFA2_PFG_to_User_Detail_gne__c getPfgToUserDetail(Id userId, Id productId, String lotNr) {
        SFA2_PFG_to_User_Detail_gne__c uDetail = null;

        if(pfgToUserDetailsCache != null) {
            String extId = userId + '_' + productId + '_' +  lotNr;
            uDetail = pfgToUserDetailsCache.get(extId);
        }

        return uDetail;
    }

    public static SFA2_PFG_to_User_Detail_gne__c getPfgToUserDetailNoLotNo(Id userId, Id productId) {
        SFA2_PFG_to_User_Detail_gne__c uDetail = null;
        if(pfgToUserDetailsCacheNoLot != null){
            String extId = userId + '_' + productId;
            uDetail = pfgToUserDetailsCacheNoLot.get(extId);
        }
        return uDetail;
    }

    public static void cachePfgToUserDetailsNoLot(List<Id> userIds, List<Id> productIds) {
        if(pfgToUserDetailsCacheNoLot == null) {
            pfgToUserDetailsCacheNoLot = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();
        }

        Set<String> existingKeys = pfgToUserDetailsCacheNoLot.keySet();
        Set<String> newKeys = new Set<String>();

        Integer idx = 0;
        Boolean isSingleProduct = productIds.size()==1;
        for(Id userId : userIds) {
            newKeys.add(userId + '_' + (isSingleProduct ? productIds[0] : productIds[idx]));
            idx++;
        }

        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,SFA2_PFG_to_User_Detail_gne__c> newUserDetails = new Map<String,SFA2_PFG_to_User_Detail_gne__c>();

            for(SFA2_PFG_to_User_Detail_gne__c uDetail : GNE_SFA2_PFG_DAO.getPFGToUserDetailsByUserAndProductIdsNoLot(
            		new Set<Id>(userIds), new Set<Id>(productIds))) {
                String extId = getRecordKey(uDetail, false);
                newUserDetails.put(extId,uDetail);
            }

            for(String key : newKeys) {
                pfgToUserDetailsCacheNoLot.put(key,newUserDetails.get(key));
            }
        }
    }

	//Account detail methods
    public static void cachePfgToAccountDetails(List<SFA2_PFG_Transaction_gne__c> transactions) {
        List<Id> accountIds = new List<String>();
        List<Id> productIds = new List<Id>();
        List<String> limitYears = new List<String>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            if(String.isNotBlank(trans.Account_gne__c) && String.isNotBlank(trans.Product_gne__c)){
                accountIds.add(trans.Account_gne__c);
                productIds.add(trans.Product_gne__c);
                limitYears.add(String.valueOf(trans.Transaction_Date_gne__c.year()));
            }
        }

        cachePfgToAccountDetails(accountIds, productIds, limitYears);
    }

    public static void cachePfgToAccountDetails(List<Call_PFG_Detail_gne__c> cDetails, String limitYear) {
        List<Id> accountIds = new List<String>();
        List<Id> productIds = new List<Id>();

        for(Call_PFG_Detail_gne__c cDetail : cDetails){
            if(String.isNotBlank(cDetail.Account_gne__c) && String.isNotBlank(cDetail.Product_gne__c)){
                accountIds.add(cDetail.Account_gne__c);
                productIds.add(cDetail.Product_gne__c);
            }
        }

        cachePfgToAccountDetails(accountIds, productIds, new List<String>{limitYear});
    }

    public static void cachePfgToAccountDetails(List<Id> accountsIds, List<Id> productIds, String currentYear) {
    	cachePfgToAccountDetails(accountsIds, productIds, new List<String>{currentYear});
    }

    public static void cachePfgToAccountDetails(List<Id> accountsIds, List<Id> productIds, List<String> years) {

        if(pfgToAccountDetailsCache == null) {
            pfgToAccountDetailsCache = new Map<String,SFA2_PFG_to_Account_Detail_gne__c>();
        }

        Set<String> existingKeys = pfgToAccountDetailsCache.keySet();

        Set<String> newKeys = new Set<String>();
        Integer yearsSize = years.size();

        Integer idx = 0;
        for(Id prodId : productIds) {
            newKeys.add(accountsIds[idx] + '_' + prodId + '_' + (idx>=yearsSize ? years[0] : years[idx]));
        	idx++;
        }

        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,SFA2_PFG_to_Account_Detail_gne__c> newAccDetails = new Map<String,SFA2_PFG_to_Account_Detail_gne__c>();

            for(SFA2_PFG_to_Account_Detail_gne__c accDetail : GNE_SFA2_PFG_DAO.getPFGtoAccountDetailsByAccountsProductsAndYears(
            		new Set<Id>(accountsIds), new Set<Id>(productIds), new Set<String>(years))) {
                String extId = getRecordKey(accDetail);
                newAccDetails.put(extId,accDetail);
            }

            for(String key : newKeys) {
                pfgToAccountDetailsCache.put(key,newAccDetails.get(key));
            }
        }
    }

    public static void addPfgToAccountDetailToCash(SFA2_PFG_to_Account_Detail_gne__c accDetail){
        String extId = getRecordKey(accDetail);
        pfgToAccountDetailsCache.put(extId,accDetail);
    }

    public static SFA2_PFG_to_Account_Detail_gne__c getPfgToAccountDetail(SFA2_PFG_Transaction_gne__c trx) {
    	return getPfgToAccountDetail(trx.Account_gne__c, trx.Product_gne__c, String.valueOf(trx.Transaction_Date_gne__c.year()));
    }

    public static SFA2_PFG_to_Account_Detail_gne__c getPfgToAccountDetail(Id accountId, Id productId, String currentYear) {
        SFA2_PFG_to_Account_Detail_gne__c accDetail = null;

        if(pfgToAccountDetailsCache!=null) {
            String extId = accountId + '_' + productId + '_' +  currentYear;
            accDetail = pfgToAccountDetailsCache.get(extId);
        }
        return accDetail;
    }

    //Other supporting methods
    public static String currentYear(){
        String year ='';
        year = String.valueOf(Date.today().year());
        return year;
    }
    public static Set<String> getTransactionsLotNOs (List<SFA2_PFG_Transaction_gne__c> transactions){
        Set<String> transactionsLotNOs = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            transactionsLotNOs.add(trans.Lot_No_gne__c);
        }
        return transactionsLotNOs;
    }
    public static Set<String> getTransactionsUsers (List<SFA2_PFG_Transaction_gne__c> transactions){
        Set<String> transactionsUsers = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            transactionsUsers.add(trans.From_User_gne__c);
        }
        return transactionsUsers;
    }
    public static Set<String> getTransactionsProducts (List<SFA2_PFG_Transaction_gne__c> transactions){
        Set<String> transactionsProducts = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            transactionsProducts.add(trans.Product_gne__c);
        }
        return transactionsProducts;
    }
    public static Set<String> getCallIds (List<SFA2_PFG_Transaction_gne__c> transactions){
        Set<String> tmpCallIds = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            tmpCallIds.add(trans.Call_PFG_Detail_ID_gne__c);
        }
        return tmpCallIds;
    }
    public static Set<String> getTransactionsAccountsIds (List<SFA2_PFG_Transaction_gne__c> transactions){
        Set<String> transactionAccountsIds = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            transactionAccountsIds.add(trans.Account_gne__c);
        }
        return transactionAccountsIds;
    }
    // Sales Roster configuration methods
    public static Set<String> getRosterSalesForceValues() {
        cacheSalesRosters();

        Set<String> salesForces = new Set<String>();

        for(IC_Calc_Sales_Roster_gne__c rec : salesRostersCache) {
            if(String.isNotBlank(rec.Salesforce_gne__c)) {
                salesForces.add(rec.Salesforce_gne__c);
            }
        }

        return salesForces;
    }

    public static List<SFA2_User_Sales_Roster_gne__c> getUsersByBrandsAndRole(Set<String> brandNames, String roleName) {
        cacheSalesRosters();

        List<SFA2_User_Sales_Roster_gne__c> users = new List<SFA2_User_Sales_Roster_gne__c>();
        for(String brandName : brandNames) {
	        if(usersByBrandAndRoleCache.containsKey(brandName) && usersByBrandAndRoleCache.get(brandName).containsKey(roleName)) {
	            users.addAll(usersByBrandAndRoleCache.get(brandName).get(roleName));
	        }
        }

        return users;
    }

    public static List<SFA2_User_Sales_Roster_gne__c> getUsersByRoleName(String roleName) {
        cacheSalesRosters();
        return (usersByRoleCache.containsKey(roleName) ? usersByRoleCache.get(roleName) : new List<SFA2_User_Sales_Roster_gne__c>());
    }

    public static SFA2_User_Sales_Roster_gne__c getSalesRosterForUser(Id userId) {
        cacheSalesRosters();
        return userSalesRosterCache.get(userId);
    }

    public static User getUser(Id userId) {
    	SFA2_User_Sales_Roster_gne__c usr = getSalesRosterForUser(userId);
    	return usr!=null ? usr.User_gne__r : null;
    }

    public static User getUserByUnixId(String unixId) {
    	cacheSalesRosters();
    	return getUser(userUnixIdToIdCache.get(unixId!=null ? unixId.toUpperCase() : null));
    }

    private static void cacheSalesRosters() {
        if(salesRostersCache==null) {
        	userIdToTerritoryIdsCache = new Map<Id, Set<Id>>();
	        terrIdToUserIdsCache = new Map<Id, Set<Id>>();
	        terrIdToTerritoryCache = new Map<Id, Territory2>();
	        terrNameToIdCache = new Map<String,Id>();
	        terrNumberToIdCache = new Map<String,Id>();
	        territoryHierarchyCache = new Map<Id, Set<Id>>();
	        territoryLevelCache = new Map<Id, Integer>();
	        salesforceCodesByUserTerritoryCache = new Map<Id, Map<String, Set<String>>>();
	        usersByBrandAndRoleCache = new Map<String,Map<String,List<SFA2_User_Sales_Roster_gne__c>>>();
	        userToBrandNamesByTerritory = new Map<Id,Set<String>>();
	        usersByRoleCache = new Map<String,List<SFA2_User_Sales_Roster_gne__c>>();
	        userSalesRosterCache = new Map<Id,SFA2_User_Sales_Roster_gne__c>();
	        userUnixIdToIdCache = new Map<String,Id>();

            cacheUsersAndTerritoryHierarchy();
        }
    }

    private static void cacheUsersAndTerritoryHierarchy() {
        Set<String> brandNames = GNE_SFA2_PFG_Config.ACTIVE_BRANDS;
        Map<String, Set<String>> salesforceCodes = getSalesforceCodesByBrandNames(brandNames);

        addTerritoryToCache(new Territory2(Name = GNE_SFA2_PFG_Util.getHoTerritoryId()));
        // 1. Cache Root Territories
        Set<String> terrExtIds = new Set<String>();
        for(Territory2 terr : GNE_SFA2_PFG_DAO.getPfgRootTerritories(salesforceCodes)) {
        	addTerritoryToCache(terr);
        	terrExtIds.add(terr.External_Id_gne__c);
        }

        // 2. Cache DM and CS Territories
        for(Territory2 terr : GNE_SFA2_PFG_DAO.getPfgAllChildTerritories(terrExtIds, salesforceCodes)) {
        	if(terrIdToTerritoryCache.containsKey(terr.ParentTerritory2Id)) {
        		addTerritoryToCache(terr);
            }
        }

        // 3. Get Territory and User connections
        Map<Id, Set<Id>> territoryIdToUserIdMap = new Map <Id, Set<Id>>();
        Set<Id> brandUserIds = new Set<Id>();

        for(UserTerritory2Association uTerr : GNE_SFA2_PFG_DAO.getUserTerritoriesByTerritoryIds(terrIdToTerritoryCache.keySet())) {
            brandUserIds.add(uTerr.UserId);

            if(!territoryIdToUserIdMap.containsKey(uTerr.Territory2Id)) {
                territoryIdToUserIdMap.put(uTerr.Territory2Id, new Set<Id>());
            }

            territoryIdToUserIdMap.get(uTerr.Territory2Id).add(uTerr.UserId);
        }

        Set<String> pfgProfiles = getProfilesWithPermissionToPfg();

        // 4. Get SalesRosters to determine user roles.
        salesRostersCache = GNE_SFA2_PFG_DAO.getSalesRosters(
        	new Set<String>{SFA_APP_TYPE},
            new Set<String>{USER_ROLE_CS, USER_ROLE_DM, USER_ROLE_RM},
            new Set<String>{USER_ROLE_MANAGER},
            brandUserIds,
            pfgProfiles);

        for(IC_Calc_Sales_Roster_gne__c rec : salesRostersCache) {
        	for (SFA2_User_Sales_Roster_gne__c uRoster : rec.User_Sales_Roasters__r) {
        		String roleName = uRoster.Role_gne__c;

            	if(!usersByRoleCache.containsKey(roleName)) {
                	usersByRoleCache.put(roleName, new List<SFA2_User_Sales_Roster_gne__c>());
                }

        		usersByRoleCache.get(roleName).add(uRoster);
                userSalesRosterCache.put(uRoster.User_gne__c, uRoster);

                if(uRoster.User_gne__r.External_Id_gne__c!=null) {
                	userUnixIdToIdCache.put(uRoster.User_gne__r.External_Id_gne__c.toUpperCase(), uRoster.User_gne__c);
                }
            }
        }

        // 5. Cache User <-> Territory connections and User <-> Brand connections
        for(Id terrId : terrIdToTerritoryCache.keySet()) {
            if(territoryIdToUserIdMap.containsKey(terrId)) {
                terrIdToUserIdsCache.put(terrId, territoryIdToUserIdMap.get(terrId));
                Territory2 terr = terrIdToTerritoryCache.get(terrId);
                String salesforceCode = terr.Salesforce_Code_gne__c.toUpperCase();
    			String salesforceSubTeamCode = terr.Salesforce_SubTeam_Code_gne__c.toUpperCase();
    			Set<String> terrBrandNames = getBrandNameBySalesforceCodes(salesforceCode,salesforceSubTeamCode);

                for(Id userId : territoryIdToUserIdMap.get(terrId)) {
                	// It means that this is not RM, DM or CS user - we don't need to store it in cache
                	if(!userSalesRosterCache.containsKey(userId)) {
                		continue;
                	}

                    SFA2_User_Sales_Roster_gne__c uRoster = userSalesRosterCache.get(userId);
                    String roleName = uRoster.Role_gne__c;

                    if(!userIdToTerritoryIdsCache.containsKey(userId)) {
                        userIdToTerritoryIdsCache.put(userId, new Set<Id>());
                    }

                    userIdToTerritoryIdsCache.get(userId).add(terrId);

                    if(!salesforceCodesByUserTerritoryCache.containsKey(userId)) {
                    	salesforceCodesByUserTerritoryCache.put(userId, new Map<String, Set<String>>());
                    }

                    Map<String, Set<String>> userSalesforceCodes = salesforceCodesByUserTerritoryCache.get(userId);

                    if (!userSalesforceCodes.containsKey(salesforceCode)){
    					userSalesforceCodes.put(salesforceCode, new Set<String>());
    				}

    				userSalesforceCodes.get(salesforceCode).add(salesforceSubTeamCode);

    				for(String brandName : terrBrandNames) {
	    				if(!usersByBrandAndRoleCache.containsKey(brandName)) {
	                    	usersByBrandAndRoleCache.put(brandName, new Map<String,List<SFA2_User_Sales_Roster_gne__c>>());
	                	}

	                	if(!usersByBrandAndRoleCache.get(brandName).containsKey(roleName)) {
	                        usersByBrandAndRoleCache.get(brandName).put(roleName, new List<SFA2_User_Sales_Roster_gne__c>());
	                    }

	                    usersByBrandAndRoleCache.get(brandName).get(roleName).add(uRoster);

	                    if(!userToBrandNamesByTerritory.containsKey(userId)) {
	                    	userToBrandNamesByTerritory.put(userId, new Set<String>());
	                    }

	                    userToBrandNamesByTerritory.get(userId).add(brandName);
    				}
    			}
    		}
        }
    }

    private static void addTerritoryToCache(Territory2 terr) {
    	terrIdToTerritoryCache.put(terr.Id, terr);
    	terrNameToIdCache.put(terr.Name.toUpperCase(), terr.Id);
    	terrNumberToIdCache.put(terr.Id!=null ? terr.Territory_Number_gne__c.toUpperCase() : null, terr.Id);
        territoryHierarchyCache.put(terr.Id, new Set<Id>());

        if(terr.ParentTerritory2Id==null) { // Home Office Virtual Territory
        	territoryLevelCache.put(terr.Id, 0);
        } else {
        	Id parentTerrId = territoryHierarchyCache.containsKey(terr.ParentTerritory2Id) ? terr.ParentTerritory2Id : null;
        	territoryHierarchyCache.get(parentTerrId).add(terr.Id);
        	territoryLevelCache.put(terr.Id, territoryLevelCache.get(parentTerrId) + 1);
        }
    }

    public static Set<String> getProfilesWithPermissionToPfg() {
    	cacheProfilesWithPermissionToPfgCache();
    	return profilesWithPermissionToPfgCache;
    }

    private static void cacheProfilesWithPermissionToPfgCache() {
    	if(profilesWithPermissionToPfgCache==null) {
    		profilesWithPermissionToPfgCache = GNE_SFA2_PFG_DAO.getProfilesWithPermissionToPfg(GNE_SFA2_PFG_Config.PFG_MAIN_PAGE);
    	}
    }

    // Check if given territory is covered by salesforces codes
    private static Boolean checkTerritoryBySalesforceCodes(Territory2 territory, Map<String, Set<String>> salesforceCodes){
    	Boolean result = false;
    	if (salesforceCodes.containsKey(territory.Salesforce_Code_gne__c)){
    		Set<String> subCodes = salesforceCodes.get(territory.Salesforce_Code_gne__c);
            if (subCodes.contains(territory.Salesforce_SubTeam_Code_gne__c)){
            	result = true;
            }
        }
        return result;
    }

    public static Map<Id,Map<Id,SFA2_PFG_to_User_Detail_gne__c>> getPFGToUserDetailsForUsers(Set<Id> userIds, String distMethod) {
        if(pfgToUserDetailsForUsersCache == null) {
            pfgToUserDetailsForUsersCache = new Map<Id,Map<Id,SFA2_PFG_to_User_Detail_gne__c>>();
        }

        Set<Id> existingKeys = pfgToUserDetailsForUsersCache.keySet();
        Set<Id> newKeys = userIds.clone();
        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<Id,Map<Id,SFA2_PFG_to_User_Detail_gne__c>> newUserDetails = new Map<Id,Map<Id,SFA2_PFG_to_User_Detail_gne__c>>();

            for(SFA2_PFG_to_User_Detail_gne__c uDetail : GNE_SFA2_PFG_DAO.getPFGToUserDetailsForUsers(userIds,new Set<String>{distMethod})) {
                if(!newUserDetails.containsKey(uDetail.User_gne__c)) {
                    newUserDetails.put(uDetail.User_gne__c, new Map<Id,SFA2_PFG_to_User_Detail_gne__c>());
                }

                newUserDetails.get(uDetail.User_gne__c).put(uDetail.Id, uDetail);

            }

            for(Id key : newKeys) {
                if(!pfgToUserDetailsForUsersCache.containsKey(key)) {
                    pfgToUserDetailsForUsersCache.put(key, new Map<Id,SFA2_PFG_to_User_Detail_gne__c>());
                }

                if(newUserDetails.containsKey(key)) {
                    pfgToUserDetailsForUsersCache.get(key).putAll(newUserDetails.get(key));
                } else {
                    newUserDetails.put(key, new Map<Id,SFA2_PFG_to_User_Detail_gne__c>());
                }
            }
        }

        Map<Id,Map<Id,SFA2_PFG_to_User_Detail_gne__c>> result = new Map<Id,Map<Id,SFA2_PFG_to_User_Detail_gne__c>>();

        for(Id uId : userIds) {
            result.put(uId, pfgToUserDetailsForUsersCache.get(uId));
        }

        return result;
    }

    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsForUsersFlat(Set<Id> userIds, String distMethod) {
        List<SFA2_PFG_to_User_Detail_gne__c> result = new List<SFA2_PFG_to_User_Detail_gne__c>();

        for(Map<Id,SFA2_PFG_to_User_Detail_gne__c> uDetailsMap: getPFGToUserDetailsForUsers(userIds, distMethod).values()) {
            for(SFA2_PFG_to_User_Detail_gne__c uDetail : uDetailsMap.values()) {
                result.add(uDetail);
            }
        }

        return result;
    }

    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsActiveForUsersFlat(Set<Id> userIds, String distMethod, Boolean includeZeroPfg2UserDetails) {
        List<SFA2_PFG_to_User_Detail_gne__c> result = new List<SFA2_PFG_to_User_Detail_gne__c>();

        for(SFA2_PFG_to_User_Detail_gne__c uDetail : getPFGToUserDetailsForUsersFlat(userIds, distMethod)) {
            if(uDetail.Product_gne__c!=null &&
               uDetail.Lot_No_gne__c!=null && uDetail.Lot_No_gne__c!=LOT_NO_NA_VALUE &&
               (uDetail.Qty_Total_Available_gne__c > 0 || includeZeroPfg2UserDetails)) {
                result.add(uDetail);
            }
        }

        return result;
    }

    public static Map<String,Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>> getPFGToTerritoryDetailsForTerrNames(Set<String> terrNames, Set<Integer> years) {
        if(pfgToTerrDetailsForUsersCache == null) {
            pfgToTerrDetailsForUsersCache = new Map<String,Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>>();
        }

        Set<String> existingKeys = pfgToTerrDetailsForUsersCache.keySet();
        Set<String> newKeys = terrNames.clone();
        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>> newTerrDetails = new Map<String,Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>>();

            for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : GNE_SFA2_PFG_DAO.getPFGtoTerritoryDetailsByTerritoryName(terrNames, years)) {
            	if(!newTerrDetails.containsKey(tDetail.Territory_Name_gne__c)) {
                    newTerrDetails.put(tDetail.Territory_Name_gne__c, new Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>());
                }

                newTerrDetails.get(tDetail.Territory_Name_gne__c).put(tDetail.Id, tDetail);

            }

            for(String key : newKeys) {
                if(!pfgToTerrDetailsForUsersCache.containsKey(key)) {
                    pfgToTerrDetailsForUsersCache.put(key, new Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>());
                }

                if(newTerrDetails.containsKey(key)) {
                    pfgToTerrDetailsForUsersCache.get(key).putAll(newTerrDetails.get(key));
                } else {
                    newTerrDetails.put(key, new Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>());
                }
            }
        }

        Map<String,Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>> result = new Map<String,Map<Id,SFA2_PFG_to_Territory_Detail_gne__c>>();

        for(String terrName : terrNames) {
            result.put(terrName, pfgToTerrDetailsForUsersCache.get(terrName));
        }

        return result;
    }

    public static List<SFA2_PFG_to_Territory_Detail_gne__c> getPFGToTerrDetailsForTerrNamesFlat(Set<String> terrNames, Set<Integer> years) {
        List<SFA2_PFG_to_Territory_Detail_gne__c> result = new List<SFA2_PFG_to_Territory_Detail_gne__c>();

        for(Map<Id,SFA2_PFG_to_Territory_Detail_gne__c> tDetailsMap: getPFGToTerritoryDetailsForTerrNames(terrNames, years).values()) {
            for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : tDetailsMap.values()) {
                result.add(tDetail);
            }
        }

        return result;
    }

    public static List<SFA2_PFG_to_Territory_Detail_gne__c> getPFGToTerrDetailsActiveForTerrNamesFlat(Set<String> terrNames, Set<Integer> years) {
        List<SFA2_PFG_to_Territory_Detail_gne__c> result = new List<SFA2_PFG_to_Territory_Detail_gne__c>();

        for(SFA2_PFG_to_Territory_Detail_gne__c tDetail: getPFGToTerrDetailsForTerrNamesFlat(terrNames, years)) {
            if(tDetail.Qty_Total_Available_gne__c > 0) {
                result.add(tDetail);
            }
        }

        return result;
    }

    public static Set<Id> getCsUserIdsWithActivePfgToUserDetails(String distMethod) {
        return getCsUserIdsWithActivePfgToUserDetails(distMethod, false);
    }

    public static Set<Id> getCsUserIdsWithActivePfgToUserDetails(String distMethod, Boolean includeZeroPfg2UserDetails) {
        Set<Id> result = new Set<Id>();

        Set<Id> csIds = new Set<Id>();
        for(SFA2_User_Sales_Roster_gne__c sRoster : GNE_SFA2_PFG_Util.getUsersByRoleName(USER_ROLE_CS)) {
            csIds.add(sRoster.User_gne__c);
        }

        for(SFA2_PFG_to_User_Detail_gne__c uDetail : getPFGToUserDetailsActiveForUsersFlat(csIds,distMethod,includeZeroPfg2UserDetails)) {
            result.add(uDetail.User_gne__c);
        }

        return result;
    }

    public static Set<Id> getUsedPfgProductsIdsForUser(Id userId, String distMethod) {
        return getUsedPfgProductsIdsForUser(userId, distMethod, false);
    }

    public static Set<Id> getUsedPfgProductsIdsForUser(Id userId, String distMethod, Boolean includeZeroPfg2UserDetails) {
        Set<Id> result = new Set<Id>();

        for(SFA2_PFG_to_User_Detail_gne__c uDetail : getPFGToUserDetailsActiveForUsersFlat(new Set<Id>{userId}, distMethod, includeZeroPfg2UserDetails)) {
            result.add(uDetail.Product_gne__c);
        }

        return result;
    }

    public static Set<Id> getUsedPfgProductsIdsForTerritory(Set<String> terrIds, Set<Integer> years) {
        Set<Id> result = new Set<Id>();

        Set<String> terrNames = new Set<String>();
        for(String terrId : terrIds) {
            String terrName = terrId;

            if(terrId != getHoTerritoryId()) {
                terrName = getTerritory(terrId).Name;
            }

            terrNames.add(terrName);
        }

        for (SFA2_PFG_to_Territory_Detail_gne__c tDetail : getPFGToTerrDetailsActiveForTerrNamesFlat(terrNames, years)) {
            if(tDetail.Product_gne__c != null) {
                result.add(tDetail.Product_gne__c);
            }
        }

        return result;
    }

    public static Set<Id> getUsedPfgLotCatalogsIdsForUser(Id userId, String distMethod) {
        return getUsedPfgLotCatalogsIdsForUser(userId, distMethod, false);
    }

    public static Set<Id> getUsedPfgLotCatalogsIdsForUser(Id userId, String distMethod, Boolean includeZeroPfg2UserDetails) {
        Set<Id> result = new Set<Id>();

        Set<String> lotNos = new Set<String>();
        for(SFA2_PFG_to_User_Detail_gne__c uDetail : getPFGToUserDetailsActiveForUsersFlat(new Set<Id>{userId}, distMethod, includeZeroPfg2UserDetails)) {
            lotNos.add(uDetail.Lot_No_gne__c);
        }
        if(!lotNos.isEmpty()) {
            for(SFA2_Lot_Catalog_gne__c lotCatalog : getLotCatalogList(lotNos).values()) {
                if(lotNos.contains(lotCatalog.Name)) {
                    result.add(lotCatalog.Id);
                }
            }
        }

        return result;
    }

    public static List<Product_vod__c> getProductsForBrand( String brandName) {
        return getProductsForBrand(brandName, true);
    }

    public static List<Product_vod__c> getProductsForBrand( String brandName, Boolean doSort) {
        if(brandToPFGProductCache== null) {
            cachePfgProducts();
        }

        List<Product_vod__c> prods = new List<Product_vod__c>();
        if(brandToPFGProductCache.containsKey(brandName)) {
            for(Id prodId : brandToPFGProductCache.get(brandName)) {
                prods.add(getPfgProduct(prodId));
            }
        }

        if(doSort) {
            prods.sort();
        }

        return prods;
    }

    public static Set<Id> getProductIdsForBrands(Set<String> brandNames) {
    	if(brandToPFGProductCache== null) {
            cachePfgProducts();
        }

        Set<Id> prodIds = new Set<Id>();

        for(String brandName : brandNames) {
        	if(brandToPFGProductCache.containsKey(brandName)) {
        		prodIds.addAll(brandToPFGProductCache.get(brandName));
        	}
        }

        return prodIds;
    }

    public static Set<String> getBrandNames() {
        if(brandToPFGProductCache== null) {
            cachePfgProducts();
        }

        return brandToPFGProductCache.keySet();
    }

    public static Product_vod__c getPfgProduct(Id prodId) {
        if(pfgProductsCache==null) {
            cachePfgProducts();
        }

        return pfgProductsCache.get(prodId);
    }

    public static Product_vod__c getPfgProductByName(String prodName) {
        if(pfgProductNameToIdCache==null) {
            cachePfgProducts();
        }

        return getPfgProduct(pfgProductNameToIdCache.get(prodName.toUpperCase()));
    }

    public static Set<String> getDistMethodsForProduct(Id prodId) {
        if(pfgProductToDistMethodsCache==null) {
            cachePfgProducts();
        }

        return pfgProductToDistMethodsCache.containsKey(prodId) ? pfgProductToDistMethodsCache.get(prodId) : new Set<String>();
    }

    public static Set<Id> getProductIdsForDistMethod(String distMethod) {
        if(pfgDistMethodToProductIdsCache==null) {
            cachePfgProducts();
        }

        return pfgDistMethodToProductIdsCache.containsKey(distMethod) ? pfgDistMethodToProductIdsCache.get(distMethod) : new Set<Id>();
    }

    public static Boolean isProductDtp(Id prodId) {
        return getDistMethodsForProduct(prodId).contains(TRANSACTION_DISCTRIBUTION_METHOD_DTP);
    }

    public static Boolean isProductHandCarry(Id prodId) {
        return getDistMethodsForProduct(prodId).contains(TRANSACTION_DISCTRIBUTION_METHOD_HC);
    }

    public static Boolean isProductDtpAndHandCarry(Id prodId) {
        return isProductDtp(prodId) && isProductHandCarry(prodId);
    }

    private static void cachePfgProducts() {
        brandToPFGProductCache = new Map<String,Set<Id>>();
        pfgProductsCache = new Map<Id,Product_vod__c>();
        pfgProductNameToIdCache = new Map<String,Id>();
        pfgDistMethodToProductIdsCache = new Map<String,Set<Id>>();
        pfgProductToDistMethodsCache = new Map<Id,Set<String>>();

        for(Product_vod__c pfgProd : GNE_SFA2_PFG_DAO.getPfgProducts(TRANSACTION_DISCTRIBUTION_METHOD_DTP, TRANSACTION_DISCTRIBUTION_METHOD_HC)) {
            Id prodId = pfgProd.Id;
            pfgProductsCache.put(prodId, pfgProd);
            pfgProductNameToIdCache.put(pfgProd.Name.toUpperCase(), prodId);
            String brandName = pfgProd.Parent_Product_vod__r.Name;

            if(!brandToPFGProductCache.containsKey(brandName)) {
                brandToPFGProductCache.put(brandName, new Set<Id>());
            }
            brandToPFGProductCache.get(brandName).add(prodId);

            String distMethod = null;

            for(SFA2_Lot_Catalog_gne__c lc : pfgProd.PFG_Lot_Catalog__r) {
                distMethod = lc.Distribution_Method_gne__c;
            }

            // Three situations may occur:
            // 1. Distribution Method is defined in Lot Catalog - add it to cache
            // 2. Distribution Method is not defined in Lot Catalog. Probably this is DTP, but we need to check if it's already registered as Hand Carry or DTP.
            //    If Yes - do not add it to cache, because it is already added to cache.
            // 3. Distribution Method is not defined in Lot Catalog and it is not yet registered in cache. Add it to cache as DTP.
            distMethod = distMethod!=null
            	? distMethod
            	: (!pfgProductToDistMethodsCache.containsKey(prodId) ? TRANSACTION_DISCTRIBUTION_METHOD_DTP : null);

            if(distMethod!=null) {
            	if(!pfgDistMethodToProductIdsCache.containsKey(distMethod)) {
	            	pfgDistMethodToProductIdsCache.put(distMethod, new Set<Id>());
	            }

	            pfgDistMethodToProductIdsCache.get(distMethod).add(prodId);

	            if(!pfgProductToDistMethodsCache.containsKey(prodId)) {
	            	pfgProductToDistMethodsCache.put(prodId, new Set<String>());
	            }
	            pfgProductToDistMethodsCache.get(prodId).add(distMethod);
            }
        }
    }

  	public static Map<String, Set<String>> getSalesforceCodesByBrandNames(Set<String> brandNames){
    	Map<String, Set<String>> result = new Map<String, Set<String>>();
    	if (brandNames == null || brandNames.isEmpty()){
    		return result;
    	}
    	if (brandToSalesforceCodesCache == null){
    		cacheBrandToSalesforce();
    	}
    	for (String brandName : brandNames){
    		if (brandToSalesforceCodesCache.containsKey(brandName)){
    			Map<String, Set<String>> codes = brandToSalesforceCodesCache.get(brandName);
    			for (String code : codes.keyset()){
    				result.put(code, codes.get(code));
    			}
    		}
    	}
    	return result;
    }

    public static Set<String> getBrandNamesByUserTerritory(Id userID){
    	cacheSalesRosters();
    	return userToBrandNamesByTerritory.containsKey(userID) ? userToBrandNamesByTerritory.get(userID) : new Set<String>();
    }

    // Map of SalesforceCodes to Salesforce SubTeamCodes (upperCase)
    public static Map<String, Set<String>> getSalesforceCodesByUserTerritory(Id userID){
    	cacheSalesRosters();
    	return salesforceCodesByUserTerritoryCache.containsKey(userID) ? salesforceCodesByUserTerritoryCache.get(userID) : new Map<String, Set<String>>();
    }

    public static Set<String> getBrandNameBySalesforceCodes(String salesforceCode, String salesforceSubCode){
    	Set<String> result = new Set<String>();
    	if (String.isBlank(salesforceCode) || String.isBlank(salesforceSubCode)){
    		return result;
    	}

    	Map<String, Set<String>> salesforceCodes = new Map<String, Set<String>>();
    	salesforceCodes.put(salesforceCode, new Set<String>{salesforceSubCode});
    	result = getBrandNamesBySalesforceCodes(salesforceCodes);
    	salesforceCodes.clear();

    	return result;
    }

    public static Set<String> getBrandNamesBySalesforceCodes(Map<String, Set<String>> salesforceCodes){
    	Set<String> result = new Set<String>();
    	if (salesforceCodes == null || salesforceCodes.isEmpty()){
    		return result;
    	}
    	if (brandToSalesforceCodesCache == null){
    		cacheBrandToSalesforce();
    	}
    	for (String salesforceCodeToFind : salesforceCodes.keyset()){
    		for (String availableBrand : brandToSalesforceCodesCache.keyset()){
    			Map<String, Set<String>> availableSalesforceCodes = brandToSalesforceCodesCache.get(availableBrand);
    			if (availableSalesforceCodes.containsKey(salesforceCodeToFind)){
    				Set<String> salesforceSubTeamCodesToFind = salesforceCodes.get(salesforceCodeToFind);
    				Set<String> availableSalesforceSubTeamCodes = availableSalesforceCodes.get(salesforceCodeToFind);
    				for (String subTeamCodeToFind : salesforceSubTeamCodesToFind){
    					if (availableSalesforceSubTeamCodes.contains(subTeamCodeToFind)){
    						result.add(availableBrand);
    						break;
    					}
    				}
    			}
    		}
    	}
    	return result;
    }

    public static Set<String> getBrandNamesBySalesforceActiveBrands(Set<String> brandNamesFilter){
    	Set<String> result = new Set<String>();
    	if (brandNamesFilter == null || brandNamesFilter.isEmpty()){
    		return result;
    	}
    	if (brandToSalesforceCodesCache == null){
    		cacheBrandToSalesforce();
    	}
    	for (String activeBrandName : brandNamesFilter){
    		if (brandToSalesforceCodesCache.containsKey(activeBrandName)){
    			result.add(activeBrandName);
    		}
    	}
    	return result;
    }

    public static void cacheBrandToSalesforce() {
    	// brandName -> salesforce code -> salesforce sub team codes
    	brandToSalesforceCodesCache = new Map<String, Map<String, Set<String>>>();
    	for (Brand_2_Salesforce_gne__c brandItem : GNE_SFA2_PFG_DAO.getBrandsToSalesforces(GNE_SFA2_PFG_Config.ACTIVE_BRANDS)){
    		String brandName = brandItem.SFA_Brand_Name_gne__c;
    		String salesforceCode = brandItem.CDM_Salesforce_Code_gne__c.toUpperCase();
    		String salesforceSubTeamCode = brandItem.CDM_Salesforce_SubTeam_Code_gne__c.toUpperCase();

    		if (!brandToSalesforceCodesCache.containsKey(brandName)){
    			brandToSalesforceCodesCache.put(brandName, new Map<String, Set<String>>());
    		}
    		Map<String, Set<String>> salesforceCodes = brandToSalesforceCodesCache.get(brandName);
    		if (!salesforceCodes.containsKey(salesforceCode)){
    			salesforceCodes.put(salesforceCode, new Set<String>());
    		}
    		salesforceCodes.get(salesforceCode).add(salesforceSubTeamCode);
    		brandToSalesforceCodesCache.put(brandName, salesforceCodes);
    	}
    }

    public static List<SFA2_PFG_Transaction_gne__c> saveTransaction(List<SFA2_PFG_Transaction_gne__c> transactionsList) {
        return saveTransaction(transactionsList, null, false);
    }

    public static List<SFA2_PFG_Transaction_gne__c> saveTransaction(List<SFA2_PFG_Transaction_gne__c> transactionsList, String refNo, Boolean setLotNo) {
        if(transactionsList!=null && !transactionsList.isEmpty()){
            // Standard Upsert Transactions operation
            upsert transactionsList;

            // Now generate Transaction Ref No if needed.
            transactionsList = GNE_SFA2_PFG_DAO.getTransactionsNameAndRefNo(transactionsList);
            List<SFA2_PFG_Transaction_gne__c> trnToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
            // Transaction Ref No is caclulated from last transaction auto generated Name
            String transRefNumber = refNo!=null ? refNo : ('PFGTRX-' + (transactionsList.get(transactionsList.size()-1).Name).substringAfter('-'));

            for(SFA2_PFG_Transaction_gne__c trn : transactionsList){
                Boolean somethingChanged = false;

                if(transRefNumber!=trn.Transaction_Ref_Number_gne__c) {
                    trn.Transaction_Ref_Number_gne__c = transRefNumber;
                    if(trn.Transaction_Type_gne__c == 'Order'){
                        trn.Lot_No_gne__c = transRefNumber;
                    }
                    somethingChanged = true;
                }

                if(setLotNo && trn.Lot_No_gne__c!=transRefNumber) {
                    trn.Lot_No_gne__c = transRefNumber;
                    somethingChanged = true;
                }

                if(somethingChanged) {
                    trnToUpdate.add(trn);
                }
            }

            upsert trnToUpdate;

            return trnToUpdate;
        }
        return null;
    }

    public static Map<String,Map<Id,SFA2_PFG_Transaction_gne__c>> cachePfgAllocationTransactions(Set<String> transactionRefNo) {
        return cachePfgAllocationTransactions(GNE_SFA2_PFG_DAO.getPfgTransactionsByRefNo(transactionRefNo));
    }

    public static Map<String,Map<Id,SFA2_PFG_Transaction_gne__c>> cachePfgAllocationTransactions(Set<Id> productIds, Set<Id> userIds) {
        return cachePfgAllocationTransactions(GNE_SFA2_PFG_DAO.getPfgAllocationsByProductId(productIds, userIds, TRANSACTION_SHIPMENT_NOT_INITIATED, TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER));
    }

    private static Map<String,Map<Id,SFA2_PFG_Transaction_gne__c>> cachePfgAllocationTransactions(List<SFA2_PFG_Transaction_gne__c> trnRecs) {
        if(pfgAllocationTransactionsCache==null) {
            pfgAllocationTransactionsCache = new Map<String,Map<Id,SFA2_PFG_Transaction_gne__c>>();
        }

        for(SFA2_PFG_Transaction_gne__c tr : trnRecs) {
            String key = tr.From_User_gne__c + '_' + tr.To_User_gne__c;
            String onlyToUserKey = null + '_' + tr.To_User_gne__c;

            if(!pfgAllocationTransactionsCache.containsKey(key)) {
                pfgAllocationTransactionsCache.put(key, new Map<Id,SFA2_PFG_Transaction_gne__c>());
            }
            pfgAllocationTransactionsCache.get(key).put(tr.Id,tr);

            if(onlyToUserKey!=key) {
                // Also group transaction by To User only. It will be handy if we don't know or don't care about 'From User'
                if(!pfgAllocationTransactionsCache.containsKey(onlyToUserKey)) {
                    pfgAllocationTransactionsCache.put(onlyToUserKey, new Map<Id,SFA2_PFG_Transaction_gne__c>());
                }
                pfgAllocationTransactionsCache.get(onlyToUserKey).put(tr.Id,tr);
            }
        }

        return pfgAllocationTransactionsCache;
    }

    public static List<SFA2_PFG_Transaction_gne__c> getPfgAllocationTransaction(Id fromUser, Id toUser) {
        return getPfgAllocationTransaction(fromUser, toUser, pfgAllocationTransactionsCache);
    }

    public static List<SFA2_PFG_Transaction_gne__c> getPfgAllocationTransaction(Id fromUser, Id toUser, Map<String,Map<Id,SFA2_PFG_Transaction_gne__c>> cache) {
        Map<Id,SFA2_PFG_Transaction_gne__c> result;

        String key = fromUser + '_' + toUser;
        if(cache!=null) {
            result = cache.get(key);
        } else {
            cache = pfgAllocationTransactionsCache = new Map<String,Map<Id,SFA2_PFG_Transaction_gne__c>>();
        }

        if(result==null) {
            result = new Map<Id,SFA2_PFG_Transaction_gne__c>{
                            null => new SFA2_PFG_Transaction_gne__c(From_User_gne__c = fromUser, To_User_gne__c = toUser,
                                                                    Requested_Quantity_gne__c = 0, Shipped_Quantity_gne__c = 0)};
            cache.put(key, result);


        } else {
            // check if there is at least one existing 'Not shipped' allocation transfer.
            // If now, create a new one
            Boolean notShippedTransferIsMissing = true;
            for(SFA2_PFG_Transaction_gne__c trn : result.values()) {
                if(trn.Generate_Shipment_Flag__c != GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED) {
                    notShippedTransferIsMissing = false;
                }
            }

            if(notShippedTransferIsMissing) {
                result.put(null, new SFA2_PFG_Transaction_gne__c(
                        From_User_gne__c = fromUser, To_User_gne__c = toUser,
                        Requested_Quantity_gne__c = 0, Shipped_Quantity_gne__c = 0));
            }
        }

        return result.values();
    }

	public static void clearPfgAllocationTransactionsCache() {
        pfgAllocationTransactionsCache=null;
	}

    public static List<SFA2_PFG_Transaction_gne__c> getAllocTransfersAssignedToCSs(Set<String> brandNames, Set<Id> pfgProductIds) {
        return GNE_SFA2_PFG_DAO.getTransactions(
            new Set<String>{TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
            brandNames,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', TRANSACTION_SHIPMENT_NOT_INITIATED),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Product_gne__c', 'IN', (pfgProductIds!=null && !pfgProductIds.isEmpty()) ? pfgProductIds : null)
            },
            new List<String>{
                'Product_gne__r.Parent_Product_vod__r.Name asc',
                'Product_gne__r.Name asc',
                'To_User_gne__r.Name asc'
            });
    }

    public static Set<Id> generateShipment(List<SFA2_PFG_Transaction_gne__c> allocTransfersToShip) {

        Set<Id> invalidAllocTransfersForShipment = new Set<Id>();

        List<SFA2_PFG_Transaction_gne__c> csRecordsToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
        List<SFA2_PFG_Transaction_gne__c> dmRecordsToUpsert = new List<SFA2_PFG_Transaction_gne__c>();

        Set<Id> csIds = new Set<Id>();
        Set<Id> dmIds = new Set<Id>();
        Set<String> refNos = new Set<String>();
        Map<String, Integer> csQuantityToShipped = new Map<String, Integer>();

        cacheStorageLocations(allocTransfersToShip, false);

        //1. Process Allocation Transfers for CSes.
        processCsAllocTransfersOnGenerateShipment(allocTransfersToShip, csIds, dmIds, refNos, csQuantityToShipped, csRecordsToUpdate,
            invalidAllocTransfersForShipment);

        //2. Process Allocation Transfers for DMs.
        processDmAllocTransfersOnGenerateShipment(csIds, dmIds, refNos, csQuantityToShipped, csRecordsToUpdate, dmRecordsToUpsert);

        //3. Update or Insert ATs for DMs.
        // DM need to be processed first, because of Logic for updating User Detail records.
        upsert dmRecordsToUpsert;
        clearPfgToUserCache();
        //4. Update ATs for CSes.
        update csRecordsToUpdate;

        //5. Return ids of those CS ATs, for which we couldn't generate the shipment.
        return invalidAllocTransfersForShipment;
    }

    private static void processCsAllocTransfersOnGenerateShipment(
            List<SFA2_PFG_Transaction_gne__c> allocTransfersToShip,
            Set<Id> csIds,
            Set<Id> dmIds,
            Set<String> refNos,
            Map<String, Integer> csQuantityToShipped,
            List<SFA2_PFG_Transaction_gne__c> csRecordsToUpdate,
            Set<Id> invalidAllocTransfersForShipment) {

        for(SFA2_PFG_Transaction_gne__c allocRec : allocTransfersToShip) {

            if(!validateGenerateShipment(allocRec)) {
                invalidAllocTransfersForShipment.add(allocRec.Id);
                continue;
            }
            csIds.add(allocRec.To_User_gne__c);
            dmIds.add(allocRec.From_User_gne__c);
            refNos.add(allocRec.Transaction_Ref_Number_gne__c);
            String dmKey = allocRec.From_User_gne__c + '_' + allocRec.Transaction_Ref_Number_gne__c;

            if(!csQuantityToShipped.containsKey(dmKey)) {
                csQuantityToShipped.put(dmKey,0);
            }

            csQuantityToShipped.put(dmKey,csQuantityToShipped.get(dmKey) + allocRec.Requested_Quantity_gne__c.intValue());

            csRecordsToUpdate.add(new SFA2_PFG_Transaction_gne__c(
                Id = allocRec.Id,
                Generate_Shipment_Flag__c = TRANSACTION_SHIPMENT_INITIATED,
                Shipment_Request_Date_gne__c = System.today(),
                Status_gne__c = TRANSACTION_STATUS_APPROVED));
        }
    }

    private static void processDmAllocTransfersOnGenerateShipment(
            Set<Id> csIds,
            Set<Id> dmIds,
            Set<String> refNos,
            Map<String, Integer> csQuantityToShipped,
            List<SFA2_PFG_Transaction_gne__c> csRecordsToUpdate,
            List<SFA2_PFG_Transaction_gne__c> dmRecordsToUpsert) {

        System.debug('[BOS]::refNos=' + refNos);
        System.debug('[BOS]::csIds=' + csIds);
        // We need to update DM Allocation Transfer as well.
        // Find Allocation Transfers for related DMs.
        List<SFA2_PFG_Transaction_gne__c> relatedDmAllocTransfers = GNE_SFA2_PFG_DAO.getTransactions(
            new Set<String>{TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', false),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', TRANSACTION_SHIPMENT_NOT_INITIATED),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_gne__c', 'IN', dmIds),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', refNos)
            },
            null);

        Set<String> dmKeysWithOtherTransfers = new Set<String>();

        System.debug('[BOS]::dmKeysWithOtherTransfers=' + dmKeysWithOtherTransfers);

        for (SFA2_PFG_Transaction_gne__c otherCsAlloc :
                    GNE_SFA2_PFG_DAO.getTransactions(
                        new Set<String>{TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER},
                        null,
                        new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_Is_CS_Flag_gne__c', '=', true),
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Generate_Shipment_Flag__c', '=', TRANSACTION_SHIPMENT_NOT_INITIATED),
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('From_User_gne__c', 'IN', dmIds),
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('To_User_gne__c', 'NOT IN', csIds),
                            new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', refNos)
                        }, null)) {

            String dmKey = otherCsAlloc.From_User_gne__c + '_' + otherCsAlloc.Transaction_Ref_Number_gne__c;
            dmKeysWithOtherTransfers.add(dmKey);
        }

        // Update DM Alocation Transfers
        for(SFA2_PFG_Transaction_gne__c allocRec : relatedDmAllocTransfers) {
            String dmKey = allocRec.To_User_gne__c + '_' + allocRec.Transaction_Ref_Number_gne__c;

            if(csQuantityToShipped.containsKey(dmKey)) {
                Integer shippedQuantity = csQuantityToShipped.get(dmKey);

                SFA2_PFG_Transaction_gne__c dmAllocTransgerToUpdate =
                    new SFA2_PFG_Transaction_gne__c(
                        Id = allocRec.Id,
                        Generate_Shipment_Flag__c = TRANSACTION_SHIPMENT_DM_PROCESSED,
                        Received_Quantity_gne__c = allocRec.Requested_Quantity_gne__c,
                        Shipped_Quantity_gne__c = allocRec.Requested_Quantity_gne__c,
                        Status_gne__c = TRANSACTION_STATUS_SUBMITTED);

                // Leave the rest of Quantity in 'Not Initiated' Allocation Transfer for DM.
                if(dmKeysWithOtherTransfers.contains(dmKey) &&
                   allocRec.Requested_Quantity_gne__c.intValue() > csQuantityToShipped.get(dmKey)) {

                    dmAllocTransgerToUpdate.Received_Quantity_gne__c =
                        dmAllocTransgerToUpdate.Shipped_Quantity_gne__c =
                        dmAllocTransgerToUpdate.Requested_Quantity_gne__c = shippedQuantity;

                    SFA2_PFG_Transaction_gne__c notInitiatedAllocTransfer = allocRec.clone(false,false,false,false);
                    notInitiatedAllocTransfer.Requested_Quantity_gne__c = (allocRec.Requested_Quantity_gne__c.intValue() - csQuantityToShipped.get(dmKey));
                    dmRecordsToUpsert.add(notInitiatedAllocTransfer);
                }

                dmRecordsToUpsert.add(dmAllocTransgerToUpdate);
            }
        }
    }

    public static Boolean validateGenerateShipment(SFA2_PFG_Transaction_gne__c csAllocationTransfer) {
        return getApprovedStorageLocationForUser(csAllocationTransfer.To_User_gne__c)!=null;
    }

    public static void cacheUsersHierarchy(Id userId) {
        SFA2_User_Sales_Roster_gne__c uRoster = getSalesRosterForUser(userId);
        cacheUsersHierarchy(userId,uRoster.Role_gne__c,null);
    }

    public static void cacheUsersHierarchy(Id userId, String userRoleName, String brandName) {
        if(usersHierarchyCache==null) {
            usersHierarchyCache = new Map<Id,List<Id>>();
            userManagersCache = new Map<Id,Id>();
        }

        List<Id> childUserIds = new List<Id>();
        usersHierarchyCache.put(userId, childUserIds);

        if(userRoleName==USER_ROLE_MANAGER) {
            List<SFA2_User_Sales_Roster_gne__c> dmSalesRosters = brandName!=null
                        ? getUsersByBrandsAndRole(new Set<String>{brandName}, USER_ROLE_DM)
                        : getUsersByRoleName(USER_ROLE_DM);
            for(SFA2_User_Sales_Roster_gne__c dmSalesRoster : dmSalesRosters) {
                //if(dmSalesRoster.User_gne__r.ManagerId == userId) {
                    childUserIds.add(dmSalesRoster.User_gne__c);
                    cacheUsersHierarchy(dmSalesRoster.User_gne__c, USER_ROLE_DM, brandName);
                //}
            }
        } else if(userRoleName==USER_ROLE_DM) {
            //userManagersCache.put(userId, getSalesRosterForUser(userId).User_gne__r.ManagerId);

            List<SFA2_User_Sales_Roster_gne__c> csSalesRosters = brandName!=null
                        ? getUsersByBrandsAndRole(new Set<String>{brandName}, USER_ROLE_CS)
                        : getUsersByRoleName(USER_ROLE_CS);
            for(SFA2_User_Sales_Roster_gne__c csSalesRoster : csSalesRosters) {
                if(csSalesRoster.User_gne__r.ManagerId == userId) {
                    childUserIds.add(csSalesRoster.User_gne__c);
                    cacheUsersHierarchy(csSalesRoster.User_gne__c, USER_ROLE_CS, brandName);
                }
            }
        } else if(userRoleName==USER_ROLE_CS) {
            // Cache only the manager
            userManagersCache.put(userId, getSalesRosterForUser(userId).User_gne__r.ManagerId);
        }
    }

    public static Boolean checkIsUserCS(Id userId){
        return checkUserRole(userId, USER_ROLE_CS);
    }

    public static Boolean checkIsUserDM(Id userId){
        return checkUserRole(userId, USER_ROLE_DM);
    }

    public static Boolean checkIsUserRM(Id userId){
        return checkUserRole(userId, USER_ROLE_RM);
    }

    public static Boolean checkIsUserBrandManager(Id userId){
        return checkIsUserRM(userId) || checkIsUserDM(userId);
    }

    public static Boolean checkIsUserManager(Id userId){
        return checkUserRole(userId, USER_ROLE_MANAGER);
    }

    public static Boolean checkUserRole(Id userId, String roleName) {
        SFA2_User_Sales_Roster_gne__c userRoster = getSalesRosterForUser(userId);
        return userRoster!=null && userRoster.Role_gne__c == roleName;
    }

    public static Boolean checkIsUserLOA(Id userId) {
        SFA2_User_Sales_Roster_gne__c userRoster = getSalesRosterForUser(userId);
        User u = userRoster!=null ? userRoster.User_gne__r : null;

        return u!=null && u.Is_User_On_LOA_Calc_gne__c;
    }

    public static Boolean checkIsUserLOAOnDate(Id userId, Date dt) {
        SFA2_User_Sales_Roster_gne__c userRoster = getSalesRosterForUser(userId);
        User u = userRoster!=null ? userRoster.User_gne__r : null;

        return u!=null &&
        	(u.LOA_HO_Override_Flag_gne__c == USER_LOA_HO_OVERRIDE_FLAG_TRUE ||
        	 (u.LOA_HO_Override_Flag_gne__c != USER_LOA_HO_OVERRIDE_FLAG_FALSE &&
        	  u.LOA_Start_Date_gne__c != null && u.LOA_End_Date_gne__c != null && dt != null &&
        	  u.LOA_Start_Date_gne__c <= dt && u.LOA_End_Date_gne__c >= dt));
    }

    public static String getUserLOAHoOverrideFlag(Id userId) {
    	SFA2_User_Sales_Roster_gne__c userRoster = getSalesRosterForUser(userId);
        User u = userRoster!=null ? userRoster.User_gne__r : null;
    	return (u!=null && u.LOA_HO_Override_Flag_gne__c!=null) ? u.LOA_HO_Override_Flag_gne__c : USER_LOA_HO_OVERRIDE_FLAG_NA;
    }

    public static Boolean checkIsUserCertified(Id userId) {
        SFA2_User_Sales_Roster_gne__c userRoster = getSalesRosterForUser(userId);
        User u = userRoster!=null ? userRoster.User_gne__r : null;

        return u==null || !u.PFG_Uncertified_Flag_gne__c;
    }

    public static Id getManagerForUser(Id userId) {
        return getManagerForUser(userId, false);
    }

    public static Id getManagerForUser(Id userId, Boolean useTerritoryHierachy) {
        cacheSalesRosters();
        Id result = null;

        // Works only for CS users
        if(checkIsUserCS(userId)) {
            if(!useTerritoryHierachy) {
                if(userManagersCache==null || !userManagersCache.containsKey(userId)) {
                    cacheUsersHierarchy(userId);
                }
                result = userManagersCache.get(userId);
            } else {
                for(Territory2 terr : getTerritoriesForUser(userId)) {
                    for(Id dmId : getUsersForTeritory(getParentTerritory(terr.Id).Id)) {
                        if(checkIsUserDM(dmId)) {
                            result = dmId;
                        }
                    }
                    if(result!=null) {
                        break;
                    }
                }
            }
        }

        return result;
    }

    public static List<Id> getSubordinatesForManager(Id managerId) {
        List<Id> result = new List<Id>();

        // Works only for DMs
        if(checkIsUserDM(managerId)) {
            if(usersHierarchyCache==null || !usersHierarchyCache.containsKey(managerId)) {
                cacheUsersHierarchy(managerId);
            }

            result = usersHierarchyCache.get(managerId);
        }

        return result;
    }

    public static Set<Id> getSubordinateCSs(Id userId) {
        Set<Id> userIds = new Set<Id>();

        // populate available users depending on current user role.
        if(checkIsUserCS(userId)) { // CS
            userIds.add(userId);
        } else if(checkIsUserDM(userId)) { // DM
            userIds = new Set<Id>(GNE_SFA2_PFG_Util.getSubordinatesForManager(userId));
        } else if(checkIsUserManager(userId)) { // Home Office
            for(SFA2_User_Sales_Roster_gne__c sRoster : getUsersByRoleName(GNE_SFA2_PFG_Util.USER_ROLE_CS)) {
                userIds.add(sRoster.User_gne__c);
            }
        }

        return userIds;
    }

    public static Set<Id> getSubordinateDMs(Id userId) {
        Set<Id> userIds = new Set<Id>();

        // populate available users depending on current user role.
        if(checkIsUserDM(userId)) { // DM
            userIds.add(userId);
        } else if(checkIsUserManager(userId)) { // Home Office
            for(SFA2_User_Sales_Roster_gne__c sRoster : getUsersByRoleName(GNE_SFA2_PFG_Util.USER_ROLE_DM)) {
                userIds.add(sRoster.User_gne__c);
            }
        }

        return userIds;
    }

    //methods for PFG Eligibility Flag operations
    public static List<SFA2_PFG_to_Account_Detail_gne__c> getAllAccountDetails (Set<Id> accountsIds){
        List<SFA2_PFG_to_Account_Detail_gne__c> tmpPfgToAccountDetails = new List<SFA2_PFG_to_Account_Detail_gne__c>();
        tmpPfgToAccountDetails = [Select Account_gne__c from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c IN : accountsIds];
        return tmpPfgToAccountDetails;
    }
    public static Map<Account, List<SFA2_PFG_to_Account_Detail_gne__c>> getAccountDetailsPerAccount(List<SFA2_PFG_to_Account_Detail_gne__c> pfgAccountDetails){
        Map<Account, List<SFA2_PFG_to_Account_Detail_gne__c>> accountDetailsPerAccount = new Map<Account, List<SFA2_PFG_to_Account_Detail_gne__c>>();
        for(SFA2_PFG_to_Account_Detail_gne__c accDet : pfgAccountDetails){
            if(accountDetailsPerAccount.containsKey(accDet.Account_gne__r)){
                accountDetailsPerAccount.get(accDet.Account_gne__r).add(accDet);
            }
            else{
                List<SFA2_PFG_to_Account_Detail_gne__c> tmpAccDets = new List<SFA2_PFG_to_Account_Detail_gne__c>();
                tmpAccDets.add(accDet);
                accountDetailsPerAccount.put(accDet.Account_gne__r, tmpAccDets);
            }
        }
        return accountDetailsPerAccount;
    }
    public static Map<Account, Integer> getCountFreezedDetailsPerAccount(Map<Account, List<SFA2_PFG_to_Account_Detail_gne__c>> accountDetailsPerAccount){
        Map<Account, Integer> countFreezedDetailsPerAccount = new Map<Account, Integer>();
        Integer baseCount = 0;
        for(Account acc : accountDetailsPerAccount.keySet()){
            for(SFA2_PFG_to_Account_Detail_gne__c detail : accountDetailsPerAccount.get(acc)){
                if(countFreezedDetailsPerAccount.containsKey(acc)){
                    if(detail.Freeze_for_Pending_AOC_gne__c != 'No'){
                        Integer currentCount = countFreezedDetailsPerAccount.get(acc);
                        currentCount++;
                        countFreezedDetailsPerAccount.remove(acc);
                        countFreezedDetailsPerAccount.put(acc, currentCount);
                    }
                }
                else{
                    if(detail.Freeze_for_Pending_AOC_gne__c != 'No'){
                        Integer currentCount = baseCount + 1;
                        countFreezedDetailsPerAccount.put(acc, currentCount);
                    }
                    else{
                        countFreezedDetailsPerAccount.put(acc, baseCount);
                    }
                }
            }
        }
        return countFreezedDetailsPerAccount;
    }
    public static Set<Id> getAccountsIds (List<SFA2_PFG_to_Account_Detail_gne__c> pfgAccDetails){
        Set<Id> accIds = new Set<Id>();
        for(SFA2_PFG_to_Account_Detail_gne__c accDet : pfgAccDetails){
            accIds.add(accDet.Account_gne__c);
        }
        return accIds;
    }
    public static Set<Id> getAccountsIds (List<Address_vod__c> addresses){
        Set<Id> accIds = new Set<Id>();
        for(Address_vod__c address : addresses){
            accIds.add(address.Account_vod__c);
        }
        return accIds;
    }
    public static List<Address_vod__c> getAddressesForAccount(List<Account> accounts){
        List<Address_vod__c> addresses = GNE_SFA2_PFG_DAO.getAccountsAddresses(accounts);
        return addresses;
    }

    public static void cacheOverdueSignatureTransactions(List<SFA2_PFG_Transaction_gne__c> triggeredTransactions){
        system.debug('triggeredTransactions=' +triggeredTransactions);
        if(pfgOverdueSignatureTransactions != null){
            return;
        }
        Set<Id> accountIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for(SFA2_PFG_Transaction_gne__c trans : triggeredTransactions){
            accountIds.add(trans.Account_gne__c);
            productIds.add(trans.Product_gne__c);
        }
        system.debug('accountIds= '+accountIds);
        system.debug('productIds= '+productIds);
        cacheOverdueSignatureTransactions(accountIds, productIds);
    }
    public static void cacheOverdueSignatureTransactions(Set<Id> accountsIds, Set<Id> productsIds){
        if(pfgOverdueSignatureTransactions != null){
            return;
        }
        for(SFA2_PFG_Transaction_gne__c pfgTrans : GNE_SFA2_PFG_DAO.getOverdueSignatureTransactions(accountsIds, productsIds)){
            system.debug('pfgTrans= '+pfgTrans);
            String extId = pfgTrans.Account_gne__c + '_' + pfgTrans.Product_gne__c;
            pfgOverdueSignatureTransactions = new Map<String, List<SFA2_PFG_Transaction_gne__c>>();
            if(pfgOverdueSignatureTransactions.containsKey(extId)){
                pfgOverdueSignatureTransactions.get(extId).add(pfgTrans);
            }
            else{
                List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
                transactions.add(pfgTrans);
                pfgOverdueSignatureTransactions.put(extId,transactions);
            }

        }
    }
    public static List<SFA2_PFG_Transaction_gne__c> getOverdueSignatureTransactions(Id accountId, Id productId) {
        List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();

        if(pfgOverdueSignatureTransactions!=null) {
            String extId = accountId + '_' + productId;
            transactions = pfgOverdueSignatureTransactions.get(extId);
        }
        return transactions;
    }
    public static List<SFA2_PFG_to_Account_Detail_gne__c> getFreezedAccDetails (List<SFA2_PFG_to_Account_Detail_gne__c> accDetails){
        List<SFA2_PFG_to_Account_Detail_gne__c> freezedAccountDetails = new List<SFA2_PFG_to_Account_Detail_gne__c>();
        for(SFA2_PFG_to_Account_Detail_gne__c accDet: accDetails){
            if(accDet.Freeze_for_Pending_AOC_gne__c != 'No'){
                freezedAccountDetails.add(accDet);
            }
        }
        return freezedAccountDetails;
    }
    public static List<SFA2_PFG_to_Account_Detail_gne__c> getNotFreezedAccDetails (List<SFA2_PFG_to_Account_Detail_gne__c> accDetails){
        List<SFA2_PFG_to_Account_Detail_gne__c> notFreezedAccountDetails = new List<SFA2_PFG_to_Account_Detail_gne__c>();
        for(SFA2_PFG_to_Account_Detail_gne__c accDet: accDetails){
            if(accDet.Freeze_for_Pending_AOC_gne__c == 'No'){
                notFreezedAccountDetails.add(accDet);
            }
        }
        return notFreezedAccountDetails;
    }
    public static List<Address_vod__c> getInvalidAddresses (List<Address_vod__c> addresses){
        List<Address_vod__c> invalidAddresses = new List<Address_vod__c>();
        for(Address_vod__c address : addresses){
            if(address.Sample_Status_vod__c != 'Valid'){
                invalidAddresses.add(address);
            }
        }
        return invalidAddresses;
    }
    public static List<Address_vod__c> getValidAddresses (List<Address_vod__c> addresses){
        List<Address_vod__c> validAddresses = new List<Address_vod__c>();
        for(Address_vod__c address : addresses){
            if(address.Sample_Status_vod__c == 'Valid'){
                validAddresses.add(address);
            }
        }
        return validAddresses;
    }

    public static void approveOrRejectStorageLocations(Id approverId, Set<Id> slIds, Boolean approveOrReject) {
        approveOrRejectStorageLocations(approverId, slIds, approveOrReject, null);
    }

    public static void approveOrRejectStorageLocations(Id approverId, Set<Id> slIds, Boolean approveOrReject, String comment) {
        cacheStorageLocations(slIds, false);

        String actionStatus = approveOrReject ? STORAGE_LOCATION_APPROVED_ACTION : STORAGE_LOCATION_REJECTED_ACTION;
        String actionComment = comment!=null ? comment : (approveOrReject ? STORAGE_LOCATION_APPROVED_COMMENT : STORAGE_LOCATION_REJECTED_COMMENT);

        Map<Id,Id> slToWorkItemIdMap = new Map<Id,Id>();
        // Get Approval Process Work Items
        for(ProcessInstanceWorkItem pwi
                : [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem
                   WHERE ProcessInstanceId IN (SELECT ID FROM ProcessInstance
                                               WHERE Status = :APPROVAL_STATUS_PENDING
                                                AND TargetObjectId IN :slIds)]) {
            slToWorkItemIdMap.put(pwi.ProcessInstance.TargetObjectId, pwi.Id);
        }

        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

        for(Id slId : slIds) {
            // Instantiate the new ProcessWorkitemRequest object and populate it
            SFA2_PFG_Storage_Location_gne__c sl = storageLocationCache.get(slId);
            if(sl!=null && slToWorkItemIdMap.containsKey(slId)) {
                Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
                approvalReq.setComments(actionComment);
                approvalReq.setAction(actionStatus);
                approvalReq.setNextApproverIds(new Id[] {approverId});
                // Use the ID from the newly created item to specify the item to be worked
                approvalReq.setWorkitemId(slToWorkItemIdMap.get(slId));
                requests.add(approvalReq);
            }
        }

        if(!requests.isEmpty()) {
            // Submit the requests for approval
            Approval.process(requests);
        }
    }

    public static Map<Id,SFA2_PFG_Storage_Location_gne__c> cacheStorageLocations(Set<Id> slIds, Boolean forceReload) {
        if(forceReload==true || storageLocationCache==null) {
            cacheStorageLocations(GNE_SFA2_PFG_DAO.getStorageLocations(slIds),forceReload);
        }

        return storageLocationCache;
    }

    public static Map<Id,SFA2_PFG_Storage_Location_gne__c> cacheStorageLocations(List<SFA2_PFG_Transaction_gne__c> trns, Boolean forceReload) {
        if(forceReload==true || storageLocationCache==null) {
            Set<Id> userIds = new Set<Id>();
            for(SFA2_PFG_Transaction_gne__c trn : trns) {
                if(trn.From_User_gne__c!=null) {
                    userIds.add(trn.From_User_gne__c);
                }

                userIds.add(trn.To_User_gne__c);
            }

            cacheStorageLocations(GNE_SFA2_PFG_DAO.getStorageLocationsByUserIds(userIds),forceReload);
        }

        return storageLocationCache;
    }

    public static Map<Id,SFA2_PFG_Storage_Location_gne__c> cacheStorageLocationsByUserIds(Set<Id> userIds, Boolean forceReload) {
        if(forceReload==true || storageLocationCache==null) {
            cacheStorageLocations(GNE_SFA2_PFG_DAO.getStorageLocationsByUserIds(userIds),forceReload);
        }

        return storageLocationCache;
    }

    public static Map<Id,SFA2_PFG_Storage_Location_gne__c> cacheStorageLocations(List<SFA2_PFG_Storage_Location_gne__c> sls, Boolean forceReload) {
        if(forceReload==true || storageLocationCache==null) {
            storageLocationCache = new Map<Id,SFA2_PFG_Storage_Location_gne__c>(sls);
            storageLocationByUserIdCache = new Map<Id,List<SFA2_PFG_Storage_Location_gne__c>>();

            for(SFA2_PFG_Storage_Location_gne__c sl : sls) {
                if(!storageLocationByUserIdCache.containsKey(sl.User_gne__c)) {
                    storageLocationByUserIdCache.put(sl.User_gne__c, new List<SFA2_PFG_Storage_Location_gne__c>());
                }

                storageLocationByUserIdCache.get(sl.User_gne__c).add(sl);
            }
        }

        return storageLocationCache;
    }

    public static List<SFA2_PFG_Storage_Location_gne__c> getStorageLocationsForUser(Id userId) {
        return storageLocationByUserIdCache.containsKey(userId) ? storageLocationByUserIdCache.get(userId)
                                                                : new List<SFA2_PFG_Storage_Location_gne__c>();
    }

    public static SFA2_PFG_Storage_Location_gne__c getApprovedStorageLocationForUser(Id userId) {
        SFA2_PFG_Storage_Location_gne__c approvedSL = null;

        for(SFA2_PFG_Storage_Location_gne__c sl : getStorageLocationsForUser(userId)) {
            if(sl.Status_gne__c == STORAGE_LOCATION_STATUS_APPROVED) {
                approvedSL = sl;
                break;
            }
        }
        system.debug('approvedSL='+approvedSL);
        return approvedSL;
    }

    //Account Limit Exceptions methods
    public static void cacheAccLimitExceptions(List<SFA2_PFG_Transaction_gne__c> transactions) {
        List<Id> accIds = new List<Id>();
        List<Id> productIds = new List<Id>();
        List<String> limitYears = new List<String>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            if(String.isNotBlank(trans.Account_gne__c) && String.isNotBlank(trans.Product_gne__c)){
                accIds.add(trans.Account_gne__c);
                productIds.add(trans.Product_gne__c);
                limitYears.add(String.valueOf(trans.Transaction_Date_gne__c.year()));
            }
        }

        cacheAccLimitExceptions(accIds, productIds, limitYears);
    }

    public static void cacheAccLimitExceptions(List<Call_PFG_Detail_gne__c> cDetails, String limitYear) {
        List<Id> accIds = new List<Id>();
        List<Id> productIds = new List<Id>();

        for(Call_PFG_Detail_gne__c cDetail : cDetails) {
            if(String.isNotBlank(cDetail.Account_gne__c) && String.isNotBlank(cDetail.Product_gne__c)) {
                accIds.add(cDetail.Account_gne__c);
                productIds.add(cDetail.Product_gne__c);
            }
        }

        cacheAccLimitExceptions(accIds, productIds, new List<String>{limitYear});
    }

    public static void cacheAccLimitExceptions(List<Id> accIds, List<Id> productIds, String limitYear) {
    	cacheAccLimitExceptions(accIds, productIds, new List<String>{limitYear});
    }

    public static void cacheAccLimitExceptions(List<Id> accIds, List<Id> productIds, List<String> limitYears) {
        if(pfgAccLimitExceptionsCache == null) {
            pfgAccLimitExceptionsCache = new Map<String,PFG_Staging_Account_Limit_Exception_gne__c>();
        }

        Set<String> existingKeys = pfgAccLimitExceptionsCache.keySet();

        Set<String> newKeys = new Set<String>();
        Integer idx = 0, yearsSize = limitYears.size();

        for(Id prodId : productIds) {
            newKeys.add(accIds[idx] + '_' + prodId + '_' +  (idx>=yearsSize ? limitYears[0] : limitYears[idx]));
        	idx++;
        }

        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,PFG_Staging_Account_Limit_Exception_gne__c> newAccExceptions = new Map<String,PFG_Staging_Account_Limit_Exception_gne__c>();

            for(PFG_Staging_Account_Limit_Exception_gne__c accExc : GNE_SFA2_PFG_DAO.getAccountExceptionLimit(
            		new Set<Id>(accIds), new Set<Id>(productIds), new Set<String>(limitYears))) {
                String extId = getRecordKey(accExc);
                newAccExceptions.put(extId,accExc);
            }

            for(String key : newKeys) {
                pfgAccLimitExceptionsCache.put(key,newAccExceptions.get(key));
            }
        }
    }

    public static PFG_Staging_Account_Limit_Exception_gne__c getAccLimitException(SFA2_PFG_Transaction_gne__c trx) {
    	return getAccLimitException(trx.Account_gne__c, trx.Product_gne__c, String.valueOf(trx.Transaction_Date_gne__c.year()));
    }

    public static PFG_Staging_Account_Limit_Exception_gne__c getAccLimitException(Id accId, Id productId, String limitYear) {
        PFG_Staging_Account_Limit_Exception_gne__c accExc = null;
        if(pfgAccLimitExceptionsCache != null) {
            String extId = accId + '_' + productId + '_' +  limitYear;
            accExc = pfgAccLimitExceptionsCache.get(extId);
        }
        return accExc;
    }
    //Product Limit Methods
    public static void cacheProductLimits(List<SFA2_PFG_Transaction_gne__c> transactions) {
        List<Id> productIds = new List<Id>();
        List<String> limitYears = new List<String>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions){
            if(String.isNotBlank(trans.Product_gne__c)){
                productIds.add(trans.Product_gne__c);
                limitYears.add(String.valueOf(trans.Transaction_Date_gne__c.year()));
            }
        }

        cacheProductLimits(productIds, limitYears);
    }

    public static void cacheProductLimits(List<Call_PFG_Detail_gne__c> cDetails, String limitYear) {
        List<Id> productIds = new List<Id>();

        for(Call_PFG_Detail_gne__c cDetail : cDetails) {
            if(String.isNotBlank(cDetail.Product_gne__c)) {
                productIds.add(cDetail.Product_gne__c);
            }
        }

        cacheProductLimits(productIds, new List<String>{limitYear});
    }

    public static void cacheProductLimits(Set<Id> productIds, String limitYear) {
    	cacheProductLimits(new List<Id>(productIds), new List<String>{limitYear});
    }

    public static void cacheProductLimits(List<Id> productIds, List<String> limitYears) {
        if(pfgProductsLimitsCache == null) {
            pfgProductsLimitsCache = new Map<String,SFA2_PFG_Product_Limit_gne__c>();
        }

        Set<String> existingKeys = pfgProductsLimitsCache.keySet();

        Set<String> newKeys = new Set<String>();
        Integer idx = 0, yearsSize = limitYears.size();

        for(Id prodId : productIds) {
            newKeys.add(prodId + '_' +  (idx>=yearsSize ? limitYears[0] : limitYears[idx]));
        	idx++;
        }

        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,SFA2_PFG_Product_Limit_gne__c> newProdLmts = new Map<String,SFA2_PFG_Product_Limit_gne__c>();

            for(SFA2_PFG_Product_Limit_gne__c prodLmt : GNE_SFA2_PFG_DAO.getProductLimit(
            		new Set<Id>(productIds), new Set<String>(limitYears))) {
                String extId = getRecordKey(prodLmt);
                newProdLmts.put(extId,prodLmt);
            }

            for(String key : newKeys) {
                pfgProductsLimitsCache.put(key,newProdLmts.get(key));
            }
        }
    }

    public static SFA2_PFG_Product_Limit_gne__c getProductLimit(SFA2_PFG_Transaction_gne__c trx) {
    	return getProductLimit(trx.Product_gne__c, String.valueOf(trx.Transaction_Date_gne__c.year()));
    }

    public static SFA2_PFG_Product_Limit_gne__c getProductLimit(Id productId, String limitYear) {
        SFA2_PFG_Product_Limit_gne__c prodLmt = null;
        if(pfgProductsLimitsCache != null) {
            String extId = productId + '_' +  limitYear;
            prodLmt = pfgProductsLimitsCache.get(extId);
        }
        return prodLmt;
    }
    public static List<sObject> compareAndReturnDiff (Map<Id, sObject> triggerOldMap, Map<Id, sObject> triggerNewMap, List<String> compareFields){
        List<sObject> diffList = new List<sObject>();
        for(Id key : triggerNewMap.keySet()){
            Integer diffCount = 0;
            for(String field : compareFields){
                if(triggerNewMap.get(key).get(field) != triggerOldMap.get(key).get(field)){
                    diffCount++;
                }
            }
            if(diffCount > 0){
                diffList.add(triggerNewMap.get(key));
            }
        }
        return diffList;
    }

    private static void cacheVendors() {
        if(vendorsByIdCache==null) {
            vendorsByIdCache = new Map<Id,Vendor_gne__c>();
            vendorsByNameCache = new Map<String,Vendor_gne__c>();
            brandToVendorsCache = new Map<String,Set<String>>();
            vendorToBrandsCache = new Map<String,Set<String>>();

            cachePfgProducts();

            Set<Id> brandIds = new Set<Id>();
            for(Product_vod__c prod : pfgProductsCache.values()) {
                if(prod.Parent_Product_vod__c!=null) {
                    brandIds.add(prod.Parent_Product_vod__c);
                }
            }

            for(Vendor_gne__c vendor : GNE_SFA2_PFG_DAO.getVendorsForBrands(brandIds, true, true)) {
                String vName = vendor.Vendor_Name_gne__c;
                vendorsByNameCache.put(vName, vendor);
                vendorsByIdCache.put(vendor.Id, vendor);
                Set<String> brands = new Set<String>();
                vendorToBrandsCache.put(vName, brands);

                for(BrandVendor_gne__c bv : vendor.BrandVendors__r) {
                    String bName = bv.Brand_gne__r.Name;
                    brands.add(bName);

                    if(!brandToVendorsCache.containsKey(bName)) {
                        brandToVendorsCache.put(bName,new Set<String>());
                    }

                    brandToVendorsCache.get(bName).add(vName);
                }
            }
        }
    }

    public static Set<String> getVendorNamesForProduct(Id prodId) {
        cacheVendors();
        Set<String> result = new Set<String>();

        Product_vod__c prod = getPfgProduct(prodId);
        String brandName = (prod!=null && prod.Parent_Product_vod__c!=null) ? prod.Parent_Product_vod__r.Name : null;

        if(brandName!=null && brandToVendorsCache.containsKey(brandName)) {
            result.addAll(brandToVendorsCache.get(brandName));
        }

        return result;
    }

    public static Vendor_gne__c getVendorForProduct(Id prodId) {
        cacheVendors();
        Vendor_gne__c result = null;

        Product_vod__c prod = getPfgProduct(prodId);
        String brandName = (prod!=null && prod.Parent_Product_vod__c!=null) ? prod.Parent_Product_vod__r.Name : null;

        if(brandName!=null && brandToVendorsCache.containsKey(brandName)) {
            for(String vName : brandToVendorsCache.get(brandName)) {
                result = vendorsByNameCache.get(vName);
                break;
            }
        }

        return result;
    }

    public static List<Vendor_gne__c> getVendorsForProducts(Set<Id> prodIds) {
        cacheVendors();
        List<Vendor_gne__c> result = new List<Vendor_gne__c>();

        for(Id prodId : prodIds) {
            for(String vName : getVendorNamesForProduct(prodId)) {
                result.add(vendorsByNameCache.get(vName));
            }
        }

        return result;
    }

    public static Vendor_gne__c getVendorById(Id vendorId) {
        cacheVendors();
        return vendorsByIdCache.get(vendorId);
    }

    public static Set<String> getBrandsForVendor(String vendorName) {
        cacheVendors();
        return vendorToBrandsCache.containsKey(vendorName) ? vendorToBrandsCache.get(vendorName) : new Set<String>();
    }

    public static Set<String> getVendorNamesForBrand(String brandName) {
        cacheVendors();
        return brandToVendorsCache.containsKey(brandName) ? brandToVendorsCache.get(brandName) : new Set<String>();
    }

    public static String getEmailForVendor(String vendorName) {
        return GNE_SFA2_PFG_Config.VENDOR_EMAIL_MAP.containsKey(vendorName) ? GNE_SFA2_PFG_Config.VENDOR_EMAIL_MAP.get(vendorName) : null;
    }

    public static Boolean populateTransactionAddressFromUser(SFA2_PFG_Transaction_gne__c trx, Id userId) {
        return populateTransactionAddressFromUser(trx, userId, true);
    }

    public static Boolean populateTransactionAddressFromUser(SFA2_PFG_Transaction_gne__c trx, Id userId, Boolean forceCacheRefresh) {
        if(forceCacheRefresh && (storageLocationByUserIdCache==null || !storageLocationByUserIdCache.containsKey(userId))) {
            cacheStorageLocations(GNE_SFA2_PFG_DAO.getStorageLocationsByUserIds(new Set<Id>{userId}), true);
        }

        SFA2_PFG_Storage_Location_gne__c sl = GNE_SFA2_PFG_Util.getApprovedStorageLocationForUser(userId);
        system.debug('sl='+sl);
        if(sl!=null) {
            trx.Address_Line_1_gne__c = sl.Address_Line_1_gne__c;
            trx.Address_Line_2_gne__c = sl.Address_Line_2_gne__c;
            trx.City_gne__c = sl.City_gne__c;
            trx.State_gne__c = sl.State_gne__c;
            trx.Zip_gne__c = sl.Zip_gne__c;
            system.debug('trx='+trx);
        }

        return sl!=null;
    }

    public static List<SFA2_PFG_Transaction_gne__c> getCallDetailTransactionsForUsers(Set<Id> userIds, Set<String> trxTypes) {
        return GNE_SFA2_PFG_DAO.getTransactions(
            trxTypes,
            null,
            new List<GNE_SFA2_PFG_DAO.WhereStatementWrapper>{
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('Call_PFG_Detail_ID_gne__c != null',null,null),
                new GNE_SFA2_PFG_DAO.WhereStatementWrapper('From_User_gne__c', 'IN', userIds)
            },
            null);
    }

    public static void approveOrders(Set<Id> trxIds) {
        List<SFA2_PFG_Transaction_gne__c> trxToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
        Id currentUser = UserInfo.getUserId();

        for(Id trxId : trxIds) {
            trxToUpdate.add(new SFA2_PFG_Transaction_gne__c(
                Id = trxId,
                From_User_gne__c = currentUser,
                Generate_Shipment_Flag__c = TRANSACTION_SHIPMENT_INITIATED,
                Status_gne__c = TRANSACTION_STATUS_APPROVED,
                Shipment_Request_Date_gne__c = System.today()));
        }

        if(!trxToUpdate.isEmpty()) {
            update trxToUpdate;
        }
    }

    public static Id getTransactionRecordTypeId(String recTypeName) {
        if(transactionNameToRecTypeIdCache==null) {
            cacheTransactionRecordTypes();
        }
        return transactionNameToRecTypeIdCache.get(recTypeName);
    }

    public static String getTransactionRecordTypeName(Id recTypeId) {
        if(transactionRecTypeIdToNameCache==null) {
            cacheTransactionRecordTypes();
        }
        return transactionRecTypeIdToNameCache.get(recTypeId);
    }

    private static void cacheTransactionRecordTypes() {
        transactionRecTypeIdToNameCache = new Map<Id,String>();
        transactionNameToRecTypeIdCache = new Map<String,Id>();

        List<Schema.RecordTypeInfo> rtInfos = SFA2_PFG_Transaction_gne__c.getSobjectType().getDescribe().getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            Id rtId = rtInfo.getRecordTypeId();
            String rtName = rtInfo.getName();
            transactionRecTypeIdToNameCache.put(rtId, rtName);
            transactionNameToRecTypeIdCache.put(rtName, rtId);
        }
    }

    public static List<SFA2_PFG_Inventory_Count_gne__c> saveInventoryCounts(List<SFA2_PFG_Inventory_Count_gne__c> invCountsList) {
        return saveInventoryCounts(invCountsList, null);
    }

    public static List<SFA2_PFG_Inventory_Count_gne__c> saveInventoryCounts(List<SFA2_PFG_Inventory_Count_gne__c> invCountsList, String invRefNo) {
        if(invCountsList!=null && !invCountsList.isEmpty()){
            // Standard Insert Inv Count operation
            System.Savepoint sp = Database.setSavepoint();
            Boolean isOk = false;
            try {
                insert invCountsList;

                if(invRefNo==null) {
                    // Now generate Inventory Ref No.
                    String lastName = GNE_SFA2_PFG_DAO.getInventoryCountName(invCountsList.get(invCountsList.size()-1).Id)[0].Name;
                    invRefNo = 'PFGIRN-' + lastName.substringAfter('-');
                }
                for(SFA2_PFG_Inventory_Count_gne__c invC : invCountsList) {
                    invC.Inventory_Ref_Number_gne__c = invRefNo;
                }

                // standard update
                update invCountsList;
                isOk = true;
            } finally {
                if(!isOk) {
                    Database.rollback(sp);
                }
            }
        }

        return invCountsList;
    }

    public static void cachePfgToTerritoryDetails(List<SFA2_PFG_Transaction_gne__c> transactions) {

        List<String> terrNames = new List<String>();
        List<Id> productIds = new List<Id>();
        List<Integer> years = new List<Integer>();

        for(SFA2_PFG_Transaction_gne__c trans : transactions) {
        	if(String.isNotBlank(trans.Product_gne__c) && isProductDtp(trans.Product_gne__c)) {
            	if(String.isNotBlank(trans.To_Territory_Name_gne__c)){
                	terrNames.add(trans.To_Territory_Name_gne__c);
                	productIds.add(trans.Product_gne__c);
                	years.add(getYear(trans));
            	}

	            if(String.isNotBlank(trans.From_Territory_Name_gne__c)) {
	            	terrNames.add(trans.From_Territory_Name_gne__c);
	                productIds.add(trans.Product_gne__c);
	                years.add(getYear(trans));
	            }
        	}
        }

        cachePfgToTerritoryDetails(terrNames, productIds, years);
    }

    public static void cachePfgToTerritoryDetails(List<Call_PFG_Detail_gne__c> cDetails) {
        cachePfgToTerritoryDetails(cDetails, null, null);
    }

    public static void cachePfgToTerritoryDetails(List<Call_PFG_Detail_gne__c> cDetails, Id userId) {
    	cachePfgToTerritoryDetails(cDetails, userId, null);
    }

    public static void cachePfgToTerritoryDetails(List<Call_PFG_Detail_gne__c> cDetails, Id userId, Integer year) {
        List<String> terrNames = new List<String>();
        List<Id> productIds = new List<Id>();
        List<Integer> years = new List<Integer>();

        for(Call_PFG_Detail_gne__c cDetail : cDetails) {
            if(String.isNotBlank(cDetail.Product_gne__c) && isProductDtp(cDetail.Product_gne__c)) {
            	for(Territory2 terr : getTerritoriesForUser(userId!=null ? userId : cDetail.Owner_calc_gne__c)) {
                	terrNames.add(terr.Name);
                	productIds.add(cDetail.Product_gne__c);
                	years.add(year!=null ? year : getYear(cDetail));
            	}
            }
        }

        cachePfgToTerritoryDetails(terrNames, productIds, years);
    }

    public static void cachePfgToTerritoryDetails(List<String> terrNames, List<Id> productIds, List<Integer> years) {
        if(pfgToTerritoryDetailsCache == null) {
            pfgToTerritoryDetailsCache = new Map<String,SFA2_PFG_to_Territory_Detail_gne__c>();
        }

        Set<String> existingKeys = pfgToTerritoryDetailsCache.keySet();

        Set<String> newKeys = new Set<String>();

        Integer idx = 0;
        Boolean isSingleProduct = productIds.size()==1;
        Boolean isSingleYear = years.size()==1;
        for(String terrName : terrNames) {
            newKeys.add(terrName + '_' + (isSingleProduct ? productIds[0] : productIds[idx]) + '_' + (isSingleYear ? years[0] : years[idx]));
            idx++;
        }

        newKeys.removeAll(existingKeys);

        if(!newKeys.isEmpty()) {
            Map<String,SFA2_PFG_to_Territory_Detail_gne__c> newTerrDetails = new Map<String,SFA2_PFG_to_Territory_Detail_gne__c>();

            for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : GNE_SFA2_PFG_DAO.getPFGtoTerritoryDetailsByTerritoryAndProduct(
            		new Set<String>(terrNames), new Set<Id>(productIds), new Set<Integer>(years))) {
                String extId = getRecordKey(tDetail);
                newTerrDetails.put(extId,tDetail);
            }

            for(String key : newKeys) {
                pfgToTerritoryDetailsCache.put(key,newTerrDetails.get(key));
            }
        }
    }

    public static void addPfgToTerritoryDetailToCache(SFA2_PFG_to_Territory_Detail_gne__c tDetail) {
        String extId = getRecordKey(tDetail);
        pfgToTerritoryDetailsCache.put(extId,tDetail);
    }

    public static SFA2_PFG_to_Territory_Detail_gne__c getPfgToTerritoryDetail(String terrName, Id productId, Integer year) {
        SFA2_PFG_to_Territory_Detail_gne__c tDetail = null;
        if(pfgToTerritoryDetailsCache != null){
            String extId = terrName + '_' + productId + '_' + year;
            tDetail = pfgToTerritoryDetailsCache.get(extId);
        }
        return tDetail;
    }

    public static void clearPfgToTerritoryCache() {
        pfgToTerritoryDetailsCache = null;
    }

    public static Boolean validateTransactionQuantity(SFA2_PFG_Transaction_gne__c trx, List<Integer> minAndMaxValues, Boolean isInsert) {
        Boolean isValid = true;
        String trxType = getTransactionRecordTypeName(trx.RecordTypeId);

        if(isInsert==true) { // Insert mode
            Integer qty = trx.Requested_Quantity_gne__c != null ? trx.Requested_Quantity_gne__c.intValue() : 0;

            if((trxType == TRANSACTION_RECORD_TYPE_TRANSFER || trxType == TRANSACTION_RECORD_TYPE_RETURN) &&
              String.isNotBlank(trx.From_User_gne__c) && String.isNotBlank(trx.Product_gne__c) && String.isNotBlank(trx.Lot_No_gne__c)) {

                SFA2_PFG_to_User_Detail_gne__c uDetail = getPfgToUserDetail(trx.From_User_gne__c, trx.Product_gne__c, trx.Lot_No_gne__c);

                if(!(isValid = (qty > 0 && uDetail != null && uDetail.Qty_Total_Available_gne__c >= qty))) {
                    minAndMaxValues[0] = 1;
                    minAndMaxValues[1] = ((uDetail!=null && uDetail.Qty_Total_Available_gne__c!=null) ? uDetail.Qty_Total_Available_gne__c.intValue() : 0);
                }
            } else if(trxType == TRANSACTION_RECORD_TYPE_ORDER && String.isNotBlank(trx.To_User_gne__c) && String.isNotBlank(trx.Product_gne__c)) {
                if(!(isValid = (qty > 0))) {
                    minAndMaxValues[0] = 1;
                }
            } else if((trxType == TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER || trxType == TRANSACTION_RECORD_TYPE_RFF || trxType == TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER) &&
                      trx.Distribution_Method_gne__c == TRANSACTION_DISCTRIBUTION_METHOD_DTP &&
                      String.isNotBlank(trx.From_Territory_Name_gne__c) && String.isNotBlank(trx.Product_gne__c)) {
                isValid = validateTerritoryQuantity(trx.From_Territory_Name_gne__c, trx.Product_gne__c, getYear(trx), qty, minAndMaxValues);
            }
        } else { // Update mode
            if(trxType == TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER || trxType == TRANSACTION_RECORD_TYPE_ORDER || trxType == TRANSACTION_RECORD_TYPE_TRANSFER) {
                Integer qty = trx.Received_Quantity_gne__c!=null ? trx.Received_Quantity_gne__c.intValue() : 0;
                if(!(isValid = (qty > 0))) {
                    minAndMaxValues[0] = 1;
                }
            }
        }
        return isValid;
    }

    public static Boolean validateCallDetailQuantity(Call_PFG_Detail_gne__c cDetail, Id userId, String terrName, String distributionMethod, List<Integer> minAndMaxValues) {
        Boolean isValid = true;

        if(String.isNotBlank(cDetail.Product_gne__c)) {
            if(distributionMethod==TRANSACTION_DISCTRIBUTION_METHOD_DTP) {
                Integer qty = cDetail.Quantity_gne__c!=null ? cDetail.Quantity_gne__c.intValue() : 0;

                for (Territory2 terr : GNE_SFA2_PFG_Util.getTerritoriesForUser(userId)) {
                	if(terr.Name == terrName) {
                		isValid = validateTerritoryQuantity(terr.Name, cDetail.Product_gne__c, getYear(cDetail), qty, minAndMaxValues);
                	}
                }
            } else if(String.isNotBlank(cDetail.Lot_No_gne__c)) { // Hand Carry
                Integer qty = cDetail.Quantity_gne__c!=null ? cDetail.Quantity_gne__c.intValue() : 0;
                SFA2_PFG_to_User_Detail_gne__c uDetail = getPfgToUserDetail(userId, cDetail.Product_gne__c, cDetail.Lot_No_gne__c);

                if(!(isValid = (qty > 0 && uDetail!=null && uDetail.Qty_Total_Available_gne__c >= qty))) {
                    minAndMaxValues[0] = 1;
                    minAndMaxValues[1] = ((uDetail!=null && uDetail.Qty_Total_Available_gne__c!=null) ? uDetail.Qty_Total_Available_gne__c.intValue() : 0);
                }
            }
        }

        return isValid;
    }

    public static Boolean validateTerritoryQuantity(String terrName, Id prodId, Integer year, Integer qty, List<Integer> minAndMaxValues) {
    	Boolean isValid = true;
    	SFA2_PFG_to_Territory_Detail_gne__c tDetail = getPfgToTerritoryDetail(terrName, prodId, year);

        if(!(isValid = (qty > 0 && tDetail!=null && tDetail.Qty_Total_Available_gne__c >= qty))) {
        	minAndMaxValues[0] = 1;
            minAndMaxValues[1] = ((tDetail!=null && tDetail.Qty_Total_Available_gne__c!=null) ? tDetail.Qty_Total_Available_gne__c.intValue() : 0);
        }

        return isValid;
    }

    public static Map<Id,ProcessInstance> getApprovedProcesses(Set<Id> targetIds) {

        Map<Id,ProcessInstance> lastProcesses = new Map<Id,ProcessInstance>();
        // Get only newest processes for each Target Record
        for(ProcessInstance pi : GNE_SFA2_PFG_DAO.getApprovalProcessesForTargets(targetIds, new Set<String>{PROCESS_STATUS_APPROVED})) {
            if(!lastProcesses.containsKey(pi.TargetObjectId)) {
                lastProcesses.put(pi.TargetObjectId, pi);
            }
        }

        return lastProcesses;
    }

    public static Map<Id,List<ProcessInstance>> getApprovalProcesses(Set<Id> targetIds) {

        Map<Id,List<ProcessInstance>> processes = new Map<Id,List<ProcessInstance>>();
        // Get only newest processes for each Target Record
        for(ProcessInstance pi : GNE_SFA2_PFG_DAO.getApprovalProcessesForTargets(targetIds,
                    new Set<String>{PROCESS_STATUS_APPROVED,PROCESS_STATUS_REJECTED,PROCESS_STATUS_PENDING})) {
            if(!processes.containsKey(pi.TargetObjectId)) {
                processes.put(pi.TargetObjectId, new List<ProcessInstance>());
            }
            processes.get(pi.TargetObjectId).add(pi);
        }

        return processes;
    }

    public static Boolean isDtpActiveForUser(Id userId) {
        return isUserInBrand(userId, GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_DTP);
    }

    public static Boolean isHcActiveForUser(Id userId) {
        return isUserInBrand(userId, GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_HC);
    }

    public static Boolean isHCPSpecActiveForUser(Id userId){
    	 return (isDtpActiveForUser(userId) || isHcActiveForUser(userId)) && !checkIsUserManager(userId) && isUserInBrand(userId, GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_HCP_SPEC);
    }

    public static Set<String> getUserInHCPSpecBrands(Id userId){
    	return getUserInBrands(userId, GNE_SFA2_PFG_Config.ACTIVE_BRANDS_FOR_HCP_SPEC);
    }

    public static Boolean isUserInBrand(Id userId, Set<String> brandNames) {
        return getUserInBrands(userId, brandNames).size() > 0;
    }

    public static Set<String> getUserInBrands(Id userId, Set<String> brandNames){
    	brandNames = brandNames.clone();
    	// Not manager, so it must be DM or CS.
        if(!brandNames.isEmpty() && !checkIsUserManager(userId)) {
           	Set<String> terrBrandNames = getBrandNamesByUserTerritory(userId);
           	brandNames.retainAll(terrBrandNames);
        }
        return brandNames;
    }

    public static Boolean canCsUseHc(Id userId) {
        return checkIsUserDM(getManagerForUser(userId));
    }

    public static void cacheCallDetails(List<SFA2_PFG_Transaction_gne__c> trxs) {
        cacheCallDetails(trxs, false);
    }

    public static void cacheCallDetails(List<SFA2_PFG_Transaction_gne__c> trxs, Boolean reloadCacheFor) {
        Set<Id> cDetailIds = new Set<Id>();
        for(SFA2_PFG_Transaction_gne__c trx : trxs) {
            if(trx.Call_PFG_Detail_ID_gne__c!=null) {
                cDetailIds.add(trx.Call_PFG_Detail_ID_gne__c);
            }
        }
        cacheCallDetails(cDetailIds, reloadCacheFor);
    }

    public static void cacheCallDetails(Set<Id> callDetailIds, Boolean reloadCacheFor) {
    	if (reloadCacheFor == true && callDetailIds != null && callDetailsCache != null){
    		for (Id callDetailId : callDetailIds){
    			if (callDetailsCache.containsKey(callDetailId)){
    				callDetailsCache.remove(callDetailId);
    			}
    		}
    	}
    	cacheCallDetails(callDetailIds);
    }

    public static void cacheCallDetails(Set<Id> callDetailIds) {
        if(callDetailsCache==null) {
            callDetailsCache = new Map<Id,Call_PFG_Detail_gne__c>();
        }

        Set<Id> existingCallDetailIds = callDetailsCache.keySet();
        callDetailIds = callDetailIds.clone();
        callDetailIds.removeAll(existingCallDetailIds);

        if(!callDetailIds.isEmpty()) {
            Map<Id,Call_PFG_Detail_gne__c> cDetails = new Map<Id,Call_PFG_Detail_gne__c>(GNE_SFA2_PFG_DAO.getCallDetailByIds(callDetailIds));

            for(Id cDetailId : callDetailIds) {
                callDetailsCache.put(cDetailId,cDetails.get(cDetailId));
            }
        }
    }

    public static void cacheTransactionsByCallDetailIds(Set<Id> callDetailIds) {
        if(callDetailTransactionsCache==null) {
            callDetailTransactionsCache = new Map<Id,SFA2_PFG_Transaction_gne__c>();
        }

        Set<Id> existingCallDetailIds = callDetailTransactionsCache.keySet();
        callDetailIds = callDetailIds.clone();
        callDetailIds.removeAll(existingCallDetailIds);

        if(!callDetailIds.isEmpty()) {
            List<SFA2_PFG_Transaction_gne__c> trxs = GNE_SFA2_PFG_DAO.getTransactionsByCallPfgDetailIds(
                callDetailIds, new Set<String>{TRANSACTION_RECORD_TYPE_DISBURSEMENT, TRANSACTION_RECORD_TYPE_RFF});

            Map<Id,SFA2_PFG_Transaction_gne__c> trxByCallDetailIdMap = new Map<Id,SFA2_PFG_Transaction_gne__c>();

            for(SFA2_PFG_Transaction_gne__c trx : trxs) {
                trxByCallDetailIdMap.put(trx.Call_PFG_Detail_ID_gne__c,trx);
            }


            for(Id cDetailId : callDetailIds) {
                callDetailTransactionsCache.put(cDetailId,trxByCallDetailIdMap.get(cDetailId));
            }
        }
    }

    public static SFA2_PFG_Transaction_gne__c getTransactionByCallDetailId(Id cDetailId) {
        return callDetailTransactionsCache!=null ? callDetailTransactionsCache.get(cDetailId) : null;
    }

    public static Call_PFG_Detail_gne__c getCallDetailById(Id cDetailId) {
        return callDetailsCache!=null ? callDetailsCache.get(cDetailId) : null;
    }

    public static Boolean validateHcpQuantityLimit(Call_PFG_Detail_gne__c cDetail, String limitYear) {
        Boolean result = true;
        if(String.isNotBlank(cDetail.Account_gne__c) && String.isNotBlank(cDetail.Product_gne__c) && cDetail.Quantity_gne__c!=null) {
            result = validateHcpQuantityLimit(cDetail.Account_gne__c, cDetail.Product_gne__c, cDetail.Quantity_gne__c.intValue(), limitYear);
        }
        return result;
    }

    public static Boolean validateHcpQuantityLimit(Id accId, Id prodId, Integer currentQty, String limitYear) {
    	Integer limitQty = getHcpQuantityLimit(accId, prodId, limitYear);
    	return (limitQty==null || currentQty <= limitQty);
    }

    public static Integer getHcpQuantityLimit(Id accId, Id prodId, String limitYear) {
    	Integer limitQty = null;
    	Integer prodLimitQty = getProductMaxQuantity(prodId, limitYear);

    	if(prodLimitQty!=null) {
    		Integer hcpLimitQty = getHcpMaxQuantity(accId, prodId, limitYear);
    		limitQty = hcpLimitQty!=null ? hcpLimitQty : prodLimitQty;
    	}

    	return limitQty;
    }

    public static Integer getHcpMaxQuantity(Id accId, Id prodId, String limitYear) {
        SFA2_PFG_to_Account_Detail_gne__c accDetail = getPfgToAccountDetail(accId, prodId, limitYear);
        Integer limitQty = (accDetail!=null && accDetail.Remaining_Quantity_gne__c!=null) ? accDetail.Remaining_Quantity_gne__c.intValue() : null;

        if(limitQty==null) {
            PFG_Staging_Account_Limit_Exception_gne__c accLimitEx = getAccLimitException(accId, prodId, limitYear);
            limitQty = (accLimitEx!=null && accLimitEx.Exception_Quantity_gne__c!=null) ? accLimitEx.Exception_Quantity_gne__c.intValue() : null;
        }

        return limitQty;
    }

    public static Integer getProductMaxQuantity(Id prodId, String limitYear) {
        SFA2_PFG_Product_Limit_gne__c prodLimit = getProductLimit(prodId, limitYear);
        Integer limitQty = (prodLimit!=null && prodLimit.Inactive_gne__c!=true && prodLimit.Limit_Quantity_gne__c!=null) ? prodLimit.Limit_Quantity_gne__c.intValue() : null;
        return limitQty;
    }

    public static List<String> getHomeOfficeEmails(){
        List<SFA2_User_Sales_Roster_gne__c> homeOfficeUsersRosters = GNE_SFA2_PFG_DAO.getHomeOfficeUsers();
        List<String> homeOfficeEmails = new List<String>();
        for(SFA2_User_Sales_Roster_gne__c sRoster : homeOfficeUsersRosters){
            homeOfficeEmails.add(sRoster.User_gne__r.Email);
        }
        return homeOfficeEmails;
    }
    public static void cacheInventoryCount(List<SFA2_PFG_Transaction_gne__c> transactions){
        if(inventoryCountCache != null){
            return;
        }
        Set<Id> userIds = new Set<Id>();
        for(SFA2_PFG_Transaction_gne__c trx : transactions){
            if(trx.To_User_gne__c != null){
                userIds.add(trx.To_User_gne__c);
            }
            if(trx.From_User_gne__c != null){
                userIds.add(trx.From_User_gne__c);
            }
        }
        cacheInventoryCount(userIds);
    }
    public static void cacheInventoryCount(Set<Id> userIds){
        if(inventoryCountCache != null){
            return;
        }
        inventoryCountCache = new Map<String, SFA2_PFG_Inventory_Count_gne__c>();
        for(SFA2_PFG_Inventory_Count_gne__c invCount : GNE_SFA2_PFG_DAO.getInventoryCountForUser(userIds)){
            String extId = invCount.Inventory_For_gne__c +'_'+ invCount.Product_gne__c;
            inventoryCountCache.put(extId, invCount);
        }
    }
    public static SFA2_PFG_Inventory_Count_gne__c getInvCountForUserAndProduct(Id userId, Id productId){
        SFA2_PFG_Inventory_Count_gne__c invCount = null;
        if(inventoryCountCache != null){
            String extId = userId+'_'+productId;
            invCount = inventoryCountCache.get(extId);
        }
        return invCount;
    }

     public static Boolean isWeekendDay(Date dateParam){
       //Recover the day of the week
       Date startOfWeek   = dateParam.toStartOfWeek();
       Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
       return dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
    }


    public static Date addBusinessDays(Date startDate, Integer businessDaysToAdd ){
       //Add or decrease in businessDaysToAdd days
       Date finalDate = startDate;
       Integer direction = businessDaysToAdd < 0 ? -1 : 1;
       while(businessDaysToAdd != 0){
            finalDate = finalDate.AddDays(direction);
            if (!isWeekendDay(finalDate)){
                businessDaysToAdd -= direction;
            }
        }
        return finalDate;
    }

    public static Boolean checkIsSlnValid(Id addressId) {
    	Boolean isValid = false;

    	for(Address_vod__c addr : GNE_SFA2_PFG_DAO.getAddressSLN(new Set<Id>{addressId})) {
    		isValid = checkIsSlnValid(addr);
    	}

    	return isValid;
    }

    public static Boolean checkIsSlnValid(Address_vod__c addr) {
    	return (addr.License_Valid_To_Sample_vod__c == ADDRESS_SLN_VALID);
    }

    public static Integer getInteractionQtyLimit(Id pfgProductId) {
    	return getInteractionQtyLimit(pfgProductId, null);
    }

    public static Integer getInteractionQtyLimit(Id pfgProductId, String dMethod) {
    	Product_vod__c pfgProd = getPfgProduct(pfgProductId);

    	if(dMethod==null) {
    		dMethod = isProductDtp(pfgProductId) ? TRANSACTION_DISCTRIBUTION_METHOD_DTP : TRANSACTION_DISCTRIBUTION_METHOD_HC;
    	}

    	return getInteractionQtyLimit(pfgProd!=null ? pfgProd.Parent_Product_vod__r.Name : null, dMethod);
    }

    public static Integer getInteractionQtyLimit(String brandName, String dMethod) {
    	Map<String,Integer> brandQtyLimit = GNE_SFA2_PFG_Config.INTERACTION_QTY_LIMITS_PER_BRAND.get(brandName);
    	return brandQtyLimit!=null ? brandQtyLimit.get(dMethod) : null;
    }

    public static String getRecordKey(SFA2_PFG_to_Territory_Detail_gne__c tDetail) {
    	return tDetail.Territory_Name_gne__c + '_' + tDetail.Product_gne__c + '_' + tDetail.Year_gne__c;
    }

    public static String getRecordKey(SFA2_PFG_to_User_Detail_gne__c uDetail) {
    	return getRecordKey(uDetail, true);
    }

    public static String getRecordKey(SFA2_PFG_to_User_Detail_gne__c uDetail, Boolean includedLot) {
    	return uDetail.User_gne__c + '_' + uDetail.Product_gne__c + (includedLot ? ('_' +  uDetail.Lot_NO_gne__c) : '');
    }

    public static String getRecordKey(SFA2_PFG_to_Account_Detail_gne__c aDetail) {
    	return aDetail.Account_gne__c + '_' + aDetail.Product_gne__c + '_' + aDetail.Limit_Year_gne__c;
    }

    public static String getRecordKey(PFG_Staging_Account_Limit_Exception_gne__c aEx) {
    	return aEx.Account_gne__c + '_' + aEx.Product_gne__c + '_' +  aEx.Limit_Year_gne__c;
    }

    public static String getRecordKey(SFA2_PFG_Product_Limit_gne__c pLimit) {
    	return pLimit.Product_gne__c + '_' +  pLimit.Limit_Year_gne__c;
    }

    public static Integer getYear(SFA2_PFG_Transaction_gne__c trx) {
    	return trx.Transaction_Date_gne__c.year();
    }

    public static Integer getYear(Call_PFG_Detail_gne__c cDetail) {
    	return cDetail.Date_gne__c.year();
    }

    public static Integer getYear() {
    	return System.today().year();
    }

    public static void addSessionLabel(String label) {
		GNE_SFA2_PFG_ExceptionHandler.addSessionLabel(label);
	}

	public static Set<String> getSessionLabels() {
		return GNE_SFA2_PFG_ExceptionHandler.getSessionLabels();
	}

	public static void setSessionLabels(Set<String> sessionLabels) {
		GNE_SFA2_PFG_ExceptionHandler.setSessionLabels(sessionLabels);
	}

    public static void handleException(Exception ex) {
    	GNE_SFA2_PFG_ExceptionHandler.handleException(ex);
    }

    public static void reportExceptions() {
    	GNE_SFA2_PFG_ExceptionHandler.reportExceptions();
    }

    public static void intReportExceptions() {
    	GNE_SFA2_PFG_ExceptionHandler.intReportExceptions();
    }

    public static void insertErrorLogs() {
    	GNE_SFA2_PFG_ExceptionHandler.insertErrorLogs();
    }

    public static void sendErrorEmailNotification() {
    	GNE_SFA2_PFG_ExceptionHandler.sendErrorEmailNotification();
    }

    public static void sendEmailNotification(String subject, String message) {
    	GNE_SFA2_PFG_ExceptionHandler.sendEmailNotification(GNE_SFA2_PFG_Config.ERROR_NOTIFICATION_EMAILS, subject, message, false);
    }

    public static void sendEmailNotification(String subject, String message, Boolean isHtmlBody) {
    	GNE_SFA2_PFG_ExceptionHandler.sendEmailNotification(GNE_SFA2_PFG_Config.ERROR_NOTIFICATION_EMAILS, subject, message, isHtmlBody);
    }

    public static void sendEmailNotification(List<String> emailAddresses, String subject, String message) {
    	GNE_SFA2_PFG_ExceptionHandler.sendEmailNotification( emailAddresses, subject, message, false);
    }

    public static void sendEmailNotification(List<String> emailAddresses, String subject, String message, Boolean isHtmlBody) {
    	GNE_SFA2_PFG_ExceptionHandler.sendEmailNotification(emailAddresses, subject, message, isHtmlBody);
    }

	public static String getSalesforceURL(String objectId) {
		return URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectId;
	}

	public static String getSalesforceLink(String objectId, String objectName) {
		return String.format('<a href="{0}">{1}</a>', new String[]{getSalesforceURL(objectId), objectName});
	}
}