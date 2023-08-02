public class CMT_Information extends CMT_JSONWrapper
{
    public String Description { get; set; }
    public List<CMT_Address> Addresses { get; set; }
	public CMT_Address YelpReference { get; set; }
    
    public CMT_Information()
    {
    }
    
    public CMT_Information (CMT_Information_gne__c info)
    {
        init (info, null);
    }
    
    public CMT_Information (CMT_Information_gne__c info, List<CMT_Attachment> attachments)
    {
        init (info, attachments);
    }
    
    private void init (CMT_Information_gne__c info, List<CMT_Attachment> attachments)
    {
        if (info != null)
        {
            Id = info.Id;
            Description = info.Description_gne__c;
            this.Addresses = new List<CMT_Address>();
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
            
            if (info.Addresses__r != null)
            {
            	for (CMT_Information_Address_gne__c a : info.Addresses__r)
            	{
            		this.Addresses.add(new CMT_Address(a));
            	}
            }
            
            if (info.Yelp_Address_gne__r != null)
            {
            	this.YelpReference = new CMT_Address(info.Yelp_Address_gne__r);
            }
        }
    }
}