public class CMT_Exhibit extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public String Description { get; set; }
    public String Location { get; set; }
    
    public CMT_Exhibit()
    {
        // empty
    }
    
    private void init (CMT_Exhibit_gne__c e, List<CMT_Attachment> attachments)
    {
    	if (e != null)
    	{
    		Id = e.Id;
        	Name = e.Name;
        	Description = e.Description_gne__c;
        	Location = e.Location_gne__c;
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
    	}
    }
    
    public CMT_Exhibit (CMT_Exhibit_gne__c e, List<CMT_Attachment> attachments)
    {
        init(e, attachments);
    }
    
    public CMT_Exhibit (CMT_Exhibit_gne__c e)
    {
        init(e, attachments);
    }
}