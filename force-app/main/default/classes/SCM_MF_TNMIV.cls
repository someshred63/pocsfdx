//Created by:Shobha Rawat


public class SCM_MF_TNMIV extends  SCM_MF_MedicalHistoryCollection{

String TNMIVFV = SCM_CheckBox_Values.Unchecked;
		  
	public SCM_MF_TNMIV(String medicalHistoryID){
    	super(medicalHistoryID);    	      
		Key = 'TNMIV';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_TNMIV';
    } 
    
    public override String getFieldValue() {
    	
    	if(medicalHistory != Null){
    		string tnmStaging = medicalHistory.TNM_Staging_gne__c;
    		if(tnmStaging != Null){
    			if ( tnmStaging.equalsIgnoreCase('Stage IV (Advanced Metastatic Disease) / Dukes D')){
    				TNMIVFV  = SCM_CheckBox_Values.checked;
    			}
    		}	
    			
    	}
    	return TNMIVFV ;
 	}

}