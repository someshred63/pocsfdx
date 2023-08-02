public class SCM_MF_BenifitType extends scm_MergeField {
   
   public SCM_MF_BenifitType (Benefit_Investigation_gne__c bi)
   {
    key = 'BenefitType';
    className = 'SCM_MF_BenifitType';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    try {
    fieldvalue=(bi.Benefit_Type_gne__c==null)?'' :bi.Benefit_Type_gne__c ;
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}
   }
}