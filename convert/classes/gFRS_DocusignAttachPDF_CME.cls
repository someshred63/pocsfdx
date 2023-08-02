Public without sharing class gFRS_DocusignAttachPDF_CME {
    
    
    public static void InsertDocument(String mySourceId,string val){
        
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Owner_Full_Name__c,First_Name__c,Last_Name__c,Cara_Signature__c,gFRS_Joyce_Signature__c,Event_Program_Title__c,RecordType.Name,Organization__r.Organization_Name__c,Organization__r.City__c,Requested_Amount__c,Approved_Amount__c,Owner.Name
                                          ,Organization__r.Street__c,Organization__r.State__c,Organization__r.Zip_Code__c From gFRS_Ltng_Application__c
                                          Where Id=:mySourceId];
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlclst = [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Type__c,Multiple_payments_associated_with_Rqst__c,gFRS_Application__r.Name,Record_Type_Name__c,Funding_Total__c
                                                                FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:mySourceId and Auto_Process_Check__c=true LIMIT 1];
        
        list < LOAdocumentInfo__mdt > loaInfo = [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,
                                                 Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraphs__c  FROM LOAdocumentInfo__mdt where Label='LOA_CME' limit 1];
        //gFRS_Ltng_Program__c gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Funding_type__c From gFRS_Ltng_Program__c Where gFRS_Application__c=:mySourceId];
        List<gFRS_Ltng_Program__c> gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Funding_type__c From gFRS_Ltng_Program__c Where gFRS_Application__c=:mySourceId];
        Map<String, Schema.SObjectType> programMap = Schema.getGlobalDescribe();
        Schema.SObjectType prgSchema = programMap.get('gFRS_Ltng_Program__c');
        Map<String, Schema.SObjectField> prgMap = prgSchema.getDescribe().fields.getMap();
        
        String appAmount = '';
        if(val!='draftLOA'){
            if(gfrsApp.Approved_Amount__c != null){
                Decimal amount = gfrsApp.Approved_Amount__c;
                appAmount = amount.format().contains('.')?amount.format():(amount.format()+'.00');
            }
        }
        
        String paymentAmount = '';
        if(val!='draftLOA'){
            if(fundAlclst.Payment_Amounts__c != null){
                Decimal amount = fundAlclst.Payment_Amounts__c;
                paymentAmount = amount.format().contains('.')?amount.format():(amount.format()+'.00');
            }
        }
        
        String FName = '';
        String LName = '';
        if(string.isNotBlank(gfrsApp.First_Name__c)) {
            FName = gfrsApp.First_Name__c;
        }   
        if(string.isNotBlank(gfrsApp.Last_Name__c)) {
            LName = gfrsApp.Last_Name__c;
        }
        
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        
        String FORM_HTML_START = '<HTML><BODY>';
        String FORM_HTML_BODY_HEADER='<div>'+
            '<div>';
            //'<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech</h1>'+#FF0000
            if(val=='draftLOA'){
                FORM_HTML_BODY_HEADER +='<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight: bold; font-size: 30px;color: #FF0000; letter-spacing: -2px; float-right">DRAFT</span></h1>';
            }else{
                FORM_HTML_BODY_HEADER +='<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech</h1>';
            }
            FORM_HTML_BODY_HEADER +='<p style="color:#1e3e63; font-size:11px; letter-spacing: -0.5px;">A Member of the Roche Group</p>'+
            '</div>'+
            '<BR>'+
            '<div style="color:#1e3e63;">'+
            '<h4 style="text-align: center; color: #005A95;font-size: 14px; font-weight: bold;">Letter of Agreement ("LOA")</h4>'+
            '</div>'+
            '<BR>'+
            '<div>'+
            '<p style="color:#1e3e63;font-size: 12px;">This LOA will outline the Terms, Conditions and Purposes of the funding provided by Genentech, Inc. ("Genentech") to'+' '+gfrsApp.Organization__r.Organization_Name__c+' '+'("Recipient").</P>'+
            '<BR>';
        /*if(val=='draftLOA'){
FORM_HTML_BODY_HEADER=FORM_HTML_BODY_HEADER+'<p>'+gfrsApp.DraftLOA__c+'</p>'+'<BR>';
}*/
        //String FORM_HTML_DRAFT='<p>'+gfrsApp.DraftLOA__c+'</p>'+'<BR>';
        FORM_HTML_BODY_HEADER=FORM_HTML_BODY_HEADER+
            '<p style="color:#1e3e63;font-size: 12px;">'+
            '<span>Authorized Signer: </span><span>'+FName+' '+LName+'</span><br/>'+
            '<SPAN>Address:</SPAN><SPAN> '+gfrsApp.Organization__r.Street__c+'</span><br/>'+
            '<SPAN>City: </SPAN><SPAN>'+gfrsApp.Organization__r.City__c+'</span><br/>'+
            '<SPAN>State: </SPAN><SPAN>'+gfrsApp.Organization__r.State__c+'</span><br/>'+
            '<span>Zip Code: </SPAN><SPAN>'+gfrsApp.Organization__r.Zip_Code__c+'</span><br/>'+
            '</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+
            '<span>Funding Type: </span><span> '+gfrsApp.RecordType.Name+' </span><br/>'+
            '<span>Program / Event Title: </span><span> '+gfrsApp.Event_Program_Title__c+'(the "Activity")</span><br/>'+
            '<span>Request ID: </span><span> '+gfrsApp.Name +' </span><br/>'+
            //'<span>Program Start Date: </span><span> '+gfrsPrglst.gFRS_Start_Date__c +' </span><br/>'+
            //'<span>Program End Date: </span><span> '+gfrsPrglst.gFRS_End_Date__c +' </span><br/>'+
            '</P>'+
            '<BR>'+
            '<div style="color:#1e3e63;font-size: 12px;">'+
            '<table style="border: 1px solid #1e3e63;">'+
            '<tr style="border: 1px solid black;font-weight: bold;">'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('name').getDescribe().getLabel()+'</th>'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('gFRS_Program_Type__c').getDescribe().getLabel()+'</th>'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('gFRS_Start_Date__c').getDescribe().getLabel()+'</th>'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('gFRS_End_Date__c').getDescribe().getLabel()+'</th>'+
            '</tr>';
        String statedata;
        Integer i=1;
        String Start_Date ='';
        String End_Date ='';
        
        for(gFRS_Ltng_Program__c gfrsProgram:gfrsPrglst){
            if(gfrsProgram.gFRS_Start_Date__c != NULL){
                Start_Date = gfrsProgram.gFRS_Start_Date__c.format();
            }
            if(gfrsProgram.gFRS_End_Date__c != NULL){
                End_Date = gfrsProgram.gFRS_End_Date__c.format();
            }
            statedata=statedata+
                '<tr style="border: 1px solid black;">'+
                '<td>'+gfrsProgram.name+'</td>'+
                '<td>'+gfrsProgram.gFRS_Program_Type__c+'</td>'+
                '<td>'+Start_Date+'</td>'+
                '<td>'+End_Date+'</td>'+
                '</tr>';
            i=i+1;
        }
        
        FORM_HTML_BODY_HEADER=FORM_HTML_BODY_HEADER+statedata+'</table>'+
            '</div>';
        
        String FORM_HTML_BODY=
            '<div>'+
            '<BR>';
        if(val=='draftLOA'){
            FORM_HTML_BODY=FORM_HTML_BODY+
                '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide a grant for the above referenced Activity by means of funding in the amount (hereafter, the “Request Payment”).  By accepting the Request Payment, Recipient agrees to use the funds solely for the Activity '+
                'and to comply with the terms and conditions of this Letter of Agreement.</P>';
        }else{
            FORM_HTML_BODY=FORM_HTML_BODY+
                '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide a grant for the above referenced Activity by means of funding in the amount of $'+paymentAmount+' (hereafter, the “Request Payment”).  By accepting the Request Payment, Recipient agrees to use the funds solely for the Activity '+
                'and to comply with the terms and conditions of this Letter of Agreement.</P>';
        }
        FORM_HTML_BODY=FORM_HTML_BODY+'<BR>'+
            '</div>'+
            '<div>'+
            '<H4 style="color: #005A95; font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>I. </span> Independence</H4>'+'<BR>'+
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph1__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph2__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph3__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph4__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph5__c+'</P>'+
            '<BR>'+
            '</div>'+
            '<h4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>II. </span> Disclosures </h4>'+'<BR>'+
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph6__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph7__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph8__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph9__c+'</P>'+
            '<BR>'+
            '</div>'+
            
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>III. </span> Objectivity and Fair Balance</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph10__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph11__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph12__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph13__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph14__c+'</P>'+
            '<BR>'+
            '</div>'+
            
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>IV. </span> Acknowledgement of Support</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph15__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph16__c+'</P>'+
            '<BR>'+
            '</div>'+
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>V. </span> Reconciliation</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph25__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph26__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph27__c+'</P>'+
            '<BR>'+
            '</div>'+
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>VI. </span> Other</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph28__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph29__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph30__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph31__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph32__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph33__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph34__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph35__c+'</P>'+
            '<BR>'+
            '</div>'+
            '</li>'+
            '</ol>'+
            '</div>'+
            '</div>';
        
        if(val!='draftLOA'){            
            FORM_HTML_BODY=FORM_HTML_BODY+
                '<div>'+
                '<h4 style="color: #005A95;font-size: 14px; font-weight: bold;padding-bottom: 12px;">Approved:</h4>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">GENENTECH, INC.</p>'+'<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">By</p>'+'<BR>'+
                //'<p>'+gfrsApp.Cara_Signature__c+'</p>'+
                '<p>'+gfrsApp.gFRS_Joyce_Signature__c+'</p>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span>Joyce Martin</span></p>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Title: </span><span>Head Of Medical Affairs Compliance</span></p>'+
                //'<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: '+todaysDateStr+'</span><span> </span></p>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">I hereby acknowledge and agree with the terms and conditions set forth in this Agreement and represent and '+
                //'warrant that I have authority to sign on behalf of '+gfrsApp.Organization__r.Organization_Name__c+'("Recipient").</p>'+
                'warrant that I have authority to sign on behalf of Recipient.</p>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">By:</P>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span></span></p>'+
                //'<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: </span><span> </span></p>'+
                //'<p style="color:#1e3e63;font-size: 12px;"><span>IP Address: </span><span> </span></p>'+ 
                '</div>'+
                '</div>';
        }        
        String FORM_HTML_END = '</BODY></HTML>';
        String pdfContent =FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY+FORM_HTML_END;
        
        Attachment attachmentPDF = new Attachment(); 
        attachmentPDF.OwnerId = UserInfo.getUserId();
        attachmentPDF.parentId = mySourceId;
        attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
        
        if(val=='draftLOA'){
            attachmentPDF.Name ='Draft LOA' + '.pdf';
        }else{
            attachmentPDF.Name ='LOA' + '.pdf';  
        }
        
         //insert attachmentPDF;
        //insert attachmentPDF;
        
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
        
         //Delete attachmentPDF;
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        if(val=='draftLOA'){
            gfrs.Submitted_Draft_ID__c = conDocument;
            gfrs.Draft_LOA_Check__c=true;
        }else{
            gfrs.DocusignAttach_PDF_ID__c = conDocument;
        }
        
        gfrs.id = mySourceId;
        update gfrs;
        
    }
    
}