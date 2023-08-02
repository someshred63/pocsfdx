//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Previous_Therapy_Regimens_gne__c. 
If Medical History.Previous_Therapy_Regimens_gne__c = “Herceptin”, then merge (checked), else (unchecked)
*/

public class SCM_MF_ChkHerceptin extends SCM_MF_MedicalHistoryCollection{
	String chkHercerptin = SCM_CheckBox_Values.Unchecked;
	public SCM_MF_ChkHerceptin(String medicalHistoryID) {    
    	
    	super(medicalHistoryID);
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'Herceptin';
    	ClassName = 'SCM_MF_ChkHerceptin';
    	fieldValue = GetHerceptinValue();    	
  	}
  	private String GetHerceptinValue() {
  		string returnValue ;
  		  		
  		if(medicalHistory != null){
  			if(medicalHistory.Previous_Therapy_Regimens_gne__c != null)
  				returnValue = medicalHistory.Previous_Therapy_Regimens_gne__c;
  		}
  		
  		if (returnValue.equalsIgnoreCase('Herceptin')) {
            chkHercerptin = SCM_CheckBox_Values.Checked;
  		}
        //else {
       //     chkHercerptin = SCM_CheckBox_Values.Unchecked;
       // }
        return chkHercerptin;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
}