// Added By: Rajesh Sinha
 
/**
Join Case.Medical_History_gne__c to Medical History.ID and store the Medical History.Date_of_First_Treatment_gne__c.
Join Case.CaseNumber to Infusion.Case_gne__c to create a list of Infusions where Infusion. Infusion_Injection_Status_gne__c = “Processed” AND Infusion.Infusion_Date_gne__c ≥ Medical History.Date_of_First_Treatment_gne__c.
For each Infusion selected, select the Infusion.milligrams_gne__c, round to the next hundred (ex. Round 301 to 400) and then add the output for all the infusions.
If infusion total is Null , merge “0”.
*/
public class SCM_MF_InfusionTotal extends SCM_MergeField  {
	
	private string case_ID;
	List<Case> Date_of_First_TreatmentList;
	List<Infusion_gne__c> TotalInfusionsList; 
	
	public SCM_MF_InfusionTotal(String caseId) {    
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'InfusionTotal';
    	ClassName = 'SCM_MF_InfusionTotal';
    	this.case_ID = caseId;
    	fieldValue = GetInfusionTotalValue();    	
  	}
  	private string GetInfusionTotalValue() {
  		string returnValue = '';
  		Double TotalInfusions = 0.0;
  		Date Date_of_First_Treatment = Date.today();
  		
  		Date_of_First_TreatmentList = [Select c.Medical_History_gne__r.Date_of_First_Treatment_gne__c , c.Medical_History_gne__c 
						        		From Case c
						                WHERE c.Id = :case_ID  LIMIT 50 ];
                if(Date_of_First_TreatmentList.size() >= 1){
                	Date_of_First_Treatment = Date_of_First_TreatmentList[0].Medical_History_gne__r.Date_of_First_Treatment_gne__c ;
                if(Date_of_First_Treatment != null){
                	TotalInfusionsList = [Select i.Case_gne__r.CaseNumber, i.Case_gne__c, i.Milligrams_gne__c,i.Infusion_Date_gne__c, i.Infusion_Injection_Status_gne__c, i.Case_gne__r.Id
 									 	From Infusion_gne__c i where i.Infusion_Injection_Status_gne__c = 'Processed' and   i.Infusion_Date_gne__c >= :Date_of_First_Treatment and  i.Case_gne__r.Id = :case_ID  LIMIT 500 ];
 						
		 						 if(TotalInfusionsList.size()> 0){
		 						 	
		 						 	for(Infusion_gne__c i : TotalInfusionsList){
		 						 		if(i.Milligrams_gne__c!=null){
		 						 			TotalInfusions += i.Milligrams_gne__c;							
										}
		 						 	}
		 						 	Double restValue =TotalInfusions;
		 						 	for(Double i=0; restValue > 100; i++)
		 						 	{
		 						 		restValue = restValue -100;
		 						 	}
		 						 	restValue = 100 - restValue;
		 						 	TotalInfusions = TotalInfusions + restValue;
		 						 			 						 
										returnValue = TotalInfusions.format();
		 						 }
		 						 
                }
 									 	
           }
      return returnValue; 
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}

}