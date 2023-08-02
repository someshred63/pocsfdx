/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : CMGT-FAX-06 Message from Access Solutions BLANK 
    // PRODUCT GROUP     : All Products
    // Type              : Fax Coversheet
    // Word Template     : 
   
/********************************************************************/    


public class SCM_MD_Fax_Msg_Access_Solutions_BLANK extends SCM_MergeDocument implements IStandardComboBox
{
    public SCM_MD_Fax_Msg_Access_Solutions_BLANK(String caseId, String argLookupId)
    {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() 
    {
    	
    	String caseRecordType = selectedCase.RecordType.Name;    	
    	String productName = selectedCase.Product_gne__c;     
    	
    	
      //CaseNumber(Case_Number)
      this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
    
      //CR_Phone	(Key CR_Phone)
      this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
      
      //CR_Phone_short
      this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
      
      //ATTN:
      this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));    
         
      // Addressed To        
      this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
        
       // Fax
       this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        //Get Case.RecordType
        String recordType = selectedCase.RecordType.Name;

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
      
       //DateShort (Current_Date)
       this.mergeRecipientInfo.add(new SCM_MF_CurrentDate()); 
      
        // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
         
        // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
      
       //Drug (Key Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
      
        //UI_Comments(Key CommentField)
        this.mergeFields.add(new SCM_MF_Comments());
     	
    }
}