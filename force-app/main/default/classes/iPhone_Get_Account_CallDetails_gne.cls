/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2Details for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallDetails/*')
global with sharing class iPhone_Get_Account_CallDetails_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallDetailsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	    	 
    } 
              
    class GetAccountCallDetailsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallDetailsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallDetailsByAccountIds(args.accountIds);      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallDetailsRecord((Call2_Detail_vod__c)sObj);    		    		
    	}     	
    } 
    
    class GetAccountCallDetailsRecord extends iPhone_Commons_gne.DeltaRecord {	
        public String iid; // Call2_Detail_vod__c.Call2_vod__c
        public String pd;  // Call2_Detail_vod__c.Product_vod__c
        public String dp;  // Call2_Detail_vod__c.Detail_Priority_vod__c         
                
        public GetAccountCallDetailsRecord(Call2_Detail_vod__c callDetail) {
        	this.id	 = callDetail.Id;
        	this.iid = callDetail.Call2_vod__c;
        	this.pd	 = iPhone_StringUtil.getString(callDetail.Product_vod__c);
        	this.dp	 = iPhone_StringUtil.getString(callDetail.Detail_Priority_vod__c);        	      
        }
	}
}