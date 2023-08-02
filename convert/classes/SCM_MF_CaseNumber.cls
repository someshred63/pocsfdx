public class SCM_MF_CaseNumber extends SCM_MergeField {
    public SCM_MF_CaseNumber(Case selectedCase) {
        key = 'Case_Number';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_CaseNumber';
        fieldValue = selectedCase.CaseNumber;
        fieldValue = (fieldValue==null)?'':fieldValue;
    }
    public SCM_MF_CaseNumber(Case selectedCase, string newkey) {
       this(selectedCase);
        key = newkey;
    }
        public override String getFieldValue() {
        return fieldValue;
    }
}