@RestResource(urlMapping='/BusinessUnitsWithBrands')
global with sharing class CHV_BusinessUnitsWithBrandsGetter {
	
	@HttpGet
    global static List<CHV_BusinessUnitWrapper> getBusinessUnitsWithBrands() {
    	
    	List<CHV_BusinessUnitWrapper> businessUnitsWrappers = new List<CHV_BusinessUnitWrapper>();
    	List<CHV_Business_Unit__c> businessUnitsList = [select Id, Name from CHV_Business_Unit__c];
    	List<CHV_Brand__c> brandsList = [select Id, Name, Business_Unit__c, Distribution_Model_Description__c, iPhone_Brand_Logo_SD_URL__c, iPhone_Brand_Logo_HD_URL__c, iPad_Brand_Logo_SD_URL__c, iPad_Brand_Logo_HD_URL__c from CHV_Brand__c];
    	
    	for (CHV_Business_Unit__c businessUnit : businessUnitsList){
    		businessUnitsWrappers.add(new CHV_BusinessUnitWrapper(businessUnit.Id, businessUnit.Name, brandsList));
    	}
    	return businessUnitsWrappers;
    	
    }
    
    global class CHV_BusinessUnitWrapper {
		
		String businessUnitId, businessUnitName;
		List<CHV_Brand_Details_Wrapper> brands = new List<CHV_Brand_Details_Wrapper>();
		
		global CHV_BusinessUnitWrapper(Id businessUnitId, String businessUnitName, List<CHV_Brand__c> allBrandsList){
			this.businessUnitId = String.valueOf(businessUnitId);
			this.businessUnitName = String.valueOf(businessUnitName);
			
			for (CHV_Brand__c brand : allBrandsList){
				if(brand.Business_Unit__c == businessUnitId){
					brands.add(new CHV_Brand_Details_Wrapper(brand));
				}
			}
		}
		
	}
	
	global class CHV_Brand_Details_Wrapper {
		
		String brandId, brandName, distributionModelDescription, iPhoneBrandLogoSDEncodedImage, iPhoneBrandLogoHDEncodedImage, iPadBrandLogoSDEncodedImage, iPadBrandLogoHDEncodedImage;
		
		global CHV_Brand_Details_Wrapper(CHV_Brand__c brand) {
			this.brandId = String.valueOf(brand.Id);
			this.brandName = String.valueOf(brand.Name);
			this.distributionModelDescription = String.valueOf(brand.Distribution_Model_Description__c);
			this.iPhoneBrandLogoSDEncodedImage = CHV_Utils.getImageId(String.valueOf(brand.iPhone_Brand_Logo_SD_URL__c));
			this.iPhoneBrandLogoHDEncodedImage = CHV_Utils.getImageId(String.valueOf(brand.iPhone_Brand_Logo_HD_URL__c));
			this.iPadBrandLogoSDEncodedImage = CHV_Utils.getImageId(String.valueOf(brand.iPad_Brand_Logo_SD_URL__c));
			this.iPadBrandLogoHDEncodedImage = CHV_Utils.getImageId(String.valueOf(brand.iPad_Brand_Logo_HD_URL__c));
		}
		
	}
	
}