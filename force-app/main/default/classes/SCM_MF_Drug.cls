//Condition is as follows
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

public class SCM_MF_Drug extends SCM_MergeField
{
 public SCM_MF_Drug(Case SelectedcaseLoacal)
 {
  	  checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='Drug';
      className='SCM_MF_Drug';
      fieldValue = obtainDrug(SelectedcaseLoacal);
 
 }
 
   public String obtainDrug(Case SelectedcaseLoacal)
   {
   	String returnString=SelectedcaseLoacal.Product_gne__c;
     if(SelectedcaseLoacal.Product_gne__c=='Rituxan RA')
     {
       returnString='Rituxan';
     
     }
     else if(SelectedcaseLoacal.Product_gne__c=='Nutropin')
     {
      List<Medical_History_gne__c> medList=[Select m.Id, m.Drug_gne__c From Medical_History_gne__c m
      				 where m.Id=:SelectedcaseLoacal.Medical_History_gne__r.Id order by m.LastModifiedDate desc LIMIT 1];
	     if(medList.Size()>0 && medList[0].Drug_gne__c!=null)
	     {
	       String Drug=medList[0].Drug_gne__c;
	       if(Drug=='Nutropin 1x10 mg')
	       		returnString='Nutropin';
	       else if(Drug=='Nutropin 1x5 mg')
	       		returnString='Nutropin';
	       else if(Drug=='Nutropin AQ 1x10 mg')
	       		returnString='Nutropin AQ';
	       else if(Drug=='Nutropin AQ Cartridge 1x10 mg')
	       		returnString='NAQ Cartridge';
	       else if(Drug=='Nutropin AQ Cartridge 1x20 mg')
	       		returnString='NAQ Cartridge';
	       else if(Drug=='Nutropin Depot')
	       		returnString='Nutropin Depot';
	       else if(Drug=='Nutropin AQ NuSpin 1x5 mg' || Drug=='Nutropin AQ NuSpin 1x10 mg' || Drug=='Nutropin AQ NuSpin 1x20 mg')
				returnString='NAQ NuSpin';
	     
	     }
     }     
     else if(SelectedcaseLoacal.Product_gne__c.contains('Pegasys'))
     {
       returnString='Pegasys';
     
     }
     
     return returnString;
   }
   
    public override String getFieldvalue()
   {
    return fieldValue;
   }
}