/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2Samples for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallSamples/*')
global with sharing class iPhone_Get_Account_CallSamples_gne {
	
	@HttpPost 
     global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallSamplesResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)    		
    	);     	  
    } 
              
    class GetAccountCallSamplesResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		List<Call2_Sample_vod__c> resultList = new List<Call2_Sample_vod__c>();
    		List<Call2_Sample_vod__c> samples = args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallSamplesByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallSamplesByAccountIds(args.accountIds);    		
    		resultList.addAll(samples);
    		List<Call2_vod__c> parentCallIds = args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallsIdsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallsIdsByAccountIds(args.accountIds);
    		
    		if(!parentCallIds.isEmpty()) {
    		  List<Call2_Sample_vod__c> childSamples = iPhone_DAO.getCallSamplesByParentCallIds(parentCallIds);
    		  resultList.addAll(childSamples);
    		}
    		
    		return resultList;    	  
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallSamplesRecord((Call2_Sample_vod__c)sObj);  		    		
    	}    	    		
    } 
    
    class GetAccountCallSamplesRecord extends iPhone_Commons_gne.DeltaRecord {    		
    	public String at;  // Call2_Sample_vod__c.Account_vod__c
		public String iid; // Call2_Sample_vod__c.Call2_vod__c or Call2_vod__c.Parent_Call_vod__c
		public String lt;  // Call2_Sample_vod__c.Lot_vod__c
		public String pd;  // Call2_Sample_vod__c.Product_vod__c
		public String qu;  // Call2_Sample_vod__c.Quantity_vod__c            
        
        public GetAccountCallSamplesRecord(Call2_Sample_vod__c callSample) {
        	this.id	 = callSample.Id;
        	this.iid = callSample.Call2_vod__r.Parent_Call_vod__c != null ? callSample.Call2_vod__r.Parent_Call_vod__c : callSample.Call2_vod__c;        	 
        	this.at	 = callSample.Account_vod__c != null ? iPhone_StringUtil.getString(callSample.Account_vod__c) : iPhone_StringUtil.getString(callSample.Contact_vod__c);
			this.pd	 = iPhone_StringUtil.getString(callSample.Product_vod__c);
			this.qu	 = iPhone_StringUtil.getString(callSample.Quantity_vod__c);
			this.lt	 = iPhone_StringUtil.getString(callSample.Lot_vod__c);					
        }
    }
}