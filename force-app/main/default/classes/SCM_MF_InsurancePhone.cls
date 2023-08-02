//Condition is a s follows
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances 
//where Insurance.Rank_gne__c = Primary and Insurance.Bill_Level_gne__c = 1.
//Select the last modified Insurance and join Insurance.Payer to Account.ID and merge Account.Phone.

public class SCM_MF_InsurancePhone extends SCM_MergeField
 {
    
    
     public SCM_MF_InsurancePhone(String cseNumberLocal)
   {
    
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='InsurancePhone';
    className='SCM_MF_InsurancePhone';
    fieldValue = obtainCompanyInsuranceName(cseNumberLocal);
   }
   
    public string obtainCompanyInsuranceName(String cseNumberLocal)
    {
       String returnString='';
       List<Insurance_gne__c> insuranceNname = [Select  i.LastModifiedDate,i.Payer_gne__r.Phone, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                                     i.Case_Insurance_gne__c, i.Bill_Level_gne__c,i.Rank_gne__c
                                                      From Insurance_gne__c i where i.Case_Insurance_gne__r.CaseNumber=:cseNumberLocal 
                                                      and i.Bill_Level_gne__c='1' and i.Rank_gne__c='Primary'
                                                      order by i.LastModifiedDate desc LIMIT 1];
        
       if(insuranceNname.size()>0)
       {
       returnString=insuranceNname[0].Payer_gne__r.Phone;
       }
      if(returnString==null)
       {
        returnString='';
       }
      
       return returnString;
    } 
     public override String getFieldvalue()
   {
    return fieldValue;
   }
}