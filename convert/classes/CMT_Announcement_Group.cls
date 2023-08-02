public class CMT_Announcement_Group extends CMT_Group
{
	public List<CMT_Announcement> Announcements { get; set; }
	
	public CMT_Announcement_Group (ID Id, String name)
	{
		super (id, name);
		Announcements = new List<CMT_Announcement>();
	}
	
	public CMT_Announcement_Group (ID Id, String name, List<CMT_Attachment> attachments)
	{
		super (id, name, attachments);
		Announcements = new List<CMT_Announcement>();
	}
	
	public void add (CMT_Announcement item)
	{
		if (this.Announcements == null)
		{
			this.Announcements = new List<CMT_Announcement>();
		}
		
		this.Announcements.add(item);
	}
}