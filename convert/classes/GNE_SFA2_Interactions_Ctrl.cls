public with sharing class GNE_SFA2_Interactions_Ctrl {

    public String systemTime {get; private set;}

    public GNE_SFA2_Interactions_Ctrl() {
        systemTime = String.valueOf(System.now());
    }

    public List<Call2_vod__c> getRecords() {
		List<Id> accountIds = getUserAccounts();
		return [SELECT Id, Name, Account_vod__c, Account_vod__r.Name, Purpose_of_Meeting_gne__c, Call_Datetime_vod__c, Call_Status_calc_gne__c, Interaction_Status_gne__c,
		          (SELECT Id, Name, Account_vod__c, Account_vod__r.Name FROM Call2_vod__r WHERE Account_vod__c <> null ORDER BY Account_vod__r.Name)
		        FROM Call2_vod__c
		        WHERE Account_vod__c IN : accountIds
		        	AND Call_Datetime_vod__c >= LAST_90_DAYS
                	AND Call_Datetime_vod__c <= NEXT_90_DAYS
                	AND Parent_Call_vod__c = null
                ORDER BY Call_Datetime_vod__c DESC
                LIMIT 1000];
	}

	private List<Id> getUserAccounts() {
		List<Id> result = new List<Id>();

		List<String> territoriesName = new List<String>();
		for(Territory2 t : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
			territoriesName.add(t.Name);
		}

		return new List<Id>(new Map<Id,Account>([SELECT Id FROM Account WHERE IsPersonAccount = true AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :territoriesName AND Address_vod__c <> null) ORDER BY LastName, FirstName LIMIT 40000]).keySet());
	}

	@RemoteAction
    public static Map<String, String> editRecord(String recordId) {
        Map<String, String> result = new Map<String, String>();
        String userId = UserInfo.getUserId();

        // Check if user has access to edit record
        result.put('recordId', recordId);
        result.put('isEditable', String.valueOf([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId LIMIT 1].HasEditAccess));

        return result;
    }

	@RemoteAction
    public static Map<String,String> deleteRecord(String recordId) {
        Map<String, String> result = new Map<String, String>();

        SObject record = Database.query('SELECT Id FROM Call2_vod__c WHERE Id =: recordId LIMIT 1');

        try {
            delete record;
            result.put('isDeleted', 'true');
            result.put('recordId', recordId);
        } catch (System.DmlException e) {
            result.put('isDeleted', 'false');
            result.put('recordId', recordId);
            result.put('exception', e.getDmlMessage(0));
        }

        return result;
    }

}