/********************************************************************/
    // Developer Name    : Deepti
    // Document Name     : XOL-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION
    // Type      		 : Fax Coversheet
    // Word Template     : CMGT-FAX-17-ReqForPriorAuthPreD-Xol   
    // Label in SF       : Request for Prior Authorization-Predetermination  
    
/********************************************************************/

public class SCM_MD_Fax_ReqForPriorAuthPredet_Xol extends SCM_MergeDocument{
       
     public SCM_MD_Fax_ReqForPriorAuthPredet_Xol(String caseId, String argLookupId){
        super(caseId, argLookupId);
     }
     
     public override void createMergeFields() {
     	
     	//local variables
     	String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
    	String recordType = selectedCase.RecordType.Name;
        
       //-------------------------------------------------------------------------------------------    
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
       //-------------------------------------------------------------------------------------------    
                
        // 2 CR_Phone(Key:CR_Phone)
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase)); 
  		       
        // 3 CR_Fax(Key:CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));   
              
        // 4 CR_URL(Key:CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // 5 DateShort(Key:Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());   
             
        // 6 PatientFullName(key:Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
      
        // 7 Patient DOB (key:Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
        // SubscriberID_PA (Key: 'SubscriberID_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPASubscriberId(selectedCase.Id));
        
        // GroupNum_PA (Key: 'GroupNum_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAGroupNum(selectedCase.Id));
     
        //10 Confidential Notice(Key:ConfidNotice)
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
  		
  		//11.Physician Full Name(Key:Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
           
        //12 NewStart(Key:NewStart)
	    this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true, true));
	    
	    //13 ContinuedTherapy(Key:ContinuedTherapy)
	    this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true, true));
	    
	    //14 Restart(Key:Restart)
	    this.mergeRecipientInfo.add(new SCM_MF_ChkRestartTherapy(selectedCase, true, true));
	    
	    //15 JCode_PA(Key:JCode_PA)
        this.mergeRecipientInfo.add(new SCM_MF_JCodePA(selectedCase.id));
    
      	//ChkJCode_PA
		this.mergeRecipientInfo.add(new SCM_MF_ChkJCode_PA(selectedCase.Id));		
	
        
        /////////-------First Screen--------
       
        // Attn (Key: 'ATTN_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAContactName(selectedCase.Id));
         
        //RECNAME_Payor
        this.mergeRecipientInfo.add(new SCM_MF_InsPAPayor(selectedCase.Id));
 
		//RECFAX_PA
		this.mergeRecipientInfo.add(new SCM_MF_InsPAContactFax(selectedCase.Id));
        
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        
        /////////-------Second Screen ------
        //21 Comments
        this.mergeFields.add(new SCM_MF_Comments());
        
     }
}