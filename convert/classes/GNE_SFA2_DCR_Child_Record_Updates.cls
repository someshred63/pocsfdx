public without sharing class GNE_SFA2_DCR_Child_Record_Updates {
	
	private static ID queueId=ChangeRequestControllerHelper.getAnalystsQueueNameQueueID();
	
	public static void onAfterInsert(List<Change_Request_gne__c> triggerNewList) {
		assignRecordSharingForUser(triggerNewList);
		sentDCRNotification(triggerNewList);
	}
	
	public static void onAfterUpdate (List<Change_Request_gne__c> triggerOldList, List<Change_Request_gne__c> triggerNewList) {
		prepareForVendors(triggerOldList,triggerNewList);
		hideInactiveAddress4User(triggerNewList);
	}
	
	public static void onAfterDelete(List<Change_Request_gne__c> triggerOldList) {
		
	}
	
	private static void assignRecordSharingForUser(List<Change_Request_gne__c> triggerNewList){
		List<Change_Request_gne__Share> newDCRShares=new List<Change_Request_gne__Share>();
		
		for(Change_Request_gne__c changeRequest : triggerNewList){
			newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById,changeRequest,'Read',Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
		}
		if(newDCRShares!=null && newDCRShares.size()>0){
			insert newDCRShares;
		}
	}
	
	private static void sentDCRNotification(List<Change_Request_gne__c> triggerNewList) {
		//sent notification for HCP_FMV_Tier_request and US_Licensed_Physician
		List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='HCP_FMV_Tier_request' OR DeveloperName ='US_Licensed_Physician'];
		for (Change_Request_gne__c dcr : triggerNewList) {
			for (RecordType recordTyp : recordTypes) {
				if (recordTyp.DeveloperName == 'HCP_FMV_Tier_request' && dcr.recordTypeId == recordTyp.Id) {
					ChangeRequestControllerHelper.sendHCPFMVTierRequestEmail(dcr);
				} else if (recordTyp.DeveloperName == 'US_Licensed_Physician' && dcr.recordTypeId == recordTyp.Id) {
					ChangeRequestControllerHelper.sendHCPUSLicensedPhysicianRequestEmail(dcr);
				}
			}
		}
	}

	private static void prepareForVendors(List<Change_Request_gne__c> triggerOldList, List<Change_Request_gne__c> triggerNewList){
		String dcrUpdates='';
		List<Id> dcrUpdatesIds = new List<Id>();
		
		for(Change_Request_gne__c changeRequest : triggerNewList){
			// bot
			if(changeRequest.ownerId == queueId && changeRequest.Vendor_Type_gne__c=='bot' && changeRequest.Status_gne__c =='Submitted') {
				dcrUpdatesIds.add(changeRequest.Id);
			}
			// ams
			if(changeRequest.ownerId==queueId && changeRequest.Vendor_Type_gne__c=='ams' && changeRequest.ams_id_1_gne__c != null && changeRequest.Status_gne__c=='Submitted') {
				Boolean bReadyforVendor = true;
				
				if ( changeRequest.duplicate_account_2_gne__c != null ){
					if ( changeRequest.ams_id_2_gne__c == null ){
						bReadyforVendor = false;
					}
				}
				if ( bReadyforVendor && changeRequest.duplicate_account_3_gne__c != null ){
					if ( changeRequest.ams_id_3_gne__c == null ){
						bReadyforVendor = false;
					}
				}
				if ( bReadyforVendor && changeRequest.duplicate_account_4_gne__c != null ){
					if ( changeRequest.ams_id_4_gne__c == null ){
						bReadyforVendor = false;
					}
				}
				if ( bReadyforVendor && changeRequest.duplicate_account_5_gne__c != null ){
					if ( changeRequest.ams_id_5_gne__c == null ){
						bReadyforVendor = false;
					}
				}
				if (bReadyforVendor){
					dcrUpdatesIds.add(changeRequest.Id);
				}
			}
		}
		if(dcrUpdatesIds.size() > 0){
			for(Integer i=0; i<dcrUpdatesIds.size(); i++){
				dcrUpdates += dcrUpdatesIds[i]; 
				if(i < dcrUpdatesIds.size() - 1){
					dcrUpdates += ',';
				}
			}
			ChangeRequestControllerHelper.moveBOTTicketsToVendorQueue(dcrUpdates);
		}
	}

	/**
		Hide inactive address for user who created DCR when DCR is approved. 
	*/
	private static void hideInactiveAddress4User(List<Change_Request_gne__c> triggerNewList) {
		Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT id, DeveloperName, Name FROM recordtype WHERE sobjecttype ='change_request_gne__c']);

		Map<Id, Set<Id>> userId4AddressIdMap = new Map<Id, Set<Id>>();
		Set<Id> addressIds = new Set<Id>();

		for (Change_Request_gne__c changeRequest : triggerNewList) {
			if (changeRequest.Approval_State__c == 'Approved' || changeRequest.Approval_State__c == 'Partial Approved' || changeRequest.Approval_State__c == 'Revised & Approved') {
				if (rtMap.get(changeRequest.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Remove_Inactivate_Address')) {
					if (changeRequest.Current_Address_gne__c != null) {
						if (!userId4AddressIdMap.containsKey(changeRequest.CreatedById)) {
							userId4AddressIdMap.put(changeRequest.CreatedById, new Set<Id>());
						}
						userId4AddressIdMap.get(changeRequest.CreatedById).add(changeRequest.Current_Address_gne__c);
						addressIds.add(changeRequest.Current_Address_gne__c);
					}
				}
			}		
		}

		if (userId4AddressIdMap.size() > 0) {
			Map<Id, Address_vod__c> addrMap = new Map<Id, Address_vod__c>([SELECT id, Account_vod__c FROM Address_vod__c WHERE id in :addressIds]);

			for (Id userId : userId4AddressIdMap.keySet()) {
				List<Address_vod__c> tempAddrList = new List<Address_vod__c>();
				for (Id addr : addrMap.keySet()) {
					if (userId4AddressIdMap.get(userId).contains(addr)) {
						tempAddrList.add(addrMap.get(addr));
					}
				}
				if (tempAddrList.size() > 0) {
					(new GNE_SFA2_UserPreference_Ctrl()).hideAddresses(userId, tempAddrList);
				}
			}
		}
	}
}