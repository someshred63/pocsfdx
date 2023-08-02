// Added by Jatin Setia
// Merge class for GATCF DisclaimerSp
public class SCM_MF_GATCFDisclaimerSp extends SCM_Mergefield
{
	public SCM_MF_GATCFDisclaimerSp() {
		key = 'GATCF Disclaimer';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		fieldValue = 'Genentech Access To Care Foundation, a su sola y absoluta discreción, ' + 
			'se reserva el derecho de modificar o suspender el programa en cualquier momento y ' +
			'también verificar la exactitud de la información presentada.';
		className = 'SCM_MF_GATCFDisclaimerSp';
	}
	
	public override String getFieldValue() {
		return fieldValue;		
	}
}