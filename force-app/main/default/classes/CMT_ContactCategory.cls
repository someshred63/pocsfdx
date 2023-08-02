public class CMT_ContactCategory extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public List<CMT_Contact> Contacts { get; set; }
    
    public CMT_ContactCategory()
    {
        // empty
    }
    
    private void init (CMT_Contact_Category_gne__c cc, List<CMT_Attachment> attachments)
    {
    	if (cc != null)
        {
            Id = cc.Id;
            Name = cc.Name;
            Contacts = new List<CMT_Contact>();
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }
    }
    
    public CMT_ContactCategory (CMT_Contact_Category_gne__c cc)
    {
		init(cc, null);   
    }
    
    public CMT_ContactCategory (CMT_Contact_Category_gne__c cc, List<CMT_Attachment> attachments)
    {
		init(cc, attachments);   
    }
    
    public void addContact (CMT_Contact c)
    {
        if (Contacts == null)
        {
            Contacts = new List<CMT_Contact>();
        }
        
        Contacts.add(c);
    }
}