public class gFRS_FRB_PaymentCallout {
    @future(callout = true)
    public static void makeFRB_PaymentCallout(String reqId,String fundAllcId,String paymentHistoryId) {        
        String strJson = '';
        String bankNumber;
        String bankName;
        String bankRoutingNumber;
        String programEventTitle;
        system.debug('@@ App Id : '+reqId);
        Id rId = Id.valueOf(reqId);
        DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );	
        fieldNames.add('Organization__r.gFRS_Record_Type__c');
        fieldNames.add('Organization__r.Owner.Profile.Name');
        fieldNames.add('Vendor_Detail__r.Name');
        fieldNames.add('Vendor_Detail__r.City__c');
        fieldNames.add('Vendor_Detail__r.Department_Chapter_Country__c');
        fieldNames.add('Vendor_Detail__r.Id');        
        String query =	  ' SELECT ' +	      String.join( fieldNames, ',' ) +	  ' FROM ' +	      describeResult.getName() +	  ' WHERE ' +	      ' id = :rId ' +	  ' LIMIT 1 '	;	
        // return generic list of sobjects or typecast to expected type	List<SObject> records = Database.query( query );
        gFRS_Ltng_Application__c reqRecd=Database.query( query );
        gFRS_Ltng_Payment_History__c paymentHistoryRecd = [SELECT Id,Status__c, Name, gFRS_Application__c, Amount__c, Payment_Method__c, 
                                                                SAP_Doc_ID__c, SAP_Payment_Document_ID__c,gFRS_Funding_Allocation__r.Auto_Process_Check__c,
                                                                gFRS_Funding_Allocation__c,gFRS_Funding_Allocation__r.Payment_Amounts__c,gFRS_Funding_Allocation__r.Approved_Amount__c,gFRS_Funding_Allocation__r.Baseline_Date__c, Date__c, Payment_Type__c, InvokeType__c, Action__c, 
                                                                SAP_Request_ID__c, Payment_Refund_Status__c, Type_of_Check_Received__c, Signed_Amount__c,
                                                                ESB_Error__c, Payment_Sub_status__c, Check_Number__c, Created_Timestamp__c, I_Block_Released__c, 
                                                                Integration_Id__c, Invoice_Block_Status__c, Note__c,Refund_Amount__c,
                                                                Payment_Block__c, SAP_Payment_Sent_Date__c 
                                                                FROM gFRS_Ltng_Payment_History__c Where id=:paymentHistoryId];
        
