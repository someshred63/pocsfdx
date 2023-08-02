/***********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of AccountPlans for the specified accounts.               
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountPlans/*')
global with sharing class iPhone_Get_Account_Plans_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds) {    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountPlansResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, unixId, accountIds
    		)
    	);     
    } 
     
    class GetAccountPlansResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getAccountPlansByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountPlansRecord((Account_Plan_vod__c)sObj);    			    		
    	}    	         	 	 
    }
    
    class GetAccountPlansRecord extends iPhone_Commons_gne.DeltaRecord {    
        public String name;
        public String account;
        public String segment;
        public String team;
        public String isActive;	
	    	    
	    public GetAccountPlansRecord(Account_Plan_vod__c accountPlan) {
			this.id = iPhone_StringUtil.getString(accountPlan.Id);
			this.name = iPhone_StringUtil.getString(accountPlan.Name);			
			this.account = iPhone_StringUtil.getString(accountPlan.Account_vod__c);			
			this.segment = iPhone_StringUtil.getString(accountPlan.Segment_gne__c);			
			this.team = iPhone_StringUtil.getString(accountPlan.Team_gne__c);			
			this.isActive = iPhone_StringUtil.getString(accountPlan.Active_vod__c);			
	    }
    }    
}