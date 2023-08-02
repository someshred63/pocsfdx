public class CMT_AbstractCategory_Group extends CMT_Group
{
	public List<CMT_AbstractCategory> AbstractCategories { get; set; }
	
	public CMT_AbstractCategory_Group (ID id, String name)
	{
		super(id, name);
		AbstractCategories = new List<CMT_AbstractCategory>();
	}
	
	public CMT_AbstractCategory_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		AbstractCategories = new List<CMT_AbstractCategory>();
	}
	
	public void add (CMT_AbstractCategory item)
	{
		if (this.AbstractCategories == null)
		{
			this.AbstractCategories = new List<CMT_AbstractCategory>();
		}
		
		this.AbstractCategories.add(item);
	}
}