/**
*  @author: Lukasz Kozminski, Roche
*  Created: 2016-07-22
* This class contains unit tests for validating the behavior of CAN SPAM Email Opt Out service.
* and triggers.
*/
@isTest
private class GNE_SFA2_CAN_SPAM_opt_out_Test {

	private final static Integer recordsNumber = 180;//it cannot be more than 200 (No more than one executeBatch can be called from within a test method) records, some records are created not using loops so recordsNumber has to be less than 200
	
	@testSetup 
	private static void init() {
		List<GNE_SFA2_CAN_SPAM_Config__c> config = new List<GNE_SFA2_CAN_SPAM_Config__c>();
		config.add(new GNE_SFA2_CAN_SPAM_Config__c(name='AuthorizationToken', Configuration_Value_gne__c='test'));
		config.add(new GNE_SFA2_CAN_SPAM_Config__c(name='EndpointForEmail', Configuration_Value_gne__c='test'));
		config.add(new GNE_SFA2_CAN_SPAM_Config__c(name='EndpointForList', Configuration_Value_gne__c='test'));
		insert config;
    }
	
	static testMethod void insertTest() {
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/CanSpamOptOut';  
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> params = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
		for (Integer i = 0; i < recordsNumber; i++) {
			String email = getEmailAddress(i);
			params.add(new GNE_SFA2_CAN_SPAM_opt_out.OptOutData(email, 'channel' + i, Datetime.now())); 
		}
		GNE_SFA2_CAN_SPAM_opt_out.CamOptOutResponse response = GNE_SFA2_CAN_SPAM_opt_out.saveData(params);
		
		system.assertEquals(recordsNumber, [Select count() FROM CAN_SPAM_Email_Opt_Out_gne__c]);
		system.assertEquals(recordsNumber, response.recordsInserted);
		system.assertEquals(0, response.recordsUpdated);
		system.assertEquals(0, response.errorsCount);
		system.assert(response.errors.isEmpty());
		system.assert(response.success);
	}
	
	static testMethod void upsertTest() {
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/CanSpamOptOut';  
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		List<CAN_SPAM_Email_Opt_Out_gne__c>spamData = new List<CAN_SPAM_Email_Opt_Out_gne__c>();
		Datetime st = Datetime.now();
		for (Integer i = 0; i < recordsNumber; i++) {
			String email = getEmailAddress(i);
			spamData.add(new CAN_SPAM_Email_Opt_Out_gne__c(Email_gne__c = email, Channel_gne__c = 'channel' + i, Opt_Out_Date_gne__c = st)); 
		}
		insert spamData;
		
		Datetime baseData = Datetime.now().addDays(1*(recordsNumber/2));
		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> params = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
		for (Integer i = 0; i < recordsNumber; i++) {
			String email = getEmailAddress(i);
			params.add(new GNE_SFA2_CAN_SPAM_opt_out.OptOutData(email, 'channel' + i, baseData.addDays(i))); 
		}
		GNE_SFA2_CAN_SPAM_opt_out.CamOptOutResponse response = GNE_SFA2_CAN_SPAM_opt_out.saveData(params);
		
		System.assertEquals(recordsNumber, [Select count() FROM CAN_SPAM_Email_Opt_Out_gne__c]);
		for (CAN_SPAM_Email_Opt_Out_gne__c ooData : [Select Opt_Out_Date_gne__c, Email_gne__c FROM CAN_SPAM_Email_Opt_Out_gne__c]) {
			System.assert(ooData.Opt_Out_Date_gne__c > st, ooData);
		}
		
		system.assertEquals(0, response.recordsInserted);
		system.assert(response.recordsUpdated > 0);
		system.assertEquals(0, response.errorsCount);
		system.assert(response.errors.isEmpty());
		system.assert(response.success);
		
	}
	
