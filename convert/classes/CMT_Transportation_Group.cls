public class CMT_Transportation_Group extends CMT_Group
{
	public List<CMT_Transportation> Transportations { get; set; }
	
	public CMT_Transportation_Group (ID id, String name)
	{
		super(id, name);
		Transportations = new List<CMT_Transportation>();
	}
	
	public CMT_Transportation_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		Transportations = new List<CMT_Transportation>();
	}
	
	public void add (CMT_Transportation item)
	{
		if (this.Transportations == null)
		{
			this.Transportations = new List<CMT_Transportation>();
		}
		
		this.Transportations.add(item);
	}
}