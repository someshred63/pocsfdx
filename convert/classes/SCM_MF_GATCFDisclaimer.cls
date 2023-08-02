// Added by Jatin Setia
// Merge class for GATCF Disclaimer
public class SCM_MF_GATCFDisclaimer extends SCM_Mergefield
{
	public SCM_MF_GATCFDisclaimer() {
		key = 'GATCF Disclaimer';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		fieldValue = 'Genentech® Access To Care Foundation at its sole and'+
					  'absolute discretion  reserves the right to modify or discontinue the program'+ 
					  'at any time and to verify the accuracy of the information submitted.';
		className = 'SCM_MF_GATCFDisclaimer';
	}
	
	public override String getFieldValue() {
		return fieldValue;		
	}
}