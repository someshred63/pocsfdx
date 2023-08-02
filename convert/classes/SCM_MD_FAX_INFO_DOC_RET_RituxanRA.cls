/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RA_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : Fax Coversheet
    // Word Template     : Information Documentation Retrieval Rituxan RA.doc
    // Label in SF       : 
/********************************************************************/
    
public class SCM_MD_FAX_INFO_DOC_RET_RituxanRA extends SCM_MergeDocument implements IStandardComboBox{
    public SCM_MD_FAX_INFO_DOC_RET_RituxanRA(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    } 
private SCM_MergeFieldCheckbox  UI_Prescriber;
     private SCM_MergeFieldCheckbox  UI_ShipLocation;

    public override void createMergeFields() {
       
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        //-------------------------------------------------------------------------------------------       
        // GATCF Phone (key GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        // GATCF Fax (key GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
         //Cr_URL (CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
       
        // GATCF URL (key GATCF_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Product Name 
        //this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
   		// 8 Drug(Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
    this.mergeRecipientInfo.add(new SCM_MF_Product_DrugType(selectedCase));
        //-------------------------------------------------------------------------------------------
        // PrivacyNotice (key PrivacyNotice)
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
        
        // Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Current Date (key Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
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
        
        // Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));

        // Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));


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
        //-------------------------------------------------------------------------------------------
        // Second Page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Additional Information Required:';
        docu.headerText = '';       
        //docu.headerText = 'The Payer will continue the medical review upon receipt of the following additional document(s):';
        docu.key = 'Documentation';

        //-------------------------------------------------------------------------------------------
        //  1. A completed Genentech Access To Care Foundation Application Form
        SCM_MergeFieldCheckbox Checkbox1 = new SCM_MergeFieldCheckbox('UI_CompletedGATCFApp', 'A Statement of Medical Necessity');       
        Checkbox1.fieldValue = 'A completed Statement of Medical Necessity \r\n';
        Checkbox1.totalWidth = '1200';
        docu.subFields.add(Checkbox1);

        //-------------------------------------------------------------------------------------------
        //  2. Genentech Patient Authorization Notification & Release of Information form
        SCM_MergeFieldCheckbox Checkbox2 = new SCM_MergeFieldCheckbox('UI_PANandReleaseofInfo', 'Genentech Patient Authorization Notification & Release of Information form');
        Checkbox2.fieldValue = 'Genentech Patient Authorization Notification & Release of Information form \r\n';
        Checkbox2.totalWidth = '1200';        
        docu.subFields.add(Checkbox2);  
        
        //-------------------------------------------------------------------------------------------
        //  3. UI_FlowSheetsInfusionRecords', 'The infusion record should provide the following details: \n Product name \n Dosage administered \n Date of administration
        SCM_MergeFieldCheckbox Checkbox3 = new SCM_MergeFieldCheckbox('UI_FlowSheetsInfusionRecords', 'Flow sheets/Infusion records that reflect administration of product');          
        Checkbox3.fieldValue = 'The infusion record should provide the following details:\r\n   Product name \r\n   Dosage administered \r\n   Date of administration \r\n';       
        Checkbox3.totalWidth = '1200';
        docu.subFields.add(Checkbox3);

        //-------------------------------------------------------------------------------------------
        //  4. Insurance denial letter/EOB or a statement on your office letterhead confirming patient's lack of insurance
        SCM_MergeFieldCheckbox Checkbox4 = new SCM_MergeFieldCheckbox('UI_InsDenialEOB', 'Insurance denial letter/EOB or a statement on your office letterhead confirming patient\'s lack of insurance');          
        Checkbox4.fieldValue = 'Insurance denial letter/EOB or a statement on your office letterhead confirming patient\'s lack of insurance \r\n';       
        Checkbox4.totalWidth = '1200';
        docu.subFields.add(Checkbox4);
       
        //-------------------------------------------------------------------------------------------
        //  5.  Patient's ICD-9 code/Diagnosis   
        SCM_MergeFieldCheckbox Checkbox5 = new SCM_MergeFieldCheckbox('UI_PatientsICD', 'Patient\'s ICD-9 code/Diagnosis');          
        Checkbox5.fieldValue = 'Patient\'s ICD-9 code/Diagnosis \r\n';       
        Checkbox5.totalWidth = '1200';
        docu.subFields.add(Checkbox5);
        
        //-------------------------------------------------------------------------------------------
        //  6.  Patient's Household Adjusted Gross Income is less than $100,000     
        SCM_MergeFieldCheckbox Checkbox6 = new SCM_MergeFieldCheckbox('UI_GrossIncome100K', 'Patient\'s Household Adjusted Gross Income is less than $100,000');         
        Checkbox6.fieldValue = 'Patient\'s Household Adjusted Gross Income is less than $100,000 \r\n';     
        Checkbox6.totalWidth = '1200';
        docu.subFields.add(Checkbox6);

        //-------------------------------------------------------------------------------------------
        // 7.  Shipping Instructions
        SCM_MergeFieldCheckbox Checkbox7 = new SCM_MergeFieldCheckbox('UI_ShippingInstructions', 'Shipping Instructions');            
        Checkbox7.fieldValue = 'Shipping Instructions \r\n';      
        Checkbox7.totalWidth = '1200';
        docu.subFields.add(Checkbox7);
        
        //-------------------------------------------------------------------------------------------
        //  8. Date and/or Physician Signature
        SCM_MergeFieldCheckbox Checkbox8 = new SCM_MergeFieldCheckbox('UI_DateandorPhySig', 'Date and/or Physician Signature');         
        Checkbox8.fieldValue = 'Date and/or Physician Signature \r\n';      
        Checkbox8.totalWidth = '1200';
        docu.subFields.add(Checkbox8);
        
        //-------------------------------------------------------------------------------------------
        this.mergeFields.add(docu);
        //-------------------------------------------------------------------------------------------
   
         
        
        
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
      public override void getLatestValues()
    {    
       
            
    }
}