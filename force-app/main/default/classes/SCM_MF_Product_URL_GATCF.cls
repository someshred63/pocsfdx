public class SCM_MF_Product_URL_GATCF  extends SCM_MergeField {

    public SCM_MF_Product_URL_GATCF(Case documentCase) 
    {
        super();
        String productName = documentCase.Product_gne__c;
        setCommons(productName);
    }
    
    public SCM_MF_Product_URL_GATCF(String productName) 
    {
        super();
        setCommons(productName);
    }
    
    private void setCommons(String productName)
    {
        key = 'GATCF_URL';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className = 'SCM_MF_Product_URL_GATCF';
        fieldValue = 'www.GenentechAccessSolutions.com';
        if(productName==null || productName=='')
            return;
        if(productName=='Activase')
            fieldValue = 'www.GenentechAccessSolutions.com';
        else if(productName=='Avastin')
            fieldValue = 'www.AvastinAccessSolutions.com';
        else if(productName=='Herceptin')
            fieldValue = 'www.HerceptinAccessSolutions.com';
        else if(productName=='Lucentis')
            fieldValue = 'www.LUCENTISAccessSolutions.com';
        else if(productName=='Nutropin')
            fieldValue = 'www.NutropinAccessSolutions.com';
        else if(productName=='Pulmozyme')
            fieldValue = 'www.PulmozymeAccessSolutions.com';
        else if(productName=='Raptiva')
            fieldValue = 'www.RAPTIVAAccessSolutions.com';
        else if(productName=='Rituxan')
            fieldValue = 'www.RITUXANAccessSolutions.com';
        else if(productName=='Rituxan RA') 
            fieldValue = 'www.RheumatologyAccessSolutions.com';
        else if(productName=='Tarceva')
            fieldValue = 'www.TarcevaAccessSolutions.com';
        else if(productName=='TNKase') 
            fieldValue = 'www.GenentechAccessSolutions.com';
        else if(productName=='Xolair')
            fieldValue = 'www.XOLAIRAccessSolutions.com';
        else if(productName.contains('Actemra'))
            fieldValue = 'www.RheumatologyAccessSolutions.com';
        else if(productName.contains('Xeloda'))
            fieldValue = 'www.BioOncologyAccessSolutions.com';
        else if(productName.contains('Pegasys'))
            fieldValue = 'www.PegasysAccessSolutions.com';
        else if(productName.contains('Zelboraf'))
            fieldValue = 'www.ZelborafAccessSolutions.com';
        else if(productName.contains('Erivedge'))
            fieldValue = 'www.ZelborafAccessSolutions.com';
    }
}