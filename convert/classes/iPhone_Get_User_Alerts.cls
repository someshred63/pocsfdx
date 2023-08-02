/**************************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com
*  Created: 2016-03-25
*  Description: REST Webservice, returns a list of Alerts for the specified user id (unixId).
***************************************************************************************************/
@RestResource(urlMapping = '/iPhoneGetUserAlerts/*')
global with sharing class iPhone_Get_User_Alerts {
	
	
	@HttpPost 
     global static iPhone_Commons_gne.RestResponse processRequest(String unixId, String lastSyncDate) {    	    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetUserAlertsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId)	    							   	    			  
    	);    	    	    	    	
    } 
     
    class GetUserAlertsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		User user = iPhone_DAO.getUserByExternalId(args.unixId);
    		return iPhone_Get_User_Alerts.getUserAlerts(user.Id);
    	} 	
    	 
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new UserAlertRecord(((Sfa_Alert_gne__c)sObj));    				
    	} 
    }
    
    
    class UserAlertRecord extends iPhone_Commons_gne.DeltaRecord {    	    
		public String ti; //(title)
		public String de; //(description)
		public Datetime fd; //(fire date)
		public Datetime ed; //(expiration date)
		public String pr; //(priority)
		public Boolean ia; //(is active)
			
		
		public UserAlertRecord(Sfa_Alert_gne__c alert) {
			this.id = alert.Id;
			this.ti = alert.Title_gne__c;
			this.de = alert.Description_gne__c;
			this.fd = alert.Fire_Date_gne__c;
			this.ed = alert.Expiration_Date_gne__c;
			this.pr = alert.Priority_gne__c;
			this.ia = true;
		}    	
    }       
    
    private static List<Sfa_Alert_gne__c> getUserAlerts(Id userId){
    	if(GNE_SFA2_User_Notification__c.getInstance().Enabled_gne__c){
    		return [SELECT Id, Description_gne__c, Expiration_Date_gne__c, Fire_Date_gne__c, Priority_gne__c, Title_gne__c, LastModifiedDate, CreatedDate FROM Sfa_Alert_gne__c WHERE Expiration_Date_gne__c >= :system.now()];
    	}else{
    		return new List<Sfa_Alert_gne__c>();
    	}
    	 
    }
}