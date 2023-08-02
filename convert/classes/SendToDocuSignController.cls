public with sharing class SendToDocuSignController {
    
    @future(callout=true)   
    public static void SendNow(Id sourceId){
       String envelopeId;
       GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
       String accountId = orgCS.DocuSign_AccountId__c;
       String userId = orgCS.DocuSign_UserId__c;
       String password = orgCS.DocuSign_Password__c;
       String integratorsKey = orgCS.DocuSign_IntegratorsKey__c;    //DocuSign_IntegratorsKey__c
       String webServiceUrl = orgCS.DocuSign_WebServiceUrl__c;  //DocuSign_WebServiceUrl__c
        
    /* String accountId = '95bf06d3-cfb9-452a-9d7d-e1ce96948270';   //DocuSign_AccountId__c
       String userId = '3bb814d2-2623-415f-90c5-2e16e4af6019';  //DocuSign_UserId__c
       String password = 'Demo2021';    //DocuSign_Password__c
       String integratorsKey = '7b3934f7-593a-411b-8a56-c9a254e73348';  //DocuSign_IntegratorsKey__c
       String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';   //DocuSign_WebServiceUrl__c*/
       gFRS_Ltng_Application__c appRec = [SELECT Id,Name,Approved_Amount__c,Event_Program_Title__c,Record_Type__c,RecordType.Name,EnvelopeId__c,Owner.FirstName,Owner.LastName,Owner.email,Program_Start_Date_Min__c,
                                          DocusignAttach_PDF_ID__c,Email_Address__c,First_Name__c,Last_Name__c,Authorized_Signer__r.Name,Accountable_Employee_Internal__r.email,Accountable_Employee_Internal__r.FirstName,Accountable_Employee_Internal__r.LastName
                                          FROM gFRS_Ltng_Application__c WHERE Id =: sourceId LIMIT 1];
       Blob pdfBlob = [SELECT Id,VersionData from ContentVersion WHERE ContentDocumentId =: appRec.DocusignAttach_PDF_ID__c LIMIT 1].VersionData;
        String emailName = '';
        if(appRec.RecordType.Name == 'Foundation Safety Net Support' || appRec.RecordType.Name == 'Foundation Undergraduate'){
            emailName = 'LOA_DocuSign_Review_Attachment_Foundation';
        }else{
            emailName = 'LOA_DocuSign_Review_Attachment';
        }
        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Description,HTMLValue,Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName =: emailName];
        //emailCon.setTargetObjectId(appRec.Id);
		
        string prgStartDate =  string.valueOf(appRec.Program_Start_Date_Min__c);
        String programDate = '';
        if(String.isNotBlank(prgStartDate)){
            Date dt=appRec.Program_Start_Date_Min__c;
            programDate=dt.format();
        }
        
        string Subject = emailCon.Subject.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);

        String body = emailCon.HTMLValue.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        String plainTextBody = emailCon.Body.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        
        body = body.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',appRec.Record_Type__c);
        plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',appRec.Record_Type__c);
        
        //body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c} {!gFRS_Ltng_Application__c.Last_Name__c}',appRec.First_Name__c + appRec.Last_Name__c);
        if(string.isNotBlank(appRec.First_Name__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c}',appRec.First_Name__c);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.First_Name__c}',appRec.First_Name__c);
        }
        if(string.isNotBlank(appRec.Last_Name__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.Last_Name__c}',appRec.Last_Name__c);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Last_Name__c}',appRec.Last_Name__c);
        }
        Decimal input=appRec.Approved_Amount__c;
        String AppAmount = '$' + String.valueOf(input.format());
        body = body.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}',AppAmount);
        if(string.isNotBlank(appRec.Event_Program_Title__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', appRec.Event_Program_Title__c);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', appRec.Event_Program_Title__c);
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        
        if(String.isNotBlank(programDate)){
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate);
        }else {
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
        }
        
        body = body.replace(']]>', '');
        body += '\n\n' + '[ref:' + appRec.id + ']';
        
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;

        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);
            
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
            auth);
 
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = Subject;
        //envelope.EmailBlurb = 'I am sending you this request for your electronic signature, please review and electronically sign by following the link below.';
        envelope.EmailBlurb = body;
        envelope.AccountId  = accountId; 


        // Render the contract
       // System.debug('Rendering the contract');
        //PageReference pageRef = new PageReference('/apex/RenderContract');
       // pageRef.getParameters().put('id',contract.Id);
        //Blob pdfBlob = pageRef.getContent();     
        //Blob pdfBlob = [SELECT Id,ContentDocumentId,ContentBodyId,ContentSize,VersionData from ContentVersion].VersionData;
        

        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name = appRec.Name+'_Executed LOA';
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;
        
        // Recipient
        System.debug('getting the contact');
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = appRec.Email_Address__c;
        //recipient.UserName = appRec.Authorized_Signer__r.Name;
        recipient.UserName = appRec.First_Name__c+' '+appRec.Last_Name__c;
            
        // This setting seems required or you see the error:
        // "The string '' is not a valid Boolean value. 
        // at System.Xml.XmlConvert.ToBoolean(String s)" 
        recipient.RequireIDLookup = false;      
        
        DocuSignAPI.Recipient ccrecipient = new DocuSignAPI.Recipient();
        ccrecipient.ID = 1;
        ccrecipient.Type_x = 'CarbonCopy';
        ccrecipient.RoutingOrder = 1;
        String recordType = appRec.Record_Type__c;
        if(recordType == 'Commercial Sponsorship' || recordType == 'Corporate Memberships' || recordType == 'Non-Commercial Sponsorship'){
            ccrecipient.Email = appRec.Accountable_Employee_Internal__r.email;
        	ccrecipient.UserName = appRec.Accountable_Employee_Internal__r.FirstName+''+appRec.Accountable_Employee_Internal__r.LastName;
        }else{
	        ccrecipient.Email = appRec.Owner.email;
          
	        ccrecipient.UserName = appRec.Owner.FirstName + appRec.Owner.LastName;
        }
        ccrecipient.RequireIDLookup = false; 
   /*
        DocuSignAPI.Recipient ccrecipientUser = new DocuSignAPI.Recipient();
        if(String.isNotEmpty(CCUser)){
        ccrecipientUser.ID = 1;
        ccrecipientUser.Type_x = 'CarbonCopy';
        ccrecipientUser.RoutingOrder = 1;
        ccrecipientUser.Email =CCUser;
     //   ccrecipientUser.UserName = appRec.Owner.FirstName + appRec.Owner.LastName;
        ccrecipientUser.RequireIDLookup = false; 
        }
       */ 
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[2];
        envelope.Recipients.Recipient[0] = recipient;
        if(recipient.Email != ccrecipient.Email){
            envelope.Recipients.Recipient[1] = ccrecipient;
        }
        /*
        if(String.isNotEmpty(CCUser)){
        if(recipient.Email != ccrecipient.Email&&recipient.Email != ccrecipientUser.Email&&ccrecipient.Email != ccrecipientUser.Email){
            envelope.Recipients.Recipient[2] = ccrecipientUser;
        }
        }
*/
        // Tab
        DocuSignAPI.Tab tab1 = new DocuSignAPI.Tab();
        tab1.Type_x = 'SignHere';
        tab1.RecipientID = 1;
        tab1.DocumentID = 1;
        tab1.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString = 'By:';
        tab1.AnchorTabItem.XOffset = 50;
        //tab1.AnchorTabItem.YOffset = 100;
        //tab1.PageNumber = 1;
        //tab1.XPosition = 100;
        //tab1.YPosition = 100;

        
        DocuSignAPI.Tab tab2 = new DocuSignAPI.Tab();
        tab2.Type_x = 'DateSigned';
        tab2.RecipientID = 1;
        tab2.DocumentID = 1;
        tab2.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString = 'Date/Time:';
        tab2.AnchorTabItem.XOffset = 80;
        //tab2.XPosition = 100;
        //tab2.YPosition = 100;       
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[2];
        envelope.Tabs.Tab[0] = tab1;        
        envelope.Tabs.Tab[1] = tab2;        
        system.debug('tabs'+envelope.Tabs);
        System.debug('Calling the API');
        try {
            DocuSignAPI.EnvelopeStatus es 
            = dsApiSend.CreateAndSendEnvelope(envelope);
            envelopeId = es.EnvelopeID;
            gFRS_Ltng_Application__c appObj = new gFRS_Ltng_Application__c();
            if(appRec.EnvelopeId__c == '' || appRec.EnvelopeId__c == null){
                appObj.Docusign_Task_Check__c = True;
            }
            appObj.EnvelopeId__c = es.EnvelopeID;
            appObj.Id = sourceId;
            update appObj;
            try{
                    Attachment a       = new Attachment();
                    a.ParentId         = sourceId;
                    a.ContentType = '.pdf';
                    String fileContent = '';
                    
                    fileContent +='From: '+'No-ReplySignRequest <No-ReplySignRequest@demodocusign.roche.com>'+'\n';
                    fileContent +='To: '+recipient.Email+'\n';
                    
                    if(ccrecipient.Email == null){
                        fileContent +='CC: \n';  
                    }else{
                        fileContent +='CC: '+ccrecipient.Email+'\n';
                    }
                    
                    fileContent =fileContent.replace(')','').replace('(','');
                    fileContent +='Subject: '+Subject+'\n\n';
                    
                    
                    if(body != null){
                        fileContent += EncodingUtil.urlDecode(plainTextBody,'UTF-8');
                        //fileContent += EncodingUtil.base64Decode(base64Data);
                    } 

                    //fileContent+=EncodingUtil.urlDecode(email.htmlbody.stripHtmlTags(),'UTF-8');
                    
                    a.Body = Blob.valueOf(fileContent);  
                    a.Name = Subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                    
                    if(recipient.Email != null){
                        a.Description='Sent by ' +recipient.Email;
                    }else{                  
                        a.Description='test';
                        
                    }  
                    
                    insert a;                                
                }
                catch(Exception e){
                }
            system.debug('status'+es.EnvelopeID);

        } catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            envelopeId = 'Exception - ' + e;
        }
      
    }
}