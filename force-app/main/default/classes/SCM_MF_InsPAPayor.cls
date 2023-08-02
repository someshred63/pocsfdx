//Added by Sanat
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances.  For each Insurance get all Benefit Investigation.BI_Insurance_gne__c where equal to Insurance.ID and filter the list of BI’s to those that have PA’s and the BI.Status_gne__c = “Complete Pending PA”
//If 0 BI with Complete Pending PA, then “”
//If = 1 BI then use PA and go back to BI and then use the Insurance.Payor_gne__c to Account.ID and merge Account.Name
//If > 1 BI Complete Pending PA, then use last modified PA and use the Insurance.Payor_gne__c to Account.ID and merge Account.Name

public class SCM_MF_InsPAPayor extends SCM_MF_InsuranceCollection{
    private Benefit_Investigation_gne__c BI;
    private Prior_Authorization_gne__c PAuth;
    
    public SCM_MF_InsPAPayor(String caseId) {
        super(caseId);
        key = 'RECNAME_Payor';
        this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = true;
        this.displayLabel = true;
        this.label = 'Addressed To:';
        
        try {
	        if(BIListFil.size() == 0){
	            fieldValue = '';
	        }
	        else if(BIListFil.size() == 1){
	            fieldValue = BIListFil[0].BI_Insurance_gne__r.Payer_gne__r.Name== null ?'' : BIListFil[0].BI_Insurance_gne__r.Payer_gne__r.Name;
	        }
	        else if(BIListFil.size() > 1){
	            fieldValue = BIListFil[0].BI_Insurance_gne__r.Payer_gne__r.Name== null ?'' : BIListFil[0].BI_Insurance_gne__r.Payer_gne__r.Name;
	        }
        }
        catch (Exception e) {
        	fieldValue = '';
        }
        
        if (fieldValue == null)
            fieldValue = '';
    }
    
    public override String getFieldValue() {        
        return fieldValue;
    }
}