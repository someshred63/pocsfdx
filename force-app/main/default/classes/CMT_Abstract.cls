public class CMT_Abstract extends CMT_JSONWrapper
{
    public String Item { get; set; }
    public String Title { get; set; }
    
    private void init (CMT_Abstract_gne__c ab, List<CMT_Attachment> attachments)
    {
    	if (ab != null)
        {
            Id = ab.Id;
            Item = ab.Item_gne__c;
            Title = ab.Title_gne__c;
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }
    }
    
    public CMT_Abstract (CMT_Abstract_gne__c ab)
    {
        init (ab, null);
    }
    
    public CMT_Abstract (CMT_Abstract_gne__c ab, List<CMT_Attachment> attachments)
    {
        init (ab, attachments);
    }
}