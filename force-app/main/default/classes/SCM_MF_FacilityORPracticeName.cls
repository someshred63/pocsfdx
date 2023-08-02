public class SCM_MF_FacilityORPracticeName extends SCM_MergeField
{
	
    public SCM_MF_FacilityORPracticeName(Case cseLocal)
    {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='FacilityOrPracticeName';
    className='SCM_MF_FacilityORPracticeName';
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
       if (returnString == ''){
       		Case caseName2 = [Select  c.Practice_gne__r.Name From Case c
                                                where c.ID=:cseLocal.ID
													order by c.LastModifiedDate desc LIMIT 1];
       	
       
       if (caseName2.Practice_gne__r.Name != null) {
       	returnString = caseName2.Practice_gne__r.Name;
       	
       }
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