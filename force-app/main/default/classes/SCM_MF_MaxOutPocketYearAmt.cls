public class SCM_MF_MaxOutPocketYearAmt extends scm_MergeField {

   public SCM_MF_MaxOutPocketYearAmt(Benefit_Investigation_gne__c bi)
   {
   
    	key = 'MaxOutPocketYearAmt';
	    className = 'SCM_MF_MaxOutPocketYearAmt';
	    checked = false;
	    displayCheck = false;
	    displayTextBox = false; 
	    displayLabel = false;
	    fieldValue = '';
        try {
        if (bi.Product_Covered_By_gne__c == 'In Network Benefits')
	    {
	      if(bi.IN_Max_Year_gne__c=='false')
	       {
	        fieldValue = 'None';
	       }
	       else
	       {
	        fieldValue=(bi.IN_Pocket_Individual_gne__c==null)?'':'$'+string.valueof(bi.IN_Pocket_Individual_gne__c);
	       }
	    
	    }
        
        if (bi.Product_Covered_By_gne__c == 'Out of Network Benefits')
	    {
	       if(bi.OT_Out_Pocket_N_A_gne__c=='false')
	       {
	        fieldValue = 'None';
	       }
	       else
	       {
	        fieldValue=(bi.OT_Out_Pocket_Individual_gne__c==null)?'':'$'+string.valueof(bi.OT_Out_Pocket_Individual_gne__c);
	       }
	    
	    }
    } 
   	catch (Exception ex){
   		fieldValue = '';
   	}    
   }

}