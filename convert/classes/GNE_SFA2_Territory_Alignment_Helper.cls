public without sharing class GNE_SFA2_Territory_Alignment_Helper{

    public static void alignedAccountsMassUpdate(List<TSF_vod__c> tsfs, String territoryId, Boolean myTarget){
    	String territoryName = [SELECT Name FROM Territory2 WHERE Id = :territoryId].Name;
        String groupId = getGroupId(territoryId);
        List<Id>accountIds = new List<Id>();
        // Update TSF
        for(TSF_vod__c tsf: tsfs){
		    tsf.My_Target_vod__c = myTarget;
		    tsf.Is_Self_Alignment_gne__c = true;
		    accountIds.add(tsf.Account_vod__c);
        }
	    update tsfs;

        // Insert Account Share
        List<AccountShare> accountShares = [SELECT Id, AccountId FROM AccountShare WHERE UserOrGroupId =: groupId AND AccountId in :accountIds AND RowCause ='Territory2AssociationManual'];
        Set<Id>accountsWithAccountShare = new Set<Id>();
        for(AccountShare accShare: accountShares){
        	accountsWithAccountShare.add(accShare.AccountId);
        }

        if(accountShares.size() > accountIds.size()) {
        	List<Sharing_Mgmt_gne__c>sharingMgmts = new List<Sharing_Mgmt_gne__c>();
        	for(Id accountId: accountIds){
        		if(!accountsWithAccountShare.contains(accountId)){
	            	Sharing_Mgmt_gne__c sharingMgmt = new Sharing_Mgmt_gne__c(Object_Name_gne__c = 'AccountShare', Account_Id_gne__c = accountId, Territory_Name_gne__c = territoryName, Territory_Id_gne__c = territoryId, Schedule_Date_Time_gne__c = System.Today(), Operation_gne__c = 'Insert', Status_gne__c = 'New');
	            	sharingMgmts.add(sharingMgmt);
        		}
        	}
            insert sharingMgmts;
        }

        // Insert Brand Affiliation
        String territoryCode = getTerritoryCode(territoryName);
        List<Product_Metrics_vod__c> brandAffiliations = getBrandAffiliationsToInsert(territoryCode, accountIds);
        if(brandAffiliations.size() > 0){
            insert brandAffiliations;
        }
       	alignBrandAffiliationsForTLCRM(new Set<Id>(accountIds), territoryId);
    }

    private static Boolean isRemovePossible(
        TSF_vod__c tsf, String userProfileName,
        Map<String,GNE_SFA2_Canadian_Users__c> canadianProfilesMap,
        Map<String,GNE_SFA2_ATLS_Profiles__c> atlsProfilesMap){
        if(userProfileName == tsf.LastModifiedBy.Profile.Name || atlsProfilesMap.containsKey(userProfileName) || canadianProfilesMap.containsKey(userProfileName) || userProfileName.contains('FRM')) {
        	return true;
        }
        return false;
    }

    /*Remove alignment for tsfs. Return list of tsfs which cannot be deleted. */
    public static List<TSF_vod__c> removeAlignmentMassUpdate(List<TSF_vod__c>tsfs, Id territoryId, String userProfileName){
    	Map<String,GNE_SFA2_Canadian_Users__c> canadianProfilesMap = GNE_SFA2_Canadian_Users__c.getAll();
        Map<String,GNE_SFA2_ATLS_Profiles__c> atlsProfilesMap = GNE_SFA2_ATLS_Profiles__c.getAll();

    	String territoryName = [SELECT Name FROM Territory2 WHERE Id = :territoryId].Name;
	 	// Delete Account Share
	 	List<Sharing_Mgmt_gne__c>sharingManagments = new List<Sharing_Mgmt_gne__c>();
	 	List<TSF_vod__c>tsfsToDelete = new List<TSF_vod__c>();
	 	List<TSF_vod__c>ignoredTsfs = new List<TSF_vod__c>();

	 	for(TSF_vod__c tsf: tsfs){
	 		if(isRemovePossible(tsf, userProfileName, canadianProfilesMap, atlsProfilesMap)){
	 			sharingManagments.add(new Sharing_Mgmt_gne__c(Object_Name_gne__c = 'AccountShare', Account_Id_gne__c = tsf.Account_vod__c, Territory_Name_gne__c = territoryName, Territory_Id_gne__c = territoryId, Schedule_Date_Time_gne__c = System.Today(), Operation_gne__c = 'Delete', Status_gne__c = 'New'));
	 			tsfsToDelete.add(tsf);
	 		}else{
	 			ignoredTsfs.add(tsf);
	 		}
	 	}
        // Delete TSF
        try {
	        insert sharingManagments;
            delete tsfsToDelete;
        } catch (Exception e) {
            System.debug('##### Delete TSF === ' + e);
        }
        return ignoredTsfs;
    }

    public static String getTerritoryCode(String territoryName) {
        String terrCode = '';
        try{
        	List<Product_Ind_to_Terr_gne__c> productInd = [SELECT Id, Territory_Code_gne__c, Territory_Code_Size_gne__c FROM Product_Ind_To_Terr_gne__c];
			for(Integer i=0; i < productInd.Size(); i++) {
                Integer terrCodeSize = productInd[i].Territory_Code_Size_gne__c.intValue();
                if (territoryName.Substring(0, terrCodeSize) == productInd[i].Territory_Code_gne__c) {
                    terrCode = productInd[i].Territory_Code_gne__c;
                    break;
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
      return terrCode;
    }

    public static List<Product_Metrics_vod__c> getBrandAffiliationsToInsert(String territoryCode, List<Id>accountIds) {
        List<Product_Metrics_vod__c> brandAffiliationsToInsertList = new List<Product_Metrics_vod__c>();
        if(String.isNotEmpty(territoryCode)) {
            Map<Id, Set<Id>> existingBrandAffiliations = new Map<Id, Set<Id>>();
            for(Product_Metrics_vod__c brandAff : [SELECT Products_vod__c, Account_vod__c FROM Product_Metrics_vod__c WHERE Account_vod__c in :accountIds]) {
            	if(!existingBrandAffiliations.containsKey(brandAff.Products_vod__c)){
            		existingBrandAffiliations.put(brandAff.Products_vod__c, new Set<Id>());
            	}
                existingBrandAffiliations.get(brandAff.Products_vod__c).add(brandAff.Account_vod__c);
            }

            for(Product_Ind_To_Terr_gne__c productInd : [SELECT Product_Indication_Name_gne__c FROM Product_Ind_To_Terr_gne__c WHERE Territory_Code_gne__c = : territoryCode]) {
                if(!existingBrandAffiliations.containsKey(productInd.Product_Indication_Name_gne__c)){
                	for(Id accountId: accountIds){
                    	Product_Metrics_vod__c brandAff = new Product_Metrics_vod__c();
                    	brandAff.Account_vod__c = accountId ;
                    	brandAff.Products_vod__c = productInd.Product_Indication_Name_gne__c ;
                    	brandAffiliationsToInsertList.add (brandAff);
                	}
                }else{
                	Set<Id>accountIdsWithBrandAffiliation = existingBrandAffiliations.get(productInd.Product_Indication_Name_gne__c);
                	for(Id accountId: accountIds){
                		if(!accountIdsWithBrandAffiliation.contains(accountId)){
	                    	Product_Metrics_vod__c brandAff = new Product_Metrics_vod__c();
	                    	brandAff.Account_vod__c = accountId ;
	                    	brandAff.Products_vod__c = productInd.Product_Indication_Name_gne__c ;
	                    	brandAffiliationsToInsertList.add (brandAff);
                		}
                	}
                }
            }
        }
        return brandAffiliationsToInsertList;
    }

    public static void alignBrandAffiliationsForTLCRM(Set<Id> accountIds, String territoryId){
    	if (GNE_SFA2_Util.getCurrentUserProfileName().startsWithIgnoreCase('GNE-TLS')){
        	alignBrandAffiliationsForTLCRMFuture(accountIds, territoryId);
        }
    }

    @future
    private static void alignBrandAffiliationsForTLCRMFuture(Set<Id> accountIds, String territoryId){
    	Boolean proceed = false;
    	Boolean alignmentDone = String.isNotBlank(territoryId);
    	String mySetupQuery = 'SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE Product_vod__c != null AND Product_vod__r.Owner.Name NOT IN (\'GNE-CANADA-INACTIVE-PROD-QUEUE\', \'GNE-INACTIVE-PROD-QUEUE\') ';
    	if (alignmentDone == false){
    		mySetupQuery += 'AND OwnerId = \'' + UserInfo.getUserId() + '\'';
    		proceed = true;
    	} else {
    		String targetTerritoryExtId = null;
    		for (Territory2 territory : [Select Id, External_Id_gne__c From Territory2 Where Id = :territoryId LIMIT 1]){
    			targetTerritoryExtId = territory.External_Id_gne__c;
    		}
    		if (String.isNotBlank(targetTerritoryExtId)){
    	 		Map<Id, Set<Id>> terrIdToUserIdsMap = new Map<Id, Set<Id>>();
    	 		for (UserTerritory2Association userTerritory : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE UserId In (SELECT Id FROM User WHERE Profile.Name Like 'GNE-TLS%' AND IsActive = true)]){
    	 			if (!terrIdToUserIdsMap.containsKey(userTerritory.Territory2Id)){
    	 				terrIdToUserIdsMap.put(userTerritory.Territory2Id, new Set<Id>());
    	 			}
    	 			terrIdToUserIdsMap.get(userTerritory.Territory2Id).add(userTerritory.UserId);
    	 		}
    	 		Set<Id> applyForUserSet = new Set<Id>();
    	 		for (Territory2 territory : [SELECT Id, External_Id_gne__c FROM Territory2 WHERE Id in :terrIdToUserIdsMap.keyset() AND Name != null AND External_id_gne__c != null AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%')]){
   	 				if (String.isNotBlank(territory.External_Id_gne__c) && targetTerritoryExtId.startsWithIgnoreCase(territory.External_Id_gne__c)){
   	 					applyForUserSet.addAll(terrIdToUserIdsMap.get(territory.Id));
   	 				}
    	 		}
    	 		mySetupQuery += 'AND OwnerId In :applyForUserSet';
    	 		proceed = true;
    		}
    	}
    	if (proceed == true) {
    		Set<Id> activeProducts = new Set<Id>();
			for (My_Setup_Products_vod__c userProduct : Database.query(mySetupQuery)){
	 			activeProducts.add(userProduct.Product_vod__c);
			}
			if (activeProducts.size() > 0){
				List<Product_Metrics_vod__c> baToUpdate = new List<Product_Metrics_vod__c>();
				List<Product_Metrics_vod__c> baToInsert = new List<Product_Metrics_vod__c>();
				Set<Id> accBas = new Set<Id>();
				for (Account acc : [SELECT Id, (SELECT Id, Products_vod__c, Brand_Affiliation_Status_gne__c FROM Product_Metrics_vod__r WHERE Products_vod__c In :activeProducts) FROM Account WHERE Id In :accountIds]){
					accBas.clear();
					for (Product_Metrics_vod__c ba : acc.Product_Metrics_vod__r){
						accBas.add(ba.Products_vod__c);
						if (ba.Brand_Affiliation_Status_gne__c != 'Active'){
							ba.Brand_Affiliation_Status_gne__c = 'Active';
							baToUpdate.add(ba);
						}
					}
					Set<Id> productsToAdd = activeProducts.clone();
					productsToAdd.removeAll(accBas);
					for (Id prodId : productsToAdd){
						baToInsert.add(
							new Product_Metrics_vod__c(
   	    						Account_vod__c = acc.Id,
       							Products_vod__c = prodId,
       							Brand_Affiliation_Status_gne__c = 'Active'
       						)
						);
					}
				}
				if (baToUpdate.size() > 0){
					Database.SaveResult[] ur = Database.update(baToUpdate, false);
				}
				if (baToInsert.size() > 0){
					Database.SaveResult[] ir = Database.insert(baToInsert, false);
				}
			}
    	}
    }

    public static String getGroupId(String territoryId) {
        return [SELECT Id  FROM Group WHERE RelatedId =: territoryId AND Type = 'Territory' LIMIT 1].id;
    }
}