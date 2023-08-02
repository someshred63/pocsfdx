public class SCM_MF_Product_Fax_CR extends SCM_MergeField
{
	/********************************************************************/
    // Function Name    : SCM_MF_Product_Fax_CR
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be
    //					  a case with product name stored in Product_gne__c field (type picklist)
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
	
	
	public SCM_MF_Product_Fax_CR(SObject obj) 
	{
		super();	
		String productName='';
		if(obj instanceof Hotline_gne__c)
    	{
    		Hotline_gne__c hotline=(Hotline_gne__c)obj;
    		productName=hotline.Product_gne__c;
    	}
    	else if(obj instanceof Case)
    	{
    		Case selectedCase=(Case)obj;
    		productName =selectedCase.Product_gne__c;
    	}
    	
		setCommons(productName);
	}
	
	public SCM_MF_Product_Fax_CR(String productName) 
	{
		super();
		setCommons(productName);
	}
	
	private void setCommons(String productName)
	{
    	key = 'CR_Fax';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		className = 'SCM_MF_Product_Fax_CR';
		fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
    	fieldValue='';
		if(productName==null || productName=='')
			return; 
		
		if(productName.contains('Activase'))
			fieldValue = '(650) 225-1366';
		else if(productName.contains('Avastin'))
			fieldValue = '(888) 249-4919';
		else if(productName.contains('Herceptin'))
			fieldValue = '(888) 249-4919';
		else if(productName.contains('Lucentis'))
			fieldValue = '(866) 724-9412';
		else if(productName.contains('Nutropin'))
			fieldValue = '(800) 545-0612';				
		else if(productName.contains('Pulmozyme'))
			fieldValue = '(800) 963-1792';
		else if(productName.contains('Raptiva'))
			fieldValue = '(866) 481-7762';
		else if(productName=='Rituxan')  
			fieldValue = '(888) 249-4919';
		else if(productName=='Rituxan RA')  
			fieldValue = '(866) 681-3288';
		else if(productName.contains('Tarceva'))
			fieldValue = '(888) 249-4919';
		else if(productName.contains('TNKase')) 
			fieldValue = '(650) 225-1366';
		else if(productName.contains('Xolair'))
			fieldValue = '(800) 704-6612';
		else if(productName.contains('Actemra'))
			fieldValue = '(866) 681-3288';
		else if(productName.contains('Xeloda'))
			fieldValue = '(888) 249-4919';
		else if(productName.contains('Pegasys'))
			fieldValue = '(888) 929-3334';
		else if(productName.contains('Zelboraf'))
			fieldValue = '(877) 313-2659';
		else if(productName.contains('Erivedge'))
			fieldValue = '(877) 313-2659';
	}
}