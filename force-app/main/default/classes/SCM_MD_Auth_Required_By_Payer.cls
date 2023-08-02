public class SCM_MD_Auth_Required_By_Payer  extends SCM_MergeDocument implements IStandardComboBox{
    public SCM_MD_Auth_Required_By_Payer(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    } 

	private SCM_MergeField FreeText1 = new SCM_MergeField();
	private SCM_MergeField FreeText2 = new SCM_MergeField();
	private SCM_MergeField FreeText3 = new SCM_MergeField();
	private SCM_MergeField PASelection = new SCM_MergeField();
	private SCM_MergeField Followup = new SCM_MergeField();
	public override void createMergeFields() {
    	
    List<Prior_Authorization_gne__c>  PAs = [Select  p.Id,p.Benefit_Investigation_gne__c,p.Benefit_Investigation_gne__r.Prior_Authorization_Required_gne__c ,p.Benefit_Investigation_gne__r.BI_Insurance_gne__c,p.Benefit_Investigation_gne__r.Is_Pre_D_Required_or_Voluntary_gne__c, p.Benefit_Investigation_gne__r.Case_BI_gne__c, p.Benefit_Investigation_gne__r.Payer_BI_gne__c, p.Name, p.PA_Obtained_By_gne__c, p.PA_Obtained_Date_gne__c, p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Name, p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Payer_gne__r.Name,p.Benefit_Investigation_gne__r.Benefit_Type_gne__c,Benefit_Investigation_gne__r.Name from Prior_Authorization_gne__c p 
    where p.Benefit_Investigation_gne__r.Case_BI_gne__c = :SelectedCase.Id and p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Case_Insurance_gne__r.id = :SelectedCase.Id];	
    
    
        PASelection.key='SelectedPA';
        PASelection.className = 'SCM_MergeField';
        PASelection.checked = false;
        PASelection.displayCheck = false;
        PASelection.displayTextBox = false;
        PASelection.displayDropdown=true; 
        PASelection.label = 'Insurance';
        PASelection.displayLabel = true;
        PASelection.controlStyle = 'width:450px';
		PASelection.totalWidth = '566';
        List<SelectOption> options = new List<SelectOption>();
        for(Prior_Authorization_gne__c PA:PAs)
        {
        	string PaReq = PA.Benefit_Investigation_gne__r.Prior_Authorization_Required_gne__c;
        	string Predet = PA.Benefit_Investigation_gne__r.Is_Pre_D_Required_or_Voluntary_gne__c;
			boolean AddToList = true;
			
			if (PaReq == null && Predet == null){
				AddToList = false;	
			}        
			if (PaReq == null && Predet == 'Not Available'){
				AddToList = false;	
			}   
			if (PaReq == 'No' && Predet == null){
				AddToList = false;	
			}   
			if (PaReq == 'No' && Predet == 'Not Available'){
				AddToList = false;	
			}        
			        
			if (AddToList){			        
        		string Option = PA.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Payer_gne__r.Name + '-' + PA.Benefit_Investigation_gne__r.Benefit_Type_gne__c + '-' + PA.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Name ;
        		
              
            	options.add(new SelectOption(PA.Id,Option));
			}
        }
        PASelection.selectionItems=options;  
    	this.mergeRecipientInfo.add(PASelection);
     // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        //3.CR_Phone ( key CR_Phone)
    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
     this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    //CR_PhoneShort
    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    
    //4.CR_Fax (key CR_Fax)
    this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
    //5.CR_URL ( key CR_URL)
    this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    
    

        //-------------------------------------------------------------------------------------------
        // Product Name 
        //this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
   		// 8 Drug(Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
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

		this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));	

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
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'The Following Document(s)\\Information Are Required:';
        docu.headerText = 'The Following Document(s)\\Information Are Required:';
        docu.key = 'UI_Additional_Docs';
        this.mergeFields.add(docu);
        FreeText1 = createMF('','','free text area1',false,true);
      	FreeText1.mergeValue = '';
        docu.subfields.add(FreeText1); 
        FreeText2 = createMF('','','free text area2',false,true);
        docu.subfields.add(FreeText2); 
        FreeText3 = createMF('','','free text area3',false,true);
        docu.subfields.add(FreeText3); 
        
        FreeText1.requireNewLineInTemplate = true;
        FreeText2.requireNewLineInTemplate = true;
        FreeText3.requireNewLineInTemplate = true;
        
        FreeText1.allowCache = false;
        FreeText2.allowCache = false;
        FreeText3.allowCache = false;
		Followup = createMF('','Access Solutions can follow-up on the status of the previously submitted authorization.','FollowupStatus',true,false);
        Followup.checked = true;
        //followup.width = '600px';
        //followup.controlStyle = 'width:600px';
        followup.totalWidth = '630';
        followup.extraHTML = '<div style=\"width:600px;text-align:left;\">Access Solutions can follow-up on the status of the previously submitted authorization. </div>';
        followup.displayExtraHTML = true;
        followup.allowCache = false;
        docu.subfields.add(Followup); 
		
		this.mergeFields.add(new SCM_MF_Comments());
         
    }
    
    
    private void MergeItems(string Value,map<string,string> myMap ){
    if (Value == null){
    return;	
    }
    
    string[] strs = Value.split(';');
    
    for(string str:strs){
    	if(!myMap.containsKey(str)){
    		myMap.put(str,str);
    	
    	}
    	
    }	
    	
    }
    
    
     public override void getLatestValues(){
     	
     	Prior_Authorization_gne__c PA = [Select   Benefit_Investigation_gne__r.Is_Pre_D_Required_or_Voluntary_gne__c ,Benefit_Investigation_gne__r.Prior_Authorization_Required_gne__c ,Benefit_Investigation_gne__r.Payer_BI_gne__r.Name, Benefit_Investigation_gne__r.Required_for_Recertification_gne__c,Benefit_Investigation_gne__r.Required_for_Initial_Auth_Only_gne__c,Benefit_Investigation_gne__r.BI_Obtained_Date_gne__c,Fax_gne__c,Phone_gne__c,Zip_gne__c,State_gne__c,City_gne__c,Address_Line_2_gne__c,Address_Line_1_gne__c,PA_Contact_Name_gne__c,p.Id,p.Benefit_Investigation_gne__c, p.Benefit_Investigation_gne__r.BI_Insurance_gne__c, p.Benefit_Investigation_gne__r.Case_BI_gne__c, p.Benefit_Investigation_gne__r.Payer_BI_gne__c, p.Name, p.PA_Obtained_By_gne__c, p.PA_Obtained_Date_gne__c, p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Name, p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Payer_gne__r.Name,p.Benefit_Investigation_gne__r.Benefit_Type_gne__c,Benefit_Investigation_gne__r.Name from Prior_Authorization_gne__c p 
                                            where p.Id = :PASelection.mergeValue limit 1];
     	 
     	this.mergeFields.add(new SCM_MF_BI_Payer(PA.Benefit_Investigation_gne__r));
     	this.mergeFields.add(new SCM_MF_BI_ObtainedDate(PA.Benefit_Investigation_gne__r));
     	
     	this.mergeFields.add(new SCM_MF_PA_AuthorizedBy(PA));
     	this.mergeFields.add(new SCM_MF_PA_PayerAddress(PA)); 
     	this.mergeFields.add(new SCM_MF_PA_PayerPhone(PA)); 
     	this.mergeFields.add(new SCM_MF_PayerFax(PA)); 
     	
     	this.mergeFields.add(SCM_MF_BI_FieldFactory.ReqdVsVolunatry(PA.Benefit_Investigation_gne__r));
     	
     	
     	Map<string,string> UniqueValues = new Map<string,string>();
     	
     	if (!followup.checked){
     		SCM_MergeSection ms = new SCM_MergeSection();
     		ms.key = 'FollowupStatus';
     		ms.visible = false;
     		this.mergeSections.add(ms);
     		
     	}
     	
     	
     	MergeItems(PA.Benefit_Investigation_gne__r.Required_for_Recertification_gne__c,UniqueValues);
     	MergeItems(PA.Benefit_Investigation_gne__r.Required_for_Initial_Auth_Only_gne__c,UniqueValues);
     	Set <String> mapset = new Set<String>();
		mapset = UniqueValues.keySet();
		string FinalList = '';
		if (mapset.size() > 0){
			for(string id:mapset){
				string vlu = UniqueValues.get(id);
				if (vlu != null && vlu != '' && vlu != 'None Required'){
		
					FinalList += '\r\n' + vlu ;
				}
			}
		}
		
		SCM_MergeField mfList = CreateMF('',FinalList,'AuthAndRecertList',false,False );
		mfList.displayLabel = false;
		
     	this.mergeFields.add(mfList);
     	
     	
     	if (!followup.checked){
     		Followup.mergeValue = '';	
     	}
     	
     }
    
    
      private SCM_MergeField CreateMF(string Label,string Value,string key,boolean isCheck,boolean EnableTextbox ) {
     	SCM_MergeField mf = new SCM_MergeField();
     	mf.displayCheck = isCheck;
     	mf.displayLabel = true;
     	mf.label = label;
     	mf.key = key;
     	mf.fieldValue = Value + '\r\n';
     	mf.displayTextBox = EnableTextbox;
     	mf.isRequired = false;
     	return mf;
     	
     	
     	
     }
}