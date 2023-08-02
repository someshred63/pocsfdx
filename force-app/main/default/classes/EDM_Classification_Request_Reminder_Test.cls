@isTest(seeAllData=false)
private class EDM_Classification_Request_Reminder_Test{

	public static void insertWorkingDays(){
		List<Actual_Working_Days_gne__c> awd = new List<Actual_Working_Days_gne__c>();
		
		for(Integer i=0;i<=5;i++){
			Actual_Working_Days_gne__c wd = new Actual_Working_Days_gne__c(Date_gne__c = Date.today()+i);
			awd.add(wd);
		}		

		insert awd;
	}

	static testMethod void crrTest(){

		insertWorkingDays();

		Test.StartTest();

			RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];
			Account acc = new Account(Name='testAccount');
	    	insert acc;

			EDM_Classification_Request_gne__c req2Days = new EDM_Classification_Request_gne__c(
				EDM_Account_gne__c = acc.Id,
				EDM_Type_of_Classification_gne__c = 'Business',
				RecordTypeId = rtBusiness.Id,
				EDM_Pending_Days_gne__c = 0
			);
			insert req2Days;

			EDM_Classification_Request_gne__c req5Days = new EDM_Classification_Request_gne__c(
				EDM_Account_gne__c = acc.Id,
				EDM_Type_of_Classification_gne__c = 'Business',
				RecordTypeId = rtBusiness.Id,
				EDM_Pending_Days_gne__c = 0
			);
			insert req5Days;

			EDM_Email_Reminder_Scheduler sh1 = new EDM_Email_Reminder_Scheduler();
			Date shDate = Date.today().addDays(3);
			String sch = '0 0 1 '+shDate.day()+' '+shDate.month()+' ? '+shDate.year(); 
			System.debug('###'+sch);
			System.schedule('Test Email Reminders', sch, sh1); 

			List<Actual_Working_Days_gne__c> wd = new List<Actual_Working_Days_gne__c>([Select Date_gne__c From Actual_Working_Days_gne__c]);
			Integer i = EDM_Classification_Utils.workingDaysBetweenTwoDates(Date.today(),Date.today()+3,wd);
			System.assertEquals(2,i);
		Test.stopTest();

	}
			
}