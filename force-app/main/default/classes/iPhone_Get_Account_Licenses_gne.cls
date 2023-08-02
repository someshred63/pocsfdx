/******************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2017-06-02
*  Project: SFA-2885
*  Description: REST Webservice, returns a list of License for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountLicences/*')
global with sharing class iPhone_Get_Account_Licenses_gne {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetLicensesResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, null, accountIds
    		)
    	);     	  
    } 
              
    class GetLicensesResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getAccountLicenses(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getAccountLicenses(args.accountIds); 
    	} 	 
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetLicensesDetailsRecord((Prescriber_License_gne__c)sObj);    		    		
    	}        	    	
    }        
    
    class GetLicensesDetailsRecord extends iPhone_Commons_gne.DeltaRecord {
        public String aid;  //(Account_Name_gne__c)
        public String ln;  //(license number)
        public String ld;  //(license expiration date)
        public String lt;  //(license status) <empty if unknown>
        public String vs;  //(valid to sample)
        public String st;  //(state)
        
        public GetLicensesDetailsRecord(Prescriber_License_gne__c license) {                   
            this.id = license.Id;                                                                                           
            this.aid = license.Account_gne__c;                                                 
    		this.ln  = iPhone_StringUtil.getString(license.name);         
            this.ld  = iPhone_StringUtil.getStringDate(license.License_Expiration_Date_gne__c);
            this.lt  = iPhone_StringUtil.getString(license.License_Status_gne__c);  
            this.vs  = iPhone_StringUtil.getString(license.License_Valid_To_Sample_gne__c);
            this.st  = iPhone_StringUtil.getString(license.License_State_gne__c); 
        }                       
    }
}