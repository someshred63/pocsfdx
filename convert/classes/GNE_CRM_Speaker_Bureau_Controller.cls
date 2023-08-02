public class GNE_CRM_Speaker_Bureau_Controller{
	private String selectedViewName;
    public List<SelectOption> items {get;set;}
    public ApexPages.StandardSetController setCon {get;set;}
    
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    
    
    public GNE_CRM_Speaker_Bureau_Controller() {
        size = 20;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        getItems();
        getRecords();
        System.debug('setCon '+setCon);
  
    }
    
    public PageReference refreshPageSize() {
        System.debug('size '+size);
         setCon.setPageSize(size);
         return null;
    }

    private List<SFA2_View_Config_gne__c> fetchViewConfig() {
        return GNE_MCCO_CRM_Util.getViews('Speaker Bureaus','TLCRM',null,'GNE-TLS');
    }
    
    private void getItems() {
        items = new List<SelectOption>();
        for(SFA2_View_Config_gne__c vc:fetchViewConfig()){
            String[]strTable = vc.View_Name_gne__c.split(' ');
            if(vc.View_Name_gne__c.startsWith('20') && strTable.size() == 2 )
            items.add(new SelectOption(strTable[0],vc.View_Name_gne__c));
		}
        selectedViewName = items.isEmpty() ? '' : items.get(items.size()-1).getValue();
        System.debug(' ++ selectedViewName '+selectedViewName);

    }
    
    public void refreshView() {
        String query = 'SELECT Name, Aprimo_Bureau_ID_gne__c, Approved_Speakers_gne__c, Nominated_Speakers_gne__c, Vendor_ID_gne__c '+
            'FROM Speaker_Bureau_gne__c';
        String whereClause = (selectedViewName == null || selectedViewName == 'All') ? ''  : ' WHERE Speaker_Bureau_Year_gne__c = :selectedViewName'; 
        query +=whereClause;
        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
    }
    
    public List<Speaker_Bureau_gne__c> getRecords() {
        String query = 'SELECT Name, Aprimo_Bureau_ID_gne__c, Approved_Speakers_gne__c, Nominated_Speakers_gne__c, Vendor_ID_gne__c '+
            'FROM Speaker_Bureau_gne__c';
        String whereClause = (selectedViewName == null || selectedViewName == 'All') ? ''  : ' WHERE Speaker_Bureau_Year_gne__c = :selectedViewName'; 
        query +=whereClause;

        if(setCon == null){
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        }
        
        return (List<Speaker_Bureau_gne__c> )setCon.getRecords();
    }
    
    public String getselectedViewName() {
        return selectedViewName;
    }
    
    public void setselectedViewName(String selectedViewName) {
        this.selectedViewName = selectedViewName;
    }

    private virtual List<SFA2_View_Config_gne__c> getViews(String nameOfThePage){
		return GNE_MCCO_CRM_Util.getViews(nameOfThePage);
	}
}