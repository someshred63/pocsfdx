/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : NUT-CMGT-FAX-28 REFERRAL FOR INJECTION TRAINING
    // Product           : Growth Hormone / Nutropin
    // Type              : Fax Coversheet
    // Word Template     : CMGT-FAX-28-Referral For Injection Training 
    // Label in SF       : Referral For Injection Training. 
    
/********************************************************************/

public class SCM_MD_Fax_RefForInjTraining_Nut extends SCM_MergeDocument {
    
    private SCM_MergeFieldCheckbox UI_ObtainedCoverageChk;
    private SCM_MergeFieldCheckbox UI_PursuingCoverageChk;
    private SCM_MergeFieldCheckbox UI_NonNFDistributorChk;
    private SCM_MergeFieldCheckbox UI_PatientDemographicInfoChk;
    private SCM_MergeFieldCheckbox UI_ValidPrescriptionChk;
        
    private SCM_MergeSection UI_ObtainedCoverageSec;
    private SCM_MergeSection UI_PursuingCoverageSec;
    private SCM_MergeSection UI_NonNFDistributorSec;
    private SCM_MergeSection UI_DocumentsAttachedSec;
    private SCM_MergeSection UI_PatientDemographicInfoSec;
    private SCM_MergeSection UI_ValidPrescriptionSec;
    
    
    public SCM_MD_Fax_RefForInjTraining_Nut(String caseID, String argLookupId) {
        super(caseID, argLookupId); 
        caseId = caseID;       
    }
    
