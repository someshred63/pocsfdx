//Condition is as follows
//Join Case.Facility_gne__c to Account.ID and select Account.Name
public class SCM_MF_FacilityName extends SCM_MergeField
{
	
    public SCM_MF_FacilityName(Case cseLocal)
    {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='FacilityName';
    className='SCM_MF_FacilityName';
    fieldValue = obtainFacilityName(cseLocal);
    }
     
    public string obtainFacilityName(Case cseLocal)
    {
    	try {
       String returnString='';
       List<Case> caseName = [Select  c.Facility_gne__r.Name From Case c
                                                where c.Facility_gne__c=:cseLocal.Facility_gne__c
													order by c.LastModifiedDate desc LIMIT 1];
      if (caseName.size() !=0) {
       returnString= caseName[0].Facility_gne__r.Name;
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