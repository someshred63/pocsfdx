public class SCM_MF_BI_PlanName extends SCM_MergeField {

  public SCM_MF_BI_PlanName(string insuranceID)
  {
  	
    key = 'PlanName';
    className = 'SCM_MF_BI_PlanName';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
    fieldValue = '';
    try{
  		
  		if (insuranceID != null) {
  			Insurance_gne__c ins = [select Plan_gne__r.name from Insurance_gne__c where id = :insuranceID limit 1 ];
  			if (ins.Plan_gne__r.name != null){
  			fieldValue = ins.Plan_gne__r.name;	
  			}		
  			
  		}
  	
  	 
    }
    catch(exception ex){
    fieldValue = '';	
    }
}
}