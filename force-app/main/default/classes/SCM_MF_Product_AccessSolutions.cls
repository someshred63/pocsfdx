public class SCM_MF_Product_AccessSolutions  extends SCM_MergeField {
    /********************************************************************/
    // Function Name    : SCM_MF_Product_AccessSolutions
    // Argument         : String productName
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //                    a product name stored in Product_gne__c field (type piclist) of Case object
    //                    Currently available values for that picklist are 
    //                    Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //                    Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //                    TNKase | Xolair
    /********************************************************************/ 
    public SCM_MF_Product_AccessSolutions(String productName) 
    {
        super();
        key = 'AccessSolutions';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        
        className = 'SCM_MF_Product_AccessSolutions';
        
        if(productName==null || productName=='')
            fieldValue = 'Genentech';
        else if(productName.contains('Activase')) 
            fieldValue = 'Genentech';
        else if(productName.contains('Avastin'))
            fieldValue = 'Genentech BioOncology'; 
        else if(productName.contains('Herceptin'))
            fieldValue = 'Genentech BioOncology'; 
        else if(productName.contains('Lucentis'))
            fieldValue = 'LUCENTIS';
        else if(productName.contains('Nutropin'))  
            fieldValue = 'Nutropin';
        else if(productName.contains('Pulmozyme'))
            fieldValue = 'Pulmozyme';
        else if(productName.contains('Raptiva'))
            fieldValue = 'RAPTIVA';
        else if(productName=='Rituxan')  
            fieldValue = 'Genentech BioOncology';
        else if(productName=='Rituxan RA')  
            fieldValue = 'Rheumatology';
        else if(productName.contains('Tarceva'))
            fieldValue = 'Genentech BioOncology';
        else if(productName.contains('TNKase'))  
            fieldValue = 'Genentech';
        else if(productName.contains('Xolair'))
            fieldValue = 'XOLAIR';
        else if(productName.contains('Actemra'))
            fieldValue = 'Genentech Rheumatology';
        else if(productName.contains('Xeloda'))
            fieldValue = 'BioOncology';
        else if(productName.contains('Pegasys'))
            fieldValue = 'Pegasys';
        else if(productName.contains('Zelboraf'))
            fieldValue = 'Zelboraf';
        else if(productName.contains('Erivedge'))
            fieldValue = 'Erivedge';
        else {
        	fieldValue ='';	
        }
    }
}