Public without sharing class gFRS_Ltng_createDraftLOAinternal{
    
   
    Public static void createLOAInternal(gFRS_Ltng_Application__c gfsrId){
        
        
        try{
         //System.debug('@@@ LOA -----'+gfsrId);
        
         gFRS_Ltng_Application__c gfrsApp=[Select Id,Name,Owner_Full_Name__c,First_Name__c,Last_Name__c,Cara_Signature__c,Event_Program_Title__c,RecordType.Name,Organization__r.Organization_Name__c,Organization__r.City__c,Requested_Amount__c,Owner.Name
                                          ,Approved_Amount__c,Email_Address__c,Organization__r.Street__c,Organization__r.State__c,Organization__r.Zip_Code__c,Record_Type__c,DraftLOA__c,
                                          Accountable_Employee_Role__c,Benefits_Exchanged_for_Internal_Funding__c,Authorized_Signer__r.Name
                                          From gFRS_Ltng_Application__c
                                           Where Id=:gfsrId.Id];
            
        //System.debug('@@@ Ater LOA -----'+gfrsApp);
        
        list < LOAdocumentInfo__mdt > loaInfo = [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,
                                                 Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,
                                                 Paragraph28__c,Paragraph29__c,Paragraph30__c,Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,
                                                 Paragraph35__c,Paragraphs__c  FROM LOAdocumentInfo__mdt where DeveloperName='Internal_Funding_Types' limit 1];
            
        List<gFRS_Ltng_Program__c> gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Funding_type__c,gFRS_Venue_City__c From gFRS_Ltng_Program__c Where gFRS_Application__c=:gfsrId.Id];
        
        Map<String, Schema.SObjectType> programMap = Schema.getGlobalDescribe();
        Schema.SObjectType prgSchema = programMap.get('gFRS_Ltng_Program__c');
        Map<String, Schema.SObjectField> prgMap = prgSchema.getDescribe().fields.getMap();
            
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        
        String FORM_HTML_START = '<HTML><BODY>';
        String FORM_HTML_BODY_HEADER='<div>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 30px;color: #005A95; letter-spacing: -2px;">Genentech</h1>'+
            '<p style="color:#1e3e63; font-size:11px; letter-spacing: -0.5px;">A Member of the Roche Group</p>'+
            '</div>'+
            '<BR>'+
            '<div style="color:#1e3e63;">'+
            '<h4 style="text-align: center; color: #005A95;font-size: 14px; font-weight: bold;">Letter of Agreement ("LOA")</h4>'+
            '</div>'+
            '<BR>'+
            '<div>'+
            '<p style="color:#1e3e63;font-size: 12px;">This LOA will outline the Terms, Conditions and Purposes of the funding provided by Genentech USA, Inc. ("Genentech") to '+' '+gfrsApp.Organization__r.Organization_Name__c+' '+'("Recipient").</P>'+
            '<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;">';

            FORM_HTML_BODY_HEADER = FORM_HTML_BODY_HEADER +
            '<p>'+gfrsApp.DraftLOA__c+'</p>'+
            '<SPAN>Address:</SPAN><SPAN> '+gfrsApp.Organization__r.Street__c+'</span><br/>'+
            '<SPAN>City: </SPAN><SPAN>'+gfrsApp.Organization__r.City__c+'</span><br/>'+
            '<SPAN>State: </SPAN><SPAN>'+gfrsApp.Organization__r.State__c+'</span><br/>'+
            '<span>Zip Code: </SPAN><SPAN>'+gfrsApp.Organization__r.Zip_Code__c+'</span><br/>'+
            '</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+
            '<span>Funding Type: </span><span> '+gfrsApp.Record_Type__c+' </span>'+'(“Funding Type”)'+'<br/>'+
            '<span>Program / Event /Membership Title: </span><span> '+gfrsApp.Event_Program_Title__c+' </span>'+'(the “Program”)'+'<br/>'+
            '<span>Request ID: </span><span> '+gfrsApp.Name +' </span><br/>'+

            //'<span>Program Start Date(s): </span><span> '+gfrsPrglst.gFRS_Start_Date__c.format() +' </span><br/>'+
            '</P>'+
            '</div>'+
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
            String FORM_HTML_BODY='<div>'+
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
            '<h4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>I. </span> Disclosures and Acknowledgement of Support </h4>'+'<BR>'+
            '<div>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph6__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph7__c+'</P>'+
                '<BR>'+
            '</div>'+
            
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>II. </span> Use of the Genentech Logo</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph8__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph9__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;"><span>A.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph10__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;"><span>B.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph11__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;"><span>C.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph12__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;"><span>D.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph13__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;"><span>E.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph14__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;"><span>F.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph15__c+'</P>'+
                '<BR>'+    
                '<P style="color:#1e3e63;font-size: 12px;"><span>G.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph16__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph17__c+'</P>'+
                '<BR>'+
            '</div>'+
                
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>III. </span> Other </H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph18__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph19__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph20__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph21__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph22__c+'</P>'+
                '<BR>'+
            '</div>'+
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>IV. </span> Payment</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph23__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph24__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph25__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph26__c+'</P>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph27__c+'</P>'+
                '<BR>'+
            '</div>'+
            '</li>'+
            '</ol>'+
            '</div>'+
            '<div>';
        
            if(gfrsApp.RecordType.Name == 'Field exhibits' || (gfrsApp.RecordType.Name == 'Commercial Sponsorship' && gfrsApp.Accountable_Employee_Role__c == 'Home Office' && gfrsApp.Benefits_Exchanged_for_Internal_Funding__c == 'Exhibit Only' && gfrsApp.Approved_Amount__c <= 25000) || (gFRSApp.RecordType.Name == 'Non-Commercial Sponsorship' && gFRSApp.Accountable_Employee_Role__c == 'Home Office' && gFRSApp.Benefits_Exchanged_for_Internal_Funding__c == 'Exhibit Only' && gFRSApp.Approved_Amount__c <= 25000)){
                // Nothing to do
                FORM_HTML_BODY_HEADER = FORM_HTML_BODY_HEADER +
                    '<div>'+
                    '<BR>'+
                    '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide funding in the amount of $'+gfrsApp.Requested_Amount__c+' (hereafter, the “Request Payment”) for the Funding Type related to the above referenced Program.'+
                    'By accepting the Request Payment, Recipient certifies and agrees to comply with the terms and conditions of this LOA.</P>'+
                    '<BR>'+
                    '</div>';
            } else {
                FORM_HTML_BODY_HEADER = FORM_HTML_BODY_HEADER +
                    '<div>'+
                    '<BR>'+
                    '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide funding in the amount of $'+gfrsApp.Requested_Amount__c+' (hereafter, the “Request Payment”) for the Funding Type related to the above referenced Program.'+
                    'By accepting the Request Payment, Recipient agrees to use the funds solely in connection with the above Program and to comply with the terms and conditions of this LOA.</P>'+
                    '<BR>'+
                    '</div>';
                FORM_HTML_BODY = FORM_HTML_BODY +
                    '<h4 style="color: #005A95;font-size: 14px; font-weight: bold;padding-bottom: 12px;">Approved:</h4>'+
                    '<BR>'+
                    '<p style="color:#1e3e63;font-size: 12px;">GENENTECH USA, INC.</p>'+'<BR>'+
                    '<p style="color:#1e3e63;font-size: 12px;">By</p>'+'<BR>'+
                    '<p>'+gfrsApp.Cara_Signature__c+'</p>'+
                    '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span>Cara Pellegrini </span></p>'+
                    '<p style="color:#1e3e63;font-size: 12px;"><span>Title: </span><span>VP, Experience Operations</span></p>'+
                    '<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: '+todaysDateStr+'</span><span> </span></p>'+
                    '<BR>'+
                    '<p style="color:#1e3e63;font-size: 12px;">I hereby acknowledge and agree with the terms and conditions set forth in this Agreement and represent and '+
                    'warrant that I have authority to sign on behalf of '+gfrsApp.Organization__r.Organization_Name__c+'("Recipient").</p>'+
                    '<BR>'+
                    '<p style="color:#1e3e63;font-size: 12px;">By:</P>'+
                    '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span></span></p>'+
                    '<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: </span><span> </span></p>'+
                    //'<p style="color:#1e3e63;font-size: 12px;"><span>IP Address: </span><span> </span></p>'+
                    '</div>'+
                    '</div>';
            }
            
            String FORM_HTML_END = '</BODY></HTML>';
            
            String pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY+FORM_HTML_END;
            Attachment attachmentPDF = new Attachment(); 
            attachmentPDF.OwnerId = UserInfo.getUserId();
            attachmentPDF.parentId = gfsrId.Id;
            attachmentPDF.Name ='Draft LOA' + '.pdf';
            attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
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
            gfrs.Submitted_Draft_ID__c = conDocument;
            gfrs.Draft_LOA_Check__c=true;
            gfrs.id = gfsrId.Id;
            update gfrs;
       }
       catch(Exception e){
            system.debug('@@ Exception ::'+e.getMessage()+e.getLineNumber());
        }    
    }
    
}