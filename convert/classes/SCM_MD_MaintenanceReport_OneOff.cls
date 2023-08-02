public class SCM_MD_MaintenanceReport_OneOff extends SCM_MergeDocument implements IStandardComboBox {
			private SCM_MergeField UI_SMN = New SCM_MergeField();
            private SCM_MergeField UI_ProgressNotes = New SCM_MergeField();
            private SCM_MergeField UI_Labs = New SCM_MergeField();
            private SCM_MergeField UI_PlanTreatmentCare = New SCM_MergeField();
            private SCM_MergeField UI_HistoryPhysical = New SCM_MergeField();
            private SCM_MergeField UI_Other = New SCM_MergeField();
public SCM_MD_MaintenanceReport_OneOff(String caseID, String argLookupId)
    {
            super(caseID, argLookupId);
            caseId = caseID;  
                     
    }
       
    public override void createMergeFields()  
    {
    	//1. Case Number (CaseID)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 

        //-------------------------------------------------------------------------------------------
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
       
   		//-------------------------------------------------------------------------------------------
        //3. CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        
        //-------------------------------------------------------------------------------------------    
        //4. CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));    
        
        //-------------------------------------------------------------------------------------------         
        //5. CR URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
    	
    	//6.  Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
         
        //-------------------------------------------------------------------------------------------
        //7. Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    	
      	//-------------------------------------------------------------------------------------------
        //8 Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
    	//Get Case.RecordType
        if(selectedCase.RecordType.Name != null)
        {
            if(selectedCase.RecordType.Name 
            == 'C&R - Continuous Care Case' || selectedCase.RecordType.Name == 'C&R - Standard Case')
            {   // key'From'
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        		// Ext
        		this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));    
            }
            if(selectedCase.RecordType.Name == 'GATCF - Standard Case')
            {  // key'From'
               this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
               // Ext
               this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));	
            }
        }
    	 //11. Current Date
        this.mergeRecipientInfo.add( new SCM_MF_CurrentDate());
    	  // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
         
        //-------------------------------------------------------------------------------------------
        // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        
        //-------------------------------------------------------------------------------------------
        //14. Product Name
        //this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));	
    	this.mergeRecipientInfo.add(new SCM_MF_DRUG(selectedCase));
    	 // 15. Privacy Notice
      	this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
      	//Patient last name 
      	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientLastName(selectedCase.patient_gne__r.id));
    	//Referral Date
    	this.mergeRecipientInfo.add(new SCM_MF_AA_ReferralDate(selectedCase));
    	//AA Pan expiration
    	this.mergeRecipientInfo.add(new SCM_MF_AA_PanExpiration(selectedCase));
    	//AA Primary Insurance 
    	this.mergeRecipientInfo.add(new SCM_MF_AA_InsuranceByRank(selectedCase,'Primary'));
    	//AA Secondary Insurance 
    	this.mergeRecipientInfo.add(new SCM_MF_AA_InsuranceByRank(selectedCase,'Secondary'));
    	//AA Tertiary Insurance 
    	this.mergeRecipientInfo.add(new SCM_MF_AA_InsuranceByRank(selectedCase,'Tertiary'));
    	//AA Prior Auth 
    	this.mergeRecipientInfo.add(new SCM_MF_AA_PriorAuth(selectedCase));
    	//AA Prior Authorization
    	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.PriorAuthorization(selectedCase, '1'));
    	//AA Prior Authorization
    	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.PriorAuthorization(selectedCase, '2'));
    	//AA Prior Authorization
    	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.PriorAuthorization(selectedCase, '3'));
    	 
    	//dispensing center
    	this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.id));
    	 // Confidentiality Notice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    	UI_SMN = CreateUiField('UI_SMN','SMN',false,true);
        UI_ProgressNotes = CreateUiField('UI_ProgressNotes','Progress Notes',false,true);
        UI_Labs = CreateUiField('UI_Labs','Labs',false,true);
        UI_PlanTreatmentCare = CreateUiField('UI_PlanTreatmentCare','Plan Treatment/Care',false,true);
        UI_HistoryPhysical = CreateUiField('UI_HistoryPhysical','History & Physical',false,true);
        UI_Other = CreateUiField('UI_Other','Other',true,false);
                  
    	this.mergeFields.add(UI_SMN);
    	this.mergeFields.add(UI_ProgressNotes);
    	this.mergeFields.add(UI_Labs);
    	this.mergeFields.add(UI_PlanTreatmentCare);
    	this.mergeFields.add(UI_HistoryPhysical);
    	this.mergeFields.add(UI_Other);
    	
    }
    
    private SCM_MergeField CreateUiField(string key, string Label, boolean DisplayTextBox,boolean displaycheck)
    {
    	SCM_MergeField mf = new SCM_MergeField();
    	mf.displayCheck = displaycheck;
    	mf.displayLabel = true;
    	mf.displayTextBox = DisplayTextBox;
    	mf.label = Label;
    	mf.key = key;
    	mf.isRequired = false;
    	return mf;
    	
    }
        public override void getLatestValues(){
        	if (UI_SMN.checked)
        	{
        		UI_SMN.mergeValue = 'SMN\r\n';
        	}
        	else
        	{
        		UI_SMN.mergeValue = '';
        	}
        	
        	if (UI_ProgressNotes.checked)
        	{
        		UI_ProgressNotes.mergeValue = 'Progress Notes\r\n';
        	}
        	else
        	{
        		UI_ProgressNotes.mergeValue = '';
        	}
        	
        	if (UI_Labs.checked)
        	{
        		UI_Labs.mergeValue = 'LABs\r\n';
        	}
        	else
        	{
        		UI_Labs.mergeValue = '';
        	}
        	
        	if (UI_PlanTreatmentCare.checked)
        	{
        		UI_PlanTreatmentCare.mergeValue = 'Plan Treatment/Care\r\n';
        	}
        	else
        	{
        		UI_PlanTreatmentCare.mergeValue = '';
        	}
        	
        	if (UI_HistoryPhysical.checked)
        	{
        		UI_HistoryPhysical.mergeValue = 'History & Physical\r\n';
        	}
        	else
        	{
        		UI_HistoryPhysical.mergeValue = '';
        	}
        	
        	if(UI_Other.fieldValue != null)
        	{
        		if (UI_Other.fieldValue != '')
        		{
        			UI_Other.mergeValue = UI_Other + '\r\n';
        		}	
        	}
        	
        	
        	
        	
        }
    
}