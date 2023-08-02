public with sharing class CFAR_MyTrialsXLSController extends CFAR_MyTrialsController {
    
    final Integer pageSize = 10000;
    transient List<CFAR_SObjectWrapper> objectListTrial;
    public ApexPages.StandardSetController stdSetControllerTrial;
    public PageReference myTrialsRef {get;private set;}
    
    public CFAR_MyTrialsXLSController() {
        myTrialsRef = ApexPages.currentPage();
    }
    
    public List<CFAR_SObjectWrapper> getobjectListTrialXLS() {
        refreshParams();
        fillTrials();       
        return objectListTrial;
    }
    
    
    private void fillTrials() {
        if (!String.isBlank(sortDirection) && !String.isBlank(sortExpression)) {
            //sort order in XLS is always reverted for unknown reason - so it needs to be reverted here once more
            if (sortDirection == 'asc') {
                sortDirection = 'desc';
            }
            else if (sortDirection == 'desc') {
                sortDirection = 'asc';
            }
            searchParam.sortDirection = sortDirection;
            searchParam.sortExpression = sortExpression;
        }
        stdSetControllerTrial = new ApexPages.StandardSetController(CFAR_DAO.getTrialsLessFields(searchParam));
        stdSetControllerTrial.setPageSize(pageSize);
        objectListTrial = new List<CFAR_SObjectWrapper>();
        for(SObject s : stdSetControllerTrial.getRecords() ) {
            CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(s, s.Id == currentObjectRefId);
            objectListTrial.add(obj);
        }
    }
    
    public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + 'Search Result' + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }
    
    public String getFileName() {
        String fileName = 'Search Result - ' + String.valueOf(DateTime.now());
        return fileName ;
    }  

    public override void addToXlsMap(String key, String value){}
    
}