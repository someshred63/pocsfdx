public class SCM_MF_PA_AuthorizedBy extends scm_MergeField {
   
   public SCM_MF_PA_AuthorizedBy (Prior_Authorization_gne__c pa)
   {
    key = 'AuthorizedBy';
    className = 'SCM_MF_PA_AuthorizedBy';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    try {
    fieldvalue=(pa.PA_Contact_Name_gne__c==null)?'' :pa.PA_Contact_Name_gne__c ;
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}
   }
}