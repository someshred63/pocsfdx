public with sharing class CONGA_SponsorProperties extends CONGA_Iproperties {

    public String name { get; set; }
    public Boolean isActive { get; set; }
    public String businessUnit {get;set;}

	public CONGA_SponsorProperties(CONGA_Sponsor_gne__c sponsor){
		this.id = sponsor.id; 
		this.name = sponsor.name; 
		this.isActive = sponsor.isActive__c; 
		this.businessUnit = sponsor.BU__c;
	}
}