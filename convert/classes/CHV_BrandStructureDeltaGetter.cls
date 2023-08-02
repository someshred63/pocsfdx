@RestResource(urlMapping='/BrandStructureDelta/*')
global with sharing class CHV_BrandStructureDeltaGetter {

	@HttpGet
	global static CHV_BrandBaseWrapper getBrandStructureDelta() {
		RestRequest req = RestContext.request;
		String params = Encodingutil.urlDecode(req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1), 'UTF-8');
		String[] paramsSpl = params.split('#');
		String brandId = paramsSpl[0];
		String timestamp = paramsSpl[1];
		Long timestampL = Long.valueOf(timestamp) * 1000;
		Datetime lastUpdate = Datetime.newInstance(timestampL);
		
		CHV_Brand__c brand = [SELECT Id, Name, Distribution_Model_Diagram_URL__c, Distribution_Model_Description__c, 
							iPad_Brand_Logo_HD_URL__c, iPad_Brand_Logo_SD_URL__c, iPhone_Brand_Logo_HD_URL__c, iPhone_Brand_Logo_SD_URL__c,
							LastModifiedDate FROM CHV_Brand__c WHERE Id =: brandId];
		return CHV_BrandStructureBuilder.buildWrapper(brand, lastUpdate);
	}
}