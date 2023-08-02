/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : RA-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION.doc
    // Type				 : Fax Coversheet
    // Word Template     : CMGT-FAX-17-RequestForPriorAuth-Predet-RitRA.doc    
    // Label in SF       : Request for Prior Authorization / Pre-Determination  
    
/********************************************************************/

public class SCM_MD_Fax_ReqForPriorAuthPret_RiRA extends SCM_MergeDocument {
	
	private SCM_MergeSection AttachedDocsInfo;
	
	private SCM_MergeField UIOtherDoc2;
	private SCM_MergeField UIOtherDoc4;
	private SCM_MergeField UIOtherDoc5;
	private SCM_MergeField UIOtherDoc6;
	private SCM_MergeField UIOtherDoc7;
	private SCM_MergeField UIOtherDoc10;
	
	private SCM_MergeFieldCheckbox IntialHisPhyChk;
	private SCM_MergeFieldCheckbox PathologyReportsChk;
	private SCM_MergeFieldCheckbox SMNChk;
	private SCM_MergeFieldCheckbox PriorTreatmentsChk;
	private SCM_MergeFieldCheckbox PhysicianNotesChk;
	private SCM_MergeFieldCheckbox CTScansChk;
	private SCM_MergeFieldCheckbox InfusionRecordsChk;
	private SCM_MergeFieldCheckbox RheumatoidFactorChk;
	private SCM_MergeFieldCheckbox ESRChk;
	private SCM_MergeFieldCheckbox LABsChk;
	private SCM_MergeFieldCheckbox EOBChk;
	private SCM_MergeFieldCheckbox DenialLettersChk;
	private SCM_MergeFieldCheckbox PatientAuthChk;
	private SCM_MergeFieldCheckbox CReactiveProteinChk;
	
	public SCM_MD_Fax_ReqForPriorAuthPret_RiRA(String caseId, String argLookupId) {
		super(caseId, argLookupId);
	}
 
