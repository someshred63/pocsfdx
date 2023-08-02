public class SCM_MF_BillingClaimsPANote extends SCM_MergeField {

  public SCM_MF_BillingClaimsPANote(Benefit_Investigation_gne__c bi)
  {
  		
    key = 'BillingClaimsPANote';
    className = 'SCM_MF_BillingClaimsPANote';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  	if (BI.required_for_billing_gne__c !=NULL) {
  		myvalue = 'The Payer requires the following to be submitted with your claim: ' + BI.required_for_billing_gne__c.replace(';',', ');
  	}	   
   fieldValue = (myvalue == null)? '': myvalue;
  }
  
}