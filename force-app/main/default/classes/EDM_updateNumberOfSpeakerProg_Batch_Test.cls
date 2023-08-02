@isTest
private class EDM_updateNumberOfSpeakerProg_Batch_Test{

	public static testMethod void batchTest(){
		
		List<Account> acc = new List<Account>();
		acc.add(new Account(Name = 'Test Account 1'));
		acc.add(new Account(Name = 'Test Account 2'));
		insert acc;

		List<Speaker_Bureau_gne__c> sbs = new List<Speaker_Bureau_gne__c>();
		sbs.add(new Speaker_Bureau_gne__c());
		sbs.add(new Speaker_Bureau_gne__c());
		sbs.add(new Speaker_Bureau_gne__c());
		sbs.add(new Speaker_Bureau_gne__c());
		insert sbs;

		List<Speaker_Bureau_Membership_gne__c> sbMem = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account ac : acc){
			for(Speaker_Bureau_gne__c sb : sbs){
				sbMem.add(new Speaker_Bureau_Membership_gne__c(
					Speaker_Bureau_Id_gne__c = sb.Id,
					Bureau_Member_gne__c = ac.Id,
					Speaker_Status_gne__c = 'Nominated'
				));
			}
		}
		insert sbMem;		
		
		List<Medical_Event_vod__c> medEv = new List<Medical_Event_vod__c>();
		medEv.add(new Medical_Event_vod__c(
			End_Date_vod__c = Date.today()+5, 
			Start_Date_vod__c = Date.today(),
			Event_Type_gne__c = 'Speaker Program',
			Status_gne__c = 'Occurred'));
		medEv.add(new Medical_Event_vod__c(
			End_Date_vod__c = Date.today()+5, 
			Start_Date_vod__c = Date.today(),
			Event_Type_gne__c = 'Speaker Program',
			Status_gne__c = 'Confirmed'));
		insert medEv;
		List<Event_Bureaus_gne__c> evBur = new List<Event_Bureaus_gne__c>();
		for(Speaker_Bureau_gne__c s : sbs){
			evBur.add(new Event_Bureaus_gne__c(
				Medical_Event_gne__c = medEv[0].id,
				Speaker_Bureau_gne__c = s.Id
			));
			evBur.add(new Event_Bureaus_gne__c(
				Medical_Event_gne__c = medEv[1].id,
				Speaker_Bureau_gne__c = s.Id
			));
		}
		insert evBur;

		List<Event_Attendee_vod__c> evAtt = new List<Event_Attendee_vod__c>();
		for(Account ac : acc){
			for(Medical_Event_vod__c me : medEv){
				evAtt.add(new Event_Attendee_vod__c(
					Medical_Event_vod__c = me.Id,
					Account_vod__c = ac.Id,
					Role_gne__c = 'Speaker'
				));
			}
		}
		insert evAtt;

		EDM_updateNumberOfSpeakerPrograms_Batch b = new EDM_updateNumberOfSpeakerPrograms_Batch();
		database.executebatch(b);

		sbMem = new List<Speaker_Bureau_Membership_gne__c>([
			Select Upcoming_Programs_gne__c,
				   Completed_Programs_gne__c,
				   Speaker_Bureau_Id_gne__c,
				   Bureau_Member_gne__c,
				   Speaker_Status_gne__c
			From Speaker_Bureau_Membership_gne__c
		]);
		System.assertEquals(8,sbMem.size());
		for(Speaker_Bureau_Membership_gne__c s : sbMem){
			System.assertEquals(1,s.Upcoming_Programs_gne__c);
			System.assertEquals(1,s.Completed_Programs_gne__c);
		}
	}
}