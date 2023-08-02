public virtual class CMT_Meeting_Properties
{
    public ID Id { get; set; }
    public String Name { get; set; }
    public String Title { get; set; }
    public String Type { get; set; }
    public Boolean IsActive { get; set; }
    public String HexColor { get; set; }
    public List<CMT_Attachment> Attachments { get; set; }
    public String Location { get; set; }
    public Date StartDate { get; set; }
    public Date EndDate { get; set; }
    public String TimeZone {get; set;}
    
    public CMT_Meeting_Properties (CMT_Meeting_gne__c m)
    {
        init(m);
    }
    
    protected void init (CMT_Meeting_gne__c m)
    {
        Id = m.Id;
        Name = m.Name;
        Title = m.Title_gne__c;
        IsActive = m.Is_Meeting_Active_gne__c;
        HexColor = m.Hexadecimal_Color_gne__c;
        Attachments = new List<CMT_Attachment>();
        Location = m.Location_gne__c;
        StartDate = m.Start_Date_gne__c;
        EndDate = m.End_Date_gne__c;
        Type = m.Meeting_Type_gne__c;
        String w ='(';
        TimeZone=(m.TimeZone__c!=null)? m.TimeZone__c.substring(m.TimeZone__c.indexOf(w)+1,m.TimeZone__c.length()-1):null;
        // init the logo property
        for (CMT_Attachment_gne__c att : m.Attachments__r)
        {
            if (att.MeetingAttachmentType_gne__c == 'Logo' || att.MeetingAttachmentType_gne__c == 'Background')
            {
                Attachments.add(new CMT_Attachment(att));
            }
        }
    }
}