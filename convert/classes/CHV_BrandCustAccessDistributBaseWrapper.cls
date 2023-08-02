global virtual with sharing class CHV_BrandCustAccessDistributBaseWrapper {
	public String id;
	public CHV_AuthorizedDistributorBaseWrapper authorizedDistributor;
	
	global CHV_BrandCustAccessDistributBaseWrapper(CHV_Brand_Customer_Access_Distributor__c bcad){
		this.id = bcad.Id;
	}
}