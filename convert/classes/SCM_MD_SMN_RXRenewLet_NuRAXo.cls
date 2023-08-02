/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : Final Consolidated RAP XOL NUT-CMGT-FAX-73-SMN-Rx Renewal Letter.doc
    // PRODUCT GROUP     : Dermatology / Raptiva - Respiratory / Xolair - Growth Hormone / Nutropin
    // Type              : System Document
    // Word Template     : CMGT-FAX-73-SMNRx_Renewal_Letter.doc    
    // Label in SF       : SMN/Rx Renewal Letter 
  
/********************************************************************/

public class SCM_MD_SMN_RXRenewLet_NuRAXo extends SCM_MergeDocument 
{
    
 public SCM_MD_SMN_RXRenewLet_NuRAXo(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
     public override void createMergeFields() {
        
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
           
        //1. Case Number
        //this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //2. Patient Id              
        //this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
             
        //3. Date Long
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());        
   
        //4. DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
          
        /** SCM_MF_PatientDOB dob = new SCM_MF_PatientDOB(selectedCase.patient_gne__r.Id);
        String dobVal = dob.getFieldValue();             
        dob.fieldValue = dobVal ;
        this.mergeRecipientInfo.add(dob);
        */
   
        //5. Foundation Specialist        
        this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        
        /**
        SCM_MF_FoundationSplName FoundationSpecialist = new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
        
        FoundationSpecialist.key = 'Foundation_Specialist_Name';
        FoundationSpecialist.label='Foundation Specialist'; 
        FoundationSpecialist.className = 'SCM_MD_SMN_RXRenewLet_NuRAXo';        
        FoundationSpecialist.fieldValue= (FoundationSpecialist.getFieldValue() == null)? '': FoundationSpecialist.getFieldValue();  
        FoundationSpecialist.checked = false;
        FoundationSpecialist.displayCheck = false;
        FoundationSpecialist.displayTextBox = false;
        FoundationSpecialist.displayLabel = false;                         
        this.mergeRecipientInfo.add(FoundationSpecialist);  
        */
   
        //6. GATCF_Phone                       
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));       

        //-------------------------------------------------------------------------------------------
        //7. GATCF_Fax               
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));     
        
        //-------------------------------------------------------------------------------------------        
        //8. Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        /** 
        SCM_MF_PatientFirstAndLastName patientFirstAndLastName =
             new SCM_MF_PatientFirstAndLastName(selectedCase);
        String patientFirstAndLastNameVal = patientFirstAndLastName.getFieldValue();             
        patientFirstAndLastName.fieldValue = patientFirstAndLastNameVal ;
        this.mergeRecipientInfo.add(patientFirstAndLastName);
        */
   
        //9. Physician LastName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
      
       /**
        SCM_MF_PhysicianLastName  phyLastName  = 
            new SCM_MF_PhysicianLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
        String phyLastNameVal = phyLastName.getFieldValue();
        phyLastName.fieldValue = phyLastNameVal ;
        this.mergeRecipientInfo.add(phyLastName);
        */
      
        //10. Physician FaxBatch
        this.mergeRecipientInfo.add( SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
    
        /**
         SCM_MergeField phyFax = SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id);
        this.mergeRecipientInfo.add(phyFax);
        */
        Scm_mergeField dummy = SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id);
         dummy.displayTextBox = false;
        dummy.displayLabel = false;
        this.mergeRecipientInfo.add(dummy);
        
        //11. Physician FullName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        /**
        String phyFirstNameVal = '';
        String phyLastNmVal = '';
        String ToVal = '';
        SCM_MF_PhysicianFirstName phyFirstName = 
            new SCM_MF_PhysicianFirstName(selectedCase.Case_Treating_Physician_gne__r.Id);
        phyFirstNameVal = phyFirstName.getFieldValue();
        SCM_MF_PhysicianLastName  phyLastNm  = 
            new SCM_MF_PhysicianLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
        phyLastNmVal = phyLastNm.getFieldValue();
        ToVal = phyFirstNameVal;
        if (phyLastNmVal != ''){
            ToVal = ToVal + ' ' +  phyLastNmVal;
        }                     
        SCM_MergeField PhyFullName = new SCM_MergeField();
        PhyFullName.key = 'PhyFullName';
        PhyFullName.fieldValue = ToVal;   
        PhyFullName.displayCheck = false; 
        PhyFullName.displayTextBox = false;
        PhyFullName.displayLabel = false;
        this.mergeRecipientInfo.add(PhyFullName);   
        */
     
        //12. RX Flag
        this.mergeRecipientInfo.add(new SCM_MF_MedHistory_RXFlag(selectedCase.Medical_History_gne__r.Id));
        //SCM_MF_MedHistory_RXFlag RxFlag = new SCM_MF_MedHistory_RXFlag(selectedCase.Medical_History_gne__r.Id);
     
        //13. SMN Flag
        this.mergeRecipientInfo.add(new SCM_MF_MedHistory_SMNFlag(selectedCase.Medical_History_gne__r.Id));
        //SCM_MF_MedHistory_SMNFlag SMNFlag = new SCM_MF_MedHistory_SMNFlag(selectedCase.Medical_History_gne__r.Id);
     
        //14. Product Name
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        /**
        SCM_MF_Product_Name ProductName = new SCM_MF_Product_Name(selectedCase);
        ProductName.key = 'ProductName';
        ProductName.label='Product Name';   
        ProductName.className = 'SCM_MD_SMN_RXRenewLet_NuRAXo';        
        ProductName.fieldValue= (ProductName.getFieldValue() == null)? '': ProductName.getFieldValue();  
        ProductName.checked = false;
        ProductName.displayCheck = false;
        ProductName.displayTextBox = false;
        ProductName.displayLabel = false;                         
        this.mergeFields.add(ProductName);  
        */      
     }

}