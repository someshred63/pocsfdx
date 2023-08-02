public class CMT_MeetGreen extends CMT_JSONWrapper
{
    public String Name { get; set; }
    
    public CMT_MeetGreen()
    {
    }
    
    private void init (CMT_Meet_Green_gne__c mg, List<CMT_Attachment> attachments)
    {
        if (mg != null)
        {
            Id = mg.Id;
            Name = mg.Name_gne__c;
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }
    }
    
    public CMT_MeetGreen(CMT_Meet_Green_gne__c mg)
    {
        init (mg, null);
    }
    
    public CMT_MeetGreen(CMT_Meet_Green_gne__c mg, List<CMT_Attachment> attachments)
    {
        init (mg, attachments);
    }
}