public with sharing class GNE_SFA2_PFG_Report_Ext_Ctrl {
    
    public SFA2_PFG_Report_gne__c reportRecord {get; private set;}
    public Boolean reportNotExist {get { return reportRecord==null; }}
    public Boolean canShare {get { return false/*!reportNotExist && reportRecord.OwnerId == UserInfo.getUserId()*/; }}
    
    public GNE_SFA2_PFG_Report_Ext_Ctrl(ApexPages.StandardController ctrl) {
        
    }
    
    public PageReference init() {
        String reportExtId = ApexPages.currentPage().getParameters().get('extId');
        String reportId = ApexPages.currentPage().getParameters().get('id');
        
        for(SFA2_PFG_Report_gne__c rec : [SELECT Id, OwnerId, Name, Report_Id_gne__c 
                FROM SFA2_PFG_Report_gne__c 
                WHERE Id = :reportId OR Report_Id_gne__c = :reportExtId 
                ORDER BY Part_No_gne__c
                LIMIT 1]) {
            reportRecord = rec;         
        }
        
        if(reportRecord==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Report with given Id doesn\'t exist or it\'s under construction right now.<br/>Refresh this page at a later time.'));
        }
        
        return null;
    }
    
    @ReadOnly @RemoteAction
    public static List<List<Object>> getCsvReport(String reportId) {
        List<List<Object>> result = null;
        List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = GNE_SFA2_PFG_Report_Engine.deserializeReport(reportId);
        
        if(reportRows!=null && !reportRows.isEmpty()) {
            result = GNE_SFA2_PFG_Report_Engine.createCsv(reportRows);
        }
        
        return result;
    }
    
    @ReadOnly @RemoteAction
    public static List<List<Object>> getGoogleWorkbookSheet(String reportId) {
        List<List<Object>> result = null;
        List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = GNE_SFA2_PFG_Report_Engine.deserializeReport(reportId);
        
        if(reportRows!=null && !reportRows.isEmpty()) {
            result = GNE_SFA2_PFG_Report_Engine.createGoogleWorkbookSheet(reportRows);
        }
        
        return result;
    }
    
    public PageReference share() {
        return null;
    }
}