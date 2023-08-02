/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : RA-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis
    // PRODUCT GROUP     : Rituxan RA
    // Type              : FaxCoverSheet
    // Word Template     : 
   
/********************************************************************/    


public class SCM_MD_Fax08_Req_For_AddInfFnAna_RitRA extends SCM_MergeDocument implements IStandardComboBox  { 

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
    private SCM_MergeFieldCheckbox UI_PhysicianNotes;
    private SCM_MergeFieldCheckbox UI_CTScans;
    private SCM_MergeFieldCheckbox UI_InfusionsRecords;
    private SCM_MergeFieldCheckbox UI_LABs;
    private SCM_MergeFieldCheckbox UI_PriorTreatments;
   //only textboxes
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    private SCM_MF_OtherDocuments  OtherDoc4;   
    private SCM_MF_OtherDocuments  OtherDoc5;   
    private SCM_MF_OtherDocuments  OtherDoc6;
    private SCM_MergeFieldCheckbox  UI_Prescriber;
     private SCM_MergeFieldCheckbox  UI_ShipLocation;
  

    
    public SCM_MD_Fax08_Req_For_AddInfFnAna_RitRA(String caseId, String argLookupId){
    
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {

        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;    
    
    //1.CaseID
    this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
    
    //2.PatientID
    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
    
    //3.CR_Phone ( key CR_Phone)
    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
    
    //4.CR_Fax (key CR_Fax)
    this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
    //5.CR_URL ( key CR_URL)
    this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    
    //6.ATTN (key ATTN_Attn)
    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
   
    //7.RECNAME_FACPHY(key RECNAME_To)    
    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    
    //8.RECFAX (key RECFAX_Fax)
    this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
    
    //9.From //10.Ext 
      String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
    
    //11.DateShort
    this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
   
    //12.PatientFullName(key Patient_First_And_Last_Name)
    this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
   
    //13.DOB(key Patient_DOB)
    this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
    
    //14.DRUG (key DRUG)
    this.mergeRecipientInfo.add(new SCM_MF_DRUG(selectedCase));
   
    //15.PrivacyNotice
    this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
   this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
   this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
   
    //17.ConfidNotice
    this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
   this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
    
    //............All Check Boxes and TestBoxes................
    
    SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
    formInformation.headerText = 'Medical Information';       
    formInformation.key = 'Medical Information';    
    
        
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
     //ony checkboxes
     
        //UI_InitialHistoryPhysical
        UI_InitialHistoryPhysical = new SCM_MergeFieldCheckbox('UI_InitialHistoryPhysical','Initial History and Physical');       
        UI_InitialHistoryPhysical.fieldValue ='Initial History and Physical\r\n';
        UI_InitialHistoryPhysical.totalWidth = '600';
        UI_InitialHistoryPhysical.isNewLine = true;  
        formInformation.subFields.add(UI_InitialHistoryPhysical);
        
         //UI_PathologyReports  
        UI_PathologyReports = new SCM_MergeFieldCheckbox('UI_PathologyReports','Pathology Reports');       
        UI_PathologyReports.fieldValue ='Pathology Reports: ';
        UI_PathologyReports.totalWidth = '150';
        UI_PathologyReports.isNewLine = true;  
        formInformation.subFields.add(UI_PathologyReports);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('UI_PathologyReports_Txt', '');
        OtherDoc1.isNewLine = false;
        OtherDoc1.totalWidth = '270';
        OtherDoc1.width = '250';
    
        formInformation.subFields.add(OtherDoc1);
       
        
        //UI_SMN
        UI_SMN = new SCM_MergeFieldCheckbox('UI_SMN','SMN');       
        UI_SMN.fieldValue ='SMN\r\n';
        UI_SMN.totalWidth = '600';
        UI_SMN.isNewLine = true;  
        formInformation.subFields.add(UI_SMN);
      
        //UI_PriorTreatments
        UI_PriorTreatments = new SCM_MergeFieldCheckbox('UI_PriorTreatments','Prior Treatment');       
        UI_PriorTreatments.fieldValue ='Prior Treatment: ';
        UI_PriorTreatments.totalWidth = '150';
        UI_PriorTreatments.isNewLine = true;  
        formInformation.subFields.add(UI_PriorTreatments);
        
        OtherDoc6 = new SCM_MF_OtherDocuments('UI_PriorTreatments_Txt', '');
        OtherDoc6.isNewLine = false;
        OtherDoc6.totalWidth = '270';
        OtherDoc6.width = '250';
     
        formInformation.subFields.add(OtherDoc6);
      
        //UI_PhysicianNotes
        UI_PhysicianNotes = new SCM_MergeFieldCheckbox('UI_PhysicianNotes','Physician Notes');       
        UI_PhysicianNotes.fieldValue ='Physician Notes: ';
        UI_PhysicianNotes.totalWidth = '150';
        UI_PhysicianNotes.isNewLine = true; 
      
        formInformation.subFields.add(UI_PhysicianNotes);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('UI_PhysicianNotes_Txt', '');
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
        OtherDoc2.width = '250';
      
        formInformation.subFields.add(OtherDoc2);
     
       //UI_CTScans
        UI_CTScans = new SCM_MergeFieldCheckbox('UI_CTScans','CT Scans');       
        UI_CTScans.fieldValue ='CT Scans: ';
        UI_CTScans.totalWidth = '150';
        UI_CTScans.isNewLine = true;
         
        formInformation.subFields.add(UI_CTScans);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('UI_CTScans_Txt', '');
        OtherDoc3.isNewLine = false;
        OtherDoc3.totalWidth = '270';
        OtherDoc3.width = '250';
      
        formInformation.subFields.add(OtherDoc3);
      
      //UI_InfusionsRecords
        UI_InfusionsRecords = new SCM_MergeFieldCheckbox('UI_InfusionsRecords','Infusion Records');       
        UI_InfusionsRecords.fieldValue ='Infusion Records: ';
        UI_InfusionsRecords.totalWidth = '150';
        UI_InfusionsRecords.isNewLine = true;  
        
        formInformation.subFields.add(UI_InfusionsRecords);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('UI_InfusionsRecords_Txt', '');
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        OtherDoc4.width = '250';
    
        formInformation.subFields.add(OtherDoc4);
      
        //UI_RheumatoidFactor
        UI_RheumatoidFactor = new SCM_MergeFieldCheckbox('UI_RheumatoidFactor','Rheumatoid Factor');       
        UI_RheumatoidFactor.fieldValue ='Rheumatoid Factor\r\n';
        UI_RheumatoidFactor.totalWidth = '600';
        UI_RheumatoidFactor.isNewLine = true;  
        formInformation.subFields.add(UI_RheumatoidFactor);
      
        //UI_ErythrocyteSedimentationRate
        UI_ErythrocyteSedimentationRate = new SCM_MergeFieldCheckbox('UI_ErythrocyteSedimentationRate','Erythrocyte Sedimentation Rate');       
        UI_ErythrocyteSedimentationRate.fieldValue ='Erythrocyte Sedimentation Rate\r\n';
        UI_ErythrocyteSedimentationRate.totalWidth = '600';
        UI_ErythrocyteSedimentationRate.isNewLine = true;  
        formInformation.subFields.add(UI_ErythrocyteSedimentationRate);
      
      //UI_LABs
        UI_LABs = new SCM_MergeFieldCheckbox('UI_LABs','LABs');       
        UI_LABs.fieldValue ='LABs: ';
        UI_LABs.totalWidth = '150';
        UI_LABs.isNewLine = true;  
        formInformation.subFields.add(UI_LABs);
        
        OtherDoc5 = new SCM_MF_OtherDocuments('UI_LABs_Txt', '');
        OtherDoc5.isNewLine = false;
        OtherDoc5.totalWidth = '270';
        OtherDoc5.width = '250';
     
        formInformation.subFields.add(OtherDoc5);
        
   
        //UI_ExpOfBenefits
        UI_ExpOfBenefits = new SCM_MergeFieldCheckbox('UI_ExpOfBenefits','Explanation of Benefits (EOBs)');       
        UI_ExpOfBenefits.fieldValue ='Explanation of Benefits (EOBs)\r\n';
        UI_ExpOfBenefits.totalWidth = '600';
        UI_ExpOfBenefits.isNewLine = true;  
        formInformation.subFields.add(UI_ExpOfBenefits);
        
        //UI_DenialLetter
        UI_DenialLetter = new SCM_MergeFieldCheckbox('UI_DenialLetter','Denial letter(s)');       
        UI_DenialLetter.fieldValue ='Denial letter(s)\r\n';
        UI_DenialLetter.totalWidth = '600';
        UI_DenialLetter.isNewLine = true;  
        formInformation.subFields.add(UI_DenialLetter);
      
        //UI_PatientAuthoNoticeReleaseInfo
        UI_PatientAuthoNoticeReleaseInfo = new SCM_MergeFieldCheckbox('UI_PatientAuthoNoticeReleaseInfo','Genentech Patient Authorization Notice of Release of Information (signed and dated)');       
        UI_PatientAuthoNoticeReleaseInfo.fieldValue ='Genentech Patient Authorization Notice of Release of Information (signed & dated)\r\n';
        UI_PatientAuthoNoticeReleaseInfo.totalWidth = '600';
        UI_PatientAuthoNoticeReleaseInfo.isNewLine = true;  
        formInformation.subFields.add(UI_PatientAuthoNoticeReleaseInfo);
      
        //UI_CReactiveProtein
        UI_CReactiveProtein = new SCM_MergeFieldCheckbox('UI_CReactiveProtein','C Reactive Protein');       
        UI_CReactiveProtein.fieldValue ='C Reactive Protein\r\n';
        UI_CReactiveProtein.totalWidth = '600';
        UI_CReactiveProtein.isNewLine = true;  
        formInformation.subFields.add(UI_CReactiveProtein);
          
      this.mergeFields.add(formInformation);   
        
       //16.UI_Comments(Key CommentField)
      this.mergeFields.add(new SCM_MF_Comments());
   
      
      
    }  
      
      public override void getLatestValues()
      {    
            if(UI_InitialHistoryPhysical.checked == false && UI_PathologyReports.checked == false && UI_SMN.checked == false && UI_PriorTreatments.checked == false 
            && UI_PhysicianNotes.checked == false 
            && UI_CTScans.checked == false && UI_InfusionsRecords.checked == false && UI_RheumatoidFactor.checked == false && UI_ErythrocyteSedimentationRate.checked == false
            && UI_LABs.checked == false && UI_ExpOfBenefits.checked == false && UI_DenialLetter.checked == false && UI_PatientAuthoNoticeReleaseInfo.checked == false 
            && UI_CReactiveProtein.checked == false )
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
              OtherDoc6.mergeValue = '';
            if (UI_PhysicianNotes.checked==false)
            OtherDoc2.mergeValue = '';
            if (UI_CTScans.checked==false)
            OtherDoc3.mergeValue = '';
            if (UI_InfusionsRecords.checked==false)
            OtherDoc4.mergeValue = '';
            if (UI_LABs.checked==false)
            OtherDoc5.mergeValue = '';
            
            if (UI_PathologyReports.checked && OtherDoc1.mergeValue == '')
            {
            	  UI_PathologyReports.requireNewLineInTemplate = true;
            }  
            if (UI_PriorTreatments.checked && OtherDoc6.mergeValue == ''){
            	
                UI_PriorTreatments.requireNewLineInTemplate = true;
            }
            if (UI_PhysicianNotes.checked && OtherDoc2.mergeValue == '')
            {
            	
                UI_PhysicianNotes.requireNewLineInTemplate = true;
            }
            
            if (UI_CTScans.checked && OtherDoc3.mergeValue == '')
            {
            
                UI_CTScans.requireNewLineInTemplate = true;
            }
            if (UI_InfusionsRecords.checked && OtherDoc4.mergeValue == ''){
                
                UI_InfusionsRecords.requireNewLineInTemplate = true;
            }
            if (UI_LABs.checked && OtherDoc5.mergeValue == ''){
                
                UI_LABs.requireNewLineInTemplate = true;
            }
            
            
         
                
      
      }
      
}