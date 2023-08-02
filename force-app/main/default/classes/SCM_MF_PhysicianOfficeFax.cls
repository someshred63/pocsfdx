//Condition is as follows
//Join Case.Facility_gne__c to Account.ID and select Account.Name
public class SCM_MF_PhysicianOfficeFax extends SCM_MergeField
{
    
    public SCM_MF_PhysicianOfficeFax(Case cseLocal)
    {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='PhysicianOfficeFax';
    className='SCM_MF_PhysicianOfficeFax';
    fieldValue = obtainPhysicianOfficeFax(cseLocal);
    }
     
    public string obtainPhysicianOfficeFax(Case cseLocal)
    {
        try {
       String returnString='';
       
       List<Address_vod__c> x1 = [Select c.Fax_vod__c From Address_vod__c c
                                                where c.Id = :cseLocal.Address_gne__c
                                                  //and account_vod__c = :cseLocal.Case_Treating_Physician_gne__c
                                                    order by c.LastModifiedDate desc LIMIT 1];
              
      if (x1.size() !=0) {
       returnString= x1[0].Fax_vod__c;
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