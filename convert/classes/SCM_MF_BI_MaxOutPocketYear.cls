public class SCM_MF_BI_MaxOutPocketYear extends SCM_MergeField {

  public SCM_MF_BI_MaxOutPocketYear(Benefit_Investigation_gne__c bi)
  {
  		
    key = 'MaxOutPocketYear';
    className = 'SCM_MF_BI_MaxOutPocketYear';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  
  if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
  	   if (BI.IN_Max_Year_gne__c == 'No') {
  	   	myvalue = 'None';
  	   }
  	   else{ 
  	   	  if (BI.IN_Pocket_Individual_gne__c == NULL && BI.IN_Pocket_Individual_amt_gne__c != NULL)
  	   	  {
       		myvalue = scm_format.ToCurrency(BI.IN_Pocket_Individual_amt_gne__c) + ' met';
  	   	  }
  	   	  else if (BI.IN_Pocket_Individual_amt_gne__c == NULL && BI.IN_Pocket_Individual_gne__c != NULL) 
  	   	  {
       		myvalue =scm_format.ToCurrency(BI.IN_Pocket_Individual_gne__c);
  	   	  }
		  else if (BI.IN_Pocket_Individual_amt_gne__c != NULL && BI.IN_Pocket_Individual_gne__c != NULL)
		  {
		   	myvalue = scm_format.ToCurrency(BI.IN_Pocket_Individual_gne__c) + '; ' + scm_format.ToCurrency(BI.IN_Pocket_Individual_amt_gne__c) + ' met';
  		  }
  		  else{
  		  myvalue = '';
  		  }
  	   }
  }
  else {
  	   if (BI.OT_Out_Pocket_N_A_gne__c ==  'No') {
  	   	myvalue = 'None';}
  	   	else {
  				if (BI.OT_Out_Pocket_Individual_gne__c == NULL && BI.OT_Out_Pocket_Individual_amount_met_gne__c != NULL) {
  			       myvalue = scm_format.ToCurrency(BI.OT_Out_Pocket_Individual_amount_met_gne__c) + ' met';
  				}
  				else if (BI.OT_Out_Pocket_Individual_amount_met_gne__c == NULL && BI.OT_Out_Pocket_Individual_gne__c != NULL) {
       				myvalue =scm_format.ToCurrency(BI.OT_Out_Pocket_Individual_gne__c);
  				}
  				else if(BI.OT_Out_Pocket_Individual_amount_met_gne__c != NULL && BI.OT_Out_Pocket_Individual_gne__c != NULL) {
  					myvalue = scm_format.ToCurrency(BI.OT_Out_Pocket_Individual_gne__c) + '; '+ scm_format.ToCurrency(BI.OT_Out_Pocket_Individual_amount_met_gne__c) + ' met';
  				}
  				  	
  	   	}
  }


 fieldValue = (myvalue == null)? '': myvalue;
  }
}