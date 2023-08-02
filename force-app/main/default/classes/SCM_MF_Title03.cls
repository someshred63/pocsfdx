//Condition is as follows
//If Product is Tarceva or Rituxan or Herceptin or Avastin
//Use Oncology
//If product is Xolair
//Use Xolair� (Omalizumab) For Subcutaneous Use
//If product is Pulmozyme
//Use Pulmozyme
//If product is Nutropin
//Use Nutropin
//If product is Raptive
//Use Raptive� (Efalizumab)
//If product is TNKase
//Use Cardiovascular
//If product is Lucentis
//Use LUCENTIS� (Ranibizumab)
//If product is Rituxan RA
//Use Rituxan� (Rituximab)
//If product is ACTivase
//Use Cardiovascular

public class SCM_MF_Title03 extends SCM_MergeField
{
   public SCM_MF_Title03(Case SelectedcaseLoacal)
   {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='Title03';
      className='SCM_MF_Title03';
      fieldValue = obtainTitle(SelectedcaseLoacal);
   
   }
   
   public String obtainTitle(Case SelectedcaseLoacal)
   {
        String returnString='';
        if(SelectedcaseLoacal.Product_gne__c=='Tarceva' || SelectedcaseLoacal.Product_gne__c=='Rituxan' || SelectedcaseLoacal.Product_gne__c=='Herceptin' || SelectedcaseLoacal.Product_gne__c=='Avastin' || SelectedcaseLoacal.Product_gne__c=='Xeloda')
        { 
         returnString='Oncology';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Xolair')
        {
         returnString='Xolair� (Omalizumab) For Subcutaneous Use';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Pulmozyme')
        {
         returnString='Pulmozyme';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Nutropin')
        {
         returnString='Nutropin';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Raptiva')
        {
         returnString='Raptiva� (Efalizumab)';
        }
         else if (SelectedcaseLoacal.Product_gne__c=='TNKase')
        {
         returnString='Cardiovascular';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Lucentis')
        {
         returnString='LUCENTIS� (Ranibizumab)';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Rituxan RA')
        {
         returnString='Rituxan� (Rituximab)';
        }
         else if (SelectedcaseLoacal.Product_gne__c=='ACTivase')
        {
         returnString='Cardiovascular';
        }
         else if (SelectedcaseLoacal.Product_gne__c=='ACTEMRA')
        {
         returnString='Actemra� (tocilizumab)';
        }
        else if (SelectedcaseLoacal.Product_gne__c.contains('Pegasys'))
        {
         returnString='Pegasys� (Peginterferon alfa-2a)';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Zelboraf')
        {
         returnString='Zelboraf (vemurafenib)';
        }
        else if (SelectedcaseLoacal.Product_gne__c=='Erivedge')
        {
         returnString='Erivedge (Vismodegib)';
        }
        return returnString;
   }
   
    public override String getFieldvalue()
   {
    return fieldValue;
   }
   
}