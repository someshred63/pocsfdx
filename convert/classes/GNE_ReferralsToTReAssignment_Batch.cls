/************************************************************
*  @author: Lukasz Bieniawski
*  Date: 2012-08-31
*  Description: This is a batch process used for re-assign referrals
*  binded to other MSL users, when the MSL's Time Off Territory period ends
*  Modification History
*  Date        Name        Description
*************************************************************/

global class GNE_ReferralsToTReAssignment_Batch implements Database.Batchable<Sobject>, Database.Stateful  {
	
	// AssignedUser, OwnerUser
	private Map<ID, ID> mapOfAssignment = null;
	
	public GNE_ReferralsToTReAssignment_Batch(){}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('GNE_ReferralsToTReAssignment_Batch started.');
		
		AggregateResult[] totdList = [Select Time_Off_Territory_gne__r.Assigned_Referral_Activity_gne__r.ID aID, Time_Off_Territory_gne__r.OwnerID oID	
			From Time_off_Territory_Day_gne__c Group by Time_Off_Territory_gne__r.OwnerID, Time_Off_Territory_gne__r.Assigned_Referral_Activity_gne__r.ID
			HAVING Time_Off_Territory_gne__r.Assigned_Referral_Activity_gne__r.ID <> null and MAX(Date_gne__c) = YESTERDAY];
		
		mapOfAssignment = new Map<ID, ID>();
		
		if (totdList != null && totdList.Size() != 0){
			System.debug('totdListSize: ' + totdList.Size());
			for (AggregateResult totd : totdList){
				mapOfAssignment.put((ID)totd.get('aID'), (ID)totd.get('oID'));
			}
			System.debug('MapOfAssignmentKeySets: ' + mapOfAssignment.keySet());
		}
		 
		return Database.getQueryLocator([Select Id, Assigned_To_gne__c, Medical_Request_gne__c,
											Medical_Request_gne__r.Referral_History_gne__c
										From Referral_Assignment_gne__c
										Where Status_Referral_gne__c IN ('Assigned','Acknowledged') AND 
											  Assigned_To_gne__c in :mapOfAssignment.keySet()]);
	}
	
	global void execute(Database.BatchableContext BC, List<Sobject> scope){
		if (scope != null){
			List<Referral_Assignment_gne__c> listToUpdate = new List<Referral_Assignment_gne__c>();
			List<Medical_Communication_gne__c> mcListToUpdate = new List<Medical_Communication_gne__c>();
			Map<Id, String> referralToPrevUsers = new Map<Id, String>();
			for (Sobject scopeItem : scope){
				Referral_Assignment_gne__c referralAssignment = (Referral_Assignment_gne__c)scopeItem;
				String previousAssignedUser = GNE_Referral_Utils.getPreviousAssignedUserId(referralAssignment);
				System.debug('previousAssignedUser: ' + previousAssignedUser);
				ID currentAssignedUser = referralAssignment.Assigned_To_gne__c;
				System.debug('currentAssignedUser: ' + currentAssignedUser);
				ID ownerFromMap = mapOfAssignment.get(currentAssignedUser);
				System.debug('ownerFromMap: ' + ownerFromMap);
				
				if (previousAssignedUser != null && previousAssignedUser.equals((String)mapOfAssignment.get(currentAssignedUser))){
					referralToPrevUsers.put(referralAssignment.Id, previousAssignedUser);
				}
			}
			
			Map<Id,User> userIDToNameAndProfile = new Map<Id,User>([SELECT Id, Name, Profile_Name_gne__c 
																	FROM User 
																	WHERE Id IN :referralToPrevUsers.values()]); 
			
			for (Sobject scopeItem : scope){
				Referral_Assignment_gne__c referralAssignment = (Referral_Assignment_gne__c)scopeItem;
				if(referralToPrevUsers.containsKey(referralAssignment.Id)) {
					String previousAssignedUser = referralToPrevUsers.get(referralAssignment.Id);
					referralAssignment.Assigned_To_gne__c = previousAssignedUser;
					listToUpdate.Add(referralAssignment);
					
					User prevUser = userIDToNameAndProfile.get((ID)previousAssignedUser);
					String historyText = referralAssignment.Medical_Request_gne__r.Referral_History_gne__c +
												GNE_Referral_Utils.createHistoryInfo( 
                    								  		GNE_Referral_Utils.strReassigned,
                    								  		prevUser.Name, prevUser.Id, prevUser.Profile_Name_gne__c);
					mcListToUpdate.add(new Medical_Communication_gne__c(
									Id = referralAssignment.Medical_Request_gne__c,
									Referral_History_gne__c = historyText));
					
				}
			}
			
			System.debug('ReferralAssignmentsToUpdate: ' + listToUpdate.Size());
			if (listToUpdate.Size() > 0){				
				update listToUpdate;	
			}
			
			if (mcListToUpdate.Size() > 0){				
				update mcListToUpdate;	
			}
		}
	}
	
	global void finish(Database.BatchableContext BC){
		System.debug('GNE_ReferralsToTReAssignment_Batch finished.');
	}
}