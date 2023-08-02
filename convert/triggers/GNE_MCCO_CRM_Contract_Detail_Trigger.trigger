trigger GNE_MCCO_CRM_Contract_Detail_Trigger on GNE_CRM_Contract_Detail__c (before insert) {
	
    List<Id> accIds = new List<Id>();
    for (GNE_CRM_Contract_Detail__c cd : Trigger.new) {
        accIds.add(cd.Account__c);
    }
    
    List<Account> existingAccList = [ SELECT Id, (SELECT Id FROM GNE_CRM_Contract_Details__r ) FROM Account WHERE Id IN :accIds ];
    Map<Id, Integer> accContractCount = new Map<Id, Integer>();
    for (Account acc : existingAccList) {
        accContractCount.put(acc.Id, acc.GNE_CRM_Contract_Details__r.size());
    }

    for (GNE_CRM_Contract_Detail__c cd : Trigger.new) {
    	if (accContractCount.get(cd.Account__c) >= 3) {
    		cd.addError(System.Label.GNE_SFA2_MCCO_AM_Max_3_Contract_Details);
    	}
    }
}