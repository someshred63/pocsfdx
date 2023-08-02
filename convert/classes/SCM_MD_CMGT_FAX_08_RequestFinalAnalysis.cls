//********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : RIT-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis
    // PRODUCT GROUP     : Rituxan
    // Type              : Fax coversheet
    // Word Template     : CMGT FAX 08 Request Final Analysis 
    // Label in SF       : CMGT FAX 08 Request Final Analysis
    
//********************************************************************/

public class SCM_MD_CMGT_FAX_08_RequestFinalAnalysis extends SCM_MergeDocument implements IStandardComboBox
{
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection Data;
   
    
    private SCM_MergeFieldCheckbox UI_BIO;
    private SCM_MergeFieldCheckbox UI_CD20;
    private SCM_MergeFieldCheckbox UI_PathologyReports;
    private SCM_MergeFieldCheckbox UI_PriorTreatments;
    private SCM_MergeFieldCheckbox UI_PhysicianNotes;
    private SCM_MergeFieldCheckbox UI_CTScans;
    private SCM_MergeFieldCheckbox UI_InfusionsRecords;
    private SCM_MergeFieldCheckbox UI_LABs;
    private SCM_MergeFieldCheckbox UI_ExpOfBenefits;
    private SCM_MergeFieldCheckbox UI_DenialLtr_Appeal;
    private SCM_MergeFieldCheckbox UI_PatientAuthoNoticeReleaseInfo;
        
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    private SCM_MF_OtherDocuments  OtherDoc4;   
    private SCM_MF_OtherDocuments  OtherDoc5;   
    private SCM_MF_OtherDocuments  OtherDoc6;    
    
