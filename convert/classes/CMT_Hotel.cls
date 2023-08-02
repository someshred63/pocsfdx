public class CMT_Hotel extends CMT_JSONWrapper
{
    public String Description { get; set; }
    public String Name { get; set; }
    public String Website { get; set; }
    public CMT_Address Address { get; set; }
    
    public CMT_Hotel()
    {
    }
    
    private void init (CMT_Hotel_gne__c hotel, List<CMT_Attachment> attachments)
    {
    	if (hotel != null)
        {
            Id = hotel.Id;
            Description = hotel.Description_gne__c;
            Name = hotel.Name_gne__c;
            Website = hotel.Website_gne__c;
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
            
            if (hotel.Address_gne__r != null)
            {    
                Address = new CMT_Address (hotel.Address_gne__r);
            }
        }
    }
    
    public CMT_Hotel (CMT_Hotel_gne__c hotel)
    {   
        init (hotel, null);
    }
    
    public CMT_Hotel (CMT_Hotel_gne__c hotel, List<CMT_Attachment> attachments)
    {   
        init (hotel, attachments);
    }
}