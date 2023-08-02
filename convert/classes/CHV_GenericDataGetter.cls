@RestResource(urlMapping='/GenericData')
global with sharing class CHV_GenericDataGetter {

	global class CHV_GenericDataWrapper {
		String Id, genericDistributionModelDescription, genericDistributionModelDiagramEncodedImage, userAccessLevel;
	
		global CHV_GenericDataWrapper(CHV_Generic_Data__c gd) {
			this.Id = gd.Id;
			this.genericDistributionModelDescription = gd.Generic_Distribution_Model_Description__c;
			this.genericDistributionModelDiagramEncodedImage = CHV_Utils.getImageId(gd.Generic_Distribution_Model_Diagram_URL__c);
			this.userAccessLevel = CHV_Utils.getUserAccessLevel();
		}
		
		//constructor to send proper structure filled with null values (except for userAccessLevel) in case there's no CHV_Generic_Data__c record
		global CHV_GenericDataWrapper() {
			this.Id = null;
			this.genericDistributionModelDescription = null;
			this.genericDistributionModelDiagramEncodedImage = null;
			this.userAccessLevel = CHV_Utils.getUserAccessLevel();
		}
	}
	
	@HttpGet
	global static CHV_GenericDataWrapper getGenericData() {
		List<CHV_Generic_Data__c> genericData = [select Id, Generic_Distribution_Model_Description__c, Generic_Distribution_Model_Diagram_URL__c from CHV_Generic_Data__c];
		if (CHV_Utils.listNotEmpty(genericData)){
			return new CHV_GenericDataWrapper(genericData[0]);
		}
		else {
			return new CHV_GenericDataWrapper();
		}
	}
		
}