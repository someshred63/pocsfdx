//condition is as follows
//If Case.CoPay_Amount_gne__c AND Case.CoPay_Percent_gne__c <> NULL,
//Merge Case.CoPay_Amount_gne__c | “and” | Case.CoPay_Percent_gne__c
//Else
//If Case.CoPay_Amount_gne__c = NULL, then merge Case.CoPay_Percent_gne__c
//Else
//If Case.CoPay_Percent_gne__c = NULL, then merge Case.CoPay_Amount_gne__c

public class SCM_MF_TotalCopay extends SCM_MergeField
{
	  public SCM_MF_TotalCopay(Case SelectedCase)
	  {
	      checked=false;
	      displayCheck=false;
	      displayTextBox=false;
	      displayLabel=false;
	      Key='Copay';
	      className='SCM_MF_TotalCopay';
	      fieldValue = obtainTotalCopay(SelectedCase); 
	  }
	  public String obtainTotalCopay(Case SelectedCase)
	  {
	  	
	  try {
	    String returnString=''; 
	    if(SelectedCase.CoPay_Percent_gne__c!=null && SelectedCase.CoPay_Amount_gne__c!=null)
	    {
	     returnString= '$'+SelectedCase.CoPay_Amount_gne__c.format() + +' and '+ SelectedCase.CoPay_Percent_gne__c.format()+'%' ;
	    }
	    else if(SelectedCase.CoPay_Percent_gne__c==null && SelectedCase.CoPay_Amount_gne__c!=null)
	    {
	     returnString='$'+SelectedCase.CoPay_Amount_gne__c.format();
	    }
	    else if(SelectedCase.CoPay_Percent_gne__c!=null && SelectedCase.CoPay_Amount_gne__c==null)
	    {
	     returnString=SelectedCase.CoPay_Percent_gne__c.format()+'% ';
	    }
	    
	    if(returnString==null)
  	   {
  	    returnString='';
  	   }
  	   return returnString;
	     	} 
   	catch (Exception ex){
   		return '';
   	}
	  
	  }
	  
	  public override String getFieldvalue()
	  {
	    return fieldValue;
	  }    
}