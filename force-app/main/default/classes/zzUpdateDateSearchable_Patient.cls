global class zzUpdateDateSearchable_Patient implements Database.Batchable<sObject>{
	
	List<Patient_gne__c> lstPatient= new List<Patient_gne__c>();
	
	global Database.Querylocator start(Database.BatchableContext BC)
	 {		 	
	    return Database.getQueryLocator([Select id,name from Patient_gne__c]);
	 }	
	
	 global void execute(Database.BatchableContext BC,list<Patient_gne__c> scope)
	 {
	 	for(Patient_gne__c Pat : scope)
	 	{	 		
            lstPatient.add(Pat);
	 	}
	 	system.debug('lstPatient----------->'+lstPatient);
 	    if(lstPatient.size() > 0)
        {
      	  update lstPatient;
        }
	 }
	 
	 global void finish(Database.BatchableContext BC)
	 {
	 }

}