        gFRS_Ltng_ACH_Details__c achRecd = [select id,Name,gFRS_Vendor_Detail__c,Bank_Account_Number__c,Bank_Name__c,Bank_Routing_ID__c from gFRS_Ltng_ACH_Details__c where Id=:reqRecd.ACH_Details_Rec_ID__c];
        if(String.isNotBlank(achRecd.Bank_Account_Number__c)){
             bankNumber =decryptACH(achRecd.Bank_Account_Number__c);
        }
        if(String.isNotBlank(achRecd.Bank_Name__c)){
             bankName =decryptACH(achRecd.Bank_Name__c);
        }
        if(String.isNotBlank(achRecd.Bank_Routing_ID__c)){
             bankRoutingNumber =decryptACH(achRecd.Bank_Routing_ID__c);
        }
        if(String.isNotBlank(reqRecd.Event_Program_Title__c)){
            if(reqRecd.Event_Program_Title__c.length()>70){
             programEventTitle=reqRecd.Event_Program_Title__c.substring(0, 70);
            }
            else{
                programEventTitle=reqRecd.Event_Program_Title__c;
            }
        }
        String remaintainceInf = 'Genentech FND ' +reqRecd.Name;
        String paymentAmount = String.valueOf(paymentHistoryRecd.gFRS_Funding_Allocation__r.Payment_Amounts__c);
        GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        String URl = orgCS.FRBEndpointURl__c;
       	String debetorAccountNumber = orgCS.FRB_Debtor_AccountNo__c;
        JSONGenerator jsGen = JSON.createGenerator(true);
        // start object ({)
        jsGen.writeStartObject();
        jsGen.writeFieldName('Document');
        jsGen.writeStartObject();
        jsGen.writeFieldName('CstmrCdtTrfInitn');
        jsGen.writeStartObject();
        jsGen.writeFieldName('GrpHdr');
        jsGen.writeStartObject();
        jsGen.writeStringField('MsgId', reqRecd.Name);
        jsGen.writeDateTimeField('CreDtTm', System.now()); 
        jsGen.writeStringField('NbOfTxs', '1');
        jsGen.writeStringField('CtrlSum', paymentAmount);
        jsGen.writeFieldName('InitgPty');
        jsGen.writeStartObject();
        jsGen.writeStringField('Nm', 'GENEFND');		
        jsGen.writeFieldName('Id');
        jsGen.writeStartObject();
        jsGen.writeFieldName('OrgId');
        jsGen.writeStartObject();
        jsGen.writeFieldName('Othr');
        jsGen.writeStartObject();
        jsGen.writeStringField('Id', 'GENEFND');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('PmtInf');
        jsGen.writeStartObject();
        jsGen.writeStringField('PmtInfId', paymentHistoryRecd.Name);
        jsGen.writeStringField('PmtMtd', 'TRF');
        jsGen.writeFieldName('PmtTpInf');
        jsGen.writeStartObject();
        jsGen.writeFieldName('SvcLvl');
        jsGen.writeStartObject();
        jsGen.writeStringField('Cd', 'URGP');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeDateField('ReqdExctnDt', paymentHistoryRecd.gFRS_Funding_Allocation__r.Baseline_Date__c);
        jsGen.writeFieldName('Dbtr');
        jsGen.writeStartObject();
        jsGen.writeStringField('Nm', 'Test Coy LLC');
        jsGen.writeFieldName('PstlAdr');
        jsGen.writeStartObject();
        jsGen.writeStringField('PstCd', '94111');
        jsGen.writeStringField('TwnNm', 'San Francisco');
        jsGen.writeStringField('CtrySubDvsn', 'CA');
        jsGen.writeStringField('Ctry', 'US');
        jsGen.writeStringField('AdrLine', '111 Pine Street');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('DbtrAcct');
        jsGen.writeStartObject();
        jsGen.writeFieldName('Id');
        jsGen.writeStartObject();
        jsGen.writeFieldName('Othr');
        jsGen.writeStartObject();
        jsGen.writeStringField('Id', debetorAccountNumber);
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('Tp');
        jsGen.writeStartObject();
        jsGen.writeStringField('Cd', 'CACC');
        jsGen.writeEndObject();
        jsGen.writeStringField('Ccy', 'USD');
        jsGen.writeEndObject();
        jsGen.writeFieldName('DbtrAgt');
        jsGen.writeStartObject();
        jsGen.writeFieldName('FinInstnId');
        jsGen.writeStartObject();
        jsGen.writeFieldName('ClrSysMmbId');
        jsGen.writeStartObject();
        jsGen.writeFieldName('ClrSysId');
        jsGen.writeStartObject();
        jsGen.writeStringField('Cd', 'USABA');
        jsGen.writeEndObject();
        jsGen.writeStringField('MmbId', '321081669');		
        jsGen.writeEndObject();
        jsGen.writeFieldName('PstlAdr');
        jsGen.writeStartObject();
        jsGen.writeStringField('PstCd', '94111');
        jsGen.writeStringField('TwnNm', 'San Francisco');
        jsGen.writeStringField('CtrySubDvsn', 'CA');
        jsGen.writeStringField('Ctry', 'US');
        jsGen.writeStringField('AdrLine', '111 Pine Street');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('CdtTrfTxInf');
        jsGen.writeStartObject();
        jsGen.writeFieldName('PmtId');
        jsGen.writeStartObject();
        jsGen.writeStringField('EndToEndId', paymentHistoryRecd.Name);
        jsGen.writeEndObject();
        jsGen.writeFieldName('PmtTpInf');
        jsGen.writeStartObject();
        jsGen.writeFieldName('SvcLvl');
        jsGen.writeStartObject();
        jsGen.writeStringField('Cd', 'URGP');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('Amt');
        jsGen.writeStartObject();
        jsGen.writeFieldName('InstdAmt');
        jsGen.writeStartObject();
        jsGen.writeStringField('Ccy', 'USD');
        jsGen.writeStringField('text', paymentAmount);
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeStringField('ChrgBr', 'DEBT');
        jsGen.writeFieldName('CdtrAgt');
        jsGen.writeStartObject();
        jsGen.writeFieldName('FinInstnId');
        jsGen.writeStartObject();
        jsGen.writeFieldName('ClrSysMmbId');
        jsGen.writeStartObject();
        jsGen.writeFieldName('ClrSysId');
        jsGen.writeStartObject();
        jsGen.writeStringField('Cd', 'USABA');
        jsGen.writeEndObject();
        jsGen.writeStringField('MmbId', bankRoutingNumber);
        jsGen.writeEndObject();
        jsGen.writeStringField('Nm', bankName);
        jsGen.writeFieldName('PstlAdr');
        jsGen.writeStartObject();
        jsGen.writeStringField('TwnNm', reqRecd.Vendor_Detail__r.City__c);
        jsGen.writeStringField('CtrySubDvsn', reqRecd.Vendor_Detail__r.City__c);
        jsGen.writeStringField('Ctry', 'US');
        jsGen.writeStringField('AdrLine', 'Street');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('Cdtr');
        jsGen.writeStartObject();
        jsGen.writeStringField('Nm', reqRecd.Vendor_Detail__r.Name);
        jsGen.writeFieldName('PstlAdr');
        jsGen.writeStartObject();
        jsGen.writeStringField('TwnNm', reqRecd.Vendor_Detail__r.City__c);
        jsGen.writeStringField('CtrySubDvsn', reqRecd.Vendor_Detail__r.City__c);
        jsGen.writeStringField('Ctry', 'US');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('CdtrAcct');
        jsGen.writeStartObject();
        jsGen.writeFieldName('Id');
        jsGen.writeStartObject();
        jsGen.writeFieldName('Othr');
        jsGen.writeStartObject();
        jsGen.writeStringField('Id', bankNumber);
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('Tp');
        jsGen.writeStartObject();
        jsGen.writeStringField('Cd', 'CACC');
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeFieldName('InstrForCdtrAgt');
        jsGen.writeStartObject();
        jsGen.writeStringField('InstrInf',programEventTitle);
        jsGen.writeEndObject();
        jsGen.writeFieldName('RmtInf');
        jsGen.writeStartObject();
        jsGen.writeFieldName('Ustrd');
        jsGen.writeStartArray();
        jsGen.writeString(remaintainceInf);
        jsGen.writeString('for FRB Wire 1');
        jsGen.writeEndArray();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        strJson = jsGen.getAsString();	
        system.debug('@@@@::::strJsonn:::'+strJson);
        
