@isTest(seeAllData=false)
private class EDM_Classification_Rst_Email_Notif_Test{

	static testMethod void crenClassificationsWithoutChangesTest(){

		insertSBL();
		User u = [SELECT Id FROM User WHERE alias = 'sbleader'];
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>();

		RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];
		RecordType rtClinical = [SELECT Id FROM RecordType WHERE DeveloperName = 'Clinical'];

		Account acc = new Account(Name='testAccount');
		insert acc;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Lead_gne__c = u.Id, Speaker_Bureau_Type_gne__c = 'Clinical');
		insert sb;

		for(Integer i=0;i<=5;i++){
			EDM_Classification_Request_gne__c req;
			if(0 == Math.mod(i,2)){
				req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rtBusiness.Id);
			} else {
				req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Clinical',RecordTypeId = rtClinical.Id);
			}
			req.EDM_Status_gne__c = 'Completed';
			triggerOld.add(req);
		}
		insert triggerOld;

		triggerNew = triggerOld.deepClone(false,false,false);

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, 
													Speaker_Status_gne__c = 'Nominated');
		insert sbm;

		EDM_Classification_Request_Email_Notif.onAfterUpdate(triggerOld,triggerNew);

		EDM_Classification_Request_Email_Notif.Reviewers rvs = new EDM_Classification_Request_Email_Notif.Reviewers();
	}

	static testMethod void crenBusinessClassificationTest(){

		insertSBL();
		User u = [SELECT Id FROM User WHERE alias = 'sbleader'];
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>();

		RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business'];
		
		Account acc = new Account(Name='testAccount');
		insert acc;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Lead_gne__c = u.Id, Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		EDM_Classification_Request_gne__c req;
		req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business',RecordTypeId = rtBusiness.Id);
		triggerOld.add(req);
		
		triggerNew = triggerOld.deepClone(false,false,false);
		req = triggerNew.get(0);
		req.EDM_CV_Attachment_Link_gne__c = 'test link';
		req.EDM_Business_Role_gne__c = 'Test Role';
		req.EDM_Status_gne__c = 'Global';

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, 
													Speaker_Status_gne__c = 'Nominated');
		insert sbm;

		EDM_Classification_Request_Email_Notif.onAfterUpdate(triggerOld,triggerNew);
	}

	static testMethod void crenClinicalClassificationTest(){

		insertSBL();
		User u = [SELECT Id FROM User WHERE alias = 'sbleader'];
		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>();

		RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Clinical'];
		
		Account acc = new Account(Name='testAccount');
		insert acc;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Lead_gne__c = u.Id, Speaker_Bureau_Type_gne__c = 'Clinical');
		insert sb;

		EDM_Classification_Request_gne__c req;
		req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Clinical',
													RecordTypeId = rtBusiness.Id,EDM_Account_Specialty_gne__c = 'CLINICAL PATHOLOGY');
		triggerOld.add(req);
		
		triggerNew = triggerOld.deepClone(false,false,false);
		req = triggerNew.get(0);
		req.EDM_CV_Attachment_Link_gne__c = 'test link';
		req.EDM_Business_Role_gne__c = 'Test Role';
		req.EDM_Status_gne__c = 'Global';

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, 
													Speaker_Status_gne__c = 'Nominated');
		insert sbm;

		EDM_Classification_Request_Email_Notif.onAfterUpdate(triggerOld,triggerNew);
	}

	static testMethod void crenClinicalClassificationClassifiedTest(){

		insertSBL();
		User u = [SELECT Id FROM User WHERE alias = 'sbleader'];

		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>();

		RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Clinical'];
		
		Account acc = new Account(Name='testAccount');
		insert acc;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Lead_gne__c = u.Id, Speaker_Bureau_Type_gne__c = 'Clinical');
		insert sb;

		EDM_Classification_Request_gne__c req;
		req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Clinical',RecordTypeId = rtBusiness.Id,
													EDM_Status_gne__c = 'Pending');
		insert req;

		triggerOld.add(req);
		
		triggerNew = triggerOld.deepClone(false,false,false);
		req = triggerNew.get(0);
		req.EDM_Status_gne__c = 'Completed';
		req.EDM_Action_Taken_gne__c = 'Global';
		req.EDM_Requestor_gne__c = u.Id;
		insert req;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, 
													Speaker_Status_gne__c = 'Nominated');
		insert sbm;

		EDM_Classification_Request_Email_Notif.onAfterUpdate(triggerOld,triggerNew);
	}

	static testMethod void crenClinicalClassificationNotClassifiedTest(){

		insertSBL();
		User u = [SELECT Id FROM User WHERE alias = 'sbleader'];

		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>();

		RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Clinical'];
		
		Account acc = new Account(Name='testAccount');
		insert acc;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Lead_gne__c = u.Id, Speaker_Bureau_Type_gne__c = 'Clinical');
		insert sb;

		EDM_Classification_Request_gne__c req;
		req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Clinical',RecordTypeId = rtBusiness.Id,
													EDM_Status_gne__c = 'Pending');
		triggerOld.add(req);
		
		triggerNew = triggerOld.deepClone(false,false,false);
		req = triggerNew.get(0);
		req.EDM_Status_gne__c = 'Completed';
		req.EDM_Action_Taken_gne__c = 'Decline To Classify';
		req.EDM_Requestor_gne__c = u.Id;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, 
													Speaker_Status_gne__c = 'Nominated');
		insert sbm;

		EDM_Classification_Request_Email_Notif.onAfterUpdate(triggerOld,triggerNew);
	}

	static testMethod void crenEmailWithAttachmentTest(){

		insertSBL();
		User u = [SELECT Id FROM User WHERE alias = 'sbleader'];

		List<EDM_Classification_Request_gne__c> triggerOld = new List<EDM_Classification_Request_gne__c>();
		List<EDM_Classification_Request_gne__c> triggerNew = new List<EDM_Classification_Request_gne__c>();

		RecordType rtBusiness = [SELECT Id FROM RecordType WHERE DeveloperName = 'Clinical'];
		
		Account acc = new Account(Name='testAccount');
		insert acc;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Lead_gne__c = u.Id, Speaker_Bureau_Type_gne__c = 'Clinical');
		insert sb;

		EDM_Classification_Request_gne__c req;
		req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Clinical',RecordTypeId = rtBusiness.Id,
													EDM_Status_gne__c = 'Pending');
		insert req;
		triggerOld.add(req);
		
		triggerNew = triggerOld.deepClone(false,false,false);
		req = triggerNew.get(0);
		req.EDM_Status_gne__c = 'Pending';
		req.EDM_Action_Taken_gne__c = 'Decline To Classify';
		req.EDM_CV_Attachment_Link_gne__c = 'www.google.com';
		insert req;

		insert new Attachment(
			Name = 'TestAtt',
			ParentId=req.Id,
			Body = Blob.valueOf('Test')
		);

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Bureau_Member_gne__c = acc.Id, Speaker_Bureau_ID_gne__c = sb.Id, 
													Speaker_Status_gne__c = 'Nominated');
		insert sbm;

		EDM_Classification_Request_Email_Notif.onAfterUpdate(triggerOld,triggerNew);
	}

	public static void insertSBL(){
		Profile p = [select id from profile where name='GNE-TLS-SpeakerBureauLead'];
		User u = new User(alias = 'sbleader', email='sbleader@gene.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
			localesidkey='en_US', profileid = p.Id,
			timezonesidkey='America/Los_Angeles', username='sbleader@gene.com');
		insert u;

		List<EDM_MU_to_User_gne__c> mutus = new List<EDM_MU_to_User_gne__c>();
		EDM_MU_to_User_gne__c mutu1 = new EDM_MU_to_User_gne__c(Name='MUTU1',Group_gne__c='BioOncology', User_External_ID_gne__c='sbleader');
		mutus.add(mutu1);
		EDM_MU_to_User_gne__c mutu2 = new EDM_MU_to_User_gne__c(Name='MUTU2',Group_gne__c='Opthalmology', User_External_ID_gne__c='michaend');
		mutus.add(mutu2);
		insert mutus;		
	}

	@isTest
	public static void shouldGetSpectrumAndOtherReviewers() {
		//given
		insertUsers();
		insertMUToUser();

		//when
		EDM_Classification_Request_Email_Notif.Reviewers rvs = new EDM_Classification_Request_Email_Notif.Reviewers();

		//then
		List<User> reviewers = rvs.getReviewersByMedicalUnit('Spectrum');
		System.assertEquals(1, reviewers.size());
		System.assertEquals('mutu1test', reviewers[0].External_ID_gne__c);
	}

	private static void insertUsers() {
		Profile p = [select id from profile where name='GNE-TLS-SpeakerBureauLead'];

		insert new User(alias = 'mutu1tst', email='mutu1test@gene.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
			localesidkey='en_US', profileid = p.Id,
			timezonesidkey='America/Los_Angeles', username='mutu1test@gene.com'
		);

		insert new User(alias = 'mutu2tst', email='mutu2test@gene.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
			localesidkey='en_US', profileid = p.Id,
			timezonesidkey='America/Los_Angeles', username='mutu2test@gene.com'
		);
	
		insert new User(alias = 'mutu3tst', email='mutu3test@gene.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
			localesidkey='en_US', profileid = p.Id,
			timezonesidkey='America/Los_Angeles', username='mutu3test@gene.com'
		);
	}

	private static void insertMUToUser() {
		List<EDM_MU_to_User_gne__c> mutus = new List<EDM_MU_to_User_gne__c>();
		EDM_MU_to_User_gne__c mutu1 = new EDM_MU_to_User_gne__c(Name = 'mutu1', Group_gne__c = 'Spectrum', User_External_ID_gne__c = 'mutu1test');
		mutus.add(mutu1);
		EDM_MU_to_User_gne__c mutu2 = new EDM_MU_to_User_gne__c(Name = 'mutu2', Group_gne__c = 'Other', User_External_ID_gne__c = 'mutu2test');
		mutus.add(mutu2);
		EDM_MU_to_User_gne__c mutu3 = new EDM_MU_to_User_gne__c(Name = 'mutu3', Group_gne__c = 'Opthalmology', User_External_ID_gne__c = 'mutu3test');
		mutus.add(mutu3);
		insert mutus;	
	}
}