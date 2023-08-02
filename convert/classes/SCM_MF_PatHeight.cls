//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select 
Medical History.Patient_Height_gne__c
*/

public class SCM_MF_PatHeight extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_PatHeight(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Height';
        
        /**
        caseMedHistList = [Select c.Medical_History_gne__r.Patient_Height_gne__c,
        		c.Medical_History_gne__c 
        		From Case c 
                WHERE Id = :caseId  LIMIT 1 ];
           */ 
        fieldValue = getFieldValue();
        
    }
    
    public override String getFieldValue(){
    	string returnValue = '';
  		  		try {
  		if(medicalHistory != null){
  			if(medicalHistory.Patient_Height_gne__c != null)
  				returnValue = medicalHistory.Patient_Height_gne__c.format();
  		}
  		
  		return returnValue;
    	
       	}catch (exception ex){
    		return '';	
    	}
    }
}