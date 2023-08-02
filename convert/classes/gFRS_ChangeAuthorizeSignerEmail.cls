/**
* @author GFRS Dev Team 
* @date 11/09/2014
* @description gFRS_ChangeAuthorizeSignerEmail class - class implemented for GFRS-91. Change Authorize Signer Email after sandbox refresh.
*/
global class gFRS_ChangeAuthorizeSignerEmail implements Database.Batchable<sObject>{
	
	global final String query = 'SELECT Signing_Authority_Email__c FROM GFRS_Funding_Request__c WHERE Signing_Authority_Email__c != null';
	
	GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
	String suffix                      = customSettings.AuthorizedSignerEmailSuffix__c;
	/**
    * @author GFRS Dev Team 
    * @date 11/09/2014
    * @description start method - gathering records needed to processing.
    */
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	/**
    * @author GFRS Dev Team 
    * @date 11/09/2014
    * @description execute method - proccesing of the records
    */
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		for(GFRS_Funding_Request__c item : (List<GFRS_Funding_Request__c>)scope){
			if(item.Signing_Authority_Email__c != null && item.Signing_Authority_Email__c != '' && !item.Signing_Authority_Email__c.endsWith(suffix)){
				item.Signing_Authority_Email__c += suffix;			
			}
		}
		
		update scope;

	}
	
	/**
    * @author GFRS Dev Team 
    * @date 11/09/2014
    * @description finish method - finish activities
    */
	global void finish(Database.BatchableContext BC){
		
	}
}