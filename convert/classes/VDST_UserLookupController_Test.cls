/** @date 3/19/2014
* @Author Pawel Sprysak
* @description Test Class with methods for User Lookup Controller
*/
@isTest
private class VDST_UserLookupController_Test {
	/** @date 3/19/2014
  	* @Author Pawel Sprysak
  	* @description Test Method - Testing all methods of VDST_UserLookupController
  	*/
  	@IsTest(SeeAllData=false)
  	static void class_Test() {
	    // Prepare data
	    ApexPages.currentPage().getParameters().put('lksrch', 'Testing');
	    ApexPages.currentPage().getParameters().put('frm', 'test1');
	    ApexPages.currentPage().getParameters().put('txt', 'test2');
	    insert prepareUser(1);
	    insert prepareUser(2);

	    // Test controller search
	    VDST_UserLookupController ulc = new VDST_UserLookupController();
	    System.assertNotEquals(ulc.usr, null);
	    System.assertEquals(ulc.searchString, 'Testing');
	    System.assertNotEquals(ulc.results, null);
	    //System.assertEquals(ulc.results.size(), 1);
	    //System.assertEquals(ulc.results.get(0).UserName, 'gssptestuser@gene.com');
	    ulc.searchString = 'OneTwoThree';
	    // Test search() method
	    ulc.search();
	    System.assertNotEquals(ulc.results, null);
	    //System.assertEquals(ulc.results.size(), 1);
	    //System.assertEquals(ulc.results.get(0).UserName, 'gssptestuser2@gene.com');
	    // Test getFormTag() method
	    System.assertEquals(ulc.getFormTag(), 'test1');
	    // Test getTextBox() method
	    System.assertEquals(ulc.getTextBox(), 'test2');
  	}

  	/** @date 3/19/2014
  	* @Author Pawel Sprysak
  	* @description Internal method for preparing user data
  	*/
  	private static User prepareUser(Integer userNo) {
	    Profile p = [SELECT id FROM Profile WHERE Name='Standard User' LIMIT 1];
	    if(userNo == 1) {
	      	return new User(alias = 'gssptest', email='gssptestuser@gene.com', firstname = 'testXXX',
		        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
		        username='gssptestuser@gene.com');
	    } else if(userNo == 2) {
	      	return new User(alias = 'gssptes2', email='gssptestuser2@gene.com', firstname = 'testXXX',
		        emailencodingkey='UTF-8', lastname='OneTwoThree', languagelocalekey='en_US',
		        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
		        username='gssptestuser2@gene.com');
	    }
	    return null;
  	}
}