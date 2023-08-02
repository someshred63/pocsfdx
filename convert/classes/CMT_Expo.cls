public class CMT_Expo extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public String Description { get; set; }
    public String Location { get; set; }
    
    public CMT_Expo()
    {
        // empty
    }
    
    private void init (CMT_Expo_gne__c expo, List<CMT_Attachment> attachments)
    {
    	if (expo != null)
    	{
    		Id = expo.Id;
        	Name = expo.Name;
        	Description = expo.Description_gne__c;
        	Location = expo.Location_gne__c;
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
    	}
    }
    
    public CMT_Expo (CMT_Expo_gne__c expo)
    {	
        init (expo, null);
    }
    
    public CMT_Expo (CMT_Expo_gne__c expo, List<CMT_Attachment> attachments)
    {	
        init (expo, attachments);
    }
}