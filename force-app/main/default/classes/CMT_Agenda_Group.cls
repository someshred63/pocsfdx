public class CMT_Agenda_Group extends CMT_Group
{
	public List<CMT_Franchise> Franchises { get; set; }
	
	public CMT_Agenda_Group (ID Id, String name)
	{
		super (id, name);
		Franchises = new List<CMT_Franchise>();
	}
	
	public CMT_Agenda_Group (ID Id, String name, List<CMT_Attachment> attachments)
	{
		super (id, name, attachments);
		Franchises = new List<CMT_Franchise>();
	}
}