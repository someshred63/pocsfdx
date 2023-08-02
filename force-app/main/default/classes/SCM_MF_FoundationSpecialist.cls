//Condition is as  follows
//Join Case. Foundation_Specialists_gne__c to User.Name  and select User.Name
public class SCM_MF_FoundationSpecialist extends SCM_MergeField {

  public SCM_MF_FoundationSpecialist(Case SelectdCase)
  {
   	  checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='FoundationSpecialist';
      className='SCM_MF_FoundationSpecialist';
      
      try
      {
	      List<Case> caseFondSpec = [Select c.Foundation_Specialist_gne__r.LastModifiedDate, 
	      c.Foundation_Specialist_gne__r.Name, c.Foundation_Specialist_gne__c From Case c 
	      where c.Foundation_Specialist_gne__c=:SelectdCase.Foundation_Specialist_gne__c
	      order by c.Foundation_Specialist_gne__r.LastModifiedDate desc LIMIT 1];
	        
	      if(caseFondSpec.Size()>0)
	      {
	        fieldValue=(caseFondSpec[0].Foundation_Specialist_gne__r.Name == null)?'':caseFondSpec[0].Foundation_Specialist_gne__r.Name;
	      }
      }
      catch (Exception e)
      {
      	fieldValue = '';
      	System.debug('SCM_MF_FoundationSpecialist...Error Message:' + e.getMessage());
      }
      
  
  }
}