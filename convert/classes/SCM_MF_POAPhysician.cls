//Created by:Shobha Rawat

public class SCM_MF_POAPhysician extends SCM_MF_MedicalHistoryCollection{
	String POAPhysicianFV = SCM_CheckBox_Values.Unchecked;
		  
	public SCM_MF_POAPhysician(String medicalHistoryID){
    	super(medicalHistoryID);    	      
		Key = 'POAPhysician';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_POAPhysician';
    } 
    
    public override String getFieldValue() {
    	try {
    	if(medicalHistory != Null){
    		string tnmStaging = medicalHistory.Place_of_Administration_gne__c ;
    		if(tnmStaging != Null){
    			if ( tnmStaging.equalsIgnoreCase('MD Office / Clinic')){
    				POAPhysicianFV  = SCM_CheckBox_Values.checked;
    			}
    		}	
    	}
    	return POAPhysicianFV ;
    	}catch (exception ex){
    		return  SCM_CheckBox_Values.unchecked;	
    	}
 	}
	

}