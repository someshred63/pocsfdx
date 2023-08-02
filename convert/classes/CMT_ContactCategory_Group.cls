public class CMT_ContactCategory_Group extends CMT_Group
{
	public List<CMT_ContactCategory> ContactCategories { get; set; }
	
	public CMT_ContactCategory_Group (ID id, String name)
	{
		super(id, name);
		ContactCategories = new List<CMT_ContactCategory>();
	}
	
	public CMT_ContactCategory_Group (ID id, String name, List<CMT_Attachment> attachments)
	{
		super(id, name, attachments);
		ContactCategories = new List<CMT_ContactCategory>();
	}
	
	public void add (CMT_ContactCategory item)
	{
		if (this.ContactCategories == null)
		{
			this.ContactCategories = new List<CMT_ContactCategory>();
		}
		
		this.ContactCategories.add(item);
	}
}