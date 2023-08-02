//Created by:Shobha Rawat

public class SCM_MF_TNMIIIB extends  SCM_MF_MedicalHistoryCollection{
	String TNMIIIBFV = SCM_CheckBox_Values.Unchecked;
		  
	public SCM_MF_TNMIIIB(String medicalHistoryID){
    	super(medicalHistoryID);    	      
		Key = 'TNMIIIB';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_TNMIIIB';
    } 
    
    public override String getFieldValue() {
    	
    	if(medicalHistory != Null){
    		string tnmStaging = medicalHistory.TNM_Staging_gne__c;
    		if(tnmStaging != Null){
    			if ( tnmStaging.equalsIgnoreCase('Stage IIIB(Advanced Local Disease) / Dukes C')){
    				TNMIIIBFV  = SCM_CheckBox_Values.checked;
    			}
    		}	
    	}
    	return TNMIIIBFV ;
 	}

}