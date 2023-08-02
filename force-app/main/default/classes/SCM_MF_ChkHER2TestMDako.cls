//Created By: Paras Sharma
/**
If Case.Product_gne__c = Herceptin, then Merge
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.First_Assay_Test_Used_gne__c.
If Medical History.First_Assay_Test_Used_gne__c = “Dako IHC”, then merge (checked) , else (unchecked)
*/

public class SCM_MF_ChkHER2TestMDako extends SCM_MF_MedicalHistoryCollection{

	private Case selectCase;
	
	public SCM_MF_ChkHER2TestMDako(Case selCase) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'HER2TestMDakoIHC';
    	ClassName = 'SCM_MF_ChkHER2TestMDako';
    	fieldValue = GetHER2TestValue();    	
  	}
  	private string GetHER2TestValue() {
  		string returnValue = '' ;
  		 try {
  		if(selectCase.Product_gne__c == 'Herceptin')
  		{
	  		if(medicalHistory != null){
	  			if(medicalHistory.First_Assay_Test_Used_gne__c != null)
	  				returnValue = medicalHistory.First_Assay_Test_Used_gne__c;
	  		}
  		}
  		
  		if (returnValue.equalsIgnoreCase('Dako IHC')) {
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