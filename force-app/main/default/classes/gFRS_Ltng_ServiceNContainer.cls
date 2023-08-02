public class gFRS_Ltng_ServiceNContainer {
    
    
    @AuraEnabled
    public static String sNCreateIncidentMethod(Id recId){
        
        gFRS_Ltng_Customer_Intraction__c CInfo=[SELECT Id, Name, RecordTypeId, Urgency__c, Business_Service__c, Service_Offering__c,
                                                Sub_Category__c, State__c, Short_Description__c, Impact__c, Request_Description__c, 
                                                Assignment_Group__c, Caller_Id__c, Affected_user__c, Email_Address__c, Triaged_to__c,
                                                Source__c, Status__c, Organization_Name__c, Description__c 
                                                FROM gFRS_Ltng_Customer_Intraction__c Where Id=:recId];
        String strJson = '';
        Id userId = UserInfo.getUserId();
        
        User userRec = [SELECT Id, Name, External_ID_gne__c FROM User WHERE Id =: userId];
        JSONGenerator jsGen = JSON.createGenerator(true);
        // start object ({)
        jsGen.writeStartObject();
        
        //Start of Content part.....
        jsGen.writeFieldName('content');
        jsGen.writeStartObject();
        jsGen.writeStringField('caller_id', userRec.External_ID_gne__c);
        if(CInfo.Affected_user__c != '' && CInfo.Affected_user__c != null){
            jsGen.writeStringField('affected_user', CInfo.Affected_user__c);
        } else {
            jsGen.writeStringField('affected_user', userRec.External_ID_gne__c);
        }
        
        jsGen.writeStringField('assignment_group',CInfo.Assignment_Group__c);
        jsGen.writeStringField('description', CInfo.Description__c);
        jsGen.writeStringField('impact', '2');
        jsGen.writeStringField('short_description','Creating incident using REST API');
        jsGen.writeStringField('state', '1');
        jsGen.writeStringField('subcategory', '');
        jsGen.writeStringField('service_offering',CInfo.Service_Offering__c );
        jsGen.writeStringField('business_service', CInfo.Business_Service__c);
        jsGen.writeStringField('urgency', '2');  
        jsGen.writeEndObject();
        
        //Start of Header part.....
        jsGen.writeFieldName('header');
        jsGen.writeStartObject();
        jsGen.writeStringField('sourcesystemid', 'COMMMS');
        jsGen.writeStringField('targetsystemid', 'SNOW');
        jsGen.writeStringField('transactionid', CInfo.Name);                
        jsGen.writeEndObject();
        // End of Header part....
        
        
        jsGen.writeEndObject();
        strJson = jsGen.getAsString();
        //system.debug('@@@@::::strJsonn:::'+strJson);
        
        HttpRequest req = new HttpRequest();
        String endpoint = System.Label.SN_Incident_Endpoint; //'https://dev-de-c1.apis.roche.com/fg-snow-incident-cloud-exp-dev/incident/createIncidentMethod';
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setHeader('client_id', System.Label.SN_IN_Client_id);
        req.setHeader('client_secret', System.Label.SN_IN_Client_Secret);
        
        String number_Incident;
        String username =System.Label.SN_Username;     //'USIXSNTS';
        String password = System.Label.SN_In_Password;    //'Usix@123';
        req.setClientCertificateName('usixsnts');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(strJson);  
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() != 201) {
            System.debug('The status code returned: ' +
                         res.getStatusCode() + '@@Status--> ' + res.getStatus()+'@@@Response body-->' +res.getBody());
            
            String input = res.getBody();
            Map<String, Object> o = (Map<String, Object>) JSON.deserializeUntyped(input);
            Map<String, Object> bdy = (Map<String, Object>) o.get('result');
            system.debug(bdy.get('number'));
            number_Incident=String.valueOf(bdy.get('number'));
            
            
            //gFRS_Ltng_Customer_Intraction__c upCI=new gFRS_Ltng_Customer_Intraction__c();
            
            CInfo.Active_Incident__c 	= number_Incident;
            CInfo.Caller_Id__c 			= userRec.External_ID_gne__c;
            if(CInfo.Affected_user__c == '' || CInfo.Affected_user__c == null){
                CInfo.Affected_user__c 			= userRec.External_ID_gne__c;
            }
            CInfo.Short_Description__c	= 'Creating incident using REST API';
            CInfo.Request_Description__c = CInfo.Description__c;
            
            update CInfo;
            
        } else {
            System.debug('@@@Response body' +res.getBody());
            
        }

        //JsonResponse jsonApex = JsonResponse.parse(res.getBody());
        //System.debug('@@@ Response'+jsonApex.result);      
        
        return number_Incident;
    }
    
    @AuraEnabled
    public static String sNCreateRequestMethod(Id recId){
        
        gFRS_Ltng_Customer_Intraction__c CInfo=[SELECT Id, Name, RecordTypeId, Urgency__c, Business_Service__c, Service_Offering__c,
                                                Sub_Category__c, State__c, Short_Description__c, Impact__c, Request_Description__c, 
                                                Assignment_Group__c, Caller_Id__c, Affected_user__c, Email_Address__c, Triaged_to__c,
                                                Source__c, Status__c, Organization_Name__c, Description__c 
                                                FROM gFRS_Ltng_Customer_Intraction__c Where Id=:recId];
        
        String strJson = '';
        JSONGenerator jsGen = JSON.createGenerator(true);
        // start object ({)
        jsGen.writeStartObject();
        
        //Start of Header part.....
        jsGen.writeFieldName('header');
        jsGen.writeStartObject();
        jsGen.writeStringField('transactionid', CInfo.Name);
        jsGen.writeStringField('sourcesystemid', 'GFRS');
        jsGen.writeStringField('targetsystemid', 'SNOW');                
        jsGen.writeEndObject();
        // End of Header part....
        
        //Start of Content part.....
        jsGen.writeFieldName('content');
        jsGen.writeStartObject();
        jsGen.writeFieldName('req_item_name');
        jsGen.writeStartArray();
        jsGen.writeStartObject();
        jsGen.writeStringField('name', 'gneCOMM INTERFACE ESB Service Request');
        jsGen.writeFieldName('variables');
        jsGen.writeStartObject();
        jsGen.writeStringField('hlr_requestedFor', 'e3cd28c64ffc93002983011f0310c72e'); // mandate
        jsGen.writeStringField('hlr_businessReason', CInfo.Description__c);
        jsGen.writeStringField('title', CInfo.Name);
        jsGen.writeStringField('dev', 'true');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndArray();
        jsGen.writeStringField('request_for', '1f8c3e861bbfb0d4decedca19b4bcb23');
        jsGen.writeStringField('description', CInfo.Description__c);
        jsGen.writeStringField('correlation_id', '123456789');
        jsGen.writeEndObject();
        // End of content part....
        
        //Start of Attachment
        /* jsGen.writeFieldName('Attachment');
        jsGen.writeStartArray();
        jsGen.writeStartObject();
        jsGen.writeStringField('file_name','test.txt');
        jsGen.writeStringField('mime_type','text/plain');
        jsGen.writeStringField('base64string','VGhpcyBpcyB0ZXN0IEJBU0U2NA==');
        jsGen.writeEndObject();
        jsGen.writeEndArray();
        // End of content part....
        
        jsGen.writeEndObject(); */
        strJson = jsGen.getAsString();
        system.debug('@@@@::::strJsonn:::'+strJson);
        
        HttpRequest req = new HttpRequest();
        String endpoint = System.Label.gFRS_SN_Request_Endpoint; //'https://dev-de-c1.apis.roche.com/fg-snow-request-cloud-exp-dev/request/createRequestMethod';
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setClientCertificateName('usixsnts');
        req.setHeader('client_id', System.Label.gFRS_SN_Request_Client_Id);
        req.setHeader('client_secret', System.Label.gFRS_SN_Request_Client_Secret);
        
        /* String username = 'USIXSNTS';
        String password = 'Usix@123'; */
        String username = System.Label.SN_Username;    
        String password = System.Label.SN_In_Password;
        String requestNumber = '';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(strJson);  
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         res.getStatusCode() + ' ' + res.getStatus()+'@@@Response body-->' +res.getBody());
            String input = res.getBody();
            Map<String, Object> o = (Map<String, Object>) JSON.deserializeUntyped(input);
            Map<String, Object> bdy = (Map<String, Object>) o.get('result');
            system.debug(bdy.get('number'));
            requestNumber = String.valueOf(bdy.get('number'));
            
            CInfo.Active_Request__c 	= requestNumber;
            
            update CInfo;
        } else {
            System.debug('@@@Response body' +res.getBody());
        }

        return requestNumber;
        
    }
    
    @AuraEnabled
    public static String sNgetIncidentMethod(Id recId){
        
        gFRS_Ltng_Customer_Intraction__c CInfo=[SELECT Id, Name, RecordTypeId, Active_Incident__c,Urgency__c, Business_Service__c, Service_Offering__c,
                                                Sub_Category__c, State__c, Short_Description__c, Impact__c, Request_Description__c, 
                                                Assignment_Group__c, Caller_Id__c, Affected_user__c, Email_Address__c, Triaged_to__c,
                                                Source__c, Status__c, Organization_Name__c 
                                                FROM gFRS_Ltng_Customer_Intraction__c Where Id=:recId];
        String strJson = '';
        JSONGenerator jsGen = JSON.createGenerator(true);
        // start object ({)
        jsGen.writeStartObject();
        
        jsGen.writeStringField('incidents', 'INC4992590,INC4234112');
        jsGen.writeStringField('sourceSystem', 'GFRS');
        jsGen.writeStringField('transactionID','7337929-u12312312312-21311');                
        
        
        jsGen.writeEndObject();
        strJson = jsGen.getAsString();
        system.debug('@@@@::::strJsonn:::'+strJson);
        
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://dev-us-e1.apis.roche.com/pharma-cmg-itsm-tkt-mgmt-proc-dev/v1/incidentsUpdates';  //System.Label.SN_Incident_Endpoint; //'https://dev-de-c1.apis.roche.com/fg-snow-incident-cloud-exp-dev/incident/createIncidentMethod';
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        //req.setHeader('client_id', '1c402ef0829a47f08930eb0c8785e61f');
        //req.setHeader('client_secret', 'D2ef3dA3E6e24599a02230E47d2dfD9b');
        
        String username ='1c402ef0829a47f08930eb0c8785e61f';    //System.Label.SN_Username;     //'USIXSNTS';
        String password ='D2ef3dA3E6e24599a02230E47d2dfD9b'; //System.Label.SN_In_Password;    //'Usix@123';
        //req.setClientCertificateName('usixsnts');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        System.debug('authorizationHeader-->'+authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(strJson);  
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('The status code returned: ' +
                         res.getStatusCode() + '@@Status--> ' + res.getStatus()+'@@@Response body-->' +res.getBody());
        
        if (res.getStatusCode() != 201) {
            System.debug('The status code returned: ' +
                         res.getStatusCode() + '@@Status--> ' + res.getStatus()+'@@@Response body-->' +res.getBody());
        } else {
            System.debug('@@@Response body' +res.getBody());
        }
        
        String number_Incident;
        
        //JsonResponse jsonApex = JsonResponse.parse(res.getBody());
        //System.debug('@@@ Response'+jsonApex.result);      
        
        
        String input = res.getBody();
       /* Map<String, Object> o = (Map<String, Object>) JSON.deserializeUntyped(input);
        Map<String, Object> bdy = (Map<String, Object>) o.get('result');
        system.debug(bdy.get('number'));
        number_Incident=String.valueOf(bdy.get('number')); */
        
        
        //gFRS_Ltng_Customer_Intraction__c upCI=new gFRS_Ltng_Customer_Intraction__c();
        
        
        return number_Incident;
    }
    
    
    
    
    
}