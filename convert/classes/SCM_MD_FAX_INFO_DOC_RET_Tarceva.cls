/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : 
    // PRODUCT GROUP     : Tarceva
    // Type              : Fax Coversheet
    // Word Template     : 01 –INFORMATION/DOCUMENTATION RETRIEVAL
   
/********************************************************************/    
public class SCM_MD_FAX_INFO_DOC_RET_Tarceva extends SCM_MergeDocument implements IStandardComboBox  {
    	public SCM_MD_FAX_INFO_DOC_RET_Tarceva(String caseId, String argLookupId) {
        super(caseId, argLookupId);
        }

    public override void createMergeFields()  {
    	String patientId = selectedCase.patient_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
       
    	//1.CaseNumber
    	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
    	
    	//2.PatientID
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
    	  
    	//3.TAR_GATCF_Phone key (GATCF_Phone)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
    	
    	//4.TAR_GATCF_Fax key (GATCF_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
    		
    	//5.URL(key GATCF_URL)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
    	
    	//DateShort
    	this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    	 
        //6.  Attn (key ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
      
        // Addressed To (key RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
          
        // Fax (key RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
        // From and EXt (key From & Ext)
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
       
      	
    	//PatientFullName(key Patient_First_And_Last_Name)
    	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
    	
    	//Patient DOB(key Patient_DOB)
    	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
    	 
    	//PRODUCT (key Product)
    	this.mergeFields.add(new SCM_MF_Product_Name(selectedCase));
    		
    	//PrivacyNotice 
    	this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
    	
    	//UI_PatientCoPhAlt
    	
    	//UI_PatientsICD
    	
    	//UI_DateandorPhySig
    	
    	//UI_GrossIncome100K
    	
    	//UI_CompleteRx
    	SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Additional Information Required:';       
        formInformation.key = 'Additional Information Required';
        
        SCM_MergeFieldCheckbox Checkbox1 = 
                new SCM_MergeFieldCheckbox('UI_PatientCoPhAlt',
                 'Patient Contact Number (alternative)');       
        Checkbox1.fieldValue = 
            'Patient Contact Number (alternative).\r\n';
        Checkbox1.totalWidth = '900';
        formInformation.subFields.add(Checkbox1);
                 
        SCM_MergeFieldCheckbox Checkbox2 = 
                new SCM_MergeFieldCheckbox('UI_PatientsICD','Patient ICD-9 Code / Diagnosis');
        Checkbox2.fieldValue = 'Patient'+'s ICD-9 code / Diagnosis.\r\n';
        Checkbox2.totalWidth = '900';        
        formInformation.subFields.add(Checkbox2);  
        
        SCM_MergeFieldCheckbox Checkbox3 = 
                new SCM_MergeFieldCheckbox('UI_DateandorPhySig','Date and/or Physician Signature ');
        Checkbox3.fieldValue = 'Date and/or Physician Signature.\r\n';
        Checkbox3.totalWidth = '900';        
        formInformation.subFields.add(Checkbox3);  
        
        SCM_MergeFieldCheckbox Checkbox4 = 
                new SCM_MergeFieldCheckbox('UI_GrossIncome100K','Patient'+'s must sign the income'+
                 ' verification certifying that the Household Adjusted Gross Income is less than $100,000');
        Checkbox4.fieldValue = 'Patient must sign the income verification certifying that the Household Adjusted Gross Income is less than $100,000.\r\n';
        Checkbox4.totalWidth = '900';        
        formInformation.subFields.add(Checkbox4); 
        
        SCM_MergeFieldCheckbox Checkbox5 = 
                new SCM_MergeFieldCheckbox('UI_CompleteRx','Complete Rx');
        Checkbox5.fieldValue = 'Complete Rx.\r\n';
        Checkbox5.totalWidth = '900';        
        formInformation.subFields.add(Checkbox5);  
                                     
        this.mergeFields.add(formInformation);
        
    	
    	//UI_Comments(Key CommentField)
        this.mergeFields.add(new SCM_MF_Comments());
    	
    	//ConfidNotice 
    	this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    
    }
    	 
 }