/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : 10 – Benefit Investigation Information
    // PRODUCT GROUP     : Lucentis,Nutropin,Rituxan,RituxanRa
    // Type              : Fax Coversheet
    // Word Template     : 
   
/********************************************************************/    


public class SCM_MD_FAX_BenInvAddInfReq_LuNuRitRitRa extends SCM_MergeDocument implements IStandardComboBox
{
    public SCM_MD_FAX_BenInvAddInfReq_LuNuRitRitRa(String caseId, String argLookupId)
    {
        super(caseId, argLookupId);
    }

    private SCM_MergeFieldCheckbox Checkbox4;
    private SCM_MergeField txtBox;
    public override void createMergeFields() 
    {
        String patientId = selectedCase.patient_gne__r.Id;
        
        //1. Case_Number        
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //2.Patient ID
        //SCM_MF_PatientId patient = ;
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        this.mergeFields.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        this.mergeimages.add(new SCM_MI_Logo(selectedCase));
        
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
       //Attn
       this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // addressedTo
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
                  
        // Fax2
         this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
          
        //from Ext
        
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
                
        //DateShort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
         
        //PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
         
        // Lucentis_Specific
        if(selectedCase.Product_gne__c=='Lucentis')
            this.mergeSections.add(new SCM_MergeSection('Lucentis_Specific', true));
         else
            this.mergeSections.add(new SCM_MergeSection('Lucentis_Specific', false));
      //second page
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Benefit Investigation Information:';
        docu.headerText = 'The following information is required to perform a Benefit Investigation';       
        docu.key = 'Documentation';
        
        SCM_MergeFieldCheckbox Checkbox1 = 
                new SCM_MergeFieldCheckbox('UnContInsComp', 'Unable to contact insurance company. Will try again.');        
        Checkbox1.fieldValue = 'Unable to contact insurance company. Will try again.\r\n';
        Checkbox1.totalWidth = '900';
        Checkbox1.key = 'Unable ContactIns';
        docu.subFields.add(Checkbox1);
                 
        SCM_MergeFieldCheckbox Checkbox2 = 
                new SCM_MergeFieldCheckbox('IncPatIdNo', 'Incorrect patient ID number.');
        Checkbox2.fieldValue = 'Incorrect patient ID number.\r\n';
        Checkbox2.totalWidth = '900';    
        CheckBox2.key = 'IncPatIdNo';    
        docu.subFields.add(Checkbox2);  
             
        SCM_MergeFieldCheckbox Checkbox3 = 
                new SCM_MergeFieldCheckbox('IncInsPhNo', 'Incorrect insurance phone number.');           
        Checkbox3.fieldValue = 'Incorrect insurance phone number.\r\n';     
        Checkbox3.totalWidth = '900';
        CheckBox3.key = 'IncInsPhNo';    
        docu.subFields.add(Checkbox3);
        
        Checkbox4 = new SCM_MergeFieldCheckbox('NoMDNo', 'No MD number provided for:');          
        Checkbox4.fieldValue = 'No MD number provided for: ';       
        Checkbox4.totalWidth = '183';
        CheckBox4.key = 'NoMDNo';    
        docu.subFields.add(Checkbox4);
                
        txtBox = new SCM_MergeField();
        txtBox.key = 'Comments';
        txtBox.isNewLine = false;
        txtBox.totalWidth = '270';
        txtBox.displayCheck  = false;
        txtBox.displayLabel = false;
        txtBox.displayTextBox = true;
        txtBox.isRequired = false;
        txtBox.requireNewLineInTemplate = true;
        docu.subFields.add(txtBox);
                
        SCM_MergeFieldCheckbox Checkbox5 = 
            new SCM_MergeFieldCheckbox('No_IncTadIdNo', 'No/Incorrect Tax ID number.');          
        Checkbox5.fieldValue = 'No/Incorrect Tax ID number.\r\n';       
        Checkbox5.totalWidth = '900';
        CheckBox5.key = 'No_IncTadIdNo';    
        docu.subFields.add(Checkbox5);
        
        this.mergeFields.add(docu);  
        
        //PrivacyNotice
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //ConfidNotice
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
       //Drug
         SCM_MF_DRUG2 drug = new SCM_MF_DRUG2(selectedCase);
         this.mergeRecipientInfo.add(drug);

    }
    
    public override void getLatestValues()
    {
        if(Checkbox4!=null && !Checkbox4.checked && txtBox!=null)
        {
            txtBox.setMergeValue('');
        }
    }
}