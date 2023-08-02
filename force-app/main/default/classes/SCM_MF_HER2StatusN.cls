public class SCM_MF_HER2StatusN extends SCM_MF_MedicalHistoryCollection{


	private Case selectCase;
	
	public SCM_MF_HER2StatusN(Case selCase) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'HER2StatusN';
    	ClassName = 'SCM_MF_ChkHER2StatusN';
    	fieldValue = GetHER2StatusValue();    	
  	}
  	private string GetHER2StatusValue() {
  		string returnValue = '' ;
  		try {
  		
	  		if(medicalHistory != null){
	  			if(medicalHistory.Her2_Test_gne__c != null)
	  				returnValue = medicalHistory.Her2_Test_gne__c;
	  		}
  		
  		
  		if (returnValue.equalsIgnoreCase('Negative')) {
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