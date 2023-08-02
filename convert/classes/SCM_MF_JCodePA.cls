//Added by Sanat
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances.  For each Insurance get all Benefit Investigation.BI_Insurance_gne__c where equal to Insurance.ID and filter the list of BI’s to those that have PA’s and the BI.Status_gne__c = “Complete Pending PA”
//If 0 BI with Complete Pending PA, then “”
//If = 1 BI then use Benefit Investigation.Drug_Billing_Code_gne__c
//If > 1 BI, then use last modified BI’s Benefit Investigation.Drug_Billing_Code_gne__c

public class SCM_MF_JCodePA extends SCM_MF_InsuranceCollection{
	public SCM_MF_JCodePA(String caseId) {
		super(caseId);
		key = 'JCode_PA';
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = false;
        if(BIListFil.size() == 0){
        	fieldValue = '';
        }
        else if(BIListFil.size() >= 1){
        	fieldValue = BIListFil[0].Drug_Billing_Code_gne__c;
        }
        
        if (fieldValue == null)
        	fieldValue = '';
	}
	
	public override String getFieldValue() {		
		return fieldValue;
	}
}