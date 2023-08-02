/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : NUT-CMGT-FAX-32 APPEAL REQUEST FOR ADDITIONAL DOCUMENTS.DOC
    // Type              : Fax Coversheet
    // Word Template     : AppealReqForAddDoc_Nutropin.doc    
    // Label in SF       : Appeal Request for Additional Documents  
    
/********************************************************************/
public class SCM_MD_Fax_AppealReq_Nutropin extends SCM_MergeDocument implements IStandardComboBox {
    private SCM_MergeSection UI_DocsRequiredList;
    
    private SCM_MergeFieldCheckbox Checkbox1;
    private SCM_MergeFieldCheckbox Checkbox2;
    private SCM_MergeFieldCheckbox Checkbox3;
    private SCM_MergeFieldCheckbox Checkbox4;
    private SCM_MergeFieldCheckbox Checkbox5;
    private SCM_MergeFieldCheckbox Checkbox6;
    private SCM_MergeFieldCheckbox Checkbox7;
    private SCM_MergeFieldCheckbox Checkbox8;
    private SCM_MergeFieldCheckbox Checkbox9;
    private SCM_MergeFieldCheckbox Checkbox10;
    private SCM_MergeFieldCheckbox Checkbox11;
    private SCM_MergeFieldCheckbox Checkbox12;
    private SCM_MergeField OtherDoc1;
    private SCM_MergeField OtherDoc2;
    private SCM_MergeField OtherDoc3;
    
    protected String caseId;
    public SCM_MD_Fax_AppealReq_Nutropin(String caseId, String argLookupId) {
        super(caseID, argLookupId);
        caseId = caseID;
    }
    
    public override void createMergeFields() {
        String recordType = selectedCase.RecordType.Name;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientId = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        
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

        //Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //7. CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //8. CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //9. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //10. PrivacyNotice
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //11. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //12. PatientFullName('Patient_First_And_Last_Name') 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        //13. Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        //14. Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));     
        
        //------------------------------------------Second Screen ------------------------------------------//
        
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Documentation:';
        docu.headerText = 'Please fax the following as soon as possible so we can expedite the appeals process:';       
        docu.key = 'Documentation';
        
        //Merge Sections       
        UI_DocsRequiredList = new SCM_MergeSection();        
        UI_DocsRequiredList.key = 'UI_DocsRequiredList';
        this.mergeSections.add(UI_DocsRequiredList);
        
        //Checkboxes
        Checkbox1 = 
                new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (Completed)');        
        Checkbox1.fieldValue = 'SMN (Completed) \r\n';
        Checkbox1.totalWidth = '270';
        Checkbox1.isNewLine = true;
        docu.subFields.add(Checkbox1);
        
        Checkbox2 = 
                new SCM_MergeFieldCheckbox('UI_KaryotypeResults', 'Karyotype Results');
        Checkbox2.fieldValue = 'Karyotype Results \r\n';
        Checkbox2.totalWidth = '270';
        Checkbox2.isNewLine = false;         
        docu.subFields.add(Checkbox2);
        
        Checkbox3 = 
                new SCM_MergeFieldCheckbox('UI_BoneAgeReport', 'Bone Age Report');          
        Checkbox3.fieldValue = 'Bone Age Report \r\n';
        Checkbox3.totalWidth = '270';
        Checkbox3.isNewLine = true;
        docu.subFields.add(Checkbox3);
        
        Checkbox4 = new SCM_MergeFieldCheckbox('UI_HisPhysTreat', 'History/Physical/Treatment Plan');           
        Checkbox4.fieldValue = 'History/Physical/TreamentPlan \r\n';
        Checkbox4.totalWidth = '270';
        Checkbox4.isNewLine = false;
        docu.subFields.add(Checkbox4);
         
        Checkbox5 = 
            new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Progress Notes');           
        Checkbox5.fieldValue = 'Progress Notes \r\n';
        Checkbox5.totalWidth = '270';
        Checkbox5.isNewLine = true;
        docu.subFields.add(Checkbox5);
        
        Checkbox6 = 
            new SCM_MergeFieldCheckbox('UI_RenalFunctionResultsCRIOnly', 'Renal Function Results (CRI Only)');          
        Checkbox6.fieldValue = 'Renal Function Results (CRI Only) \r\n';
        Checkbox6.totalWidth = '270';
        Checkbox6.isNewLine = false;
        docu.subFields.add(Checkbox6);
        
        Checkbox7 = 
            new SCM_MergeFieldCheckbox('UI_GrowthChart', 'Current Growth Chart');           
        Checkbox7.fieldValue = 'Growth Chart \r\n';
        Checkbox7.totalWidth = '270';
        Checkbox7.isNewLine = true;
        docu.subFields.add(Checkbox7);
        
        Checkbox8 = 
            new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');          
        Checkbox8.fieldValue = 'Prescriptions \r\n';
        Checkbox8.totalWidth = '270';
        Checkbox8.isNewLine = false;
        docu.subFields.add(Checkbox8);
        
        Checkbox9 = 
            new SCM_MergeFieldCheckbox('UI_StimTestReport', 'Stim Test(s) Report(s)');          
        Checkbox9.fieldValue = 'Stim Test(s) Report(s) \r\n';
        Checkbox9.totalWidth = '270';
        Checkbox9.isNewLine = true;
        docu.subFields.add(Checkbox9);
        
        Checkbox10 = 
            new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form (signed & completed)');         
        Checkbox10.fieldValue = 'Prior Authorization Form (signed & completed) \r\n';
        Checkbox10.totalWidth = '300';
        Checkbox10.isNewLine = false;
        docu.subFields.add(Checkbox10);
        
        Checkbox11 = 
            new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');           
        Checkbox11.fieldValue = 'PCP Referral \r\n';
        Checkbox11.totalWidth = '270';
        Checkbox11.isNewLine = true;
        docu.subFields.add(Checkbox11);
     
        
        OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', 'Other Documentation ');
        OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');
        docu.subFields.add(OtherDoc1);
        docu.subFields.add(OtherDoc2);
        docu.subFields.add(OtherDoc3);
        this.mergeFields.add(docu);
        
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        
        comments.headerText = 'Comments: ';       
        comments.key = 'Comments';                                  
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);
    }
    public override void getLatestValues(){
        
        if(Checkbox1.checked == false && Checkbox2.checked == false && Checkbox3.checked == false 
        && Checkbox4.checked == false && Checkbox5.checked == false && Checkbox6.checked == false
        && Checkbox7.checked == false && Checkbox8.checked == false && Checkbox9.checked == false
        && Checkbox10.checked == false && Checkbox11.checked == false &&
        (OtherDoc1.getMergeValue() == null || OtherDoc1.getMergeValue().equals('')) &&
        (OtherDoc2.getMergeValue() == null || OtherDoc2.getMergeValue().equals('')) &&
        (OtherDoc3.getMergeValue() == null || OtherDoc3.getMergeValue().equals(''))){
            UI_DocsRequiredList.visible = false;
        }
        else{
            UI_DocsRequiredList.visible = true;
            }
        }   
}