    public override void createMergeFields() {
       
       
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String pid = selectedCase.Patient_gne__c;
        String caseRecordType = selectedCase.RecordType.Name ;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));        
        // 2 CR_Phone(CR_PhoneShort)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));        
        // 3 CR_Fax(CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));         
        // 4 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //------------------------------------First Screen------------------------------------------------
        
        // Attn
        SCM_MergeField attn = new SCM_MF_Fax_AttnRefForInjTrain(selectedCase);
        attn.key = 'ATTN_Attn';
		this.mergeRecipientInfo.add(attn);
		
		// To
		this.mergeRecipientInfo.add(new SCM_MF_Fax_AddrToRefForInjTrain());
		
		// Fax
		this.mergeRecipientInfo.add(new SCM_MF_Fax_FaxRefForInjTrain(selectedCase));
		
        
        // 8 From(From)   9 Extension(Ext)
      
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        } 
        //--------------------------------------------------------------------------------------
        
         //10 DateShort(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        
        //12 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        //13 Patient Full Address(PatientAddressCityStateZip)
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(patientId));
         
        // 14 Patient Prime Contact FullName(PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(pId));
         
        // 15 Patient Prime Contact Home Phone number(Pat_Home_Ph)  
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(pId));
        
        // 16 Patient Prime contact Work Phone Number(Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(pId));
        
         //17 Confidential Notice(ConfidNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
         
        
        //----------------------------------------------------------------------------------
        
        //18. Pediatric(Key:Pediatric)
        this.mergeRecipientInfo.add(new SCM_MF_ChkPediatric(selectedCase));
        
        //19. Adult(Key:Adult)
        this.mergeRecipientInfo.add(new SCM_MF_ChkAdult(selectedCase));
        
        // 20 NewStart(NewStart)
        this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase,true,true));
        
        // 21 ContinuedTherapy(ContinuedTherapy)
        this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase,true,true));
        
        //-------------------------------------------------------------------------------------
        
         //22. SalesRepName(Key:SalesRepName)
        this.mergeRecipientInfo.add(SCM_MF_SalesFieldFactory.SalesRepName(selectedCase));
        
        //23. SalesRepEmail(Key:SalesRepEmail)
        this.mergeRecipientInfo.add(SCM_MF_SalesFieldFactory.SalesRepEmail(selectedCase));
      
        /**
        SCM_MergeField_Incomplete SalesRepName = new SCM_MergeField_Incomplete('SalesRepName');
        SalesRepName.key='SalesRepName';
        SalesRepName.checked = false;
        SalesRepName.displayCheck = false;
        SalesRepName.displayTextBox = false;
        SalesRepName.displayLabel = false;
        SalesRepName.fieldValue ='';         
        this.mergeRecipientInfo.add(SalesRepName);
        
        //23. SalesRepEmail(Key:SalesRepEmail)
        SCM_MergeField_Incomplete SalesRepEmail = new SCM_MergeField_Incomplete('SalesRepEmail');
        SalesRepEmail.key='SalesRepEmail';
        SalesRepEmail.checked = false;
        SalesRepEmail.displayCheck = false;
        SalesRepEmail.displayTextBox = false;
        SalesRepEmail.displayLabel = false;
        SalesRepEmail.fieldValue =''; 
        this.mergeRecipientInfo.add(SalesRepEmail);
        */
        //24. Physician Full Name(Key:Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //25. ConfidNotice(key:ConfidNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //-------------------------------Second Screen-----------------------------------------
        
         // Form Information
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Form Information:';               
        formInfo.key = 'Form Information';
        
        
        //Check boxes
     
        
     //Checkboxes
        // 1 UI_ObtainedCoverage
        UI_ObtainedCoverageChk = 
            new SCM_MergeFieldCheckbox('UI_ObtainedCoverage', 'Access Solutions has obtained coverage for the above growth hormone patient ');
        UI_ObtainedCoverageChk.fieldValue = '' ;                    
        UI_ObtainedCoverageChk.totalWidth = '900';
        formInfo.subFields.add(UI_ObtainedCoverageChk);
        
        // 2 UI_PursuingCoverage 
        UI_PursuingCoverageChk = new SCM_MergeFieldCheckbox('UI_PursuingCoverage','Access Solutions is pursuing coverage for the above growth hormone patient ');
        UI_PursuingCoverageChk.fieldValue = '' ;                    
        UI_PursuingCoverageChk.totalWidth = '900';
        formInfo.subFields.add(UI_PursuingCoverageChk);
        
        // 3 UI_NonNFDistributor
        UI_NonNFDistributorChk = new SCM_MergeFieldCheckbox('UI_NonNFDistributor',
                'The patient is utilizing a non-NF distributor. Please coordinate training per contact ');
        UI_NonNFDistributorChk.fieldValue = '' ;                    
        UI_NonNFDistributorChk.totalWidth = '900';
        formInfo.subFields.add(UI_NonNFDistributorChk);
        
          // Label
        SCM_MergeField DocAttached = new  SCM_MergeField();
        DocAttached.label = 'Documents Attached:';
        DocAttached.fieldValue = '';
        DocAttached.displayCheck = false;
        DocAttached.displayTextBox = false;
        DocAttached.isRequired=false;
        //DocAttached.isNewLine=false;    
        formInfo.subFields.add(DocAttached);  
        
        // 4 UI_PatientDemographicInfo
        UI_PatientDemographicInfoChk = new SCM_MergeFieldCheckbox('UI_PatientDemographicInfo',
                'Patient demographic info (on SMN or other document ');
        UI_PatientDemographicInfoChk.fieldValue = '' ;                    
        UI_PatientDemographicInfoChk.totalWidth = '900';
        //UI_PatientDemographicInfoChk.isNewLine=false;
        formInfo.subFields.add(UI_PatientDemographicInfoChk);
        
        // UI_ValidPrescription
       UI_ValidPrescriptionChk = new SCM_MergeFieldCheckbox('UI_ValidPrescription',
                '                    Valid prescription for drug, for which instruction will be provided ');
        UI_ValidPrescriptionChk.fieldValue = '' ;                    
        UI_ValidPrescriptionChk.totalWidth = '900';
        UI_ValidPrescriptionChk.isNewLine=true;
        formInfo.subFields.add(UI_ValidPrescriptionChk);
         
        this.mergeFields.add(formInfo);
        
        //comments
        //this.mergeFields.add(new SCM_MF_Comments());
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        comments.headerText = 'Comments: ';       
        comments.key = 'Comment';           
        
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        CommentField.key = 'Comments';                       
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments); 
        
        
        //---------------------merge sections
        
        
        // Merge Sections
               
        UI_ObtainedCoverageSec = new SCM_MergeSection();        
        UI_ObtainedCoverageSec.key = 'UI_ObtainedCoverage';
        this.mergeSections.add(UI_ObtainedCoverageSec);
        
        UI_PursuingCoverageSec = new SCM_MergeSection();        
        UI_PursuingCoverageSec.key = 'UI_PursuingCoverage';
        this.mergeSections.add(UI_PursuingCoverageSec); 
        
        UI_NonNFDistributorSec = new SCM_MergeSection();        
        UI_NonNFDistributorSec.key = 'UI_NonNFDistributor';
        this.mergeSections.add(UI_NonNFDistributorSec); 
        
        UI_DocumentsAttachedSec = new SCM_MergeSection();        
        UI_DocumentsAttachedSec.key = 'UI_DocumentsAttached';
        this.mergeSections.add(UI_DocumentsAttachedSec);
        
        UI_PatientDemographicInfoSec = new SCM_MergeSection();        
        UI_PatientDemographicInfoSec.key = 'UI_PatientDemographicInfo';
        this.mergeSections.add(UI_PatientDemographicInfoSec);
         
        UI_ValidPrescriptionSec = new SCM_MergeSection();        
        UI_ValidPrescriptionSec.key = 'UI_ValidPrescription';
        this.mergeSections.add(UI_ValidPrescriptionSec);
    
    }  
    
        public override void getLatestValues()  {
    
        UI_ObtainedCoverageSec.visible = UI_ObtainedCoverageChk.checked;
        UI_PursuingCoverageSec.visible = UI_PursuingCoverageChk.checked;  
        UI_NonNFDistributorSec.visible = UI_NonNFDistributorChk.checked;
        UI_PatientDemographicInfoSec.visible = UI_PatientDemographicInfoChk.checked;  
        UI_ValidPrescriptionSec.visible = UI_ValidPrescriptionChk.checked;
        
        if(UI_PatientDemographicInfoChk.checked == true || 
        UI_ValidPrescriptionChk.checked == true)
        {
        UI_DocumentsAttachedSec.visible = true; 
        }
        else
        { 
        UI_DocumentsAttachedSec.visible = false;
        }
         
        //mf1.selectedValue = mf1.selectionItems[1].getValue();
                               
        
                            
    }   


}