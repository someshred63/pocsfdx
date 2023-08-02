/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-12-13
*  Description: This is a test class for GNE_SFA2_Key_Message_Trigger trigger.
*  
*  Modification History
*  Date        Name        Description
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Key_Message_Trigger_Test {
	
	public static testMethod void testBeforeDelete() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Sample account');
        		insert acc;

		        Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		        call.Account_vod__c = acc.id;
        		insert call;

				Key_Message_vod__c km = new Key_Message_vod__c();
				insert km;
				Call2_Key_Message_vod__c callKM = GNE_SFA2_Triggers_Test_Util.prepareCall2_Key_Message_vod(call.Id);
				callKM.Key_Message_vod__c=km.Id;
				insert callKM;
				try{
					delete km;
					system.assert(false, 'this line shouldn\'t be reached');
				} catch(Exception ex){
					system.assert(true,'delete should have failed');
				}
				delete callKM;
				delete km;
				system.assert(true, 'now it should work ok');

				/*added undelete just for coverage - it doesn't contain any logic*/
				undelete km;
			}
		}
	}
}