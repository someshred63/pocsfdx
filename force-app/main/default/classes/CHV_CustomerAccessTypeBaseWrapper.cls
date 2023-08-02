global virtual with sharing class CHV_CustomerAccessTypeBaseWrapper {
	public String id;
	
	public CHV_CustomerAccessTypeBaseWrapper(CHV_Customer_Access__c cat){
		this.id = cat.Id;
	}
}