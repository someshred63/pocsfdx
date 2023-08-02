/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : PUL_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.docx
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type              : Fax Coversheet
    // Word Template     : INFODOCRETRIEVAL.doc    
    // Label in SF       : INFORMATION DOC RETRIEVAL
    
/********************************************************************/

public class SCM_MD_FAX_INF_DOC_RET_PUL extends SCM_MergeDocument implements IStandardComboBox
  { 
    public SCM_MD_FAX_INF_DOC_RET_PUL(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
        
    public override void createMergeFields() {
        
        String patientNumber = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String productName = selectedCase.Product_gne__c;
        String caseRecordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;


        // Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));   
        
        // Phone 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));

        // Fax (800) 963-1792
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));

        // URL www.PulmozymeAccessSolutions.com
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));

        //6. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));               
                    
                        
        //7. Addressed To 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //8.Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
                 
        //9 From Ext
        if (caseRecordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (caseRecordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }

        // Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
       //11. Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
                 
        //12. DOB DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
        

        // Product Name
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase)); 
        
        // Privacy Notice    
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        // Confidentiality Notice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //-------------------------------------------------------------------------------------------
        //second page
        //-------------------------------------------------------------------------------------------
       
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Additional Information Required:';
        docu.headerText = '';       
        //docu.headerText = 'The Payor will continue the medical review upon receipt of the following additional document(s):';
        docu.key = 'Documentation';
        
        //-------------------------------------------------------------------------------------------
        //  Line 1
        //  Shipping Date
        SCM_MergeFieldCheckbox Checkbox1 = 
                new SCM_MergeFieldCheckbox('ShippingDate', 'Shipping Date');       
        Checkbox1.fieldValue = 'Shipping Date \r\n';
        Checkbox1.totalWidth = '900';
        docu.subFields.add(Checkbox1);
  
        //-------------------------------------------------------------------------------------------
        //  Ship To Physician’s Office or Patient’s Home
        SCM_MergeFieldCheckbox Checkbox2 = 
                new SCM_MergeFieldCheckbox('ShipToPhyOffice', 'Ship to Physician’s Office or Patient’s Home');
        Checkbox2.fieldValue = 'Ship to Physician’s Office or Patient’s Home \r\n';
        Checkbox2.totalWidth = '900';        
        docu.subFields.add(Checkbox2); 
            
        //-------------------------------------------------------------------------------------------
        //  Patient Name
        SCM_MergeFieldCheckbox Checkbox3 = 
                new SCM_MergeFieldCheckbox('PatientName', 'Patient Name');          
        Checkbox3.fieldValue = 'Patient Name \r\n';       
        Checkbox3.totalWidth = '900';
        docu.subFields.add(Checkbox3);
     
        //-------------------------------------------------------------------------------------------
        //  Patient Address
        SCM_MergeFieldCheckbox Checkbox4 = new SCM_MergeFieldCheckbox('PatientAddress', 'Patient Address');          
        Checkbox4.fieldValue = 'Patient Address \r\n';       
        Checkbox4.totalWidth = '900';
        docu.subFields.add(Checkbox4);
         
        //-------------------------------------------------------------------------------------------
        //  Patient Home Phone   
        SCM_MergeFieldCheckbox Checkbox5 = 
            new SCM_MergeFieldCheckbox('PatientHomePhone', 'Patient Home Phone');          
        Checkbox5.fieldValue = 'Patient Home Phone \r\n';       
        Checkbox5.totalWidth = '900';
        docu.subFields.add(Checkbox5);
         
        //-------------------------------------------------------------------------------------------
        //  Patient Contact Number (Alternative)      
        SCM_MergeFieldCheckbox Checkbox6 = 
            new SCM_MergeFieldCheckbox('PatientContactNumber', 'Patient Contact Number (Alternative)');         
        Checkbox6.fieldValue = 'Patient Contact Number (Alternative) \r\n';     
        Checkbox6.totalWidth = '900';
        docu.subFields.add(Checkbox6);
 
        //-------------------------------------------------------------------------------------------
        //  Patient Date of Birth
        SCM_MergeFieldCheckbox Checkbox7 = new SCM_MergeFieldCheckbox('PatientDOB', 'Patient Date of Birth');            
        Checkbox7.fieldValue = 'Patient Date of Birth \r\n';      
        Checkbox7.totalWidth = '900';
        docu.subFields.add(Checkbox7);
            
        //-------------------------------------------------------------------------------------------
        //  Diagnosis
        SCM_MergeFieldCheckbox Checkbox8 = 
            new SCM_MergeFieldCheckbox('Diagnosis', 'Diagnosis');         
        Checkbox8.fieldValue = 'Diagnosis \r\n';      
        Checkbox8.totalWidth = '900';
        docu.subFields.add(Checkbox8);
            
        //-------------------------------------------------------------------------------------------
        //  Pulmozyme Regimen      
        SCM_MergeFieldCheckbox Checkbox9 = 
            new SCM_MergeFieldCheckbox('PulmozymeRegimen', 'Pulmozyme Regimen');            
        Checkbox9.fieldValue = 'Pulmozyme Regimen \r\n';       
        Checkbox9.totalWidth = '900';
        docu.subFields.add(Checkbox9);
           
        //-------------------------------------------------------------------------------------------
        //  Physician Name
        SCM_MergeFieldCheckbox Checkbox10 = 
            new SCM_MergeFieldCheckbox('PhysicianName', 'Physician Name');         
        Checkbox10.fieldValue = 'Physician Name \r\n';      
        Checkbox10.totalWidth = '900';
        docu.subFields.add(Checkbox10);
          
        //-------------------------------------------------------------------------------------------
        //  Physician Address      
        SCM_MergeFieldCheckbox Checkbox11 = 
            new SCM_MergeFieldCheckbox('PhysicianAddress', 'Physician Address');            
        Checkbox11.fieldValue = 'Physician Address \r\n';       
        Checkbox11.totalWidth = '900';
        docu.subFields.add(Checkbox11);
         
        //-------------------------------------------------------------------------------------------
        //  Physician Phone Number
        SCM_MergeFieldCheckbox Checkbox12 = 
            new SCM_MergeFieldCheckbox('PhysicianPhone', 'Physician Phone Number');         
        Checkbox12.fieldValue = 'Physician Phone Number \r\n';      
        Checkbox12.totalWidth = '900';
        docu.subFields.add(Checkbox12);
         
        //-------------------------------------------------------------------------------------------
        //  Physical Fax Number      
        SCM_MergeFieldCheckbox Checkbox13 = 
            new SCM_MergeFieldCheckbox('PhysicalFax', 'Physician Fax Number');            
        Checkbox13.fieldValue = 'Physician Fax Number \r\n';       
        Checkbox13.totalWidth = '900';
        docu.subFields.add(Checkbox13);
          
         //-------------------------------------------------------------------------------------------
        //  Nebulizer Type      
        SCM_MergeFieldCheckbox Checkbox14 = 
            new SCM_MergeFieldCheckbox('NebulizerType', 'Nebulizer Type');            
        Checkbox14.fieldValue = 'Nebulizer Type \r\n';       
        Checkbox14.totalWidth = '900';
        docu.subFields.add(Checkbox14);
          
         //-------------------------------------------------------------------------------------------
        //  Date of Physician Signature      
        SCM_MergeFieldCheckbox Checkbox15 = 
            new SCM_MergeFieldCheckbox('DatePhysicianSign', 'Date of Physician Signature');            
        Checkbox15.fieldValue = 'Date of Physician Signature \r\n';       
        Checkbox15.totalWidth = '900';
        docu.subFields.add(Checkbox15);
           
           this.mergeFields.add(docu);
           
         //-------------------------------------------------------------------------------------------
        //  Comments
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        
        //comments.label = 'Comments:';
        comments.headerText = 'Comments: ';       
        comments.key = 'Comments';                                  
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);

        
    } 
       
         
        
        
        
}