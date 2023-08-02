//Generic class for C&R Phone
public class SCM_MF_CR_Phone extends SCM_MergeField {
	public SCM_MF_CR_Phone(Case selectedCase) {
		String product = selectedCase.Product_gne__c;
		String recordType = selectedCase.RecordType.Name;
		
		key = 'CR_Phone';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
        
		if (product == null || product.equals('')) 
			fieldValue = '';
		else if (product.equals('Activase'))
			fieldValue = '(800) 530-3083';
		else if (product.equals('Lucentis'))
			fieldValue = '(866) 724-9394';
		else if (product.equals('Nutropin'))
			fieldValue = '(866) Nutropin / (866) 688-7674';
		else if (product.equals('Pulmozyme'))	
			fieldValue = '(800) 690-3023';
		else if (product.equals('Rituxan RA'))	
			fieldValue = '(866) 681-3261';
		else if (product.equals('Raptiva'))	
			fieldValue = '(877) RAPTIVA / (877) 727-8482';
		else if (product.equals('TNKase'))	
			fieldValue = '(800) 530-3083';
		else if (product.equals('Xolair'))	
			fieldValue = '(800) 704-6610';
		else if (product.equals('Avastin'))	
			fieldValue = '(888) 249-4918';
		else if (product.equals('Rituxan'))	
			fieldValue = '(888) 249-4918';
		else if (product.equals('Tarceva'))
			fieldValue = '(888) 249-4918';
		else if (product.equals('Herceptin'))	
			fieldValue = '(888) 249-4918';
		else
			fieldValue = '';
	}

	public override String getFieldValue() {
		return fieldValue;
	}
}