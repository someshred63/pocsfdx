public class SCM_MD_FAX_Claim_Status_Info_XOL extends SCM_MergeDocument implements IStandardComboBox{
public SCM_MD_FAX_Claim_Status_Info_XOL(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    private SCM_MergeField UI_DateofService = new SCM_MergeField();
    private SCM_MergeField UI_DateClaimBilled = new SCM_MergeField();
    
    private SCM_MergeField UI_EOB_RCL = new SCM_MergeField();
    private SCM_MergeField UI_DenialLet_Claim = new SCM_MergeField();
    private SCM_MergeField UI_AmtBilled = new SCM_MergeField();
    private SCM_MergeField UI_AmtPaid = new SCM_MergeField();
    private SCM_MergeField UI_PatNotesDOS = new SCM_MergeField();
    private SCM_MergeField UI_DiagTests = new SCM_MergeField();
    private SCM_MergeField UI_GenPatAuthNotRelInfo = new SCM_MergeField();
    private SCM_MergeField UI_DateClaimPaid = new SCM_MergeField();
    private SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
    
     public override void createMergeFields() {
//0. Attn (ATTN_Attn)
		string physicianId = selectedcase.Case_Treating_Physician_gne__c;
		String caseRecordType = selectedCase.RecordType.Name;
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //1. Addressed To 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //2. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
       //9 From Ext
        if (caseRecordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (caseRecordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        //5. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //7. AVST GATCF Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //8. AVST GATCF Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //9. AVST URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11.PatientFullName('Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        //Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        

        //-------------------------------------------------------------------------------------------
        // 14. Privacy Notice
        SCM_MF_Product_PrivacyNotice privacynotice = new SCM_MF_Product_PrivacyNotice(selectedCase);
                                  
        this.mergeRecipientInfo.add(privacynotice);
        
        //-------------------------------------------------------------------------------------------
        //15. Confidentiality Notice
        SCM_MF_Product_ConfidentialityNotice confidnotice = new SCM_MF_Product_ConfidentialityNotice(selectedCase);
        this.mergeRecipientInfo.add(confidnotice);
        
        this.mergeFields.add(new SCM_MF_Product_DrugName(selectedcase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        this.mergeFields.add(new SCM_MF_Product_Name(selectedcase));
        this.mergefields.add(SCM_MF_ReferralFieldFactory.ReferredDate(selectedCase));
        docu = new SCM_MergeFieldGroup();
        docu.label = 'The Following Document(s)\\Infomration Are Required:';
        docu.headerText = 'The Following Document(s)\\Infomration Are Required:';
        docu.key = 'UI_Additional_Docs';
        UI_DateofService = createMF('Date(s) of Service','• Date(s) of service: __________________ ','ui_DateofService',true,false);
        
        docu.subfields.add(UI_DateofService);
        UI_DateClaimBilled = createMF('Date claim billed','• Date claim billed: __________________','UI_DateClaimBilled',true,false);
        docu.subfields.add(UI_DateClaimBilled);
        
        UI_EOB_RCL = createMF('Explanation of Benefits (EOBs) with remark code legend','• Explanation of Benefits (EOBs) with remark code legend','UI_EOB_RCL',true,false);
        docu.subfields.add(UI_EOB_RCL);
        UI_DenialLet_Claim = createMF('Denial Letter(s) or claim','• Denial letter(s) or claim','UI_DenialLet_Claim',true,false);
        docu.subfields.add(UI_DenialLet_Claim);
        UI_AmtBilled = createMF('Amount billed per date of service, if not included on EOB','• Amount billed per date of service, if not included on EOB: ________________','UI_AmtBilled',true,false);
        docu.subfields.add(UI_AmtBilled);
        UI_DateClaimPaid = createMF('Date claim paid','• Date claim paid: _____________________','UI_DateClaimPaid',true,false);
        docu.subfields.add(UI_DateClaimPaid);
        UI_AmtPaid = createMF('Amount paid per date of service','• Amount paid per date of service: ______________________','UI_AmtPaid',true,false);
        docu.subfields.add(UI_AmtPaid);
        UI_PatNotesDOS = createMF('Patient notes specific to Dates of service','• Patient notes specific to Date of Service','UI_PatNotesDOS',true,false);
        docu.subfields.add(UI_PatNotesDOS);
        UI_DiagTests = createMF('Diagnosis tests: RAST/Skin, IgE, PFT (if applicable)','• Diagnosis tests: RAST/Skin, IgE, PFT (if applicable)','UI_DiagTests',true,false);
        docu.subfields.add(UI_DiagTests);
        UI_GenPatAuthNotRelInfo = createMF('Genentech Patient Authorization Notice of Release of Information (signed & dated)','• Genentech Patient Authorization Notice of Release of Information (signed and dated)','UI_GenPatAuthNotRelInfo',true,false);
        UI_GenPatAuthNotRelInfo.fieldStyle= 'width:600px';
        docu.subfields.add(UI_GenPatAuthNotRelInfo); 
        
        
        this.mergefields.add(docu);       
        this.mergefields.add(new scm_mf_Comments());
        this.mergeImages.add(new scm_MI_Logo(selectedcase));
     }
     public override void getLatestValues() {
     	boolean found = false;
     	for(scm_mergefield mf : docu.subfields){
     		if (mf.checked == false) {
     			
     			mf.mergeValue = '';
     			
     		}
     		else if(mf.checked)
     		{
     			found = true;
     			mf.mergeValue = mf.fieldValue;
     		}
     		docu.setVisible(found);
     		
     		
     		
     	}
     	
     }
     private SCM_MergeField CreateMF(string Label,string Value,string key,boolean isCheck,boolean EnableTextbox ) {
     	SCM_MergeField mf = new SCM_MergeField();
     	mf.displayCheck = isCheck;
     	mf.displayLabel = true;
     	mf.label = label;
     	mf.key = key;
     	mf.fieldValue = Value + '\r\n';
     	mf.displayTextBox = EnableTextbox;
     	mf.isRequired = false;
     	return mf;
     	
     	
     	
     }
     
}