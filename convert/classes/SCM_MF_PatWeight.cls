//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and select 
Medical History.Patient_Weight_kg_gne__c
*/

public class SCM_MF_PatWeight extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_PatWeight(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Weight';
        
        /**
        caseMedHistList = [Select c.Medical_History_gne__r.Patient_Weight_kg_gne__c,
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
  			if(medicalHistory.Patient_Weight_kg_gne__c != null)
  				returnValue = medicalHistory.Patient_Weight_kg_gne__c.format();
  		}
  		
  		return returnValue;
    	/**
    	string ret = '';
    	if(caseMedHistList.size() >= 1)
        {
        	caseMedHist = caseMedHistList[0];
        	if(caseMedHist.Medical_History_gne__r.Patient_Weight_kg_gne__c != null){
        		ret = caseMedHist.Medical_History_gne__r.Patient_Weight_kg_gne__c.format();
        	}                 
        }
       	return ret;
       	*/ 
       	}catch (exception ex){
    		return '';	
    	}
    }
}