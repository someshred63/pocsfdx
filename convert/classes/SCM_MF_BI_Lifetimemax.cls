public class SCM_MF_BI_Lifetimemax extends scm_MergeField {
	public SCM_MF_BI_Lifetimemax(Benefit_Investigation_gne__c bi) {
	key = 'LifeTimeMax';
    className = 'SCM_MF_BI_Lifetimemax';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    string myvalue ='';
    
    if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
    	if (BI.IN_Max_Life_gne__c == 'N/A' || BI.IN_Max_Life_gne__c == 'None') {
    	myvalue = 'None';	
    	}
    	else {
			if (BI.IN_Max_Life_Amount_gne__c == NULL && BI.IN_Max_Remaining_Amount_gne__c != NULL) {
       myvalue = scm_format.ToCurrency(BI.IN_Max_Remaining_Amount_gne__c) +' remaining';
			}
			else if (BI.IN_Max_Remaining_Amount_gne__c == NULL && BI.IN_Max_Life_Amount_gne__c != NULL) {
				myvalue = scm_format.ToCurrency(BI.IN_Max_Life_Amount_gne__c);
			}
			else if (BI.IN_Max_Remaining_Amount_gne__c != NULL && BI.IN_Max_Life_Amount_gne__c != NULL){
				myvalue = scm_format.ToCurrency(BI.IN_Max_Life_Amount_gne__c) +'; ' + scm_format.ToCurrency(BI.IN_Max_Remaining_Amount_gne__c) + ' remaining';
				
    	}
    }
    }
    else {
    	if (BI.OT_Max_Life_gne__c == 'N/A' || BI.OT_Max_Life_gne__c == 'None') {
    	myvalue = 'None';	
    	}
    	else {
			if (BI.OT_Max_Life_Amount_gne__c == NULL && BI.OT_Max_Remaining_Amount_gne__c != NULL) {
       myvalue = scm_format.ToCurrency(BI.OT_Max_Remaining_Amount_gne__c) +' remaining';
			}
			else if (BI.OT_Max_Remaining_Amount_gne__c == NULL && BI.OT_Max_Life_Amount_gne__c != NULL) {
				myvalue = scm_format.ToCurrency(BI.OT_Max_Life_Amount_gne__c);
			}
			else if (BI.OT_Max_Remaining_Amount_gne__c != NULL && BI.OT_Max_Life_Amount_gne__c != NULL){
				myvalue = scm_format.ToCurrency(BI.OT_Max_Life_Amount_gne__c) +'; '+ scm_format.ToCurrency(BI.OT_Max_Remaining_Amount_gne__c) + ' remaining';
    	}
    }
    	
    }
     fieldValue = (myvalue == null)? '': myvalue;	
    }
}