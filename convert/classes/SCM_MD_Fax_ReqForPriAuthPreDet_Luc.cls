/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : LUC-CMGT-FAX-17_Req_For_prior_Auth_Pre_Det.doc
    // Type				 : Fax Coversheet
    // Word Template     : Req_For_prior_Auth_Pre_Det.doc    
    // Label in SF       : Request for Prior Authorization / Pre-Determination  
    
/********************************************************************/
public class SCM_MD_Fax_ReqForPriAuthPreDet_Luc extends SCM_MergeDocument {
	public SCM_MD_Fax_ReqForPriAuthPreDet_Luc(String caseId, String argLookupId) {
		super(caseId, argLookupId);
	}
 
	public override void createMergeFields() {
    	String phyId = selectedCase.Case_Treating_Physician_gne__r.Id;
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Physician Id : ' + phyId));
    	//Case Number
        mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //Patient ID
        SCM_MF_PatientId patientId = new SCM_MF_PatientId(selectedCase);
        mergeRecipientInfo.add(patientId);

		//CR_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        		         
        // DateShort
        SCM_MF_CurrentDate curDate = new SCM_MF_CurrentDate();
        //curDate.key = 'DateShort';
        this.mergeRecipientInfo.add(curDate);

     // Attn (Key: 'ATTN_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAContactName(selectedCase.Id));
         
        //RECNAME_Payor
        this.mergeRecipientInfo.add(new SCM_MF_InsPAPayor(selectedCase.Id));
 
		//RECFAX_PA
		this.mergeRecipientInfo.add(new SCM_MF_InsPAContactFax(selectedCase.Id));

        //From and Ext
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }
           
        // PatientFullName(key:Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
      
  	
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
		   
		// SubscriberID PA
        this.mergeRecipientInfo.add(new SCM_MF_SubscriberIdPA(selectedCase.Id));
        
        // GroupNum PA
        this.mergeRecipientInfo.add(new SCM_MF_GroupNumPA(selectedCase.Id));
        
              
        //12 NewStart(Key:NewStart)
	    this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true, true));
	    
	    //13 ContinuedTherapy(Key:ContinuedTherapy)
	    this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true, true));
	    
	    //14 Restart(Key:Restart)
	    this.mergeRecipientInfo.add(new SCM_MF_ChkRestartTherapy(selectedCase, true, true));
	 	
		//ChkJCode_PA
		this.mergeRecipientInfo.add(new SCM_MF_ChkJCode_PA(selectedCase.Id));		
		
		//JCode_PA
		this.mergeRecipientInfo.add(new SCM_MF_JCodePA(selectedCase.Id));
		
		//Physician Full Name
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(phyId));
				
        //Confidentiality Notice
		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));     
		
		/////////-------Second Screen ------
		
        // Comments 
        this.mergeFields.add(new SCM_MF_Comments());
       
	}
}