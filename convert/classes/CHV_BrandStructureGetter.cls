@RestResource(urlMapping='/BrandStructure/*')
global with sharing class CHV_BrandStructureGetter {

	@HttpGet
	global static CHV_BrandBaseWrapper getBrandStructure() {
		RestRequest req = RestContext.request;
		String brandId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		CHV_Brand__c brand = [SELECT Id, Name, Distribution_Model_Diagram_URL__c, Distribution_Model_Description__c, 
							iPad_Brand_Logo_HD_URL__c, iPad_Brand_Logo_SD_URL__c, iPhone_Brand_Logo_HD_URL__c, iPhone_Brand_Logo_SD_URL__c,
							LastModifiedDate FROM CHV_Brand__c WHERE Id =: brandId];
		return CHV_BrandStructureBuilder.buildWrapper(brand, null);
	}

}