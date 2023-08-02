global virtual with sharing class CHV_BrandCustomerAccessTypesBaseWrapper {
	
	public String id;
	
	public CHV_CustomerAccessTypeBaseWrapper accessType;
	public List<CHV_BrandCustAccessDistributBaseWrapper> accessDistributors;
	
	global CHV_BrandCustomerAccessTypesBaseWrapper(CHV_Brand_Customer_Access__c bca){
		this.id = bca.Id;
	}

}