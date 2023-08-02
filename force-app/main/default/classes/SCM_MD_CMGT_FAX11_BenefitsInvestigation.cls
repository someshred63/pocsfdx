/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : RA-CMGT-FAX-11_BenefitsInvestigation
    // PRODUCT GROUP     : Rituxan RA
    // Type              : Fax coversheet(C&R STANDARD, C&R CONTINUOUS CARE, GATCF)
    // Word Template     : RA_CMGT_FAX11_BenefitsInvestigation
    // Label in SF       : Fax 11 BenefitsInvestigation
    
/********************************************************************/
public class SCM_MD_CMGT_FAX11_BenefitsInvestigation extends SCM_MergeDocument implements IStandardComboBox{
 
 
      //Merge sections
      private SCM_MergeSection UI_BIwithprescription;
      private SCM_MergeSection UI_BIwithoutPrescription;
      
      //Radio buttons
      private SCM_MergeField mf1;
      private SCM_MergeField mf2;
      
      public SCM_MD_CMGT_FAX11_BenefitsInvestigation(String caseID, String argLookupId)
      {
            super(caseID, argLookupId);
            caseId = caseID;
      }

       public override void createMergeFields()  
      {
        //Case ID(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase)); 
        //Patient ID(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
                this.mergeFields.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        //CR_Phone(CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
           
        // Addressed To (RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    
        // Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        // From and EXt(From,Ext)
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case'))
        {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case'))
        {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
       
        // Date (Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //Patient full name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Patient DOB(Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
        //Drug (DRUG)
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //privacy notice (PrivacyNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
       
        //Confid notice(ConfidNotice)
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //---------------Second screen-----------------
        
        string product=null;
        SCM_MF_Product_Name prdName= new SCM_MF_Product_Name(selectedCase);
        this.mergeRecipientInfo.add(prdName);
        product=prdName.getFieldValue();
        
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Benefit Investigation:';       
        formInformation.key = 'Benefit Investigation:';
        
        //Merge Sections       
        UI_BIwithprescription = new SCM_MergeSection();        
        UI_BIwithprescription.key = 'UI_BIwithprescription';
        UI_BIwithprescription.visible = false;
        
        this.mergeSections.add(UI_BIwithprescription);
        
        UI_BIwithoutPrescription  = new SCM_MergeSection();        
        UI_BIwithoutPrescription .key = 'UI_BIwithoutPrescription';
        UI_BIwithoutPrescription.visible = false;
        this.mergeSections.add(UI_BIwithoutPrescription );
        
             
        mf1 = new SCM_MergeField();
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false; 
        //mf1.totalWidth = '800';
        mf1.fieldValue = '';
       // mf2.fieldStyle = 'text-align: left';
        mf1.key = 'test123';
        mf1.isFormField = false; 
        string selopt = 'If you elect not to use the prescription benefit identified for '                
                + product+ ' treatment, then this case will not be '
                +'\r\n considered for product replacement. However, if you choose to utilize the major medical benefit and receive a'
                +'\r\n denial, Rituxan Access Solutions will be happy to assist with the appeals process.';
        mf1.selectionItems.add(new SelectOption('Yes'
                ,'Benefits Investigation with prescription benefits enforcement' ));
        
         
         //formInformation.subFields.add(mf1);
        
        
        /*mf2 = new SCM_MergeField();
        mf2.displayRadio = true;
        mf2.displayLabel = false;
        mf2.displayCheck = false;
        mf2.displayTextbox = false;
        mf2.IsRequired = false; 
        mf2.totalWidth = '550';*/
        mf1.selectionItems.add(new SelectOption('No'
                ,'Benefits Investigation without prescription benefits enforcement' ));

        mf1.fieldvalue = 'Yes';
         formInformation.subFields.add(mf1);
              
        this.mergeFields.add(formInformation);         
        
        //Comments
        SCM_MergeFieldGroup comments = new SCM_MF_Comments();        
        this.mergeFields.add(comments);  
      }
      
       public override void getLatestValues()
       {
         if (mf1.getMergeValue().startsWith('Yes'))
        {
         UI_BIwithprescription.visible=true;
          UI_BIwithoutPrescription.visible=false;
        }
               
        if (mf1.getMergeValue().startsWith('No'))
        {
         UI_BIwithoutPrescription.visible=true;
         UI_BIwithprescription.visible=false;
         
        }
               
       
       }
      
}