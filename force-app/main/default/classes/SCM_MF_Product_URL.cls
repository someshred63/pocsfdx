public class SCM_MF_Product_URL extends SCM_MergeField {

    public SCM_MF_Product_URL(Case documentCase) 
    {
        key = 'URL';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_Product_URL';
        String productName = documentCase.Product_gne__c;
        String caseTypeName = documentCase.RecordType.Name;
        fieldValue = '';
        
        if(productName=='Activase')
        {
            fieldValue = 'www.GenentechAccessSolutions.com';
        }
        else if(productName=='Avastin')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.AvastinAccessSolutions.com';
            else
                fieldValue = 'www.BioOncologyAccessSolutions.com';
        }
        else if(productName=='Herceptin')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.HerceptinAccessSolutions.com';
            else
                fieldValue = 'www.BioOncologyAccessSolutions.com';
        }
        else if(productName=='Lucentis')
            fieldValue = 'www.LUCENTISAccessSolutions.com';
        else if(productName=='Nutropin')
            fieldValue = 'www.NutropinAccessSolutions.com';
        else if(productName=='Pulmozyme')
            fieldValue = 'www.PulmozymeAccessSolutions.com';
        else if(productName=='Raptiva')
            fieldValue = 'www.RAPTIVAAccessSolutions.com';
        else if(productName=='Rituxan')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.RITUXANAccessSolutions.com';
            else
                fieldValue = 'www.BioOncologyAccessSolutions.com';
        }
        else if(productName=='Rituxan RA')  //Get real number
            fieldValue = 'www.RheumatologyAccessSolutions.com';
        else if(productName=='Tarceva')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.TarcevaAccessSolutions.com';
            else
                fieldValue = 'www.BioOncologyAccessSolutions.com';
        }
        else if(productName=='TNKase')  //Get real number
            fieldValue = 'www.GenentechAccessSolutions.com';
        else if(productName=='Xolair')
            fieldValue = 'www.XOLAIRAccessSolutions.com';
        else if(productName.contains('Actemra'))
            fieldValue = 'www.RheumatologyAccessSolutions.com';
                
        else if(productName=='Xeloda')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.BioOncologyAccessSolutions.com';
            else
                fieldValue = 'www.BioOncologyAccessSolutions.com';
        }
        else if(productName=='Pegasys')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.PegasysAccessSolutions.com';
            else
                fieldValue = 'www.PegasysAccessSolutions.com';
        }
        else if(productName=='Zelboraf')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.BioOncologyAccessSolutions.com';
            else
                fieldValue = 'www.VemurafenibAccessSolutions.com';
        }
        else if(productName=='Erivedge')
        {
            if(caseTypeName.startsWith('GATCF'))
                fieldValue = 'www.BioOncologyAccessSolutions.com';
            else
                fieldValue = 'www.BioOncologyAccessSolutions.com';
        }
    }
}