global class CHV_CustomerAccessTypeWrapper extends CHV_CustomerAccessTypeBaseWrapper {
	
	public String name;
	public String accessIconHDEncodedImage;
	public String accessIconSDEncodedImage;
	public String notes;
	
	public CHV_CustomerAccessTypeWrapper(CHV_Customer_Access__c cat){
		super(cat);
		this.name = cat.Name;
		this.accessIconHDEncodedImage = CHV_Utils.getImageId(cat.Access_Icon_HD_URL__c);
		this.accessIconSDEncodedImage = CHV_Utils.getImageId(cat.Access_Icon_SD_URL__c);
		this.notes = String.valueOf(cat.Notes__c);
	}
}