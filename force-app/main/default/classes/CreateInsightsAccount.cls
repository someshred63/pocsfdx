global with sharing class CreateInsightsAccount implements Process.Plugin{
    
    public CreateInsightsAccount() {
        
    }
    
    
    global Process.PluginResult invoke(Process.PluginRequest request) {
        Map<String,Object> result = new Map<String,Object>();
        
        String FirstName = (String)request.inputParameters.get('FirstName'); 
        String LastName = (String)request.inputParameters.get('LastName'); 
        String eMail = (String)request.inputParameters.get('eMail'); 
        string account_id = create_Account(FirstName, LastName, eMail);
        system.debug('Record_Type_ID: ' + account_id);
        result.put('InsightsAccountID', account_id);
        return new Process.PluginResult(result);
    }
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
//      result.setDescription('This Plugin schedules the New Relic Agent and defines the frequency with which it reports');
//      result.setTag('NewRelic Agent');
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('FirstName',Process.PluginDescribeResult.ParameterType.String, true),
            new Process.PluginDescribeResult.InputParameter('LastName',Process.PluginDescribeResult.ParameterType.String, true),
            new Process.PluginDescribeResult.InputParameter('eMail',Process.PluginDescribeResult.ParameterType.String, true)};                
        
        result.outputParameters = new List<Process.Plugindescriberesult.Outputparameter>{
            new Process.Plugindescriberesult.Outputparameter('InsightsAccountID', Process.Plugindescriberesult.Parametertype.String)
        };

        return result;
        
    }
    
    Public String create_account(string FName, string LName, string eMailAdr){
		string payload;
        string result;
        List <Organization> myOrg = [Select name From Organization];
        
        system.debug(eMailAdr + '; ' + FName + ' ' + LName);
                        
        payload = '{"account":{"name":"' + myOrg[0].Name + '",' +   //"Sample Account",' +
            	  ' "users":[{"email":"' + eMailAdr + '", "password":"Ins1ghtsIntegr@tion", "first_name":"' + FName + '", "last_name":"' + LName + '", "role":"admin", "owner":"true"}],' + 
          		  '"subscriptions":[{"product_id": 18,"quantity": 25, "data_retention": 12}]}}';
        
        system.debug('Payload: ' + payload);
            
        Http h = new Http();
		HttpRequest req = new HttpRequest();	
			
		req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-api-key', '947a9ba53af9cdac257e75ed2674e297472b137e21b7b00 ');
					
        req.setEndpoint('https://rpm.newrelic.com/api/v2/partners/1422/accounts');
		req.setMethod('POST');
						 
        req.setBody(payload);
		
        HttpResponse res;
        if(Test.isRunningTest()){
            result = '{"id": 565365,"name": "Sample Account","status": "pending","license_key": "caf8247360d8db295c142c72138fa8fb28df1403","api_key": "86f818b6d81668b6c034661396b71c25bb323d8b8df1403","data_access_key": "a65a8ba22a269975c794819e2a5b05899eb98b248df1403","browser_monitoring_key": "66617123f5","allow_api_access": true,"high_security": false,"testing": null,"partner_external_identifier": null,"subscription": {"id": XXXXXX,"starts_on": "2016-05-17","expires_on": null,"annual_renewal_on": null,"products": [{"product_id": 4,"name": "Pro","units": 10,"price": 1990.0}]},"primary admin": {"id": XXXXXX,"email": "sample_user@sample.org","first_name": "Sample","last_name": "User","state": "active"}}';
        } Else {
			res = h.send(req);
            result = res.getBody();
        }
		
/*        if (res.getBody() != null) {
			result = res.getBody();
        } else {
            result = 'Call to New Relic failed';
        } */
            
        // Parse JSON response to get all the totalPrice field values.
       	JSONParser parser = JSON.createParser(result);
       	String NRAccountID;
       	while ((parser.nextToken() != null) && NRAccountID == null) {
           	if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
               	(parser.getText() == 'id')) {
                // Get the value.
	            parser.nextToken();
    	        // Compute the grand total price for all invoices.
       	        NRAccountID = parser.getText();
           	}
       	}
            
    	system.debug(result);
        system.debug(NRAccountID);
            
/*        List <SFDC2Insights__c> my_setting = [Select Name, NR_Account_ID__c From SFDC2Insights__c Where Name = 'Default App Settings'];
        my_setting[0].NR_Account_ID__c = NRAccountID;
        Update my_setting[0];
*/        
        return NRAccountID;
    }
}