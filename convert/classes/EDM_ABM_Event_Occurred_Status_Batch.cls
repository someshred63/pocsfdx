global class EDM_ABM_Event_Occurred_Status_Batch implements Database.Batchable<sObject> {

	final static String EVENT_OCCURRED = 'Event Occurred';
	
	global EDM_ABM_Event_Occurred_Status_Batch() {
		System.debug('EDM_ABM_Event_Occurred_Status_Batch start.');
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(
				[SELECT Id, Name, EDM_Status_gne__c,EDM_End_Date_gne__c,EDM_Start_Date_gne__c
				FROM EDM_IABP_gne__c 
				WHERE EDM_Parent_IABP_gne__c = null AND EDM_History_Parent_IABP_gn__c = null AND EDM_IABP_Version_gne__c > 0 
				AND	EDM_Status_gne__c NOT IN ('Canceled', :EVENT_OCCURRED, 'Executive Summary in Progress', 'Executive Summary in Review', 'PTD in Progress', 'PTD complete') 
				AND	EDM_End_Date_gne__c <= TODAY]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		// logic to restore previous version of IABP 
			Map<Id,EDM_IABP_gne__c> previousVersions = new Map<Id,EDM_IABP_gne__c>();
			Set<Id> scopeForRestore = new Set<Id>();
		// logic to restore previous version of IABP 

		 if (scope != null && scope.size() > 0) {
			List<EDM_IABP_gne__c> eventsOccurred = new List<EDM_IABP_gne__c>();
			for(sObject objIABP : scope) {
				EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)objIABP;

				if(iabp.EDM_Status_gne__c != 'IABP Approved' && iabp.EDM_End_Date_gne__c == System.today()){
						scopeForRestore.add(iabp.Id);
				} else {

					iabp.EDM_Status_gne__c = EVENT_OCCURRED;
					eventsOccurred.add(iabp);			
				}

				
			}
		
		
		// logic to restore previous version of IABP
		String scopeStr = '' + scopeForRestore;
		scopeStr = scopeStr.replace('{', '(\'');
		scopeStr = scopeStr.replace('}', '\')');
		scopeStr = scopeStr.replace(',', '\',\'');
		List<String> extFlds = new List<String>{'CreatedDate'};
		List<EDM_IABP_gne__c> iabps = (List<EDM_IABP_gne__c>)Database.query(EDM_ABM_Utils.getCreatableFieldsSOQL('EDM_IABP_gne__c','EDM_Status_gne__c IN (\'IABP Approved\') AND  EDM_History_Parent_IABP_gn__c IN ' + scopeStr,extFlds));

			for(EDM_IABP_gne__c tmp:iabps){

				if(previousVersions.containsKey(tmp.EDM_History_Parent_IABP_gn__c)){
					if(previousVersions.get(tmp.EDM_History_Parent_IABP_gn__c).CreatedDate < tmp.CreatedDate) {

							previousVersions.remove(tmp.EDM_History_Parent_IABP_gn__c);
							previousVersions.put(tmp.EDM_History_Parent_IABP_gn__c,tmp);
					}

				} else {

					previousVersions.put(tmp.EDM_History_Parent_IABP_gn__c,tmp);
				}

			}
			for(sObject objIABP : scope) {
				EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)objIABP;
				if(scopeForRestore.contains(iabp.Id) && iabp.EDM_End_Date_gne__c == System.today()){
						
						if(previousVersions.containsKey(iabp.id)){
								
							Map<String, Schema.SobjectField> IABPFields = Schema.SObjectType.EDM_IABP_gne__c.fields.getMap();

							for(String key : EDM_ABM_Utils.getCreatableFields('EDM_IABP_gne__c')) {
							       if(key != 'EDM_Status_gne__c' || key != 'EDM_IABP_Version_gne__c') {
							       	 iabp.put(key, previousVersions.get(iabp.id).get(key));
							       }
							       
						   	}
						   	iabp.EDM_History_Parent_IABP_gn__c = null;
						   	iabp.EDM_Historical_gne__c = false;
                            iabp.EDM_Status_gne__c = EVENT_OCCURRED;
                            eventsOccurred.add(iabp);
						}
				}		
			}

			update eventsOccurred;
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('EDM_ABM_Event_Occurred_Status_Batch finished.');
	}
	
}