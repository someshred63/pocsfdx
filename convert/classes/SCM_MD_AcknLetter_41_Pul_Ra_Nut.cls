// Developer Name    : Manjunath Nilagiri
    // Document Name     : Consolidated_PUL-NUT-RA_CMGT-FAX-41_Acknowledgement_Letter_final.doc
    // Type				 : SYSTEM DOCUMENT
    // Word Template     : AcknowledgementLetter_Fax41_PuRaNu.doc     
    // Label in SF       : Acknowledgement Letter
    
/********************************************************************/

public class SCM_MD_AcknLetter_41_Pul_Ra_Nut extends SCM_MergeDocument
 {	   
 
	public SCM_MD_AcknLetter_41_Pul_Ra_Nut(String caseId, String argLookupId)
    { 
        super(caseId, argLookupId);
    }

    public override void createMergeFields()
     {
     	String productName = selectedCase.Product_gne__c;
     	String caseRecordType = selectedCase.RecordType.Name;
      
         //CR_Logo  (CR_LOGO) 
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));   
     	     	
     	// Case Number (Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));  
        
        //Cr_Phone (CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //Cr_Fax (CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
         
        //Cr_URL (CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //DateLong - (DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //ReferralOffice - (ReferralOffice)
     	this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralOffice(selectedCase));
     	
     	//ReferralAttn - (ReferralAttn)
     	this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralAttn(selectedCase));
     	
     	//ReferralStAddress - (ReferralStAddress)
     	this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralStAddress(selectedCase));
     	
     	//ReferralSuiteFlUnit - (ReferralSuiteFlUnit)
     	this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralSuiteFlUnit(selectedCase));
     	
     	//ReferralCityStateZip - (ReferralCityStateZip)
     	this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralCityStateZip(selectedCase));
     	
     	//Referral ACKN Phone
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralPhone(Selectedcase));
		
		//Referral ACKN Fax
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralFax(Selectedcase));
     	//Patient Full Name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Patient first Name - (PatientFirstName)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(selectedCase.Patient_gne__r.Id));
        
        //AccessSolutions - (AccessSolutions)
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(productName));
        
        //Product - (Product)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
       
        //CaseWorker - (Case Mang Name)
            String recordType = selectedCase.RecordType.Name;
	        if (recordType.startsWith('C&R')) {
	            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
	        }
	        else if (recordType.startsWith('GATCF')) {
	            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
	        }
	        
	        /**        
        	 	caseRecordType = (caseRecordType == null)? '': caseRecordType;
        		if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            	   caseRecordType.equalsIgnoreCase('C&R - Standard Case')) 
                 {
             	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
               	SCM_MF_CaseMangFirstAndLastName casMang = new SCM_MF_CaseMangFirstAndLastName(selectedCase.Case_Manager__r.Id);
            	string casMangVal = casMang.getFieldValue();
            	casMang.fieldValue = casMangVal;
            	casMang.key = 'Case Mang Name';
            	this.mergeRecipientInfo.add(casMang);
                  }
                          
        		if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) 
                  {                     
          		this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
                SCM_MF_FoundationSplName foundSpl= new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
            	string foundSplVal = foundSpl.getFieldValue();
            	foundSpl.fieldValue = foundSplVal;
            	foundSpl.key = 'Case Mang Name';         
            	this.mergeRecipientInfo.add(foundSpl);
                   }                   
        */
        
        //ConfidNotice (ConfidNotice)
         this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
     	
     }
     
 }