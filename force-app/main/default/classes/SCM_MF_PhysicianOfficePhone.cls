//Condition is as follows
//Join Case.Facility_gne__c to Account.ID and select Account.Name
public class SCM_MF_PhysicianOfficePhone extends SCM_MergeField
{
    
    public SCM_MF_PhysicianOfficePhone(Case cseLocal)
    {
   
    checked=false;
    displayCheck=false;
    displayTextBox=false;
    displayLabel=false;
    Key='PhysicianOfficePhone';
    className='SCM_MF_PhysicianOfficePhone';
    fieldValue = obtainPhysicianOfficePhone(cseLocal);
    }
     
    public string obtainPhysicianOfficePhone(Case cseLocal)
    {
        try {
       String returnString='';
       
       List<Address_vod__c> x1 = [Select c.Phone_vod__c From Address_vod__c c
                                                where c.Id = :cseLocal.Address_gne__c
                                                  //and account_vod__c = :cseLocal.Case_Treating_Physician_gne__c
                                                    order by c.LastModifiedDate desc LIMIT 1];
              
      if (x1.size() !=0) {
       returnString= x1[0].Phone_vod__c;
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