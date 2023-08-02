//Condition is as follows
//Join Case.Facility_gne__c to Account.ID and select Account.Name
public class SCM_MF_FacilityFax extends SCM_MergeField
{
    
    public SCM_MF_FacilityFax(Case cseLocal)
    {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='FacilityFax';
    className='SCM_MF_FacilityFax';
    fieldValue = obtainFacilityFax(cseLocal);
    }
     
    public string obtainFacilityFax(Case cseLocal)
    {
        try {
       String returnString='';
       
       
       List<Case> x1 = [Select c.Facility_gne__r.Fax From Case c
                                                where c.Facility_gne__c=:cseLocal.Facility_gne__c
                                                    order by c.LastModifiedDate desc LIMIT 1];
       
      if (x1.size() !=0) {
       returnString= x1[0].Facility_gne__r.Fax;
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