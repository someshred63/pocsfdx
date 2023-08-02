/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : TNK_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.DOC
    // Type              : Fax Coversheet
    // Word Template     : INFO_DOC_RETRIEVAL_TNK   
    // Label in SF       : INF DOC RETRIEVAL TNK 
    
/********************************************************************/
public class SCM_MD_FAX_INFDOC_RETRIEVAL_TNK extends SCM_MergeDocument implements IStandardComboBox {
    
    protected String caseId;
    public SCM_MD_FAX_INFDOC_RETRIEVAL_TNK(String caseId, String argLookupId) {
        super(caseID, argLookupId);
        caseId = caseID;
    }
    
    public override void createMergeFields() { 
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String caseRecordType = selectedCase.RecordType.Name;
        
        //0. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //1. Addressed To (RECNAME_To)
       this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //2. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
        //Drug
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        //9 From Ext
        if (caseRecordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (caseRecordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
      
        // Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        // Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
                
        // Tnk Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        // Tnk Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        // Tnk URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        
        //DateShort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //PatientFullName(''Patient_First_And_Last_Name'')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        //Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id)); 
        
        //PrivacyNotice
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //ConfidNotice
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //------------------------------------------Second Screen ------------------------------------------//
        
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.headerText = 'Additional Information Required:';       
        docu.key = 'Add Information';
        
        SCM_MergeFieldCheckbox UI_PatientInfoChk = 
                new SCM_MergeFieldCheckbox('UI_PatientInfoChk', 'Patient Information');     
        UI_PatientInfoChk.fieldValue = 'Patient Information \r\n';
        UI_PatientInfoChk.totalWidth = '900';
        docu.subFields.add(UI_PatientInfoChk);
        
        SCM_MergeFieldCheckbox UI_InsuranceInfoChk = 
                new SCM_MergeFieldCheckbox('UI_InsuranceInfoChk', 'Insurance Information');
        UI_InsuranceInfoChk.fieldValue = 'Insurance Information \r\n';
        UI_InsuranceInfoChk.totalWidth = '900';          
        docu.subFields.add(UI_InsuranceInfoChk);
        
        SCM_MergeFieldCheckbox UI_FacilityPhysicianInfoChk = 
                new SCM_MergeFieldCheckbox('UI_FacilityPhysicianInfoChk', 'Facility/Physician Information');            
        UI_FacilityPhysicianInfoChk.fieldValue = 'Facility/Physician Information \r\n';     
        UI_FacilityPhysicianInfoChk.totalWidth = '900';
        docu.subFields.add(UI_FacilityPhysicianInfoChk);
        
        SCM_MergeFieldCheckbox UI_MedicalInfoChk = new SCM_MergeFieldCheckbox('UI_MedicalInfoChk', 'Medical Information');          
        UI_MedicalInfoChk.fieldValue = 'Medical Information \r\n';      
        UI_MedicalInfoChk.totalWidth = '900';
        docu.subFields.add(UI_MedicalInfoChk);
        
        SCM_MergeFieldCheckbox UI_ShippingDetailsChk = 
            new SCM_MergeFieldCheckbox('UI_ShippingDetailsChk', 'Shipping Details');            
        UI_ShippingDetailsChk.fieldValue = 'Shipping Details \r\n';     
        UI_ShippingDetailsChk.totalWidth = '900';
        docu.subFields.add(UI_ShippingDetailsChk);
        
        SCM_MergeFieldCheckbox UI_AuthorizedSignatureDateChk = 
            new SCM_MergeFieldCheckbox('UI_AuthorizedSignatureDateChk', 'Authorized Signature/Date');           
        UI_AuthorizedSignatureDateChk.fieldValue = 'Authorized Signature/Date \r\n';        
        UI_AuthorizedSignatureDateChk.totalWidth = '900';
        docu.subFields.add(UI_AuthorizedSignatureDateChk);
        
        SCM_MergeFieldCheckbox UI_IncomeVerficationChk = new SCM_MergeFieldCheckbox('UI_IncomeVerficationChk', 'Income Verification ');         
        UI_IncomeVerficationChk.fieldValue = 'Income Verification \r\n';        
        UI_IncomeVerficationChk.totalWidth = '900';
        docu.subFields.add(UI_IncomeVerficationChk);
        this.mergeFields.add(docu);
        
        
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        
        comments.headerText = 'Comments: ';       
        comments.key = 'Comments';                                  
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);
    
    }
  }