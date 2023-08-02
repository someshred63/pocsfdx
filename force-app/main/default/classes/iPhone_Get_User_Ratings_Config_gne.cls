/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-07-03
*  Project: OTR2
*  Description: REST Webservice, basing on the data from GNE_SFA2_Ratings_Configuration__c 
*  object, returns columns list assigned to record type name for the specified user.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserRatingsConfig/*')
global with sharing class iPhone_Get_User_Ratings_Config_gne {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId) {
    	return iPhone_Commons_gne.buildResponse(
    				new GetUserRatingsConfigResponseBuilder(), 
    				unixId
    	);
    }
		
	class GetUserRatingsConfigResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
    	
    	public iPhone_Commons_gne.RestResponse build(Object args) {
    		String unixId = (String)args;
    		User user = iPhone_DAO.getUserByExternalId(unixId);
			if(user == null)
				throw new iPhone_Commons_gne.IPhoneException('User not found: ' + unixId);  
			
			List<RecordTypeColumns> rtcList = getRecordTypeColumns(user);						
    		return new GetUserRatingsConfigResponse(rtcList);
    	} 
    	
    	private List<RecordTypeColumns> getRecordTypeColumns(User user) {    		
    		List<RecordTypeColumns> recordTypeColumnsList = new List<RecordTypeColumns>();     		
    		GNE_SFA2_User_App_Context_gne__c appCtx = new iPhone_Commons_gne.UserAppContextUtil().getAppCtx(user.Id);    		    	
    		List<GNE_SFA2_Ratings_Configuration__c> ratingsCfgs = iPhone_DAO.getRatingsConfiguration(appCtx.Role_gne__c, appCtx.Brand_gne__c, appCtx.App_Name_gne__c);    		    		    		    		
    		if(ratingsCfgs == null) {
    			throw new iPhone_Commons_gne.IPhoneException('No ratings configuration found for user: ' + user.id);
    		}        		
    		for(GNE_SFA2_Ratings_Configuration__c ratingsCfg: ratingsCfgs) {
    			system.debug('RatingsConfiguration: ' + ratingsCfg);    		    			    			    			    		
    			RecordTypeColumns rtColumns = new RecordTypeColumns(ratingsCfg.Record_Type_gne__c, ratingsCfg.Columns_List_gne__c.split(',', 0));     			
    			recordTypeColumnsList.add(rtColumns);  
    		}
    		return recordTypeColumnsList;
    	}    	
    } 
        
    public class GetUserRatingsConfigResponse extends iPhone_Commons_gne.RestResponse {    
    	public List<RecordTypeColumns> records;
    	
    	public GetUserRatingsConfigResponse(List<RecordTypeColumns> records) {
    		this.records = records;
    	}
    }
		
	public class RecordTypeColumns {
		public String recordTypeName;
		public List<String> columns;
				
		public RecordTypeColumns(String recordTypeName, List<String> columns) {
			this.recordTypeName = iPhone_StringUtil.getString(recordTypeName);
			this.columns = columns;
		}		
	}	
}