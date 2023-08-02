@isTest
public with sharing class GNE_SFA2_ConfigurationEditor_Ctrl_Test {

	@isTest
	public static void testHtmlDecoder() {
		String html = '&lt;p&gt;Test&lt;/p&gt;', result;
		Test.startTest();
 		result = GNE_SFA2_ConfigurationEditor_Controller.htmlDecode(html);
		Test.stopTest();
		System.assertEquals('<p>Test</p>', result);
	}

	@isTest
	public static void testConfigurationGetters() {
		String applicationType = 'TLCRM';
		createSampleConfiguration(applicationType, null, null, 'testBrand', 'System Administrator');
		List<String> roles; List<String> applicationTypes; List<String> brands;
		Test.startTest();
		applicationTypes = GNE_SFA2_ConfigurationEditor_Controller.getApplicationTypes();
		roles = GNE_SFA2_ConfigurationEditor_Controller.getRoles(applicationType);
		brands = GNE_SFA2_ConfigurationEditor_Controller.getBrands(applicationType, 'System Administrator');
		Test.stopTest();
		System.assertEquals('TLCRM', applicationTypes[0]);
		System.assertEquals('System Administrator', roles[0]);
		System.assertEquals('testBrand',brands[0]);
	}

	@isTest
	public static void testPageConfigurationGetter() {
		SFA2_Configuration_Object_gne__c conf = createSampleConfiguration('testApp', 'testObjectName', 'testRecordType', 'testBrand', 'testRole');
		createSampleConfigurationDetails(conf);
		Map<SFA2_Configuration_Object_gne__c, List<SFA2_Configuration_Object_Detail_gne__c>> result;
		Test.startTest();
		result = GNE_SFA2_ConfigurationEditor_Controller.getPageConfiguration('testApp', 'testObjectName', 'testRecordType', 'testBrand', 'testRole');
		Test.stopTest();
		System.assertEquals(1, result.size());
	}

	private static SFA2_Configuration_Object_gne__c createSampleConfiguration(String applicationType,  String objectName, String recordType, String brand, String role) {
		SFA2_Configuration_Object_gne__c conf = new SFA2_Configuration_Object_gne__c(Application_Type__c = applicationType, Role_gne__c = role, Object_Name_gne__c = objectName, Record_Type_gne__c = recordType, Brand_gne__c = brand);   
		insert conf;
		return conf;
	}

	private static void createSampleConfigurationDetails(SFA2_Configuration_Object_gne__c conf) {
		SFA2_Configuration_Object_Detail_gne__c confDetails = new SFA2_Configuration_Object_Detail_gne__c(Configuration_Object_ref_gne__r = conf, 
			Configuration_Object_ref_gne__c = conf.Id);
		insert confDetails;
	}

	@isTest
	public static void testFieldsAsMapGetter() {
		Map<String, GNE_SFA2_ConfigurationEditor_Controller.FieldWrapper> result = GNE_SFA2_ConfigurationEditor_Controller.getFieldsAsMap('Account');
		System.assertEquals('AHA__c', result.get('AHA__c').Name);
	}
}