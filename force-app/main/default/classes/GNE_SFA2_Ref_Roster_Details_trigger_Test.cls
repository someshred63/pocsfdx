/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/7/2013
*  Description: This class GNE_SFA2_Ref_Roster_Details_trigger_Test test class to test the triggers on Referral_Roster_gne__c object
*  
*  Modification History
*  Date        Name        		Description
*  2014-02-25  Piotr Przesmycki Fixed unit test
*************************************************************/
@isTest
private class GNE_SFA2_Ref_Roster_Details_trigger_Test {
    
    static testMethod void testOnInsertAndOnDelete() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();		
		
		if(sfa2USer != null) {			
			switchAdminMode(false, sfa2User);			
			System.runAs(sfa2User) {				
				Referral_Roster_gne__c rrMaster = GNE_SFA2_Triggers_Test_Util.prepareReferral_Roster_gne();
				insert rrMaster;

				rrMaster = [SELECT Id, LastModifiedDate FROM Referral_Roster_gne__c WHERE Id = :rrMaster.Id LIMIT 1];
				Datetime dtBefore = rrMaster.LastModifiedDate;
				
				waitFor(5000);
				
				Referral_Roster_Detail_gne__c rrDet = GNE_SFA2_Triggers_Test_Util.prepareReferral_Roster_Detail_gne(rrMaster.Id);
				insert rrDet;
				
				rrMaster = [SELECT Id, LastModifiedDate FROM Referral_Roster_gne__c WHERE Id = :rrMaster.Id LIMIT 1];
				Datetime dtAfter = rrMaster.LastModifiedDate;
				system.assertNotEquals(dtBefore, dtAfter);
				
				dtBefore = rrMaster.LastModifiedDate;
				
				waitFor(5000);

				delete rrDet;
				
				rrMaster = [SELECT Id, LastModifiedDate FROM Referral_Roster_gne__c WHERE Id = :rrMaster.Id LIMIT 1];
				dtAfter = rrMaster.LastModifiedDate;
				system.assertNotEquals(dtBefore,dtAfter);
				
				/*undelete just for coverage - it doesn't contain any logic*/
				undelete rrDet;

			}
		}
	}
	
	private static void waitFor(Integer delayInMiliSeconds){
		Long startingTime = System.now().getTime();
		while (System.now().getTime() - startingTime < delayInMiliSeconds) {
            // Do nothing until desired delay has passed
 		}		
	}
	
	private static void switchAdminMode(Boolean isAdminMode, User sfa2User) {        
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId =: sfa2User.Id LIMIT 1];
        if (adminModeSetting.isEmpty()) {
            insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = sfa2User.Id, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
        } else {
            adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
            update adminModeSetting;
        }
    }
}