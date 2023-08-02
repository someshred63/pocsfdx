/**************************************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : CMGT-FAX-14_Appeal_Letter_Draft_FinalAnalysis
    // Type              : Fax Coversheet
    // Word Template     : Fax_AppealLetterDraft_OncRheLuc.doc    
    // Label in SF       : Appeal Letter Draft FinalAnalysis
    
/*************************************************************************************/
public class SCM_MD_Fax_AppealLetterDraft_OncRheLuc extends SCM_MergeDocument  implements IStandardComboBox {
    private SCM_MergeSection LucentisFooterInfo;
      
    public SCM_MD_Fax_AppealLetterDraft_OncRheLuc(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }        
    
    public override void createMergeFields() {
        String recordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientId = selectedCase.Patient_gne__r.Id;
        String productName = selectedCase.Product_gne__c;                    
        
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
            
        //CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));                          
        
        //Attn - no logic here, so no factory class can be used. 
        SCM_MergeField attn = new SCM_MergeField();
        attn.key = 'ATTN_Attn';
        attn.label = 'Attn:';
        attn.checked = false;
        attn.displayCheck = false;
        this.mergeRecipientInfo.add(attn);
                        
        //Recname
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //Recfax - no logic here, so no factory class can be used.
        SCM_MergeField recfax = new SCM_MergeField();
        recfax.key = 'RECFAX_Fax';
        recfax.label = 'Fax Number:';
        recfax.checked = false;
        recfax.displayCheck = false;
        recfax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField; 
        this.mergeRecipientInfo.add(recfax);
        
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
           
        //Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate()); 
        
        //Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        
        //DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
        
        //Product
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //Confidentiality Notice        
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase)); 
        
        //Access solutions
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(productName)); 
        
         //CR_Logo
        this.mergeimages.add(new SCM_MI_Logo(selectedCase));

        //comments
         this.mergeFields.add(new SCM_MF_Comments());
 
        // Merge Sections
        LucentisFooterInfo = new SCM_MergeSection();        
        LucentisFooterInfo.key = 'LucentisFooter';
        LucentisFooterInfo.visible = false;
        this.mergeSections.add(LucentisFooterInfo);
    }
      
    public override void getLatestValues() {
        String productname = selectedCase.Product_gne__c;
        productname = (productname == null)?'': productname;
        LucentisFooterInfo.visible = productname.equalsIgnoreCase('Lucentis');
    } 
}