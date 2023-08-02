//condtion is as follows
//Join Case.Case_Treating_Physician_gne__c to Account.ID and join Account.ID to Contact.HCP_gne__c.  Filter contacts which are associated to treating location on the case by using Case.Address_gne to return a list of Contact objects.
//If Case.Case_Type_gne__c = ("C&R - Standard" OR "C&R - Continuous Care") then 
   //If Contact.Is_Primary_for_gne__c  = “C&R” 
      //If 0, merge then last modified Contact.Primary_Contact_gne__c = T, else “”
       //If 1, merge Contact.Phone 
       //If > 1, choose last modified and merge Contact.Phone, Else merge ""
//If Case.Case_Type_gne__c = "GATCF - Standard" then
   //If Contact.Is_Primary_for_gne__c  = “GATCF” 
     // If 0, merge then last modified Contact.GATCF_Specific_gne__c = T, else “”
       //If 1, merge Contact.Phone 
       //If > 1, choose last modified and merge Contact.Phone, Else merge ""

public class SCM_MF_PhysicianConatcPhone extends SCM_MergeField 
{
    public SCM_MF_PhysicianConatcPhone(Case Selectedcase)
    {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='PhysContactPh';
      className='SCM_MF_PhysicianConatcPhone';
      fieldValue = obtainPhysicianConatcPhone(Selectedcase);
       
    } 
    
     public string obtainPhysicianConatcPhone(Case Selectedcase)
    {
      String returnString='';
      String recordType = selectedCase.RecordType.Name;
        
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case'))
        {
          List<Contact > ListContact = [Select c.Phone, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c='C&R' and c.Address_gne__c=:Selectedcase.Address_gne__c
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
           order by c.LastModifiedDate desc LiMIT 500
                                                   ]; 
                                                  
            if(ListContact.SIZE()>=1)
            {
             returnString=ListContact[0].Phone; 
            } 
            else if(ListContact.SIZE()==0)
            {
               List<Contact > Listtrue = [Select c.Phone,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c='C&R' and c.Address_gne__c=:Selectedcase.Address_gne__c
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
           and c.Primary_Contact_gne__c=true
           order by c.LastModifiedDate desc LiMIT 500
                                                  ]; 
                                                  
               if(Listtrue.Size()==0)
               {
                //do nothing
               } 
               else
               {                                  
                returnString=Listtrue[0].Phone; 
               }
            
            }
            
                                               
        }
        else if (recordType.equals('GATCF - Standard Case'))
        {
          List<Contact > List1 = [Select c.Phone, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c='GATCF' and c.Address_gne__c=:Selectedcase.Address_gne__c
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
           order by c.LastModifiedDate desc LiMIT 500
                                                  ]; 
                                                  
            if(List1.SIZE()>=1)
            {
             returnString=List1[0].Phone; 
            } 
            else if(List1.SIZE()==0)
            {
               List<Contact > Listtrue1 = [Select c.Phone,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c='GATCF' and c.Address_gne__c=:Selectedcase.Address_gne__c
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
           and c.Primary_Contact_gne__c=true
           order by c.LastModifiedDate desc LiMIT 1
                                                  ]; 
                                                  
               if(Listtrue1.Size()==0)
               {
                //do nothing
               } 
               else
               {                                  
                returnString=Listtrue1[0].Phone; 
               }
            
            }
            
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