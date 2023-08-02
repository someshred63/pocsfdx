//Created By: Paras Sharma
/**
Join Case.Medical_History_gne__c to Medical History.ID and 
select Medical History.Maint_Dose_mg_gne__c
*/

public class SCM_MF_Dose extends SCM_MF_MedicalHistoryCollection{

	public SCM_MF_Dose(String medicalHistoryID)
    {
    	super(medicalHistoryID);
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Dose';
        
        /**
        caseMedHistList = [Select c.Medical_History_gne__r.Maint_Dose_mg_gne__c,
        		c.Medical_History_gne__c 
        		From Case c 
                WHERE Id = :caseId  LIMIT 1 ];
           */ 
        fieldValue = getFieldValue();
        
    }
    
    public override String getFieldValue(){
    	string returnValue = '';
    	try {
  		//system.Debug(medicalHistory.Dosage_Infused_mg_gne__c.format());  		
  		if(medicalHistory != null){
  			if (medicalHistory.Product_gne__c != null)
  			{
  				if (medicalHistory.Product_gne__c == 'Avastin')
  					returnValue = medicalHistory.Dosage_Infused_mg_gne__c.format();
  				if ((medicalHistory.Product_gne__c == 'Rituxan') || (medicalHistory.Product_gne__c == 'Tarceva'))
  							returnValue = medicalHistory.Dosage_mg_gne__c.format();  				
  				if (medicalHistory.Product_gne__c == 'Herceptin')
  					returnValue = medicalHistory.Maint_Dose_mg_gne__c.format();
  			}
  			//if(medicalHistory.Dosage_Infused_mg_gne__c != null)
  			//	returnValue = medicalHistory.Dosage_Infused_mg_gne__c.format();
  		}  	
  		}catch (exception ex){
    		returnvalue = '';	
    	}	
  		return returnValue;
    	
    
		/**
    	Dosage_Infused_mg_gne__c
    	string ret = '';
    	if(caseMedHistList.size() >= 1)
        {
        	caseMedHist = caseMedHistList[0];
        	if(caseMedHist.Medical_History_gne__r.Maint_Dose_mg_gne__c != null){
        		ret = caseMedHist.Medical_History_gne__r.Maint_Dose_mg_gne__c.format();
        	}                 
        }
       	return ret;
       	*/ 
    }
}