global class zzRemoveDup_MedicalHistory implements Database.Batchable<sObject>{
	
	List<Medical_History_gne__c> lstUpdateMedHist= new List<Medical_History_gne__c>();
	
	global Database.Querylocator start(Database.BatchableContext BC)
	 {	
	 	RecordType mhRecordType = [select Id from RecordType where Name = 'Herceptin' and SobjectType = 'Medical_History_gne__c' limit 1]; 
	    return Database.getQueryLocator([Select id,Her2_Test_gne__c from Medical_History_gne__c where Her2_Test_gne__c != null] );
	 }	
	
	 global void execute(Database.BatchableContext BC,list<Medical_History_gne__c> scope)
	 {
	 	for(Medical_History_gne__c mh : scope)
	 	{
	 		if(mh.Her2_Test_gne__c == 'Positive')
            {
                mh.Her2_Test_gne__c = 'Yes';
            }
            if(mh.Her2_Test_gne__c == 'Negative')
            {
                mh.Her2_Test_gne__c = 'No';
            }
            lstUpdateMedHist.add(mh);
	 	}
	 	system.debug('lstUpdateMedHist----------->'+lstUpdateMedHist);
 	    if(lstUpdateMedHist.size() > 0)
        {
      	  update lstUpdateMedHist;
        }
	 }
	 
	 global void finish(Database.BatchableContext BC)
	 {
	 }
}