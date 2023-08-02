/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RA-CMGT-FAX-22_Status_Update_Additional_Information_FinalAnalysis.doc
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : Fax Coversheet
    // Word Template     : Status Update Request for Additional Information.doc
    // Label in SF       : 
/********************************************************************/
    
public class SCM_MD_FAX_StatusUpdAddInfoReq_RitRA extends SCM_MergeDocument implements IStandardComboBox{
    
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection Data;
    
    //only checkboxes
    private SCM_MergeFieldCheckbox UI_InitialHistoryPhysical;
    private SCM_MergeFieldCheckbox UI_SMN;
    private SCM_MergeFieldCheckbox UI_RheumatoidFactor;
    private SCM_MergeFieldCheckbox UI_ErythrocyteSedimentationRate;
    private SCM_MergeFieldCheckbox UI_ExpOfBenefits;
    private SCM_MergeFieldCheckbox UI_DenialLetter;
    private SCM_MergeFieldCheckbox UI_PatientAuthoNoticeReleaseInfo;
    private SCM_MergeFieldCheckbox UI_CReactiveProtein;
    
    //checkbox+textbox
    private SCM_MergeFieldCheckbox UI_PathologyReports;
    private SCM_MergeFieldCheckbox UI_PriorTreatments;
    private SCM_MergeFieldCheckbox UI_PhysicianNotes;
    private SCM_MergeFieldCheckbox UI_CTScans;
    private SCM_MergeFieldCheckbox UI_InfusionsRecords;
    private SCM_MergeFieldCheckbox UI_LABs;

    //only textboxes
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    private SCM_MF_OtherDocuments  OtherDoc4;   
    private SCM_MF_OtherDocuments  OtherDoc5;   
    private SCM_MF_OtherDocuments  OtherDoc6;
     private SCM_MergeFieldCheckbox  UI_Prescriber;
     private SCM_MergeFieldCheckbox  UI_ShipLocation;
 
    private SCM_MergeFieldGroup docu;
    
    public SCM_MD_FAX_StatusUpdAddInfoReq_RitRA (String caseId, String argLookupId) {
        super(caseId, argLookupId);
    } 

    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
          this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        //-------------------------------------------------------------------------------------------       
        // CR Phone (key CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR Fax (key CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
         this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        // CR URL (key CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Product Name (key Drug)
        this.mergeFields.add(new SCM_MF_Product_DrugName(selectedCase));
        //-------------------------------------------------------------------------------------------
        // PrivacyNotice (key PrivacyNotice)
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
        
        // Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Current Date (key Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // Current Daate Plus 10 Days (key TenDaysAfterCurrentDate)                
        this.mergeRecipientInfo.add(new SCM_MF_TenDaysAfterCurrentDate());
        //-------------------------------------------------------------------------------------------
        // PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));

        // Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        //-------------------------------------------------------------------------------------------
        // First Page
        //-------------------------------------------------------------------------------------------
        // Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // To:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_TextBox(selectedCase.Case_Treating_Physician_gne__r.Id));        //RecFax
        
        // RECFAX 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
    
        // From and Ext (key From & Ext)
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
        //-------------------------------------------------------------------------------------------
        // Second Page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
        docu = new SCM_MergeFieldGroup();
        docu.label = 'The following document(s) are required';
        docu.headerText = 'Medical Information';
        //docu.displayLabel = true;       
        //docu.headerText = 'The Payor will continue the medical review upon receipt of the following additional document(s):';
        docu.key = 'Documentation';
        
        //-------------------------------------------------------------------------------------------
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
        //-------------------------------------------------------------------------------------------
        //  1. Initial History and Physical
        UI_InitialHistoryPhysical = new SCM_MergeFieldCheckbox('UI_InitialHistoryPhysical', 'Initial History and Physical');       
        UI_InitialHistoryPhysical.fieldValue = '• Initial History and Physical \r\n';
        UI_InitialHistoryPhysical.totalWidth = '400';
        //UI_InitialHistoryPhysical.isNewLine=true;
        docu.subFields.add(UI_InitialHistoryPhysical);

        //-------------------------------------------------------------------------------------------
        //  2. Pathology Reports: 
        UI_PathologyReports = new SCM_MergeFieldCheckbox('UI_PathologyReports', 'Pathology Reports: ');
        UI_PathologyReports.fieldValue = '• Pathology Reports: ';
        UI_PathologyReports.totalWidth = '130'; 
        //UI_PathologyReports.isNewLine = true;   
        docu.subFields.add(UI_PathologyReports);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('UI_PathologyReports_Txt', ' ');
        OtherDoc1.isNewLine = false;
        OtherDoc1.totalWidth = '270';
        //OtherDoc1.requireNewLineInTemplate = false;
    OtherDoc1.requireNewLineInTemplate = true; 
        //docu.subFields.add(NewMergefield(' \r\n','PathoReports','PathoReports'));
    
