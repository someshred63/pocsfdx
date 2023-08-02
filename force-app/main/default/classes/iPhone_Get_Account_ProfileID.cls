/******************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2013-11-18
*  Project: sfa-514
*  Description: REST Webservice, returns a list of 	Profile ID/License for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountProfileIDLicence/*')
global with sharing class iPhone_Get_Account_ProfileID {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetProfileIdResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, null, accountIds
    		)
    	);     	  
    } 
              
    class GetProfileIdResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getAccountProfileId(args.accountIds);      
    	} 	 
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetProfileIdDetailsRecord((ProfileID_License_gne__c)sObj);    		    		
    	}        	    	
    }        
    
    class GetProfileIdDetailsRecord extends iPhone_Commons_gne.DeltaRecord {
        public String aid;  //(Account_Name_gne__c)
        public String li;  //(ID_License_gne__c)
        public String st;  //(State_gne__c)
        public String ai;	//(Address_gne__c)
                                             
        public GetProfileIdDetailsRecord(ProfileID_License_gne__c profileId) {                   
            this.id = profileId.Id;                                                                                           
            this.aid = profileId.Account_Name_gne__c;                                                 
            this.li = iPhone_StringUtil.getString(profileId.ID_License_gne__c);               
            this.st = iPhone_StringUtil.getString(profileId.State_gne__c);     
            this.ai = iPhone_StringUtil.getString(profileId.Address_gne__c);
        }                       
    }
}