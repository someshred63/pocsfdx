//Added by Manjunath Nilagiri
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances.  For each Insurance get all Benefit Investigation.BI_Insurance_gne__c where equal to Insurance.ID and filter the list of BI’s to those that have PA’s and the BI.Status_gne__c = “Complete Pending PA”
//If 0 BI with Complete Pending PA, then “”
//If = 1 BI then use Benefit Investigation.Drug_Billing_Code_gne__c
//If > 1 BI, then use last modified BI’s Benefit Investigation.Drug_Billing_Code_gne__c

public class SCM_MF_ChkJCode_PA extends SCM_MF_InsuranceCollection{
public SCM_MF_ChkJCode_PA(String caseId) {
		super(caseId);
		key = 'ChkJCode_PA';
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = false;
        this.ClassName = 'SCM_MF_ChkJCode_PA';
        fieldValue = SCM_CheckBox_Values.UnChecked;
		String retValue =  SCM_CheckBox_Values.UnChecked;
		       
        if(BIListFil.size() == 0){
        	retValue = '';
        	fieldValue = SCM_CheckBox_Values.UnChecked;
        }
        else if(BIListFil.size() >= 1){
        	retValue = BIListFil[0].Drug_Billing_Code_gne__c == null?'':BIListFil[0].Drug_Billing_Code_gne__c;
        	fieldValue =BIListFil[0].Drug_Billing_Code_gne__c == null?SCM_CheckBox_Values.UnChecked:SCM_CheckBox_Values.Checked; 
        }
        
        if (fieldValue == null)
        	{
        		retValue = '';
        		fieldValue = SCM_CheckBox_Values.UnChecked;
        	}
        	
       //	if (retValue.length() > 0)
       	//	fieldValue = SCM_CheckBox_Values.UnChecked;
		//else
        //	fieldValue = SCM_CheckBox_Values.Checked;
     
	}
	
	public override String getFieldValue() {		
		return fieldValue;
	}
}