public class SCM_MF_BI_InsuranceAllowable extends SCM_MergeField {

  public SCM_MF_BI_InsuranceAllowable(Benefit_Investigation_gne__c bi)
  {
  		
    key = 'InsuranceAllowable';
    className = 'SCM_MF_BI_InsuranceAllowable';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  
  if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
  	myvalue = BI.INA_Drug_Payer_gne__c;
   if (BI.I_N_Payer_Allowable_percent_gne__c != null && BI.INA_Drug_Payer_gne__c != null) {
   	myvalue +=  '; '+ BI.I_N_Payer_Allowable_percent_gne__c;
   }
  }
  else {
  	myvalue = BI.OTA_Drug_Payer_Allowable_gne__c; 
	if (BI.O_N_Payer_Allowable_percent_gne__c != null && BI.OTA_Drug_Payer_Allowable_gne__c != null) { 
   myvalue += '; ' + BI.O_N_Payer_Allowable_percent_gne__c;
	}
  	 
  }
  fieldValue = (myvalue == null)? '': myvalue;
}
}