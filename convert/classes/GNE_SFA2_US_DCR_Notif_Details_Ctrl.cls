public with sharing class GNE_SFA2_US_DCR_Notif_Details_Ctrl {

	public String dcrId { get; set; }

    private Change_Request_gne__c changeRequest {get; set;}
    private Address_vod__c primaryAccountAddress {get; set;}

	public GNE_SFA2_US_DCR_Notif_Details_Ctrl() {
	}

	public Change_Request_gne__c getChangeRequest() {
		if (changeRequest == NULL) {
			changeRequest = [SELECT Id, License_State_gne__c, License_Number_gne__c,HCP_National_Provider_Id_gne__c,
							 Account_gne__c, Account_gne__r.Name 
							 FROM Change_Request_gne__c WHERE Id = :dcrId];
		}

		return changeRequest;
	}

	public Address_vod__c getPrimaryAccountAddress() {
		if (primaryAccountAddress == NULL) {
			primaryAccountAddress = [
					SELECT Id, Name, Address_line_2_vod__c, City_vod__c, Country_gen__c, Postal_Code_can_gne__c, Province_can_gne__c
					FROM Address_vod__c
					WHERE Account_vod__c = :getChangeRequest().Account_gne__c AND Primary_vod__c = true];
		}

		return primaryAccountAddress;
	}
	
}