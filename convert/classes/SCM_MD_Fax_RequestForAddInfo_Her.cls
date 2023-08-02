/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : HER-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis.doc
    // Type              : Fax Coversheet
    // Word Template     : Req_For_Add_Info_Her.doc 
    // Label in SF       : Request For Additional Information
    
/********************************************************************/

public class SCM_MD_Fax_RequestForAddInfo_Her extends SCM_MergeDocument implements IStandardComboBox{

    
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
    private SCM_MergeFieldCheckbox Checkbox13;
    private SCM_MergeField OtherDoc1;
    private SCM_MergeField OtherDoc2;
    private SCM_MergeField OtherDoc3;
    private SCM_MergeField OtherDoc4;
    private SCM_MergeField OtherDoc5;
    
        
    protected String caseId;
    
    public SCM_MD_Fax_RequestForAddInfo_Her(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
        public override void createMergeFields() {
        
            String caseRecordType = selectedCase.RecordType.Name;
            String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
            String patientNumber = selectedCase.Patient_gne__r.Id;
            String productName = selectedCase.Product_gne__c; 
            
            //1. Case Number
            this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
            
               
            //2. Patient Number
            this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
            
            // CR_Phone
            this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
            
            // CR_Fax
            this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
            
            // CR_URL
            this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
            
            //6. Attn (ATTN_Attn)
            this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));               
                    
                        
            //7. Addressed To 
            this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
            //8.Fax (RECFAX_Fax)
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
            // Date
            this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
            
            // PatientFullName
             this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
            
            //12. DOB DOB
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
        
            //13. Product Product Name
            this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
            
            
            // PrivacyNotice
            this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
            
