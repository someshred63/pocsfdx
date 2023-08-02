public class SCM_MF_MailStop extends SCM_MergeField {

	public SCM_MF_MailStop(Case documentCase) 
	{
		key = 'MailStop';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		className = 'SCM_MF_MailStop';
		String productName = documentCase.Product_gne__c;
		String caseTypeName = documentCase.RecordType.Name;
		fieldValue = '';
		
		try{
			string VariableName = 'SCM_MailStop_' + productName;
			if (caseTypeName.contains('GATCF')){
				VariableName = 'SCM_MailStop_GATCF';		
			}
		
		
			this.fieldValue = SCM_Security.getEnvironmentVariable(VariableName);
		
			}
		catch (Exception e){
			this.fieldValue = '';
		}	
	}
}