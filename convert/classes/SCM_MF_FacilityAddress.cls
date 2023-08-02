//Condition is as follows
//Join Case.Facility_gne__c to Account.ID and select Account.Name
public class SCM_MF_FacilityAddress extends SCM_MergeField
{
    
    public SCM_MF_FacilityAddress (Case cseLocal)
    {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='FacilityAddress';
    className='SCM_MF_FacilityAddress ';
    fieldValue = obtainFacilityAddress(cseLocal);
    }
     
    public string obtainFacilityAddress(Case cseLocal)
    {
        try {
       String returnString='';
       
       
       List<Case> x1 = [Select c.Facility_gne__r.Id From Case c
                                                where c.Facility_gne__c=:cseLocal.Facility_gne__c
                                                    order by c.LastModifiedDate desc LIMIT 1];
       string x2 = x1[0].Facility_gne__r.Id;
       
       
       List<Address_vod__c> x3 = [Select Address_1_gne__c From Address_vod__c Where Id=:x2 LIMIT 1];
       
      if (x3.size() !=0) {
       returnString= x3[0].Address_1_gne__c;
      }  
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