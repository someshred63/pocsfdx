public class gFRS_DocusignAttachPDF_Foundation {
    
    public static void InsertDocument(String mySourceId,string val){
        
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Owner_Full_Name__c,First_Name__c,Last_Name__c,Cara_Signature__c,Kristin_Signature__c,Event_Program_Title__c,RecordType.Name,Organization__r.Organization_Name__c,Organization__r.City__c,Requested_Amount__c,Approved_Amount__c,Owner.Name
                                          ,Email_Address__c,Multi_year_grant__c,Organization__r.Street__c,Organization__r.State__c,Organization__r.Zip_Code__c From gFRS_Ltng_Application__c
                                          Where Id=:mySourceId];
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlclst = [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Type__c,Multiple_payments_associated_with_Rqst__c,gFRS_Application__r.Name,Record_Type_Name__c,Funding_Total__c
                                                                FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:mySourceId and Auto_Process_Check__c=true LIMIT 1];
        
        list < LOAdocumentInfo__mdt > loaInfo = [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,
                                                 Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraphs__c  FROM LOAdocumentInfo__mdt where Label='LOA_Foundation' limit 1];
        //gFRS_Ltng_Program__c gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Focus_Area__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Funding_type__c From gFRS_Ltng_Program__c Where gFRS_Application__c='aKP3C0000004IK5WAM'];
        List<gFRS_Ltng_Program__c> gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Funding_type__c From gFRS_Ltng_Program__c Where gFRS_Application__c=:mySourceId];
        
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
        
        Map<String, Schema.SObjectType> programMap = Schema.getGlobalDescribe();
        Schema.SObjectType prgSchema = programMap.get('gFRS_Ltng_Program__c');
        Map<String, Schema.SObjectField> prgMap = prgSchema.getDescribe().fields.getMap();
        
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        
        String FORM_HTML_START = '<HTML><BODY>';
        String FORM_HTML_BODY_START='<div>'+
            '<div>';
            //'<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech</h1>'+
            if(val=='draftLOA'){
                FORM_HTML_BODY_START +='<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-weight: bold; font-size: 30px;color: #FF0000; letter-spacing: -2px; float-right">DRAFT</span></h1>';
            }else{
                FORM_HTML_BODY_START +='<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech</h1>';
            }
            FORM_HTML_BODY_START +='<p style="color:#005A95; font-size:11px; letter-spacing: -0.5px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FOUNDATION</p>'+
            '</div>'+
            '<BR>'+
            '<div style="color:#1e3e63;">'+
            '<h4 style="text-align: center; color: #005A95;font-size: 14px; font-weight: bold;">Grant Agreement ("Agreement")</h4>'+
            '</div>'+
            '<BR>'+
            '<div>'+
            '<p style="color:#1e3e63;font-size: 12px;">This is a legally binding grant agreement (“Agreement”), effective upon the Genentech Foundation’s receipt of this Agreement, electronically signed by the authorized representative of'+' '+gfrsApp.Organization__r.Organization_Name__c+'.</P>'+
            '<BR>';
        /*if(val=='draftLOA'){
            FORM_HTML_BODY_START=FORM_HTML_BODY_START+'<p>'+gfrsApp.DraftLOA__c+'</p>'+'<BR>';
        }*/
        FORM_HTML_BODY_START=FORM_HTML_BODY_START+
            '<p style="color:#1e3e63;font-size: 12px;">'+
            '<span>Authorized Signer: </span><span>'+FName+' '+LName+'</span><br/>'+
            '<SPAN>Address:</SPAN><SPAN> '+gfrsApp.Organization__r.Street__c+'</span><br/>'+
            '<SPAN>City: </SPAN><SPAN>'+gfrsApp.Organization__r.City__c+'</span><br/>'+
            '<SPAN>State: </SPAN><SPAN>'+gfrsApp.Organization__r.State__c+'</span><br/>'+
            '<span>Zip Code: </SPAN><SPAN>'+gfrsApp.Organization__r.Zip_Code__c+'</span><br/>'+
            '</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+
            '<span>Program / Event Title: </span><span> '+gfrsApp.Event_Program_Title__c+' </span><br/>'+
            '<span>Grant Request ID: </span><span> '+gfrsApp.Name +' </span><br/>'+
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
        FORM_HTML_BODY_START=FORM_HTML_BODY_START+statedata+'</table>'+
            '</div>';
        
        FORM_HTML_BODY_START=FORM_HTML_BODY_START+
            '<div>'+
            '<BR>';
        if(val=='draftLOA'){
            FORM_HTML_BODY_START=FORM_HTML_BODY_START+
            '<P style="color:#1e3e63;font-size: 12px;">The Genentech Foundation (the “Foundation”), with offices at 1 DNA Way M/S 49, South San Francisco, California, 94010, has approved a grant in the amount to '+gfrsApp.Organization__r.Organization_Name__c+'(“Grantee”). '+
            'This grant will support '+gfrsApp.Event_Program_Title__c+', per '+gfrsApp.Organization__r.Organization_Name__c+' budget breakdown submitted as an attachment to '+gfrsApp.Name+'.</P>';
        }else{
            FORM_HTML_BODY_START=FORM_HTML_BODY_START+
            '<P style="color:#1e3e63;font-size: 12px;">The Genentech Foundation (the “Foundation”), with offices at 1 DNA Way M/S 49, South San Francisco, California, 94010, has approved a grant in the amount of $'+appAmount+' to '+gfrsApp.Organization__r.Organization_Name__c+'(“Grantee”). '+
            'This grant will support '+gfrsApp.Event_Program_Title__c+', per '+gfrsApp.Organization__r.Organization_Name__c+' budget breakdown submitted as an attachment to '+gfrsApp.Name+'.</P>';
        }
        FORM_HTML_BODY_START=FORM_HTML_BODY_START+'<BR>'+
            '<h4 style="text-align: center; color: #005A95;font-size: 13px; font-weight: bold;">TERMS AND CONDITIONS</h4>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">1.Use of Funds. </span>Grantee shall use the grant funds only for the purposes of the specific project described above, on or before the Grant End Date. '+
            'Grantee shall repay to the Foundation any portion of the grant funds over $1,000 that is not spent or committed for these purposes on or prior to the Grant End Date. '+
            'Any significant changes in the purposes for which grant funds are spent or the budget breakdown referenced in this grant request '+gfrsApp.Name+' must be approved in writing by the Foundation before the funds are spent.</P>'+
            '<BR>'+
            '</div>';    
        
        String FORM_HTML_BODY_MY_NO='<div>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">2.Reporting. </span>'+loaInfo[0].Paragraph1__c+'</P>'+
            '</div>';
        String FORM_HTML_BODY_MY_YES='<div>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">2.Reporting. </span>'+loaInfo[0].Paragraph2__c+'</P>'+
            '</div>';
        String FORM_HTML_BODY_END='<div>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">3.Recordkeeping. </span>'+loaInfo[0].Paragraph3__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">4.Legal Proceedings. </span>'+loaInfo[0].Paragraph4__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">5.Discretion and Control. </span>'+loaInfo[0].Paragraph5__c+'</P>'+
            '<BR>'+            
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">6.Prohibited Uses. </span>'+loaInfo[0].Paragraph6__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a.  </span>'+loaInfo[0].Paragraph7__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b.  </span>'+loaInfo[0].Paragraph8__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c.  </span>'+loaInfo[0].Paragraph9__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">7.Grant Announcements. </span>'+loaInfo[0].Paragraph10__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">8.Representation and Warranty Regarding Tax Status. </span>'+loaInfo[0].Paragraph11__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">9.Notice. </span>'+loaInfo[0].Paragraph12__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph13__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">10.No Agency. </span>'+loaInfo[0].Paragraph14__c+'</P>'+
            '<BR>'+            
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">11.No Terrorist Activity. </span>'+loaInfo[0].Paragraph15__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">12.Knowing Assumption of Obligations. </span>'+loaInfo[0].Paragraph16__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">13.Indemnification. </span>'+loaInfo[0].Paragraph17__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">14.Remedies. </span>'+loaInfo[0].Paragraph18__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">15.Captions. </span>'+loaInfo[0].Paragraph19__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">16.Entire Agreement. </span>'+loaInfo[0].Paragraph20__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">17.Governing Law. </span>'+loaInfo[0].Paragraph21__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">18.Assignment. </span>'+loaInfo[0].Paragraph22__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">19.Severability. </span>'+loaInfo[0].Paragraph23__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">20.No Voter Registration Drive. </span>'+loaInfo[0].Paragraph24__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span style="color:#005A95; font-weight: bold;">21.Non-Discrimination. </span>'+loaInfo[0].Paragraph25__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph26__c+'</P>'+
            '<BR>'+
            '</div>'+

            '</li>'+
            '</ol>'+
            '</div>'+
            '</div>'+
            '<div>';
        if(val!='draftLOA'){
            FORM_HTML_BODY_END=FORM_HTML_BODY_END+
            '<h4 style="color: #005A95;font-size: 14px; font-weight: bold;padding-bottom: 12px;">Approved by:</h4>'+
            '<BR>'+
            '<p>'+gfrsApp.Kristin_Signature__c+'</p>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>Kristin Campbell Reed </span></p>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>Executive Director</span></p>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>Genentech Foundation</span></p>'+
            '<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: '+todaysDateStr+'</span><span> </span></p>'+
            '<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;">Accepted on behalf of Grantee By:</p>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span></span></p>'+'<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: </span><span> </span></p>'+'<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;"><span>IP Address: </span><span> </span></p>'+
            '</div>'+
            '</div>';
        }
        String FORM_HTML_END = '</BODY></HTML>';
        String pdfContent;
        if(gfrsApp.Multi_year_grant__c == 'Yes'){
            pdfContent=FORM_HTML_START+FORM_HTML_BODY_START+FORM_HTML_BODY_MY_YES+FORM_HTML_BODY_END+FORM_HTML_END;
        }else{
            pdfContent=FORM_HTML_START+FORM_HTML_BODY_START+FORM_HTML_BODY_MY_NO+FORM_HTML_BODY_END+FORM_HTML_END;
        }
        
        Attachment attachmentPDF = new Attachment(); 
        attachmentPDF.OwnerId = UserInfo.getUserId();
        attachmentPDF.parentId = mySourceId;
        if(val=='draftLOA'){
            attachmentPDF.Name ='Draft LOA' + '.pdf';
        }else{
            attachmentPDF.Name ='LOA' + '.pdf';  
        }
        attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
        insert attachmentPDF;
        
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