public class SCM_MF_PreExisting extends SCM_MergeField {

  public SCM_MF_PreExisting(Benefit_Investigation_gne__c bi)
  {
  		
    key = 'PreExisting';
    className = 'SCM_MF_PreExisting';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  
  if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
  	if (BI.IN_Condtn_gne__c == NULL) {
  		myvalue = 'N/A';
  	} else {
  		myvalue = BI.IN_Condtn_gne__c;
  	}
  }
  else {
  		if (BI.OT_Condtn_gne__c == NULL) {
  		myvalue = 'N/A';
  	} else {
  		myvalue = BI.OT_Condtn_gne__c;
  	}
  }
  fieldvalue = myvalue;
  }
}