	public override void createMergeFields() {
				       
        String pid = selectedCase.Patient_gne__c;
        String caseRecordType = selectedCase.RecordType.Name ;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));        
        // 2 CR_Phone(CR_Phone)
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));        
        // 3 CR_Fax(CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));         
        // 4 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
       // Attn (Key: 'ATTN_PA')
        //this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceContactNamePA(selectedCase.Id));       
        this.mergeRecipientInfo.add(new SCM_MF_InsPAContactName(selectedCase.Id));
        
        //RECNAME_Payor
        this.mergeRecipientInfo.add(new SCM_MF_InsPAPayor(selectedCase.Id));
        
		//RECFAX_PA
		this.mergeRecipientInfo.add(new SCM_MF_InsPAContactFax(selectedCase.Id));
	
        // 8 From(From)         
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        // 9 Extension(Ext)
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
        //10 DateShort(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());        
        //11 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        //12 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
          // SubscriberID_PA (Key: 'SubscriberID_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPASubscriberId(selectedCase.Id));
        
        // GroupNum_PA (Key: 'GroupNum_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAGroupNum(selectedCase.Id));
        
        //15 PolicyNum_PA(PolicyNum_PA)
        this.mergeRecipientInfo.add(new SCM_MF_PolicyNumPA(selectedcase.id));//Policy_Num
     
       /**
        //13 SubscriberID_PA(SubscriberID_PA)
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberID_PA(selectedcase.id));
        //14 GroupNum_PA(GroupNum_PA)
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNum_PA(selectedcase.id));
        */
        //15 PolicyNum_PA(PolicyNum_PA)
        //this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.PolicyNum_PA(selectedcase.id));
        
        //16 Confidential Notice(ConfidNotice)
		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
		 this.mergeimages.add(new SCM_MI_LOGO(selectedCase));  
		//-------------------------------------------------------------------------------------------
		
		//------------------------------Second Screen------------------------------------------
		
		// Medical Information       
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.label = 'Medical Information:';
        formInfo.headerText = 'The following document(s) are required ';       
        formInfo.key = 'Medical Information';
        
        // UI_AttachedDocs  
        // Merge Section
        AttachedDocsInfo = new SCM_MergeSection();                 
        AttachedDocsInfo.key = 'UI_AttachedDocs';
        this.mergeSections.add(AttachedDocsInfo);
        
        // Check Boxes
        //1  UI_IntialHisPhy
        IntialHisPhyChk = 
                new SCM_MergeFieldCheckbox('UI_IntialHisPhy','Initial History and Physical');       
        IntialHisPhyChk.fieldValue = 'Initial History and Physical \r\n';
        IntialHisPhyChk.totalWidth = '400';        
        formInfo.subFields.add(IntialHisPhyChk);
        
        //2 UI_PathologyReports
        PathologyReportsChk = 
                new SCM_MergeFieldCheckbox('UI_PathologyReports','Pathology Reports');       
        PathologyReportsChk.fieldValue = 'Pathology Reports  ';
        PathologyReportsChk.totalWidth = '230';        
        formInfo.subFields.add(PathologyReportsChk);
        
        UIOtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        UIOtherDoc2.isNewLine = false;
        UIOtherDoc2.totalWidth = '270';
        formInfo.subFields.add(UIOtherDoc2);
        
        //3 UI_SMN
        SMNChk = new SCM_MergeFieldCheckbox('UI_SMN','SMN');       
        SMNChk.fieldValue = 'SMN \r\n';
        SMNChk.totalWidth = '400';        
        formInfo.subFields.add(SMNChk);
        
        //4 UI_PriorTreatments
        PriorTreatmentsChk = 
                new SCM_MergeFieldCheckbox('UI_PriorTreatments','Prior Treatments');       
        PriorTreatmentsChk.fieldValue = 'Prior Treatments ';
        PriorTreatmentsChk.totalWidth = '230';        
        formInfo.subFields.add(PriorTreatmentsChk);
        
        UIOtherDoc4 = new SCM_MF_OtherDocuments('UI_OtherDoc4', '');
        UIOtherDoc4.isNewLine = false;
        UIOtherDoc4.totalWidth = '270';
        formInfo.subFields.add(UIOtherDoc4);
        
        //5 UI_PhysicianNotes
        PhysicianNotesChk = 
                new SCM_MergeFieldCheckbox('UI_PhysicianNotes','Physician Notes');       
        PhysicianNotesChk.fieldValue = 'Physician Notes ';
        PhysicianNotesChk.totalWidth = '230';        
        formInfo.subFields.add(PhysicianNotesChk);
        
        UIOtherDoc5 = new SCM_MF_OtherDocuments('UI_OtherDoc5', '');
        UIOtherDoc5.isNewLine = false;
        UIOtherDoc5.totalWidth = '270';
        formInfo.subFields.add(UIOtherDoc5);
        
        //6 UI_CTScans
        CTScansChk = new SCM_MergeFieldCheckbox('UI_CTScans','CT Scans');       
        CTScansChk.fieldValue = 'CT Scans ';
        CTScansChk.totalWidth = '230';        
        formInfo.subFields.add(CTScansChk);
        
        UIOtherDoc6 = new SCM_MF_OtherDocuments('UI_OtherDoc6', '');
        UIOtherDoc6.isNewLine = false;
        UIOtherDoc6.totalWidth = '270';
        formInfo.subFields.add(UIOtherDoc6);
        
        //7 UI_InfusionRecords
        InfusionRecordsChk = 
                new SCM_MergeFieldCheckbox('UI_InfusionRecords','Infusion Records');       
        InfusionRecordsChk.fieldValue = 'Infusion Records ';
        InfusionRecordsChk.totalWidth = '230';        
        formInfo.subFields.add(InfusionRecordsChk);
        
        UIOtherDoc7 = new SCM_MF_OtherDocuments('UI_OtherDoc7', '');
        UIOtherDoc7.isNewLine = false;
        UIOtherDoc7.totalWidth = '270';
        formInfo.subFields.add(UIOtherDoc7);
        
        //8 UI_RheumatoidFactor
		RheumatoidFactorChk = 
                new SCM_MergeFieldCheckbox('UI_RheumatoidFactor','Rheumatoid Factor');       
        RheumatoidFactorChk.fieldValue = 'Rheumatoid Factor \r\n';
        RheumatoidFactorChk.totalWidth = '400';        
        formInfo.subFields.add(RheumatoidFactorChk);
        
        //9 UI_ESR
        ESRChk = new SCM_MergeFieldCheckbox('UI_ESR','Erythrocyte Sedimentation Rate');       
        ESRChk.fieldValue = 'Erythrocyte Sedimentation Rate \r\n';
        ESRChk.totalWidth = '400';        
        formInfo.subFields.add(ESRChk);
        
        //10 UI_LABs
        LABsChk = new SCM_MergeFieldCheckbox('UI_LABs','LABs');       
        LABsChk.fieldValue = 'LABs ';
        LABsChk.totalWidth = '230';        
        formInfo.subFields.add(LABsChk);
        
        UIOtherDoc10 = new SCM_MF_OtherDocuments('UI_OtherDoc10', '');
        UIOtherDoc10.isNewLine = false;
        UIOtherDoc10.totalWidth = '270';
        formInfo.subFields.add(UIOtherDoc10);
        
        //11 UI_EOB
        EOBChk = new SCM_MergeFieldCheckbox('UI_EOB','Explanation of Benefits (EOBs)');       
        EOBChk.fieldValue = 'Explanation of Benefits (EOBs) \r\n';
        EOBChk.totalWidth = '400';        
        formInfo.subFields.add(EOBChk);
        
        //12 UI_DenialLetters
        DenialLettersChk = new SCM_MergeFieldCheckbox('UI_DenialLetters','Denial Letter(s)');       
        DenialLettersChk.fieldValue = 'Denial Letters \r\n';
        DenialLettersChk.totalWidth = '400';        
        formInfo.subFields.add(DenialLettersChk);
        
        //13 UI_PatientAuth
        PatientAuthChk = 
        	new SCM_MergeFieldCheckbox('UI_PatientAuth','Patient Authorization Notice of Release of Information (signed & dated)');       
        PatientAuthChk.fieldValue = 'Patient Authorization Notice of Release of Information (signed & dated) \r\n';
        PatientAuthChk.totalWidth = '500';        
        formInfo.subFields.add(PatientAuthChk);
        
         //14 UI_CReactiveProtein
        CReactiveProteinChk = new SCM_MergeFieldCheckbox('UI_CReactiveProtein','C Reactive Protein');       
        CReactiveProteinChk.fieldValue = 'C Reactive Protein \r\n';
        CReactiveProteinChk.totalWidth = '400';        
        formInfo.subFields.add(CReactiveProteinChk);
        
        this.mergeFields.add(formInfo);
        
        // Comments
        this.mergeFields.add(new SCM_MF_Comments());
                        
	}
	
	 public override void getLatestValues()  {
        	
        	if ( (IntialHisPhyChk.checked == false)&&
        		(PathologyReportsChk.checked == false)&&
        		(SMNChk.checked == false)&&
        		(PriorTreatmentsChk.checked == false)&&
        		(PhysicianNotesChk.checked == false)&&
        		(CTScansChk.checked == false)&&
        		(InfusionRecordsChk.checked == false)&&
        		(RheumatoidFactorChk.checked == false)&&
        		(ESRChk.checked == false)&&
        		(LABsChk.checked == false)&&
        		(EOBChk.checked == false)&&
        		(DenialLettersChk.checked == false)&&
        		(PatientAuthChk.checked == false)&&
        		(CReactiveProteinChk.checked == false))
        		{
        			AttachedDocsInfo.visible = false;
        		}
        	else
        	{
        			AttachedDocsInfo.visible = true;
        	}	
     	if (PathologyReportsChk.checked==false)
            UIOtherDoc2.mergeValue = '';  
            if (PriorTreatmentsChk.checked==false)
              UIOtherDoc4.mergeValue = '';
            if (PhysicianNotesChk.checked==false)
            UIOtherDoc5.mergeValue = '';
            if (CTScansChk.checked==false)
            UIOtherDoc6.mergeValue = '';
            if (InfusionRecordsChk.checked==false)
            UIOtherDoc7.mergeValue = '';
            if (LABsChk.checked==false)
            UIOtherDoc10.mergeValue = '';
            
            if (PathologyReportsChk.checked && UIOtherDoc2.mergeValue == '')
            {
            	  PathologyReportsChk.requireNewLineInTemplate = true;
            }  
            if (PriorTreatmentsChk.checked && UIOtherDoc4.mergeValue == ''){
            	
                PriorTreatmentsChk.requireNewLineInTemplate = true;
            }
            if (PhysicianNotesChk.checked && UIOtherDoc5.mergeValue == '')
            {
            	
                PhysicianNotesChk.requireNewLineInTemplate = true;
            }
            
            if (CTScansChk.checked && UIOtherDoc6.mergeValue == '')
            {
            
                CTScansChk.requireNewLineInTemplate = true;
            }
            if (InfusionRecordsChk.checked && UIOtherDoc7.mergeValue == ''){
                
                InfusionRecordsChk.requireNewLineInTemplate = true;
            }
            if (LABsChk.checked && UIOtherDoc10.mergeValue == ''){
                
                LABsChk.requireNewLineInTemplate = true;
            }
     	
     	
     	
        }
}