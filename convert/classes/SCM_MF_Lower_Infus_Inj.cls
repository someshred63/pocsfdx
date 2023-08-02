public class SCM_MF_Lower_Infus_Inj extends SCM_MergeField
{
	
	
	public SCM_MF_Lower_Infus_Inj(String product)
	{ 
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'LowerInfInj';
     try {
     	if (product == 'Rituxan RA' || product == 'Actemra'){
     	fieldvalue = 'infusion'	;
     	}
     	else if (product == 'Xolair' || product == 'Lucentis')
     	{
     		fieldvalue = 'injection';
     	}
     	else {
     		fieldvalue = '';
     	}
     	
     }  Catch(Exception ex) {
     	
     	fieldvalue = '';
     } 
        
		
	}

}