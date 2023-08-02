public class SCM_MF_FaxFrom extends SCM_MF_FaxWizCollection
{   
	public SCM_MF_FaxFrom(Case selectedCase, String caseRecordType)
    {   
        super(selectedCase,caseRecordType);
        this.key = 'From';
        this.label = 'From:'; 
        this.fieldType = SCM_MergeField.FieldTypes.textboxField ; 
        this.fieldValue = this.getFieldValue();          
    } 
     
    public override String getFieldValue() 
    {   
    String returnString = '';	
    try {
    	     
        if(caseRecordTypeLocal.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordTypeLocal.equalsIgnoreCase('C&R - Standard Case')) 
        {                 
        	if (userListCAndR.size() > 0) {
            returnString =  (userListCAndR[0].Name == null)? '':userListCAndR[0].Name;
        	} 
        }
        else if(caseRecordTypeLocal.equalsIgnoreCase('GATCF - Standard Case'))
        {
        	if (userListGATCF.size() > 0) {
        	returnString =  (userListGATCF[0].Name == null)? '':userListGATCF[0].Name;
        	}                          
        }    
    }catch(Exception ex){
    returnString = '';	
    	
    }
        
        
                   
        return returnString;
    }
    
     
    
}