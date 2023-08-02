public class CMT_Exhibit_Group extends CMT_Group
{
	public List<CMT_Exhibit> Exhibits { get; set; }
	
	public CMT_Exhibit_Group (ID id, String name)
	{
		super(id, name);
		Exhibits = new List<CMT_Exhibit>();
	}
	
	public CMT_Exhibit_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		Exhibits = new List<CMT_Exhibit>();
	}
	
	public void add (CMT_Exhibit item)
	{
		if (this.Exhibits == null)
		{
			this.Exhibits = new List<CMT_Exhibit>();
		}
		
		this.Exhibits.add(item);
	}
}