/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : CMGT-FAX-05 GATCF FORMS.doc    
    // PRODUCT GROUP     : Activase, Avastin, Herceptin, Lucentis,
    //                     Nutropin, Pulmozyme, Raptiva, Rituxan, 
    //                     Rituxan RA, Tarceva, TNKase, Xolair
    // Type              : Fax Coversheet
    
/********************************************************************/
public class SCM_MD_Fax_GATCFForms_Lucentis extends SCM_MergeDocument implements IStandardComboBox {
    
    private SCM_MergeSection UI_ReqMDSig;
    private SCM_MergeSection UI_GATCFGuidelines;
    private SCM_MergeSection UI_PANandReleaseofInfo2;
    
    private SCM_MergeFieldCheckbox UI_ReqMDSigchk ;
    private SCM_MergeFieldCheckbox UI_GATCFGuidelineschk ;
    private SCM_MergeFieldCheckbox UI_PANandReleaseofInfo2chk ;
    
    public SCM_MD_Fax_GATCFForms_Lucentis(String caseID,String argLookupID) {
        super(caseID, argLookupID);          
    } 
     
     public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;

        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //Attn
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //Recname
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));       
        
        //Recfax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        
        //GATCF_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));

        //GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));

        //GATCF_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        
        //GATCF_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        
        //Drug
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
        
        //ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //PrivacyNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase)); 
        
        //AccessSolutions
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        //logo 
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));

        //==================================Second Scren===========================================//
        
        SCM_MergeFieldGroup EnrollInfo = new SCM_MergeFieldGroup();
        EnrollInfo.label = 'Enrollment Information:';
        EnrollInfo.headerText = 'The following document(s) are required';       
        EnrollInfo.key = 'Enrollment Information';
        
        UI_ReqMDSigchk = 
                new SCM_MergeFieldCheckbox('UI_ReqMDSigchk',
                 'Statement of Medical Necessity (requires MD signature)');       
        UI_ReqMDSigchk.fieldValue = '';
        UI_ReqMDSigchk.totalWidth = '900';
        EnrollInfo.subFields.add(UI_ReqMDSigchk);
                 
        UI_GATCFGuidelineschk = 
                new SCM_MergeFieldCheckbox('UI_GATCFGuidelineschk',
                 'Genentech Access To Care Foundation Guidelines');
        UI_GATCFGuidelineschk.fieldValue = '';
        UI_GATCFGuidelineschk.totalWidth = '900';        
        EnrollInfo.subFields.add(UI_GATCFGuidelineschk);    
             
        UI_PANandReleaseofInfo2chk = 
                new SCM_MergeFieldCheckbox('UI_PANandReleaseofInfo2chk',
                 'Patient Authorization Notice of Release of Information (signed and dated)');          
        UI_PANandReleaseofInfo2chk.fieldValue = '';       
        UI_PANandReleaseofInfo2chk.totalWidth = '900';
        EnrollInfo.subFields.add(UI_PANandReleaseofInfo2chk);
        this.mergeFields.add(EnrollInfo); 
        
         //Merge Sections       
        UI_ReqMDSig = new SCM_MergeSection();        
        UI_ReqMDSig.key = 'UI_ReqMDSig';
        this.mergeSections.add(UI_ReqMDSig);
        
        UI_GATCFGuidelines = new SCM_MergeSection();        
        UI_GATCFGuidelines.key = 'UI_GATCFGuidelines';
        this.mergeSections.add(UI_GATCFGuidelines);
        
        UI_PANandReleaseofInfo2 = new SCM_MergeSection();        
        UI_PANandReleaseofInfo2.key = 'UI_PANandReleaseofInfo2';
        this.mergeSections.add(UI_PANandReleaseofInfo2);
     }
     
     public override void getLatestValues() {
        UI_ReqMDSig.visible = UI_ReqMDSigchk.checked;
        UI_GATCFGuidelines.visible = UI_GATCFGuidelineschk.checked;
        UI_PANandReleaseofInfo2.visible = UI_PANandReleaseofInfo2chk.checked;        
    }
}