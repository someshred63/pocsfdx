/******************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2016-12-06
*  Project: PACT
*  Description: REST Webservice, returns a list of hcp mappings for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetHCPsToMapping/*')
global with sharing class iPhone_Get_HCP_To_Mapping {
	private static String userIdPrefix;
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountMappingsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId)
    	);     	  
    } 
              
    class GetAccountMappingsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		User user = iPhone_DAO.getUserByExternalId(args.unixId);
    		return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getAccountMapping(user.Id);
    	}

  	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetHCPMappingRecord((HCP_To_FRM_HCO_Mapping_gne__c)sObj);    		    		
    	}        	    	
    }  

    class GetHCPMappingRecord extends iPhone_Commons_gne.DeltaRecord {	
		public iPhone_Get_Account_Mappings_gne.Address address;
		public iPhone_Get_Account_Mappings_gne.AccountDetail account;
		public String pactAccountId;
		public String pactAddresId;
		public String products;
		
		
		public GetHCPMappingRecord(HCP_To_FRM_HCO_Mapping_gne__c hcp) {
			this.id = hcp.Id;
			this.pactAccountId = hcp.PACT_Prescriber_Id_gne__c;
			this.pactAddresId = hcp.PACT_Prescriber_Address_Id_gne__c;
			this.account = new iPhone_Get_Account_Mappings_gne.AccountDetail(hcp.HCP_Account_gne__r);
			this.address = new iPhone_Get_Account_Mappings_gne.Address(hcp.HCP_Address_gne__r);
			this.address.aid = hcp.HCP_Account_gne__c;
			this.products = hcp.Products_gne__c;
		}
	}
}