        docu.subFields.add(OtherDoc1);  
        
        //-------------------------------------------------------------------------------------------
        //  3. UI_SMN
        UI_SMN = new SCM_MergeFieldCheckbox('UI_SMN', 'SMN');          
        UI_SMN.fieldValue = '• SMN \r\n';       
        UI_SMN.totalWidth = '400';
        //UI_SMN.isNewLine=true;
      
        docu.subFields.add(UI_SMN);

        //-------------------------------------------------------------------------------------------
        //  4. Prior Treatment: 
        UI_PriorTreatments = new SCM_MergeFieldCheckbox('UI_PriorTreatments', 'Prior Treatments: ');          
        UI_PriorTreatments.fieldValue = '• Prior Treatments: ';       
        UI_PriorTreatments.totalWidth = '130';
        //UI_PriorTreatments.requireNewLineInTemplate = true;
        //UI_PriorTreatments.isNewLine=true;
        docu.subFields.add(UI_PriorTreatments);
       
        OtherDoc2 = new SCM_MF_OtherDocuments('UI_PriorTreatments_Txt', ' ');
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
      	//OtherDoc2.requireNewLineInTemplate = true;
        docu.subFields.add(OtherDoc2);  
        
        //-------------------------------------------------------------------------------------------
        //  5. Physician Notes:    
        UI_PhysicianNotes = new SCM_MergeFieldCheckbox('UI_PhysicianNotes', 'Physician Notes: ');          
        UI_PhysicianNotes.fieldValue = '• Physician Notes: ';       
        UI_PhysicianNotes.totalWidth = '130';
        //UI_PhysicianNotes.requireNewLineInTemplate = true;
        //UI_PhysicianNotes.isNewLine=true;
        docu.subFields.add(UI_PhysicianNotes);

        OtherDoc3 = new SCM_MF_OtherDocuments('UI_PhysicianNotes_Txt', ' ');
        OtherDoc3.isNewLine = false;
        OtherDoc3.totalWidth = '270';
        //OtherDoc3.requireNewLineInTemplate = true;
        docu.subFields.add(OtherDoc3);  
        
        //-------------------------------------------------------------------------------------------
        //  6. CT Scans:      
        UI_CTScans = new SCM_MergeFieldCheckbox('UI_CTScans', 'CT Scans:');         
        UI_CTScans.fieldValue = '• CT Scans:';     
        UI_CTScans.totalWidth = '130';
        //UI_CTScans.requireNewLineInTemplate = false;
        //UI_CTScans.isNewLine=true;
        docu.subFields.add(UI_CTScans);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('UI_CTScans_Txt', '');
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        //OtherDoc4.requireNewLineInTemplate = true;
        docu.subFields.add(OtherDoc4);  

        //-------------------------------------------------------------------------------------------
        // 7.  Infusion Records:
        UI_InfusionsRecords = new SCM_MergeFieldCheckbox('UI_InfusionsRecords', 'Infusion Records: ');            
        UI_InfusionsRecords.fieldValue = '• Infusion Records: ';      
        UI_InfusionsRecords.totalWidth = '130';
        //UI_InfusionsRecords.isNewLine=true;
        docu.subFields.add(UI_InfusionsRecords);
        
        OtherDoc5 = new SCM_MF_OtherDocuments('UI_InfusionsRecords_Txt', ' ');
        OtherDoc5.isNewLine = false;
        OtherDoc5.totalWidth = '270';
        //OtherDoc5.requireNewLineInTemplate = true;
    
        docu.subFields.add(OtherDoc5);  
        
        //-------------------------------------------------------------------------------------------
        //  8. Rheumatoid Factor
        UI_RheumatoidFactor = new SCM_MergeFieldCheckbox('UI_RheumatoidFactor', 'Rheumatoid Factor');         
        UI_RheumatoidFactor.fieldValue = '• Rheumatoid Factor \r\n';      
        UI_RheumatoidFactor.totalWidth = '400';
        //UI_RheumatoidFactor.isNewLine=true;
        docu.subFields.add(UI_RheumatoidFactor);
        
        //-------------------------------------------------------------------------------------------
        //  9. Erythrocyte Sedimentation Rate
        UI_ErythrocyteSedimentationRate = new SCM_MergeFieldCheckbox('UI_ErythrocyteSedimentationRate', 'Erythrocyte Sedimentation Rate');         
        UI_ErythrocyteSedimentationRate.fieldValue = '• Erythrocyte Sedimentation Rate \r\n';      
        UI_ErythrocyteSedimentationRate.totalWidth = '400';
        //UI_ErythrocyteSedimentationRate.isNewLine=true;
        docu.subFields.add(UI_ErythrocyteSedimentationRate);

        //-------------------------------------------------------------------------------------------
        //  10. LABs:
        UI_LABs = new SCM_MergeFieldCheckbox('UI_LABs', 'LABs:');         
        UI_LABs.fieldValue = '• LABs: ';      
        UI_LABs.totalWidth = '130';
        //UI_LABs.isNewLine=true;
        docu.subFields.add(UI_LABs);
        
