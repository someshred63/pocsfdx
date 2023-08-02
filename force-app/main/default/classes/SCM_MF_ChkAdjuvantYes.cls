//Created By: Paras Sharma
/**
If Case.Product_gne__c = Herceptin, then Merge
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Adjuvant_gne__c.
If  Medical History. Adjuvant_gne__c = “Yes”, then merge (checked), else (unchecked)
*/

public class SCM_MF_ChkAdjuvantYes extends SCM_MF_MedicalHistoryCollection{

	private Case selectCase;
	
	public SCM_MF_ChkAdjuvantYes(Case selCase) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'AdjuvantYes';
    	ClassName = 'SCM_MF_ChkAdjuvantYes';
    	fieldValue = GetAdjValue();    	
  	}
  	private string GetAdjValue() {
  		string returnValue = '' ;
  		try {
  		if(selectCase.Product_gne__c == 'Herceptin')
  		{
	  		if(medicalHistory != null){
	  			if(medicalHistory.Adjuvant_gne__c != null)
	  				returnValue = medicalHistory.Adjuvant_gne__c;
	  		}
  		}
  		
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