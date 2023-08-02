global class Affiliation_alignTerritory {
	@future
	public static void AlignTerritory_fromTrigger(List<Id> triggerNew_Ids) {
		List<Affiliation_vod__c> Affl_list = [SELECT Id, CreatedById, Affiliation_Type_gne__c,
		                                      from_account_vod__c, to_account_vod__c
		                                      FROM Affiliation_vod__c
		                                      WHERE Id in :triggerNew_Ids];
		alignTerritory(Affl_list);
	}

	public static void alignTerritory(List<Affiliation_vod__c> Affl_list) {
		for (Affiliation_vod__c affl : Affl_list) {
			try {
				// Get List of Territories assigned to the logged in User
				List<String> userTerritoryList = new List<String>();
				for (UserTerritory2Association u : [SELECT ut.Territory2Id
				                                    FROM UserTerritory2Association ut
				                                    WHERE ut.UserId = :affl.CreatedById])
					userTerritoryList.add(u.Territory2Id);

				if (userTerritoryList.size() > 0) {
					// Get GroupId of From_Account i.e HCO
					List<String> fromAccount_GroupList = new List<String>();
					for (AccountShare a : [ SELECT UserOrGroupId
					                        FROM AccountShare
					                        WHERE accountId = :affl.From_Account_vod__c])
						fromAccount_GroupList.add(a.UserOrGroupId) ;
						
					if (fromAccount_GroupList.size() > 0 ) {
						// get common Territory list for from_account AND user
						Map<String, String> commonTerritoryMap = new Map<String, String>();
						for (Group g : [SELECT RelatedId, Id
						                FROM Group
						                WHERE Id in :fromAccount_GroupList
						                AND Type = 'Territory'
						                AND RelatedId in :userTerritoryList])
							commonTerritoryMap.put(g.relatedId, g.Id);


						if (commonTerritoryMap.size() > 0 ) {
							//check if To_Affiliated is already aligned to any of these territory

							// get GroupIds for To_account i.e for HCP
							List<String> toAccount_GroupList = new List<String>();
							for (AccountShare a : [ SELECT UserOrGroupId
							                        FROM AccountShare
							                        WHERE accountId = :affl.to_Account_vod__c])
								toAccount_GroupList.add(a.UserOrGroupId) ;

							Set<String> toAccount_TerritoryList = new set<String>();
							if (toAccount_GroupList.size() > 0) {
								// get common Territory list for from_account AND user
								for (Group g : [SELECT RelatedId
								                FROM Group
								                WHERE Id in :toAccount_GroupList
								                AND Type = 'Territory'
								                AND RelatedId in :commonTerritoryMap.keyset()])
									toAccount_TerritoryList.add(g.RelatedId);
							}

							List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
							for (String territoryId : commonTerritoryMap.keyset() ) {
								if (!toAccount_TerritoryList.contains(territoryId)) {
									ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = affl.to_Account_vod__c, Territory2Id = territoryId, AssociationCause='Territory2Manual');
									territoryAssociations.add(territoryAssociation);
								}
							}

							if (territoryAssociations.size() > 0) {
								insert territoryAssociations;
							}
						}
					}
				}
			}
			catch (exception e) {
				System.Debug ('An error occured while ' + e.getMessage());
			}
		}
	}
}