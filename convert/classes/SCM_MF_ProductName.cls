// Added By: Deepak Yadav
// Merge field for product name
public class SCM_MF_ProductName extends SCM_MergeField {
    protected Case patientCase;
    
    public SCM_MF_ProductName(Case selectedcase) {      
        patientCase = selectedCase;
        key = 'Product Name';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_ProductName';
    }
    
     public override String getFieldValue() {
        if(patientCase != null && patientCase.product_gne__c != null){
            return patientCase.product_gne__c ;
        }
        else {
            return '';
        }
        
    }

}