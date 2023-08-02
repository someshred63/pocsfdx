public class SCM_MF_Product_Fax extends SCM_MergeField{
	/********************************************************************/
    // Function Name    : SCM_MF_Product_Fax
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be
    //					  a case with product name stored in Product_gne__c field (type picklist)
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
	public SCM_MF_Product_Fax(Case documentCase) 
	{
		super();
		key = 'Fax';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		String productName =documentCase.Product_gne__c;
		String caseTypeName = documentCase.RecordType.Name;
		fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
		className = 'SCM_MF_Product_Fax';
		
		if(productName=='Activase')
		{
			if(caseTypeName.startsWith('GATCF'))
				fieldValue = '(650) 225-1366';
			else
				fieldValue = '(650) 225-1366';
		}
		else if(productName=='Avastin')
		{
			if(caseTypeName.startsWith('GATCF'))
				fieldValue = '(877) 428-2326'; 
			else
				fieldValue = '(888) 249-4919';
		}
		else if(productName=='Herceptin')
		{
			if(caseTypeName.startsWith('GATCF'))
				fieldValue = '(877) 428-2326'; 
			else
				fieldValue = '(888) 249-4919';
		}
		else if(productName=='Lucentis')
		{
			if(caseTypeName.startsWith('GATCF'))
				fieldValue = '(888) 727-7773';
			else
				fieldValue = '(866) 724-9412';
		}
		else if(productName=='Nutropin')
		{
			if(caseTypeName.startsWith('GATCF'))
				fieldValue = '(800) 545-0612';
			else
				fieldValue = '(800) 545-0612';				
		}
		else if(productName=='Pulmozyme')
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(800) 963-1792';
			else
				fieldValue = '(800) 963-1792';
		}
		else if(productName=='Raptiva')
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(800) 240-5487';
			else
				fieldValue = '(866) 481-7762';
		}
		else if(productName=='Rituxan')  
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(877) 428-2326';
			else
				fieldValue = '(888) 249-4919';
		}
		else if(productName=='Rituxan RA')  
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(866) 681-3338';
			else
				fieldValue = '(866) 681-3288';
		}
		else if(productName=='Tarceva')
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(877) 428-2326';
			else
				fieldValue = '(888) 249-4919';
		}
		else if(productName=='TNKase') 
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(650) 225-1366';
			else
				fieldValue = '(650) 225-1366';
		}
		else if(productName=='Xolair')
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(800) 704-6615';
			else
				fieldValue = '(800) 704-6612';
		}
		else if(productName=='Actemra')
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(866) 681-3338';
			else
				fieldValue = '(866) 681-3288';
		}
		else if(productName=='Xeloda')
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(877) 428-2326';
			else
				fieldValue = '(888) 249-4919';
		}
		else if(productName.contains('Pegasys'))
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(888) 929-3334';
			else
				fieldValue = '(888) 929-3334';
		}
		else if(productName.contains('Zelboraf'))
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(877) 313-2659';
			else
				fieldValue = '(877) 313-2659';
		}
		else if(productName.contains('Erivedge'))
		{
			if(caseTypeName.startsWith('GATCF'))		
				fieldValue = '(877) 313-2659';
			else
				fieldValue = '(877) 313-2659';
		}
	}
}