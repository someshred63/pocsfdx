// Created By: Paras Sharma
/**
Created for CMGT-FAX-04 GATCF Tab - GATCF Referral for Injection Training.doc
If the product = Raptiva then
This editable field is initialized for this template:   CBS/Intake
Else if the product = Nutropin then
This editable field is initialized for this template:   GH Injection Training
*/

public class SCM_MF_Fax_AttnRefForInjTrain extends SCM_MergeField{

	protected Case selCase;
    
    public SCM_MF_Fax_AttnRefForInjTrain(Case selectedcase) {      
        selCase = selectedCase;
        key = 'ATTN_Ref';
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        label='Attn';
        className = 'SCM_MF_Fax_AttnRefForInjTrain';
        fieldValue = getFieldValue();
    }
    
     public override String getFieldValue() {
        string ret = '';
        if(selCase != null && selCase.product_gne__c != null){
            if(selCase.product_gne__c == 'Raptiva'){
            	ret = 'CBS/Intake';
            }
            else if(selCase.product_gne__c == 'Nutropin'){
            	ret = 'GH Injection Training';
            }
        }
        return ret;
        
    }
}