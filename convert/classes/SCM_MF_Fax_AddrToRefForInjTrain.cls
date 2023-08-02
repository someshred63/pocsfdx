//Created By: Paras Sharma
/**
This editable field is hardcoded for this template: Nova Factor/CBS
*/
public class SCM_MF_Fax_AddrToRefForInjTrain extends SCM_MergeField{

	public SCM_MF_Fax_AddrToRefForInjTrain() {      
        key = 'RecName';
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        label='Addressed To:';
        className = 'SCM_MF_Fax_AddrToRefForInjTrain';
        fieldValue = getFieldValue();
    }
    
     public override String getFieldValue() {
        return 'Nova Factor/CBS';
    }
}