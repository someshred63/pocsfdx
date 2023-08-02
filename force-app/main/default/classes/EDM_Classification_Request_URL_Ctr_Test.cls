@isTest
private class EDM_Classification_Request_URL_Ctr_Test {
	
	@isTest static void testSFDCLayout() {
		EDM_Classification_Request_URL_Ctr ctr = new EDM_Classification_Request_URL_Ctr();
		ctr.profileName = 'GNE-AGS-CCO-Analyst';
		ctr.accountId = 'dummyId';
		ctr.classificationType = 'Business';
		String resultURL = ctr.getClassificationURL();
		System.debug(resultURL);
		System.assert(resultURL.toLowerCase().contains('edm_classification_request_create_sfdc'));
	}
	
	@isTest static void testNewLayout() {
		EDM_Classification_Request_URL_Ctr ctr = new EDM_Classification_Request_URL_Ctr();
		ctr.profileName = 'GNE-TLS';
		ctr.accountId = 'dummyId';
		ctr.classificationType = 'Business';
		String resultURL = ctr.getClassificationURL();
		System.debug(resultURL);
		System.assert(resultURL.toLowerCase().contains('edm_classification_request_edit_create'));
	}

	@isTest static void testNoURL() {
		EDM_Classification_Request_URL_Ctr ctr = new EDM_Classification_Request_URL_Ctr();
		ctr.profileName = 'dummyProfile';
		ctr.accountId = 'dummyId';
		ctr.classificationType = 'Business';
		String resultURL = ctr.getClassificationURL();
		System.debug(resultURL);
		System.assert(resultURL == 'no url');
	}
}