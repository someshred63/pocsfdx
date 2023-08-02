//Join Case.Facility_gne__c to Account.ID and select Account.Name to merge.  
//If Account.Name = NULL, then join Case.Case_Treating_Physician_gne__c to Account.ID and 
//select Account.FirstName || Account.LastName

public class SCM_MF_PhysicianAddressTo1  extends SCM_MergeField
{ 
	private string caseId;
    public SCM_MF_PhysicianAddressTo1(Case documentCase) 
	{
		key = 'RECNAME_To';
	    displayCheck=false;
	    displayTextBox=true;
	    displayLabel=true;
	    fieldType = SCM_MergeField.FieldTypes.textboxField;
	    label='Addressed To';
		className = 'SCM_MF_PhysicianAddressTo1';
		fieldValue = '';
		caseId=documentCase.id;
		
      List < Case > list1 = [Select c.Facility_gne__r.Name, c.Facility_gne__c From Case c where c.id=:caseId ];
      Case list2 = list1[0];
			 fieldValue = list2.Facility_gne__r.Name; 
		   
		  if (fieldValue == null)
		   {  List < Case > list3 = [Select c.Case_Treating_Physician_gne__r.FirstName, c.Case_Treating_Physician_gne__r.LastName, 
                                         c.Case_Treating_Physician_gne__c From Case c where c.id=:caseId];
			  Case list4 = list3[0];
	
		       fieldValue = list4.Case_Treating_Physician_gne__r.FirstName + ' ' + list4.Case_Treating_Physician_gne__r.LastName ;
		   
		   }
		   
		   if (fieldValue == null)
		   	fieldValue = '';
	}
}