	static testMethod void differentChannelsTest() {
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/CanSpamOptOut';  
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;
		
		List<CAN_SPAM_Email_Opt_Out_gne__c>spamData = new List<CAN_SPAM_Email_Opt_Out_gne__c>();
		Datetime st = Datetime.now();
		for (Integer i = 0; i < recordsNumber; i++) {
			String email = getEmailAddress(i);
			spamData.add(new CAN_SPAM_Email_Opt_Out_gne__c(Email_gne__c = email, Channel_gne__c = 'channel' + i, Opt_Out_Date_gne__c = st)); 
		}
		insert spamData;
		
		Datetime baseData = Datetime.now().addDays(-1*(recordsNumber/2));
		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> params = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
		for (Integer i = 0; i < recordsNumber; i++) {
			String email = getEmailAddress(i);
			params.add(new GNE_SFA2_CAN_SPAM_opt_out.OptOutData(email, 'channel' + (recordsNumber+i), baseData.addDays(i))); 
		}
		GNE_SFA2_CAN_SPAM_opt_out.CamOptOutResponse response = GNE_SFA2_CAN_SPAM_opt_out.saveData(params);
		
		system.assertEquals(recordsNumber*2, [Select count() FROM CAN_SPAM_Email_Opt_Out_gne__c]);
		system.assertEquals(recordsNumber, response.recordsInserted);
		system.assertEquals(response.recordsUpdated,  0);
		system.assertEquals(0, response.errorsCount);
		system.assert(response.errors.isEmpty());
		system.assert(response.success);
		
	}
	
	static testMethod void testOptOutBatch() {

		// Create 200 test accounts - this simulates one execute.  
		// Important - the Salesforce.com test framework only allows you to 
		// test one execute.  
		System.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Map<String, Account> accounts = new Map<String, Account>();
		for (Integer i = 0; i < recordsNumber; i++) {
			String name = 'testAccount' + i;
			accounts.put(name, new Account(Name = name)); 
		}
		insert accounts.values();
		
		List <Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < recordsNumber; i++) {
			Contact con = new Contact(FirstName='testContactFN'+i, LastName='testContactLN'+i, Email =  getEmailAddress(i), AccountId = accounts.get('testAccount' + i).Id); 
			contacts.add(con);
		}
		insert contacts;
		
		Contact contactNotOptOut = new Contact(FirstName='notOptOut', LastName='notOptOut', Email =  'optOut@test.com', AccountId = accounts.get('testAccount' + 0).Id, Has_Opted_Out_gne__c=false);
		insert contactNotOptOut;
		
		Datetime st = Datetime.now();
		List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData> params = new List<GNE_SFA2_CAN_SPAM_opt_out.OptOutData>();
		for (Integer i = 0; i < recordsNumber + 10; i++) {
			String email = getEmailAddress(i);
			params.add(new GNE_SFA2_CAN_SPAM_opt_out.OptOutData(email, 'GLOBAL', st)); 
		}
		GNE_SFA2_CAN_SPAM_opt_out.saveData(params);
		
		Test.startTest();
		
		GNE_SFA2_CAN_SPAM_opt_out_Batch optOutbatch = new GNE_SFA2_CAN_SPAM_opt_out_Batch();
		ID batchprocessid = Database.executeBatch(optOutbatch);
		
		Test.stopTest();
		
		for (Contact con : [Select Firstname, Has_Opted_Out_gne__c, Has_Opted_Out_Date_gne__c, Email FROM Contact]) {
			if (con.Firstname == contactNotOptOut.FirstName) {
				system.assert(!con.Has_Opted_Out_gne__c, con);
				system.assertEquals(null, con.Has_Opted_Out_Date_gne__c);
			} else {
				system.assertEquals(true, con.Has_Opted_Out_gne__c);
				system.assertNotEquals(null, con.Has_Opted_Out_Date_gne__c);
			}
		}
	}
	
	private static String getEmailAddress(Integer num) {
		return 'test' + num + '@test.com';
	}
	
	
	class MockHttpResponseGenerator implements HttpCalloutMock {

    	public HTTPResponse respond(HTTPRequest req) {
		    // Create a fake response
		    HttpResponse res = new HttpResponse();
		    res.setHeader('Content-Type', 'application/json');
		    res.setHeader('pageCount', '0');
		    res.setBody('[]');
		    res.setStatusCode(200);
        	return res;
    	}
}
}