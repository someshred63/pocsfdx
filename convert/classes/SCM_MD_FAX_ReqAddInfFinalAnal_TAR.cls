/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : TAR-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis.doc
    // PRODUCT GROUP     : Oncology/Tarceva
    // Type              : Fax Coversheet
    // Word Template     : ReqAddInfFinalAnal_TAR.doc    
    // Label in SF       : RequestFinalAnalysis_TAR
    
/********************************************************************/

public class SCM_MD_FAX_ReqAddInfFinalAnal_TAR extends SCM_MergeDocument implements IStandardComboBox
 {
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection Data;
    
    
    
    private SCM_MergeFieldCheckbox UI_BIO;
    private SCM_MergeFieldCheckbox UI_PathologyReports;
    private SCM_MergeFieldCheckbox UI_TreatmentPlan;
    private SCM_MergeFieldCheckbox UI_PriorTreatments;
    private SCM_MergeFieldCheckbox UI_PhysicianNotes;
    private SCM_MergeFieldCheckbox UI_CTScans;
    private SCM_MergeFieldCheckbox UI_MetastaticSites;
    private SCM_MergeFieldCheckbox UI_DenialLtr_Appeal;
    private SCM_MergeFieldCheckbox UI_PatientAuthoNoticeReleaseInfo;
   
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    private SCM_MF_OtherDocuments  OtherDoc4; 
   
    public SCM_MD_FAX_ReqAddInfFinalAnal_TAR(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
        
    public override void createMergeFields() {
        
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String productName = selectedCase.Product_gne__c;
        String recordType = selectedCase.RecordType.Name;
        
        //1. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2. Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));   
        
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
               
        // Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
           
        // Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    
        // Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));

         // From and EXt
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }     
        
        //11.DateShort
        SCM_MF_CurrentDate currentDate = new SCM_MF_CurrentDate();
        this.mergeRecipientInfo.add(currentDate);
        
        //Patient full name 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Patient DOB 
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
                      
        //14.Drug 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        //15.PrivacyNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //16.ConfidNotice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
       //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Medical Information';       
        formInformation.key = 'Medical Information';     
        
        //Merge Sections       
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
        Data = new SCM_MergeSection();        
        Data.key = 'Data';
        this.mergeSections.add(Data);
        
        //-------------------------------------------------------------------------------------------       
  
        //  Initial History and Physical
        UI_BIO = new SCM_MergeFieldCheckbox('BIO',
                 'Recent History and Physical / Discharge Summary');       
        UI_BIO.fieldValue ='Recent History and Physical / Discharge Summary.\r\n';
        UI_BIO.totalWidth = '900';
        formInformation.subFields.add(UI_BIO);
        
        //  Pathology Reports
        UI_PathologyReports = 
                new SCM_MergeFieldCheckbox('PathologyReports', 'Pathology Reports');               
        UI_PathologyReports.totalWidth = '130';
         UI_PathologyReports.fieldValue = 'Pathology Reports:';
        formInformation.subFields.add(UI_PathologyReports);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('cnt', '');
        OtherDoc1.isNewLine = false;
        OtherDoc1.totalWidth = '270';
        formInformation.subFields.add(OtherDoc1);
               
        //  Treatment Plan
        UI_TreatmentPlan = new SCM_MergeFieldCheckbox('TreatmentPlan','Treatment Plan');       
        UI_TreatmentPlan.fieldValue ='Treatment Plan:\r\n';
        UI_TreatmentPlan.totalWidth = '900';
        formInformation.subFields.add(UI_TreatmentPlan);
     
        //  Prior Treatments 
        UI_PriorTreatments = new SCM_MergeFieldCheckbox('prtrt','Prior Treatments');              
        UI_PriorTreatments.totalWidth = '130';
         UI_PriorTreatments.fieldValue ='Prior Treatments:'; 
        formInformation.subFields.add(UI_PriorTreatments);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('prtext', '');
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
        formInformation.subFields.add(OtherDoc2);
         
             
        //  Physician Notes   
        UI_PhysicianNotes = new SCM_MergeFieldCheckbox('phynot','Physician Notes');             
        UI_PhysicianNotes.totalWidth = '130';   
        UI_PhysicianNotes.fieldValue ='Physician Notes:';
        formInformation.subFields.add(UI_PhysicianNotes);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('phynottext', '');
        OtherDoc3.isNewLine = false;
        OtherDoc3.totalWidth = '270';
        formInformation.subFields.add(OtherDoc3);
         
         //  CT Scans      
        UI_CTScans = new SCM_MergeFieldCheckbox('ctScans','CT Scans');       
        UI_CTScans.totalWidth = '130';
        UI_CTScans.fieldValue ='CT Scans:';
        formInformation.subFields.add(UI_CTScans);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('ctScanstext', '');
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        formInformation.subFields.add(OtherDoc4);
 
                  
         //  Metastatic Sites(s)
         UI_MetastaticSites = new SCM_MergeFieldCheckbox('MetastaticSites', 'Metastatic Sites(s)');            
        UI_MetastaticSites.fieldValue = 'Metastatic Sites(s) \r\n';      
        UI_MetastaticSites.totalWidth = '900';
        formInformation.subFields.add(UI_MetastaticSites);
            
         //  Denial letter(s), Appeal Instructions and any correspondence with the insurance company
        UI_DenialLtr_Appeal = new SCM_MergeFieldCheckbox('DenLtrs','Denial letter(s) Appeal Instructions and any correspondence with the insurance co.');       
        UI_DenialLtr_Appeal.fieldValue ='Denial letter(s) Appeal Instructions and any correspondence with the insurance co.\r\n';
        UI_DenialLtr_Appeal.totalWidth = '900';
        formInformation.subFields.add(UI_DenialLtr_Appeal);
 
         //  Genentech Patient Authorization Notice of Release of Information (signed and dated)      
        UI_PatientAuthoNoticeReleaseInfo = new SCM_MergeFieldCheckbox('Relins',
                 'Genentech Patient Authorization Notice of Release of Information (signed and dated)');       
        UI_PatientAuthoNoticeReleaseInfo.fieldValue ='Genentech Patient Authorization Notice of Release of Information (signed and dated).\r\n';
        UI_PatientAuthoNoticeReleaseInfo.totalWidth = '900';
        formInformation.subFields.add(UI_PatientAuthoNoticeReleaseInfo);
           
        this.mergeFields.add(formInformation);         
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
   
    
    }
    
    
    public override void getLatestValues()
    {
      
            if(UI_BIO.checked == false && UI_PathologyReports.checked == false 
            && UI_TreatmentPlan.checked == false && UI_PriorTreatments.checked == false && UI_PhysicianNotes.checked == false 
            && UI_CTScans.checked == false && UI_MetastaticSites.checked == false  
            && UI_DenialLtr_Appeal.checked == false && UI_PatientAuthoNoticeReleaseInfo.checked == false)
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }
            
            if (UI_PathologyReports.checked==false)
            OtherDoc1.mergeValue = '';
            if (UI_PriorTreatments.checked==false)
            OtherDoc2.mergeValue = '';
            if (UI_PhysicianNotes.checked==false)
            OtherDoc3.mergeValue = '';
            if (UI_CTScans.checked==false)
            OtherDoc4.mergeValue = '';
           
       }
        
   
}