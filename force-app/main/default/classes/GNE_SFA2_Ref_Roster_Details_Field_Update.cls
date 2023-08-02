/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/7/2013
*  Description: This class GNE_SFA2_Ref_Roster_Details_Field_Update handles field updates on Referral_Roster_Detail_gne__c object on DML operations
*  This class is being used in GNE_SFA2_Referral_Roster_Details_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Ref_Roster_Details_Field_Update {
		// On Before insert method
	public static void OnBeforeInsert (Map<Id,Referral_Roster_Detail_gne__c> oldRRDMap,  List<Referral_Roster_Detail_gne__c> newRRDList){
		updateRefRosterOnDelete(oldRRDMap, newRRDList, true);
	}
	// On Before Delete method
	public static void OnBeforeDelete(Map<Id,Referral_Roster_Detail_gne__c> oldRRDMap,  List<Referral_Roster_Detail_gne__c> newRRDList){
		updateRefRosterOnDelete(oldRRDMap, newRRDList, false);
	}
	/*
    This trigger updates Referral Roster datetime stamp whenever the Referral Roster detail record is deleted or updated.
    This functionality is to ensure that the MSL Roster lookup web service(sfdc) for OTR sends the correct data for Delta loads

    */
    //implemented based on trigger UpdateReferralRoster on Referral_Roster_Detail_gne__c (before delete, before insert) 
	private static void updateRefRosterOnDelete(Map<id, Referral_Roster_Detail_gne__c> oldRefRosterDetMap, 
												List<Referral_Roster_Detail_gne__c> newRefRosterDetList, boolean isInsert){
        List<Referral_Roster_Detail_gne__c> refRosterList= isInsert ? newRefRosterDetList : oldRefRosterDetMap.values();
        set<Id> RefDetIds = new set<Id>();
        for(Referral_Roster_Detail_gne__c rr : refRosterList){
            RefDetIds.add(rr.Referral_Roster_gne__c);
        }
        if(RefDetIds!=null && RefDetIds.size()>0){
            List<Referral_Roster_gne__c> lstRefRoster = [Select Id from Referral_Roster_gne__c where Id IN :RefDetIds ];
            if(lstRefRoster!=null && lstRefRoster.size()>0){
            	update lstRefRoster;
            }
        }
	}
}