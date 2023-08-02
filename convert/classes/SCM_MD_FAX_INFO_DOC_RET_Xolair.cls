/********************************************************************/
    // Developer Name    : shobha Rawat
    // Document Name     : XOL_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL
    // PRODUCT GROUP     : Respiratory / Xolair
    // Type              : Fax Coversheet
    // Word Template     : CMGT-FAX-01-GATCF-InformationDocumentRetrieval.doc
    // Label in SF       : Information-Documentation Retrieval
/********************************************************************/


public class SCM_MD_FAX_INFO_DOC_RET_Xolair extends SCM_MergeDocument implements IStandardComboBox{

 public SCM_MD_FAX_INFO_DOC_RET_Xolair(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
    	
      	string caseRecordType = selectedCase.RecordType.Name ;
      	string pId= selectedCase.Patient_gne__c;
      	string physicianId=selectedCase.Case_Treating_Physician_gne__r.Id;
    	
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        //0 Case Number (CaseID) (Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //1 Patient ID (Patient Id)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		//-------------------------------------------------------------------------------------------    	
        //2 GATCF Phone (GATCF_Phone)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //3 GATCF Fax (GATCF_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        //4 GATCF URL (GATCF_URL)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
    	//-------------------------------------------------------------------------------------------
        //5 Product Name (Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
    	//-------------------------------------------------------------------------------------------
    	//6 PrivacyNotice (PrivacyNotice)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
    	
        //7 Confidentiality Notice (ConfidNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
		//-------------------------------------------------------------------------------------------
        //8 Current Date (Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
		//-------------------------------------------------------------------------------------------
        //9 PatientFullName(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pId));

        //10 Patient DOB (Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pId));
    	//-------------------------------------------------------------------------------------------
    	// First Page
    	//-------------------------------------------------------------------------------------------
        //11 Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //12 Addressed To(RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));

        //13 Fax(RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));

        //14 From(From)
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        
        //15. Extension  (Ext)       
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        //-------------------------------------------------------------------------------------------
        //second page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.key = 'Documentation';
        this.mergeFields.add(docu);
        //-------------------------------------------------------------------------------------------
        
        //  Comments
        //this.mergeFields.add(new SCM_MF_Comments());
        
       this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_XolairPlus(SelectedCase.Product_gne__c));	
		//17. comments
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        comments.headerText = 'Comments: ';       
        comments.key = 'Comment';           
        
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        CommentField.key = 'Comments';                       
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);
        
    }


}