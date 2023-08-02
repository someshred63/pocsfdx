public class Summary_Snapshot_Flag_PDF_CoPay {
    
	@AuraEnabled
    public static void generatePDF(Id reqId,String compliancedocumentName)
    {	
        gFRS_Ltng_CAF_Application__c CAFRequest = [Select Id,Name,Record_Type__c,Summary_Snapshot_PDF_ID__c,gFRS_Organization__r.name,gFRS_Organization__r.Organization_Name__c,
                                                   Estimated_Current_Revenue__c,Donation_Requested_for_Quarter__c,Total_Payment_Amount_Rollup__c,Total_Apprv_Amount__c,
                                                   Compliance_Reviewer_Decision_Date__c,Finance_Approver_Decision_Date__c,Acknowledge_Current_Revenue_33__c,Manual_Resolution__c,
                                                   Grant_Reviewer__r.Name,Grant_Approver__r.Name,Finance_Approver__r.Name,VP_Approver__r.Name,CFO_Approver__r.Name,
                                                   No_Undue_Influence_Clinical_Practices__c,No_Undue_Influence_Clinical_Pract_Notes__c,
                                                   Organization_Reputation_Blacklist__c,Org_Reputation_Blacklist_Notes__c,
                                                   OrgType_Charitable_Foundation_of_a_Group__c,OrgType_Charitable_Foundation_Notes__c,
                                                   Organization_Type_Poltical_Sec__c,Org_Type_Political_Sectarian_Notes__c,
                                                   Application_Acknowledgment__c,Application_Acknowledgment_Notes__c,
                                                   Organization_Tax_Status__c,Organization_Tax_Status_Notes__c,
                                                   (Select Disease_Fund_Name__c, Payment_Amount__c, Requested_Donation_Amount__c, Approved__c from gFRS_CAF_Disease_State__r ) 
                                           		   	FROM gFRS_Ltng_CAF_Application__c WHERE  Id =:reqId ];     
        //gFRS_CAF_Disease_State__c StateReq = [Select Disease_Fund_Name__c, Payment_Amount__c, Requested_Donation_Amount__c, Approved__c from gFRS_CAF_Disease_State__c WHERE  Id =:reqId ];     
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Ltng_CAF_Application__c');
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
        
        Map<String, Schema.SObjectType> dstateMap = Schema.getGlobalDescribe();
        Schema.SObjectType stateSchema = dstateMap.get('gFRS_CAF_Disease_State__c');
        Map<String, Schema.SObjectField> stateMap = stateSchema.getDescribe().fields.getMap();
        
        Integer currentYear = System.Today().year();
        
        Decimal appAmt = CAFRequest.Total_Apprv_Amount__c;
        String approvedAmt = appAmt.format();
        
        Decimal payAmt = CAFRequest.Total_Payment_Amount_Rollup__c;
        String paymentAmt = payAmt.format();
        
        String nullVal = '';
		
        //Decimal FiscalRev = CAFRequest.Estimated_Current_Revenue__c;
        //if(FiscalRev == 0){	FiscalRev = 0;	}
        
        String OrgID = CAFRequest.gFRS_Organization__r.name;
        if(String.isBlank(OrgID)){	OrgID = nullVal;	}
        
        String FundTypeName = CAFRequest.Record_Type__c;
        if(String.isBlank(FundTypeName)){	FundTypeName = nullVal;	}
        
        String OrgName = CAFRequest.gFRS_Organization__r.Organization_Name__c;
        if(String.isBlank(OrgName)){	OrgName = nullVal;	}
        
        String Donation = CAFRequest.Donation_Requested_for_Quarter__c;
        if(String.isBlank(Donation)){	Donation = nullVal;	}
        
        //Decimal Payment = CAFRequest.Total_Payment_Amount__c;
        //if(Payment == 0){		}
        
        //Date FPORewDate = CAFRequest.Compliance_Reviewer_Decision_Date__c;
        //String FPODate = FPORewDate.format();

		/*
        Date FPORewDate = CAFRequest.Compliance_Reviewer_Decision_Date__c;
        if(FPORewDate != 'null'){        String FPODate = FPORewDate.format();	}

		Date BADate = request.Business_Approver_Decision_Date__c;
        if(BADate == 'null'){	BADate = "";	}*/
		String FADate = '';
        Date FADecDate = CAFRequest.Finance_Approver_Decision_Date__c;        
        if(FADecDate == Date.today()){
            FADate = FADecDate.format();
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
        
        String TaxNotes = CAFRequest.Organization_Tax_Status_Notes__c;
        if(String.isBlank(TaxNotes)){	TaxNotes = nullVal;	}
        
        String No_Undue_Label =System.Label.gFRS_CAF_Flag_No_Undue_Influence;
        String Restricted_Label =System.Label.gFRS_CAF_Flag_Restricted_List;
        String Charitable_Label =System.Label.gFRS_CAF_Flag_Charitable_Foundation;
        String PoliticalSec_Label =System.Label.gFRS_CAF_Flag_Political_Sectarian;
        
        List<gFRS_CAF_Disease_State__c> diseaseStateList = new List<gFRS_CAF_Disease_State__c>();
        double Requested_Donation_Amount = 0.0;
        double Approved_Amount = 0.0;
        double Payment_Amount = 0.0;
        for(gFRS_CAF_Disease_State__c ds : CAFRequest.gFRS_CAF_Disease_State__r){
            diseaseStateList.add(ds);
            
            if(ds.Requested_Donation_Amount__c!= null){
                Requested_Donation_Amount = Requested_Donation_Amount + ds.Requested_Donation_Amount__c;
            }
            
            if(ds.Approved__c!= null){
                Approved_Amount = Approved_Amount + ds.Approved__c;
            }
            
            if(ds.Payment_Amount__c!= null){
                Payment_Amount = Payment_Amount + ds.Payment_Amount__c;
            }
           
        }
        gFRS_CAF_Disease_State__c sumDS = new gFRS_CAF_Disease_State__c(Disease_Fund_Name__c = 'Total ', Requested_Donation_Amount__c = Requested_Donation_Amount, Approved__c = Approved_Amount, Payment_Amount__c = Payment_Amount);
        diseaseStateList.add(sumDS);
        
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
            '<span>'+fieldMap.get('Name').getDescribe().getLabel()+': &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Name+'</span><br/>'+
            '</P>'+
            '<P>'+
            '<span>Funding Type Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+FundTypeName+'</span><br/>'+
            '</P>'+
            '<P>'+
            '<span>Organization ID: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+OrgID+'</span><br/>'+
            '</P>'+
            '<p>'+
            '<span>Organization Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+OrgName+'</span>'+
            '</p>'+
            '<P>'+
            '<span>Donation Requested for Quarter: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+Donation+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Year: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+currentYear+'</span><br/>'+
            '</P>'+
            '<P>'+
            '<span>'+fieldMap.get('Total_Apprv_Amount__c').getDescribe().getLabel()+': &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+approvedAmt+'</span>'+
            '</P>'+
            '<P>'+
            '<span>'+fieldMap.get('Total_Payment_Amount_Rollup__c').getDescribe().getLabel()+': &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+paymentAmt+'</span>'+
            '</P>'+
            '<P>'+
            '<span>'+fieldMap.get('Estimated_Current_Revenue__c').getDescribe().getLabel()+': &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Estimated_Current_Revenue__c+'</span>'+
            '</P>'+
        	'<P>'+
            '<span>Acknowledge Current Revenue % > 33%: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Acknowledge_Current_Revenue_33__c+'</span>'+
            //'</P>'+
          	//'<P>'+
            //'<span>Manual Resolution: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+CAFRequest.Manual_Resolution__c+'</span>'+
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
            '</div>';
        String FORM_HTML_Approvers_START='<BR/>'+
            '<BR/>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Approvers List</h1>'+
            '</div>'+
            '<BR/>'+
            '<div style="color:#000000;font-size: 12px;">'+
            '<table style="border: 1px solid #000000;">'+
            	'<tr style="border: 1px solid black;font-weight: bold;">'+
            		'<th style="border: 1px solid #000000;">Role</th>'+
                	'<th style="border: 1px solid #000000;">Assigned Approver Name</th>'+
          		'</tr>'+
            	'<tr style="border: 1px solid black;">'+
            		'<td font-weight: bold;>'+fieldMap.get('Grant_Reviewer__c').getDescribe().getLabel()+'</td>'+
                	'<td>'+CAFRequest.Grant_Reviewer__r.Name+'</td>'+
          		'</tr>'+
            	'<tr style="border: 1px solid black;">'+
            		'<td font-weight: bold;>'+fieldMap.get('Grant_Approver__c').getDescribe().getLabel()+'</td>'+
                	'<td>'+CAFRequest.Grant_Approver__r.Name+'</td>'+
          		'</tr>'+
            	'<tr style="border: 1px solid black;">'+
            		'<td font-weight: bold;>'+fieldMap.get('Finance_Approver__c').getDescribe().getLabel()+'</td>'+
                	'<td>'+CAFRequest.Finance_Approver__r.Name+'</td>'+
          		'</tr>'+
            	'<tr style="border: 1px solid black;">'+
            		'<td font-weight: bold;>'+fieldMap.get('VP_Approver__c').getDescribe().getLabel()+'</td>'+
                	'<td>'+CAFRequest.VP_Approver__r.Name+'</td>'+
          		'</tr>';
        String FORM_HTML_Approvers_CFO= '<tr style="border: 1px solid black;">'+
                                            '<td font-weight: bold;>'+fieldMap.get('CFO_Approver__c').getDescribe().getLabel()+'</td>'+
                                            '<td>'+CAFRequest.CFO_Approver__r.Name+'</td>'+
                                        '</tr>';
        String FORM_HTML_Approvers_END='</table>'+
            '</div>';
        String FORM_HTML_Disease_START='<BR/>'+
            '<BR/>'+
            '<BR/>'+
            '<BR/>'+
            '<BR/>'+
            '<BR/>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Disease State</h1>'+
            '</div>'+
            '<BR/>'+
            '<div style="color:#000000;font-size: 12px;">'+
            '<table style="border: 1px solid #000000;">'+
            	'<tr style="border: 1px solid black;font-weight: bold;">'+
            		'<th style="border: 1px solid #000000;">'+stateMap.get('Disease_Fund_Name__c').getDescribe().getLabel()+'</th>'+
                	'<th style="border: 1px solid #000000;">'+stateMap.get('Requested_Donation_Amount__c').getDescribe().getLabel()+'</th>'+
            		'<th style="border: 1px solid #000000;">'+stateMap.get('Approved__c').getDescribe().getLabel()+'</th>'+
            		'<th style="border: 1px solid #000000;">'+stateMap.get('Payment_Amount__c').getDescribe().getLabel()+'</th>'+
          		'</tr>';
        String statedata;
        Integer i=1;
        for(gFRS_CAF_Disease_State__c gfrsCAFState:diseaseStateList){
            
            Decimal reqAmt = gfrsCAFState.Requested_Donation_Amount__c;
            String requestedAmt = reqAmt.format();
            
            Decimal app = gfrsCAFState.Approved__c;
            String approved = app.format();
            
            Decimal pay = gfrsCAFState.Payment_Amount__c;
            String payment = pay.format();
            
            statedata=statedata+
                '<tr style="border: 1px solid black;">'+
                '<td>'+gfrsCAFState.Disease_Fund_Name__c+'</td>'+
                '<td>'+requestedAmt+'</td>'+
                '<td>'+approved+'</td>'+
                '<td>'+payment+'</td>'+
                '</tr>';
            i=i+1;
        }
        FORM_HTML_Disease_START=FORM_HTML_Disease_START+statedata+'</table>'+
            '</div>';
        String FORM_HTML_END = '<DIV></BODY></HTML>';
        String pdfContent;
        //if(CAFRequest.CFO_Approver__r.Name == ''){
            if(String.isBlank(CAFRequest.CFO_Approver__r.Name)){
        	pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_COMPLIANCE_START+FORM_HTML_Compliance1+FORM_HTML_Compliance+FORM_HTML_Approvers_START+FORM_HTML_Approvers_END+FORM_HTML_Disease_START+FORM_HTML_END;
        }
        else{
            pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_COMPLIANCE_START+FORM_HTML_Compliance1+FORM_HTML_Compliance+FORM_HTML_Approvers_START+FORM_HTML_Approvers_CFO+FORM_HTML_Approvers_END+FORM_HTML_Disease_START+FORM_HTML_END;
        }
        /*Attachment attach1= new Attachment();
        attach1.ParentId = reqId;
        attach1.Name = compliancedocumentName;
        attach1.Body = Blob.toPDF(pdfContent);//File content
        attach1.contentType = 'application/pdf';
        insert attach1;
        
        CAFRequest.Summary_Snapshot_PDF_ID__c = attach1.Id;
            CAFRequest.id = reqId;
            update CAFRequest;*/
        
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
            gfrs.Summary_Snapshot_PDF_ID__c =conDocument;
            gfrs.id = reqId;
            update gfrs;
    }
}