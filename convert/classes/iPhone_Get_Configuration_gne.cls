/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a global configuration for OTR2 project 
*  (as a json string). The configuration text can be edited at the iPhone_Settings_gne.page 
*
*  Modification History
*  Date            Name               Description
*  2014.01.21	   Lukasz Bieniawski  The Read setting logic managed by IPhoneSettingsRecord class.              
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetConfiguration/*')
global with sharing class iPhone_Get_Configuration_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest() {
    	iPhone_Commons_gne.setStartTimeStamp();
    	IPhoneSettingsRecord.refresh();
    	return iPhone_Commons_gne.buildResponse(
    				new GetConfigurationResponseBuilder(),  
    				null
    		   );    	           	    
    }
      
    class GetConfigurationResponse extends iPhone_Commons_gne.RestResponse {
    	public String configText;
    }
    
    class GetConfigurationResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
    	    	
		public iPhone_Commons_gne.RestResponse build(Object arg) {
			GetConfigurationResponse response = new GetConfigurationResponse();			
			response.configText = IPhoneSettingsRecord.getInstance().getText();			
			return response;			
		}
    }
}