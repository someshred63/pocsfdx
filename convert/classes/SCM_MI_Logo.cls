public class SCM_MI_Logo extends SCM_MergeImage {

    public SCM_MI_Logo(SObject obj) {
		super();
    	String productName ='';
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
       
    public SCM_MI_Logo(String productName) {
		super();
    	setCommons(productName);
    }
    
    private void setCommons(String productName)
    {
    	key = 'Logo';
    	if(productName==null || productName=='' || 
    	   productName.contains('Activase')  || 
    	   productName.contains('TNKase') 
    	   ) 
    		setvalue('Generic Logo');
    	else if (productName.contains('Lucentis'))
    		setvalue('Lucentis Logo');	
    	else if (productName.contains('Nutropin'))
    		setvalue('Nutropin Logo');
		else if (productName.contains('Pulmozyme'))
    		setvalue('Pulmozyme Logo');
		else if (productName.contains('Raptiva'))
    		setvalue('Raptiva Logo');
    	else if (productName.contains('Xolair'))
    		setvalue('Xolair Logo');
		else if (productName.contains('Avastin'))
    		setvalue('BioOncology Logo');
		else if (productName.contains('Tarceva') || 
				 productName.contains('Herceptin') || 
				 productName =='Rituxan' || 
				 productName.contains('Xeloda')) 
    		setvalue('BioOncology Logo');
		else if (productName  == 'Rituxan RA')
    		setvalue('Actemra Logo');
    	else if (productName  == 'Actemra')
    		setvalue('Actemra Logo');
		else if (productName.contains('Pegasys'))
    		setvalue('Pegasys Logo');
		else if (productName.contains('Zelboraf'))
    		setvalue('BioOncology Logo');
		else if (productName.contains('Erivedge'))
    		setvalue('BioOncology Logo');
		//if (selectedCase.RecordType.Name == 'GATCF - Standard Case') {
		//	setvalue('GATCF Logo');
		//}
    }

}