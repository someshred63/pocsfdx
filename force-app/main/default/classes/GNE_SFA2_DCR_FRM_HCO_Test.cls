@isTest
private class GNE_SFA2_DCR_FRM_HCO_Test {
	
	@testSetup
    private static void initData(){
    	initCustomSettings();
    	List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'CORE_Merge_Object__c' AND DeveloperName IN ('Group', 'Main') ORDER BY DeveloperName];
        CORE_Merge_Object__c parentMO = new CORE_Merge_Object__c(Object_Type_gne__c='ALL', Object_Name_gne__c='ALL', RecordTypeId = rts[0].Id, Order_gne__c=0,Region_Code_gne__c = 1,External_Id_gne__c='ALL-US');
        insert parentMO;
        List<CORE_Merge_Object__c> mobjs = new List<CORE_Merge_Object__c>{
            new CORE_Merge_Object__c(Name = 'Account-US', Object_Type_gne__c='Account', Object_Name_gne__c='Account', Parent_Merge_Object_gne__c=parentMO.Id,RecordTypeId = rts[1].Id,Order_gne__c=1,Region_Code_gne__c = 1,External_Id_gne__c='Account-US'), 
            new CORE_Merge_Object__c(Name = 'Address-US',Object_Type_gne__c='Address_vod__c', Object_Name_gne__c='Address', Parent_Merge_Object_gne__c=parentMO.Id,RecordTypeId = rts[1].Id,Order_gne__c=2,Region_Code_gne__c = 1,External_Id_gne__c='Address-US')
        };
        insert mobjs;       
    }

    static testMethod void testCreateMergeCandidates() {
        Change_Request_gne__c cr = new Change_Request_gne__c();
		cr.RecordTypeId = GNE_SFA2_Triggers_Test_Util.getRecordTypeId('Change_Request_gne__c', 'HCO_Remove_Duplicate_Organization');
		User mccoUser = GNE_SFA2_Triggers_Test_Util.createUser('BarbaraSmith', 'GNE-Field');
		Id frmHcoRecType = GNE_SFA2_Triggers_Test_Util.getRecordTypeId('Account', 'FRM_HCO');
    	System.runAs(mccoUser){
			List<Account> hcos = new List<Account>();
			hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test1', frmHcoRecType));
			hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test2', frmHcoRecType));
			hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test3', frmHcoRecType));
            hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test4', frmHcoRecType));
			hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test5', frmHcoRecType));
			insert hcos;
			
			List<Address_vod__c> addresses = new List<Address_vod__c>();
			for (Account a : hcos) {
				addresses.add(GNE_FRM_TestUtilities.createAddress('515 East Alvin Avenue', a.Id, 'SANTA MARIA', 'CA', '93454', false));
			}
			insert addresses;	
			cr.Account_gne__c = hcos[0].Id;
			cr.Duplicate_Account_2_gne__c = hcos[1].Id;
			cr.Duplicate_Account_3_gne__c = hcos[2].Id;
			cr.Duplicate_Account_4_gne__c = hcos[3].Id;
			cr.Duplicate_Account_5_gne__c = hcos[4].Id;
			insert cr;
		}
		cr.Approval_State__c = 'TBD';
		update cr;
		List<CORE_Merge_Candidate__c> mergeCandidates = [SELECT id FROM CORE_Merge_Candidate__c];
		system.assertEquals(0, mergeCandidates.size());	

		cr.Approval_State__c = 'Revised & Approved';
		update cr;
		
		mergeCandidates = [SELECT id FROM CORE_Merge_Candidate__c];
		system.assertEquals(10, mergeCandidates.size());
		
		cr.Approval_State__c = 'Approved';
		update cr;	
		mergeCandidates = [SELECT id FROM CORE_Merge_Candidate__c];
		system.assertEquals(10, mergeCandidates.size());
    }
   
       
    private static void initCustomSettings(){
		insert new GNE_SFA2_DCR_Config_Items_gne__c(Name='ParentUpdateDcrApprovalStatuses', Key_gne__c='ParentUpdateDcrApprovalStatuses', Value_gne__c='Approved::[FRM_HCO]Revised & Approved', Configuration_Type_gne__c='Main');
		insert new GNE_SFA2_DCR_Config_Items_gne__c(Name='AddressDcrFields', Key_gne__c='AddressDcrFields', Value_gne__c='Name,City_vod__c,State_vod__c,Zip_vod__c', Configuration_Type_gne__c='Main');
	} 
   
}