public abstract class CMT_JSONWrapper
{
    public ID Id { get; set; }
    public List<CMT_Attachment> Attachments { get; set; }
    
    public CMT_JSONWrapper()
    {
    	// even if the collection is empty, we don't want it to be null
    	Attachments = new List<CMT_Attachment>();
    }
    
    public void addAttachment (CMT_Attachment a)
    {
        if (Attachments == null)
        {
            Attachments = new List<CMT_Attachment>();
        }
        
        Attachments.add(a);
    }
}