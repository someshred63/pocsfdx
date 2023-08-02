global class CHV_AccountManagerWrapper extends CHV_AccountManagerBaseWrapper{
	
	public String name;
	public String photoEncodedImage;
	public String email;
	public String deskPhone;
	public String cellPhone;
	
	public CHV_AccountManagerWrapper(CHV_Account_Manager__c am){
		super(am);
		this.name = am.Name;
		this.photoEncodedImage = CHV_Utils.getImageId(am.Photo_URL__c);
		this.email = am.Email_ID__c;
		this.deskPhone = am.Desk_Phone__c;
		this.cellPhone = am.Cell_Phone__c;
	}
	
}