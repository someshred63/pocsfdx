//Created By: Paras Sharma
/**
Join Case.Patient_gne__c to Patient.PatientID_gne__c  and select Patient.pat_patient_deceased_gne__c
If  Patient.pat_patient_deceased_gne__c  = “Yes”, then merge (checked) , else (unchecked)
*/

public class SCM_MF_PatientDeceasedY extends SCM_MergeField{

	private string case_ID;
	
	
	public SCM_MF_PatientDeceasedY(String caseId) {    
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'PatientDeceasedY';
    	ClassName = 'SCM_MF_PatientDeceasedY';
    	this.case_ID = caseId;
    	fieldValue = GetPatientDeceasedValue();    	
  	}
  	private string GetPatientDeceasedValue() 
  	{
  		string returnValue = '';
  		 try {
  		List<Case> cas = [Select c.Patient_gne__r.pat_patient_deceased_gne__c, 
	        	c.Patient_gne__c From Case c
	        	where c.Id = :case_ID limit 500];
	        
        if (cas.size() > 0)
        	returnValue = cas[0].Patient_gne__r.pat_patient_deceased_gne__c;
	    
  		returnValue = (returnValue == null)?'': returnValue;
  		if (returnValue.equalsIgnoreCase('Yes')) {
            returnValue = SCM_CheckBox_Values.Checked;
  		}
        else {
            returnValue = SCM_CheckBox_Values.Unchecked;
        }
        }catch (exception ex){
    		returnvalue = SCM_CheckBox_Values.Unchecked;	
    	}
        return returnValue;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
	
}