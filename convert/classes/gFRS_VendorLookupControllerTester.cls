@isTest
private class gFRS_VendorLookupControllerTester {
	class TestSettings {
	 	public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        
         public TestSettings(){
         	this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.account;
        	
        	this.organization = gFRS_TestCreationUtils.createOrganization2( 'IBM', this.account.id );
        	insert this.organization;
        	
        	this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
        	insert this.location;
        }
        
	 }
	 
	 static testMethod void testVendorLookupController() {
	 	TestSettings ts = new TestSettings();
	 	gFRS_VendorLookupController cont = new gFRS_VendorLookupController(new ApexPages.StandardController(ts.location));
	 	
	 	System.assertEquals(ts.location.Id,cont.currentLocation.Id);
	 	
	 	GFRS_VendorLookupSAP.VendorDetails_element[] VendorDetailsList = new List<GFRS_VendorLookupSAP.VendorDetails_element>();
	 	GFRS_VendorLookupSAP.VendorDetails_element detail1 = new GFRS_VendorLookupSAP.VendorDetails_element();
 		detail1.AddressLine1 = 'PO BOX 5100 STN F';
 		detail1.City = 'TORONTO';
 		detail1.Country='CA';
 		detail1.NameLine1='IBM CANADA LTD.';
 		detail1.PaymentMethod='E';
 		detail1.State='ON';
 		detail1.VendorAccountGroup='Z003';
 		detail1.VendorID='0090301926';
 		detail1.Zip='M4Y 2T5aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
	 		
	 	VendorDetailsList.add(detail1);
	 	
	 	GFRS_VendorLookupSAP.VendorDetails_element detail2 = new GFRS_VendorLookupSAP.VendorDetails_element();
 		detail2.AddressLine1 = 'PO BOX 534151';
 		detail2.City = 'ATLANTA';
 		detail2.Country='US';
 		detail2.NameLine1='IBM CORP.';
 		detail2.PaymentMethod='C';
 		detail2.State='GA';
 		detail2.VendorAccountGroup='Z003';
 		detail2.VendorID='0003004859';
 		detail2.Zip='30353-4151';
	 	VendorDetailsList.add(detail2);
	 	GFRS_VendorLookupSAP.VendorLookupResponse_element response = new GFRS_VendorLookupSAP.VendorLookupResponse_element();
 		response.MessageText = null;
 		response.TotalRecords = '2'; 
 		response.MessageType = 'S';
 		response.VendorDetails = VendorDetailsList;
	 	
	 	cont.handleResponse(response);
	 	System.assertEquals(2,cont.locationMap.size());
	 	System.assertEquals(true,cont.hasMatchedLocations);
	 	System.assertEquals(true,cont.hasMessages);
	 	
	 	response.MessageText = 'aaaaa';
	 	cont.handleResponse(response);
	 	cont.currentVendorId = null;
	 	cont.savePage();
	 	cont.currentVendorId = '1345';
	 	cont.savePage();
	 	cont.currentVendorId = '0003004859';
	 	cont.savePage();
	 	cont.currentVendorId = '0090301926';
	 	cont.savePage();
	 	
	 	
	 	cont.searchBy = 'vendorId';
	 	cont.searchVendor();
	 	cont.searchBy = 'companyName';
	 	cont.searchVendor();
	 	cont.searchBy = 'asdff';
	 	cont.searchVendor();
	 	
	 	
	 	
	 	Attachment att = gFRS_TestCreationUtils.createAttachment(ts.location.Id, 'testName', Blob.valueOf('testBody'));
        insert att;
      	ts.location.W9_Form_W_8BEN_Form__c = att.id;
      	update ts.location;
	 	cont.sendEmailToCreateLocation();
	 	cont.sendEmailToUpdateLocation();
	 	
	 	
	 	
	 	gFRS_VendorLookupController.sendSAPEmail(Id.valueOf('01pS00000001qQN'), true);
	 	gFRS_VendorLookupController.sendSAPEmail(Id.valueOf('01pS00000001qQN'), null);
	 	cont = new gFRS_VendorLookupController(new ApexPages.StandardController(new GFRS_Location__c()));
	 	
	 }
	 
	
	static testMethod void testInnerClasses(){
		//-- the classes do not contain logic but use internal SFDC functionality for usign the calls.
		GFRS_VendorLookupGFRS.VendorLookup request = new GFRS_VendorLookupGFRS.VendorLookup();
		GFRS_VendorLookupGFRS.VendorLookupResponse response = new GFRS_VendorLookupGFRS.VendorLookupResponse();
		
	}
}