@isTest
public class GNE_SFA2_Peeps_API_Engine_Test implements HttpCalloutMock {

	private Boolean validCredentials;
	private Boolean containsPicture;
	private Boolean success;

	public GNE_SFA2_Peeps_API_Engine_Test(Boolean validCredentials, Boolean containsPicture, Boolean success){
		this.validCredentials = validCredentials;
		this.containsPicture = containsPicture;
		this.success = success;
	}

	public HttpResponse respond(HttpRequest req){
		String body = '[';
		body += '{"buildingNumber": "A124","departmentName": "Ultramarines","jobTitle": "Chief Librarian","location": "Macragge","mailStop": "Z14","mobilePhoneNumber": "54321","phoneNumber": "12345","roomNumber": "R124151","userId": "testUnixId"},';
		body += '{"buildingNumber": "B15","departmentName": "Alpha Legion","location": "Unknown","mobilePhoneNumber": "+1 54321","phoneNumber": "+1 21241","userId": "differentUnixId","photoUrl": "http://pictureUrl.gene.com/test/test/test/testUnixId1x.jpg?stime=20161215114312&etime=20161215114542&encoded=0a1"}';
		body += ']';
		HttpResponse res = new HttpResponse();
		res.setStatusCode(validCredentials ? 200 : 401);
		if(success){
			res.setBody(body);
			if(containsPicture){
				res.setBodyAsBlob(Blob.valueOf('sample body'));
			}
		}
		return res;
	}

	private static void initCustomSettings(){
		initCustomSettings('Basic', 'Salesforce,Salesforce Platform');
	}

	private static void initCustomSettings(String authorizationMethod, String userLicenses){
		List<GNE_PeepsAPI_Config__c> toInsert = new List<GNE_PeepsAPI_Config__c>();
		toInsert.add(new GNE_PeepsAPI_Config__c(Name = 'apiKey', Configuration_Value_gne__c = 'a86b0f6e-ff91-49c1-b159-3b5d32d2562a'));
		toInsert.add(new GNE_PeepsAPI_Config__c(Name = 'appKey', Configuration_Value_gne__c = 'testAppKey'));
		toInsert.add(new GNE_PeepsAPI_Config__c(Name = 'authorizationMethod', Configuration_Value_gne__c = authorizationMethod));
		toInsert.add(new GNE_PeepsAPI_Config__c(Name = 'authorizationToken', Configuration_Value_gne__c = 'TestAuthorizationToken'));
		toInsert.add(new GNE_PeepsAPI_Config__c(Name = 'endpointForGW', Configuration_Value_gne__c = 'https://apidev-emea.roche.com:21110/api/pharma/mobile/peeps/'));
		toInsert.add(new GNE_PeepsAPI_Config__c(Name = 'userLicenses', Configuration_Value_gne__c = userLicenses));
		insert toInsert;
	}

	private static User prepareTestUser(Id profileId){
		return new User(
                Alias = 'tu1', 
                Email='test_user@roche.com',
                Emailencodingkey='UTF-8',
                Firstname='firstName',
                Lastname='lastName1',
                Languagelocalekey='en_US',
                Localesidkey='en_US',
                ProfileId = profileId,
                Timezonesidkey='America/Los_Angeles',
                Username='testUnixId@roche.com1',
                External_Id_gne__c = 'testUnixId'
            );
	}
	
	@isTest static void testStatusCode() {
		Test.setMock(HttpCalloutMock.class, new GNE_SFA2_Peeps_API_Engine_Test(true, false, false));
		Http h = new Http();
		HttpResponse res = h.send(new HttpRequest());
		system.assertEquals(res.getStatusCode(), 200);

		Test.setMock(HttpCalloutMock.class, new GNE_SFA2_Peeps_API_Engine_Test(false, false, false));
		h = new Http();
		res = h.send(new HttpRequest());
		system.assertEquals(res.getStatusCode(), 401);
	}

	@isTest static void userWithWrongLicense(){
		initCustomSettings();
		Id wrongProfileId = [SELECT Id FROM Profile WHERE Id NOT IN :GNE_SFA2_Peeps_API_Engine.getMatchingProfileIds() AND UserType = 'Standard' LIMIT 1][0].Id;
		User u = prepareTestUser(wrongProfileId);
		Test.startTest();
		insert u;
		Test.stopTest();
		u = [SELECT Id, Title, Department, Phone, MobilePhone, Street, City, FullPhotoUrl, External_Id_gne__c FROM User WHERE Id = :u.Id LIMIT 1];
		system.assertEquals('testUnixId', u.External_Id_gne__c);
		system.assertEquals(null, u.Title);
		system.assertEquals(null, u.Department);
		system.assertEquals(null, u.Phone);
		system.assertEquals(null, u.MobilePhone);
		system.assertEquals(null, u.Street);
		system.assertEquals(null, u.City);
		system.assert(u.FullPhotoUrl.endsWith('/005/F'), 'Actual FullPhotoUrl: ' + u.FullPhotoUrl);
	}

	/*@isTest static void usersWithValidLicenseAndSuccessfullPath(){
		initCustomSettings('Basic', 'Salesforce');
		Id correctProfileId = [SELECT Id FROM Profile WHERE Id NOT IN :GNE_SFA2_Peeps_API_Engine.getMatchingProfileIds() AND UserType = 'Standard' LIMIT 1][0].Id;
		User u = prepareTestUser(correctProfileId);
		Test.startTest();
		insert u;
		Test.setMock(HttpCalloutMock.class, new GNE_SFA2_Peeps_API_Engine_Test(false, false, true));
		GNE_SFA2_Peeps_API_Engine.enrichUserData(new List<Id>{u.Id});
		Test.stopTest();
		u = [SELECT Id, Title, Department, Phone, MobilePhone, Street, City, FullPhotoUrl, External_Id_gne__c FROM User WHERE Id = :u.Id LIMIT 1];
		system.assertEquals('testUnixId', u.External_Id_gne__c);
		system.assertEquals('Chief Librarian', u.Title);
		system.assertEquals('Ultramarines', u.Department);
		system.assertEquals('12345', u.Phone);
		system.assertEquals('54321', u.MobilePhone);
		system.assertEquals('Building: A124, Office: R124151, Mail Stop: Z14', u.Street);
		system.assertEquals('Macragge', u.City);
		system.assert(u.FullPhotoUrl.endsWith('/005/F'), 'Actual FullPhotoUrl: ' + u.FullPhotoUrl);
	}*/
}