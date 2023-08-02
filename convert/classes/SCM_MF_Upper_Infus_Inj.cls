public class SCM_MF_Upper_Infus_Inj extends SCM_MergeField
{
	
	 
	public SCM_MF_Upper_Infus_Inj(String product)
	{
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'UpperInfInj';
     try {
     	if (product == 'Rituxan RA' || product == 'Actemra'){
     	fieldvalue = 'Infusion'	;
     	}
     	else if (product == 'Xolair' || product == 'Lucentis')
     	{
     		fieldvalue = 'Injection';
     	}
     	else {
     		fieldvalue = '';
     	}
     	
     }  Catch(Exception ex) {
     	
     	fieldvalue = '';
     } 
        
		
	}

}