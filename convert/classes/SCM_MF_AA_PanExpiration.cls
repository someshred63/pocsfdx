public class SCM_MF_AA_PanExpiration extends SCM_MergeField{
public SCM_MF_AA_PanExpiration(Case SelectedCase)
	{
		 Case SelCase = SelectedCase;
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		key = 'AA_PanExpiration';
		displayLabel = false;
		
		try {
  		List<Patient_gne__c> Pat = [select p.PAN_Form_2_Product_gne__c, p.PAN_Form_2_Exipration_Date_gne__c, p.PAN_Form_1_Product_gne__c, p.PAN_Form_1_Expiration_Date_gne__c From Patient_gne__c p where (id = :selectedCase.Patient_gne__c and PAN_Form_1_Product_gne__c = 'Rituxan RA') or (id = :selectedCase.Patient_gne__c and PAN_Form_2_Product_gne__c = 'Rituxan RA') limit 1];
  			if (pat.size() > 0){
  				if (pat[0].PAN_Form_1_Product_gne__c != null && pat[0].PAN_Form_1_Product_gne__c == 'Rituxan RA'){
  					if (pat[0].PAN_Form_1_Expiration_Date_gne__c  != null)
  					fieldvalue = string.valueof(pat[0].PAN_Form_1_Expiration_Date_gne__c.format());
  					
  				}else if(pat[0].PAN_Form_2_Product_gne__c != null && pat[0].PAN_Form_2_Product_gne__c == 'Rituxan RA'){
  					if (pat[0].PAN_Form_2_Exipration_Date_gne__c != null)
  					fieldvalue = string.valueof(pat[0].PAN_Form_2_Exipration_Date_gne__c.format());
  					
  				}	
  				
  			}
  			else {
  				fieldValue = 'No PAN on file';
  				
  			}
  			if (fieldvalue == null)
  				fieldvalue = 'No PAN on file';
  		}catch (Exception ex) {
  			fieldValue = '';
  		}
	}
	
}