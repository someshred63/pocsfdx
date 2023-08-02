//********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : CMGT-FAX-03_RX to Specialty Pharmacy.doc
    // PRODUCT GROUP     : All
    // Type              : Fax coversheet
    // Word Template     : Rx to Specialty Pharmacy.doc   
    // Label in SF       : Rx to Specialty Pharmacy
    
//********************************************************************/

public class SCM_MD_CMGT_FAX_03_RX_SpecialtyPharmacy extends SCM_MergeDocument
{
   public SCM_MD_CMGT_FAX_03_RX_SpecialtyPharmacy(String caseID, String argLookupId)
    {
            super(caseID, argLookupId);
            caseId = caseID;            
    }
     public override void createMergeFields()  
    {
    	
        //0 Case ID
        mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //1 Patient ID
        mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
		//2 CR_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
       
        //3 CR_Fax      
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
          
        //4 CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        
        //5 Title03
        this.mergeRecipientInfo.add(new SCM_MF_Title03(selectedCase));
        
    	//6 PrivacyNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //7 ATTN
        this.mergeRecipientInfo.add(new SCM_MF_Fax_Attn_Pharmacy());
        
        //8 Addressed to 'RxCrossroads'
        this.mergeRecipientInfo.add(new SCM_MF_Fax_AddressedTo());
       
        //9 Fax
        // Fax No
		SCM_MergeField fax = new SCM_MergeField();
		fax.label='Fax Number:';
        fax.setFieldValue('(502)322-1331');
        fax.setKey('RECFAX_Fax1');     
        fax.checked = false;
        fax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;        
        fax.displayCheck = false;
        fax.displayTextBox = true;
        fax.displayLabel = true;
        fax.className = 'SCM_MergeField';
        this.mergeRecipientInfo.add(fax);
        
         //10, 11 Ext & From
         //Get Case.RecordType
        String caseRecordType = selectedCase.RecordType.Name;
        // 8 From(From) 
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        // 9 Extension(Ext)
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType)); 
        /**if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }**/
        
        
        //12 Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //13 Patient full name
        //SCM_MF_PatientFirstAndLastName patientFirstAndLastName = new SCM_MF_PatientFirstAndLastName(selectedCase);
        //patientFirstAndLastName.key='Name';
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id)); 
               
        
        //14 Patient DOB 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        //this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
       
        //15 Drug
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
         
        //---------------Second screen-----------------
        //SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        //formInformation.headerText = 'Comments';       
        //formInformation.key = 'Comments';
        //this.mergeFields.add(formInformation); 
        
        //16 SCM_MergeFieldGroup comments = new SCM_MF_Comments();        
        this.mergeFields.add(new SCM_MF_Comments()); 
        
        //17 CR_Logo
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
          
    }
  
}