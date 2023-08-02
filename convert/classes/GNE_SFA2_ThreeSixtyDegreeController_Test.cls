/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-28
*  Description: This is a test class for GNE_SFA2_ThreeSixtyDegreeController class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_ThreeSixtyDegreeController_Test {
	
	public static testMethod void test_ThreeSixtyDegreeController() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				Account testAcc = new Account(Name = 'testAcc');
				insert testAcc;
				Contact testContact = new Contact(AccountId=testAcc.Id, HCP_gne__c = testAcc.Id, LastName='testCont');
				insert testContact;
				Call2_vod__c testCall = new Call2_vod__c(Account_vod__c=testAcc.Id, Call_Date_vod__c = system.today());
				insert testCall;

				Integer reportsSizeBefore = [SELECT Id FROM ThreeSixtyDegreeReport_gne__c].size();

				ApexPages.StandardController stdcontroller = new ApexPages.StandardController(testAcc);
				GNE_SFA2_ThreeSixtyDegreeController tsdCtrl = new GNE_SFA2_ThreeSixtyDegreeController(stdcontroller);
				String reportUrl = GNE_SFA2_ThreeSixtyDegreeController.runThreeSixtyDegreeReport((String)(testAcc.Id));

				Integer reportsSizeAfter = [SELECT Id FROM ThreeSixtyDegreeReport_gne__c].size();
				system.assert(reportsSizeAfter>reportsSizeBefore);
				system.assert(reportUrl.contains('/apex/GNE_SFA2_Report_layout?id='));
				system.assert(reportUrl.contains('&pv0='+sfa2User.Id));
			}
		}
	}	
}