//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and 
select Medical History.Number_of_Doses_gne__c
*/

public class SCM_MF_NumberOfDoses extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_NumberOfDoses(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Num_Doses';
        
        /**
        caseMedHistList = [Select c.Medical_History_gne__r.Number_of_Doses_gne__c,
        		c.Medical_History_gne__c 
        		From Case c 
                WHERE Id = :caseId  LIMIT 1 ];
           */ 
        fieldValue = getFieldValue();
        
    }
    
    public override String getFieldValue(){
    	string returnValue = '';
  		 try  { 		
  		if(medicalHistory != null){
  			if(medicalHistory.Number_of_Doses_gne__c != null)
  				returnValue = medicalHistory.Number_of_Doses_gne__c.format();
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
        	if(caseMedHist.Medical_History_gne__r.Number_of_Doses_gne__c != null){
        		ret = caseMedHist.Medical_History_gne__r.Number_of_Doses_gne__c.format();
        	}                 
        }
       	return ret;
       	*/ 
    }
}