public class CMT_AbstractCategory extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public List<CMT_Abstract> Abstracts { get; set; }
    
    public CMT_AbstractCategory (CMT_Abstract_Category_gne__c aCategory)
    {
        init (aCategory, null);
    }
    
    public CMT_AbstractCategory (CMT_Abstract_Category_gne__c aCategory, List<CMT_Attachment> attachments)
    {
        init (aCategory, attachments);
    }
    
    private void init (CMT_Abstract_Category_gne__c aCategory, List<CMT_Attachment> attachments)
    {
    	if (aCategory != null)
        {
            Id = aCategory.Id;
            Name = aCategory.Category_Name_gne__c;
            Abstracts = new List<CMT_Abstract>();
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }
    }
    
    public void addAbstract (CMT_Abstract c)
    {
        if (Abstracts == null)
        {
            Abstracts = new List<CMT_Abstract>();
        }
        
        Abstracts.add(c);
    }
}