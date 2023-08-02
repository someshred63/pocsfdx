public class SCM_MF_BI_Payer extends SCM_MergeField {

  public SCM_MF_BI_Payer(Benefit_Investigation_gne__c bi)
  {
  	try {
    key = 'Payer';
    className = 'SCM_MF_BI_Payer';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
    
  		string myvalue = bi.Payer_BI_gne__r.Name;
  		
  	
  	 fieldValue = (myvalue == null)? '': myvalue;
  	}
  	catch(exception ex){
  		fieldValue = '';	
  	}
}
}