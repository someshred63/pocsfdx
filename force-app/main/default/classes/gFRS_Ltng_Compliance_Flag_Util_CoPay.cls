public class gFRS_Ltng_Compliance_Flag_Util_CoPay {
    @AuraEnabled
    public static void generatePDF(Id reqId,String compliancedocumentName)
    {	
        gFRS_Ltng_CAF_Application__c CAFRequest = [Select Id,Name,Record_Type__c,gFRS_Organization__r.name,gFRS_Organization__r.Organization_Name__c,Estimated_Current_Revenue__c,
                                                   Compliance_Reviewer_Decision_Date__c,Finance_Approver_Decision_Date__c,Decision_Date__c,Acknowledge_Current_Revenue_33__c,Manual_Resolution__c,
                                                   No_Undue_Influence_Clinical_Practices__c,No_Undue_Influence_Clinical_Pract_Notes__c,
                                                   Organization_Reputation_Blacklist__c,Org_Reputation_Blacklist_Notes__c,
                                                   OrgType_Charitable_Foundation_of_a_Group__c,OrgType_Charitable_Foundation_Notes__c,
                                                   Organization_Type_Poltical_Sec__c,Org_Type_Political_Sectarian_Notes__c,
                                                   Application_Acknowledgment__c,Application_Acknowledgment_Notes__c,
                                                   Organization_Tax_Status__c,Organization_Tax_Status_Notes__c,
                                                   Organization_Favorable_OIG_Opinion_Notes__c,Donation_Requested_for_Quarter__c
                                                   FROM gFRS_Ltng_CAF_Application__c WHERE  Id =:reqId ];            
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Ltng_CAF_Application__c');
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
        String nullVal = '';
        
        //Decimal FiscalRev = CAFRequest.Estimated_Current_Revenue__c;
        //if(FiscalRev == 0){	FiscalRev = 0;	}
        
        if(CAFRequest.Estimated_Current_Revenue__c > 33){
            CAFRequest.Acknowledge_Current_Revenue_33__c = true;        
        }
        
        String FundTypeName = CAFRequest.Record_Type__c;
        if(String.isBlank(FundTypeName)){	FundTypeName = nullVal;	}
        
        String OrgName = CAFRequest.gFRS_Organization__r.Organization_Name__c;
        if(String.isBlank(OrgName)){	OrgName = nullVal;	}
        
        Date FPORewDate = CAFRequest.Compliance_Reviewer_Decision_Date__c;
        String FPODate = FPORewDate.format();
        
        /*
Date FPORewDate = CAFRequest.Compliance_Reviewer_Decision_Date__c;
if(FPORewDate != 'null'){        String FPODate = FPORewDate.format();	}

Date BADate = request.Business_Approver_Decision_Date__c;
if(BADate == 'null'){	BADate = "";	}*/
        String FADate = '';
        if(compliancedocumentName.contains('Compliance Flags Snapshot')){
            Date FADecDate = CAFRequest.Decision_Date__c;        
            //if(FADecDate == Date.today()){
            FADate = FADecDate.format();
            //}
        }
        String ClinicalNotes = CAFRequest.No_Undue_Influence_Clinical_Pract_Notes__c;
        if(String.isBlank(ClinicalNotes)){	ClinicalNotes = nullVal;	}
        
        String BlacklistNotes = CAFRequest.Org_Reputation_Blacklist_Notes__c;
        if(String.isBlank(BlacklistNotes)){	BlacklistNotes = nullVal;	}
        
        String CharitableNotes = CAFRequest.OrgType_Charitable_Foundation_Notes__c;
        if(String.isBlank(CharitableNotes)){	CharitableNotes = nullVal;	}
        
        String PoliticalNotes = CAFRequest.Org_Type_Political_Sectarian_Notes__c;
        if(String.isBlank(PoliticalNotes)){	PoliticalNotes = nullVal;	}
        
        String AckNotes = CAFRequest.Application_Acknowledgment_Notes__c;
        if(String.isBlank(AckNotes)){	AckNotes = nullVal;	}
        
        /*String OIGNotes = CAFRequest.Organization_Favorable_OIG_Opinion_Notes__c;
if(String.isBlank(OIGNotes)){	OIGNotes = nullVal;	}*/
        String No_Undue_Label =System.Label.gFRS_CAF_Flag_No_Undue_Influence;
        String Restricted_Label =System.Label.gFRS_CAF_Flag_Restricted_List;
        String Charitable_Label =System.Label.gFRS_CAF_Flag_Charitable_Foundation;
        String PoliticalSec_Label =System.Label.gFRS_CAF_Flag_Political_Sectarian;
        
        String TaxNotes = CAFRequest.Organization_Tax_Status_Notes__c;
        if(String.isBlank(TaxNotes)){	TaxNotes = nullVal;	}
        
        //String documentName = 'Compliance_Flags_Test';
        String FORM_HTML_START = '<HTML>'+'<BODY>';
        String FORM_HTML_BODY_HEADER='<DIV>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 30px;color: #005A95;font-family:sans-serif">Genentech</h1>'+
            '<p style="color:#1e3e63; font-size:11px; letter-spacing: -0.5px;font-style: italic;font-family:sans-serif">A Member of the Roche Group</p>'+
            '</div>'+
            '<BR/>'+
            '<div>'+
            '<P>'+
            '<span>Request ID: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Name+'</span><br/>'+
            '</P>'+
            '<P>'+
            '<span>Funding Type Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+FundTypeName+'</span><br/>'+
            '</P>'+
            '<p>'+
            '<span>Organization Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+OrgName+'</span>'+
            '</p>'+
            '<P>'+
            '<span>Estimated Current Revenue %: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Estimated_Current_Revenue__c+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Donation Requested for Quarter: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Donation_Requested_for_Quarter__c+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Compliance Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+FPODate+'</span>'+
            '</P>';
        //String FORM_HTML_BODY_Decision = 
        if(compliancedocumentName.contains('Compliance Flags Snapshot')){
            FORM_HTML_BODY_HEADER += '<P>'+
                '<span>Decision Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+FADate+'</span>'+
                '</P>'+
                '<P>'+
                '<span>Acknowledge Current Revenue % > 33%: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Acknowledge_Current_Revenue_33__c+'</span>'+
                '</P>';
        }
        String FORM_HTML_BODY_END = '<P>'+
            '<span>Manual Resolution: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Manual_Resolution__c+'</span>'+
            '</P>';
        String FORM_HTML_COMPLIANCE_START = '</div>'+
            '<BR/>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Compliance Flags</h1>'+
            '<BR/>'+
            '</div>'+
            '<div style="color:#000000;font-size: 12px;">'+
            '<table style="border: 1px solid #000000;">'+
            '<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+No_Undue_Label+'</td>'+
            '<td style="width:10px;">'+CAFRequest.No_Undue_Influence_Clinical_Practices__c+'</td>'+
            '<td>'+ClinicalNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+Restricted_Label+'</td>'+
            '<td style="width:10px;">'+CAFRequest.Organization_Reputation_Blacklist__c+'</td>'+
            '<td>'+BlacklistNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+Charitable_Label+'</td>'+
            //'<td style="width:150px;">'+fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel()+'</td>'+
            '<td style="width:10px;">'+CAFRequest.OrgType_Charitable_Foundation_of_a_Group__c+'</td>'+
            '<td>'+CharitableNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+PoliticalSec_Label+'</td>'+
            '<td style="width:10px;">'+CAFRequest.Organization_Type_Poltical_Sec__c+'</td>'+
            '<td>'+PoliticalNotes+'</td>'+
            '</tr>';
        String FORM_HTML_Compliance1='<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+fieldMap.get('Application_Acknowledgment__c').getDescribe().getLabel()+'</td>'+
            '<td style="width:10px;">'+CAFRequest.Application_Acknowledgment__c+'</td>'+
            '<td>'+AckNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+fieldMap.get('Organization_Tax_Status__c').getDescribe().getLabel()+'</td>'+
            '<td style="width:10px;">'+CAFRequest.Organization_Tax_Status__c+'</td>'+
            '<td>'+TaxNotes+'</td>'+
            '</tr>';
        String FORM_HTML_Compliance='</table>'+
            '</div>'+
            '<DIV>';
        String FORM_HTML_END = '</BODY></HTML>';
        String pdfContent;
        //if(CAFRequest.Finance_Approver_Decision_Date__c == Date.today()){
        /*if(compliancedocumentName.contains('Decision')){
pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY_Decision+FORM_HTML_BODY_END+FORM_HTML_COMPLIANCE_START+FORM_HTML_Compliance1+FORM_HTML_Compliance+FORM_HTML_END;
}else{*/
        pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY_END+FORM_HTML_COMPLIANCE_START+FORM_HTML_Compliance1+FORM_HTML_Compliance+FORM_HTML_END;
        //}
        /*Attachment attach1= new Attachment();
        attach1.ParentId = reqId;
        attach1.Name = compliancedocumentName;
        attach1.Body = Blob.toPDF(pdfContent);//File content
        attach1.contentType = 'application/pdf';
        insert attach1;*/
        
        Attachment attach1= new Attachment();
        attach1.ParentId = reqId;
        attach1.Name = compliancedocumentName+'.pdf';
        attach1.OwnerId=UserInfo.getUserId();
        attach1.Body = Blob.toPDF(pdfContent);//File content
        attach1.contentType = 'application/pdf';
        //insert attach1;
        
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = attach1.Name;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = attach1.OwnerId;//Owner of the file
        cVersion.Title = attach1.Name;//Name of the file
        cVersion.VersionData = attach1.Body;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = attach1.ParentId;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
       // Delete attach1;
        
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        if(compliancedocumentName.contains('Compliance')){
            gfrs.Compliance_Flag_PDF_ID__c =conDocument;
            gfrs.id = reqId;
            update gfrs;
        } else if(compliancedocumentName.contains('Compliance Flags Snapshot')){
            gfrs.Decision_Flag_PDF_ID__c =conDocument;
            gfrs.id = reqId;
            update gfrs; 
        }
    }
}