public class SCM_MF_Product_Phone_CR_Short  extends SCM_MF_Product_Phone_CR {
    /********************************************************************/
    // Function Name    : SCM_MF_Product_Phone_CR_Short
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //                    a case with product name stored in Product_gne__c field (type picklist)
    //                    Currently available values for that picklist are 
    //                    Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //                    Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //                    TNKase | Xolair
    /********************************************************************/ 

    public SCM_MF_Product_Phone_CR_Short(SObject obj) 
    { 
        super(obj);
        key = 'CR_PhoneShort';
        className = 'SCM_MF_Product_Phone_CR_Short';
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
        setPhoneNumberShort(productName);
    }

    public SCM_MF_Product_Phone_CR_Short(String productName) 
    {
        super(productName);
        key = 'CR_PhoneShort';
        className = 'SCM_MF_Product_Phone_CR_Short';
        setPhoneNumberShort(productName);
    }
    
    private void setPhoneNumberShort(String productName)
    {
        if(productName==null || productName=='')
        {
            fieldValue= '';
            return;
        }
        if(productName.contains('Nutropin'))
            fieldValue= '(866) 688-7674';
        else if(productName.contains('Raptiva'))
            fieldValue= '(866) 480-7762';
        else if(productName.contains('Zelboraf'))
            fieldValue= '(888) 249-4918';
        else if(productName.contains('Erivedge'))
            fieldValue= '(888) 249-4918';
    }
}