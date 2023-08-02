//Created By : Jatin
//Logic : Get Case.Approval_Date_gne__c

public class SCM_MF_Upp_Approval_date extends SCM_MergeField{
        
        public SCM_MF_Upp_Approval_date(Case selectedCase ){
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key='Upp Appdate';
        className = 'SCM_MF_UppApprovaldate';
       
        if (selectedCase.Approval_Date_gne__c!= null)
          fieldValue = selectedCase.Approval_Date_gne__c.format();
        else
          fieldValue = '';
    
       }
        public override String getFieldValue() {
        return fieldValue;
    }
}