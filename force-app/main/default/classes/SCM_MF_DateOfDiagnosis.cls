//Created By: Paras Sharma

public class SCM_MF_DateOfDiagnosis extends SCM_MergeField{

	protected Case caseDateDiag;
	List<Case> caseDateDiagList;
	
	public SCM_MF_DateOfDiagnosis(String caseId)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = true;
        key = 'Date Of Diagnosis';
        try{
        	caseDateDiagList = [Select c.Medical_History_gne__r.Date_of_Diagnosis_gne__c, c.Medical_History_gne__c 
        		From Case c 
                WHERE Id = :caseId  LIMIT 1 ];
        
        fieldValue = getFieldValue();
        }catch(Exception e){
        	caseDateDiagList = null;	
        	fieldValue = getFieldValue();
        }
    }
    
    public override String getFieldValue(){
    	if(caseDateDiagList.size() >= 1)
        {
        	caseDateDiag = caseDateDiagList[0];
        	if(caseDateDiag.Medical_History_gne__r.Date_of_Diagnosis_gne__c != null){
        		return caseDateDiag.Medical_History_gne__r.Date_of_Diagnosis_gne__c.format();
        	}
        	else{return '';}                        
        }
            
        else
        {        	
        	return '';       
        }
    }
}