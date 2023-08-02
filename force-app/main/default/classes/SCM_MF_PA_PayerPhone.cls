public class SCM_MF_PA_PayerPhone extends scm_MergeField {
   
   public SCM_MF_PA_PayerPhone (Prior_Authorization_gne__c pa)
   {
    key = 'PayerPhone';
    className = 'SCM_MF_PA_PayerPhone';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    try {
    fieldvalue=(pa.Phone_gne__c==null)?'' :pa.Phone_gne__c ;
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}
   }
}