global class CMT_Transportation extends CMT_JSONWrapper
{
    public List<CMT_Shuttle> Shuttles { get; set; }
    public List<CMT_TaxiCompany> TaxiCompanies { get; set; }
    public List<CMT_Parking> Parkings { get; set; }
    
    // Initializes the object
    // @param transportation - the transportation object from which the initialization takes place
    // @param attachments - attachments grouped by parent ID
    private void init (CMT_Transportation_gne__c transportation, Map<Id, List<CMT_Attachment>> attachments)
    {
    	if (transportation != null)
    	{
	    	Id = transportation.Id;
	  
	  		if (attachments == null)
	  		{
	  			attachments = new Map<Id, List<CMT_Attachment>>();
	  		}
	  		
	    	this.Attachments = attachments.get(transportation.Id);
	    	
	    	if (this.Attachments == null)
	    	{
	    		this.Attachments = new List<CMT_Attachment>();
	    	}
	        
	        Shuttles = new List<CMT_Shuttle>();
	        for (CMT_Shuttle_gne__c shuttle : transportation.Shuttles__r)
	        {
	            Shuttles.add(new CMT_Shuttle(shuttle, attachments.get(shuttle.Id)));
	        }
	        
	        TaxiCompanies = new List<CMT_TaxiCompany>();
	        for (CMT_Taxi_Company_gne__c tc : transportation.Taxi_Companies__r)
	        {
	            TaxiCompanies.add(new CMT_TaxiCompany(tc, attachments.get(tc.Id)));
	        }
	        
	        Parkings = new List<CMT_Parking>();
	        for (CMT_Parking_gne__c p : transportation.Parkings__r)
	        {
	            Parkings.add(new CMT_Parking(p, attachments.get(p.Id)));
	        }
    	}
    }
    
    public CMT_Transportation (CMT_Transportation_gne__c transportation)
    {
        init (transportation, null);
    }
    
    public CMT_Transportation (CMT_Transportation_gne__c transportation, Map<Id, List<CMT_Attachment>> attachments)
    {
        init (transportation, attachments);
    }
}