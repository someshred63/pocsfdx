public with sharing class SCM_MF_AdditionalSupport_BenefitLevel extends SCM_Mergefield {
	public SCM_MF_AdditionalSupport_BenefitLevel(String CaseID) {
		key = 'AS_BenefitLevel';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		
		try {
			Alternative_Funding_gne__c af = [Select Benefit_Type_gne__c from Alternative_Funding_gne__c where Case_gne__c = :CaseID and Card_ID_gne__c != NULL order by LastModifiedDate desc limit 1];
			fieldValue = af.Benefit_Type_gne__c;
		}
		catch(Exception ex){
			fieldvalue = '';	
		}
	}
}