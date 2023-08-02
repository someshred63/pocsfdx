@isTest(seeAllData=false)
private class EDM_Classification_Section_SFDC_Ext_Test{

	static testMethod void csControllerTest(){

		Account acc = new Account(Name='testAccount');
        insert acc;

		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(
			EDM_Account_gne__c = acc.Id,
			EDM_Type_of_Classification_gne__c = 'Clinical',
			EDM_Status_gne__c = 'Pending'
		);
        insert req;
        req = new EDM_Classification_Request_gne__c(
			EDM_Account_gne__c = acc.Id,
			EDM_Type_of_Classification_gne__c = 'Business',
			EDM_Status_gne__c = 'Pending'
		);
        insert req;

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);

		EDM_Classification_Section_SFDC_Ext ext = new EDM_Classification_Section_SFDC_Ext(sc);


		System.assert(ext.isBusinessClassifcationPending);
		System.assert(ext.isClinicalClassifcationPending);

		System.assertEquals(Date.today(),ext.clinicalClassDate);
		System.assertEquals(Date.today(),ext.businessClassDate);

		PageReference pr = Page.EDM_Classification_Request_Create_SFDC;
		pr.getParameters().put('accountId', acc.Id);
		pr.getParameters().put('retUrl', '/' + acc.Id);
		pr.getParameters().put('typeOfClassification', 'Business');	

		System.assertEquals(pr.getUrl(),ext.newBusinessRequestUrl);
		
		pr = Page.EDM_Classification_Request_Create_SFDC;
		pr.getParameters().put('accountId', acc.Id);
		pr.getParameters().put('retUrl', '/' + acc.Id);
		pr.getParameters().put('typeOfClassification', 'Clinical');	

		System.assertEquals(pr.getUrl(),ext.newClinicalRequestUrl);
	}
}