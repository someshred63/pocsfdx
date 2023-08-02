/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : AVA - HER - RIT-CMGT-FAX-59 - GATCF Appeal
    //					   Cover Letter.doc
    // Product           : Oncology / Avastin, Herceptin, and Rituxan
    // Type				 : System Document
    // Word Template     : GATCFAppealCoverLetter.doc
    // Label in SF       : GATCF Appeal Cover Letter 
    
/********************************************************************/

public class SCM_MD_GATCFAppealCoverLet_AvHeRi extends SCM_MergeDocument {


	public SCM_MD_GATCFAppealCoverLet_AvHeRi(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            setRequireSystemDocUI(true);

	}

    public override void createMergeFields() 
    {
	    string patientId = selectedCase.patient_gne__r.Id;
	    string caseRecordType = selectedCase.RecordType.Name;
	    String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
	
		//Case ID
		this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
		// Patient Id
	    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
	
		//Date Long
		this.mergeRecipientInfo.add(new SCM_MF_DateLong());
	
		//CR URL
		this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));	
		
		//CR Fax
		this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
		
		//CR Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
		
		//Phys Contact Full Name
		this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));
		
		//Physician Full Name
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(physicianId));
		
		//Physician Last Name
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
		
		//Physician Title
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(physicianId));
		
		//Physician St Address
		this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
		
		//Physician City State Zip
		this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
		
		//Phys Contact Phone
		this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
		
		//Patient Full Name
	    this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId) );
		
		
		SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Appeal Cover Letter:';
        docu.key = 'Documentation';
        
        //TextBoxes 
        SCM_MergeField mfDeadline = new SCM_MF_OtherDocuments('UIDeadline', 'Deadline :');
        mfDeadline.isRequired = false;
        mfDeadline.fieldType = SCM_MergeField.Fieldtypes.dateField;
        mfDeadline.totalWidth = '440';
        mfDeadline.requireNewLineInTemplate = false;   
        docu.subFields.add(mfDeadline);
        this.mergeFields.add(docu);
		
		/**
		//SCM_MergeField mfDeadline =new SCM_MergeField();
		SCM_MergeField UIDatePayer = new SCM_MF_OtherDocuments('UI_DatePayer', 'Date Payor contacted :');
        UIDatePayer.isRequired = false;
        UIDatePayer.fieldType = SCM_MergeField.Fieldtypes.dateField;
        UIDatePayer.totalWidth = '440';
        docu.subFields.add(UIDatePayer);
		//Configure mergefield…
		mfDeadline.displayTextBox = true;
		mfDeadline.displayLabel = true;
		mfDeadline.displayCheck = false;
		mfDeadline.isRequired = false;
		mfDeadline.key = 'UIDeadline';
		mfDeadline.label = 'Deadline'; // or set it based on the requirement
		mfDeadline.fieldType = SCM_MergeField.Fieldtypes.dateField;
		mfDeadline.fieldValue = ''; // Your default value for the textbox.
		//Add SCM_MergeField to the collection
		this.mergeFields.add(mfDeadline);		
		*/
		//Deadline
		//SCM_MergeField_Incomplete UIDeadline  = new SCM_MergeField_Incomplete('UIDeadline');
		//UIDeadline.fieldValue = '';
		//this.mergeRecipientInfo.add(UIDeadline);
		//Case Worker
		// From
		string recordType = selectedCase.RecordType.Name ;
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
		//this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));	
				
		//Comments.
		this.mergeFields.add(new SCM_MF_Comments());
	
	    // AppealSpecialist
        this.mergeRecipientInfo.add(new SCM_MF_AppealSpecialistCollection(selectedCase.Id));
	    }
}