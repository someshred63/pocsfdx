/** @date 3/19/2014
* @Author Pawel Sprysak
* @description Test Class with methods for SIMS Service Class
*/
@isTest
private class VDST_SIMS_Service_Test {
	/** @date 3/19/2014
  	* @Author Pawel Sprysak
  	* @description Test Method - Testing all methods of VDST_UserLookupController
  	*/
  	@IsTest(SeeAllData=false)
  	static void class_Test() {
	    // Prepare data
	    Profile p = [SELECT id FROM Profile WHERE Name='Standard User' LIMIT 1];
	    User usr = new User(alias = 'gssptest', email='gssptestuser@gene.com', firstname = 'testXXX',
	    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
	    localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
	    username='gssptestuser@gene.com');
	    insert usr;
	    VDST_Settings__c sett = new VDST_Settings__c(Name = VDST_Utils.getEnvName(), SIMS_Endpoint__c = 'WRONG_ENDPOINT',
	        SIMS_Username__c = 'USR', SIMS_Password__c = 'PSWRD');
	    insert sett;

	    // Test controller
	    VDST_SIMS_Service sims = new VDST_SIMS_Service();
	    System.assertEquals(sims.SIMS_WEBSERVICE_ENDPOINT, 'WRONG_ENDPOINT');
	    System.assertEquals(sims.SIMS_WEBSERVICE_USERNAME, 'USR');
	    System.assertEquals(sims.SIMS_WEBSERVICE_PASSWORD, 'PSWRD');
	    System.assertEquals(sims.SIMS_APP, 'gssp');
	    // registerSIMSUser(user id)
	    System.assertEquals(sims.registerSIMSUser(usr.Id), false); // Because endpoing and other credential are wrong
	    System.assertEquals(sims.registerSIMSUser(p.Id), false);
	    // registerSIMSUser(user)
	    System.assertEquals(sims.registerSIMSUser(usr), false); // Because endpoing and other credential are wrong
	    // findUserById()
	    System.assertNotEquals(sims.findUserById(usr.Id), null);
	    // subString()
	    System.assertEquals(sims.subString(null), '');
	    System.assertEquals(sims.subString('abc'), 'abc');
	    // Inner class constructor test
	    VDST_SIMS_Service.SimsExceptionResponse ser = new VDST_SIMS_Service.SimsExceptionResponse();
	    System.assertEquals(ser.exceptionObj.stackTrace, '');
	    System.assertEquals(ser.exceptionObj.message, '');
	}
}