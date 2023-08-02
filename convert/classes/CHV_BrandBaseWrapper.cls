global virtual with sharing class CHV_BrandBaseWrapper {
	public String brandId;
	public String currentTimestamp;
	
	public List<CHV_TalkingPointBaseWrapper> talkingPoints;
	public List<CHV_BrandCustomerAccessTypesBaseWrapper> brandCustomerAccessTypes;
	
	public CHV_BrandBaseWrapper(){}
	
	public CHV_BrandBaseWrapper(CHV_Brand__c brand){
		this.brandId = brand.Id;
		this.currentTimestamp = CHV_Utils.getCurrentTimeInTimestampGMT();
	}
}