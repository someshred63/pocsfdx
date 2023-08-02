/*********************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2015-09-14
*  Project: Canada Pre-Call-Planning
*  Description: REST Webservice, returns a list of Call_Pre_Call_gne__c for the specified accounts.             
**********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallPreCalls/*')
global with sharing class iPhone_Get_Account_CallPreCalls_gne {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallPreCallsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	  
    } 
              
    class GetAccountCallPreCallsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallPreCallsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallPreCallsByAccountIds(args.accountIds);      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallPreCallsRecord((Call_Pre_Call_gne__c)sObj);     		    		
    	}     	
    } 
    
    class GetAccountCallPreCallsRecord extends iPhone_Commons_gne.DeltaRecord {   
		public String cs;  // Call_Pre_Call_gne__c.Customer_Segment_gne__c
		public String dc;  // Call_Pre_Call_gne__c.Decision_Cycle_gne__c
		public String iq;  // Call_Pre_Call_gne__c.Implication_Questions_gne__c
		public String nq;  // Call_Pre_Call_gne__c.Need_payoff_Questions_gne__c
		public String pq;  // Call_Pre_Call_gne__c.Problem_Questions_gne__c
		public String io;  // Call_Pre_Call_gne__c.Interaction_Objectives_gne__c
		public String pr;  // Call_Pre_Call_gne__c.Product_gne__c
		public String iid; // Call_Pre_Call_gne__c.Call2_vod__c
		public String ld; // Call_Pre_Call_gne__c.LastModifiedDate           
        
        public GetAccountCallPreCallsRecord(Call_Pre_Call_gne__c preCall) {
        	this.id	 = preCall.Id;
			this.cs	 = iPhone_StringUtil.getString(preCall.Customer_Segment_gne__c);
			this.dc	 = iPhone_StringUtil.getString(preCall.Decision_Cycle_gne__c);
			this.iq  = iPhone_StringUtil.getString(preCall.Implication_Questions_gne__c);
			this.nq  = iPhone_StringUtil.getString(preCall.Need_payoff_Questions_gne__c);
			this.pq  = iPhone_StringUtil.getString(preCall.Problem_Questions_gne__c);
			this.io	 = iPhone_StringUtil.getString(preCall.Interaction_Objectives_gne__c);
			this.pr = iPhone_StringUtil.getString(preCall.Product_gne__c);		
			this.iid = iPhone_StringUtil.getString(preCall.Call_gne__c);
			this.ld = iPhone_StringUtil.getString(preCall.LastModifiedDate);
        }
    }
}