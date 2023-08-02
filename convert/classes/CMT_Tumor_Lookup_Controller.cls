public without sharing class CMT_Tumor_Lookup_Controller {
	
	public string lookupID {get; set;}
	public string franchiseID {get; set;}
	public integer recordcount {get; set;}  
	public List<CMT_Intermediate_Level_gne__c> tumors {get; set;}
	public integer flg {get; set;}
	public string searchName {get; set;}
	public String parentTumorId {get; set;}
    public String childTumorId {get; set;}
    public List<SelectOption> tumorsChildren  {get; set;}
    
	public CMT_Tumor_Lookup_Controller()
	{
		lookupID = System.currentPageReference().getParameters().get('lknm');
		franchiseID = System.currentPageReference().getParameters().get('frId');  
		DoSearch();
	}

	public PageReference cont()
	{
		DoSearch();
		return null;
	}
	
	private void DoSearch() 
	{  
		recordcount=0;
		flg=0;
		tumors = [select Name,Id from CMT_Intermediate_Level_gne__c where CMT_Franchise_gne__c=:franchiseID];
		recordcount = tumors.size();
	}      
	
	    
    public List<SelectOption> getTumorsParents() {
       List<SelectOption> options = new List<SelectOption>();
       options.add(new SelectOption('', '-None-'));	
       for(CMT_Intermediate_Level_gne__c tumor:[select id,Name from CMT_Intermediate_Level_gne__c where Parent_Id_gne__c=null and CMT_Franchise_gne__c=:franchiseID])
       {
       		options.add(new SelectOption(tumor.id, tumor.Name));		
       }
       return options;
    }
    
    public PageReference populateTumorsChildren() {
       tumorsChildren = new List<SelectOption>();
       if(parentTumorId != null)
       {
	       for(CMT_Intermediate_Level_gne__c tumor:[select id,Name from CMT_Intermediate_Level_gne__c where Parent_Id_gne__c=:parentTumorId])
	       {
	       		tumorsChildren.add(new SelectOption(tumor.id, tumor.Name));		
	       }
       }
       return null;
    }
}