   public SCM_MD_CMGT_FAX_08_RequestFinalAnalysis(String caseID, String argLookupId)
    {
            super(caseID, argLookupId);
            caseId = caseID;            
    }
    public override void createMergeFields()  
    { 
         
        
         //1 Case ID (Caseid)
        SCM_MF_CaseNumber caseid= new SCM_MF_CaseNumber(selectedCase);
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //2 Patient ID (Patient Id)
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
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
       
       // Date (Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
       //Patient full name (Name)
       this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
               
        
       //Patient DOB 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));

        
       //Drug 
       this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
       
       //privacy notice (PrivacyNotice)
       this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
       
       //Confid notice
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
                    
        //checkboxes
               
        UI_BIO = new SCM_MergeFieldCheckbox('BIO',
                 'Initial History and Physical');       
        UI_BIO.fieldValue ='Initial History and Physical.\r\n';
        UI_BIO.totalWidth = '900';
        formInformation.subFields.add(UI_BIO);
        
        UI_PathologyReports = new SCM_MergeFieldCheckbox('Patrep','Pathology Reports');       
        UI_PathologyReports.fieldValue ='Pathology Reports:';
        UI_PathologyReports.totalWidth = '150';
        //UI_PathologyReports.isNewLine = false;  
        formInformation.subFields.add(UI_PathologyReports);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('cnt', '');
        OtherDoc1.isNewLine = false;
        OtherDoc1.totalWidth = '270';
        formInformation.subFields.add(OtherDoc1);
           
                  
        UI_CD20 = new SCM_MergeFieldCheckbox('CD20',
                 'CD20 Report');       
        UI_CD20.fieldValue ='CD20 Report.\r\n';
        UI_CD20.totalWidth = '900';
        formInformation.subFields.add(UI_CD20);
        
        UI_PriorTreatments = new SCM_MergeFieldCheckbox('prtrt','Prior Treatments');       
        UI_PriorTreatments.fieldValue ='Prior Treatments:';
        UI_PriorTreatments.totalWidth = '150';
        //UI_PriorTreatments.isNewLine = true;   
        formInformation.subFields.add(UI_PriorTreatments);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('prtext', '');
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
        formInformation.subFields.add(OtherDoc2);
        
        
        UI_PhysicianNotes = new SCM_MergeFieldCheckbox('phynot','Physician Notes');       
        UI_PhysicianNotes.fieldValue ='Physician Notes:';
        UI_PhysicianNotes.totalWidth = '150';
       // UI_PhysicianNotes.isNewLine = true;     
        formInformation.subFields.add(UI_PhysicianNotes);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('phynottext', '');
        OtherDoc3.isNewLine = false;
        OtherDoc3.totalWidth = '270';
        formInformation.subFields.add(OtherDoc3);
        
         
        UI_CTScans = new SCM_MergeFieldCheckbox('ctScans','CT Scans');       
        UI_CTScans.fieldValue ='CT Scans:';
        UI_CTScans.totalWidth = '150';
       // UI_CTScans.isNewLine = true;    
        formInformation.subFields.add(UI_CTScans);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('ctScanstext', '');
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        formInformation.subFields.add(OtherDoc4);
        
        UI_InfusionsRecords = new SCM_MergeFieldCheckbox('infsRec','Infusion Records');       
        UI_InfusionsRecords.fieldValue ='Infusion Records:';
        UI_InfusionsRecords.totalWidth = '150';
       // UI_InfusionsRecords.isNewLine = true;    
        formInformation.subFields.add(UI_InfusionsRecords);
        
        OtherDoc5 = new SCM_MF_OtherDocuments('infsRectext', '');
        OtherDoc5.isNewLine = false;
        OtherDoc5.totalWidth = '270';
        formInformation.subFields.add(OtherDoc5);
        
        
        UI_LABs = new SCM_MergeFieldCheckbox('LABs','LABs');       
        UI_LABs.fieldValue ='LABs:';
        UI_LABs.totalWidth = '150';
       // UI_LABs.isNewLine = true;    
        formInformation.subFields.add(UI_LABs);
        
        OtherDoc6 = new SCM_MF_OtherDocuments('LABstext', '');
        OtherDoc6.isNewLine = false;
        OtherDoc6.totalWidth = '270';
        formInformation.subFields.add(OtherDoc6);
        
        UI_ExpOfBenefits = new SCM_MergeFieldCheckbox('EOB',
                 'Explanation of Benefits (EOB)');       
        UI_ExpOfBenefits.fieldValue ='Explanation of Benefits (EOB).\r\n';
        UI_ExpOfBenefits.totalWidth = '900';
        formInformation.subFields.add(UI_ExpOfBenefits);
        
        UI_DenialLtr_Appeal = new SCM_MergeFieldCheckbox('DenLtrs',
                 'Denial letter(s)');       
        UI_DenialLtr_Appeal.fieldValue ='Denial letter(s).\r\n';
        UI_DenialLtr_Appeal.totalWidth = '900';
        formInformation.subFields.add(UI_DenialLtr_Appeal);
        
        UI_PatientAuthoNoticeReleaseInfo = new SCM_MergeFieldCheckbox('Relins',
                 'Genentech Patient Authorization Notice of Release of Information (signed and dated');       
        UI_PatientAuthoNoticeReleaseInfo.fieldValue ='Genentech Patient Authorization Notice of Release of Information (signed and dated.\r\n';
        UI_PatientAuthoNoticeReleaseInfo.totalWidth = '900';
        formInformation.subFields.add(UI_PatientAuthoNoticeReleaseInfo);
        
        this.mergeFields.add(formInformation);         
        
        //Comments
        SCM_MergeFieldGroup comments = new SCM_MF_Comments();        
        this.mergeFields.add(comments);  
    }
    
    public override void getLatestValues()
    {
                
            if(UI_BIO.checked == false && UI_PathologyReports.checked == false 
            && UI_PriorTreatments.checked == false && UI_PhysicianNotes.checked == false 
            && UI_CTScans.checked == false  && UI_InfusionsRecords.checked == false && UI_LABs.checked == false 
            && UI_ExpOfBenefits.checked == false && UI_DenialLtr_Appeal.checked == false && UI_PatientAuthoNoticeReleaseInfo.checked == false)
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
            if (UI_InfusionsRecords.checked==false)
            OtherDoc5.mergeValue = '';
            if (UI_LABs.checked==false)
            OtherDoc6.mergeValue = '';
        } 
        
}