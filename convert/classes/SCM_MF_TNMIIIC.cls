//Created by:Shobha Rawat

public class SCM_MF_TNMIIIC extends SCM_MF_MedicalHistoryCollection{
	String TNMIIICFV = SCM_CheckBox_Values.Unchecked;
		  
	public SCM_MF_TNMIIIC(String medicalHistoryID){
    	super(medicalHistoryID);    	      
		Key = 'TNMIIIC';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_TNMIIIC';
    } 
    
    public override String getFieldValue() {
    	
    	if(medicalHistory != Null){
    		string tnmStaging = medicalHistory.TNM_Staging_gne__c;
    		if(tnmStaging != Null){
    			if ( tnmStaging.equalsIgnoreCase('Stage IIIC (Advanced Local Disease) / Dukes C')){
    				TNMIIICFV  = SCM_CheckBox_Values.checked;
    			}
    		}	
    	}
    	return TNMIIICFV ;
 	}
	
	

}