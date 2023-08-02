public with sharing class CMT_Intermediate_Level extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public Id ParentId { get; set; }
    
    public CMT_Intermediate_Level()
    {
    }
    
    private void init (CMT_Intermediate_Level_gne__c intermediate_level)
    {
    	if (intermediate_level != null)
    	{
    		Id = intermediate_level.Id;
	        Name = intermediate_level.Name;
	        ParentId = intermediate_level.Parent_Id_gne__c;
    	}
    }
    
    public CMT_Intermediate_Level (CMT_Intermediate_Level_gne__c intermediate_level)
    {
        init (intermediate_level);
    }
}