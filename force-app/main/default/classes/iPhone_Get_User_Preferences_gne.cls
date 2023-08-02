/***************************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of UserPreferences for the specified user id (unixId).             
*****************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserPreferences/*')
global with sharing class iPhone_Get_User_Preferences_gne extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, Boolean enhDelta, String otrVersion) {
    	return iPhone_Commons_gne.buildResponse(
	    		new iPhone_Get_User_Preferences_gne(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, null, enhDelta, otrVersion)    		
    	);     	    	  	
    } 
    
    protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {  
    	User user = iPhone_DAO.getUserByExternalId(args.unixId);
    	return args.isEnhancedDelta() ? iPhone_DeltaDAO.getUserPreferencesByUserId(user.id, args.getLastSyncDate()) : iPhone_DAO.getUserPreferencesByUserId(user.id);		
    } 	
    	 
    protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    	return new GetUserPreferencesRecord((User_Preference_gne__c)sObj);    		    		
    }    	
    
    class GetUserPreferencesRecord extends iPhone_Commons_gne.DeltaRecord {   	    
		public String ty;
		public String oi;
		public String ot;
		public String wi;
		public Boolean active;
					
		public GetUserPreferencesRecord(User_Preference_gne__c userPreference) {
			this.id = userPreference.id;
			this.ty = userPreference.Type_gne__c;
			this.oi = userPreference.Account_gne__c!=null ? (String)userPreference.Account_gne__c : iPhone_StringUtil.getString(userPreference.OnObject_Id_gne__c);
			this.ot = iPhone_StringUtil.getString(userPreference.OnObject_Type_gne__c);
			this.wi = iPhone_StringUtil.getString(userPreference.Address_gne__c);
			this.active = userPreference.Active_gne__c;
		}						    	
    }
}