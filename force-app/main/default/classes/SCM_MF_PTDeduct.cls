public class SCM_MF_PTDeduct extends scm_MergeField {
	public SCM_MF_PTDeduct(Benefit_Investigation_gne__c bi) {
	key = 'PTDeduct';
    className = 'PTDeduct';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    string myvalue ='';
    
    if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
    	if (BI.IND_None_gne__c == 'No') {
    		myvalue = 'None';
    	}
    	else{
    		if (bi.IND_Individual_gne__c == null && BI.IND_Indv_Amount_gne__c != null) {
    			myvalue = scm_format.ToCurrency(BI.IND_Indv_Amount_gne__c) + 'met';
    		}
    		else if (BI.IND_Indv_Amount_gne__c == null && bi.IND_Individual_gne__c != null) { 
    			myvalue = scm_format.ToCurrency(BI.IND_Individual_gne__c);
    		}
    		else if(BI.IND_Indv_Amount_gne__c != null && bi.IND_Individual_gne__c != null) {
    			myvalue = scm_format.ToCurrency(BI.IND_Individual_gne__c) + '; ' + scm_format.ToCurrency(BI.IND_Indv_Amount_gne__c) + ' met';
        		}
        	else {
        		myvalue = '';
    	} 
    	}	
    }
    else
    {
    	if (BI.OTD_None_gne__c == 'No') {
    		myvalue = 'None';
    	}
    	else{
    		if (bi.OTD_Individual_gne__c == null && bi.OTD_Indv_Amount_Met_gne__c != NULL) {
    			myvalue = scm_format.ToCurrency(BI.OTD_Indv_Amount_Met_gne__c) + 'met';
    		}
    		else if (bi.OTD_Indv_Amount_Met_gne__c == NULL && bi.OTD_Individual_gne__c!= null) { 
    			myvalue = scm_format.ToCurrency(BI.OTD_Individual_gne__c);
    		}
    		else if(bi.OTD_Indv_Amount_Met_gne__c != NULL && bi.OTD_Individual_gne__c!= null){
    			myvalue = scm_format.ToCurrency(BI.OTD_Individual_gne__c) + '; ' + scm_format.ToCurrency(BI.OTD_Indv_Amount_Met_gne__c) + ' met';
        	 	}
        	else {
        		myvalue = '';        	
        	}
    	} 
    	
    }
    fieldValue = (myvalue == null)? '': myvalue;
	}
}