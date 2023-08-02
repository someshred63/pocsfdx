public class SCM_MF_FaxExtn extends SCM_MF_FaxWizCollection {
    
    public SCM_MF_FaxExtn(Case selectedCase, String caseRecordType)
    {   
        super(selectedCase,caseRecordType);
        this.key = 'Ext';
        this.checked = false;
        this.label = 'Ext#:'; 
        this.fieldType = SCM_MergeField.FieldTypes.extensionField; 
        this.totalWidth = '90';
        this.width = '40';
        this.IsNewLine = false;
        this.fieldValue = getFieldValue();
        this.isRequired = false;          
    }
    
    public virtual override String getFieldValue() 
    {
        String returnString = ''; 
        try {       
        if(caseRecordTypeLocal.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordTypeLocal.equalsIgnoreCase('C&R - Standard Case')) 
        {                 
        	if ( userListCAndR.size() > 0 ) {
            returnString = (userListCAndR[0].Extension == null)? '': userListCAndR[0].Extension;            
        	}
        }
        else if(caseRecordTypeLocal.equalsIgnoreCase('GATCF - Standard Case'))
        {
        	if ( userListGATCF.size() > 0) {
            returnString = (userListGATCF[0].Extension == null)? '': userListGATCF[0].Extension;
        	}
        }
        }catch (Exception ex){
        returnString = '';	
        }
        return returnString; 
    }
}