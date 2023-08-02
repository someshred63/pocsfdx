//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Previous_Therapy_Regimens_gne__c. 
If Medical History.Previous_Therapy_Regimens_gne__c = “Tarceva”, then merge (checked), else (unchecked)
*/

public class SCM_MF_ChkTarceva extends SCM_MF_MedicalHistoryCollection{
	String ChkTarceva = SCM_CheckBox_Values.Unchecked;
	public SCM_MF_ChkTarceva(String medicalHistoryID) {    
    	
    	super(medicalHistoryID);
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'Tarceva';
    	ClassName = 'SCM_MF_ChkTarceva';
    	fieldValue = GetTarcevaValue();    	
  	}
  	private String GetTarcevaValue() {
  		string returnValue ;
  		  		
  		if(medicalHistory != null){
  			if(medicalHistory.Previous_Therapy_Regimens_gne__c != null)
  				returnValue = medicalHistory.Previous_Therapy_Regimens_gne__c;
  		}
  		if(returnValue!=null){
  			if (returnValue.equalsIgnoreCase('Tarceva')) {
            	ChkTarceva = SCM_CheckBox_Values.Checked;
  			}
  		}
        //else {
        //    ChkTarceva = SCM_CheckBox_Values.Unchecked;
       // }
        return ChkTarceva;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
}