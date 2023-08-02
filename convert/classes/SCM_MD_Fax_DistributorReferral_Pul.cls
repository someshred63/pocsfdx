/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : PUL-CMGT-FAX-23_Distributor_Refferral_FinalAnalysis
    // Type              : Fax Coversheet
    // Word Template     : CMGT-FAX-23-DistributorRefferral-Pul.doc    
    // Label in SF       : Distributor Referral
    
/********************************************************************/

public class SCM_MD_Fax_DistributorReferral_Pul extends SCM_MergeDocument {
	    
    public SCM_MD_Fax_DistributorReferral_Pul(String caseID, String argLookupId) {
        super(caseID, argLookupId);
        
    }
    
    public override void createMergeFields() {
    	
        String caseRecordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;  
        string pid = selectedCase.Patient_gne__c;
        String patientId = selectedCase.Patient_gne__r.Id;
        
        
         
        	//---------------------------------First Screen----------------------------------------
    	
    	//1 Attn(ATTN_Attn)(FulFillment Attn)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter_TextBox(selectedCase.Id));
    
        //this.mergeRecipientInfo.add(new SCM_MF_Attn(selectedCase.Id));    
        // 2 Addressed To(RECNAME_To)(FulFillment name)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentAddressTo(selectedCase.Id));
        //this.mergeRecipientInfo.add(new SCM_MF_FulFillmentAddressTo(selectedCase.Id));
        
        // 3 Fax No(RECFAX_Fax)(No factory class:RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(selectedCase.Id));
        
        //this.mergeRecipientInfo.add(new SCM_MF_FulFillmentFaxNumber(selectedCase.Id));  
        // 4 From(From)
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        
        // 5. Extension  (Ext)       
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
        //-----------------------------------------------------------------------------------------------
        
        //0 Case Number (CaseID) (Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //1 Patient ID (Patient Id)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		//-------------------------------------------------------------------------------------------    	
        // 2 CR_Phone (CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //3 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //4 CR_Fax(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //5 Product Name (Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
    	//-------------------------------------------------------------------------------------------      
        //6 Confidentiality Notice (ConfidNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
		//-------------------------------------------------------------------------------------------
        //7 Current Date (Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
		//-------------------------------------------------------------------------------------------
        //8 PatientFullName(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pId));
        
        //9 Patient DOB (Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pId));
    	//-------------------------------------------------------------------------------------------
		//10 Patient Full Address(PatientAddressCityStateZip)
		this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(patientId));
    	 
		// 11 Patient Prime Contact FullName(PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(pId));
    	 
        // 12 Patient Prime Contact Home Phone number(Pat_Home_Ph)  
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(pId));
        
        // 13 Patient Prime contact Work Phone Number(Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(pId));
        
        // 14 NewStart(NewStart)
        this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase,true,true));
        
        // 15 ContinuedTherapy(ContinuedTherapy)
        this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase,true,true));
        
        //16 Provider NPI(ProviderNPI)  
        this.mergeRecipientInfo.add( new SCM_MF_ProviderNPI(physicianId));
        
        //17 Facility NPI  (FacilityNPI)      
        this.mergeRecipientInfo.add( new SCM_MF_FacilityNPI(selectedCase));
       
        //------------------------------------------Second Screen ------------------------------------------//
     
            //  Additional Information Required:
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.key = 'Documentation';
        this.mergeFields.add(docu);
        //-------------------------------------------------------------------------------------------
        
      
		//17. comments
        this.mergeFields.add(new SCM_MF_Comments());	
        //SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        //comments.headerText = 'Comments: ';       
        //comments.key = 'Comment';           
        
        //SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        //CommentField.key = 'Comments';                       
        //comments.subFields.add(CommentField);
        //this.mergeFields.add(comments);
        
    }
	

}