public class CMT_Information_Group extends CMT_Group
{
	public List<CMT_Information> Infos { get; set; }
	
	public CMT_Information_Group (ID id, String name)
	{
		super(id, name);
		Infos = new List<CMT_Information>();
	}
	
	public CMT_Information_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		Infos = new List<CMT_Information>();
	}
	
	public void add (CMT_Information item)
	{
		if (this.Infos == null)
		{
			this.Infos = new List<CMT_Information>();
		}
		
		this.Infos.add(item);
	}
}