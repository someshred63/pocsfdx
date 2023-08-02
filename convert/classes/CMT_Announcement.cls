public class CMT_Announcement extends CMT_JSONWrapper
{
    public String Description { get; set; }
    public ID RecordId { get; set; }
    public String Name { get; set; }
    
    public CMT_Announcement()
    {
    }
    
    private void init (CMT_Announcement_gne__c a, List<CMT_Attachment> attachments)
    {
    	if (a != null)
        {
        	Id = a.Id;
            Description = a.Description_gne__c;
            RecordId = a.Record_Id_gne__c;
            Name = a.Name_gne__c;
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }	
    }
    
    public CMT_Announcement (CMT_Announcement_gne__c a)
    {
		init (a, null);   
    }
    
    public CMT_Announcement (CMT_Announcement_gne__c a, List<CMT_Attachment> attachments)
    {
		init (a, attachments);   
    }
}