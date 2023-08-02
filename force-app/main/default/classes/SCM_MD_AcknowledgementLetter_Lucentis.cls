/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : LUC-CMGT-FAX-41 Acknowledgement Letter.doc
    // Type              : System Document
    // Word Template     : Acknowledgement Letter_Lucentis.doc    
    // Label in SF       : Acknowledgement Letter
    
/********************************************************************/
public class SCM_MD_AcknowledgementLetter_Lucentis extends SCM_MergeDocument {
    private String selectedCaseId;
    
    public SCM_MD_AcknowledgementLetter_Lucentis(String caseId, String argLookupId) {
        super(caseId, argLookupId);
        selectedCaseId = caseId;
    }  
    
    public override void createMergeFields() {
    	String patId = selectedCase.Patient_gne__r.Id;
    	String recordType = selectedCase.RecordType.Name;
    	
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient Id              
		this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));

        //Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
    	//URL
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    	
        //Date Long
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //ReferralOffice
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralOffice(selectedCase));
        
        //ReferralAttn
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralAttn(selectedCase));
        
        //ReferralStAddress
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralStAddress(selectedCase));
        
        //ReferralSuiteFlUnit
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralSuiteFlUnit(selectedCase));
        
        //ReferralCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralCityStateZip(selectedCase));
       
        //Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patId));

		//Referral ACKN Phone
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralPhone(Selectedcase));
		
		//Referral ACKN Fax
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralFax(Selectedcase));
        //Case Worker
        if (recordType.startsWith('C&R')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        } 
        this.mergeRecipientInfo.add(new SCM_MF_XolairPlus(SelectedCase.Product_gne__c));
  		this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));	
        //Confidentiality Notice
		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    }
}