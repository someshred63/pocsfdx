public without sharing class GNE_SFA2_MySetup_ChildRecord_Update {

	public static void OnAfterInsert(List<My_Setup_Products_vod__c> triggerNew){
		stampTsfRecords(triggerNew, true);
	}

	public static void OnAfterUpdate(Map<Id, My_Setup_Products_vod__c> triggerOldMap, Map<Id, My_Setup_Products_vod__c> triggerNewMap){
		stampTsfRecordsOnOwnerChanged(triggerOldMap, triggerNewMap);
	}

	private static void stampTsfRecordsOnOwnerChanged(Map<Id, My_Setup_Products_vod__c> triggerOldMap, Map<Id, My_Setup_Products_vod__c> triggerNewMap){
		List<My_Setup_Products_vod__c> recordsWithOwnerChanged = new List<My_Setup_Products_vod__c>();
		for (Id recordId : triggerNewMap.keyset()){
			if (triggerOldMap.get(recordId).OwnerId != triggerNewMap.get(recordId).OwnerId){
				recordsWithOwnerChanged.add(triggerNewMap.get(recordId));
			}
		}
		if (!recordsWithOwnerChanged.isEmpty()){
			stampTsfRecords(recordsWithOwnerChanged, true);
		}
	}

	/* [SFA-903] This method is needed to stamp territory field record after user setup product added in case of OTR delta future - only for Canada users.
	   [SFA-1291] Need to stamp child territories for Sales Managers users also - their have been included in the My HCP view. */

	public static void stampTsfRecords(List<My_Setup_Products_vod__c> records, Boolean isTriggerMode){
		Set<Id> productsAdded = new Set<Id>();
		Set<Id> userList = new Set<Id>();
		Set<Id> userIdsWithChildTerritoriesIncluded = new Set<Id>();

		if(isTriggerMode && GNE_SFA2_Util.getUserProfileName(UserInfo.getUserId()) == 'RCanada-SYS-AutomatedJob') {
			return;
		}

		for(My_Setup_Products_vod__c productAdded : [Select Id, Product_vod__c, OwnerId, Owner.Profile.Name From My_Setup_Products_vod__c
			Where Id In :records And Product_vod__c != null And Owner.Profile.Name Like '%Canada%' And (Not Owner.Profile.Name Like '%SYS%')]){
			productsAdded.add(productAdded.Product_vod__c);
			if (GNE_SFA2_MyAccounts_Controller.hasExtendedMyHcpByTargetAndTiersView(productAdded.Owner.Profile.Name)){
				userIdsWithChildTerritoriesIncluded.add(productAdded.OwnerId);
			} else {
				userList.add(productAdded.OwnerId);
			}
	    }

	    if (productsAdded.size() == 0){
	    	return;
	    }

	    Set<String> userTerritoriesNames = new Set<String>();
	    if (userList.size() > 0){
	    	for (Territory2 territory : [SELECT Name FROM Territory2 WHERE Id in (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId In :userList)]){
	    		userTerritoriesNames.add(territory.Name);
	    	}
	    }
	    if (userIdsWithChildTerritoriesIncluded.size() > 0){
	    	List<Territory2> topLevelTerritories = [SELECT Id, Name FROM Territory2 WHERE Id in (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId In :userIdsWithChildTerritoriesIncluded)];
	    	if (topLevelTerritories.size() > 0){
	    		Set<Territory2> allLevelTerritories = new Set<Territory2>();
	    		allLevelTerritories.addAll(topLevelTerritories);
	    		GNE_SFA2_Util.getChildrenTerritories(topLevelTerritories, allLevelTerritories);
	    		for (Territory2 territory : allLevelTerritories){
	    			userTerritoriesNames.add(territory.Name);
	    		}
	    	}
	    }

	    if (userTerritoriesNames.size() == 0){
	    	return;
	    }

	    List<TSF_vod__c> tsfsToStamp = new List<TSF_vod__c>();
	    for (TSF_vod__c tsfRow : [Select Id, My_Target_vod__c From TSF_vod__c Where Address_vod__c <> null AND Account_vod__c <> null AND Territory_vod__c <> null AND External_Id_vod__c <> null AND My_Target_vod__c = true
	    	AND Id In (SELECT Territory_Field_parent_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Territory_gne__c In :userTerritoriesNames AND Product_Catalog_gne__c In :productsAdded
	    	AND (My_Target_gne__c <> null OR Target_gne__c <> null OR Segment_gne__c <> null OR Tier_can_gne__c <> null))]){
			tsfRow.My_Target_vod__c = true;
			tsfsToStamp.add(tsfRow);
		}

		if (tsfsToStamp.size() > 0){
			// Just want to update lastModifiedDate on tsf records, nothing more
			GNE_SFA2_TSF_Trigger_Helper.setTSFTrig(true);
			Database.SaveResult[] sResults = Database.update(tsfsToStamp, false);
			GNE_SFA2_TSF_Trigger_Helper.setTSFTrig(false);

			List<Error_Log_gne__c> errorList = new List<Error_Log_gne__c>();
	    	for (Integer sresultIndex = 0; sresultIndex < sResults.size(); sresultIndex++){
				Database.SaveResult sr = sResults[sresultIndex];
				if (!sr.isSuccess()){
					List<String> errMessages = new List<String>();
					errMessages.add('An error occured during update on tsf record with id: ' + tsfsToStamp[sresultIndex].Id);
					for(Database.Error err : sr.getErrors()) {
						errMessages.add(err.getMessage());
					}
					String errMessage = String.join(errMessages, ';');
					Error_Log_gne__c errLog = createErrorLog(errMessage);
					if (errLog != null){
						errorList.add(errLog);
					}
				}
			}
			if (errorList.size() > 0){
				insert errorList;
			}
		}
	}

	private static Error_Log_gne__c createErrorLog(String exMessage){
		if (String.isBlank(exMessage)){
			return null;
		}
    	if (exMessage.length() > 4000){
    		exMessage = exMessage.substring(0, 4000);
    	}
    	return new Error_Log_gne__c(
    		Object_Name__c = String.valueOf(My_Setup_Products_vod__c.getSObjectType()),
    		Error_Level_gne__c = 'Medium',
            Snippet_Name__c = 'GNE_SFA2_MySetup_ChildRecord_Update',
            Code_Type__c = 'Apex Class',
            Error_Description__c = exMessage,
            User_Name__c = UserInfo.getUserName()
        );
    }
}