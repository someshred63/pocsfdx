// Created by : Jatin 
// Document Name : NUT- PUL CMGT-FAX-46 Family Intro Letter final.doc
// LOgic : If Product = Nutropin then use “products, Nutropin® AQ and Nutropin®” Else use “”


public class SCM_MF_ProductNames_Nutropin extends SCM_MergeField {
	
	public SCM_MF_ProductNames_Nutropin(Case documentCase) 
	{
		super();
		key = 'ProductNames_Nut';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		String productName=documentCase.Product_gne__c;
		className = 'SCM_MF_ProductNames_Nutropin';

		if(productName=='Nutropin') 
			fieldValue = 'products, Nutropin® AQ and Nutropin® ';
		else
			fieldValue = '';			
	}
	
	public SCM_MF_ProductNames_Nutropin(Case documentCase, boolean nutPulProducts) 
    {
        super();
        key = 'ProductNames_Nut';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        String productName=documentCase.Product_gne__c;
        className = 'SCM_MF_ProductNames_Nutropin';

        if(productName == 'Nutropin') 
            fieldValue = 'NutropinAQ® y Nutropin®';
        else if(productName == 'Pulmozyme')
            fieldValue = 'Pulmozyme';            
    }
	
}