/*****************************************************************************************************************************
CLASS NAME: gFRS_OCR_HTTPCallouts
DESCRIPTION: Created this call to handle and make OCR - Vidado related callouts.
LOGS: Maintain atleast last 5 logs

DATE			DEVELOPER			PURPOSE
-----------------------------------------------------------------------------------------------------------------------------
08-Dec-2020		Vikram				Created this class with name gFRS_OCR_HTTPCallouts.


******************************************************************************************************************************/

public with sharing class gFRS_OCR_HTTPCallouts {
    
    /*
    Method Name: getCaptricityToken
    Description: This method helps to get Captricity Token value.
    */
    public static String getCaptricityToken() {
        return Label.GFRS_OCR_CaptricityToken;
    }
    
    /*
    Method Name: getBoundary
    Description: This method helps to get boundary value of salesforce stored in Custom Label.
    */
    public static String getBoundary() {
        return Label.GFRS_OCR_Boundary;
    }
    
    /*
    Method Name: createBatchCallout
    Description: This method helps Vidado first api callout, create batch api is triggered.
	Params: 
    */
    public static String createBatchCallout(String strName){
        String name = strName; //'PA2020 OCR ' + String.valueOf(DateTime.now());
        String batchId = '';
        JSONGenerator payload = JSON.createGenerator(true);
        payload.writeStartObject();
        payload.writeStringField('name',name);
       // payload.writeStringField('name', 'test04Febv3_W9.pdf');
        payload.writeBooleanField('sorting_enabled', true);
        payload.writeBooleanField('is_sorting_only', false);
        payload.writeEndObject();
        String body = payload.getAsString();
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Captricity-API-Token', getCaptricityToken());
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setEndpoint('https://shreddr.captricity.com/api/v1/batch/');
        req.setBody(body);
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        try {
            if(!Test.isRunningTest()) { 
                res = http.send(req);
            }
            else { 
                // mock response will be set in future
            }
            String resultBody = res.getBody();
            Map<String, Object> m =(Map<String, Object>)JSON.deserializeUntyped(resultBody);
            if (m.containsKey('id')) {
                batchId = String.valueOf(m.get('id'));
            } else {
                system.debug('@@@::: Id related key value is not found.');
            }
        } catch(System.Exception e) {
            res.setStatus(e.getMessage());
            system.debug(res.toString());
        }
        system.debug('@@@:::batchId value :::::'+batchId);
        return batchId;
    }
    
    /*
    Method Name: addFileToBatch
    Description: This method helps Vidado second api callout, helps in triggering addFileToBatch api 
					using batch id value received from createBatch response.
	Params:
    */
    public static HttpResponse addFileToBatch(String batchIdVal){
        
        String batchId  = batchIdVal;
        String boundary = getBoundary();
        String footer = '--'+boundary+'--';
        String envName = 'dev';
        String envNameShort = '';
        ContentVersion cv;
        //String fileName = 'PA2020 OCR 2020-12-03 18:04:18';
        Blob bodyBlob = null;
        String docId = null;
        gFRS_OCR_Forms__c obj = null;
        if (envName == 'dev' || envName == 'sqa' || envName == 'uat') {
            envNameShort = '_' + envName.removeStart('pps').toUpperCase();
        }
        if(batchIdVal != null){
                obj = [Select id,gFRS_Batch_ID__c,gFRS_Document_ID__c,gFRS_Attachment_Name__c
                                     from gFRS_OCR_Forms__c where gFRS_Batch_ID__c =: batchId];
            if(obj != null && obj.gFRS_Document_ID__c != null)
            	docId = obj.gFRS_Document_ID__c;            
        }
        if(Test.isRunningTest()){
            cv = [Select id,VersionData,PathOnClient from ContentVersion Limit 1];
        }else{
            cv = [Select id,VersionData,PathOnClient from ContentVersion where ContentDocumentId =: docId and IsLatest = true]; 
        }
         
        HttpRequest req = new HttpRequest();
        req.setHeader('Captricity-API-Token',getCaptricityToken());
        req.setHeader('Content-Type','multipart/form-data');
        //add on values
        req.setHeader('Connection','keep-alive');
        req.setHeader('Accept-Encoding','gzip, deflate, br');
        req.setHeader('Accept','*/*');
        req.setMethod('POST');
        req.setEndpoint('https://shreddr.captricity.com/api/v1/batch/' + batchId + '/batch-file/');        
        req.setHeader('Content-Type','multipart/form-data; boundary=' + getBoundary());       
		Integer extensionIndex = cv.PathOnClient.lastIndexOf('.');
        String reg = '[^A-Za-z0-9_.-]';
        String fileName = obj.gFRS_Attachment_Name__c+ '_' + cv.PathOnClient.left(extensionIndex).replaceAll(' ','_').replaceAll(reg,'') + envNameShort + cv.PathOnClient.right(cv.PathOnClient.length() - extensionIndex);
        //fileName = 'PA2020 OCR 2021-12-03 18:04:18';
        String header =+ boundary +'\r\n';
        header += 'Content-Disposition: form-data; name="uploaded_with"' + '\r\n\r\n' + 'api' + '\r\n--'+ boundary + '\r\n';
        header += 'Content-Disposition: form-data; name="metadata"' + '\r\n\r\n';
        header += '{"item":"' + docId + '", "envName":"' + envName + '"}' + '\r\n--' + boundary + '\r\n';
        header += 'Content-Disposition: form-data; name="uploaded_file"; filename="' +fileName + '"'+ '\r\n\r\n';        
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header));        
        while (headerEncoded.endsWith('=')) {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        
        
        
        String bodyEncoded = EncodingUtil.base64Encode(cv.VersionData);
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        // replacement section to get rid of padding without corrupting data
        if (last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if (last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);
        req.setHeader('Content-Length', String.valueOf(bodyBlob.size()));
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        try {
            if(!Test.isRunningTest()) { 
                res = http.send(req);
            }
            else {                     
            	system.debug('@@:::set up mockup.');
                res.setHeader('Content-Type', 'multipart/form-data');
                res.setBody('{"example":"test"}');
                res.setStatusCode(200);
            }
        }
        catch(System.Exception e) {
            res.setStatus(e.getMessage());
            system.debug(res.toString());
        }
        system.debug('@@@:::'+res);
        return res;
    }
    
    /*
    Method Name: submitBatchCallout
    Description: This method helps Vidado third api callout, submit batch api is triggered.
    */
    public static HttpResponse submitBatchCallout(String batchIdVal) {
        String batchId  = batchIdVal;
        HttpRequest req = new HttpRequest();
        req.setHeader('Captricity-API-Token',getCaptricityToken());
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setEndpoint('https://shreddr.captricity.com/api/v1/batch/' + batchId + '/submit');
        req.setTimeout(120000);
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        try {
            if(!Test.isRunningTest()) {
                res = http.send(req); } 
            else { 
                system.debug('@@:::set up mockup.');
                res.setHeader('Content-Type', 'multipart/form-data');
                res.setBody('{"example":"test"}');
                res.setStatusCode(200);
            }
        }catch(System.Exception e) {            
            res.setStatus(e.getMessage());
            system.debug(res.toString());
        }
            system.debug('@@@ res:::'+res);
        return res;
    }
}