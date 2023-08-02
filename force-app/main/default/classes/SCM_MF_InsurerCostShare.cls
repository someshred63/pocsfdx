public class SCM_MF_InsurerCostShare extends scm_MergeField {
	public SCM_MF_InsurerCostShare(Benefit_Investigation_gne__c bi) {
	key = 'InsCostShare';
    className = 'SCM_MF_InsurerCostShare';
    checked = false;
    displayCheck = false;
    displayTextBox = false; 
    displayLabel = false;
    string myvalue ='';
    
     if (BI.Product_Covered_By_gne__c == 'In Network Benefits') {
     myvalue =BI.INC_Insurer_gne__c == null?'': string.valueof(BI.INC_Insurer_gne__c) +'%';	
     }
     else {
     	myvalue =bi.OTC_Insurer_gne__c==null?'': string.valueof(bi.OTC_Insurer_gne__c)+'%';
     }
    fieldValue = (myvalue == null)? '': myvalue;
    
	}
	
}