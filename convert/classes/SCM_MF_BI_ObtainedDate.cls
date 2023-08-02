public class SCM_MF_BI_ObtainedDate extends SCM_MergeField {

  public SCM_MF_BI_ObtainedDate(Benefit_Investigation_gne__c bi)
  {
  try{	
    key = 'ObtainedDate';
    className = 'SCM_BI_ObtainedDate';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
    
  		string myvalue = bi.BI_Obtained_Date_gne__c.format('MM/dd/yyyy');
  		
  		
  	
  	 fieldValue = (myvalue == null)? '': myvalue;
  }
  catch(exception ex){
  	fieldValue = '';
  }
  }
}