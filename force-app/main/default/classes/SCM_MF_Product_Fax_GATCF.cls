public class SCM_MF_Product_Fax_GATCF extends SCM_MergeField
{
	/********************************************************************/
    // Function Name    : SCM_MF_Product_Fax_GATCF
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be
    //					  a case with product name stored in Product_gne__c field (type picklist)
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
	public SCM_MF_Product_Fax_GATCF(Case documentCase) 
	{
		super();
		String productName =documentCase.Product_gne__c;
		setCommons(productName);
	}
	
	public SCM_MF_Product_Fax_GATCF(String productName) 
	{
		super();
		setCommons(productName);
	}
	
	private void setCommons(String productName)
	{
		key = 'GATCF_Fax';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
		className = 'SCM_MF_Product_Fax_GATCF';
		
		if(productName=='Activase')
			fieldValue = '(650) 225-1366';
		else if(productName=='Avastin')
			fieldValue = '(877) 428-2326'; 
		else if(productName=='Herceptin')
			fieldValue = '(877) 428-2326'; 
		else if(productName=='Lucentis')
			fieldValue = '(888) 727-7773';
		else if(productName=='Nutropin')
			fieldValue = '(800) 545-0612';
		else if(productName=='Pulmozyme')		
			fieldValue = '(800) 963-1792';
		else if(productName=='Raptiva')	
			fieldValue = '(800) 240-5487';
		else if(productName=='Rituxan')  		
			fieldValue = '(877) 428-2326';
		else if(productName=='Rituxan RA')  		
			fieldValue = '(866) 681-3338';
		else if(productName=='Tarceva')	
			fieldValue = '(877) 428-2326';
		else if(productName=='TNKase') 	
			fieldValue = '(650) 225-1366';
		else if(productName=='Xolair')		
			fieldValue = '(800) 704-6615';
		else if(productName=='Actemra')		
			fieldValue = '(866) 681-3338';
		else if(productName=='Xeloda')		
			fieldValue = '(877) 428-2326';
		else if(productName.contains('Pegasys'))
			fieldValue = '(888) 929-3334';
		else if(productName=='Zelboraf')	
			fieldValue = '(877) 313-2659';
		else if(productName=='Erivedge')	
			fieldValue = '(877) 313-2659';
		else {
			fieldValue = '';
		}
	}
}