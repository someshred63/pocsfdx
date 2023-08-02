global class GNE_SFA2_TSFAddressFix_Batch implements Database.Batchable<Sobject>, Database.Stateful {
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('GNE_SFA2_TSFAddressFix_Batch start.');
		
		return Database.getQueryLocator([SELECT Id, Account_vod__c, Address_vod__c from TSF_vod__c WHERE Address_vod__c = null OR Address_vod__r.Inactive_vod__c = true]);
	}
	
	global void execute(Database.BatchableContext BC, List<Sobject> scope){
		if (scope != null && scope.size() > 0){
			
			Map<ID,List<TSF_vod__c>> tsfMap = new Map<Id,List<TSF_vod__c>>();
			List<Id> accountsList = new List<Id>();
			
			for(Sobject obj : scope) {
				TSF_vod__c tsf = (TSF_vod__c)obj;
				if(!tsfMap.containsKey(tsf.Account_vod__c)) {
					tsfMap.put(tsf.Account_vod__c, new List<TSF_vod__c>());
					accountsList.add(tsf.Account_vod__c);
				}
				
				tsfMap.get(tsf.Account_vod__c).add(tsf);
			} 
			
			List<Address_vod__c> addressList = [SELECT Id, Account_vod__c from Address_vod__c WHERE Primary_vod__c = true AND Inactive_vod__c = false AND Account_vod__c IN : accountsList];
					
			Map<Id, Address_vod__c> addressesMap = new Map<Id, Address_vod__c>();
			
			for(Address_vod__c addr : addressList) {
				addressesMap.put(addr.Account_vod__c, addr);
			} 
			
			for(Id accountId : tsfMap.keyset()) {
				for(TSF_vod__c tsf : tsfMap.get(accountId)) {
					if(addressesMap.containsKey(accountId)) {
						tsf.Address_vod__c = addressesMap.get(accountId).Id;
					}
				}
			}
			
			update scope;
		}
	}
	
	global void finish(Database.BatchableContext BC){
		
	}

}