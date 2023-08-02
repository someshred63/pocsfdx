/**************************************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : RAP-CMGT-FAX-28 REFERRAL FOR INJECTION TRAINING.doc
    // Type              : Fax Coversheet
    // Word Template     : FAX_REFERRAL_FOR_INJECTION_TRAINING.doc    
    // Label in SF       : Referral For Injection Training
    
/*************************************************************************************/


public class SCM_MD_Fax_RefForInjTraining_Rap extends SCM_MergeDocument {
    
    private String caseRecordType;
    private SCM_MergeSection UI_AttachedDocsInfo;
    private SCM_MergeSection UI_PatientDemDocInfo;
    private SCM_MergeSection UI_ValidPrespDocInfo;
   
    
    private SCM_MergeFieldCheckbox UI_PatientDemDocChk;
    private SCM_MergeFieldCheckbox UI_ValidPrespDocChk;
  
    
    public SCM_MD_Fax_RefForInjTraining_Rap(String caseID, String argLookupId) {
        super(caseID, argLookupId);
        caseId = caseID;
    }
    
    public override void createMergeFields() {
            
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String pid = selectedCase.patient_gne__r.id;
        // 0 Case Number
        SCM_MF_CaseNumber caseNumber = new SCM_MF_CaseNumber(selectedCase);
        this.mergeRecipientInfo.add(caseNumber);          
         
        // 1 Patient Number
        SCM_MF_PatientId patientID = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patientId);   
        
        // 2. CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
       //CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
     
        
        // 3. CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // 4. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
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
        
         //10 DateShort(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        
        //12 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        //13 Patient Full Address(PatientAddressCityStateZip)
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(pid));
         
        // 14 Patient Prime Contact FullName(PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(pId));
         
        // 15 Patient Prime Contact Home Phone number(Pat_Home_Ph)  
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(pId));
        
        // 16 Patient Prime contact Work Phone Number(Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(pId));
    
        // PatientPrimeConOthPh (key Pat_Other_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientOtherPhone(pid));
        
        // 17. Physician Full Name(Key:Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
    
        // 18. 9 Physician phone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
             
        //19 Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));     
        
        
        //------------------------------------------Second Screen ------------------------------------------//
        
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Form Information'; 
        formInfo.label='Documents Attached';              
        formInfo.key = 'Form Information';
        
        //Checkboxes
      
        UI_PatientDemDocChk = 
            new SCM_MergeFieldCheckbox('UI_PatientDemDocChk',
                'Patient demographic information on SMN or other document.');
        UI_PatientDemDocChk.fieldValue = '' ;                    
        UI_PatientDemDocChk.totalWidth = '900';
        formInfo.subFields.add(UI_PatientDemDocChk); 
        
        UI_ValidPrespDocChk = 
           new SCM_MergeFieldCheckbox('UI_ValidPrespDocChk',
                    'Valid Prescription for drug, for which teaching will be provided.');
        UI_ValidPrespDocChk.fieldValue = '' ;                    
        UI_ValidPrespDocChk.totalWidth = '900';
        formInfo.subFields.add(UI_ValidPrespDocChk); 
        
      
                    
        this.mergeFields.add(formInfo); 
        
        //Merge Sections       
        UI_AttachedDocsInfo = new SCM_MergeSection();        
        UI_AttachedDocsInfo.key = 'UI_AttachedDocs';
        this.mergeSections.add(UI_AttachedDocsInfo);
        
        UI_PatientDemDocInfo = new SCM_MergeSection();        
        UI_PatientDemDocInfo.key = 'UI_PatientDemDoc';
        this.mergeSections.add(UI_PatientDemDocInfo);
        
        UI_ValidPrespDocInfo = new SCM_MergeSection();        
        UI_ValidPrespDocInfo.key = 'UI_ValidPrespDoc';
        this.mergeSections.add(UI_ValidPrespDocInfo);
        
        //comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
     
    public override void getLatestValues()
    {
        if(UI_PatientDemDocChk.checked==false || UI_ValidPrespDocChk.checked==false)

        {   
            UI_AttachedDocsInfo.visible = false;
        }
        else
        {
            UI_AttachedDocsInfo.visible=true;
        }
       if(UI_PatientDemDocChk.checked==false )
        {   
            UI_PatientDemDocInfo.visible = false;
        }
        else
        {
            UI_PatientDemDocInfo.visible=true;
        }
        if(UI_ValidPrespDocChk.checked==false)

        {   
            UI_ValidPrespDocInfo.visible = false;
        }
        else
        {
            UI_ValidPrespDocInfo.visible=true;
        }
        
    }

}