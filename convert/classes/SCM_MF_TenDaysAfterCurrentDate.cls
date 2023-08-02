//Added By : Rajesh Sinha
/**
Compute: Sysdate plus 10 days.  
Display format: mm/dd/yyyy
*/

public class SCM_MF_TenDaysAfterCurrentDate extends SCM_MergeField {
	public SCM_MF_TenDaysAfterCurrentDate() {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key = 'TenDaysAfterCurrentDate';
        fieldValue = Date.today().addDays(10).format();
        className = 'SCM_MF_TenDaysAfterCurrentDate';
  }
}