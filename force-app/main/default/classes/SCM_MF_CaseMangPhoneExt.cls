// Added By: Deepak Yadav
// Merge field for Case Manger Phone extension
public class SCM_MF_CaseMangPhoneExt extends SCM_MF_CaseMangCollection {
	  
	public SCM_MF_CaseMangPhoneExt(String userId) {
		super(userId);
		
		this.key = 'Case Manger Phone Ext';
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = true;
        this.displayLabel = true;
        this.fieldType = SCM_MergeField.FieldTypes.extensionField; 
       	this.totalWidth = '90';
       	this.width = '40';
       	this.isNewLine = false;
       	this.isRequired = false;
	}
	
	    
    
	public override String getFieldValue() {		
		if(caseManager !=null && caseManager.Extension != null ){			
  			return  caseManager.Extension ;   		
		}
		else {
			return '';
		}
  	}

}