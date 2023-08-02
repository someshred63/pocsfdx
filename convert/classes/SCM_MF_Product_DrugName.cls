public class SCM_MF_Product_DrugName  extends SCM_MergeField{
	/********************************************************************/
    // Function Name    : SCM_MF_Product_DrugName
    // Argument         : String productName
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //					  a product name stored in Product_gne__c field (type piclist) of Case object
    //					  Currently available values for that picklist are 
    //					  Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //					  Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //					  TNKase | Xolair
    /********************************************************************/ 
/*	If Case.Product <> Nutropin OR Rituxan RA, then merge Case.Product
Else
If Case.Product = Nutropin, then
Join Case to Medical History and if Medical History.Drug = 
Nutropin 1x10 mg, then merge "Nutropin"
Nutropin 1x5 mg, then merge "Nutropin"
Nutropin AQ 1x10 mg, then merge "Nutropin AQ"
Nutropin AQ Cartridge 1x10 mg, then merge "NAQ Cartridge"
Nutropin AQ Cartridge 1x20 mg, then merge "NAQ Cartridge"
Nutropin Depot, then merge "Nutropin Depot"

If Case.Product = Rituxan RA, then merge "Rituxan"
*/
	
	public SCM_MF_Product_DrugName(SObject obj) 
	{
		super();	
		setCommons();
		setValue(obj);
	}
	
	public SCM_MF_Product_DrugName(String productName)
	{
		super();
		setCommons();
		setValue(productName);
	}
	
	private void setCommons()
	{
		key = 'Drug';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		isRequired = false;
		className = 'SCM_MF_Product_DrugName';
	}

	private void setValue (String productName)
	{
		fieldValue='';
		if(productName==null || productName=='')
			return; 
			
		if(!productName.contains('Nutropin') && 
			!productName.contains('Rituxan RA') &&	!productName.contains('Actemra') && !productName.contains('Xeloda') && !productName.contains('Pegasys'))
			fieldValue=productName;
		else
		{
			if(productName.contains('Nutropin'))
				fieldValue='Nutropin';
			else if(productName.contains('Rituxan RA'))
				fieldValue='Rituxan';
			else if(productName.contains('Actemra'))
				fieldValue='ACTEMRA';
			else if(productName.contains('Xeloda'))
				fieldValue='XELODA';
			else if(productName.contains('Pegasys'))
				fieldValue='Pegasys';
		}
	}
	
	private void setValue(SObject obj)
	{
		fieldValue='';
		String productName='';
		
		if(obj instanceof Hotline_gne__c)
    	{
    		Hotline_gne__c hotline=(Hotline_gne__c)obj;
    		productName=hotline.Product_gne__c;
    		setCommons();
    		if(productName!=null)
    		{
    			fieldValue=productName;
	    		if(productName.contains('Xeloda'))
					fieldValue='XELODA';	
    		}
    		else if(productName.contains('Pegasys'))
				fieldValue='Pegasys';
    	}
    	else if(obj instanceof Case)
    	{
    		Case selectedCase=(Case)obj;
    		productName =selectedCase.Product_gne__c;
    		if(productName==null || productName=='')
				return; 
			
			if(!productName.contains('Nutropin') && 
				!productName.contains('Rituxan RA') &&	!productName.contains('Actemra') && !productName.contains('Xeloda') && !productName.contains('Pegasys'))
					fieldValue=productName;
			else
			{
				if(productName.contains('Nutropin'))
				{
					String drugName = selectedCase.Medical_History_gne__r.Drug_gne__c;
					if(drugName==null || 
							drugName=='Nutropin 1x5 mg' ||
							drugName=='Nutropin 1x10 mg')
						fieldValue='Nutropin';
					else if(drugName=='Nutropin AQ Cartridge 1x10 mg'|| 
							drugName=='Nutropin AQ Cartridge 1x20 mg')
						fieldValue='NAQ Cartridge';
					else if(drugName=='Nutropin Depot')
						fieldValue='Nutropin Depot';     																	
					else if(drugName=='Nutropin AQ NuSpin 1x5 mg' || drugName=='Nutropin AQ NuSpin 1x10 mg' || drugName=='Nutropin AQ NuSpin 1x20 mg')
						fieldValue='NAQ NuSpin';
					else
						fieldValue='Nutropin';
				}
				else if(productName.contains('Rituxan RA'))
					fieldValue='Rituxan';
				else if(productName.contains('Actemra'))
				fieldValue='ACTEMRA';
				else if(productName.contains('Xeloda'))
				fieldValue='XELODA';
				else if(productName.contains('Pegasys'))
					{
						String drugName = selectedCase.Medical_History_gne__r.Drug_gne__c;
					if (drugName == null){
						
						fieldValue='Pegasys';	
					}
					else if (drugName == 'Pegasys - Copegus'){
						fieldValue='Pegasys - Copegus';
					}
					else {
				
					fieldValue='Pegasys';
					}		
				}
				else if(productName.contains('Zelboraf'))
				fieldValue='Zelboraf';
				else if(productName.contains('Erivedge'))
				fieldValue='Erivedge';
			}
    	}
	}
}