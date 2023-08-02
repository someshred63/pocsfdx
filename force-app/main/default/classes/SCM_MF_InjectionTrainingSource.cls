//condition is as follows
//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and select Fulfillment. Injection_Training_Provided_By_gne__c
//If Fulfillment. Injection_Training_Provided_By_gne__c = “CBS” OR “Other Agency”, then merge 
//“A nursing agency will be contacting you shortly to set up your injection training at home. If you do not receive a call from them within 24 hours of this letter, please contact us for assistance.”
//else
//If Fulfillment. Injection_Training_Provided_By_gne__c = “MD Office”, then merge 
//“Your doctor’s office will contact you to set up your injection training if they have not already.”
//else
//If Fulfillment. Injection_Training_Provided_By_gne__c = “Distributor”, then merge 
//“The pharmacy will provide information on injection training at the same time they schedule your first shipment. If they do not, please remind them that you will need injection training.”
//Else merge “”

public class SCM_MF_InjectionTrainingSource extends SCM_MergeField
{
  public SCM_MF_InjectionTrainingSource(String CaseNumberLocal)
  {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='InjTrnSrc';
      className='SCM_MF_InjectionTrainingSource';
      fieldValue = obtainInjectionTrainerSource(CaseNumberLocal); 
  
  }
  
   public String obtainInjectionTrainerSource(String CaseNumberLocal)
  {

try {
    String returnString='';
     List<Fulfillment_gne__c > caseFulfillmentList=[Select f.Other_gne__c,f.Injection_Training_Provided_By_gne__c, f.Case_Fulfillment_gne__r.CaseNumber, 
                                                   f.LastModifiedDate,f.Case_Fulfillment_gne__c From Fulfillment_gne__c f 
                                                   where Case_Fulfillment_gne__r.CaseNumber=:CaseNumberLocal order by f.LastModifiedDate
                                                   desc LIMIT 1];
                                                   
            if(caseFulfillmentList.Size()==1)
            {
	             if(caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='Other Agency' || caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='CBS')
	             {
	              returnString='A nursing agency will be contacting you shortly to set up your injection training at home.'+
	              ' If you do not receive a call from them within 24 hours of this letter, please contact us for assistance.';
	             }
	             
	             else if(caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='MD Office')
	             {
	              returnString='Your doctor’s office will contact you to set up your injection training if they have not already.';
	             }
	             else if(caseFulfillmentList[0].Injection_Training_Provided_By_gne__c=='Distributor')
	             {
	              returnString='The pharmacy will provide information on injection training at the same time they schedule your first shipment.'+
	               'If they do not, please remind them that you will need injection training.';
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