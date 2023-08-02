public class GNE_SFA2_PREP_DAO {

	public static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getActiveForAccountStrategiesByIds(Set<Id> accStrategyIds) {
		return getAccountStrategiesByIds(accStrategyIds, true);
	}

    private static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getAccountStrategiesByIds(Set<Id> accStrategyIds, Boolean activeForAccount) {
        String accRelName = SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c.getDescribe().getRelationshipName();
        String strategyRelName = SFA2_PREP_Account_Testing_Strategy_gne__c.Testing_Strategy_gne__c.getDescribe().getRelationshipName();
        String stratProdRelName = SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c.getDescribe().getRelationshipName();
        String childToParentRelName = SFA2_PREP_Account_MBO_gne__c.Account_Testing_Strategy_gne__c.getDescribe().getRelationshipName();
        String childToMboRelName = SFA2_PREP_Account_MBO_gne__c.MBO_gne__c.getDescribe().getRelationshipName();
        String mboToStratRelName = SFA2_PREP_MBO_gne__c.Testing_Strategy_ref_gne__c.getDescribe().getRelationshipName();
        String parentToChildRelName = 'Account_MBOs_gne__r';

        String queryParent = String.format('SELECT Id, {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9} ',
        	new String[]{
                String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Status_gne__c),												// 0
                String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c),												// 1
                String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Testing_Strategy_gne__c),										// 2
                strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Order_gne__c),									// 3
                strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c),  								// 4
                strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Account_gne__c),					// 5
                strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Call_gne__c),						// 6
                strategyRelName + '.' + stratProdRelName + '.Name',                														// 7
                strategyRelName + '.Name',																								// 8
                accRelName + '.' + String.valueOf(Account.PREP_Status_gne__c)															// 9
        	}
        );

        String queryChild = String.format('SELECT Id, {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14} FROM {15} ',
        	new String[]{
        		String.valueOf(SFA2_PREP_Account_MBO_gne__c.Status_gne__c),																// 0
        		String.valueOf(SFA2_PREP_Account_MBO_gne__c.Account_Testing_Strategy_gne__c),											// 1
        		String.valueOf(SFA2_PREP_Account_MBO_gne__c.MBO_gne__c),																// 2
        		childToParentRelName + '.' + String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c),                	// 3
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Short_Description_gne__c),								// 4
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Definition_gne__c),										// 5
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Default_Status_gne__c),									// 6
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Testing_Strategy_ref_gne__c),								// 7
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Account_gne__c),								// 8
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Call_gne__c),									// 9
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_gne__c),											// 10 - Deprecated
                childToMboRelName + '.' + mboToStratRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c),	// 11
                childToMboRelName + '.' + mboToStratRelName + '.' + stratProdRelName + '.Name',											// 12
                childToMboRelName + '.' + mboToStratRelName + '.Name',																	// 13
                childToMboRelName + '.Name',																							// 14
                parentToChildRelName																									// 15
        	}
        );

        String whereParent = 'WHERE Id In :accStrategyIds ';
        String whereChild = '';

        if (activeForAccount == true){
        	whereParent += String.format('AND {0} = true ',
        		new String[]{
        			strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Account_gne__c)					// 0
        		}
        	);
        	whereChild = String.format('WHERE {0} = true ',
        		new String[]{
        			childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Account_gne__c)							// 0
        		}
        	);
        	queryChild += whereChild;
        }

        String query = String.format('{0}, ({1}) FROM SFA2_PREP_Account_Testing_Strategy_gne__c {2}',
        	new String[]{
        		queryParent,																											// 0
        		queryChild,																												// 1
        		whereParent																												// 2
        	}
        );

        return Database.query(query);
    }

    public static List<Account> getAccountsWithStatus(Set<Id> accIds) {
        return [
            SELECT
                Id,
                Name,
                PREP_Status_gne__c,
                IsPersonAccount,
                RecordType.Name
            FROM Account
            WHERE Id IN :accIds
        ];
    }

    public static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getActiveForAccountStrategies(Set<Id> accIds) {
    	return getAccountStrategies(accIds, true);
    }

    private static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getAccountStrategies(Set<Id> accIds, Boolean activeForAccount) {
        String accRelName = SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c.getDescribe().getRelationshipName();
        String strategyRelName = SFA2_PREP_Account_Testing_Strategy_gne__c.Testing_Strategy_gne__c.getDescribe().getRelationshipName();
        String stratProdRelName = SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c.getDescribe().getRelationshipName();
        String childToParentRelName = SFA2_PREP_Account_MBO_gne__c.Account_Testing_Strategy_gne__c.getDescribe().getRelationshipName();
        String childToMboRelName = SFA2_PREP_Account_MBO_gne__c.MBO_gne__c.getDescribe().getRelationshipName();
        String mboToStratRelName = SFA2_PREP_MBO_gne__c.Testing_Strategy_ref_gne__c.getDescribe().getRelationshipName();
        String parentToChildRelName = 'Account_MBOs_gne__r';

        String queryParent = String.format('SELECT Id, {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10} ',
        	new String[]{
        		String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Status_gne__c),								// 0
            	String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.iPhone_Request_Id_gne__c),						// 1
            	String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c),								// 2
            	String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Testing_Strategy_gne__c),						// 3
            	strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Order_gne__c),					// 4
            	strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c),            	// 5
            	strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Account_gne__c),	// 6
            	strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Call_gne__c),		// 7
            	strategyRelName + '.Name',																				// 8
            	strategyRelName + '.' + stratProdRelName + '.Name',														// 9
            	accRelName + '.' + String.valueOf(Account.PREP_Status_gne__c)											// 10
        	}
        );

        String queryChild = String.format('SELECT Id, {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15} FROM {16} ',
        	new String[]{
        		String.valueOf(SFA2_PREP_Account_MBO_gne__c.Status_gne__c),																// 0
                String.valueOf(SFA2_PREP_Account_MBO_gne__c.Account_Testing_Strategy_gne__c),											// 1
                String.valueOf(SFA2_PREP_Account_MBO_gne__c.iPhone_Request_Id_gne__c),													// 2
                String.valueOf(SFA2_PREP_Account_MBO_gne__c.MBO_gne__c),																// 3
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Short_Description_gne__c),								// 4
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Definition_gne__c),										// 5
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Default_Status_gne__c),									// 6
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Testing_Strategy_ref_gne__c),								// 7
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Account_gne__c),								// 8
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Call_gne__c),									// 9
                childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_gne__c),                							// 10 - Deprecated
                childToMboRelName + '.' + mboToStratRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c),	// 11
                childToMboRelName + '.' + mboToStratRelName + '.' + stratProdRelName + '.Name',                    						// 12
                childToMboRelName + '.' + mboToStratRelName + '.Name',                													// 13
                childToMboRelName + '.Name',																							// 14
                childToParentRelName + '.' + String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c),					// 15
                parentToChildRelName																									// 16
        	}
        );

        String whereParent = String.format('WHERE {0} In: accIds ',
        	new String[]{
        		String.valueOf(SFA2_PREP_Account_Testing_Strategy_gne__c.Account_gne__c)												// 0
        	}
        );
        String whereChild = '';

        if (activeForAccount == true){
        	whereParent += String.format('AND {0} = true ',
        		new String[]{
        			strategyRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Account_gne__c)					// 0
        		}
        	);
        	whereChild = String.format('WHERE {0} = true ',
        		new String[]{
        			childToMboRelName + '.' + String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Account_gne__c)							// 0
        		}
        	);
        	queryChild += whereChild;
        }

        String query = String.format('{0}, ({1}) FROM SFA2_PREP_Account_Testing_Strategy_gne__c {2}',
        	new String[]{
        		queryParent,
        		queryChild,
        		whereParent
        	}
        );

        return Database.query(query);
    }

    public static List<SFA2_PREP_Account_MBO_gne__c> getAccountMBOs(Set<Id> accStrategyIds) {
        return [
            SELECT
                Id,
                Status_gne__c,
                Account_Testing_Strategy_gne__c,
                Account_Testing_Strategy_gne__r.Status_gne__c
            FROM SFA2_PREP_Account_MBO_gne__c
            WHERE Account_Testing_Strategy_gne__c IN :accStrategyIds
        ];
    }

    public static List<SFA2_PREP_Testing_Strategy_gne__c> getTestingStrategiesWithMBOs(Boolean activeForAccount, Boolean activeForCall) {
    	String prodRelName = SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c.getDescribe().getRelationshipName();
    	String parentToChildRelName = 'MBOs_gne__r';
    	String childToParentRelName = SFA2_PREP_MBO_gne__c.Testing_Strategy_ref_gne__c.getDescribe().getRelationshipName();

    	String queryParent = String.format('SELECT Id, Name, {0}, {1}, {2}, {3}, {4}, {5}, {6} ',
    		new String[]{
                String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Order_gne__c), 								// 0
                String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Region_Code_gne__c), 							// 1
                String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.External_Id_gne__c),							// 2
                String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c),								// 3
                String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Account_gne__c),					// 4
                String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Call_gne__c),						// 5
                prodRelName + '.Name'																			// 6
    		}
    	);

    	String queryChild = String.format('SELECT Id, Name, {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11} FROM {12} ',
    		new String[]{
    			String.valueOf(SFA2_PREP_MBO_gne__c.Short_Description_gne__c),									// 0
    			String.valueOf(SFA2_PREP_MBO_gne__c.Definition_gne__c), 										// 1
                String.valueOf(SFA2_PREP_MBO_gne__c.Default_Status_gne__c),										// 2
                String.valueOf(SFA2_PREP_MBO_gne__c.Region_Code_gne__c), 										// 3
                String.valueOf(SFA2_PREP_MBO_gne__c.External_Id_gne__c),										// 4
                String.valueOf(SFA2_PREP_MBO_gne__c.Testing_Strategy_ref_gne__c),								// 5
                String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Account_gne__c),									// 6
                String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Call_gne__c),									// 7
                String.valueOf(SFA2_PREP_MBO_gne__c.Active_gne__c),												// 8 - Deprecated
                childToParentRelName + '.Name',																	// 9
                childToParentRelName + '.' + String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Product_gne__c),	// 10
                childToParentRelName + '.' + prodRelName + '.Name',                								// 11
                parentToChildRelName																			// 12
    		}
    	);

    	String whereParent = '';
    	String whereChild = '';

    	if (activeForAccount == true){
    		whereParent = String.format('WHERE {0} = true ',
    			new String[]{
    				String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Account_gne__c)					// 0
    			}
    		);
    		whereChild = String.format('WHERE {0} = true ',
    			new String[]{
    				String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Account_gne__c)								// 0
    			}
    		);
    	}
    	if (activeForCall == true){
    		if (String.isNotBlank(whereParent)){
    			whereParent += 'AND ';
    		} else {
    			whereParent = 'WHERE ';
    		}
    		whereParent = String.format('{0} = true ',
    			new String[]{
    				String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Active_for_Call_gne__c)					// 0
    			}
    		);
    		if (String.isNotBlank(whereChild)){
    			whereChild += 'AND ';
    		} else {
    			whereChild = 'WHERE ';
    		}
    		whereChild += String.format('{0} = true ',
    			new String[]{
    				String.valueOf(SFA2_PREP_MBO_gne__c.Active_for_Call_gne__c)									// 0
    			}
    		);
    	}
    	if (String.isNotBlank(whereChild)){
    		queryChild += whereChild;
    	}

    	queryChild += String.format('ORDER BY {0} ',
    		new String[]{
    			String.valueOf(SFA2_PREP_MBO_gne__c.Order_gne__c)												// 0
    		}
    	);

    	String query = String.format('{0}, ({1}) FROM SFA2_PREP_Testing_Strategy_gne__c {2} Order By {3}, Name',
    		new String[]{
    			queryParent,																					// 0
    			queryChild,																						// 1
    			whereParent,																					// 2
    			String.valueOf(SFA2_PREP_Testing_Strategy_gne__c.Order_gne__c)									// 3
    		}
    	);

    	return Database.query(query);
    }

    public static List<SFA2_PREP_Account_Testing_Info_gne__c> getTestingInfos(Set<Id> accIds) {
        return [
            SELECT
                Id,
                Name,
                Account_gne__c,
                External_Id_calc_gne__c,
                External_Id_gne__c,
                MDT_Lead_gne__c,
                Percent_of_Global_gne__c,
                Percent_of_TC_gne__c,
                Referred_Account_gne__c,
                Referred_Account_gne__r.Name,
                Region_Code_gne__c,
                Stage_Tested_gne__c,
                Test_Component_gne__c,
                Test_Hierarchy_gne__c,
                Test_Initiator_gne__c,
                Test_Method_gne__c,
                Test_Type_gne__c,
                Testing_Volume_Month_gne__c
            FROM SFA2_PREP_Account_Testing_Info_gne__c
            WHERE Account_gne__c IN :accIds
            ORDER BY Test_Type_gne__c, Test_Method_gne__c, Test_Hierarchy_gne__c
        ];
    }

    public static List<Account> getAccountsProfTypes(Set<Id> accIds) {
        return [
            SELECT
                Id,
                PREP_Professional_Type_gne__c
            FROM Account
            WHERE Id IN :accIds
        ];
    }

    public static List<Territory2> getTerritories(String rootTerritoryNumber) {
        String terrNumberSelector = '%-' + rootTerritoryNumber + '-%';
        return [
            SELECT
                Id,
                Name
            FROM Territory2
            WHERE External_Id_gne__c like :terrNumberSelector
                AND (NOT(External_Id_gne__c like '%_OLD'))
            ORDER BY External_Id_gne__c
        ];
    }

    public static List<Group> getGroupsForTerritoryIds(Set<Id> terrIds) {
        return [
            SELECT
                Id,
                RelatedId
            FROM Group
            WHERE RelatedId IN : terrIds
                AND Type = 'Territory'
        ];
    }

    public static List<AccountShare> getHcoAccountSharesForGroupIds(Set<Id> groupIds) {
        return [
            SELECT
                AccountId,
                UserOrGroupId
            FROM AccountShare
            WHERE Account.IsPersonAccount = false
                AND UserOrGroupId IN :groupIds
        ];
    }

    public static List<User> getPrepUsers() {
        return [
            SELECT
                Id,
                Name,
                Email,
                Manager.Name,
                Manager.Email
            FROM User
            WHERE IsActive = true
                AND Profile.Name like 'GNE-SFA-PREP-%'
            ORDER BY Name
        ];
    }

    public static User getUser(Id userId) {
        return [
            SELECT
                Id,
                Name,
                Email,
                Manager.Id,
                Manager.Name,
                Manager.Email,
                Profile.Name
            FROM User
            WHERE Id = :userId
        ];
    }

    public static List<Call_PREP_MBO_gne__c> getCallMbos(Id callId) {
        return [
            SELECT
                Id,
                Call_gne__c,
                Mbo_gne__c,
                Mbo_gne__r.Short_Description_gne__c,
                Mbo_gne__r.Active_for_Account_gne__c,
                Mbo_gne__r.Active_for_Call_gne__c,
                Mbo_gne__r.Active_gne__c
            FROM Call_PREP_MBO_gne__c
            WHERE Call_gne__c = :callId
        ];
    }
}