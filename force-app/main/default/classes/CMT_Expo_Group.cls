public class CMT_Expo_Group extends CMT_Group
{
	public List<CMT_Expo> Expos { get; set; }
	
	public CMT_Expo_Group (ID id, String name)
	{
		super(id, name);
		Expos = new List<CMT_Expo>();
	}
	
	public CMT_Expo_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		Expos = new List<CMT_Expo>();
	}
	
	public void add (CMT_Expo item)
	{
		if (this.Expos == null)
		{
			this.Expos = new List<CMT_Expo>();
		}
		
		this.Expos.add(item);
	}
}