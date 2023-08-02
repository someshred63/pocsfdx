public class SCM_MF_PA_PayerAddress extends scm_MergeField {
   
   public SCM_MF_PA_PayerAddress (Prior_Authorization_gne__c pa)
   {
    key = 'PayerAddress';
    className = 'SCM_MF_PA_AuthorizedBy';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    fieldvalue='';
    try {
    
    	if (pa.Address_Line_1_gne__c != null){
    		fieldvalue+=pa.Address_Line_1_gne__c  ;
    	}
    	if (pa.Address_Line_2_gne__c != null){
    		fieldvalue+=pa.Address_Line_2_gne__c;
    	}
    	if (fieldValue != ''){
    		fieldvalue+= ', ';
    	}
    	if (pa.City_gne__c != null){
    		fieldvalue+=pa.City_gne__c + ' ';
    	}
    	if (pa.State_gne__c != null){
    		fieldvalue+=pa.State_gne__c + ' ';
    	}
    	if (pa.Zip_gne__c != null){
    		fieldvalue+=pa.Zip_gne__c ;
    	}
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}
   }
}