/***********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of AccountTactics for the specified accountIds.               
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountTactics/*')
global with sharing class iPhone_Get_Account_Tactics_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds) {    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountTacticsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, unixId, accountIds
    		)		
    	);     
    } 
     
    class GetAccountTacticsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {    	
    		return iPhone_DAO.getAccountTacticsByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountTacticsRecord((Account_Tactic_vod__c)sObj);    			    		
    	}    	         	 	 
    }
    
    class GetAccountTacticsRecord extends iPhone_Commons_gne.DeltaRecord {    
        public String name;
        public String accountPlan;	
	    	    
	    public GetAccountTacticsRecord(Account_Tactic_vod__c accountTactic) {
			this.id = iPhone_StringUtil.getString(accountTactic.Id);
            this.name = iPhone_StringUtil.getString(accountTactic.Name);
			this.accountPlan = iPhone_StringUtil.getString(accountTactic.Account_Plan_vod__c);								
	    }
    }    
}