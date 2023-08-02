global class CHV_BrandCustomerAccessTypesWrapper extends CHV_BrandCustomerAccessTypesBaseWrapper {
	
	public String name;
	public String displayedName;
	public String notes;
	
	public CHV_BrandCustomerAccessTypesWrapper(CHV_Brand_Customer_Access__c bca){
		super(bca);
		this.name = bca.Name;
		this.displayedName = bca.Brand_Customer_Access_Displayed_Name__c;
		this.notes = bca.Notes__c != null ? String.valueOf(bca.Notes__c).replaceAll('<li style=\"(.*)\">','<li>') : bca.Notes__c;
	}
}