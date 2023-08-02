//Generic class for C&R URL
public class SCM_MF_CR_URL extends SCM_MergeField {
	public SCM_MF_CR_URL(Case selectedCase) {
		String product = selectedCase.Product_gne__c;
		key = 'CR_URL';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
				
		if (product == null || product.equals('')) 
			fieldValue = '';
		else if (product.equals('Activase'))
			fieldValue = 'www.GenentechAccessSolutions.com';
		else if (product.equals('Lucentis'))
			fieldValue = 'www.LUCENTISAccessSolutions.com';
		else if (product.equals('Nutropin'))
			fieldValue = 'www.NutropinAccessSolutions.com';
		else if (product.equals('Pulmozyme'))	
			fieldValue = 'www.PulmozymeAccessSolutions.com';
		else if (product.equals('Rituxan RA'))	
			fieldValue = 'www.RITUXANAccessSolutions.com';
		else if (product.equals('Raptiva'))	
			fieldValue = 'www.RAPTIVAAccessSolutions.com';
		else if (product.equals('TNKase'))	
			fieldValue = 'www.GenentechAccessSolutions.com';
		else if (product.equals('Xolair'))	
			fieldValue = 'www.XOLAIRAccessSolutions.com';
		else if (product.equals('Avastin'))	
			fieldValue = 'www.BioOncologyAccessSolutions.com';
		else if (product.equals('Rituxan'))	
			fieldValue = 'www.BioOncologyAccessSolutions.com';
		else if (product.equals('Tarceva'))
			fieldValue = 'www.BioOncologyAccessSolutions.com';
		else if (product.equals('Herceptin'))	
			fieldValue = 'www.BioOncologyAccessSolutions.com';
		else
			fieldValue = 'www.GenentechAccessSolutions.com';			
	}
}