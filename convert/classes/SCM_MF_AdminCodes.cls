public class SCM_MF_AdminCodes extends SCM_MergeField {

  public SCM_MF_AdminCodes(Benefit_Investigation_gne__c bi)
  {
  		
    key = 'AdminCodes';
    className = 'SCM_MF_AdminCodes';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  
  if (BI.First_Hour_cpt_gne__c == NULL && BI.Subsequent_hours_cpt_gne__c != NULL) {
  	 myvalue = BI.Subsequent_hours_cpt_gne__c;
  } else if (BI.Subsequent_hours_cpt_gne__c == NULL && BI.First_Hour_cpt_gne__c != NULL)
  {
  	myvalue = BI.First_Hour_cpt_gne__c;
  	}
  	else if  (BI.Subsequent_hours_cpt_gne__c == NULL && BI.First_Hour_cpt_gne__c == NULL) {
  		myvalue = '';
  	} else if(BI.First_Hour_cpt_gne__c != null && BI.Subsequent_hours_cpt_gne__c != null){
		myvalue = BI.First_Hour_cpt_gne__c + '/' + BI.Subsequent_hours_cpt_gne__c;
  	}
  	fieldValue = (myvalue == null)? '': myvalue;
  }
}