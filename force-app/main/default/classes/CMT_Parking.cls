global class CMT_Parking extends CMT_JSONWrapper
{
    public String Description { get; set; }

    public CMT_Parking()
    {
    }
    
    private void init (CMT_Parking_gne__c parking, List<CMT_Attachment> attachment)
    {
    	if (parking != null)
    	{
        	Id = parking.Id;
        	Description = parking.Description_gne__c;
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
    	}
    }
    
    public CMT_Parking (CMT_Parking_gne__c parking)
    {
    	init (parking, null);
    }
    
    public CMT_Parking (CMT_Parking_gne__c parking, List<CMT_Attachment> attachments)
    {
    	init (parking, attachments);
    }
}