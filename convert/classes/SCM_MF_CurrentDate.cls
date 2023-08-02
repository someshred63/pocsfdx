public class SCM_MF_CurrentDate extends SCM_MergeField {
  public SCM_MF_CurrentDate() {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        setKey('Current_Date');
        fieldValue = Date.today().format();
        className = 'SCM_MF_CurrentDate';
  }
  public SCM_MF_CurrentDate( string newkey) {
       this();
        key = newkey;
    }
}