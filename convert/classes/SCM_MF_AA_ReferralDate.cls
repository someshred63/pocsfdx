public class SCM_MF_AA_ReferralDate extends SCM_MergeField{
public SCM_MF_AA_ReferralDate(Case SelectedCase)
	{
		 Case SelCase = SelectedCase;
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		key = 'AA_ReferralDate';
		displayLabel = false;
		
		try {
  			
  		
  			fieldvalue =  string.valueof(SelCase.CreatedDate.format('MM/dd/yyyy'));
  		}catch (Exception ex) {
  			fieldValue = '';
  		}
	}
	
}