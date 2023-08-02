//Created By : Deepti
//Join Case.Medical_History_gne__c to Medical History.ID and 
//select Medical History.Prescription_Type_gne__c. 
//If Medical History.Prescription_Type_gne__c= “Pediatric”, then merge , else •

public class SCM_MF_ChkPediatric extends SCM_MF_MedicalHistoryCollection{
	private Case selectCase;
	
	public SCM_MF_ChkPediatric(Case selCase) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'Pediatric';
    	ClassName = 'SCM_MF_ChkPediatric';
    	fieldValue = GetHisPresTypeValue();    	
  	}
  	
  	 private string GetHisPresTypeValue() {
  		string returnValue = '' ;
  		  		
  	    if(medicalHistory != null){
	  	  if(medicalHistory.Prescription_Type_gne__c != null){
	  		returnValue = medicalHistory.Prescription_Type_gne__c;
	  		}
  		}
  		
  		if (returnValue.equalsIgnoreCase('Pediatric')) {
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