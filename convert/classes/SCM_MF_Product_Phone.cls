public class SCM_MF_Product_Phone  extends SCM_MergeField {
    /********************************************************************/
    // Function Name    : SCM_MF_Product_Phone
    // Argument         : Case documentCase
    // Return Type      : (constructor)
    // Description      : This constructor gets an argument which has to be 
    //                    a case with product name stored in Product_gne__c field (type picklist)
    //                    Currently available values for that picklist are 
    //                    Activase | Avastin | Herceptin | Lucentis | Nutropin |
    //                    Pulmozyme | Raptiva | Rituxan | Rituxan RA | Tarcheva | 
    //                    TNKase | Xolair
    /********************************************************************/ 

    public SCM_MF_Product_Phone(Case documentCase) {
        super();
        key = 'Phone';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        String productName = documentCase.Product_gne__c;
        String caseTypeName = documentCase.RecordType.Name;
        fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        className = 'SCM_MF_Product_Phone_GATCF';
        
        if(productName=='Activase')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(800) 530-3083';
        }
        else if(productName=='Avastin')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = '(800) 530-3083'; 
            else
                fieldValue = '(888) 249-4918';
        }
        else if(productName=='Herceptin')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = '(800) 530-3083'; 
            else
                fieldValue = '(888) 249-4918';
        }
        else if(productName=='Lucentis')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = '(800) 232-0592';
            else
                fieldValue = '(866) 724-9394';
        }
        else if(productName=='Nutropin')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = '(800) 879-4747';
            else
                fieldValue = '(866) NUTROPIN / (866) 688-7674';             
        }
        else if(productName=='Pulmozyme')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 690-3023';
            else
                fieldValue = '(800) 690-3023';
        }
        else if(productName=='Raptiva')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 280-8938';
            else
                fieldValue = '(877) RAPTIVA / (877) 727-8482';
        }
        else if(productName=='Rituxan')  
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(888) 249-4918';
        }
        else if(productName=='Rituxan RA')  
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(866) 681-3329';
            else
                fieldValue = '(866) 681-3261';
        }
        else if(productName=='Tarceva')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(888) 249-4918';
        }
        else if(productName=='TNKase') 
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(800) 530-3083';
        }
        else if(productName=='Xolair')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 704-6614';
            else
                fieldValue = '(800) 704-6610';
        }
         else if(productName=='Actemra')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(866) 681-3329';
            else
                fieldValue = '(866) 681-3261';
        }
          else if(productName=='Xeloda')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(888) 249-4918';
        }
         else if(productName=='Pegasys')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(888) 941-3331';
            else
                fieldValue = '(888) 941-3331';
        }
        else if(productName=='Zelboraf')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(888) 249-4918';
        }
        else if(productName=='Erivedge')
        {
            if(caseTypeName.startsWith('GATCF'))        
                fieldValue = '(800) 530-3083';
            else
                fieldValue = '(888) 249-4918';
        }
    }
}