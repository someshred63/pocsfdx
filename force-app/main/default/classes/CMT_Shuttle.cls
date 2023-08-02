global class CMT_Shuttle extends CMT_JSONWrapper
{
    public String Description { get; set; }
    public String Type { get; set; }
    
    public CMT_Shuttle()
    {
    }
    
    private void init (CMT_Shuttle_gne__c shuttle, List<CMT_Attachment> attachments)
    {
    	if (shuttle != null)
    	{
    		Id = shuttle.Id;
        	Description = shuttle.Description_gne__c;
        	Type = shuttle.Type_gne__c;
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
    	}
    }
    
    public CMT_Shuttle (CMT_Shuttle_gne__c shuttle)
    {
    	init (shuttle, null);    
    }
    
    public CMT_Shuttle (CMT_Shuttle_gne__c shuttle, List<CMT_Attachment> attachments)
    {
    	init (shuttle, attachments);    
    }
}