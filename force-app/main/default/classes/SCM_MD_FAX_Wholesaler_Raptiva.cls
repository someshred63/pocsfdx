/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : RAP_CMGT_FAX_21_WHOLESALER
    // Type				 : Fax Coversheet
    // Word Template     : Fax-Wholesaler_Raptiva.doc
    // Label in SF       : Wholesaler Raptiva 
    
/********************************************************************/
public class SCM_MD_FAX_Wholesaler_Raptiva extends SCM_MergeDocument implements IStandardComboBox
 {
	public SCM_MD_FAX_Wholesaler_Raptiva(String caseId, String argLookupId) 
	{
		super(caseId, argLookupId);
	}
 
	public override void createMergeFields()
	 {
    	String phyId = selectedCase.Case_Treating_Physician_gne__r.Id;
    	String accountIdLocal = selectedCase.accountId;
    	
    	//1.CaseNumber(Case_Number)
    	 this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));         
    	
    	//2.Patient Id(Patient Id)
    	  SCM_MF_PatientId patient = new SCM_MF_PatientId(selectedCase);
          this.mergeRecipientInfo.add(patient);
       
    	
    	//3.RAP_Phone(CR_PhoneShort)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    		
     	//4.RAP_Fax(Fax)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    	
    	//5.URL(URL)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    	
       // Attn 
       	this.mergeRecipientInfo.add(new SCM_MF_AttnFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        // Addressed To
        this.mergeRecipientInfo.add(new SCM_MF_FaxAdrsTo(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        // Fax
        this.mergeRecipientInfo.add(new SCM_MF_FaxRECFAX(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // From and Extension   
       String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
		 
 	   //13.PhysicianFullName(Physician First And Last Name)
 	    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
     
    	//11.DateShort
    	this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    		
    	//14.PhysicianTitle(Physician Title)    	
    	this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(selectedCase.Case_Treating_Physician_gne__r.Id));
     	
		//15.PhysicianDEA(Physician Profile Luncentis)
	    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(selectedCase.Case_Treating_Physician_gne__r.Id));
      		
	    //DispensingCenter
	    this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.Id));
	    
     	//DispensingContactPhone(Distributor_Contact_Phone)
     	this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingContactPhone(selectedCase.Id));
    	
    	//DispensingContactName(Distributor_Contact_Name)
    	this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingContactName(selectedCase.Id));
    	
    	
        SCM_MergeFieldGroup forminfo = new SCM_MergeFieldGroup();
        forminfo.label = 'Referral';
        forminfo.headerText = 'Referral';       
        forminfo.key = 'Referral';
     
    	// second screen   	
    	
    	//20.ReferralType//19.UI_ OneOffProgram
    	
    	SCM_MergeField mf1 = new SCM_MergeField();
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false; 
        mf1.fieldStyle='text-align: left;';
        mf1.totalwidth ='600';
        //mf1.isNewLine=true;
        mf1.width = '500';
        mf1.selectionItems.add(new SelectOption('One Off Referral','One Off' ));
        mf1.selectionItems.add(new SelectOption('Regular Referral','Regular' ));  
        mf1.selectedValue = mf1.selectionItems[0].getValue();
        mf1.setKey('ReferralType');
        mf1.setFieldValue(mf1.selectedValue);
        forminfo.subFields.add(mf1);        
       
        this.mergeFields.add(forminfo);
    	//21.UI_Comments
    	 this.mergeFields.add(new SCM_MF_Comments());
    		
    	//22.ConfidNotice (ConfidNotice)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    	
    	
	 }
 }