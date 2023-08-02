public class gFRS_DocusignAttachPDF {
  
    
    public static void InsertDocument(String mySourceId){
        try{
        gFRS_Ltng_Application__c gfrsApp=[Select Id,Name,Cara_Signature__c,Owner_Full_Name__c,Event_Program_Title__c,Organization__r.Organization_Name__c,Organization__r.City__c,Requested_Amount__c,Owner.Name
                                                         ,Organization__r.Street__c,Organization__r.Zip_Code__c From gFRS_Ltng_Application__c
                                           Where Id=: mySourceId];
        //List<gFRS_Ltng_Program__c> gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c From gFRS_Ltng_Program__c Where gFRS_Application__c='aKY4C0000007ukgWAA'];
        system.debug('Inside Class Line no 9'+gfrsApp);
         //system.debug('Inside Class Line no 10'+gfrsPrglst);
        String FORM_HTML_START = '<HTML><BODY>';
        String FORM_HTML_BODY='<div>'+
                                    '<div>'+
                                        '<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech</h1>'+
                                        '<p style="color:#1e3e63; font-size:11px; letter-spacing: -0.5px;">A Member of the Roche Group</p>'+
                                    '</div>'+
                                    '<BR>'+
                                    '<div style="color:#1e3e63;">'+
                                        '<h4 style="text-align: center; color: #005A95;font-size: 14px; font-weight: bold;">Letter of Agreement (LOA) for Exhibit Space</h4>'+
                                    '</div>'+
                                    '<BR>'+
                                    '<div>'+
                                        '<p style="color:#1e3e63;font-size: 12px;">Regarding Terms and Conditions of Payment for Exhibit Space between'+' '+gfrsApp.Organization__r.Organization_Name__c+' '+'("Recipient") and Genentech USA, Inc. ("Genentech").</P>'+
                                    '<BR>'+
                                    '</div>'+
            				'</div>';
            
            String FORM_HTML_END = '</BODY></HTML>';
            system.debug('HTML ENd');
            String pdfContent=FORM_HTML_START+FORM_HTML_BODY+FORM_HTML_END;
            Attachment attachmentPDF = new Attachment(); 
            attachmentPDF.OwnerId = UserInfo.getUserId();
            attachmentPDF.parentId = mySourceId;
            attachmentPDF.Name ='LOA' + '.pdf';
            attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
            insert attachmentPDF;
             system.debug('Attached PDF');
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attachmentPDF.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attachmentPDF.OwnerId;//Owner of the file
            cVersion.Title = attachmentPDF.Name;//Name of the file
            cVersion.VersionData = attachmentPDF.Body;//File content
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attachmentPDF.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
        
            Delete attachmentPDF;
            gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
            gfrs.DocusignAttach_PDF_ID__c = conDocument;
            gfrs.id = mySourceId;
            update gfrs;
        }catch(Exception e){
            system.debug(e.getmessage());
        }
 
    }

}