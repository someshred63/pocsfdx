/********************************************************************/
    // Developer Name    : Sanat Gersappa
    // Document Name     : LUC-CMGT-FAX-19 INO Resource Letter.doc
    // Type              : Fax Coversheet
    // Word Template     : INO_Resource_Letter.doc    
    // Label in SF       : INO Resource Letter
    
/********************************************************************/
public class SCM_MD_Fax_INOResLett_Luc extends SCM_MergeDocument {
    public SCM_MD_Fax_INOResLett_Luc(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
       //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient ID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //Fax
        SCM_MergeField recfax = new SCM_MergeField();
        recfax.key = 'RECFAX_Blank';
        recfax.label = 'Fax Number:';
        recfax.checked = false;
        recfax.displayCheck = false;
        recfax.displayTextBox = true;
        recfax.displayLabel = true;
        recfax.isRequired = true;
        recfax.fieldValue ='';
        recfax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        this.mergeRecipientInfo.add(recfax);

        //Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //The following fields added to meet mandatory field requirements.
        SCM_MergeField attn = new SCM_MergeField();
        attn.key = 'ATTN_Attn';
        attn.isRequired = false;
        attn.setControlStyle('visibility:hidden');
        this.mergeRecipientInfo.add(attn);
    }
}