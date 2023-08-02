public class SCM_MF_InsuranceNameRecertRpt extends scm_MergeField{
  
  public  SCM_MF_InsuranceNameRecertRpt (Insurance_gne__c ins)
  {
    key = 'AA_InsuranceNamePrimary';
    className = 'SCM_MF_InsuranceName_BI';
    checked = false;
    fieldValue = '';
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
 	fieldvalue = '';
 	try {
 		
 		fieldvalue =ins.Rank_gne__c + ':' + ins.Payer_gne__r.Name;
 	}
 	catch(Exception ex){
 		fieldvalue ='';
 	}
 
  } 
}