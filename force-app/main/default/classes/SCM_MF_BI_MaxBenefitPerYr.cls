public class SCM_MF_BI_MaxBenefitPerYr extends SCM_MergeField {

  public SCM_MF_BI_MaxBenefitPerYr(Benefit_Investigation_gne__c bi)
  {
  		
    key = 'MaxBenefitPerYear';
    className = 'SCM_MF_BI_MaxBenefitPerYr';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
  	string myvalue = '';
  
  if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
  	if (BI.IN_Max_Benefit_Individual_gne__c == null  &&  BI.IN_Max_Benefit_Individual_Met_gne__c == null && BI.IN_Max_Benefit_Amount_Used_gne__c == null) {
  	 myvalue =  'None';
  	}
  	else if (BI.IN_Max_Benefit_Individual_gne__c == null) {
     myvalue = scm_format.ToCurrency(BI.IN_Max_Benefit_Amount_Used_gne__c) + ' met';
  }
  else if (BI.IN_Max_Benefit_Amount_Used_gne__c == null) {
      myvalue = scm_format.ToCurrency(BI.IN_Max_Benefit_Individual_gne__c);
  }
	else {
		myvalue =scm_format.ToCurrency(BI.IN_Max_Benefit_Individual_gne__c) +'; '+ scm_format.ToCurrency(BI.IN_Max_Benefit_Amount_Used_gne__c) +' met';
	}
  
  
  }
  else {
  	  	if (BI.OT_Max_Benefit_Individual_gne__c == null  &&  BI.OT_Max_Benefit_Individual_Met_gne__c == null && bi.OT_Max_Benefit_Indv_Used_gne__c == null) {
  	 myvalue =  'None';
  	}
  	else if (BI.OT_Max_Benefit_Individual_gne__c == null) {
     myvalue = scm_format.ToCurrency(BI.OT_Max_Benefit_Indv_Used_gne__c) + ' met';
  }
  else if (BI.OT_Max_Benefit_Indv_Used_gne__c == null) {
      myvalue = scm_format.ToCurrency(BI.OT_Max_Benefit_Individual_gne__c);
  }
	else {
		myvalue =scm_format.ToCurrency(BI.OT_Max_Benefit_Individual_gne__c) +'; $'+ string.valueof(BI.OT_Max_Benefit_Indv_Used_gne__c) +' met';
	}
  }
  	 fieldValue = (myvalue == null)? '': myvalue;
  	  fieldValue = (myvalue == '$null met')? '': myvalue;
  }
}