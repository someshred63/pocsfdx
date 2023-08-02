public class CMT_Contact extends CMT_JSONWrapper
{
    public String Title { get; set; }
    public String Phone { get; set; }
    public String Email { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Text { get; set; }
    
    // these properties are not returned because they are not used by the iPhone app
    // public String FullName { get; set; }
    // public String Description { get; set; }
    
    public CMT_Contact()
    {
        // empty
    }
    
    private void init (CMT_Contact_gne__c c, List<CMT_Attachment> attachments)
    {
    	if (c != null)
        {
            Id = c.Id;
            Title = c.Title_gne__c;
            Phone = c.Phone_gne__c;
            Email = c.Email_gne__c;
            FirstName = c.First_Name_gne__c;
            LastName = c.Last_Name_gne__c;
            Text = c.Text_Number_gne__c;
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }
    }
    
    public CMT_Contact (CMT_Contact_gne__c c, List<CMT_Attachment> attachments)
    {
        init(c, attachments);
    }
    
    public CMT_Contact (CMT_Contact_gne__c c)
    {
        init(c, null);
    }
}