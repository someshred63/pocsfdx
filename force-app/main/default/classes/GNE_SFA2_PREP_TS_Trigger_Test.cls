/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-08-27
*  This is a test class for GNE_SFA2_PREP_TS_Trigger
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_PREP_TS_Trigger_Test {
	
	public static testMethod void testInsertAndUpdate() {
		SFA2_PREP_Testing_Strategy_gne__c prepTS = new SFA2_PREP_Testing_Strategy_gne__c(Name = 'testName', Region_Code_gne__c = 1.0);
		insert prepTS;
		prepTS = [SELECT Id, Name, External_Id_gne__c FROM SFA2_PREP_Testing_Strategy_gne__c WHERE Id = :prepTs.Id LIMIT 1];
		system.assertEquals('1_testName', prepTS.External_Id_gne__c);
		prepTS.Name = 'otherName';
		update prepTS;
		prepTS = [SELECT Id, Name, External_Id_gne__c FROM SFA2_PREP_Testing_Strategy_gne__c WHERE Id = :prepTs.Id LIMIT 1];
		system.assertEquals('1_otherName', prepTS.External_Id_gne__c);
	}	
}