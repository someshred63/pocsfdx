//Generic class for C&R Fax
public class SCM_MF_CR_Fax extends SCM_MergeField {
	public SCM_MF_CR_Fax(Case selectedCase) {
		String product = selectedCase.Product_gne__c;
		key = 'CR_Fax';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
				
		if (product == null || product.equals('')) 
			fieldValue = '';
		else if (product.equals('Activase'))
			fieldValue = '(650) 225-1366';
		else if (product.equals('Lucentis'))
			fieldValue = '(866) 724-9412';
		else if (product.equals('Nutropin'))
			fieldValue = '(800) 545-0612';
		else if (product.equals('Pulmozyme'))	
			fieldValue = '(800) 963-1792';
		else if (product.equals('Rituxan RA'))	
			fieldValue = '(866) 681-3288';
		else if (product.equals('Raptiva'))	
			fieldValue = '(866) 481-7762';
		else if (product.equals('TNKase'))	
			fieldValue = '(650) 225-1366';
		else if (product.equals('Xolair'))	
			fieldValue = '(800) 704-6612';
		else if (product.equals('Avastin'))	
			fieldValue = '(888) 249-4919';
		else if (product.equals('Rituxan'))	
			fieldValue = '(888) 249-4919';
		else if (product.equals('Tarceva'))
			fieldValue = '(888) 249-4919';
		else if (product.equals('Herceptin'))	
			fieldValue = '(888) 249-4919';
		else
			fieldValue = '';			
	}

	public override String getFieldValue() {
		return fieldValue;
	}
}