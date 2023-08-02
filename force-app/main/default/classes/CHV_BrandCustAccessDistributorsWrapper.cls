global class CHV_BrandCustAccessDistributorsWrapper extends CHV_BrandCustAccessDistributBaseWrapper {
	public String name;
	public String authorizedDistributorNote;
	
	public CHV_BrandCustAccessDistributorsWrapper(CHV_Brand_Customer_Access_Distributor__c bcad){
		super(bcad);
		this.name = bcad.Name;
		this.authorizedDistributorNote = String.valueOf(bcad.Authorized_Distributor_Note__c);
	}
}