        if(String.isNotBlank(URl)){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URl);
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json');
        request.setBody(strJson); 
            
        HttpResponse response = http.send(request);
        // Parse the JSON response
            Map<String, String> m = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
            String status = m.get('status');
            String message = m.get('message');
            
        if (response.getStatusCode() == 200) {
            gFRS_Ltng_Payment_History__c paymentHistory=new gFRS_Ltng_Payment_History__c();
            paymentHistory.Id=paymentHistoryId;
            paymentHistory.Status__c=status;
            paymentHistory.ESB_Error__c=message;
            paymentHistory.Amount__c=paymentHistoryRecd.gFRS_Funding_Allocation__r.Payment_Amounts__c;
            update paymentHistory;
            gFRS_Ltng_FundAllcViewController.sendNotificationEmails(reqId);
            
        }else{
            gFRS_Ltng_Payment_History__c paymentHistory=new gFRS_Ltng_Payment_History__c();
            paymentHistory.Id=paymentHistoryId;
            paymentHistory.Status__c=status;
            paymentHistory.ESB_Error__c=message;
            update paymentHistory;
        }
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug('@@@Response body' +response.getBody());
        }
         //return response;
        }
    }  
    
    public static string decryptACH(string stringToDecrypt){
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        Blob aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        Blob decoder = EncodingUtil.base64Decode(stringToDecrypt);
        Blob decryptor = Crypto.decryptWithManagedIV('AES256', aesKey, decoder);
        string decryptedStr = decryptor.toString();
        return decryptedStr;
    }
    
    
}