/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RA replacement md approval - CMGT-FAX-51 - GATCF Approval Form.doc
    // PRODUCT GROUP     : Rituxan RA
    // Type              : System Document
    // Word Template     : Approval Form.doc
    // Label in SF       : Replacement Approval (Physician)
/********************************************************************/
 
public class SCM_MD_ReplaceMDApproval extends SCM_MergeDocument{

    protected String patientIdLocal;
    protected String cseId;
    protected String physId;
    
    public SCM_MD_ReplaceMDApproval(String caseId, String argLookupId)
    {
        super(caseId,argLookupId);   
    }
    
    public override void createMergeFields()
    {   
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
 this.mergeRecipientInfo.add(new SCM_MF_product_DrugName(selectedCase));
 this.mergeRecipientInfo.add(new SCM_MF_product_ScientificName(selectedCase));
        // Patient ID (key Patient ID)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
    	
    	//DateLong(key DateLong)
      	this.mergeRecipientInfo.add(new SCM_MF_DateLong());
		//-------------------------------------------------------------------------------------------    	
        // CR Phone (key GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        // CR Fax (key GATCF_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
    	//-------------------------------------------------------------------------------------------
        //Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
    	
        //Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
    	
        //Physician Title
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(selectedCase.Case_Treating_Physician_gne__r.Id));

        //Physician Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(Selectedcase));
        //-------------------------------------------------------------------------------------------
        // PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
     	//-------------------------------------------------------------------------------------------
     	// Document Number (key Documentnumber)
        this.mergeRecipientInfo.add(SCM_MF_ShipmentDetail_FieldFactory.DocumentNumber(selectedCase));
		
		// Purchase Number          
        this.mergeRecipientInfo.add(SCM_MF_ShipmentDetail_FieldFactory.PurchaseNumber(selectedCase));
        
 	   	// ShipDetail
 	   	this.mergeRecipientInfo.add(new SCM_MF_ShipDetail(selectedCase));
     	//-------------------------------------------------------------------------------------------
  	   	// Upp_Approval_date (key Upp Appdate)
 	   	this.mergeRecipientInfo.add(new SCM_MF_Upp_Approval_date(selectedCase));
     	//-------------------------------------------------------------------------------------------
		//CaseWorker
        String recordType = selectedCase.RecordType.Name;        
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
    }
}