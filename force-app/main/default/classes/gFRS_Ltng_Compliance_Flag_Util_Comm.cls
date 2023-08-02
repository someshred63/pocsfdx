public class gFRS_Ltng_Compliance_Flag_Util_Comm {
	@AuraEnabled
    public static void generatePDF(Id reqId,String compliancedocumentName)
    {
        gFRS_Ltng_Compliance_Flag__c compReq = [Select Id,Manual_Resolution__c,No_Undue_Influence_Clinical_Practices__c,gFRS_No_Undue_Influ_Clinical_Pract_Notes__c,
                                                gFRS_Organization_Reputation_Blacklist__c,gFRS_Org_Reputation_Blacklist_Notes__c,OrgType_Charitable_Foundation_of_a_Group__c,gFRS_Org_Type_Individual_or_Group_Notes__c,Organization_Type_Poltical_Sec__c,gFRRS_Org_Type_Political_Sectarian_Notes__c,Organization_Ownership_Individual_OR_Gr__c,Organization_Ownership_Ind_OR_Grp_Notes__c,No_Undue_Influence_General_Org_Support__c,No_Undue_Influence_General_Org_Support_N__c,Broad_Audience_Not_Open_To_Public__c,Broad_Audience_Not_Open_To_Public_Notes__c,
                                                OrgType_Other__c,OrgType_Other_Notes__c,Promotional_Material_Separated_from_CME__c,Promo_Material_Separated_from_CME_Notes__c,Reach_of_the_Event_Program__c,Reach_of_the_Event_Program_Notes__c,Organization_Type_Memberships__c,Organization_Type_Memberships_Notes__c,Organization_Type_Field_Exhibits__c,Organization_Type_Field_Exhibits_Notes__c,Funding_Purpose_Target_audience_not_HCPs__c,gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c,HCP_Audience_Mix_Learners_not_US_based__c,gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =:reqId LIMIT 1];
        gFRS_Ltng_Application__c request = [Select Id,Name,RecordType.Name,Organization__r.Name,Event_Program_Type__c,Event_Program_Title__c,FPO_Reviewer_Decision_Date__c,Business_Approver_Decision_Date__c,Final_Approver_Decision_Date__c FROM gFRS_Ltng_Application__c WHERE  Id =:reqId ];            
        String nullVal = '';
        //Date nullDate = ;
        String OrgName = request.Organization__r.Name;
        if(String.isBlank(OrgName)){	OrgName = nullVal;	}
        
        String PrgType = request.Event_Program_Type__c;
        if(String.isBlank(PrgType)){	PrgType = nullVal;	}
        
        String PrgTitle = request.Event_Program_Title__c;
        if(String.isBlank(PrgTitle)){	PrgTitle = nullVal;	}
        
        /*Date FPODate = request.FPO_Reviewer_Decision_Date__c;
        if(FPODate == 'null'){	FPODate = '';	}
        
		Date BADate = request.Business_Approver_Decision_Date__c;
        if(BADate == 'null'){	BADate = "";	}
        
        Date FADate = request.Final_Approver_Decision_Date__c;
        if(FADate == 'null'){	FADate = nullDate;	}*/
        
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
        
        String OrgTypeNotes = compReq.OrgType_Other_Notes__c;
        if(String.isBlank(OrgTypeNotes)){	OrgTypeNotes = nullVal;	}
        
        String FundingNotes = compReq.gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c;
        if(String.isBlank(FundingNotes)){	FundingNotes = nullVal;	}
        
        String EventNotes = compReq.Reach_of_the_Event_Program_Notes__c;
        if(String.isBlank(EventNotes)){	EventNotes = nullVal;	}
        
        String PromoNotes = compReq.Promo_Material_Separated_from_CME_Notes__c;
        if(String.isBlank(PromoNotes)){	PromoNotes = nullVal;	}
        
        String FENotes = compReq.Organization_Type_Field_Exhibits_Notes__c;
        if(String.isBlank(FENotes)){	FENotes = nullVal;	}
        
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
            '<span>HC Compliance Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.FPO_Reviewer_Decision_Date__c+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Decision Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Final_Approver_Decision_Date__c+'</span>'+
            '</P>';
      String FORM_HTML_BODY = '</div>'+
            '<BR/>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Compliance Flags</h1>'+
            '<BR/>'+
            '</div>'+
            '<div style="color:#000000;font-size: 12px;">'+
            '<table style="border: 1px solid #000000;">'+
          		'<tr style="border: 1px solid black;">'+
            	'<td style="width:150px; colspan="2";">'+fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel()+'</td>'+
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
            	'<td >'+fieldMap.get('Promotional_Material_Separated_from_CME__c').getDescribe().getLabel()+'</td>'+
                '<td >'+compReq.Promotional_Material_Separated_from_CME__c+'</td>'+
                '<td>'+PromoNotes+'</td>'+
                '</tr>';
        String FORM_HTML_Compliance='</table>'+
            '</div>'+
            '<DIV>';
        String FORM_HTML_END = '</BODY></HTML>';
        String pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY+FORM_HTML_Compliance+FORM_HTML_END;
        
        Attachment attach1= new Attachment();
        attach1.ParentId = reqId;
        attach1.Name = compliancedocumentName;
        attach1.Body = Blob.toPDF(pdfContent);//File content
        attach1.contentType = 'application/pdf';
        insert attach1;
        
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        if(compliancedocumentName.contains('Compliance')){
            gfrs.Compliance_Flags_PDF_ID__c = attach1.Id;
            gfrs.id = reqId;
            update gfrs;
        } else if(compliancedocumentName.contains('Decision')){
            gfrs.Decision_Flags_PDF_ID__c = attach1.Id;
            gfrs.id = reqId;
            update gfrs; 
        }        
    }
}