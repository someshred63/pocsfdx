/******************************************************************************************
*  @author: Tomasz Kosecki, Roche (contractor)
*  @email: tomasz.kosecki@contractors.roche.com   
*  Created: 2017-09-21
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2_Interaction_Detail_vod__c for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallInteractionDetails/*')
global with sharing class iPhone_Get_Account_CallIntDetails_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallDetailsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	    	 
    } 
              
    class GetAccountCallDetailsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallInteractionDetailsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallInteractionDetailsByAccountIds(args.accountIds);      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallDetailsRecord((Call2_Interaction_Detail_vod__c)sObj);    		    		
    	}     	
    } 
    
    class GetAccountCallDetailsRecord extends iPhone_Commons_gne.DeltaRecord {	
        public String iid; // Call2_Interaction_Detail_vod__c.Call2_vod__c
        public String vr; // Call2_Interaction_Detail_vod__c.Visit_Reason_vod__c
        public String cnm; // Call2_Interaction_Detail_vod__c.Name_vod__c
        public String cty; // Call2_Interaction_Detail_vod__c.Type_vod__c
        public String vrt; // Call2_Interaction_Detail_vod__c.Tactic_vod__c              
        
        public String st; // Call2_Interaction_Detail_vod__c.Strategy_RAMA_vod__c              
        public String tc; // Call2_Interaction_Detail_vod__c.Tactic_RAMA_vod__c              
        public String tl; // Call2_Interaction_Detail_vod__c.Tools_RAMA_vod__c              
                
        public GetAccountCallDetailsRecord(Call2_Interaction_Detail_vod__c callDetail) {
        	this.id  = callDetail.Id;
            this.iid = callDetail.Call2_vod__c;
            this.vr = iPhone_StringUtil.getString(callDetail.Visit_Reason_vod__c);
            this.cnm = iPhone_StringUtil.getString(callDetail.Name_vod__c);
            this.cty = iPhone_StringUtil.getString(callDetail.Type_vod__c);
            this.vrt = iPhone_StringUtil.getString(callDetail.Tactic_vod__c); 

            this.st = iPhone_StringUtil.getString(callDetail.Strategy_RAMA_vod__c); 
            this.tc = iPhone_StringUtil.getString(callDetail.Tactic_RAMA_vod__c); 
            this.tl = iPhone_StringUtil.getString(callDetail.Tools_RAMA_vod__c); 

        }
	}
}