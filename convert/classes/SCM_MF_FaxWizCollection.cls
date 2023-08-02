public virtual class SCM_MF_FaxWizCollection extends SCM_MergeField{
	
	protected Case selectedCaseLocal;
    protected String caseRecordTypeLocal;
    protected List<User> userListCAndR;
    protected List<User> userListGATCF;
	
	public SCM_MF_FaxWizCollection(Case selectedCase, String caseRecordType)
	{
		selectedCaseLocal = selectedCase;
        caseRecordTypeLocal = caseRecordType;
        //this.key = 'Ext';
        this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = true;
        this.displayLabel = true;
        //this.label = 'Ext#:'; 
        //this.fieldType = SCM_MergeField.FieldTypes.extensionField; 
        //this.totalWidth = '80';
        //this.width = '40';
        this.isNewLine = true;
        this.IsRequired = false;
        //this.fieldValue = getFieldValue();
        
        if(caseRecordTypeLocal.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordTypeLocal.equalsIgnoreCase('C&R - Standard Case')) {  
                
            userListCAndR = [Select u.Extension, u.Name From User u 
            where u.id = :selectedCaseLocal.Case_Manager__r.Id LIMIT 1];                                 
        }
        else if(caseRecordTypeLocal.equalsIgnoreCase('GATCF - Standard Case'))
        {
            userListGATCF = [Select u.Extension, u.Name From User u 
            where u.id = :selectedCaseLocal.Foundation_Specialist_gne__r.Id LIMIT 1];                         
        }
        
        
        
        
	}

}