trigger SPCM_Product_trigger on SPCM_Product__c (before update) {

	//TODO: make this code a batch. It may hit the CPU limit soon, as there is a lot of junctions.

	Map<id, SPCM_Product__c> oMap = trigger.oldMap;
	for(SPCM_Product__c product : trigger.new){
		string oldName = oMap.get(product.id).name;
		string newName = product.name;

		if (oldName == newName){
			continue;
		}

		List<SPCM_Log_To_Product_Junction__c> junctions = [select id, ICFR_Log__c from SPCM_Log_To_Product_Junction__c where Product_name__c = :oldName];

		set<id> logEntriesWithProductSet = new set<id>();
		for(SPCM_Log_To_Product_Junction__c junction : junctions){
			logEntriesWithProductSet.add(junction.ICFR_Log__c);
		}

		List<SPCM_ICFR_Log__c> logEntriesWithProduct = [select id, Product_List__c from SPCM_ICFR_Log__c where id in :logEntriesWithProductSet];

		for(SPCM_ICFR_Log__c log : logEntriesWithProduct){
			List<string> prods = log.Product_List__c.split(',');
			for(integer i = 0; i <prods.size(); i++){
				if (prods[i].trim() == oldName)
					prods[i] = newName;
			}
			log.Product_List__c =  string.join(prods, ', '); //log.Product_List__c.replace(oldName, newName);
		}

		update logEntriesWithProduct;
	}

}