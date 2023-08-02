/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : NUT-CMGT-FAX-34_Rx_To_Novafactor_FinalAnalysis
    // PRODUCT GROUP     : Growth Hormone/Nutropin
    // Type              : Fax Coversheet
    // Word Template     : Novafactor_FinalAnal_NUT.doc    
    // Label in SF       : Novafactor_FinalAnal 
    
/********************************************************************/

public class SCM_MD_FAX_Rx_Novafact_FinalAnal  extends SCM_MergeDocument  {

	private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    
public SCM_MD_FAX_Rx_Novafact_FinalAnal(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
     public override void createMergeFields() {
     	
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String productName = selectedCase.Product_gne__c;
        String recordType = selectedCase.RecordType.Name;
        
        // 1.Case Number
        mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        // 2.Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));  
        
        // 3.CR_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
		
		// 4.Phone_CR_Short
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));  
        
        // 5.CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // 6.CR_URL 
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // 7.ATTN_NOVA key = ATTN_Attn
        OtherDoc1 = new SCM_MF_OtherDocuments('ATTN_Attn', 'Attn');
        OtherDoc1.key = 'ATTN_Attn';
        OtherDoc1.fieldValue='Specialty Pharmacy';
        OtherDoc1.IsRequired = true;
        OtherDoc1.totalWidth = '270';
        OtherDoc1.width = '150';
        OtherDoc1.requireNewLineInTemplate = false;
        this.mergeRecipientInfo.add(OtherDoc1);
                              
        // 8.RECNAME_NOVA  (RECNAME) 
        OtherDoc2 = new SCM_MF_OtherDocuments('RECNAME', 'Addressed To');
        OtherDoc2.key = 'RECNAME';
        OtherDoc2.fieldValue='Accredo / Nova Factor';
        OtherDoc2.IsRequired = true;
        OtherDoc2.totalWidth = '270';
        OtherDoc2.width = '150';
        OtherDoc2.requireNewLineInTemplate = false;
        this.mergeRecipientInfo.add(OtherDoc2);
        

        // 9.RECFAX_NOVA ''RECFAX_Fax
        OtherDoc3 = new SCM_MF_OtherDocuments('RECFAX_Fax', 'Fax Number');
        OtherDoc3.key = 'RECFAX_Fax';
        OtherDoc3.fieldValue='(877) 378-3499';
        OtherDoc3.IsRequired = true;
        OtherDoc3.totalWidth = '270';
        OtherDoc3.width = '150';
        OtherDoc3.requireNewLineInTemplate = false;
        this.mergeRecipientInfo.add(OtherDoc3);
           
               
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
                       
        // 12.DateShort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // 13.PatientFullName
        SCM_MF_PatientFirstAndLastName patientName = new SCM_MF_PatientFirstAndLastName(selectedCase);
        this.mergeRecipientInfo.add(patientName);
        
        // 14.DOB
        this.mergeRecipientInfo.add(new SCM_MF_Patient_DOB(selectedCase.Patient_gne__r.Patient_Id_gne__c));              
        
        // 15.Drug 
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        // 16.Privacy Notice    
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
           
        // 17.Confidentiality Notice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));

      	//---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Prescription';       
        formInformation.key = 'Prescription';     
                
        this.mergeFields.add(formInformation);  
         
        // 18.Comments
        this.mergeFields.add(new SCM_MF_Comments());
        
    }

}