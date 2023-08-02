public class SCM_MF_CopayCardID extends SCM_Mergefield
{
	public SCM_MF_CopayCardID(String CaseID) {
		key = 'CopayCardID';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		
	try {
		
		Alternative_Funding_gne__c AF = [Select Card_ID_gne__c from Alternative_Funding_gne__c where Case_gne__c = :CaseID and Card_ID_gne__c != NULL order by LastModifiedDate desc limit 1];
		fieldValue = af.Card_ID_gne__c;
	}
	catch(Exception ex){
	fieldvalue = '';	
		
	}
	
	}
		
}