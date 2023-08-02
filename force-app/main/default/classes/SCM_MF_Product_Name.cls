public class SCM_MF_Product_Name  extends SCM_MergeField {
	/********************************************************************/
    // Function Name    : SCM_MF_Product_Name
    // Argument         : String productName
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //					  a product name stored in Product_gne__c field (type piclist) of Case object
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
	public SCM_MF_Product_Name(SObject obj) 
	{
		super();
		key = 'Product';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
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
    	
		className = 'SCM_MF_Product_Name';
		fieldValue='';
		
		if(productName==null || productName=='')
			return; 

		if(productName.contains('Lucentis'))
            fieldValue ='Lucentis';
        else if(productName.contains('Nutropin'))
            fieldValue = 'Nutropin';
        else if(productName.contains('TNKase'))
            fieldValue = 'TNKase';
        else if(productName.contains('Xolair'))
            fieldValue = 'Xolair';
        else if(productName.contains('Avastin'))
        	fieldValue = 'Avastin';
        else if(productName.contains('Herceptin'))
        	fieldValue = 'Herceptin';
        else if(productName.contains('Raptiva'))
        	fieldValue = 'Raptiva';
        else if(productName.contains('Pulmozyme'))
        	fieldValue = 'Pulmozyme';
        else if(productName=='Rituxan' || productName=='Rituxan RA')
        	fieldValue = 'Rituxan';
        else if(productName.contains('Tarceva'))
         	fieldValue = 'Tarceva';
        else if(productName.contains('TNKase'))
         	fieldValue = 'TNKase';
        else if(productName.contains('Activase'))
         	fieldValue ='Activase';
        else if(productName.contains('Actemra'))
         	fieldValue ='Actemra';
        else if(productName.contains('Xeloda'))
         	fieldValue ='Xeloda';
        else if(productName.contains('Pegasys'))
         	fieldValue ='Pegasys';
        else if(productName.contains('Zelboraf'))
         	fieldValue ='Zelboraf';
        else if(productName.contains('Erivedge'))
         	fieldValue ='Erivedge';
	}
}