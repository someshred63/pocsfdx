//condition is as follows
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances 
//where Insurance.Bill_Level_gne__c = 1.  Select the last modified Insurance and 
//join Insurance.Payer to Account.ID and merge Account.Name
public class SCM_MF_CompanyInsurance extends SCM_MergeField
{
   public SCM_MF_CompanyInsurance(string cseNumberLocal)
   {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='InsuranceName'; 
    className='SCM_MF_CompanyInsurance';
    fieldValue = obtainCompanyInsuranceName(cseNumberLocal);
   }
   
    public string obtainCompanyInsuranceName(string cseNumberLocal)
    {
       String returnString='';
       List<Insurance_gne__c> insuranceNname = [Select i.Payer_gne__r.Name, i.Payer_gne__r.Id, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                             i.Case_Insurance_gne__c, i.Bill_Level_gne__c From Insurance_gne__c i where i.Bill_Level_gne__c='1'
                                            and i.Case_Insurance_gne__r.CaseNumber=:cseNumberLocal and i.Rank_gne__c='Primary'
                                                    order by i.LastModifiedDate desc LIMIT 1];
       if(insuranceNname.Size()>0)
       {
       returnString=insuranceNname[0].Payer_gne__r.Name;
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