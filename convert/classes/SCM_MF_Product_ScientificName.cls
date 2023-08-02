public class SCM_MF_Product_ScientificName  extends SCM_MergeField {
	/********************************************************************/
    // Function Name    : SCM_MF_Product_ScientificName
    // Argument         : String productName
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //					  a product name stored in Product_gne__c field (type piclist) of Case object
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
	public SCM_MF_Product_ScientificName(Case documentCase) 
	{
		super();
		key = 'ProdScientific';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		String productName=documentCase.Product_gne__c;
		className = 'SCM_MF_Product_ScientificName';
		
		if(productName=='Activase') 
		//(Alteplase, recombinant)
			fieldValue = '(Alteplase)';
		else if(productName=='Avastin')
			fieldValue = '(bevacizumab)'; 
		else if(productName=='Herceptin')
			fieldValue = '(Trastuzumab)'; 
		else if(productName=='Lucentis')
			fieldValue = '(ranibizumab injection)';
		else if(productName=='Nutropin')  
			fieldValue = '[somatropin (rDNA origin) for injection]';
		else if(productName=='Pulmozyme')
			fieldValue = '(dornase alfa)';
		else if(productName=='Raptiva')
			fieldValue = '(efalizumab)';
		else if(productName=='Rituxan')  
			fieldValue = '(Rituximab)';
		else if(productName=='Rituxan RA')  
			fieldValue = '(Rituximab)';
		else if(productName=='Tarceva')
			fieldValue = '(erlotinib)';
		else if(productName=='TNKase')  
			fieldValue = '(Tenecteplase)';
		else if(productName=='Xolair')
			fieldValue = '(Omalizumab)';
		else if(productName=='Actemra')
			fieldValue = '(tocilizumab)';
		else if(productName=='Xeloda')
			fieldValue = '(capecitabine)';
		else if(productName.Contains('Pegasys'))
			fieldValue = '(Peginterferon alfa-2a)';
		else if(productName=='Zelboraf')
			fieldValue = '(vemurafenib)';
		else if(productName=='Erivedge')
			fieldValue = '(Vismodegib)';
	}

}