//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Previous_Therapy_Regimens_gne__c. 
If Medical History.Previous_Therapy_Regimens_gne__c = “Avastin”, then merge (checked), else (unchecked)
*/

public class SCM_MF_ChkAvastin extends SCM_MF_MedicalHistoryCollection {
		String chkAvastin = SCM_CheckBox_Values.Unchecked;
	public SCM_MF_ChkAvastin(String medicalHistoryID) {    
    	
    	super(medicalHistoryID);
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'Avastin';
    	ClassName = 'SCM_MF_ChkAvastin';
    	fieldValue = GetAvastinValue();    	
  	}
  	private String GetAvastinValue() {
  		
  		string returnValue ='';
  		
  		if(medicalHistory != null){
  			if(medicalHistory.Previous_Therapy_Regimens_gne__c != null)
  				returnValue = medicalHistory.Previous_Therapy_Regimens_gne__c;
  				
  		}  		
  		if (returnValue.equalsIgnoreCase('Avastin')) {
            chkAvastin = SCM_CheckBox_Values.Checked;
  		}
       // else {
        //    chkAvastin = SCM_CheckBox_Values.Unchecked;
       // }
        return chkAvastin;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
	
}