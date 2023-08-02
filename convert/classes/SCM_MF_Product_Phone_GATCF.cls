public class SCM_MF_Product_Phone_GATCF  extends SCM_MergeField {
	/********************************************************************/
    // Function Name    : SCM_MF_Product_Phone_GATCF
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //					  a case with product name stored in Product_gne__c field (type picklist)
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 

	public SCM_MF_Product_Phone_GATCF(Case documentCase) {
		super();
		setCommonConfiguration();
		String productName = documentCase.Product_gne__c;
		setPhoneNumber(productName);
	}
	
	public SCM_MF_Product_Phone_GATCF(String productName) 
	{
		super();
		setCommonConfiguration();
		setPhoneNumber(productName);
	}

	private void setCommonConfiguration()
	{
		key = 'GATCF_Phone';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
		className = 'SCM_MF_Product_Phone_GATCF';
	}
	
	private void setPhoneNumber(String productName)
	{
		if(productName=='Activase')
			fieldValue = '(800) 530-3083';
		else if(productName=='Avastin')
			fieldValue = '(800) 530-3083'; 
		else if(productName=='Herceptin')
			fieldValue = '(800) 530-3083'; 
		else if(productName=='Lucentis')
			fieldValue = '(800) 232-0592';
		else if(productName=='Nutropin')
			fieldValue = '(800) 879-4747';
		else if(productName=='Pulmozyme')		
			fieldValue = '(800) 690-3023';
		else if(productName=='Raptiva')	
			fieldValue = '(800) 280-8938';
		else if(productName=='Rituxan')  		
			fieldValue = '(800) 530-3083';
		else if(productName=='Rituxan RA')  	
			fieldValue = '(866) 681-3329';
		else if(productName=='Tarceva')		
			fieldValue = '(800) 530-3083';
		else if(productName=='TNKase') 		
			fieldValue = '(800) 530-3083';
		else if(productName=='Xolair')		
			fieldValue = '(800) 704-6614';
		else if(productName=='Actemra')		
			fieldValue = '(866) 681-3329';
		else if(productName=='Xeloda')		
			fieldValue = '(800) 530-3083';
		else if(productName.contains('Pegasys'))
			fieldValue = '(888) 941-3331';
		else if(productName=='Zelboraf')
			fieldValue = '(800) 530-3083';
		else if(productName=='Erivedge')
			fieldValue = '(800) 530-3083';
		else {
			fieldValue = '';
		}
	}
}