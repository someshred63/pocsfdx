public class SCM_MF_PayerFax extends scm_MergeField {
   
   public SCM_MF_PayerFax (Prior_Authorization_gne__c pa)
   {
    key = 'PayerFax';
    className = 'SCM_MF_PayerFax';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    try {
    fieldvalue=(pa.Fax_gne__c==null)?'' :pa.Fax_gne__c ;
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}
   }
}