//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and 
select Medical History.Freqcy_of_Admin_gne__c
*/

public class SCM_MF_FrequencyOfAdmin extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_FrequencyOfAdmin(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Freq_Admin';
        
        /**
        caseMedHistList = [Select c.Medical_History_gne__r.Freqcy_of_Admin_gne__c,
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
  			if(medicalHistory.Freqcy_of_Admin_gne__c != null)
  				returnValue = medicalHistory.Freqcy_of_Admin_gne__c;
  		}
  		}catch (exception ex){
    		returnvalue = '';	
    	}
  		return returnValue;
    	/**
    	string ret = '';
    	if(caseMedHistList.size() >= 1)
        {
        	caseMedHist = caseMedHistList[0];
        	if(caseMedHist.Medical_History_gne__r.Freqcy_of_Admin_gne__c != null){
        		ret = caseMedHist.Medical_History_gne__r.Freqcy_of_Admin_gne__c;
        	}                 
        }
       	return ret; 
       	*/
    }
}