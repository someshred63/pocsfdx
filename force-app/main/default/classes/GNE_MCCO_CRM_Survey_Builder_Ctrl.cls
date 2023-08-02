public with sharing class GNE_MCCO_CRM_Survey_Builder_Ctrl {

	private final static Integer PAGE_SIZE = 50;
	
	public String iconBase64 { get; private set; }
	public String userTimeZone { get; private set; }

	public GNE_MCCO_CRM_Survey_Builder_Ctrl() {
		userTimeZone 	= String.valueOf(UserInfo.getTimeZone());
		iconBase64		= GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
	}
	
	@RemoteAction
	@ReadOnly
	public static SurveyWrapper loadSurveys(Integer page, String sortColumn, String sortDirection, String searchValue) {
		List<GNE_MCCO_CRM_Survey__c> items = Database.query(createQuery(page, sortColumn, sortDirection, searchValue));
		return new SurveyWrapper(items);
	}	

	private static String createQuery(Integer page, String sortColumn, String sortDirection, String searchValue) {
		Integer offset = (PAGE_SIZE * page) - PAGE_SIZE;
		
		String query = 'SELECT Id, Name, Title_gne__c, Status_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, Record_Type_gne__c, Requested_By_gne__r.Id, Requested_By_gne__r.Name, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate FROM GNE_MCCO_CRM_Survey__c';
	        
        if(String.isNotBlank(searchValue)){
            query += ' WHERE (Title_gne__c LIKE \'%'+searchValue+'%\')';
        }
	        
		query += ' ORDER BY ' + sortColumn + ' ' + sortDirection + setNullsBySortDirection(sortDirection);
		query += ' LIMIT ' + (PAGE_SIZE + 1) + ' OFFSET ' + offset;
		
		System.debug('# Query #');
		System.debug(query);
		
		return query;
	}
	             
    private static String setNullsBySortDirection(String sortDirection){
        return sortDirection == 'DESC' ? ' NULLS LAST ' : ' NULLS FIRST ';
    }
    
    private class SurveyWrapper {
    	
    	public Boolean hasNextPage { get; private set; }
    	public List<GNE_MCCO_CRM_Survey__c> items { get; private set; }

    	public SurveyWrapper(List<GNE_MCCO_CRM_Survey__c> items) {
    		this.hasNextPage 	= (items.size() > PAGE_SIZE) ? true : false;
    		this.items 			= items;
    	}
    	
    }
 
}