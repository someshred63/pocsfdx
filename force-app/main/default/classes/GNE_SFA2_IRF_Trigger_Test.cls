/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-12
*  Description: This is a test class for GNE_SFA2_IRF_Trigger trigger.
*  
*  Modification History
*  Date        	Name        		Description
*  2014-01-30	Piotr Przesmycki    Removed seeAllData annotation
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
private class GNE_SFA2_IRF_Trigger_Test {
/*
 	public static testMethod void testResolvedDateFieldUpdateWhenIRFInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		insert new Account(Name = 'test', Account_Type_gne__c='Hospital');
		List<Issue_gne__c> opens = GNE_SFA2_IRF_Test_Helper.insertTestIRFs(null, new Map<String, Object>{'Assigned_FRM_gne__c' => GNE_SFA2_IRF_Test_Helper.user.Id, 'Practice_Name_frm_gne__c' => GNE_SFA2_IRF_Test_Helper.acct.Id, 'Status_frm_gne__c' => 'Open'});
		opens = [Select Id, Resolved_Date_frm_gne__c from Issue_gne__c where Id in : opens];
		
		List<Issue_gne__c> resolveds = GNE_SFA2_IRF_Test_Helper.insertTestIRFs(null, new Map<String, Object>{'Assigned_FRM_gne__c' => GNE_SFA2_IRF_Test_Helper.user.Id, 'Practice_Name_frm_gne__c' => GNE_SFA2_IRF_Test_Helper.acct.Id, 'Status_frm_gne__c' => 'Resolved'});
		resolveds = [Select Id, Resolved_Date_frm_gne__c from Issue_gne__c where Id in : resolveds];
		
		
		
		Test.startTest();
		for(Issue_gne__c iRF : opens){
			System.assertEquals(null, iRF.Resolved_Date_frm_gne__c);	
		}
		for(Issue_gne__c iRF : resolveds){
			System.assertEquals(System.Today(), iRF.Resolved_Date_frm_gne__c);	
		}
		Test.stopTest();
	}
	
	public static testMethod void testResolvedDateFieldUpdateWhenIRFUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		insert new Account(Name = 'test', Account_Type_gne__c='Hospital');
		List<Issue_gne__c> opens = GNE_SFA2_IRF_Test_Helper.insertTestIRFs(null, new Map<String, Object>{'Assigned_FRM_gne__c' => GNE_SFA2_IRF_Test_Helper.user.Id, 'Practice_Name_frm_gne__c' => GNE_SFA2_IRF_Test_Helper.acct.Id, 'Status_frm_gne__c' => 'Open'});
		opens = [Select Id, Resolved_Date_frm_gne__c, Status_frm_gne__c from Issue_gne__c where Id in : opens];
		
		List<Issue_gne__c> resolveds = GNE_SFA2_IRF_Test_Helper.insertTestIRFs(null, new Map<String, Object>{'Assigned_FRM_gne__c' => GNE_SFA2_IRF_Test_Helper.user.Id, 'Practice_Name_frm_gne__c' => GNE_SFA2_IRF_Test_Helper.acct.Id, 'Status_frm_gne__c' => 'Resolved'});
		resolveds = [Select Id, Resolved_Date_frm_gne__c, Status_frm_gne__c from Issue_gne__c where Id in : resolveds];
		
		for(Integer i = 0; i < opens.size(); i++){
			opens[i].Status_frm_gne__c = 'Resolved';	
		}
		for(Integer i = 0; i < resolveds.size(); i++){
			resolveds[i].Status_frm_gne__c = 'Open';	
		}
		
		Test.startTest();
		try {
			update opens;
			update resolveds;
		} catch (DMLException ex) {
			for(Issue_gne__c iRF : opens){
				System.assertEquals(System.Today(), iRF.Resolved_Date_frm_gne__c);	
			}
			
			for(Issue_gne__c iRF : resolveds){
				System.assertEquals(null, iRF.Resolved_Date_frm_gne__c);	
			}
		}
		Test.stopTest();
	} */
}