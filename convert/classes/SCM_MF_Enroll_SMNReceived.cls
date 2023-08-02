public class SCM_MF_Enroll_SMNReceived extends SCM_Mergefield
{
	public SCM_MF_Enroll_SMNReceived(Case SelectedCase) {
		key = 'SMNReceivedDate';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		fieldValue = '';
		
	try {
		if (SelectedCase.Enroll_Date_Calc_gne__c != null)
			fieldValue = SelectedCase.Enroll_Date_Calc_gne__c.format();
	}
	catch(Exception ex){
	fieldvalue = '';	
		
	}
	
	}
		
}