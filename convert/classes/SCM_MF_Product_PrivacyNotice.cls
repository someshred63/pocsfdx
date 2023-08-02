public class SCM_MF_Product_PrivacyNotice extends SCM_MergeField{

    public SCM_MF_Product_PrivacyNotice(SObject obj) 
	{
		
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
		
		setCommons( productName);
	}
	
	public SCM_MF_Product_PrivacyNotice(String productName) 
	{
		setCommons( productName);
	}
	
	private void setCommons(String productName)
	{
		key = 'PrivacyNotice';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		className = 'SCM_MF_Product_PrivacyNotice';
		fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with'+
						 ' Genentech Access Solutions/Genentech Access to'+
						 ' Care Foundation. Further, please provide this'+
						 ' Case ID No. and NOT your patient\'s name when you'+
						 ' request information regarding your patient\'s '+
						 'reimbursement status from Genentech, e.g., '+
						 'your clinical specialist or Genentech Access Solutions/Genentech Access'+
						 ' to Care Foundation.';
		if(productName==null || productName=='')
			return;
		// To-do 
		if(productName.contains('Activase'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with'+
						 ' Genentech Access Solutions/Genentech Access to'+
						 ' Care Foundation. Further, please provide this'+
						 ' Case ID No. and NOT your patient\'s name when you'+
						 ' request information regarding your patient\'s '+
						 'reimbursement status from Genentech, e.g., '+
						 'your clinical specialist or Genentech Access Solutions/Genentech Access'+
						 ' to Care Foundation.';
		else if(productName.contains('Avastin'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Genentech BioOncology Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Genentech BioOncology Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Herceptin'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Herceptin Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Herceptin Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Lucentis'))
			fieldValue ='To help us protect your patient\'s privacy, please refer to this ' + 
			'Case ID No. in all communications with LUCENTIS Access Solutions/Genentech Access ' + 
			'to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s ' + 
			'name when you request information regarding your patient\'s reimbursement status from ' + 
			'Genentech, e.g., your clinical specialist or LUCENTIS Access Solutions/Genentech ' + 
			'Access to Care Foundation.';
		else if(productName.contains('Nutropin'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to'+
			' this Case ID No. in all communications with Nutropin Access '+
			'Solutions/Genentech Access to Care Foundation. Further, please '+
			'provide this Case ID No. and NOT your patient\'s name when you '+
			'request information regarding your patient\'s reimbursement '+
			'status from Genentech, e.g., your clinical specialist or '+
			'Nutropin Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Pulmozyme'))
			fieldValue = 'To help us protect your patient\'s privacy, please '
			+'refer to this Case ID No. in all communications with '+
			'Pulmozyme Access Solutions/Genentech Access to Care Foundation. '+
			'Further, please provide this Case ID No. and NOT your patient\'s name'+
			' when you request information regarding your patient\'s reimbursement'+
			' status from Genentech, e.g., your clinical specialist or Pulmozyme'+
			' Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Raptiva'))
			fieldValue = 'To help us protect your patient\'s privacy, please '+
			'refer to this Case ID No. in all communications with RAPTIVA Access'+
			' Solutions/Genentech Access to Care Foundation. Further, please'+
			' provide this Case ID No. and NOT your patient\'s name when you'+
			' request information regarding your patient\'s reimbursement '+
			'status from Genentech, e.g., your clinical specialist or RAPTIVA'+
			' Access Solutions/Genentech Access to Care Foundation.';
		else if(productName=='Rituxan') 
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Genentech BioOncology Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Genentech BioOncology Access Solutions/Genentech Access to Care Foundation.';
		else if(productName=='Rituxan RA')
			fieldValue = 'To help us protect your patient\'s privacy, please'+
			' refer to this Case ID No. in all communications with Genentech'+
			' Access Solutions/Genentech Access to Care Foundation. Further,'+
			' please provide this Case ID No. and NOT your patient\'s name when'+
			' you request information regarding your patient\'s reimbursement'+
			' status from Genentech, e.g., your clinical specialist or'+
			' Genentech Access Solutions/Genentech Access to Care Foundation.';
		else if(productName=='Tarceva')
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Tarceva Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Tarceva Access Solutions/Genentech Access to Care Foundation.';
		else if(productName=='TNKase')  
			fieldValue = 'To help us protect your patient\'s privacy, please refer'+
			' to this Case ID No. in all communications with Genentech Access'+
			' Solutions/Genentech Access to Care Foundation. Further, please'+
			' provide this Case ID No. and NOT your patient\'s name when you'+
			' request information regarding your patient\'s reimbursement status'+
			' from Genentech, e.g., your clinical specialist or Genentech Access'+
			' Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Xolair'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with XOLAIR Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., XOLAIR Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Actemra'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Genentech Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., your clinical specialist or Genentech Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Xeloda'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Genentech BioOncology Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Genentech BioOncology Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Pegasys'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Pegasys Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., your clinical specialist or Pegasys Access Solutions/Genentech Access to Care Foundation.';
		else if(productName.contains('Zelboraf'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Genentech BioOncology Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Genentech BioOncology Access Solutions/Genentech Access to Care Foundation.';
	    else if(productName.contains('Erivedge'))
			fieldValue = 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Genentech BioOncology Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., Genentech BioOncology Access Solutions/Genentech Access to Care Foundation.';
	}
}