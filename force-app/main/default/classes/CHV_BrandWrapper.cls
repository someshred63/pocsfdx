global class CHV_BrandWrapper extends CHV_BrandBaseWrapper{
   	
   	public String brandName;
   	public String distributionModelDiagramEncodedImage;
   	public String distributionModelDescription;
   	public String iPadBrandLogoHDEncodedImage;
   	public String iPadBrandLogoSDEncodedImage;
   	public String iPhoneBrandLogoHDEncodedImage;
   	public String iPhoneBrandLogoSDEncodedImage;
   	
	public CHV_BrandWrapper(CHV_Brand__c brand){
		super(brand);
		this.brandName = brand.Name;
		this.distributionModelDiagramEncodedImage = CHV_Utils.getImageId(brand.Distribution_Model_Diagram_URL__c);
		this.distributionModelDescription = brand.Distribution_Model_Description__c;
		this.iPadBrandLogoHDEncodedImage = CHV_Utils.getImageId(brand.iPad_Brand_Logo_HD_URL__c);
		this.iPadBrandLogoSDEncodedImage = CHV_Utils.getImageId(brand.iPad_Brand_Logo_SD_URL__c);
		this.iPhoneBrandLogoHDEncodedImage = CHV_Utils.getImageId(brand.iPhone_Brand_Logo_HD_URL__c);
		this.iPhoneBrandLogoSDEncodedImage = CHV_Utils.getImageId(brand.iPhone_Brand_Logo_SD_URL__c);
	}
	
}