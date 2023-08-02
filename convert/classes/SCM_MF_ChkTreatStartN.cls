//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Date_of_First_Treatment_gne__c. 
If Medical History.Date_of_First_Treatment is null, then merge (checked) , else (unchecked)
*/

public class SCM_MF_ChkTreatStartN extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_ChkTreatStartN(String medicalHistoryID) {    
    	
    	super(medicalHistoryID);
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'TreatStartN';
    	ClassName = 'SCM_MF_ChkTreatStartN';
    	fieldValue = GetTreatStartValue();    	
  	}
  	private string GetTreatStartValue() {
  		string returnValue = '' ;
  		 try { 		
  		if(medicalHistory != null){
  			if(medicalHistory.Date_of_First_Treatment_gne__c != null)
  				returnValue = medicalHistory.Date_of_First_Treatment_gne__c.format();
  		}
  		}catch (exception ex){
    		returnvalue = '';	
    	}
  		if (returnValue == '') {
            returnValue = SCM_CheckBox_Values.Checked;
  		}
        else {
            returnValue = SCM_CheckBox_Values.Unchecked;
        }
        return returnValue;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
}