//Condition is as follows
//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances 
//where Insurance.Rank_gne__c = Primary and Insurance.Bill_Level_gne__c = 1. 
//Select the last modified Insurance and merge Insurance.ins_eligible_for_Medicare_Part_D_gne__c
public class SCM_MF_MedicarePart extends SCM_MergeField
 {
   
    
     public SCM_MF_MedicarePart(String cseNumberLocal)
   {
    
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='MedPartDFlag';
    className='SCM_MF_MedicarePart';
    fieldValue = obtainCompanyInsuranceName(cseNumberLocal);
   }
   
    public string obtainCompanyInsuranceName(String cseNumberLocal)
    {
    	try {
       String returnString='';
       List<Insurance_gne__c> insuranceNname = [Select i.LastModifiedDate,i.ins_eligible_for_Medicare_Part_D_gne__c, i.Rank_gne__c,
                                      i.Case_Insurance_gne__r.CaseNumber, i.Case_Insurance_gne__c, i.Bill_Level_gne__c From Insurance_gne__c i 
                                      where i.Case_Insurance_gne__r.CaseNumber=:cseNumberLocal and Bill_Level_gne__c='1' and Rank_gne__c = 'Primary' order by 
												i.LastModifiedDate desc LIMIT 1];
       if(insuranceNname.size()>0)
       	returnString=insuranceNname[0].ins_eligible_for_Medicare_Part_D_gne__c;
      if(returnString==null)
       {
        returnString='';
       }
      
       return returnString;
    } 
     catch (exception ex) {
   	return '';
   }
    }
     public override String getFieldvalue()
   {
    return fieldValue;
   }
}