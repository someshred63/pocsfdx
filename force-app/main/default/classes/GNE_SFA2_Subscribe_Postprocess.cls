public without sharing class GNE_SFA2_Subscribe_Postprocess implements CORE_Subscribe_Interface.Postporcessor{


	public void processRecords(List<CORE_Pub_Party__c> parties, Map<Id, List<CORE_Pub_External_Id__c>> partyToExtIds,  Map<Id, List<CORE_Pub_Plan_Product__c>> partyToProductPlans, Map<String, Map<String, List<sObject>>>partyToRecords, Map<String, Map<String, List<sObject>>>partyLocationToRecords, Map<String, Map<String, List<sObject>>>extIdToRecords, Map<String, Map<String, List<sObject>>>licenseToRecords, Map<String, Map<String, List<sObject>>>productToRecords){
		for(CORE_Pub_Party__c party: parties){
			if(partyToRecords.containsKey(party.Id) && partyToRecords.get(party.Id).containsKey('Account')){
				List<sObject>accounts = partyToRecords.get(party.Id).get('Account');
				
				for(CORE_Pub_External_Id__c extId : partyToExtIds.get(party.Id)){
					if(extId.Cnncl_Enty_Type_gne__c == CORE_Subscribe_Base.CNNCL_PARTY && extId.Ctrb_Src_gne__c == CORE_Subscribe_Base.AMS_CTRB_SOURCE_CODE){
						for(sObject obj: accounts){
							Account account = (Account)obj;
							account.AMS_ID_gne__c = extId.Ctrb_Src_Id_gne__c;
						}
					}
					
					if(extId.Cnncl_Enty_Type_gne__c == CORE_Subscribe_Base.CNNCL_PARTY && extId.Ctrb_Src_gne__c == CORE_Subscribe_Base.NPI_CTRB_SOURCE_CODE){
						for(sObject obj: accounts){
							Account account = (Account)obj;
							account.NPI_vod__c = extId.Ctrb_Src_Id_gne__c;
						}
					}
				}
			}
		}	
	}
}