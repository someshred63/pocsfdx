public class SCM_MF_PtDeductAmt extends scm_MergeField {

	 public SCM_MF_PtDeductAmt(Benefit_Investigation_gne__c bi)
	 {
		key = 'PtDeductAmt';
	    className = 'SCM_MF_PtDeductAmt';
	    checked = false;
	    displayCheck = false;
	    displayTextBox = false; 
	    displayLabel = false;
	    fieldValue = '';
	    try {
	    if (bi.Product_Covered_By_gne__c == 'In Network Benefits')
	    {
	       if(bi.IND_None_gne__c=='No')
	       {
	        fieldValue = 'None';
	       }
	       else
	       {
	        fieldValue=(bi.IND_Individual_gne__c==null)?'':'$'+string.valueof(bi.IND_Individual_gne__c);
	       }
	    
	    }
	    
	    if (bi.Product_Covered_By_gne__c == 'Out of Network Benefits')
	    {
	       if(bi.OTD_None_gne__c=='No')
	       {
	        fieldValue = 'None';
	       }
	       else
	       {
	        fieldValue=(bi.OTD_Individual_gne__c==null)?'':'$'+string.valueof(bi.OTD_Individual_gne__c);
	       }
	    
	    }
	 }
	 
   	catch (Exception ex){
   		fieldvalue= '';
   	}
	 }
}