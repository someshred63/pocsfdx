public abstract class CMT_Group
{
	public ID Id { get; set; }
	public String Name { get; set; }
	public List<CMT_Attachment> Attachments { get; set; }
	
	public CMT_Group ()
	{
		Attachments = new List<CMT_Attachment>();
	}
	
	public CMT_Group (ID id, String name)
	{
		init (id, name, null);
	}
	
	public CMT_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		init(id, name, attachments);	
	}
	
	private void init (ID id, String name, List<CMT_Attachment> attachments)
	{
		this.Id = id;
		this.Name = name;
		this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
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