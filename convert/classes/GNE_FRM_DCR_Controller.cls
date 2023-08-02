/************************************************************
*  @author: Lukasz Kozminski, Roche
*  Date: 2016-12-12
*  Description: This is a controller class for GNE_FRM_DCR_Portal page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_FRM_DCR_Controller {
    private static final Integer DEFAULT_QUERY_LIMIT = 999;
    private Integer QUERY_LIMIT;

	public List<SelectOption> viewSelectOptions {get; set;}
	private List<SFA2_View_Config_gne__c> views;
	public String viewId {get; set;}
	public transient List<RecordWrapper> recordWrappers {get; private set;}

    public String iconBase64 { get; private set; }
    
    public GNE_FRM_DCR_Controller() {
        iconBase64	= '/img/icon/custom51_100/pencil32.png';
        views =  GNE_SFA2_List_View_Util.getViews('Change_Request_gne__c', 'GNE_FRM_DCR_Portal', 'DatastewardshipTool', null, 'FRM-Data-Steward');
        viewSelectOptions = GNE_SFA2_List_View_Util.prepareSelectOptions(views);
        SFA2_View_Config_gne__c view = GNE_SFA2_List_View_Util.getLastSeenOrFirstAvailableView(views,GNE_SFA2_List_View_Util.getUserPreferences('GNE_FRM_DCR_Portal'));
        setRecordLimit();
        if(view != null){
        	viewId = view.Id;
        	recordWrappers = queryRecords(view);
        } 
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
    
    private SFA2_View_Config_gne__c getView(String viewId){
		for(SFA2_View_Config_gne__c view: views){
			if(view.Id == viewId){
				return view;
			}
		}
		return null;
	}
	
	public PageReference loadRecords(){
		if(String.isNotEmpty(viewId)) {
			GNE_SFA2_List_View_Util.updateViewPreference(viewId, 'GNE_FRM_DCR_Portal');
			recordWrappers = queryRecords(getView(viewId));
		}
		return null;
	}
	
	public List<RecordWrapper> queryRecords(SFA2_View_Config_gne__c view){
		String status = viewId;
		String accountRelName = Change_Request_gne__c.Account_gne__c.getDescribe().getRelationshipName();
		String addressRelName = Change_Request_gne__c.Current_Address_gne__c.getDescribe().getRelationshipName();
		
		String selectString = String.format('SELECT Id, Name, CreatedDate, CreatedBy.Name, CreatedById, RecordType.Name, LastModifiedById, LastModifiedDate, {0}, {1}, {2}, {3}, {4}, {5} FROM Change_Request_gne__c ',
			new String[]{
				String.valueOf(Change_Request_gne__c.Account_gne__c),	
				String.valueOf(Change_Request_gne__c.Status_gne__c),	
				String.valueOf(Change_Request_gne__c.Approval_State__c),
				String.valueOf(Change_Request_gne__c.Assigned_Analyst_gne__c),
				accountRelName + '.Name',
				addressRelName + '.Name'
			}
		);
		
		String whereString = ' ';
		
		if(view.View_Name_gne__c.contains('Closed')){
			whereString += ' WHERE CreatedDate = LAST_N_DAYS:90 AND ' + String.format('{0} = \'\'Closed\'\' ',
													new String[]{
														String.valueOf(Change_Request_gne__c.Status_CS_gne__c)	// 0
													}
												);
			
		} else if(view.View_Name_gne__c.contains('Open')){
			whereString += ' WHERE ' + String.format('{0} != \'\'Closed\'\' ',
												new String[]{
													String.valueOf(Change_Request_gne__c.Status_CS_gne__c)	// 0
													}
												);
		} else if (view.View_Name_gne__c.contains('My')){
			whereString += ' WHERE CreatedDate = LAST_N_DAYS:90 AND ' + String.format('{0} = \'\'{1}\'\' ',
												new String[]{
													String.valueOf(Change_Request_gne__c.Assigned_Analyst_gne__c),	// 0
													UserInfo.getUserId()	// 0
													}
												);
			
		}
		
		
		whereString += ' AND Account_gne__r.RecordTypeId = \'' + GNE_SFA2_Util.getFrmHcoAccountRecordTypeId() + '\' ';
		
		String orderString = 'ORDER BY CreatedDate DESC LIMIT ' + QUERY_LIMIT;
		
		String queryString = String.format('{0} {1} {2}', new String[]{selectString, whereString, orderString});
		
		List<RecordWrapper> result = new List<RecordWrapper>();		
		try {
			for(Change_Request_gne__c cr: Database.query(queryString)){
				result.add(new RecordWrapper(cr, GNE_SFA2_DCR_Util.isOpen(cr)));
			}
		} catch (Exception ex){
			result = new List<RecordWrapper>();			 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		return result;
	}
	
	public String getReportId() {
        String result;
        Report [] reports = [SELECT Id FROM Report WHERE DeveloperName = 'ALL_DCR_HCO' LIMIT 1];
        return result = reports.isEmpty() ? '' : reports[0].Id;
    }

	class RecordWrapper {
		public Change_Request_gne__c dcr {get; set;}
		public Boolean isOpen {get; set;}
		
		public RecordWrapper(Change_Request_gne__c record, Boolean isOpen) {
			this.dcr = record;
			this.isOpen = isOpen;
		}
	}
}