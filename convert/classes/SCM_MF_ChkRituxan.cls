//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Previous_Therapy_Regimens_gne__c. 
If Medical History.Previous_Therapy_Regimens_gne__c = “Rituxan”, then merge (checked), else (unchecked)
*/

public class SCM_MF_ChkRituxan extends SCM_MF_MedicalHistoryCollection{
	String ChkRituxan = SCM_CheckBox_Values.Unchecked;
	public SCM_MF_ChkRituxan(String medicalHistoryID) {    
    	
    	super(medicalHistoryID);
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'Rituxan';
    	ClassName = 'SCM_MF_ChkRituxan';
    	fieldValue = GetRituxanValue();    	
  	}
  	private String GetRituxanValue() {
  		string returnValue ;
  		  		
  		if(medicalHistory != null){
  			if(medicalHistory.Previous_Therapy_Regimens_gne__c != null)
  				returnValue = medicalHistory.Previous_Therapy_Regimens_gne__c;
  		}
  		if(returnValue!=null){
  			if (returnValue.equalsIgnoreCase('Rituxan')) {
            	ChkRituxan = SCM_CheckBox_Values.Checked;
  			}
  		}
      //  else {
      //      ChkRituxan = SCM_CheckBox_Values.Unchecked;
      //  }
        return ChkRituxan;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
}