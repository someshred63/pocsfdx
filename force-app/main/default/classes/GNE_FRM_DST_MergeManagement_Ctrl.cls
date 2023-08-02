/************************************************************
*  @author: Jaroslaw Laniecki, Billennium
*  Date: 2016-11-16
*  Description: This is a controller for GNE_FRM_DST_MergeManagement page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_FRM_DST_MergeManagement_Ctrl {
    private static final Integer DEFAULT_QUERY_LIMIT = 999;
    private Integer QUERY_LIMIT;
    public String viewId {get; set;}
    public transient Map<Id,DST_Match_Loser__c> records {get; private set;}
    public List<SelectOption> viewSelectOptions {get; set;}
    private String viewParam;
    private static final String QUERY_SELECT = 
        'SELECT Id, Name, CreatedDate, LastModifiedById, MDM_bundle_status__c, Merge_Candidate_ID_gne__c, '+
        '    Match_Loser_Name__c, Merge_Candidate_Address_gne__c, Selected_Winner_Account_gne__c,  '+
        '    Request_Analyst_gne__c, CreatedBy.Name, LastModifiedBy.Name, CreatedById, LastModifiedDate '+
        'FROM DST_Match_Loser__c ';
    private static final String CLOSED_STATUSES_STR  = '(\''+DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_CLOSEDMERGED+'\', \''+DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_CLOSEDREJECTED+'\') ';
    private static final String QUERY_WHERE_CLOSE    = 'WHERE CreatedDate = LAST_N_DAYS:90 AND Mdm_Bundle_Status__c IN ' + CLOSED_STATUSES_STR;
    private static final String QUERY_WHERE_OPEN     = 'WHERE Mdm_Bundle_Status__c NOT IN ' + CLOSED_STATUSES_STR; 
    private static final String QUERY_WHERE_MYBUNDLE = 'WHERE CreatedDate = LAST_N_DAYS:90 AND Request_Analyst_gne__c = \''+ UserInfo.getUserId() + '\'';
        
    public GNE_FRM_DST_MergeManagement_Ctrl(){
        viewParam = System.currentPageReference().getParameters().get('viewParam');       
        viewSelectOptions = new List<SelectOption>{
            new SelectOption('open', 'Open Merge Bundles'), 
            new SelectOption('closed', 'Closed Bundles'),
            new SelectOption('myBundles', 'My Bundles')
        };
        viewId = String.isNotBlank(viewParam) ? viewParam : 'open';
        setRecordLimit();
        records = queryRecords(); 
    }
    
    public PageReference loadRecords(){
        records = queryRecords();
        return null;
    }
    
    public Map<Id,DST_Match_Loser__c> queryRecords() {
        Map<Id,DST_Match_Loser__c> result; 
        String status = viewId;        
        String whereString = ' ';
        
        if(status == 'closed'){
            whereString += QUERY_WHERE_CLOSE;
        } else if (status == 'open'){
            whereString += QUERY_WHERE_OPEN;
        } else if(status == 'myBundles'){
            whereString += QUERY_WHERE_MYBUNDLE;
        }

        String orderString = 'ORDER BY CreatedDate DESC LIMIT ' + QUERY_LIMIT;        
        String queryString = String.format('{0} {1} {2}', new String[]{QUERY_SELECT, whereString, orderString});
   
        try {
            result = new Map<Id,DST_Match_Loser__c>((DST_Match_Loser__c[])Database.query(queryString));
        } catch (Exception ex){
            result = new Map<Id,DST_Match_Loser__c>();             
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return result;
    }
    
    public String getReportId() {
        String result;
        Report [] reports = [SELECT Id FROM Report WHERE DeveloperName = 'All_Merge_Bundles' LIMIT 1];
        return result = reports.isEmpty() ? '' : reports[0].Id;
    }
    
    private void setRecordLimit() {
        QUERY_LIMIT = DEFAULT_QUERY_LIMIT;
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('DST_QUERY_LIMIT') != null){
            try {
            	QUERY_LIMIT = Integer.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues('DST_QUERY_LIMIT').Configuration_Value_gne__c);
            } catch (Exception ex) {
                System.debug(' EXCEPTION during set QUERY_LIMIT :: ' + ex.getCause());
            }
        }
    }
}