//Created By: Paras Sharma

public class SCM_MF_PrimaryICD9Code extends SCM_MergeField{

    protected Case caseMedHist;
    List<Case> caseMedHistList;
    
    public SCM_MF_PrimaryICD9Code(String caseId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Primary ICD9 Code';
        
        caseMedHistList = [Select c.Medical_History_gne__r.ICD9_Code_1_gne__r.ICD9_Code_gne__c, c.Medical_History_gne__c 
                From Case c 
                WHERE Id = :caseId  LIMIT 1 ];
        fieldvalue=getFieldValue();        
        
    }
    
    public override String getFieldValue(){
    	try {
        if(caseMedHistList.size() >= 1)
        {
            caseMedHist = caseMedHistList[0];
            if(caseMedHist.Medical_History_gne__r.ICD9_Code_1_gne__r.ICD9_Code_gne__c != null){
                return caseMedHist.Medical_History_gne__r.ICD9_Code_1_gne__r.ICD9_Code_gne__c;
            }
            else{return '';}                        
        }
            
        else
        {           
            return '';       
        }
         }catch (exception ex){
    		return  '';	
    	}
    }
}