public class   gFRS_ServiceNowCallout {
    public static HttpResponse makeServiceNowCallout() {
        String userName ='intrmapi';
        String password ='Rolemgmt2019';
        String strJson = '';
        JSONGenerator jsGen = JSON.createGenerator(true);
        // start object ({)
        jsGen.writeStartObject();
        
        //Start of Header part.....
        jsGen.writeFieldName('header');
        jsGen.writeStartObject();
        jsGen.writeStringField('transactionid', '12345');
        jsGen.writeStringField('sourcesystemid', 'intrmapi');
        jsGen.writeStringField('targetsystemid', 'SNOW');                
        jsGen.writeEndObject();
        // End of Header part....
        
        //Start of Content part.....
        jsGen.writeFieldName('content');
        jsGen.writeStartObject();
        jsGen.writeFieldName('req_item_name');
        jsGen.writeStartArray();
        jsGen.writeStartObject();
        jsGen.writeStringField('name', 'gMemori MT Application Request');
        jsGen.writeFieldName('variables');
        jsGen.writeStartObject();
        jsGen.writeStringField('hlr_requestedFor', 'e3cd28c64ffc93002983011f0310c72e'); // mandate
        jsGen.writeStringField('hlr_businessReason', 'Test Item - businessReason');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndArray();
        jsGen.writeStringField('request_for', 'guptap16');
        jsGen.writeStringField('description', 'test description 123456');
        jsGen.writeStringField('correlation_id', '123456789');
        jsGen.writeEndObject();
        // End of content part....
        
        jsGen.writeEndObject();
        strJson = jsGen.getAsString();
        system.debug('@@@@::::strJsonn:::'+strJson);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://send-tst.roche.com/api/IT4IT/ServiceNow/request/v2.0/request/createRequestMethod?apikey=e0fac6fb-eedf-4260-91d1-c98a55a134a2');
        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/json');    	
        Blob headerValue = Blob.valueOf(userName+':'+password);
       	// Blob auth = Blob.valueOf(user+':'+password);
        //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(strJson);        
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug('@@@Response body' +response.getBody());
        }
        return response;
    }       
}