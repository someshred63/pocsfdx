/************************************************************
*  @author:Rakesh Boinepalli 
*  Date: 2012-01-05
*  Description: This is a test class for GNE_SFA2_Spkr_Training_Trigger trigger
*  
*  Modification History
*  Date        	Name        			Description
*  2014-02-04	Piotr Przesmycki    	Fixed and improved unit test, removed SeeAllData annotation
*  2014-02-17   Piotr Przesmycki    	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2015-07-08   Przemyslaw Giszczak 	Add status to Speaker_Bureau_Membership_gne__c against DmlException
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Spkr_Training_Trigger_Test {

	public static testMethod void testInsertAndUpdate(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
			insert acc;

			Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
			insert sb;

			Event_Curriculum_gne__c ec = GNE_SFA2_Triggers_Test_Util.prepareEvent_Curriculum_gne();
			insert ec;

			Curriculum_Speaker_Bureau_gne__c csb = GNE_SFA2_Triggers_Test_Util.prepareCurriculum_Speaker_Bureau_gne(ec.Id, sb.Id);
			insert csb;

			Speaker_Training_gne__c speakerTrain = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Training_gne(Date.today());
			speakerTrain.Speaker_gne__c 		 = acc.Id;
			speakerTrain.Event_Curriculum_gne__c = ec.Id;
			insert speakerTrain;

			Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id, 'Approved');
			insert sbm;

			Member_Trainings_gne__c mt = GNE_SFA2_Triggers_Test_Util.prepareMember_Trainings_gne(speakerTrain.Id, sbm.Id);
			insert mt;

			Id mtId = mt.Id;
			update speakerTrain;

			Member_Trainings_gne__c newMT = [SELECT Id,Speaker_Bureau_Membership_gne__c,Speaker_Training_gne__c FROM Member_Trainings_gne__c WHERE Speaker_Training_gne__c = :speakerTrain.Id LIMIT 1];
			system.assertEquals(newMT.Speaker_Bureau_Membership_gne__c, sbm.Id);
			system.assertEquals(newMT.Speaker_Training_gne__c, speakerTrain.Id);
			system.assertNotEquals(mtId, newMT.Id);
		}
	}
}