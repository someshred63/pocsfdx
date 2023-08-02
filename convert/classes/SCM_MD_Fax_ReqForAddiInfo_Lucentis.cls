// Added By: Deepak Yadav
// Doc Name: Fax Cover Sheet Analysis v3.1.doc
// PRODUCT GROUP: OPTHALMOLOGY
// CMGT-FAX-08  Request for Additional Information
public class SCM_MD_Fax_ReqForAddiInfo_Lucentis extends SCM_MergeDocument {
    
    public SCM_MD_Fax_ReqForAddiInfo_Lucentis(String caseID,String argLookupID) {
        super(caseID, argLookupID);          
    } 
    
    public override void createMergeFields() {      
        
        // SCM_MergeField_Incomplete for field Attn
        SCM_MergeField_Incomplete mFI_Attn = new SCM_MergeField_Incomplete('Attn') ;        
        mFI_Attn.label='Attn:';
        mFI_Attn.className = 'SCM_MD_Fax_MessageDetails_Lucentis';                
        mFI_Attn.checked = false;
        mFI_Attn.displayCheck = false;
        mFI_Attn.displayTextBox = true;
        mFI_Attn.displayLabel = true;
        mFI_Attn.setFieldValue('');         
        this.mergeRecipientInfo.add(mFI_Attn);    
        
        // SCM_MergeField_Incomplete for field Fax No
        SCM_MergeField_Incomplete mFI_FaxNo = new SCM_MergeField_Incomplete('Fax No') ;     
        mFI_FaxNo.label='Fax Number:';
        mFI_FaxNo.className = 'SCM_MD_Fax_MessageDetails_Lucentis';                
        mFI_FaxNo.checked = false;
        mFI_FaxNo.displayCheck = false;
        mFI_FaxNo.displayTextBox = true;
        mFI_FaxNo.displayLabel = true;
        mFI_FaxNo.setFieldValue(''); 
        this.mergeRecipientInfo.add(mFI_FaxNo);
                
        // addressedTo
        String toValue ;
        SCM_MF_PhysicianFirstMidAndLastName addressedTo = new SCM_MF_PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
        addressedTo.key = 'addressed To';
        addressedTo.label='Addressed To:';
        addressedTo.className = 'SCM_MD_Fax_MessageDetails_Lucentis';
        toValue = (addressedTo.getFieldValue() == null)? '': addressedTo.getFieldValue();
        if(toValue.Trim() != ''){
            toValue = toValue + ' ,M.D.' ;
        }               
        addressedTo.fieldValue= toValue ;        
        addressedTo.checked = false;
        addressedTo.displayCheck = false;
        addressedTo.displayTextBox = true;
        addressedTo.displayLabel = true;        
        this.mergeRecipientInfo.add(addressedTo);
        
        // From
        SCM_MF_CaseMangFirstAndLastName caseMangName = 
                                new SCM_MF_CaseMangFirstAndLastName(selectedCase.Case_Manager__r.Id);       
        caseMangName.key = 'from';
        caseMangName.label='From:'; 
        caseMangName.className = 'SCM_MD_Fax_MessageDetails_Lucentis';        
        caseMangName.fieldValue= (caseMangName.getFieldValue() == null)? '': caseMangName.getFieldValue();  
        caseMangName.checked = false;
        caseMangName.displayCheck = false;
        caseMangName.displayTextBox = true;
        caseMangName.displayLabel = true;
        caseMangName.setFieldValue('');
        this.mergeRecipientInfo.add(caseMangName);
        
        
        // Ext #
        SCM_MF_CaseMangPhoneExt extNo = 
                                new SCM_MF_CaseMangPhoneExt(selectedCase.Case_Manager__r.Id);       
        extNo.key = 'extNo';
        extNo.label='Ext #:';   
        extNo.className = 'SCM_MD_Fax_MessageDetails_Lucentis';        
        extNo.fieldValue= (extNo.getFieldValue() == null)? '': extNo.getFieldValue();  
        extNo.checked = false;
        extNo.displayCheck = false;
        extNo.displayTextBox = true;
        extNo.displayLabel = false;                         
        this.mergeRecipientInfo.add(extNo); 
          
        
        //=================================== second Screen================================================
        
        
        this.mergeFields.add(new SCM_MFG_ReqForAddiInfo_Luc_Documentation());
        
        // commets      
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        comments.label = 'Comments:';
        comments.headerText = 'Comments.';       
        comments.key = 'Comments';
        comments.isFieldGroup = true;
        //comments.fieldType = textField;
        
        SCM_MergeField CommentField = new SCM_MergeField();
        CommentField.key = 'CommentField';
        CommentField.label='Comments';  
        CommentField.className = 'SCM_MD_Fax_MessageDetails_Lucentis';        
        CommentField.fieldValue= '';  
        CommentField.checked = false;
        CommentField.displayCheck = false;
        CommentField.displayTextBox = true;
        CommentField.displayLabel = false;  
        comments.subFields.add(CommentField);
        
        this.mergeFields.add(comments);
        
        
        
    }
}