//Added by Sanat
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances.  For each Insurance get all Benefit Investigation.BI_Insurance_gne__c where equal to Insurance.ID and filter the list of BI’s to those that have PA’s and the BI.Status_gne__c = “Complete Pending PA”
//If 0 BI with Complete Pending PA, then “”
//If 1 BI with Complete Pending PA, then Prior Authorization.Contact_Name_gne__c
//If > 1 BI Complete Pending PA, then use last modified PA for the Prior Authorization.Prior Authorization.Fax_gne__c
public class SCM_MF_InsPAContactFax extends SCM_MF_InsuranceCollection{
	private Benefit_Investigation_gne__c BI;
	private Prior_Authorization_gne__c PAuth;
	
	public SCM_MF_InsPAContactFax(String caseId) {
		super(caseId);
		key = 'RECFAX_PA';
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = true;
        this.displayLabel = true;
        this.label = 'Fax Number:';
        this.fieldType = FieldTypes.phoneNumberField;
        try {
        if(BIListFil.size() == 0){
        	fieldValue = '';
        }
        else if(BIListFil.size() == 1){
        	fieldValue = PA.Fax_gne__c;
        }
        else if(BIListFil.size() > 1){
        	fieldValue = PA.Fax_gne__c;
        }
        
        if (fieldValue == null)
        	fieldValue = '';
        }catch(Exception ex){
        	fieldvalue = '';	
        }
	}
	
	public override String getFieldValue() {		
		return fieldValue;
	}
}