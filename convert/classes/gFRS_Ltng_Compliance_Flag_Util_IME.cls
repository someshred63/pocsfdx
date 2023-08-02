public class gFRS_Ltng_Compliance_Flag_Util_IME {
    @AuraEnabled
    public static void generatePDF(Id reqId,String compliancedocumentName)
    {
        gFRS_Ltng_Compliance_Flag__c compReq = [Select Id,Manual_Resolution__c,HCP_Audience_Mix_Learners_not_US__c,gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c,Organization_Tax_Status__c,Organization_Tax_Status_Notes__c,No_Undue_Influence_Clinical_Practices__c,gFRS_No_Undue_Influ_Clinical_Pract_Notes__c, 
                                                gFRS_Organization_Reputation_Blacklist__c,gFRS_Org_Reputation_Blacklist_Notes__c,OrgType_Charitable_Foundation_of_a_Group__c,gFRS_Org_Type_Individual_or_Group_Notes__c,Organization_Type_Poltical_Sec__c,gFRRS_Org_Type_Political_Sectarian_Notes__c,Organization_Ownership_Individual_OR_Gr__c,Organization_Ownership_Ind_OR_Grp_Notes__c,No_Undue_Influence_General_Org_Support__c,No_Undue_Influence_General_Org_Support_N__c,Broad_Audience_Not_Open_To_Public__c,Broad_Audience_Not_Open_To_Public_Notes__c,
                                                OrgType_Other__c,OrgType_Other_Notes__c,Promotional_Material_Separated_from_CME__c,Promo_Material_Separated_from_CME_Notes__c,Reach_of_the_Event_Program__c,Reach_of_the_Event_Program_Notes__c,Organization_Type_Memberships__c,Organization_Type_Memberships_Notes__c,Organization_Type_Field_Exhibits__c,Organization_Type_Field_Exhibits_Notes__c,Funding_Purpose_Target_audience_not_HCPs__c,gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c,HCP_Audience_Mix_Learners_not_US_based__c from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =:reqId LIMIT 1];
        gFRS_Ltng_Application__c request = [ Select Id,Name,RecordType.Name,Organization__r.Name,X33_Limit_Percentage__c,Acknowledge_33_Exceeded__c,Event_Program_Type__c,Event_Program_Title__c,FPO_Reviewer_Decision_Date__c,Business_Approver_Decision_Date__c,Final_Approver_Decision_Date__c,Decision_Date__c FROM gFRS_Ltng_Application__c WHERE  Id =:reqId ];            
        String nullVal = '';
        //Date nullDate = ;
        String OrgName = request.Organization__r.Name;
        if(String.isBlank(OrgName)){	OrgName = nullVal;	}
        
        String PrgType = request.Event_Program_Type__c;
        if(String.isBlank(PrgType)){	PrgType = nullVal;	}
        
        String PrgTitle = request.Event_Program_Title__c;
        if(String.isBlank(PrgTitle)){	PrgTitle = nullVal;	}
        
        Date FPORewDate = request.FPO_Reviewer_Decision_Date__c;
        String FPODate = FPORewDate.format();
        
        /*Date BADate = request.Business_Approver_Decision_Date__c;
		if(BADate == 'null'){	BADate = "";	}*/
        
        /*if(request.Final_Approver_Decision_Date__c == Date.today()){
            Date FADecDate = request.Final_Approver_Decision_Date__c;
            FADate = FADecDate.format();
        }*/
        
        /*String FADate = '';
        if(compliancedocumentName.contains('Decision')){
            Date FADecDate = request.Decision_Date__c ;
            FADate = FADecDate.format();
        }*/
        
        String FundingNotes = compReq.gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c;
        if(String.isBlank(FundingNotes)){	FundingNotes = nullVal;	}
        
        String AudienceNotes = compReq.gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c;
        if(String.isBlank(AudienceNotes)){	AudienceNotes = nullVal;	}
        
        String ClinicalNotes = compReq.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c;
        if(String.isBlank(ClinicalNotes)){	ClinicalNotes = nullVal;	}
        
        String BlacklistNotes = compReq.gFRS_Org_Reputation_Blacklist_Notes__c;
        if(String.isBlank(BlacklistNotes)){	BlacklistNotes = nullVal;	}
        
        String CharitableNotes = compReq.gFRS_Org_Type_Individual_or_Group_Notes__c;
        if(String.isBlank(CharitableNotes)){	CharitableNotes = nullVal;	}
        
        String PoliticalNotes = compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c;
        if(String.isBlank(PoliticalNotes)){	PoliticalNotes = nullVal;	}
        
        String OwnershipNotes = compReq.Organization_Ownership_Ind_OR_Grp_Notes__c;
        if(String.isBlank(OwnershipNotes)){	OwnershipNotes = nullVal;	}
        
        String TaxNotes = compReq.Organization_Tax_Status_Notes__c;
        if(String.isBlank(TaxNotes)){	TaxNotes = nullVal;	}
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Ltng_Compliance_Flag__c');
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
        
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
            '<span>Request ID: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>' +request.Name+'</span><br/>'+
            '</P>'+
            '<P>'+
            '<span>Funding Type Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.RecordType.Name+'</span><br/>'+
            '</P>'+
            '<p>'+
            '<span>Organization Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+OrgName+'</span>'+
            '</p>'+
            '<P>'+
            '<span>Event / Program Type: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+PrgType+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Event / Program Title: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+PrgTitle+'</span>'+
            '</P>'+
            '<P>'+
            '<span>HC Compliance Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.FPO_Reviewer_Decision_Date__c.format()+'</span>'+
            '</P>';
        if(compliancedocumentName.contains('Decision')){
                FORM_HTML_BODY_HEADER +=
                    '<P>'+
                    '<span>33 Limit Percentage: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.X33_Limit_Percentage__c+'</span>'+
                    '</P>'+
                    '<P>'+
                    '<span>Decision Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Decision_Date__c.format()+'</span>'+
                    '</P>';
            }
        /*String FORM_HTML_BODY_Decision = '<P>'+
            '<span>Decision Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Decision_Date__c.format()+'</span>'+
            '</P>';*/
        String FORM_HTML_BODY = '</div>'+
            '<BR/>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Compliance Flags</h1>'+
            '<BR/>'+
            '</div>'+
            '<div style="color:#000000;font-size: 12px;">'+
            '<table style="border: 1px solid #000000;">'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('Funding_Purpose_Target_audience_not_HCPs__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.Funding_Purpose_Target_audience_not_HCPs__c+'</td>'+
            '<td>'+FundingNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('HCP_Audience_Mix_Learners_not_US__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.HCP_Audience_Mix_Learners_not_US__c+'</td>'+
            '<td>'+AudienceNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td style="width:150px;">'+fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel()+'</td>'+
            '<td style="width:10px;">'+compReq.No_Undue_Influence_Clinical_Practices__c+'</td>'+
            '<td>'+ClinicalNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.gFRS_Organization_Reputation_Blacklist__c+'</td>'+
            '<td>'+BlacklistNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.OrgType_Charitable_Foundation_of_a_Group__c+'</td>'+
            '<td>'+CharitableNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.Organization_Type_Poltical_Sec__c+'</td>'+
            '<td>'+PoliticalNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.Organization_Ownership_Individual_OR_Gr__c+'</td>'+
            '<td>'+OwnershipNotes+'</td>'+
            '</tr>'+
            '<tr style="border: 1px solid black;">'+
            '<td >'+fieldMap.get('Organization_Tax_Status__c').getDescribe().getLabel()+'</td>'+
            '<td >'+compReq.Organization_Tax_Status__c+'</td>'+
            '<td>'+TaxNotes+'</td>'+
            '</tr>';
        String FORM_HTML_Compliance='</table>'+
            '</div>'+
            '<DIV>';
        String FORM_HTML_END = '</BODY></HTML>';
        String pdfContent;
        //if(request.Decision_Date__c  == Date.today()){
        /*if(compliancedocumentName.contains('Decision')){    
            pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY_Decision+FORM_HTML_BODY+FORM_HTML_Compliance+FORM_HTML_END;
        }else{*/
            pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY+FORM_HTML_Compliance+FORM_HTML_END;

        Attachment attach1= new Attachment();
        attach1.ParentId = reqId;
        attach1.OwnerId=UserInfo.getUserId();
        attach1.Name = compliancedocumentName+'.pdf';
        attach1.Body = Blob.toPDF(pdfContent);//File content
        attach1.contentType = 'application/pdf';
        insert attach1;
        
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
        
        Delete attach1;
        
        
        
        
        
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        if(compliancedocumentName.contains('Compliance')){
            gfrs.Compliance_Flags_PDF_ID__c =conDocument;
            gfrs.id = reqId;
            update gfrs;
        } else if(compliancedocumentName.contains('Decision')){
            gfrs.Decision_Flags_PDF_ID__c =conDocument;
            gfrs.id = reqId;
            update gfrs; 
        }  
    }
}