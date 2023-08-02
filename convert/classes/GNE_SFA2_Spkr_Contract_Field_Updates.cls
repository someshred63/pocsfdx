public with sharing class GNE_SFA2_Spkr_Contract_Field_Updates {
	
	
	
	public static void onAfterInsert(List<Speaker_Contract_gne__c> triggerNewList){
		updateBrandAffiliations(triggerNewList);
		
	}
	
	public static void onAfterUpdate(List<Speaker_Contract_gne__c> triggerNewList){
		updateBrandAffiliations(triggerNewList);
	}
	
	
	public static void updateBrandAffiliations (List<Speaker_Contract_gne__c> triggerNewList){
		List<String> validAccountID_List = new List<String>();
		Map<String,String> accountID_Date_Map1 = new Map<String,String>();
		Map<String,Date> accountID_Date_Map = new Map<String,Date>();
		Date endDate = null;
		Date beginDate= null;
		String beginDateEndDate='';
		for(Integer i=0;triggerNewList.size()>i;i++){ 
			endDate = triggerNewList[i].End_Date_gne__c;
			endDate = date.newinstance(endDate.year(), endDate.month(), endDate.day()); 
			accountID_Date_Map.put(triggerNewList[i].Contracted_Party_ID__c,endDate);
		}
		UpsertBrandAffiliations.update_InsertSpContractBrandAff_beforeInsertUpdate(accountID_Date_Map);
	}

}