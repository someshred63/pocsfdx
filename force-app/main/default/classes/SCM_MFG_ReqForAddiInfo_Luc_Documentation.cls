// Added By: Deepak Yadav
// Doc Name: Fax Cover Sheet Analysis v3.1.doc
// PRODUCT GROUP: OPTHALMOLOGY
// CMGT-FAX-08  Request for Additional Information
public class SCM_MFG_ReqForAddiInfo_Luc_Documentation extends SCM_MergeFieldGroup {
      
    public SCM_MFG_ReqForAddiInfo_Luc_Documentation() {
        super();
        this.headerText = 'Documentation:';
        //displaylabel = true;        
        this.label = 'The following additional document(s) are required by the Payor';      
        key = 'documentation';
         
        // Now, let's add a bunch of fields to the Documentation fieldset.
        SCM_MergeFieldCheckbox checkbox1 = new SCM_MergeFieldCheckbox('smn complete', 'SMN (Complete)');
        checkbox1.isNewLine = false;        
        subFields.add(checkbox1);
        SCM_MergeFieldCheckbox checkbox2 = new SCM_MergeFieldCheckbox('history physical treatment', 'History/Physical/Treatment Plan');
        checkbox2.isNewLine = true;
        subFields.add(checkbox2);        
        SCM_MergeFieldCheckbox checkbox3 = new SCM_MergeFieldCheckbox('current va', 'Current VA');
        checkbox3.isNewLine = true;
        subFields.add(checkbox3);
        subFields.add(new SCM_MergeFieldCheckbox('fa', 'FA'));
        subFields.add(new SCM_MergeFieldCheckbox('progress notes', 'Progress Notes'));
        subFields.add(new SCM_MergeFieldCheckbox('prescription', 'Prescription'));
        subFields.add(new SCM_MergeFieldCheckbox('oct', 'OCT'));
        subFields.add(new SCM_MergeFieldCheckbox('va before treatment', 'VA Before Treatment'));
        subFields.add(new SCM_MergeFieldCheckbox('lesion size', 'Lesion Size'));
        subFields.add(new SCM_MergeFieldCheckbox('prior authorization form', 'Prior Authorization Form'));
        subFields.add(new SCM_MergeFieldCheckbox('pcp referral', 'PCP Referral'));
        subFields.add(new SCM_MergeFieldCheckbox('lesion type', 'Lesion Type'));
        subFields.add(new SCM_MergeFieldCheckbox('lesion position', 'Lesion Position'));      
        subFields.add(new SCM_MergeFieldCheckbox('eye affected', 'Eye Affected (right, left, both)'));
        subFields.add(new SCM_MergeFieldCheckbox('other', 'Other'));

        
        // Other Documentation
        SCM_MergeField_Incomplete mFI_OtherDoc1 = new SCM_MergeField_Incomplete('mFI_OtherDoc1') ;
        mFI_OtherDoc1.className = 'SCM_MFG_ReqForAddiInfo_Luc_Documentation';  
        mFI_OtherDoc1.label = 'Other Documentation'; 
        subFields.add(mFI_OtherDoc1);
           
        
        SCM_MergeField_Incomplete mFI_OtherDoc2 = new SCM_MergeField_Incomplete('mFI_OtherDoc2') ;
        mFI_OtherDoc2.className = 'SCM_MFG_ReqForAddiInfo_Luc_Documentation';
        subFields.add(mFI_OtherDoc2);
        
        SCM_MergeField_Incomplete mFI_OtherDoc3 = new SCM_MergeField_Incomplete('mFI_OtherDoc3') ;
        mFI_OtherDoc3.className = 'SCM_MFG_ReqForAddiInfo_Luc_Documentation';        
        subFields.add(mFI_OtherDoc3);
        
        
        // Initial Request
        SCM_MergeField_Incomplete mFI_InitialRequest = new SCM_MergeField_Incomplete('Initial Request') ;
        mFI_InitialRequest.className = 'SCM_MFG_ReqForAddiInfo_Luc_Documentation';  
        mFI_InitialRequest.label = 'Initial Request'; 
        subFields.add(mFI_InitialRequest);                
    }

}