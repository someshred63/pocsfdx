public class SCM_MF_XolairPlus  extends SCM_MergeField
{
	
	 
	public SCM_MF_XolairPlus(String product)
	{
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'XolairPlus';
     try {
     	if (product == 'Xolair'){
     		fieldvalue = 'For Subcutaneous Use'	;
     	}
     	else {
     		fieldvalue = '';
     	}
     	
     }  Catch(Exception ex) {
     	
     	fieldvalue = '';
     } 
        
		
	}

}