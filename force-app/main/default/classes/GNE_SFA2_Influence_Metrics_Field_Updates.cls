public with sharing class GNE_SFA2_Influence_Metrics_Field_Updates {
	
	public static void onBeforeInsert(List<Influence_Metrics_gne__c> triggerNewList){
		
		populateInfluenceMetricsColumns(triggerNewList);
	}
	
	
	public static void onBeforeUpdate(List<Influence_Metrics_gne__c> triggerNewList){
		
		populateInfluenceMetricsColumns(triggerNewList);
	}
	
	
	public static void  populateInfluenceMetricsColumns(List<Influence_Metrics_gne__c> triggerNewList){
		
		Set<String> mdmIDSet = new Set<String>();
		for (Influence_Metrics_gne__c record : triggerNewList) {
			if (record.Target_Physician_MDM_ID_gne__c != null)
			mdmIDSet.add(record.Target_Physician_MDM_ID_gne__c);     
			if (record.Related_Physician_MDM_ID_gne__c != null)
			mdmIDSet.add(record.Related_Physician_MDM_ID_gne__c);     
		}

		List<Account> accList = [SELECT 
		Id, 
		MDMID_gne__c
		FROM 
		Account 
		WHERE 
		MDMID_gne__c in :mdmIDSet 
		ORDER BY 
		MDMId_gne__c, LastModifiedDate DESC];
		
		if (accList.size() > 0) {
			Map<String, String> mdmToaccountIDMap = new Map<String, String>();
			for (Integer i=0; i < accList.size(); i++) {
				if (!mdmToaccountIDMap.containsKey(accList[i].MDMID_gne__c))
				mdmToaccountIDMap.put(accList[i].MDMID_gne__c, accList[i].Id);
			}
			
			for (Influence_Metrics_gne__c record : triggerNewList) {
				if ((record.Target_Physician_MDM_ID_gne__c != null) && (mdmToaccountIDMap.containsKey(record.Target_Physician_MDM_ID_gne__c)))
				record.Target_Physician_gne__c = mdmToaccountIDMap.get(record.Target_Physician_MDM_ID_gne__c);
				if ((record.Related_Physician_MDM_ID_gne__c != null) && (mdmToaccountIDMap.containsKey(record.Related_Physician_MDM_ID_gne__c)))
				record.Related_Physician_gne__c = mdmToaccountIDMap.get(record.Related_Physician_MDM_ID_gne__c); 
			}
		}
		
		
	}
	

}