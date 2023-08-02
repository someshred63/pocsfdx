public virtual class SCM_MF_Product_Phone_CR  extends SCM_MergeField{
    /********************************************************************/
    // Function Name    : SCM_MF_Product_Phone_CR
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //                    a case with product name stored in Product_gne__c field (type picklist)
    //                    Currently available values for that picklist are 
    //                    Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //                    Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //                    TNKase | Xolair
    /********************************************************************/ 
 
    public SCM_MF_Product_Phone_CR(SObject obj) 
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

        setCommonConfiguration();
        setPhoneNumber(productName);
    }

    public SCM_MF_Product_Phone_CR(String productName)
    {
        super();
        setCommonConfiguration();
        setPhoneNumber(productName);
    }

    private void setPhoneNumber(String productName)
    {
        fieldValue='';
        if(productName==null || productName=='')
            return;
            
        if(productName.contains('Activase'))
            fieldValue = '(800) 530-3083';
        else if(productName.contains('Avastin'))
            fieldValue = '(888) 249-4918';
        else if(productName.contains('Herceptin'))
            fieldValue = '(888) 249-4918';
        else if(productName.contains('Lucentis'))
            fieldValue = '(866) 724-9394';
        else if(productName.contains('Nutropin'))
            fieldValue = '(866) NUTROPIN / (866) 688-7674'; 
        else if(productName.contains('Pulmozyme'))
            fieldValue = '(800) 690-3023';
        else if(productName.contains('Raptiva'))
            fieldValue = '(877) RAPTIVA / (877) 727-8482';
        else if(productName=='Rituxan')  
            fieldValue = '(888) 249-4918';
        else if(productName=='Rituxan RA')  
            fieldValue = '(866) 681-3261';
        else if(productName.contains('Tarceva'))
            fieldValue = '(888) 249-4918';
        else if(productName.contains('TNKase')) 
            fieldValue = '(800) 530-3083';
        else if(productName.contains('Xolair'))
            fieldValue = '(800) 704-6610';
        else if(productName.contains('Actemra'))
            fieldValue = '(866) 681-3261';
        else if(productName.contains('Xeloda'))
            fieldValue = '(888) 249-4918';
        else if(productName.contains('Pegasys'))
            fieldValue = '(888) 941-3331';
        else if(productName.contains('Zelboraf'))
        	fieldValue = '(888) 249-4918';
        else if(productName.contains('Erivedge'))
        	fieldValue = '(888) 249-4918';
    }
    
    private void setCommonConfiguration()
    {
        key = 'CR_Phone';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;

        fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        className = 'SCM_MF_Product_Phone_CR';
    }
}