public with sharing class GNE_SFA2_PFG_DAO {
    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsByUserAndProductIds(Set<Id> userIDs, Set<Id> productIds, Set<String> lotNOs) {
        return getPFGToUserDetailsByUserAndProductIds(userIDs, productIds, lotNOs, false);
    }
    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsByUserAndProductIds(Set<Id> userIDs, Set<Id> productIds, Set<String> lotNOs, Boolean merged) {
        return [
        SELECT
            Id,
            Name,
            Active_gne__c,
            CreatedById,
            CreatedDate,
            Distribution_Method_gne__c,
            Expiration_Date_gne__c,
            IsDeleted,
            IsLocked,
            LastModifiedById,
            LastModifiedDate,
            Lot_NO_gne__c,
            OwnerId,
            Product_gne__c,
            Qty_Adjusted_gne__c,
            Qty_Disbursed_gne__c,
            Qty_Last_Physical_Inventory_gne__c,
            Qty_Reserved_gne__c,
            Qty_Returned_gne__c,
            Qty_Shipped_to_Physician_gne__c,
            Qty_Total_Allocated_gne__c,
            Qty_Total_Available_gne__c,
            Qty_Transferred_In_gne__c,
            Qty_Transferred_Out_gne__c,
            UOM_gne__c,
            User_gne__c,
            User_gne__r.Name,
            Merged_gne__c,
            YTD_Allocated_gne__c
        FROM SFA2_PFG_to_User_Detail_gne__c
        WHERE User_gne__c IN :userIDs AND Product_gne__c IN :productIds AND Lot_NO_gne__c IN : lotNOs AND Merged_gne__c = :merged
        ];

    }
    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsByUserAndProductIdsNoLot(Set<Id> userIDs, Set<Id> productIds)
    {
        return [
        SELECT
            Id,
            Name,
            Active_gne__c,
            CreatedById,
            CreatedDate,
            Distribution_Method_gne__c,
            Expiration_Date_gne__c,
            IsDeleted,
            IsLocked,
            LastModifiedById,
            LastModifiedDate,
            Lot_NO_gne__c,
            OwnerId,
            Product_gne__c,
            Qty_Adjusted_gne__c,
            Qty_Disbursed_gne__c,
            Qty_Last_Physical_Inventory_gne__c,
            Qty_Reserved_gne__c,
            Qty_Returned_gne__c,
            Qty_Shipped_to_Physician_gne__c,
            Qty_Total_Allocated_gne__c,
            Qty_Total_Available_gne__c,
            Qty_Transferred_In_gne__c,
            Qty_Transferred_Out_gne__c,
            UOM_gne__c,
            User_gne__c,
            User_gne__r.Name,
            Merged_gne__c,
            YTD_Allocated_gne__c

        FROM SFA2_PFG_to_User_Detail_gne__c
        WHERE User_gne__c IN :userIDs AND Product_gne__c IN :productIds AND Merged_gne__c = false
        ];

    }

    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsForUsers(Set<Id> userIDs, Set<String> distrMethods)
    {
        return [
        SELECT
            Id,
            Name,
            Active_gne__c,
            CreatedById,
            CreatedDate,
            Distribution_Method_gne__c,
            Expiration_Date_gne__c,
            IsDeleted,
            IsLocked,
            LastModifiedById,
            LastModifiedDate,
            Lot_NO_gne__c,
            OwnerId,
            Product_gne__c,
            Qty_Adjusted_gne__c,
            Qty_Disbursed_gne__c,
            Qty_Last_Physical_Inventory_gne__c,
            Qty_Reserved_gne__c,
            Qty_Returned_gne__c,
            Qty_Shipped_to_Physician_gne__c,
            Qty_Total_Allocated_gne__c,
            Qty_Total_Available_gne__c,
            Qty_Transferred_In_gne__c,
            Qty_Transferred_Out_gne__c,
            UOM_gne__c,
            User_gne__c,
            User_gne__r.Name,
            Merged_gne__c,
            YTD_Allocated_gne__c,
            Product_gne__r.NDC_Number_gne__c,
            Product_gne__r.Name
        FROM SFA2_PFG_to_User_Detail_gne__c
        WHERE User_gne__c IN :userIDs AND Distribution_Method_gne__c IN :distrMethods
        ORDER BY Product_gne__r.Name
        ];

    }

    public static List<SFA2_PFG_to_User_Detail_gne__c> getPFGToUserDetailsForUsersWithPositiveQty(Set<Id> userIDs, Set<String> distrMethods)
    {
        return [
        SELECT
            Distribution_Method_gne__c,
            Lot_NO_gne__c, Product_gne__c,
            Product_gne__r.NDC_Number_gne__c ,
            Product_gne__r.Name ,
            Expiration_Date_gne__c,
            Qty_Total_Available_gne__c,
            UOM_gne__c,
            User_gne__c
        FROM SFA2_PFG_to_User_Detail_gne__c
        WHERE User_gne__c IN :userIDs AND Distribution_Method_gne__c IN :distrMethods AND Qty_Total_Available_gne__c>0
        ORDER BY Product_gne__r.Name
        ];

    }

    public static List<SFA2_Lot_Catalog_gne__c> getLotCatalogsForLotNumber(Set<String> lotNumbers){
        return[
        SELECT
            Expiration_Date_gne__c,
            Name,
            Product_gne__c,
            Product_gne__r.Name,
            Product_gne__r.NDC_Number_gne__c,
            Distribution_Method_gne__c,
            Product_gne__r.UOM_gne__c,
            Product_gne__r.Parent_Product_vod__r.Name
        FROM SFA2_Lot_Catalog_gne__c
        WHERE Name IN :lotNumbers AND Active_gne__c = true
        ];
    }

    public static List<SFA2_Lot_Catalog_gne__c> getLotCatalogsForIds(Set<String> lotIds){
        return[
        SELECT
            Expiration_Date_gne__c,
            Name,
            Product_gne__c,
            Product_gne__r.Name,
            Product_gne__r.NDC_Number_gne__c,
            Distribution_Method_gne__c,
            Product_gne__r.UOM_gne__c,
            Product_gne__r.Parent_Product_vod__r.Name
        FROM SFA2_Lot_Catalog_gne__c
        WHERE Id IN :lotIds AND Active_gne__c = true
        ];
    }

    public static List<SFA2_Lot_Catalog_gne__c> getLotCatalogsForProdIds(Set<Id> prodIds){
        return[
        SELECT
            Expiration_Date_gne__c,
            Name,
            Product_gne__c,
            Product_gne__r.Name,
            Product_gne__r.NDC_Number_gne__c,
            Distribution_Method_gne__c,
            Product_gne__r.UOM_gne__c,
            Product_gne__r.Parent_Product_vod__r.Name
        FROM SFA2_Lot_Catalog_gne__c
        WHERE Product_gne__c IN :prodIds AND Active_gne__c = true
        ];
    }

    public static List<SFA2_PFG_to_Account_Detail_gne__c> getPFGtoAccountDetailsByAccountsProductsAndYears(Set<Id> accountsIds, Set<Id> productsIds, Set<String> years)
    {
        return
        [
            Select
                Id,
                Name,
                CreatedById,
                CreatedDate,
                IsDeleted,
                IsLocked,
                LastModifiedById,
                LastModifiedDate,
                OwnerId,
                Account_gne__c,
                Distribution_Method_gne__c,
                Enforce_Limit_gne__c,
                Exception_Limit_gne__c,
                Exception_Quantity_gne__c,
                Freeze_for_Pending_AOC_gne__c,
                Limit_Year_gne__c,
                Max_Quantity_gne__c,
                Product_gne__c,
                Qty_Disbursed_gne__c,
                Qty_to_Fulfill_gne__c,
                Remaining_Quantity_gne__c
            FROM SFA2_PFG_to_Account_Detail_gne__c
            WHERE Account_gne__c IN : accountsIds AND Product_gne__c IN: productsIds AND Limit_Year_gne__c IN :years
        ];
    }

    public static List<IC_Calc_Sales_Roster_gne__c> getSalesRosters( Set<String> types, Set<String> userRoles, Set<String> managerRoles, Set<Id> userIds, Set<String> pfgProfiles) {
        return [
        SELECT
            Brand_Name_gne__c,
            Salesforce_gne__c,
            Type_gne__c,
            User_Role_gne__c,
            (SELECT
                User_gne__c,
                User_gne__r.Id,
                User_gne__r.Name,
                User_gne__r.ManagerId,
                User_gne__r.FirstName,
                User_gne__r.LastName,
                User_gne__r.UserName,
                User_gne__r.Is_User_On_LOA_Calc_gne__c,
                User_gne__r.PFG_Uncertified_Flag_gne__c,
                User_gne__r.LOA_HO_Override_Flag_gne__c,
                User_gne__r.LOA_Start_Date_gne__c,
                User_gne__r.LOA_End_Date_gne__c,
                User_gne__r.Email,
                User_gne__r.External_ID_gne__c,
                User_gne__r.Profile.Name,
                Role_gne__c,
                Sales_Roster_gne__r.Brand_Name_gne__c,
                Sales_Roster_gne__r.Salesforce_gne__c
             FROM User_Sales_Roasters__r
             WHERE User_gne__c IN (SELECT Id FROM User WHERE Profile.Name IN :pfgProfiles)
             	AND ((Role_gne__c IN :userRoles AND User_gne__c IN :userIds)
             		OR (Role_gne__c IN :managerRoles)))
        FROM IC_Calc_Sales_Roster_gne__c
        WHERE Type_gne__c IN :types
        ];
    }

    public static Set<String> getProfilesWithPermissionToPfg(String pfgMainPageName) {
    	Set<String> pfgProfiles = new Set<String>();

    	for(ApexPage pfgMainPage : [
		    	SELECT
		    		(SELECT Parent.Profile.Name FROM SetupEntityAccessItems)
				FROM ApexPage
				WHERE Name = :pfgMainPageName]) {
			for(SetupEntityAccess sea : pfgMainPage.SetupEntityAccessItems) {
				if(String.isNotBlank(sea.Parent.Profile.Name)) {
					pfgProfiles.add(sea.Parent.Profile.Name);
				}
			}
		}

		return pfgProfiles;
    }

    public static List<SFA2_User_Sales_Roster_gne__c> getSalesRostersByCsIds (Set<Id> csIds)
    {
        return [Select User_gne__c, User_gne__r.ManagerId From SFA2_User_Sales_Roster_gne__c Where User_gne__c IN : csIds];
    }

    public static List<UserTerritory2Association> getUserTerritoriesByTerritoryIds(Set<Id> terrIds)
    {
        return [Select UserId, Territory2Id from UserTerritory2Association where Territory2Id IN :terrIds AND IsActive = true];
    }

    public static List<Territory2> getPfgRootTerritories(Map<String, Set<String>> salesforceCodes) {
        if (salesforceCodes == null || salesforceCodes.isEmpty()){
            return new List<Territory2>();
        }

        String query = String.format('SELECT Id, Name, ParentTerritory2Id, Territory_Number_gne__c, External_Id_gne__c, {0}, {1} FROM Territory2 ', new String[]{
            String.valueOf(Territory2.Salesforce_Code_gne__c),
            String.valueOf(Territory2.Salesforce_SubTeam_Code_gne__c)
        });

        String whereCondition = String.format('WHERE {0} = true AND (NOT(External_Id_gne__c LIKE \'\'{1}\'\')) ', new String[]{
            String.valueOf(Territory2.Is_Root_gne__c),
            '%_OLD'
        });

        List<String> orConditions = new List<String>();
        for (String salesforceCode : salesforceCodes.keyset()){
            String salesforceSubCodesToInQuery = GNE_SFA2_Util.createInListForQuery(new List<String>(salesforceCodes.get(salesforceCode)));
            String orConditionItem = String.format(
                '({0} = \'\'{1}\'\' AND {2} IN {3})', new String[]{
                String.valueOf(Territory2.Salesforce_Code_gne__c),
                salesforceCode,
                String.valueOf(Territory2.Salesforce_SubTeam_Code_gne__c),
                salesforceSubCodesToInQuery
            });
            orConditions.add(orConditionItem);
        }
        String orConditionString = String.join(orConditions, ' OR ');
        if (orConditions.size() > 1){
            orConditionString = '(' + orConditionString + ')';
        }
        whereCondition += 'AND ' + orConditionString;
        query += whereCondition;

        System.debug('Query: ' + query);
        return Database.query(query);
    }

    public static List<Territory2> getPfgAllChildTerritories(Set<String> extIds, Map<String, Set<String>> salesforceCodes) {
        List<Territory2> result = new List<Territory2>();
        if(!extIds.isEmpty()) {
            String query = String.format(
                'SELECT Id, Territory_Number_gne__c, External_Id_gne__c, Name, ParentTerritory2Id, {0}, {1} FROM Territory2 ', new String[]{
                String.valueOf(Territory2.Salesforce_Code_gne__c),
                String.valueOf(Territory2.Salesforce_SubTeam_Code_gne__c)
            });

            String whereCondition = String.format('WHERE {0} <> null AND {1} <> null ', new String[]{
                String.valueOf(Territory2.Salesforce_Code_gne__c),
                String.valueOf(Territory2.Salesforce_SubTeam_Code_gne__c)
            });

            List<String> orConditions = new List<String>();
            for(String extId : extIds) {
                //orConditions.add('External_Id_gne__c like \'' + extId + '-%\''); JL test after tm2
                orConditions.add('External_Id_gne__c like \'' + extId + '%\'');
            }
            String orConditionString = String.join(orConditions, ' OR ');
            if (orConditions.size() > 1){
                orConditionString = '(' + orConditionString + ')';
            }
            whereCondition += 'AND ' + orConditionString;

            if (salesforceCodes != null && !salesforceCodes.isEmpty()){
                orConditions.clear();
                for (String salesforceCode : salesforceCodes.keyset()){
                    String salesforceSubCodesToInQuery = GNE_SFA2_Util.createInListForQuery(new List<String>(salesforceCodes.get(salesforceCode)));
                    String orConditionItem = String.format(
                        '({0} = \'\'{1}\'\' AND {2} IN {3})', new String[]{
                        String.valueOf(Territory2.Salesforce_Code_gne__c),
                        salesforceCode,
                        String.valueOf(Territory2.Salesforce_SubTeam_Code_gne__c),
                        salesforceSubCodesToInQuery
                    });
                    orConditions.add(orConditionItem);
                }
                orConditionString = String.join(orConditions, ' OR ');
                if (orConditions.size() > 1){
                    orConditionString = '(' + orConditionString + ')';
                }
                whereCondition += ' AND ' + orConditionString;
            }

            query += whereCondition;
            query += ' ORDER BY External_Id_gne__c ASC';

            System.debug('Query: ' + query);
            result = Database.query(query);
        }
        return result;
    }

    // DEPRECATED, new method: getBrandsToSalesforces(Set<String> brandNamesFilter)
    public static List<Brand_2_Salesforce_gne__c> getBrandsToSalesforces(){
        return [
            SELECT
                Id,
                Name,
                CDM_Brand_Code_gne__c,
                CDM_Salesforce_Code_gne__c,
                CDM_Salesforce_SubTeam_Code_gne__c,
                External_Id_gne__c,
                Salesforce_Name_gne__c,
                Salesforce_SubTeam_Name_gne__c,
                SFA_Brand_Name_gne__c
            FROM Brand_2_Salesforce_gne__c
            ORDER BY Name
        ];
    }

    public static List<Brand_2_Salesforce_gne__c> getBrandsToSalesforces(Set<String> brandNamesFilter){
        return [
            SELECT
                Id,
                Name,
                CDM_Brand_Code_gne__c,
                CDM_Salesforce_Code_gne__c,
                CDM_Salesforce_SubTeam_Code_gne__c,
                External_Id_gne__c,
                Salesforce_Name_gne__c,
                Salesforce_SubTeam_Name_gne__c,
                SFA_Brand_Name_gne__c
            FROM Brand_2_Salesforce_gne__c
            WHERE SFA_Brand_Name_gne__c IN :brandNamesFilter
            AND CDM_Salesforce_Code_gne__c <> null
            AND CDM_Salesforce_SubTeam_Code_gne__c <> null
            ORDER BY SFA_Brand_Name_gne__c
        ];
    }

    public static List<Product_vod__c> getPfgProducts(String dtpMethodName, String hcMethodName) {
        List<Product_vod__c> pfgProds = [
        SELECT
            Id,
            Name,
            NDC_Number_gne__c,
            UOM_gne__c,
            Parent_Product_vod__c,
            Parent_Product_vod__r.Name,
            CreatedDate,
            LastModifiedDate,
            (SELECT Id, Distribution_Method_gne__c FROM PFG_Lot_Catalog__r WHERE Distribution_Method_gne__c = :hcMethodName LIMIT 1)
        FROM Product_vod__c
        WHERE Product_Type_vod__c = 'PFG'
        ORDER BY Name
        ];

        pfgProds.addAll([
        SELECT
            Id,
            Name,
            NDC_Number_gne__c,
            UOM_gne__c,
            Parent_Product_vod__c,
            Parent_Product_vod__r.Name,
            CreatedDate,
            LastModifiedDate,
            (SELECT Id, Distribution_Method_gne__c FROM PFG_Lot_Catalog__r WHERE Distribution_Method_gne__c = :dtpMethodName LIMIT 1)
        FROM Product_vod__c
        WHERE Product_Type_vod__c = 'PFG'
        ORDER BY Name
        ]);

        return pfgProds;
    }

    public static List<SFA2_PFG_Product_Limit_gne__c> getAllPFGProductsLimitsPerYearAndProducts(String limitYear, List<Product_vod__c> products){
    	return [
    	SELECT
    		Limit_Quantity_gne__c,
    		Product_gne__c,
    		Product_gne__r.NDC_Number_gne__c,
    		Product_gne__r.Name
    	FROM SFA2_PFG_Product_Limit_gne__c
    	WHERE Limit_Year_gne__c =: limitYear AND Product_gne__c IN :products AND Inactive_gne__c <> true];
    }

    public static List<SFA2_PFG_to_Account_Detail_gne__c> getPfgToAccountDetailsPerAccountAndLimitYearAndProducts(Id accountId, String limitYear, List<Product_vod__c> products){
    	return[
    	SELECT
    		Account_gne__c,
    		Product_gne__c,
    		Qty_Disbursed_gne__c
    	FROM SFA2_PFG_to_Account_Detail_gne__c
    	WHERE Account_gne__c = :accountId AND Limit_Year_gne__c = :limitYear AND Product_gne__c In :products
    	ORDER BY Qty_Disbursed_gne__c DESC
    	];
    }

    public static List<PFG_Staging_Account_Limit_Exception_gne__c> getAccountProductsLimitsPerYear(Id accountId, String limitYear, List<Product_vod__c> products){
    	return[
    	SELECT
    		Exception_Quantity_gne__c,
    		Product_gne__c,
    		Product_gne__r.NDC_Number_gne__c,
    		Product_gne__r.Name
    	FROM PFG_Staging_Account_Limit_Exception_gne__c
    	WHERE Account_gne__c =:accountId AND Limit_Year_gne__c =:limitYear AND Product_gne__c In :products AND Logical_Delete_Flag_gne__c = false
    	];
    }

    public static List<Product_vod__c> getProductsById(Set<String> ids) {
        return [
        SELECT
            Id,
            Name,
            NDC_Number_gne__c,
            UOM_gne__c,
            Parent_Product_vod__c,
            Parent_Product_vod__r.Name
        FROM Product_vod__c
        WHERE Id in :ids
        ORDER BY Name
        ];
    }

    public static List<SFA2_PFG_Transaction_gne__c> getTransactionsNameAndRefNo(List<SFA2_PFG_Transaction_gne__c> trns){
        return
        [SELECT
            Name,
            Transaction_Ref_Number_gne__c,
            Lot_No_gne__c,
            Transaction_Type_gne__c
        FROM SFA2_PFG_Transaction_gne__c
        WHERE Id IN :trns];
    }

    public static List<SFA2_PFG_Transaction_gne__c> getPfgTransactionsByRefNo(Set<String> transRefNos) {
        return getTransactions(null,null,
            new List<WhereStatementWrapper>{
                new WhereStatementWrapper('Transaction_Ref_Number_gne__c', 'IN', transRefNos)
            },new List<String>{'Product_gne__r.Name asc'});
    }

    public static List<SFA2_PFG_Transaction_gne__c> getPfgAllocationsByProductId(Set<Id> pfgProductIds, Set<Id> userIds, String shipmentStatus, String trxType) {
        return getTransactions(
            new Set<String>{trxType},
            null,
            new List<WhereStatementWrapper>{
                new WhereStatementWrapper('Product_gne__c', 'IN', pfgProductIds),
                new WhereStatementWrapper('To_User_gne__c', 'IN', userIds),
                new WhereStatementWrapper('Generate_Shipment_Flag__c', '=', shipmentStatus)
            },null);
    }

    public static List<SFA2_PFG_Transaction_gne__c> getTransactionsByCallPfgDetailIds(Set<Id> callDetailIds, Set<String> trxTypes) {
        return getTransactions(
            trxTypes,
            null,
            new List<WhereStatementWrapper>{
                new WhereStatementWrapper('Call_PFG_Detail_ID_gne__c', 'IN', callDetailIds)
            },null);
    }

    public static List<SFA2_PFG_Transaction_gne__c> getTransactions(
                Set<String> trnTypes,
                Set<String> brandNames,
                List<WhereStatementWrapper> whereWrappers,
                List<String> orderFields) {

        List<String> queryFields = new List<String>{
            String.valueOf(SFA2_PFG_Transaction_gne__c.Id),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Name),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Ref_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_gne__c),
            'From_User_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_gne__c),
            'To_User_gne__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Type_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.RecordTypeId),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Generate_Shipment_Flag__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Requested_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipped_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Received_Quantity_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Discrepancy_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Transaction_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Submitted_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Receipt_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_PFG_Detail_ID_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Call_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Shipment_Id_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Lot_No_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.NDC_Number__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Product_gne__c),
            'Product_gne__r.Name',
            'Product_gne__r.NDC_Number_gne__c',
            'Product_gne__r.Parent_Product_vod__r.Name',
            String.valueOf(SFA2_PFG_Transaction_gne__c.UOM_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Distribution_Method_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_Territory_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_Is_CS_Flag_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_Is_CS_Flag_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_Territory_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_Territory_Number_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.From_Territory_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.To_Territory_Name_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Request_Signature_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Request_Signature_Date_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_gne__c),
            String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Date_gne__c)
            };

        return getTransactions(queryFields, trnTypes, brandNames, whereWrappers, orderFields);
    }

        public static List<SFA2_PFG_Transaction_gne__c> getTransactions(
                List<String> queryFields,
                Set<String> trnTypes,
                Set<String> brandNames,
                List<WhereStatementWrapper> whereWrappers,
                List<String> orderFields) {
        	return getTransactions(queryFields, trnTypes, brandNames, whereWrappers, orderFields, null);
        }

        public static List<SFA2_PFG_Transaction_gne__c> getTransactions(
                List<String> queryFields,
                Set<String> trnTypes,
                Set<String> brandNames,
                List<WhereStatementWrapper> whereWrappers,
                List<String> orderFields,
                String whereStatementAdvancedLogic) {

        Set<Id> recordTypeIds = new Set<Id>();
        if(trnTypes!=null) {
            Map<String, Schema.RecordTypeInfo> rtInfos = SFA2_PFG_Transaction_gne__c.getSobjectType().getDescribe().getRecordTypeInfosByName();
            for(String trnType : trnTypes) {
                recordTypeIds.add(rtInfos.get(trnType).getRecordTypeId());
            }
        }

        if(whereWrappers==null) {
            whereWrappers = new List<WhereStatementWrapper>();
        }

        Integer sizeOfWheres = whereWrappers.size();
        Integer idx = 0;

        Object whereValue0 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue1 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue2 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue3 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue4 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue5 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue6 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue7 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue8 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;
        Object whereValue9 = sizeOfWheres>=(idx+1) ? whereWrappers[idx++].value : null;

        List<String> whereStatements = new List<String>();

        if(!recordTypeIds.isEmpty()) {
            whereStatements.add('RecordTypeId IN :recordTypeIds');
        }

        if(brandNames!=null && !brandNames.isEmpty()) {
            whereStatements.add('Product_gne__c IN (SELECT Id FROM Product_vod__c WHERE Parent_Product_vod__r.Name IN :brandNames)');
        }

        for(Integer i = 0; i<Math.min(sizeOfWheres,10);i++) {
            WhereStatementWrapper wrapper = whereWrappers[i];
            String operator = wrapper.operator!=null ? wrapper.operator.toUpperCase() : null;

            if((operator=='NOT IN' || operator=='IN') && wrapper.value==null) {
                continue;
            } else if(operator==null && wrapper.value == null) {
                whereStatements.add(wrapper.fieldName);
            } else {
                whereStatements.add(String.format('{0} {1} :{2}', new List<String>{
                        wrapper.fieldName,
                        wrapper.operator,
                        'whereValue' + i} ));
            }
        }

        String whereStatementsString = whereStatementAdvancedLogic==null
        		? String.join(whereStatements, ' AND ')
        		: String.format(whereStatementAdvancedLogic, whereStatements);

        String queryString = 'SELECT ' + String.join(queryFields,',')
             + ' FROM SFA2_PFG_Transaction_gne__c'
             + (!whereStatements.isEmpty() ? ' WHERE ' + whereStatementsString : '')
             + ((orderFields!=null && !orderFields.isEmpty()) ? ' ORDER BY ' + String.join(orderFields,',') : '');

        System.debug('queryString=' + queryString);

        return Database.query(queryString);
    }

    public class WhereStatementWrapper {
        public String fieldName;
        public String operator;
        public Object value;

        public WhereStatementWrapper(String a_fieldName, String a_operator, Object a_value) {
            fieldName = a_fieldName;
            operator = a_operator;
            value = a_value;
        }
    }


    public static List<Address_vod__c> getAccountsAddresses (List<Account> accounts)
    {
        return [Select Account_vod__c, Sample_Status_vod__c from Address_vod__c where Account_vod__c IN : accounts];
    }
    public static List<SFA2_PFG_Transaction_gne__c> getOverdueSignatureTransactions (Set<Id> accIds, Set<Id> prodId)
    {
        return [Select Id, Product_gne__c, Account_gne__c from SFA2_PFG_Transaction_gne__c where Product_gne__c IN: prodId AND Account_gne__c IN: accIds AND Signature_Status_gne__c = 'Overdue - Freeze 60 days or greater late'];
    }

    public static List<SFA2_PFG_Storage_Location_gne__c> getStorageLocations(Set<Id> slIds) {
        return  [
        SELECT
            Id,
            Name,
            User_gne__c,
            Manager_gne__c,
            Address_Line_1_gne__c,
            Address_Line_2_gne__c,
            Zip_gne__c,
            City_gne__c,
            State_gne__c,
            Phone_gne__c,
            Is_Manager_gne__c,
            Status_gne__c,
            User_gne__r.Name,
            DM_Name_gne__c,
            CS_Name_gne__c,
            Location_gne__c,
            CreatedDate
        FROM SFA2_PFG_Storage_Location_gne__c
        WHERE Id in :slIds
        ];
    }

    public static Map<Id, SFA2_PFG_Storage_Location_gne__c> getStorageLocationsStatusesMap(List<String> slIds)
    {
        return new Map<Id, SFA2_PFG_Storage_Location_gne__c>([
        Select
            Id,
            Name,
            Status_gne__c
        From SFA2_PFG_Storage_Location_gne__c
        Where Id IN: slIds
        ]);
    }

    public static List<SFA2_PFG_Storage_Location_gne__c> getStorageLocationsStatuses(Set<Id> slIds)
    {
        return [
        Select
            Id,
            Name,
            Status_gne__c
        From SFA2_PFG_Storage_Location_gne__c
        Where Id IN: slIds
        ];
    }
    public static List<SFA2_PFG_Storage_Location_gne__c> getStorageLocationsByUserIds(Set<Id> userIds) {
        return  [
        SELECT
            Id,
            Name,
            User_gne__c,
            Manager_gne__c,
            Address_Line_1_gne__c,
            Address_Line_2_gne__c,
            Zip_gne__c,
            City_gne__c,
            State_gne__c,
            Phone_gne__c,
            Is_Manager_gne__c,
            Status_gne__c,
            User_gne__r.Name,
            DM_Name_gne__c,
            CS_Name_gne__c,
            Location_gne__c,
            CreatedDate
        FROM SFA2_PFG_Storage_Location_gne__c
        WHERE User_gne__c in :userIds
        ];
    }

    public static List<SFA2_PFG_Storage_Location_gne__c> getStorageLocationsByManagerIds(Set<Id> mgrIds, Set<String> statuses) {
        return  [
        SELECT
            Id,
            Name,
            User_gne__c,
            Manager_gne__c,
            Address_Line_1_gne__c,
            Address_Line_2_gne__c,
            Zip_gne__c,
            City_gne__c,
            State_gne__c,
            Phone_gne__c,
            Is_Manager_gne__c,
            Status_gne__c,
            User_gne__r.Name,
            DM_Name_gne__c,
            CS_Name_gne__c,
            Location_gne__c,
            CreatedDate
        FROM SFA2_PFG_Storage_Location_gne__c
        WHERE Manager_gne__c in :mgrIds
            AND Status_gne__c IN :statuses
        ORDER BY Status_gne__c, Manager_gne__r.Name, User_gne__r.Name
        ];
    }

    public static Call_PFG_Detail_gne__c getCallDetailById(String id){
        return [SELECT Lot_No_gne__c, Product_gne__c, Quantity_gne__c FROM Call_PFG_Detail_gne__c where id=:id limit 1];
    }

    public static List<Call_PFG_Detail_gne__c> getCallDetailsByCallIds(Set<Id> callIds){
        return [
        SELECT
            Call_gne__c,
            Account_gne__c,
            Lot_No_gne__c,
            Product_gne__c,
            Product_gne__r.NDC_Number_gne__c,
            Product_gne__r.Name,
            Quantity_gne__c,
            DTP_AOC_Status_gne__c,
            Shipment_ID_gne__c,
            Order_Status_gne__c
        FROM Call_PFG_Detail_gne__c
        WHERE Call_gne__c IN :callIds
        ORDER BY Product_gne__r.Name asc, Lot_No_gne__c];
    }

    public static List<Call_PFG_Detail_gne__c> getCallDetailByIds(Set<Id> ids){
        return [
        SELECT
            Call_gne__c,
            Call_gne__r.OwnerId,
            Call_gne__r.Parent_Address_vod__c,
            Call_gne__r.Parent_Address_vod__r.Name,
            Call_gne__r.Parent_Address_vod__r.Address_Line_2_vod__c,
            Call_gne__r.Parent_Address_vod__r.City_vod__c,
            Call_gne__r.Parent_Address_vod__r.State_vod__c,
            Call_gne__r.Parent_Address_vod__r.Zip_vod__c,
            Call_gne__r.Parent_Address_vod__r.Designation_gne__c,
            Call_gne__r.Parent_Address_vod__r.License_vod__c,
            Call_gne__r.PFG_BDTD_gne__c,
            Call_gne__r.Territory_vod__c,
            Call_gne__r.Request_Signature_gne__c,
            Call_gne__r.Request_Signature_Date_gne__c,
            Call_gne__r.Signature_vod__c,
            Call_gne__r.Signature_Date_vod__c,
            Call_gne__r.Disclaimer_vod__c,
            Call_gne__r.HCP_Specialty_gne__c,
            Owner_calc_gne__c,
            Account_gne__c,
            Account_gne__r.Name,
            Account_gne__r.MDMID_gne__c,
            Date_gne__c,
            Product_gne__c,
            Product_gne__r.Name,
            Product_gne__r.NDC_Number_gne__c,
            Lot_No_gne__c,
            Distribution_Method_gne__c,
            Quantity_gne__c,
            DTP_AOC_Status_gne__c,
            Shipment_ID_gne__c,
            Order_Status_gne__c
        FROM Call_PFG_Detail_gne__c
        WHERE Id IN :ids];
    }

    public static List<SFA2_PFG_Transaction_gne__c> getTransactionById(String id){
        return getTransactions(null,null,
            new List<WhereStatementWrapper>{
                new WhereStatementWrapper('Id', '=', id)
            },null);
    }

    public static List<User> getUserById(String id){
        return [
        SELECT
            AccountId,
            City,
            Country,
            Email,
            FirstName,
            Id,
            IsActive,
            LastName,
            Is_User_On_LOA_Calc_gne__c,
            PFG_Uncertified_Flag_gne__c,
            Username,
            UserType
        FROM User
        WHERE Id=:id
        ];
    }
    public static List<PFG_Staging_Account_Limit_Exception_gne__c> getAccountExceptionLimit(Set<Id> accountsIds, Set<Id> productsIds, Set<String> limitYears)
    {
        return [
                Select
                    Id,
                    Account_gne__c,
                    Exception_Quantity_gne__c,
                    Limit_Year_gne__c,
                    Logical_Delete_Flag_gne__c,
                    Product_gne__c,
                    CreatedDate,
                    LastModifiedDate
                From PFG_Staging_Account_Limit_Exception_gne__c
                Where Account_gne__c IN :accountsIds
                AND Product_gne__c IN :productsIds
                AND Limit_Year_gne__c IN :limitYears
                AND Logical_Delete_Flag_gne__c = false
               ];
    }
    public static List<SFA2_PFG_Product_Limit_gne__c> getProductLimit(Set<Id> productsIds, Set<String> limitYears)
    {
        return [
                Select
                    Id,
                    Limit_Quantity_gne__c,
                    Limit_Year_gne__c,
                    Product_gne__c,
                    Inactive_gne__c,
                    CreatedDate,
                    LastModifiedDate
                From SFA2_PFG_Product_Limit_gne__c
                Where Product_gne__c IN :productsIds
                AND Limit_Year_gne__c IN :limitYears
               ];
    }

    public static List<RecordType> getRecordTypeByName(String recordTypeName){

        return [
                SELECT Id, Name
                FROM RecordType
                WHERE Name =:recordTypeName
                ];
    }

    public static List<SFA2_PFG_Transaction_gne__c> getTransactionsByInteractionId(Set<Id> ids){
        return [
                SELECT
                    Transaction_Type_gne__c,
                    Call_PFG_Detail_ID_gne__c,
                    From_User_gne__c,
                    To_User_gne__c ,
                    Product_gne__c,
                    Lot_No_gne__c
                FROM SFA2_PFG_Transaction_gne__c
                WHERE Call_PFG_Detail_ID_gne__c IN :ids
                ];
    }

    public static List<UserTerritory2Association> getUsersTerritories(Set<Id> userIds)
    {
        return [Select Territory2Id from UserTerritory2Association where UserId IN: userIds];
    }

    public static List<Vendor_gne__c> getVendorsForBrands( Set<Id> brandIds, Boolean activeFlag, Boolean primaryShipperFlag) {
        return [
        SELECT
            Id,
            Name,
            Address_Line_1_gne__c,
            Address_Line_2_gne__c,
            City_gne__c,
            State_gne__c,
            Vendor_Name_gne__c,
            Zip_gne__c,
            (SELECT
                Brand_gne__c,
                Brand_gne__r.Name,
                Primary_Shipper_Flag_gne__c,
                Active_Flag_gne__c
             FROM BrandVendors__r
             WHERE Brand_gne__c IN :brandIds
                AND Primary_Shipper_Flag_gne__c = :primaryShipperFlag
                AND Active_Flag_gne__c = :activeFlag)
        FROM Vendor_gne__c
        WHERE
            Id IN (SELECT Vendor_Name_gne__c
                    FROM BrandVendor_gne__c
                    WHERE Brand_gne__c IN :brandIds
                        AND Primary_Shipper_Flag_gne__c = :primaryShipperFlag
                        AND Active_Flag_gne__c = :activeFlag)
            AND Active_Flag_gne__c = :activeFlag
        ];
    }

    public static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountsForUsers(Set<Id> userIds) {
        return [SELECT
            Name,
            Inventory_Ref_Number_gne__c,
            Inventory_Id_gne__c,
            Inventory_Type_gne__c,
            Submitted_Date_gne__c
        FROM SFA2_PFG_Inventory_Count_gne__c
        WHERE Inventory_For_gne__c IN :userIds
        ORDER BY LastModifiedDate desc
        ];
    }

    public static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountName(Id invCountId) {
        return [
        SELECT
            Id,
            Name
        FROM SFA2_PFG_Inventory_Count_gne__c
        WHERE
            Id = :invCountId
        ];
    }

    public static String getInventoryCountRefNo(Id icId) {
        return [SELECT
            Inventory_Ref_Number_gne__c
        FROM SFA2_PFG_Inventory_Count_gne__c
        WHERE Id = :icId
        LIMIT 1].Inventory_Ref_Number_gne__c;
    }

    public static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountsByRefNo(String refNo) {
        return [
        SELECT
            Id,
            Name,
            Count_gne__c,
            Expiration_Date_gne__c,
            Lot_gne__c,
            NDC_gne__c,
            Product_gne__c,
            Product_gne__r.Name,
            Status_gne__c,
            UOM_gne__c,
            CreatedById,
            Inventory_Count_Date_gne__c,
            Inventory_Ref_Number_gne__c,
            Inventory_Type_gne__c
        FROM SFA2_PFG_Inventory_Count_gne__c
        WHERE
            Inventory_Ref_Number_gne__c = :refNo
        ORDER BY Product_gne__r.Name
        ];
    }

    public static List<SFA2_PFG_to_Territory_Detail_gne__c> getPFGtoTerritoryDetailsByTerritoryAndProduct(Set<String> terrNames, Set<Id> prodIds, Set<Integer> years)
    {
        return [
        SELECT
            Id,
            Name,
            CreatedById,
            CreatedDate,
            LastModifiedById,
            LastModifiedDate,
            Active_gne__c,
            Distribution_Method_gne__c,
            Expiration_Date_gne__c,
            Lot_NO_gne__c,
            Merged_gne__c,
            Product_gne__c,
            Qty_Adjusted_gne__c,
            Qty_Reserved_gne__c,
            Qty_Shipped_to_Physician_gne__c,
            Qty_Total_Allocated_gne__c,
            Qty_Total_Available_gne__c,
            Region_Code_gne__c,
            Territory_gne__c,
            Territory_Name_gne__c,
            Territory_Number_gne__c,
            UOM_gne__c,
            YTD_Allocated_gne__c,
            Year_gne__c
        FROM SFA2_PFG_to_Territory_Detail_gne__c
        WHERE
            Territory_Name_gne__c IN: terrNames AND Product_gne__c IN: prodIds AND Year_gne__c IN :years
        ];
    }

    public static List<SFA2_PFG_to_Territory_Detail_gne__c> getPFGtoTerritoryDetailsByTerritoryName(Set<String> terrNames, Set<Integer> years)
    {
        return [
        SELECT
            Id,
            Name,
            CreatedById,
            CreatedDate,
            LastModifiedById,
            LastModifiedDate,
            Active_gne__c,
            Distribution_Method_gne__c,
            Expiration_Date_gne__c,
            Lot_NO_gne__c,
            Merged_gne__c,
            Product_gne__c,
            Product_gne__r.Name,
            Product_gne__r.NDC_Number_gne__c,
            Qty_Adjusted_gne__c,
            Qty_Reserved_gne__c,
            Qty_Shipped_to_Physician_gne__c,
            Qty_Total_Allocated_gne__c,
            Qty_Total_Available_gne__c,
            Region_Code_gne__c,
            Territory_gne__c,
            Territory_Name_gne__c,
            Territory_Number_gne__c,
            UOM_gne__c,
            YTD_Allocated_gne__c,
            Year_gne__c
        FROM SFA2_PFG_to_Territory_Detail_gne__c
        WHERE
            Territory_Name_gne__c IN: terrNames AND Year_gne__c IN :years
        ORDER BY Product_gne__r.Name
        ];
    }

    public static List<ProcessInstance> getApprovalProcessesForTargets(Set<Id> targetIds, Set<String> statuses) {
        return [
        SELECT
            Status,
            TargetObject.Name,
            TargetObjectId,
            TargetObject.Type,
            LastModifiedDate,
            LastModifiedBy.Name,
            (SELECT
                Actor.Id,
                Actor.Name,
                Actor.Email,
                CreatedDate,
                OriginalActor.Id,
                OriginalActor.Name,
                OriginalActor.Email,
                StepStatus,
                ProcessInstance.Status
            FROM Steps
            ORDER BY CreatedDate desc LIMIT 1),
            (SELECT
                Actor.Id,
                Actor.Name,
                Actor.Email,
                CreatedDate,
                OriginalActor.Id,
                OriginalActor.Name,
                OriginalActor.Email,
                ProcessInstance.Status
            FROM Workitems
            ORDER BY CreatedDate desc LIMIT 1)
        FROM ProcessInstance
        WHERE TargetObjectId IN :targetIds
            AND Status IN :statuses
        ORDER BY TargetObjectId, LastModifiedDate desc
        ];
    }
    public static List<SFA2_User_Sales_Roster_gne__c> getHomeOfficeUsers()
    {
        return
        [
            Select
                User_gne__r.Email
            From
                SFA2_User_Sales_Roster_gne__c
            Where
                Role_gne__c =: GNE_SFA2_PFG_Util.USER_ROLE_MANAGER
        ];
    }
    public static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountForUser(Set<Id> userIds)
    {
        return
        [
            Select
                Count_gne__c,
                Inventory_For_gne__c,
                Product_gne__c
            From
                SFA2_PFG_Inventory_Count_gne__c
            Where
                Inventory_For_gne__c =: userIds
        ];
    }

    public static List<Address_vod__c> getAddressSLN(Set<Id> addrIds) {
    	return
    	[
    		SELECT
    			License_Valid_To_Sample_vod__c
    		FROM
    			Address_vod__c
    		WHERE
    			Id IN :addrIds
    	];
    }
}