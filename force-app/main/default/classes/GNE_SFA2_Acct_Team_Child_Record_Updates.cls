/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-08
*  Description: This is a trigger for handling Account Team child record updates
*  Test class: GNE_SFA2_Account_Team_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Acct_Team_Child_Record_Updates {
	
	private static void deleteTeamMemberAccountShares(List<Account_Team_gne__c> triggerOld) {
		List<Sharing_Mgmt_gne__c> shareMgmtToInsert = new List<Sharing_Mgmt_gne__c>();
		for(Account_Team_gne__c accountTeam : triggerOld) {
			if(accountTeam.Team_Member_gne__c != null){
				Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c();
				shareMgmt.Object_Name_gne__c = 'AccountShare';
				shareMgmt.Status_gne__c = 'New';
				shareMgmt.Operation_gne__c = 'Delete';
				shareMgmt.Opportunity_Access_Level_gne__c = 'None';
				shareMgmt.Case_Access_Level_gne__c = 'None';
				shareMgmt.Schedule_Date_Time_gne__c = System.today();
				shareMgmt.Account_Id_gne__c = accountTeam.Account_gne__c;
				shareMgmt.User_Id_gne__c = accountTeam.Team_Member_gne__c;
				if(accountTeam.Account_Access_gne__c == 'Read/ Write') {
		        	shareMgmt.Account_Access_Level_gne__c = 'Edit';
		        } else if(accountTeam.Account_Access_gne__c == 'Read Only') {
		            shareMgmt.Account_Access_Level_gne__c = 'Read';
		        }
				shareMgmtToInsert.add(shareMgmt);
			}
		}
		insert shareMgmtToInsert;
	}
	
	private static void addTeamMemberAccountShares(List<Account_Team_gne__c> triggerNew) {
		List<Sharing_Mgmt_gne__c> shareMgmtToInsert = new List<Sharing_Mgmt_gne__c>();
		for(Account_Team_gne__c accountTeam : triggerNew) {
			if(accountTeam.Team_Member_gne__c != null){
				Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c();
				shareMgmt.Object_Name_gne__c = 'AccountShare';
				shareMgmt.Status_gne__c = 'New';
				shareMgmt.Operation_gne__c = 'Insert';
				shareMgmt.Opportunity_Access_Level_gne__c = 'None';
				shareMgmt.Case_Access_Level_gne__c = 'None';
				shareMgmt.Schedule_Date_Time_gne__c = System.today();
				shareMgmt.Account_Id_gne__c = accountTeam.Account_gne__c;
				shareMgmt.User_Id_gne__c = accountTeam.Team_Member_gne__c;
				if(accountTeam.Account_Access_gne__c == 'Read/ Write') {
	                shareMgmt.Account_Access_Level_gne__c = 'Edit';
	            } else if(accountTeam.Account_Access_gne__c == 'Read Only') {
	                shareMgmt.Account_Access_Level_gne__c = 'Read';
	            }
				shareMgmtToInsert.add(shareMgmt);
			}
		}
		
		insert shareMgmtToInsert;
	}
	
	private static void updateTeamMemberAccountShares(List<Account_Team_gne__c> triggerOld, Map<Id, Account_Team_gne__c> triggerNewMap) {
		List<Account_Team_gne__c> changedAccountTeams = new List<Account_Team_gne__c>();
		Set<Id> accountIds = new Set<Id>();
		Set<Id> teamMemberIds = new Set<Id>();
		
		 List<Sharing_Mgmt_gne__c> shareMgmtToInsert = new List<Sharing_Mgmt_gne__c>();
        for(Integer i = 0; i < triggerOld.size(); i++) {
        	if (triggerOld[i].Team_Member_gne__c != triggerNewMap.get(triggerOld[i].Id).Team_Member_gne__c ||
                triggerOld[i].Account_Access_gne__c != triggerNewMap.get(triggerOld[i].Id).Account_Access_gne__c) {
                
                changedAccountTeams.add(triggerOld[i]);
                system.debug('pp>>trigOld: ' + triggerOld);
                if(triggerOld[i].Team_Member_gne__c != null){
	                Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c();
					shareMgmt.Object_Name_gne__c = 'AccountShare';
					shareMgmt.Status_gne__c = 'New';
					shareMgmt.Operation_gne__c = 'Delete';
					shareMgmt.Opportunity_Access_Level_gne__c = 'None';
					shareMgmt.Case_Access_Level_gne__c = 'None';
					shareMgmt.Schedule_Date_Time_gne__c = System.today();
					shareMgmt.Account_Id_gne__c = triggerOld[i].Account_gne__c;
					shareMgmt.User_Id_gne__c = triggerOld[i].Team_Member_gne__c;
					if(triggerOld[i].Account_Access_gne__c == 'Read/ Write') {
		                shareMgmt.Account_Access_Level_gne__c = 'Edit';
		            } else if(triggerOld[i].Account_Access_gne__c == 'Read Only') {
		                shareMgmt.Account_Access_Level_gne__c = 'Read';
		            }
					shareMgmtToInsert.add(shareMgmt);
				}
	        }
        }
        insert shareMgmtToInsert;
        
        shareMgmtToInsert = new List<Sharing_Mgmt_gne__c>();
        for(Account_Team_gne__c accountTeam : changedAccountTeams) {
        	if(triggerNewMap.get(accountTeam.Id).Team_Member_gne__c != null){
				Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c();
				shareMgmt.Object_Name_gne__c = 'AccountShare';
				shareMgmt.Status_gne__c = 'New';
				shareMgmt.Operation_gne__c = 'Insert';
				shareMgmt.Opportunity_Access_Level_gne__c = 'None';
				shareMgmt.Case_Access_Level_gne__c = 'None';
				shareMgmt.Schedule_Date_Time_gne__c = System.today();
				shareMgmt.Account_Id_gne__c = triggerNewMap.get(accountTeam.Id).Account_gne__c;
				shareMgmt.User_Id_gne__c = triggerNewMap.get(accountTeam.Id).Team_Member_gne__c;
				if(accountTeam.Account_Access_gne__c == 'Read/ Write') {
	                shareMgmt.Account_Access_Level_gne__c = 'Edit';
	            } else if(accountTeam.Account_Access_gne__c == 'Read Only') {
	                shareMgmt.Account_Access_Level_gne__c = 'Read';
	            }
				shareMgmtToInsert.add(shareMgmt);
			}
		}
		
		insert shareMgmtToInsert;
	}
	
	public static void onAfterInsert(List<Account_Team_gne__c> triggerNew) {
		addTeamMemberAccountShares(triggerNew);
	}
	
	public static void onAfterUpdate(List<Account_Team_gne__c> triggerOld, Map<Id, Account_Team_gne__c> triggerNewMap) {
		updateTeamMemberAccountShares(triggerOld, triggerNewMap);
	}
	
	public static void onAfterDelete(List<Account_Team_gne__c> triggerOld) {
		deleteTeamMemberAccountShares(triggerOld);
	}
}