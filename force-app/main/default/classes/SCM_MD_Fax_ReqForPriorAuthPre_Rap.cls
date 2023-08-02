/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : RAP-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION
    // Type              : Fax Coversheet
    // Word Template     : CMGT-Fax-17-ReqForPriorAuthPre-Rap.doc    
    // Label in SF       : Request For Prior Authorization/Pre-Determination
    
/********************************************************************/
public class SCM_MD_Fax_ReqForPriorAuthPre_Rap extends SCM_MergeDocument {
 
 public SCM_MD_Fax_ReqForPriorAuthPre_Rap(String caseId, String argLookupId) {
  super(caseId, argLookupId);
 }
 
 public override void createMergeFields() {
  
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String pid = selectedCase.Patient_gne__c;
        String recordType = selectedCase.RecordType.Name ;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));        
        // 2 CR_PhoneShort(CR_PhoneShort)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));        
        // 3 CR_Fax(CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));         
        // 4 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
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
        
        //-----------------------------------------------------------------------------------------------
        
        //10 DateShort(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());        
        //11 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        //12 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        //---------------------------------------------------------------------------------------------------
        
        // SubscriberID_PA (Key: 'SubscriberID_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPASubscriberId(selectedCase.Id));
        
        // GroupNum_PA (Key: 'GroupNum_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAGroupNum(selectedCase.Id));
        
        //15 PolicyNum_PA(PolicyNum_PA)
        this.mergeRecipientInfo.add(new SCM_MF_PolicyNumPA(selectedcase.id));//Policy_Num
        
        //16 Confidential Notice(ConfidNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
  //-------------------------------------------------------------------------------------------
  
  //------------------------------Second Screen------------------------------------------
  		
  		
        
        // comments
        this.mergeFields.add(new SCM_MF_Comments()); 
      
    }     
}