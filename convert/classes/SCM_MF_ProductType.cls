// Created by : Jatin 
// Document Name : NUT- PUL CMGT-FAX-46 Family Intro Letter final.doc

// logic : If Product = Nutropin then use “Growth Hormone” Else use “Pulmozyme”


public class SCM_MF_ProductType extends SCM_MergeField {

	public SCM_MF_ProductType(Case documentCase) 
	{
		super();
		key = 'ProductType';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		String productName=documentCase.Product_gne__c;
		className = 'SCM_MF_ProductType';

		if(productName=='Nutropin') 
			fieldValue = 'Growth Hormone';
		else
			fieldValue = 'Pulmozyme';
		
		
	}
}