public without sharing class EDM_Spend_Utils {

	public static List<EDM_Spend_gne__c> retrieveEDMSpend(ID parentIABPId) {
		//without sharing to retrieve CreatedBy.Name, CreatedBy.Email, LastModifiedBy.Name, LastModifiedBy.Email
		//for portal user EDM VDST Partner External ABM
		return [SELECT Id, EDM_Non_HCP_Fees_gne__c, EDM_Non_HCP_Hotel_gne__c,
					EDM_Non_HCP_Meals_gne__c, EDM_Non_HCP_Travel_gne__c,
					EDM_Non_HCP_Total_gne__c, EDM_Spend_Status_gne__c,
					EDM_Spend_Comments_gne__c, EDM_Cancellation_Type_gne__c,
					CreatedBy.Name, CreatedBy.Email, CreatedDate,
					LastModifiedBy.Name, LastModifiedBy.Email, LastModifiedDate,
					EDM_Audio_Video_gne__c
				FROM EDM_Spend_gne__c
				WHERE EDM_Parent_IABP_gne__c = :parentIABPId];
	}

	public static List<Account> getAccountsWithAddressAndLicensesAndAffiliation(Id accountId) {
		return getAccountsWithAddressAndLicensesAndAffiliation(new Set<Id> {accountId});
	}

	public static List<Account> getAccountsWithAddressAndLicensesAndAffiliation(Set<Id> accountIds) {
		return [SELECT Id, Name, FirstName, LastName, Middle_gne__c, Suffix_vod__c, Credentials_gne__c, Professional_Type_gne__c, NPI_vod__c,
					MDMID_gne__c, EDM_Clinical_Classification_gne__c, EDM_Business_Classification_gne__c, Phone,
					(SELECT Id, Name, City_vod__c, Country_gen__c, State_vod__c, Zip_vod__c, Address_line_2_vod__c, Email_gne__c, DEA_vod__c 
					 FROM Address_vod__r ORDER BY Primary_vod__c DESC),
					(SELECT Id, To_Account_vod__c, To_Account_vod__r.Name, Primary_gne__c, LastModifiedDate 
						FROM Affiliation_vod__r ORDER BY Primary_gne__c DESC, LastModifiedDate DESC LIMIT 1)
				FROM Account
				WHERE Id in :accountIds];
	}

	public static List<CORE_Pub_License__c> getLicenses(Account acc) {
		Map<String, List<CORE_Pub_License__c>> licensesByMdmId = getLicensesByMdmId(new Set<String> {acc.MDMID_gne__c});

		return licensesByMdmId.get(acc.MDMID_gne__c);
	}

	public static Map<String, List<CORE_Pub_License__c>> getLicensesByMdmId(Set<String> mdmIds) {
		Map<String, List<CORE_Pub_License__c>> results = new Map<String, List<CORE_Pub_License__c>>();
		System.debug('getLicensesByMdmId: ' + mdmIds);

		//add empty List for every item in mdmIds to avoid return null list when there is no licenses for given account
		for (String mdmId : mdmIds) {
			results.put(mdmId, new List<CORE_Pub_License__c>());
		}

		mdmIds.remove(null);

		for (CORE_Pub_License__c license : [
				SELECT Id, License_Number_gne__c, License_State_gne__c, Party_Id_ref_gne__r.Mdm_Id_gne__c
				FROM CORE_Pub_License__c 
				WHERE Party_Id_ref_gne__r.Mdm_Id_gne__c in :mdmIds]) {
			if (results.containsKey(license.Party_Id_ref_gne__r.Mdm_Id_gne__c)) {
				results.get(license.Party_Id_ref_gne__r.Mdm_Id_gne__c).add(license);
			}
		}

		return results;
	}


	public static List<EDM_Attendee_gne__c> getAttendees(String attendeeId) {
		return getAttendees(new Set<Id> {attendeeId});
	}

	public static List<EDM_Attendee_gne__c> getAttendees(Set<Id>  attendeeIds) {
		return [SELECT Id, EDM_Account_gne__c, EDM_System_Type_gne__c, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, 
					LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedBy.Email,
					EDM_Role_gne__c 
				FROM EDM_Attendee_gne__c
				WHERE Id = :attendeeIds];
	}
}