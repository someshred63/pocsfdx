//Created by:Shobha Rawat

public class SCM_MF_POAHospIn extends SCM_MF_MedicalHistoryCollection{
	String POAHospInFV = SCM_CheckBox_Values.Unchecked;
		  
	public SCM_MF_POAHospIn(String medicalHistoryID){
    	super(medicalHistoryID);    	      
		Key = 'POAHospIn';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_POAHospIn';
    } 
    
    public override String getFieldValue() {
    	try {
    	if(medicalHistory != Null){
    		string tnmStaging = medicalHistory.Place_of_Administration_gne__c ;
    		if(tnmStaging != Null){
    			if ( tnmStaging.equalsIgnoreCase('Hospital Inpatient')){
    				POAHospInFV  = SCM_CheckBox_Values.checked;
    			}	
    		}
    	}
    	}catch (exception ex){
    		return  SCM_CheckBox_Values.unchecked;	
    	}
    	return POAHospInFV ;
 	}
	

}