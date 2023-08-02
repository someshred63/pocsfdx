public class SCM_MF_BI_PatientCostShare extends SCM_MergeField {

  public SCM_MF_BI_PatientCostShare(Benefit_Investigation_gne__c bi)
  {
  	
    key = 'PatCostShares';
    className = 'SCM_MF_BI_PatientCostShare';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  try {
  if (BI.Product_Covered_By_gne__c == 'In Network Benefits') 
  {
  	  if  (BI.INC_Patient_Amount_gne__c == NULL) 
  	  {
       myvalue =BI.INC_Patient_PC_gne__c==null?'': string.valueof(BI.INC_Patient_PC_gne__c) + '%';
  	  }
  	  else if (BI.INC_Patient_PC_gne__c == NULL) 
  	  {
       myvalue = scm_format.ToCurrency(BI.INC_Patient_Amount_gne__c);
  	  }
  	  else {
  	  	myvalue =string.valueof(BI.INC_Patient_PC_gne__c)+ '% and '+scm_format.ToCurrency(BI.INC_Patient_Amount_gne__c);
  	  }
  }
  else 
  {
  	  if  (BI.OTC_Patient_Amount_gne__c == NULL) 
  	  {
       myvalue =BI.OTC_Patient_gne__c==null?'': string.valueof(BI.OTC_Patient_gne__c) + '%';
  	  }
  	 
  	  else if (BI.OTC_Patient_Amount_gne__c == NULL) 
  	  {
       myvalue = scm_format.ToCurrency(BI.OTC_Patient_Amount_gne__c);
  	  }
  	  else {
  	  	myvalue =string.valueof(BI.OTC_Patient_gne__c)+ '% and '+scm_format.ToCurrency(BI.OTC_Patient_Amount_gne__c);
  	  }
  }
 	fieldValue = (myvalue == null)? '': myvalue;
  } 
   	catch (Exception ex){
   		fieldValue= '';
   	}
  
  }
}