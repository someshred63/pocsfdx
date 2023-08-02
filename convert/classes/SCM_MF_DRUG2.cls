// created by Sridhar

//If Case.Product <> Nutropin OR Rituxan RA, then merge Case.Product
//Else
//If Case.Product = Nutropin, then
//Join Case to Medical History and if Medical History.Drug = 
//Nutropin 1x10 mg, then merge "Nutropin"
//Nutropin 1x5 mg, then merge "Nutropin"
//Nutropin AQ 1x10 mg, then merge "Nutropin AQ"
//Nutropin AQ Cartridge 1x10 mg, then merge "NAQ Cartridge"
//Nutropin AQ Cartridge 1x20 mg, then merge "NAQ Cartridge"
//Nutropin Depot, then merge "Nutropin Depot"

//If Case.Product = Rituxan RA, then merge "Rituxan"


public class SCM_MF_DRUG2 extends SCM_MergeField
{
	List<Case> caseList;
	private string ret;
	
	public SCM_MF_DRUG2(Case SelectedCaseLocal)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'DRUG';
        className = 'SCM_MF_DRUG2';
        
        
        if(SelectedCaseLocal.Product_gne__c!='Nutropin' || SelectedCaseLocal.Product_gne__c!='Rituxan RA')
        {
         	ret =SelectedCaseLocal.Product_gne__c;
        }
        else if(SelectedCaseLocal.Product_gne__c=='Nutropin')
         {
         	List<Case> caseList2 = [Select c.Medical_History_gne__r.Drug_gne__c, c.Medical_History_gne__c From Case c];
         	if(caseList2[0].Medical_History_gne__r.Drug_gne__c ==' Nutropin 1x10 mg')
         	{
         		ret='Nutropin';         		
         	}
         	else if(caseList2[0].Medical_History_gne__r.Drug_gne__c ==' Nutropin 1x5 mg')
         	{
         		ret='Nutropin';      
         	}
         	else if(caseList2[0].Medical_History_gne__r.Drug_gne__c ==' Nutropin AQ 1x10 mg')
         	{
         		ret='Nutropin AQ';
         	}
         	else if(caseList2[0].Medical_History_gne__r.Drug_gne__c =='Nutropin AQ Cartridge 1x10 mg')
         	{
         		ret='NAQ Cartridge';
         	}
         	else if(caseList2[0].Medical_History_gne__r.Drug_gne__c =='Nutropin AQ Cartridge 1x20 mg')
         	{
         		ret='NAQ Cartridge';
         	}
         	else if (caseList2[0].Medical_History_gne__r.Drug_gne__c =='Nutropin Depot')
         	{
         		ret='Nutropin Depot';
         	}
         	
         }
       else if(SelectedCaseLocal.Product_gne__c=='Rituxan RA')
       {
       	ret='Rituxan';
       }
             
    } 
    public override String getFieldValue()
    {
    	return ret;
    }
}