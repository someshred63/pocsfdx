//condition is as follows
//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and select Fulfillment. Injection_Training_Provided_By_gne__c
//If Fulfillment. Injection_Training_Provided_By_gne__c = “Other Agency”, then merge Fulfillment.Other_gne__c else
//If Fulfillment. Injection_Training_Provided_By_gne__c = “CBS”, then merge ”Clinical Business Solutions”, else
//If Fulfillment. Injection_Training_Provided_By_gne__c = “Distributor”, then merge “your pharmacy”, else
//Merge Fulfillment. Injection_Training_Provided_By_gne__c

public class SCM_MF_InjectionTrainer extends SCM_MergeField
{
  public SCM_MF_InjectionTrainer(String CaseNumberLocal)
  {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='InjTrn';
      className='SCM_MF_InjectionTrainer';
      fieldValue = obtainInjectionTrainer(CaseNumberLocal); 
  
  }
  
   public String obtainInjectionTrainer(String CaseNumberLocal)
  {
  	
  try {
    String returnString='';
     List<Fulfillment_gne__c > caseFulfillmentList=[Select f.Other_gne__c,f.Injection_Training_Provided_By_gne__c, f.Case_Fulfillment_gne__r.CaseNumber, 
                                                   f.LastModifiedDate,f.Case_Fulfillment_gne__c From Fulfillment_gne__c f 
                                                   where Case_Fulfillment_gne__r.CaseNumber=:CaseNumberLocal order by f.LastModifiedDate
                                                   desc LIMIT 1];
                                                   
            if(caseFulfillmentList.Size()==1)
            {
	             if(caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='Other Agency')
	             {
	              returnString=caseFulfillmentList[0].Other_gne__c;
	             }
	             else if(caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='CBS')
	             {
	              returnString='Clinical Business Solutions.';
	             }
	             else if(caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='Distributor')
	             {
	              returnString='your pharmacy.';
	             }
	             else
	             {
	              returnString=caseFulfillmentList[0].Injection_Training_Provided_By_gne__c;
	             }
            }
            
            if(returnString==null)
            {
             returnString='';
            }
            return returnString;
            } 
   	catch (Exception ex){
   		return '';
   	}
  }
  
   public override String getFieldvalue()
   {
    return fieldValue;
   }    
}