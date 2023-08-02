public class CMT_Hotel_Group extends CMT_Group
{
	public List<CMT_Hotel> Hotels { get; set; }
	
	public CMT_Hotel_Group (ID id, String name)
	{
		super(id, name);
		Hotels = new List<CMT_Hotel>();
	}
	
	public CMT_Hotel_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		Hotels = new List<CMT_Hotel>();
	}
	
	public void add (CMT_Hotel item)
	{
		if (this.Hotels == null)
		{
			this.Hotels = new List<CMT_Hotel>();
		}
		
		this.Hotels.add(item);
	}
}