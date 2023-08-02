//Condition is a s follows
//Join Case.Case_Treating_Physician_gne__c to Account.ID and merge Account.Title
public class SCM_MF_Physician_Title extends SCM_MergeField
{  		
   public  SCM_MF_Physician_Title(String Physicangnec)
  {
   		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        this.className = 'SCM_MF_Physician_Title';
        this.key = 'PhysicianTitle';
        
        List<Case> casePhyTitle;
        try
        {
        casePhyTitle = [Select c.Case_Treating_Physician_gne__r.PersonTitle, 
        c.Case_Treating_Physician_gne__r.LastModifiedDate, c.Case_Treating_Physician_gne__r.Id, 
        c.Case_Treating_Physician_gne__c From Case c where c.Case_Treating_Physician_gne__c=:Physicangnec
        order by c.Case_Treating_Physician_gne__r.LastModifiedDate desc LIMIT 1];
        
        }
        catch(Exception ex)
        {
        	fieldValue = '';        	
        } 
       
        if(casePhyTitle.Size()>0)
        {
         fieldValue=(casePhyTitle[0].Case_Treating_Physician_gne__r.PersonTitle == null)?'':casePhyTitle[0].Case_Treating_Physician_gne__r.PersonTitle;
        }
  }


}