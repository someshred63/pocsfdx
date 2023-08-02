public class SCM_MF_BI_PriorAuthorization_TAT extends SCM_MergeField {

  public SCM_MF_BI_PriorAuthorization_TAT(Benefit_Investigation_gne__c bi)
  {
  	 	
    key = 'PA_Tat';
    className = 'SSCM_MF_BI_PriorAuthorization_TAT';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  	if (BI.Prior_Authorization_est_tat_gne__c != null) {
  		myvalue =  BI.Prior_Authorization_est_tat_gne__c;
  	} else {
		myvalue = BI.est_tat_pre_determination_gne__c;
  	}
   fieldValue = (myvalue == null)? '': myvalue;
  	
  	
  	
  	
  }
}