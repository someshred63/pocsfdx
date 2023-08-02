//Created By: Paras Sharma
/**
Join Medical History.ICD9_Code_2_gne__c to ICD9 Code.ICD9_Code_gne_c 
and merge ICD9.ICD9_Code_gne__c || ICD9 Code.ICD9_Descrption_gne__c
*/

public class SCM_MF_2ICD9Description extends SCM_MergeField{

	protected Case caseMedHist;
	List<Case> caseMedHistList;
	
	public SCM_MF_2ICD9Description(String caseId)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = '2ICD9 Desc';
        
        caseMedHistList = [Select c.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Code_gne__c, 
        		c.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Descrption_gne__c, c.Medical_History_gne__c 
        		From Case c 
                WHERE Id = :caseId  LIMIT 1 ];
            
        fieldValue = getFieldValue();
        
    }
    
    public override String getFieldValue(){
    	string ret = '';
    	try {
    	if(caseMedHistList.size() >= 1)
        {
        	caseMedHist = caseMedHistList[0];
        	if(caseMedHist.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Code_gne__c != null){
        	//	ret = caseMedHist.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Code_gne__c;
        	}
        	if(caseMedHist.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Descrption_gne__c != null){
        		ret = caseMedHist.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Descrption_gne__c;
           //		ret += ' ' + caseMedHist.Medical_History_gne__r.ICD9_Code_2_gne__r.ICD9_Descrption_gne__c;
   
        	}
        	                  
        }
        }catch (exception ex){
    		ret = '';	
    	}
       	return ret; 
    }
}