        OtherDoc6 = new SCM_MF_OtherDocuments('UI_LABs_Txt', '');
        OtherDoc6.isNewLine = false;
        OtherDoc6.totalWidth = '270';
        //OtherDoc6.requireNewLineInTemplate = true;
    
        docu.subFields.add(OtherDoc6);  
        
        //-------------------------------------------------------------------------------------------
        //  11. Explanation of Benefits (EOB)
        UI_ExpOfBenefits = new SCM_MergeFieldCheckbox('UI_ExpOfBenefits', 'Explanation of Benefits (EOBs)');         
        UI_ExpOfBenefits.fieldValue = '• Explanation of Benefits (EOBs) \r\n';      
        UI_ExpOfBenefits.totalWidth = '400';
        //UI_ExpOfBenefits.isNewLine=true;
        docu.subFields.add(UI_ExpOfBenefits);
        
        //-------------------------------------------------------------------------------------------
        //  12. Denial letter(s)
        UI_DenialLetter = new SCM_MergeFieldCheckbox('UI_DenialLetter', 'Denial Letter(s)');         
        UI_DenialLetter.fieldValue = '• Denial Letter(s) \r\n';      
        UI_DenialLetter.totalWidth = '400';
        //UI_DenialLetter.isNewLine=true;
        docu.subFields.add(UI_DenialLetter);
        
        //-------------------------------------------------------------------------------------------
        //  13. Denial letter(s)
        UI_PatientAuthoNoticeReleaseInfo = new SCM_MergeFieldCheckbox('UI_PatientAuthoNoticeReleaseInfo', 'Genentech Patient Authorization Notice of Release of Information (signed and dated)');         
        UI_PatientAuthoNoticeReleaseInfo.fieldValue = '• Genentech Patient Authorization Notice of Release of Information (signed and dated) \r\n';      
        UI_PatientAuthoNoticeReleaseInfo.totalWidth = '900';
        //UI_PatientAuthoNoticeReleaseInfo.isNewLine = true;
        docu.subFields.add(UI_PatientAuthoNoticeReleaseInfo);
        
        //-------------------------------------------------------------------------------------------
        //  14. C Reactive Protein
        UI_CReactiveProtein = new SCM_MergeFieldCheckbox('UI_CReactiveProtein', 'C Reactive Protein');         
        UI_CReactiveProtein.fieldValue = '• C Reactive Protein';      
        UI_CReactiveProtein.totalWidth = '250';
        //UI_CReactiveProtein.isNewLine = true;
        docu.subFields.add(UI_CReactiveProtein);
        
        //-------------------------------------------------------------------------------------------
        this.mergeFields.add(docu);
        //-------------------------------------------------------------------------------------------
        
         
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
    public override void getLatestValues()
    {    
        if(UI_InitialHistoryPhysical.checked == false 
            && UI_PathologyReports.checked == false 
            && UI_SMN.checked == false 
            && UI_PriorTreatments.checked == false 
            && UI_PhysicianNotes.checked == false 
            && UI_CTScans.checked == false 
            && UI_InfusionsRecords.checked == false 
            && UI_RheumatoidFactor.checked == false 
            && UI_ErythrocyteSedimentationRate.checked == false
            && UI_LABs.checked == false 
            && UI_ExpOfBenefits.checked == false 
            && UI_DenialLetter.checked == false 
            && UI_PatientAuthoNoticeReleaseInfo.checked == false 
            && UI_CReactiveProtein.checked == false )
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }
           
            if (UI_PathologyReports.checked==false)
            {
            	//docu.subFields.remove(2);
            	//docu.subFields.remove(3);
                OtherDoc1.mergeValue = '';
            }  
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
            
            if (UI_PathologyReports.checked && OtherDoc1.mergeValue == '')
            {
            	  UI_PathologyReports.requireNewLineInTemplate = true;
            }  
            if (UI_PriorTreatments.checked && OtherDoc2.mergeValue == ''){
            	
                UI_PriorTreatments.requireNewLineInTemplate = true;
            }
            if (UI_PhysicianNotes.checked && OtherDoc3.mergeValue == '')
            {
            	
                UI_PhysicianNotes.requireNewLineInTemplate = true;
            }
            
            if (UI_CTScans.checked && OtherDoc4.mergeValue == '')
            {
            
                UI_CTScans.requireNewLineInTemplate = true;
            }
            if (UI_InfusionsRecords.checked && OtherDoc5.mergeValue == ''){
                
                UI_InfusionsRecords.requireNewLineInTemplate = true;
            }
            if (UI_LABs.checked && OtherDoc6.mergeValue == ''){
                
                UI_LABs.requireNewLineInTemplate = true;
            }
            
           
    }
 
}