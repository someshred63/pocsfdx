public class CMT_Event_Group extends CMT_Group
{
	public List<CMT_Event> Events { get; set; }
	
	public CMT_Event_Group (ID id, String name)
	{
		super(id, name);
		Events = new List<CMT_Event>();
	}
	
	public CMT_Event_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		Events = new List<CMT_Event>();
	}
	
	public void add (CMT_Event item)
	{
		if (this.Events == null)
		{
			this.Events = new List<CMT_Event>();
		}
		
		this.Events.add(item);
	}
}