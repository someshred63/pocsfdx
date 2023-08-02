/******************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2016-12-13
*  Project: PACT
*  Description: REST Webservice to manage FRM HCO Mappings. 
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneManageAccountMapping/*')
global without sharing class iPhone_ManageAccountMapping implements iPhone_Commons_gne.Runnable{
	
	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(AccountMappingParams params) {		
		return iPhone_Commons_gne.executeAlterData(
			new iPhone_ManageAccountMapping(), 
			params
		);						 																					
	}
	
	@HttpDelete
    global static iPhone_Commons_gne.RestResponse doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String recId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try{
        	if(String.isNotEmpty(recId)){
	        	delete [SELECT Id FROM FRM_HCO_Mapping_gne__c WHERE Id = :recId];
        	}
	        return new iPhone_Commons_gne.BasicResponse();
        }catch(Exception ex){
        	return new iPhone_Commons_gne.BasicResponse(ex);
        }
    }
	

	
	public Object run(Object arg) {
		AccountMappingParams params = (AccountMappingParams)arg;
		GNE_SFA2_HCPtoFRMHCOMappingEngine.SaveMappingWrapper result = new GNE_SFA2_HCPtoFRMHCOMappingEngine().createAccountMapping(params.hcoId, params.hcpId, params.addressId, params.pactAccountId, params.pactAddressId);
		return new iPhone_Commons_gne.AlterDataResponse(result.getMapping().Id);
	}

	global class AccountMappingParams implements iPhone_Commons_gne.BaseArgs{
		private String iphoneRequestId;
		private String unixId;
		private String hcoId;
		private String hcpId;
		private String addressId;
		private String pactAccountId;
		private String pactAddressId;
		
		
		public AccountMappingParams(String iphoneRequestId, String unixId, String hcoId, String hcpId, String addressId, String pactAccountId, String pactAddressId){
			this.unixId = unixId;
			this.hcoId = hcoId;
			this.hcpId = hcpId;
			this.addressId = addressId;
			this.pactAccountId = pactAccountId;
			this.pactAddressId = pactAddressId;
		}
		
		public String getIPhoneRequestId(){
			return iphoneRequestId;
		}
	}
}