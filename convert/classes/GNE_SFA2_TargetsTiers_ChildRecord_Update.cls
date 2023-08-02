/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/31/2012
*  Description: This class GNE_SFA2_TargetsTiers_ChildRecord_Update handles updates Dependent objects and Referenced objects on Targets_and_Tiers_can_gne__c object on DML operations
*  This class is being used in GNE_SFA2_Targets_and_Tiers_Trigger trigger
*  
*  Modification History
*  Date        Name        			Description
*  31.10.2014  Lukasz Bieniawski    Logic optimized and new conditions added - more fields determine value for the TSF_vod__c.My_Target_vod__c flag per SFA-903 requirement
*************************************************************/

public without sharing class GNE_SFA2_TargetsTiers_ChildRecord_Update {
	
	public static void OnAfterUpdate(Map<Id,Targets_and_Tiers_can_gne__c> oldTargetsMap,  List<Targets_and_Tiers_can_gne__c> newTargetsList){
		updateTSF(oldTargetsMap, newTargetsList);
	}
		
	private static void updateTSF(Map<Id, Targets_and_Tiers_can_gne__c> oldTargetsMap, List<Targets_and_Tiers_can_gne__c> newTargetList){
		Set<Id> accountIds = new Set<Id>();
		Set<String> territoriesNames = new Set<String>();
		Set<String> scopeExternalIds = new Set<String>();
		String externalId;
		
		for(Targets_and_Tiers_can_gne__c tnt : newTargetList){
			externalId = getExternalId(tnt.Account_can_gne__c, tnt.Territory_gne__c);
			if (scopeExternalIds.contains(externalId)){
				continue;
			}
			scopeExternalIds.add(externalId);
			accountIds.add(tnt.Account_can_gne__c);
		    territoriesNames.add(tnt.Territory_gne__c);
	    }
	    
	    Set<String> myTargetExternalIds = new Set<String>();	    
	    for (AggregateResult myTargetRow : [SELECT Account_can_gne__c accountId, Territory_gne__c territoryName FROM Targets_and_Tiers_can_gne__c
	    	Where Product_Catalog_gne__c <> null
				AND Account_can_gne__c IN :accountIds
				AND Territory_gne__c IN :territoriesNames
				AND Account_can_gne__c <> null AND Territory_gne__c <> null 
				AND (My_Target_gne__c <> null OR Target_gne__c <> null OR Segment_gne__c <> null OR Tier_can_gne__c <> null)
				Group By Territory_gne__c, Account_can_gne__c
				Order By Territory_gne__c, Account_can_gne__c]){
			externalId = getExternalId((String)myTargetRow.get('accountId'), (String)myTargetRow.get('territoryName'));
			if (scopeExternalIds.contains(externalId)){
				myTargetExternalIds.add(externalId);
			}			
		}
		
		Map<Id, TSF_vod__c> tsfsToUpdateMap = new Map<Id, TSF_vod__c>();
		for (TSF_vod__c tsfRecord : [SELECT Id, Account_vod__c, Territory_vod__c, My_Target_vod__c FROM TSF_vod__c
			WHERE Account_vod__c IN :accountIds
			AND Territory_vod__c IN :territoriesNames
			AND Address_vod__c <> null AND Account_vod__c <> null AND Territory_vod__c <> null AND External_Id_vod__c <> null]){
			externalId = getExternalId(tsfRecord.Account_vod__c, tsfRecord.Territory_vod__c);
			if (scopeExternalIds.contains(externalId)){
				tsfRecord.My_Target_vod__c = myTargetExternalIds.contains(externalId);
				tsfsToUpdateMap.put(tsfRecord.Id, tsfRecord);
			}
		}
		
		if (tsfsToUpdateMap.size() > 0){			
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
	    	List<Database.Saveresult> sResults = Database.update(tsfsToUpdateMap.values());
	    	GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
			List<Error_Log_gne__c> errorList = new List<Error_Log_gne__c>();
	    	for (Integer sresultIndex = 0; sresultIndex < sResults.size(); sresultIndex++){
				Database.SaveResult sr = sResults[sresultIndex];
				if (!sr.isSuccess()){
					List<String> errMessages = new List<String>();
					errMessages.add('An error occured during update on tsf record with id: ' + tsfsToUpdateMap.values()[sresultIndex].Id);
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
	
	private static String getExternalId(String accountId, String territoryName){
		return String.format('{0}__{1}',
			new String[]{
				accountId,
				territoryName != null ? territoryName.toUpperCase() : 'null'
			}
		);
	}
	
	private static Error_Log_gne__c createErrorLog(String exMessage){
		if (String.isBlank(exMessage)){
			return null;
		}	
    	if (exMessage.length() > 4000){
    		exMessage = exMessage.substring(0, 4000);
    	}    	
    	return new Error_Log_gne__c(
    		Object_Name__c = String.valueOf(Targets_and_Tiers_can_gne__c.getSObjectType()),
    		Error_Level_gne__c = 'Medium',
            Snippet_Name__c = 'GNE_SFA2_TargetsTiers_ChildRecord_Update', 
            Code_Type__c = 'Apex Class',
            Error_Description__c = exMessage,
            User_Name__c = UserInfo.getUserName()
        );
    }
}