            // ConfidNotice
            this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase)); 
            
            /////////-------Second Screen ------
            
            SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
            docu.label = 'Medical Information';
            docu.headerText = 'The following document(s) are required:';       
            docu.key = 'Documentation';
            
            //Merge Sections       
            UI_DocsRequiredList = new SCM_MergeSection();        
            UI_DocsRequiredList.key = 'UI_DocsRequiredList';
            this.mergeSections.add(UI_DocsRequiredList);
            
            //Checkboxes
            Checkbox1 = 
                    new SCM_MergeFieldCheckbox('UI_BIO_InitialHistoryPhysical', 'Initial History and Physical');        
            Checkbox1.fieldValue = 'Initial History and Physical \r\n';
            Checkbox1.totalWidth = '900';
            Checkbox1.isNewLine = false;
            docu.subFields.add(Checkbox1);
            
            Checkbox2 = 
                    new SCM_MergeFieldCheckbox('UI_PathologyReports', 'Pathology Reports');
            Checkbox2.fieldValue = 'Pathology Reports: ';
            Checkbox2.totalWidth = '130';
            Checkbox2.isNewLine = false;         
            docu.subFields.add(Checkbox2);
            
            
            
            OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', '');
            OtherDoc1.isNewLine = false;
            OtherDoc1.totalWidth = '270';
            OtherDoc1.isNewLine = false; 
            docu.subFields.add(OtherDoc1);
            
            Checkbox3 = 
                    new SCM_MergeFieldCheckbox('UI_HER_Her2Report', 'Her2 Reports');            
            Checkbox3.fieldValue = 'Her2 Report \r\n';
            Checkbox3.totalWidth = '900';
            Checkbox3.isNewLine = false;
            docu.subFields.add(Checkbox3);
            
            Checkbox4 = new SCM_MergeFieldCheckbox('UI_PriorTreatments', 'Prior Treatments');           
            Checkbox4.fieldValue = 'Prior Treatments: ';
            Checkbox4.totalWidth = '137';
            Checkbox4.isNewLine = false;
            docu.subFields.add(Checkbox4);
            
            OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
            OtherDoc2.totalWidth = '270';
            OtherDoc2.displayLabel=false;
            OtherDoc2.isNewLine = false;
            //OtherDoc2.setControlStyle('width:150');
            docu.subFields.add(OtherDoc2);
            
            Checkbox5 = 
                new SCM_MergeFieldCheckbox('UI_PhysicianNotes', 'Physician Notes');         
            Checkbox5.fieldValue = 'Physician Notes: ';
            Checkbox5.totalWidth = '130';
            Checkbox5.isNewLine = true;
            docu.subFields.add(Checkbox5);
            
            OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');
            OtherDoc3.totalWidth = '270';
            OtherDoc3.isNewLine = false;
            docu.subFields.add(OtherDoc3);
            
            Checkbox6 = 
                new SCM_MergeFieldCheckbox('UI_CTScans', 'CT Scans');           
            Checkbox6.fieldValue = 'CT Scans: ';
            Checkbox6.totalWidth = '130';
            Checkbox6.isNewLine = true;
            docu.subFields.add(Checkbox6);
            
            OtherDoc4 = new SCM_MF_OtherDocuments('UI_OtherDoc4', '');
            OtherDoc4.totalWidth = '270';
            OtherDoc4.isNewLine = false;
            docu.subFields.add(OtherDoc4);
           
            Checkbox7 = 
                new SCM_MergeFieldCheckbox('UI_InfusionsRecords', 'Infusion Records');          
            Checkbox7.fieldValue = 'Infusion Records: ';
            Checkbox7.totalWidth = '130';
            Checkbox7.isNewLine = true;
            docu.subFields.add(Checkbox7);
            
            OtherDoc5 = new SCM_MF_OtherDocuments('UI_OtherDoc5', '');
            OtherDoc5.totalWidth = '270';
            OtherDoc5.isNewLine = false;
            docu.subFields.add(OtherDoc5);
            
            Checkbox8 = 
                new SCM_MergeFieldCheckbox('UI_EKG_MUCHA_ECHO', 'EKG/MUGA/ECHO');           
            Checkbox8.fieldValue = 'EKG/MUGA/ECHO \r\n';
            Checkbox8.totalWidth = '900';
            Checkbox8.isNewLine = false;
            docu.subFields.add(Checkbox8);
            
            Checkbox9 = 
                new SCM_MergeFieldCheckbox('UI_ClinicalTNMStage', 'Clinical TNM Stage');            
            Checkbox9.fieldValue = 'Clinical TNM Stage \r\n';
            Checkbox9.totalWidth = '900';
            Checkbox9.isNewLine = false;
            docu.subFields.add(Checkbox9);
            
            Checkbox10 = 
                new SCM_MergeFieldCheckbox('UI_MetastaticSites', 'Metastatic Sites');           
            Checkbox10.fieldValue = 'Metastatic Sites \r\n';
            Checkbox10.totalWidth = '900';
            Checkbox10.isNewLine = false;
            docu.subFields.add(Checkbox10);
            
            Checkbox11 = 
                new SCM_MergeFieldCheckbox('UI_ExpOfBenefits', 'Explanation of Benefits (EOB)');            
            Checkbox11.fieldValue = 'Explanation of Benefits (EOB) \r\n';
            Checkbox11.totalWidth = '900';
            Checkbox11.isNewLine = false;
            docu.subFields.add(Checkbox11);
            
            Checkbox12 = 
                new SCM_MergeFieldCheckbox('UI_DenialLetter', 'Denial letter(s)');          
            Checkbox12.fieldValue = 'Denial letter(s) \r\n';
            Checkbox12.totalWidth = '900';
            Checkbox12.isNewLine = false;
            docu.subFields.add(Checkbox12);
            
            Checkbox13 = 
                new SCM_MergeFieldCheckbox('UI_PatientAuthoNoticeReleaseInfo', 'Genentech Patient Authorization Notice of Release of Information (signed and dated)');          
            Checkbox13.fieldValue = 'Genentech Patient Authorization Notice of Release of Information (signed and dated) \r\n';
            Checkbox13.totalWidth = '900';
            Checkbox13.isNewLine = false;
            docu.subFields.add(Checkbox13);
            
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
            && Checkbox10.checked == false && Checkbox11.checked == false ){
                UI_DocsRequiredList.visible = false;
            }
            else{
                UI_DocsRequiredList.visible = true;
                }
                
            if(Checkbox2.checked == false)
                OtherDoc1.mergeValue = '';
            if(Checkbox4.checked == false)
                OtherDoc2.mergeValue = '';
            if(Checkbox5.checked == false)
                OtherDoc3.mergeValue = '';
            if(Checkbox6.checked == false)
                OtherDoc4.mergeValue = '';
            if(Checkbox7.checked == false)
                OtherDoc5.mergeValue = '';
                
        }
        
        
}