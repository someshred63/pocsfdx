public class SCM_MF_Product_DrugType  extends SCM_MergeField {
	/********************************************************************/
    // Function Name    : SCM_MF_Product_DrugType
    // Argument         : String productName
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //					  a product name stored in Product_gne__c field (type piclist) of Case object
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
	public SCM_MF_Product_DrugType(Case documentCase) 
	{ 
		super();
		key = 'DrugType';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		String productName=documentCase.Product_gne__c;
		className = 'SCM_MF_Product_DrugType';
		try 
		{
			if(productName=='Activase') 
				fieldValue = 'Cardiology';
			else if(productName=='Avastin')
				fieldValue = 'Oncology'; 
			else if(productName=='Herceptin')
				fieldValue = 'Oncology'; 
			else if(productName=='Lucentis')
				fieldValue = 'Ophthalmology';
			else if(productName=='Nutropin')  
				fieldValue = 'Endocrinology';
			else if(productName=='Pulmozyme')
				fieldValue = 'Pulmonary';
			else if(productName=='Raptiva')
				fieldValue = 'Dermatology';
			else if(productName=='Rituxan')  
				fieldValue = 'Oncology';
			else if(productName=='Rituxan RA')  
				fieldValue = 'Rheumatology';
			else if(productName=='Tarceva')
				fieldValue = 'Oncology';
			else if(productName=='TNKase')  
				fieldValue = 'Cardiology';
			else if(productName=='Xolair')
				fieldValue = 'Respiratory';
			else if(productName=='Actemra')
				fieldValue = 'Rheumatology';
			else if(productName=='Xeloda')
				fieldValue = 'Oncology';
			else if(productName.contains('Pegasys'))
				fieldValue = 'Virology';
			else if(productName.contains('Zelboraf'))
				fieldValue = 'Oncology';
			else if(productName.contains('Erivedge'))
				fieldValue = 'Oncology';
		} 
		catch (Exception ex) 
		{
			fieldValue = '';
		}
	}
}