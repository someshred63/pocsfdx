public class GNE_CRM_340B_Email_TriggerHandler {

    private static boolean emailAssignmentRun = false;
    
    public static void updateParentCase(List<GNE_CRM_340B_Email__c> emails){
        Set<Id> parentIds = new Set<Id>();
        for(GNE_CRM_340B_Email__c record : emails){
			if(String.isNotBlank(record.X340B_Case__c)) {
				parentIds.add(record.X340B_Case__c);
			}
        }
        
        update [SELECT Id FROM GNE_CRM_340B_Case__c WHERE Id IN: parentIds];  
    }

    public static void updateCaseAssignedStatus(List<GNE_CRM_340B_Email__c> emails) {
        for (GNE_CRM_340B_Email__c e : emails) {
            e.Case_Assigned__c = String.isNotBlank(e.X340B_Case__c);
        }
    }
    
    public static Boolean isSharedValue(String value1, String value2) {
        List<String> value2List = value2.split('; ');
        for (String s : value1.split('; ')) {
            if (value2List.contains(s)) {
                return true;
            }
        }
        return false;
    }
    
    public static String extractEmailAddress(String email) {
        if (email.contains('<') && email.contains('>')) {
            return email.substring(email.indexof('<')+1, email.indexof('>')).toLowerCase();
        }
        return email.toLowerCase();
    }


    /*
    if there is Account assigned to Contact's email and has only 1 opened case - assign to this case
    if there is Account assigned to Contact's email and has more then 1 opened case - leave it in the queue  
    if there is Account assigned to Contact's email and doesn't have open case - leave it in the queue  
    
    If there is no matching Contact, but 340B label is assigned - leave it in the queue
    If there is no matching Contact, and there is no 340B label assigned - remove email

    If there are multiple recipients in To field - leave it in the queue

    There should be only emails with 340B label or with matching Contact (with 340B status) 
    */    
    public static void assignEmailToCase(List<GNE_CRM_340B_Email__c> emails) {
        
        if (!emailAssignmentRun) {
            
            emailAssignmentRun = true;
            
	        List<GNE_CRM_340B_Email__c> emailsToUpdate = new List<GNE_CRM_340B_Email__c>(); 
	        List<Id> emailIdToDelete = new List<Id>(); 
	        
	        Set<String> toAddresses = new Set<String>{};
	        for (GNE_CRM_340B_Email__c e : emails) {
	            if (String.isNotBlank(e.Labels__c) && e.Labels__c.contains('DRAFT')) {
	                emailIdToDelete.add(e.Id);
	            } else if (String.isNotBlank(e.From__c) && String.isNotBlank(e.To__c) && String.isBlank(e.X340B_Case__c)) {
	                toAddresses.add(extractEmailAddress(e.From__c));
	
	                if (e.To__c.contains(', ')) {
	                    for (String s : e.To__c.split(', ')) {
	                        toAddresses.add(extractEmailAddress(s));
	                    }
	                } else {
	                    toAddresses.add(extractEmailAddress(e.To__c));
	                }
	            } else if (String.isNotBlank(e.From__c) && String.isBlank(e.To__c) && String.isBlank(e.X340B_Case__c)) {
	                emailIdToDelete.add(e.Id);
	            }
	        }
	
	        if (!toAddresses.isEmpty()) {
				List<Contact> contacts = [ SELECT Id, AccountId, Account.X340B_Open_Case__c, Email FROM Contact WHERE X340B_Contact__c = TRUE AND Email IN :toAddresses AND Email != NULL LIMIT 50000 ];
	            // Email, AccountId
	            Map<String, Id> contactEmailMap = new Map<String, Id>();  
	            Set<Id> accountsIdsWithOpenCases = new Set<Id>();
	            for (Contact c : contacts) {
	                contactEmailMap.put(c.Email, c.AccountId);
	                if (c.Account.X340B_Open_Case__c && String.isNotBlank(c.AccountId)) {
						accountsIdsWithOpenCases.add(c.AccountId);
	                }
	            }
		
	            Map<Id, Account> accountMapWithOpenedCases = new Map<Id, Account>([ SELECT Id, (SELECT Id FROM X340B_Cases__r WHERE Case_Status__c NOT IN ('Closed')) 
	                                                                                FROM Account 
	                                                                                WHERE Id IN :accountsIdsWithOpenCases ]); 
	
	            // Map<Contact.Email, NumerOfOpenedCases>
	            Map<String, Integer> contactWithOpenedCases = new Map<String, Integer>();
	            for (String email : contactEmailMap.keySet()) {
	                Id accountId = contactEmailMap.get(email);
	                Account acc = accountMapWithOpenedCases.get(accountId);
	                contactWithOpenedCases.put(email, (acc != null) ? acc.X340B_Cases__r.size() : 0);
	            }
	                
	            for (GNE_CRM_340B_Email__c e : emails) {
	                if (String.isNotBlank(e.From__c) && String.isNotBlank(e.To__c)) {
	                    Integer numberOfCasesFrom = contactWithOpenedCases.get(extractEmailAddress(e.From__c));
	                    Id accountIdFrom = contactEmailMap.get(extractEmailAddress(e.From__c));
	                    
	                    Map<String, Integer> numberOfCasesToMap = new Map<String, Integer>();
	                    if (e.To__c.contains(', ')) {
	                        for (String s : e.To__c.split(', ')) {
	                            numberOfCasesToMap.put(extractEmailAddress(s), contactWithOpenedCases.get(extractEmailAddress(s)));
	                        }
	                    } else {
	                        numberOfCasesToMap.put(extractEmailAddress(e.To__c), contactWithOpenedCases.get(extractEmailAddress(e.To__c)));
	                    }
	                    Integer numberOfCasesTo = contactWithOpenedCases.get(extractEmailAddress(e.To__c));
	
	                    Id accountIdTo = contactEmailMap.get(extractEmailAddress(e.To__c));
	    
	                    if (numberOfCasesFrom == 1) {
	                        Id caseId = accountMapWithOpenedCases.get(accountIdFrom).X340B_Cases__r.get(0).Id;
	                        emailsToUpdate.add(
	                           new GNE_CRM_340B_Email__c(Id = e.Id, X340B_Case__c = caseId)
	                        );
	                    } else if (numberOfCasesTo == 1) {
	                        Id caseId = accountMapWithOpenedCases.get(accountIdTo).X340B_Cases__r.get(0).Id;
	                        emailsToUpdate.add(
	                           new GNE_CRM_340B_Email__c(Id = e.Id, X340B_Case__c = caseId)
	                        );
	                    } else if (accountIdFrom == null && accountIdTo == null) {
	                        if (String.isNotBlank(e.Labels__c) && String.isNotBlank(e.User_Labels__c)) {
	                            Boolean labelExists = isSharedValue(e.Labels__c, e.User_Labels__c);
	                            if (!labelExists) {
	                                //emailIdToDelete.add(e.Id);
			                        emailsToUpdate.add(
			                           new GNE_CRM_340B_Email__c(Id = e.Id, Inactive__c = true)
			                        );                                
	                            }
	                        }
	                    }
	                }
	            }
	        }
	        
	        if (emailsToUpdate.size()>0) {
	            update emailsToUpdate;
	        }
	        
	        if (emailIdToDelete.size()>0) {
	            Database.delete(emailIdToDelete);
	        }        
	    }
    }
}