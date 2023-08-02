//Created By: Paras Sharma
/**
If the product = Raptiva then
This editable field is hardcoded for this template: (888) 267-5443
Else if the product = Nutropin then
This editable field is hardcoded for this template: (877) 222-2334
*/

public class SCM_MF_Fax_FaxRefForInjTrain extends SCM_MergeField{

	protected Case selCase;
    
    public SCM_MF_Fax_FaxRefForInjTrain(Case selectedcase) {      
        selCase = selectedCase;
        key = 'RECFAX_Fax';
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        label='Fax:';
        fieldType = scm_MergeField.FieldTypes.phoneNumberField;
        className = 'SCM_MF_Fax_FaxRefForInjTrain';
        fieldValue = getFieldValue();
    }
    
     public override String getFieldValue() {
        string ret = '';
        if(selCase != null && selCase.product_gne__c != null){
            if(selCase.product_gne__c == 'Raptiva'){
            	ret = '(888) 267-5443';
            }
            else if(selCase.product_gne__c == 'Nutropin'){
            	ret = '(877) 222-2334';
            }
        }
        return ret;
        
    }
}