//Created By: Paras Sharma
/**
If Case.Product_gne_c = “Herceptin”, then
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Her2_Test_gne__c. 
If Medical History.Her2_Test_gne__c = “Positive”, then merge (checked) , else (unchecked)
*/

public class SCM_MF_ChkHER2StatusP extends SCM_MF_MedicalHistoryCollection{

	private Case selectCase;
	
	public SCM_MF_ChkHER2StatusP(Case selCase) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'HER2StatusP';
    	ClassName = 'SCM_MF_ChkHER2StatusP';
    	fieldValue = GetHER2StatusValue();    	
  	}
  	private string GetHER2StatusValue() {
  		string returnValue = '' ;
  		try {
  		if(selectCase.Product_gne__c == 'Herceptin')
  		{
	  		if(medicalHistory != null){
	  			if(medicalHistory.Her2_Test_gne__c != null)
	  				returnValue = medicalHistory.Her2_Test_gne__c;
	  		}
  		}
  		
  		if (returnValue.equalsIgnoreCase('Positive')) {
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