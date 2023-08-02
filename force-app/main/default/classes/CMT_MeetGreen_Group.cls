public class CMT_MeetGreen_Group extends CMT_Group
{
	public List<CMT_MeetGreen> MeetGreens { get; set; }
	
	public CMT_MeetGreen_Group (ID id, String name)
	{
		super(id, name);
		MeetGreens = new List<CMT_MeetGreen>();
	}
	
	public CMT_MeetGreen_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		MeetGreens = new List<CMT_MeetGreen>();
	}
	
	public void add (CMT_MeetGreen item)
	{
		if (this.MeetGreens == null)
		{
			this.MeetGreens = new List<CMT_MeetGreen>();
		}
		
		this.MeetGreens.add(item);
	}
}