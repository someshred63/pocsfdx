global class CHV_AuthorizedDistributorWrapper extends CHV_AuthorizedDistributorBaseWrapper{
	
	public String name;
	public String corporateURL;
	public String corporatePhoneNumber;
	public String corporateFax;
	
	public CHV_AuthorizedDistributorWrapper(CHV_Authorized_Distributor__c ad){
		super(ad);
		this.name = ad.Name;
		this.corporateURL = ad.Corporate_URL__c;
		this.corporatePhoneNumber = ad.Corporate_Phone__c;
		this.corporateFax = ad.Corporate_Fax__c;
	}
}