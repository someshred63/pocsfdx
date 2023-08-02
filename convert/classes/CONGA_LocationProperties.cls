public with sharing class CONGA_LocationProperties {

    public ID id { get; set; }
    public String name { get; set; }
	public String country { get; set; } 
	public String city { get; set; } 
	public String canadianProvince { get; set; } 
	public Decimal latitude { get; set; } 
	public Decimal longitude { get; set; } 
	public Boolean eventLocation{ get; private set; }
	public Boolean physicianLocation{ get; private set; }
	
	
	public CONGA_LocationProperties(){
		//set default values
		this.eventLocation= false;  
		this.physicianLocation = false; 
	}
	
	public CONGA_LocationProperties(CONGA_Event_Location_gne__c location){
		this(); 
		this.id = location.id; 
		this.name = location.name; 
		this.Country = location.Country__c;
		this.City = location.name;
		this.canadianProvince = location.Province_can__c; 
		this.Latitude = location.Latitude__c; 
		this.Longitude = location.Longitude__c;
		this.eventLocation= true;  
	}
	
	public CONGA_LocationProperties(Address_vod__c location){
		this(); 
		System.debug('###'+ location); 
		this.id = location.id; 
		this.name = location.name; 
		this.Country = location.Country_gen__c; 
		this.City = location.City_vod__c;
		this.canadianProvince = location.Province_can_gne__c; 
		this.Latitude = location.Latitude_vod__c; 
		this.Longitude = location.Longitude_vod__c; 
		physicianLocation = true; 
	}
		

}