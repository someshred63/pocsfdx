/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-23
*  Description: This is a helper class for GNE_SFA2_SharingMgmt_Trigger
*  Test class: GNE_SFA2_SharingMgmt_Trigger_Test
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_SharingMgmt_Trigger_Helper {

	/**
	*	Temporary future method used for creating sharing management records on insertion of AccountShares on
	*	Account page through Territory Alignment S-control
	*/
	@future
	public static void insertSharingMgmtInsertRecord(String territoryId, String accountId, String recordId) {
		Account acc = [ SELECT MDMID_gne__c FROM Account WHERE Id = :accountId LIMIT 1 ];
		Territory2 terr = [ SELECT Name FROM Territory2 WHERE Id = :territoryId LIMIT 1 ];
		Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c(Object_Name_gne__c = 'AccountShare', Account_Id_gne__c = accountId, Territory_Name_gne__c = terr.Name, Record_Id_gne__c = recordId,
			External_Id_gne__c = acc.MDMID_gne__c, Operation_gne__c = 'Insert', Territory_Id_gne__c = territoryId, Status_gne__c = 'Completed', Schedule_Date_Time_gne__c = System.today());

		insert shareMgmt;
	}

	/**
	*	Temporary future method used for creating sharing management records on deletion of AccountShares on
	*	Account page through Territory Alignment S-control
	*/
	@future
	public static void insertSharingMgmtDeleteRecord(String territoryId, String accountId, String recordId) {
		Account acc = [ SELECT MDMID_gne__c FROM Account WHERE Id = :accountId LIMIT 1 ];
		Territory2 terr = [ SELECT Name FROM Territory2 WHERE Id = :territoryId LIMIT 1 ];
		Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c(Object_Name_gne__c = 'AccountShare', Account_Id_gne__c = accountId, Territory_Name_gne__c = terr.Name, Record_Id_gne__c = recordId,
			External_Id_gne__c = acc.MDMID_gne__c, Operation_gne__c = 'Delete', Territory_Id_gne__c = territoryId, Status_gne__c = 'Completed', Schedule_Date_Time_gne__c = System.today());

		insert shareMgmt;
	}
}