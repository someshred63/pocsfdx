global class GNE_SFA2_PrimAddrFixAfterMerge_Batch implements Database.Batchable<Sobject>, Database.Stateful {
	
	private static final String RECORDTYPE_NAME = 'Company Maintained';
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('GNE_SFA2_PrimAddrFixAfterMerge_Batch start.');
		
		return Database.getQueryLocator([SELECT Id, Main_Address_gne__c, (SELECT Id, Account_vod__c, Account_vod__r.Region_Code_gne__c, LastModifiedDate, Primary_vod__c, RecordType.Name, Region_Code_gne__c, Inactive_vod__c from Address_vod__r ORDER BY LastModifiedDate) FROM Account WHERE LastModifiedById =: UserInfo.getUserId() AND LastModifiedDate >=: system.today().addDays(-3)]);
		
	}
	
	global void execute(Database.BatchableContext BC, List<Sobject> scope){
		if (scope != null && scope.size() > 0){
			
			List<Address_vod__c> addressesListToUpdate = new List<Address_vod__c>();
			List<Account> accountsListToUpdate = new List<Account>();
		
			for(Sobject obj : scope) {
				Account acct = (Account)obj;
				List<Address_vod__c> addresses = new List<Address_vod__c>();
				for(Address_vod__c addr : acct.Address_vod__r) {
					if(!addr.Inactive_vod__c) {
						addresses.add(addr);
					}
				}
				
				addressesListToUpdate.addAll(addresses);
				accountsListToUpdate.add(acct);
				
				Boolean isCanadaAccount = false;
				
				if(addresses.isEmpty()) {
					acct.Main_Address_gne__c = null;
					continue;	
				}
				
				if(addresses.size() == 1) {
					addresses.get(0).Primary_vod__c = true;
					acct.Main_Address_gne__c = addresses.get(0).Id;
				} else {
					List<Address_vod__c> primaryAddresses = new List<Address_vod__c>();
					for(Address_vod__c addr : addresses) {
						if(addr.Primary_vod__c) {
							primaryAddresses.add(addr);
						}
						
						if(addr.Account_vod__r.Region_Code_gne__c == 2) {
							isCanadaAccount = true;
						}
					}
					
					if(!isCanadaAccount) {
						
						if(primaryAddresses.size() == 1) { 
							acct.Main_Address_gne__c = primaryAddresses.get(0).Id;
						} else if (primaryAddresses.size() == 0) {
							Boolean hasAddPrimary = false;
							for(Address_vod__c addr : addresses) {
								if((addr.RecordType.Name == RECORDTYPE_NAME)) {
									addr.Primary_vod__c = true;
									acct.Main_Address_gne__c = addr.Id;
									hasAddPrimary = true;
									break;
								}
							}
							
							if(!hasAddPrimary) {
								addresses.get(0).Primary_vod__c = true;
								acct.Main_Address_gne__c = addresses.get(0).Id;
							}		
						} else {
							for(Integer i = 0; i < primaryAddresses.size(); i++ ) {
								primaryAddresses.get(i).Primary_vod__c = false;	
							}
							
							Boolean hasAddPrimary = false;
							for(Address_vod__c addr : addresses) {
								if((addr.RecordType.Name == RECORDTYPE_NAME)) {
									addr.Primary_vod__c = true;
									acct.Main_Address_gne__c = addr.Id;
									hasAddPrimary = true;
									break;
								}
							}
							
							if(!hasAddPrimary) {
								addresses.get(0).Primary_vod__c = true;
								acct.Main_Address_gne__c = addresses.get(0).Id;
							}		
						}
					} else {
						
						if(primaryAddresses.size() == 1) { 
							acct.Main_Address_gne__c = primaryAddresses.get(0).Id;
						} else if (primaryAddresses.size() == 0) {
							addresses.get(0).Primary_vod__c = true;	
							acct.Main_Address_gne__c = addresses.get(0).Id;
						} else {
							acct.Main_Address_gne__c = addresses.get(0).Id;
							for(Integer i = 1; i < primaryAddresses.size(); i++ ) {
								primaryAddresses.get(i).Primary_vod__c = false;	
							}		
						}
					}
				}
			}
			
			update addressesListToUpdate;
			update accountsListToUpdate;
			
		}
	}
	
	global void finish(Database.BatchableContext BC){
		System.debug('GNE_SFA2_PrimAddrFixAfterMerge_Batch finished.');
	}
	
}