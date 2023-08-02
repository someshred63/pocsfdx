public class II {
    // Constructor
    // 
    public II(){
    }
    
    public static void InsightsSetup(string command){
        if (command == 'new_account') {
            string payload;
            string result;
            List <Organization> myOrg = [Select name From Organization];
                        
            payload = '{"account":{"name":"' + myOrg[0].Name + '",' +   //"Sample Account",' + 
                		' "users":[{"email":"heiko@newrelic.com", "password":"RubyOnRails1!", "first_name":"Heiko", "last_name":"Leibenath", "role":"admin", "owner":"true"}],' + 
                		'"subscriptions":[{"product_id": 18,"quantity": 25, "data_retention": 12}]}}';
            
            Http h = new Http();
			HttpRequest req = new HttpRequest();	
			
			req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', '711a9438216921de138ea6bdf60eafcac8526934def26ee');
			
			req.setEndpoint('https://staging.newrelic.com/api/v2/partners/300/accounts');
			req.setMethod('POST');
				
			 req.setBody(payload);
			
			HttpResponse res = h.send(req);
			result = res.getBody();
            
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
            
            List <SFDC2Insights__c> my_setting = [Select Name, NR_Account_ID__c From SFDC2Insights__c Where Name = 'Default App Settings'];
            my_setting[0].NR_Account_ID__c = NRAccountID;
            Update my_setting[0];
        }
    }

    
    @future(callout = true)  	    
    public static void generateJson(){
        string result;
        Integer responseCode;
        string accessToken;
        string lastFileWritten = '';
        
        String SFDC2InsightsRecordName2Use;
        if(Test.isRunningTest()){
            SFDC2InsightsRecordName2Use = 'thisisatest';
        }
        else{
            SFDC2InsightsRecordName2Use = 'Default App Settings';
        }
        SFDC2Insights__c sfdc2Insights = SFDC2Insights__c.getValues(SFDC2InsightsRecordName2Use);

        // Setting up JWT to get the access Token for ETL process     
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(sfdc2Insights.Integratio_Running_User_Username__c); 
        if (sfdc2Insights.Sandbox__c) {
            jwt.setAud('https://test.salesforce.com'); 
        } Else {
        	jwt.setAud('https://login.salesforce.com');    
        }
         
        jwt.setIss(sfdc2Insights.Consumer_Key__c);
        
        // Additional claims to set scope
        // currently not using additional claims, might need to discuss in future
/*      Map<String, Object> claims = new Map<String, Object>();
        claims.put('scope', 'scope name');
		jwt.setAdditionalClaims(claims); */

        //Create the object that signs the JWT bearer token
        Auth.JWS my_jws = new Auth.JWS(jwt, 'InsightsIntegration');
        
        //Get the resulting JWS in case debugging is required
        String token = my_jws.getCompactSerialization();
        
        //Set the token endpoint that the JWT bearer token is posted to
        String tokenEndpoint;
        if (sfdc2Insights.Sandbox__c) {
            tokenEndpoint = 'https://test.salesforce.com/services/oauth2/token';
        } Else {
        	tokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
        }
        
        //POST the JWT bearer token
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, my_jws);
        
        //Get the access token        
        if(Test.isRunningTest()){
        } Else {
			accessToken = bearer.getAccessToken();
        }
        
        Organization my_org = [Select Name From Organization];
        String org_name = my_org.name;
        List<EventLogFile> my_elf = [SELECT Id, LogFileFieldTypes,ApiVersion,CreatedById,CreatedDate,EventType,IsDeleted,LogDate,LogFileContentType,LogFileFieldNames,LogFileLength FROM EventLogFile WHERE CreatedDate < TOMORROW ORDER BY CreatedDate DESC, Id DESC NULLS FIRST];
        
        // generating JSON for ETL process
        transient JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('sfdc_orgs');
        generator.writeStartArray();
        generator.writeStartObject();
        
        generator.writeStringField('org', org_name);
        if(Test.isRunningTest()){
        } Else {
			generator.writeStringField('sfdcAccessToken', accessToken);
        }
        generator.writeStringField('sfdcBaseUrl', URL.getSalesforceBaseUrl().toExternalForm());
        generator.writeStringField('insightsAccountId', sfdc2Insights.NR_Account_ID__c);
        generator.writeStringField('insightsInsertKey', sfdc2Insights.Custom_Event__c);
        generator.writeFieldName('logevents');
        generator.writeStartArray();
        
        Integer i = 0;
        for (EventLogFile elf : my_elf){
            if (sfdc2Insights.LastFileWritten__c == String.valueof(elf.Id)) {
                break;
            }
        	generator.writeStartObject();
    	    generator.writeStringField('sfdcLogFileUrl', '/services/data/v37.0/sobjects/EventLogFile/' + elf.Id);
	        generator.writeStringField('ApiVersion', String.valueOf(elf.ApiVersion));
	        generator.writeStringField('CreatedById', elf.CreatedById);
	        generator.writeStringField('CreatedDate', String.valueOf(elf.CreatedDate));
	        generator.writeStringField('EventType', elf.EventType);
	        generator.writeStringField('IsDeleted', String.valueOf(elf.IsDeleted));
	        generator.writeStringField('LogDate', String.valueOf(elf.LogDate));
	        generator.writeStringField('LogFileContentType', elf.LogFileContentType);
	        generator.writeStringField('LogFileFieldNames', elf.LogFileFieldNames);
	        generator.writeStringField('LogFileLength', String.valueOf(elf.LogFileLength));
	        generator.writeStringField('logFileFieldTypes', elf.LogFileFieldTypes);
        	generator.writeEndObject();
            //lastFileWritten = elf.Id;
            i += 1;
        }
        
        generator.writeEndArray();
        generator.writeEndObject();
        generator.writeEndArray();
        generator.writeEndObject();

		system.debug(generator.getAsString());        
        
        // sending to ETL
        if(Test.isRunningTest()){
        } Else {
            if (i>0) {
		        Http h = new Http();
				HttpRequest req = new HttpRequest();	
				
				req.setHeader('Content-Type', 'application/json'); 
			
				req.setEndpoint(sfdc2Insights.ETL_URL__c);
				req.setMethod('POST');
				
				req.setBody(generator.getAsString());
                req.setTimeout(120000);
                
                Try {
					HttpResponse res = h.send(req);
					result = res.getBody();
                    responseCode = res.getStatusCode();
    				system.debug(result);                    
                } catch (exception e) {
                    system.debug('Exception:' + e.getMessage());
                    HttpResponse res1 = h.send(req);
                    result = res1.getBody();
                    responseCode = res1.getStatusCode();                    
                }
            }                
        }
        
        system.debug('Size: ' + String.valueof(my_elf.size()));
        if (my_elf.size() >0) {
	        sfdc2Insights.LastFileWritten__c = my_elf[0].Id;
        }
        
        if (responseCode == 200) {
        	update sfdc2Insights;
        }
        
        system.debug('ETL responded with ' + String.valueOf(responseCode));
        system.debug(String.valueof(i) + ' log files processed');
        system.debug('II.generateJSON ran');
    }
}