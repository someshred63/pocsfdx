public with sharing class GNE_SFA2_Spkr_Bur_Mem_Validation_Rules {
	
	
	public static void onBeforeInsert(List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		
		Speaker_Bureau_de_duplication(triggerNewList);
        takeSnapshotClassificationAndExclusion(triggerNewList);
	}
	
	public static void onBeforeUpdate(List<Speaker_Bureau_Membership_gne__c> triggerOldList,List<Speaker_Bureau_Membership_gne__c> triggerNewList,Map<ID,Speaker_Bureau_Membership_gne__c> triggerOldMap,Map<ID,Speaker_Bureau_Membership_gne__c> triggerNewMap){
		Speaker_Bureau_de_duplication(triggerNewList,triggerOldMap,triggerNewMap);
		checkStatusChanges(triggerNewList,triggerOldMap,triggerNewMap);
	}
	
	
	//for update triggers 
	public static void Speaker_Bureau_de_duplication(List<Speaker_Bureau_Membership_gne__c> triggerNewList,Map<ID,Speaker_Bureau_Membership_gne__c> triggerOldMap,Map<ID,Speaker_Bureau_Membership_gne__c> triggerNewMap){
		
		Map<ID,Speaker_bureau_Membership_gne__c> old_members_map = triggerOldMap;
		//Map to hold new records
		Map<ID,Speaker_bureau_Membership_gne__c> new_members_map = triggerNewMap;
		
		//List to hold all relevant bureaus brought into the trigger
		Set<ID> bureaus_set = new Set<ID>();
		
		//set to hold all relevant members brought into the trigger
		set<id> members_set = new set<ID>();
		
		for(Speaker_Bureau_Membership_gne__c sb : triggerNewList){
			
			if((sb.Speaker_Bureau_ID_gne__c != old_members_map.get(sb.id).speaker_bureau_id_gne__c)){
				bureaus_set.add(sb.speaker_bureau_id_gne__c);  
				
			}	
			
			if((sb.bureau_member_gne__c != old_members_map.get(sb.id).bureau_member_gne__c)){
				members_set.add(sb.bureau_member_gne__c);   
			}               
		}
		
		checkDuplicates(bureaus_set,members_set,triggerNewList);
		 /*//List to hold all records to be inserted or updated
        List<Speaker_bureau_Membership_gne__c> members_to_ins_list = new List<Speaker_bureau_membership_gne__c>();
        
        //Loop through all records in the trigger and add the ones remaining in the 
        //bureaus_set to the members_to_ins_upd_list to be upserted
        for(Integer i=0;i<trigger.new.size();i++){
            if(bureaus_set.contains(trigger.new[i].speaker_bureau_id_gne__c)){
                members_to_ins_list.add(trigger.new[i]);
            }
        }           
        
        //upserts de-duped list of records
        update(members_to_ins_list);*/
		
		
	}
	
	
	//for insert triggers 
	public static void Speaker_Bureau_de_duplication(List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		
		///set to hold all relevant bureaus brought into the trigger
		Set<ID> bureaus_set = new Set<ID>();
		
		//set to hold all relevant members brought into the trigger
		set<id> members_set = new set<ID>();
		
		for(Speaker_Bureau_Membership_gne__c sb : triggerNewList){     
			bureaus_set.add(sb.Speaker_Bureau_ID_gne__c);
			members_set.add(sb.bureau_member_gne__c);
		} 
		
		
		system.debug('BUREAUS SET:'+bureaus_set);
		
		checkDuplicates(bureaus_set,members_set,triggerNewList);
	}
	
	
	public static void checkDuplicates(Set<ID> bureaus_set,Set<id> members_set,List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		//List of Existing Bureau Memberships 
		List<Speaker_Bureau_Membership_gne__c> existing_memberships = [Select s.Speaker_Bureau_ID_gne__c, 
		s.Bureau_Member_gne__c,s.Speaker_Bureau_ID_gne__r.Name, s.Bureau_Member_gne__r.Name From Speaker_Bureau_Membership_gne__c s where s.Speaker_Bureau_ID_gne__c IN :bureaus_set
		AND s.Bureau_Member_gne__c IN :members_set];                
		
		//Loop through existing memberships and the previously created bureaus_set
		//and remove from the matching element from the bureaus_set when a dupe is found    
		for(Speaker_Bureau_Membership_gne__c sb : existing_memberships){
			for(Speaker_Bureau_Membership_gne__c sbm :triggerNewList){                
				if((sb.speaker_bureau_id_gne__c == sbm.speaker_bureau_id_gne__c) && 
						(sb.bureau_member_gne__c == sbm.bureau_member_gne__c)){
					bureaus_set.remove(sbm.speaker_bureau_id_gne__c);                   
					sbm.addError('Cannot Insert Duplicate Speaker Bureau Memberships');
				}
			}                           
		} 
	}
	
	public static void checkStatusChanges(List<Speaker_Bureau_Membership_gne__c> triggerNewList,Map<ID,Speaker_Bureau_Membership_gne__c> triggerOldMap,Map<ID,Speaker_Bureau_Membership_gne__c> triggerNewMap){	
		
		Map<String, Set<String>> possibleStatusChanges = new Map<String, Set<String>>();
		possibleStatusChanges.put('', new Set<String>{'Pending', 'Rejected', 'Nominated'});
		possibleStatusChanges.put('Nominated', new Set<String>{'Approved', 'Removed', 'Excluded'});
		possibleStatusChanges.put('Approved', new Set<String>{'Removed', 'Excluded'});
		possibleStatusChanges.put('Removed', new Set<String>{'Approved', 'Excluded'});
		possibleStatusChanges.put('Excluded', new Set<String>{'Approved', 'Removed', 'Nominated'});
		possibleStatusChanges.put('Rejected', new Set<String>{'Nominated', 'Pending', 'Excluded'});
		possibleStatusChanges.put('Pending', new Set<String>{'Nominated', 'Excluded'});

        takeSnapshotClassificationAndExclusion(triggerNewList);

		for(Speaker_Bureau_Membership_gne__c sbm :triggerNewList){
			Id mapKey = sbm.Id;
			String oldStatus = triggerOldMap.get(mapKey).Speaker_Status_gne__c;
			String newStatus = triggerNewMap.get(mapKey).Speaker_Status_gne__c;
			if(oldStatus != newStatus && !possibleStatusChanges.get(oldStatus).contains(newStatus)){
				sbm.addError('You cannot change Membership Status from ' + oldStatus + ' to ' + newStatus);
			}
		}
	}

    public static void takeSnapshotClassificationAndExclusion(List<Speaker_Bureau_Membership_gne__c> triggerNew) {
    	if(triggerNew == null)
    		return;

    	Map<Id, Account> accounts = retrieveAccounts(triggerNew);
    	Map<ID, Speaker_Bureau_gne__c> speakerBureaus = retrieveBureaus(triggerNew);
       	
   		for (Speaker_Bureau_Membership_gne__c sbm : triggerNew) {
			if (sbm.Speaker_Status_gne__c == 'Nominated') {

                if (accounts.get(sbm.Bureau_Member_gne__c) != null && speakerBureaus.get(sbm.Speaker_Bureau_ID_gne__c) != null) {

                    if (sbm.Current_Speaker_Scope_gne__c == null || sbm.Current_Speaker_Scope_gne__c == 'Not Classified') {

                    	if(speakerBureaus.get(sbm.Speaker_Bureau_ID_gne__c).Speaker_Bureau_Type_gne__c == 'Clinical'){
	      		            sbm.Current_Speaker_Scope_gne__c = accounts.get(sbm.Bureau_Member_gne__c).EDM_Clinical_Classification_gne__c;
	                        sbm.Current_Speaker_Scope_Date_gne__c = accounts.get(sbm.Bureau_Member_gne__c).EDM_Clinical_Classification_Date_gne__c;
                    	}
	                    if (speakerBureaus.get(sbm.Speaker_Bureau_ID_gne__c).Speaker_Bureau_Type_gne__c == 'Business') {
	             			sbm.Current_Speaker_Scope_gne__c = accounts.get(sbm.Bureau_Member_gne__c).EDM_Business_Classification_gne__c;
	                        sbm.Current_Speaker_Scope_Date_gne__c = accounts.get(sbm.Bureau_Member_gne__c).EDM_Business_Classification_Date_gne__c;
	                    }
                    }
                    if (sbm.Current_Exclusion_Status_gne__c == null) {
      		              sbm.Current_Exclusion_Status_gne__c = accounts.get(sbm.Bureau_Member_gne__c).AGS_EX_Exclusion_Status_gne__c;

                        if (accounts.get(sbm.Bureau_Member_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Request Pending' || 
                            accounts.get(sbm.Bureau_Member_gne__c).AGS_EX_Exclusion_Status_gne__c == 'In Process') {
                               
                            List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate 
                                                                                    FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                    WHERE 
                                                                                    (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
                                                                                  AND AGS_EX_Account_Name_gne__c = :accounts.get(sbm.Bureau_Member_gne__c).Id];
                            if(!existingExclusionRequests.isEmpty()) {
                                DateTime dT = existingExclusionRequests[0].CreatedDate;                  
                                sbm.Current_Exclusion_Status_Date_gne__c = Date.newInstance(dT.year(), dT.month(), dT.day());                                
                            } else {
                                sbm.Current_Exclusion_Status_Date_gne__c = accounts.get(sbm.Bureau_Member_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;
                            }                                                                                                              
                        } else {
                            sbm.Current_Exclusion_Status_Date_gne__c = accounts.get(sbm.Bureau_Member_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;               
                        }
                    }
                }
        	}
    	}
	}
    
    private static Map<Id, Account> retrieveAccounts(List<Speaker_Bureau_Membership_gne__c> triggerNew) {
        Set<Id> hcpIds = new Set<Id>();
        for (Speaker_Bureau_Membership_gne__c sbm : triggerNew) {
            hcpIds.add(sbm.Bureau_Member_gne__c);
        }
        Map<Id, Account> result = new Map<Id, Account>([SELECT EDM_Business_Classification_gne__c, EDM_Business_Classification_Date_gne__c,
                                                EDM_Clinical_Classification_gne__c, EDM_Clinical_Classification_Date_gne__c,
                                                AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c
                                      FROM Account 
                                      WHERE id IN :hcpIds ]); 

        return result;
    }

    private static Map<Id, Speaker_Bureau_gne__c> retrieveBureaus(List<Speaker_Bureau_Membership_gne__c> triggerNew) {
        Set<Id> bureausIds = new Set<Id>();
        for (Speaker_Bureau_Membership_gne__c sbm : triggerNew) {
            bureausIds.add(sbm.Speaker_Bureau_ID_gne__c);
        }
        Map<Id, Speaker_Bureau_gne__c> result = new Map<Id, Speaker_Bureau_gne__c>([SELECT Speaker_Bureau_Type_gne__c
                                      FROM Speaker_Bureau_gne__c 
                                      WHERE id IN :bureausIds ]); 

        return result;
    }
}