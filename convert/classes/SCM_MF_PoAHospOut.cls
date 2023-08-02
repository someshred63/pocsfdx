//Created by:Shobha Rawat

public class SCM_MF_PoAHospOut extends SCM_MF_MedicalHistoryCollection{
	String PoAHospOutFV = SCM_CheckBox_Values.Unchecked;
		  
	public SCM_MF_PoAHospOut(String medicalHistoryID){
    	super(medicalHistoryID);    	      
		Key = 'PoAHospOut';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_PoAHospOut';
    } 
    
    public override String getFieldValue() {
    	try {
    	if(medicalHistory != Null){
    		string tnmStaging = medicalHistory.Place_of_Administration_gne__c ;
    		if(tnmStaging != Null){
    			if ( tnmStaging.equalsIgnoreCase('Hospital Outpatient')){
    				PoAHospOutFV  = SCM_CheckBox_Values.checked;
    			}
    		}	
    	}
    	return PoAHospOutFV ;
    	
    	}catch (exception ex){
    		return  SCM_CheckBox_Values.unchecked;	
    	}
 	}
	

}