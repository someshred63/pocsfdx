public class SCM_MF_Product_URL_CR extends SCM_MergeField  {

	public SCM_MF_Product_URL_CR(SObject obj) 
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

	public SCM_MF_Product_URL_CR(String productName) 
	{
		super();
		setCommons(productName);		
	}

	private void setCommons(String productName)
	{
		key = 'CR_URL';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		className = 'SCM_MF_Product_URL_CR';
		fieldValue='www.GenentechAccessSolutions.com';
		if(productName==null || productName=='')
			return; 
			
        if(productName.contains('Activase') || 
           productName.contains('TNKase'))
            fieldValue = 'www.GenentechAccessSolutions.com';
        else if(productName.contains('Avastin') || 
        		productName.contains('Herceptin') || 
        		productName=='Rituxan' ||
        		productName.contains('Tarceva') )
            fieldValue = 'www.BioOncologyAccessSolutions.com';
        else if(productName.contains('Lucentis'))
            fieldValue = 'www.LUCENTISAccessSolutions.com';
        else if(productName.contains('Nutropin'))
            fieldValue = 'www.NutropinAccessSolutions.com';
        else if(productName.contains('Pulmozyme'))
            fieldValue = 'www.PulmozymeAccessSolutions.com';
        else if(productName.contains('Raptiva'))
            fieldValue = 'www.RAPTIVAAccessSolutions.com';
        else if(productName.contains('Rituxan RA'))
            fieldValue = 'www.RheumatologyAccessSolutions.com';
        else if(productName.contains('Xolair'))
            fieldValue = 'www.XOLAIRAccessSolutions.com';
        else if(productName.contains('Actemra'))
            fieldValue = 'www.RheumatologyAccessSolutions.com';
        else if(productName.contains('Xeloda'))
            fieldValue = 'www.BioOncologyAccessSolutions.com';
        else if(productName.contains('Pegasys'))
            fieldValue = 'www.PegasysAccessSolutions.com';
        else if(productName.contains('Zelboraf'))
            fieldValue = 'www.BioOncologyAccessSolutions.com';
        else if(productName.contains('Erivedge'))
            fieldValue = 'www.BioOncologyAccessSolutions.com';
	} 
}