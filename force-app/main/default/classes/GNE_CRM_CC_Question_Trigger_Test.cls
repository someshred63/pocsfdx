@isTest
private class GNE_CRM_CC_Question_Trigger_Test {
	
	@isTest static void testExternalIdInsertUpdateWithSpecialCharacters() {
		GNE_CRM_CC_Question__c question1 = new GNE_CRM_CC_Question__c(Type__c = 'Checkbox', Possible_Values__c = null, Question__c = 'Returning a call', Inquiry__c = 'Warm / Internal Transfer', 
																	Order__c = 2, Prerequisite__c = null );
		insert question1;
		GNE_CRM_CC_Question__c questionRet = [SELECT Id, Type__c, Possible_Values__c, Inquiry__c, Order__c, Question__c, Prerequisite__c, External_Id__c FROM GNE_CRM_CC_Question__c LIMIT 1];
		system.assertEquals(questionRet.External_Id__c, 'Warm___Internal_Transfer_2_Returning_a_call');

		GNE_CRM_CC_Question__c question2 = new GNE_CRM_CC_Question__c(Id = question1.Id, Type__c = 'Dropdown', Possible_Values__c = 'Shipping Damage (damage to shipper);;;Received wrong product;;;Received Overage;;;Received Shortage;;;Tag Alert triggered (shipped on time);;;Product arrived late/lost by carrier', 
																	Question__c = 'What kind of claim?', Inquiry__c = 'Shortage/Overage/Mis-shipment/Tag Alert', 
																	Order__c = 1, Prerequisite__c = null );
		update question2;
		questionRet = [SELECT Id, Type__c, Possible_Values__c, Inquiry__c, Order__c, Question__c, Prerequisite__c, External_Id__c FROM GNE_CRM_CC_Question__c LIMIT 1];
		system.assertEquals(questionRet.External_Id__c, 'Shortage_Overage_Mis-shipment_Tag_Alert_1_What_kind_of_claim');
	}
	
	@isTest static void testExternalIdInsertUpdateWithoutSpecialCharacters() {
		GNE_CRM_CC_Question__c question1 = new GNE_CRM_CC_Question__c(Type__c = 'Checkbox', Possible_Values__c = null, Question__c = 'Test', Inquiry__c = 'Spoilage', 
																	Order__c = 2, Prerequisite__c = null );
		insert question1;
		GNE_CRM_CC_Question__c questionRet = [SELECT Id, Type__c, Possible_Values__c, Inquiry__c, Order__c, Question__c, Prerequisite__c, External_Id__c FROM GNE_CRM_CC_Question__c LIMIT 1];
		system.assertEquals(questionRet.External_Id__c, 'Spoilage_2_Test');

		GNE_CRM_CC_Question__c question2 = new GNE_CRM_CC_Question__c(Id = question1.Id, Type__c = 'Dropdown', Possible_Values__c = 'Shipping Damage (damage to shipper);;;Received wrong product;;;Received Overage;;;Received Shortage;;;Tag Alert triggered (shipped on time);;;Product arrived late/lost by carrier', 
																	Question__c = 'Nothing', Inquiry__c = 'Expired', 
																	Order__c = 1, Prerequisite__c = null );
		update question2;
		questionRet = [SELECT Id, Type__c, Possible_Values__c, Inquiry__c, Order__c, Question__c, Prerequisite__c, External_Id__c FROM GNE_CRM_CC_Question__c LIMIT 1];
		system.assertEquals(questionRet.External_Id__c, 'Expired_1_Nothing');
	}
	
}