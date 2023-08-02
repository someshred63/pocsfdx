public class CMT_Attachment
{
    public ID Id { get; set; }
    public String DownloadURL { get; set; }
    public String FileName { get; set; }
    public String Type { get; set; }
    public String URL { get; set; }
    public String Description { get; set; }
    public String MeetingAttachmentType { get; set; }
    
    public CMT_Attachment()
    {
    }
    
    public CMT_Attachment (CMT_Attachment_gne__c attachment)
    {
        if (attachment != null)
        {
            Id = attachment.Id;
            DownloadURL = attachment.downloadURL_gne__c;
            FileName = attachment.File_Name_gne__c;
            Type = attachment.Type_gne__c;
            URL = attachment.URL_gne__c;
            Description = attachment.Description_gne__c;
            MeetingAttachmentType = attachment.MeetingAttachmentType_gne__c;
        }
    }
}