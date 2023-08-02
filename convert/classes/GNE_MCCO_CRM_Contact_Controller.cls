public without sharing class GNE_MCCO_CRM_Contact_Controller extends GNE_MCCO_CRM_Base_Ctrl {

    public static final String ACCT_PREFIX = '001';
    public String iconBase64 {get; private set;}
    private transient Id accountId;
    private transient Account account;
    public transient Boolean newModeWithoutRecord;

    public GNE_MCCO_CRM_Contact_Controller(ApexPages.StandardController sctrl) {
        this();
    }

    public GNE_MCCO_CRM_Contact_Controller() {
        super();
        iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('Contact_Tab_Icon');
    }

    public override GNE_MCCO_CRM_Base_Ctrl.DataWrapper init(Map<String, String> params) {
        newModeWithoutRecord = !params.containsKey('accountId');
        return super.init(params);
    }

    public override GNE_MCCO_CRM_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
        this.params = params.clone();
        return super.intInit(this.params);
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper initNewMode() {
        this.params.put('sObjectType', 'Contact');
        return super.initNewMode();
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper getDataWrapper(GNE_MCCO_CRM_Base_Ctrl.DataWrapper dataWrapper) {
        DataWrapper result = (DataWrapper)super.getDataWrapper(dataWrapper);
        // General
        Contact contact = (Contact)record;

        if (String.isNotBlank(contact.Id)) {
            result.contactName = contact.Name;
            result.contactPhoto = contact.Photo_gne__c;
            result.contactId = contact.Id;
            result.createdDate = contact.CreatedDate;
            result.lastModifiedDate = contact.LastModifiedDate;
/*
            result.otherTitle = contact.Title;
            result.otherFunction = contact.Function_Other_gne__c;
*/
        }
        result.accountId = accountId;

        return result;
    }

    protected override SObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        account = null;

        if (String.isBlank(recordId)) {
            if (!newModeWithoutRecord) {
                accountId = checkInputParam('accountId');
            }
        }

        if (String.isNotBlank(accountId)) {
            account = [
                          SELECT Id, Name
                          FROM Account WHERE Id = :accountId
                      ];
        }

        Contact contact = (Contact)super.getRecord(configObjects);

        if (account != null) {
            contact.AccountId = account.Id;
            contact.Account = account;
        }

        if (contact.Id == null) {
            contact.Active_gne__c = true;
			
        String profileName = [ SELECT Id, Name from Profile WHERE Id = :UserInfo.getProfileId() ].Name;
        if (profileName.contains('340B')) {
            contact.X340B_Contact__c = true;
            }
        }

        if(String.isNotBlank(contact.AccountId) && String.isBlank(accountId)){
			accountId = contact.AccountId;
        }

        return contact;
    }

    protected override String checkInputParam(String paramName) {
        String result = super.checkInputParam(paramName);

        if (paramName == 'accountId') {
            try {
                Id.valueOf(result);
            } catch (Exception e) {
                throw createException(new GNE_MCCO_CRM_Base_Ctrl.WrongInputParamTypeErrorException(), new Object[] {paramName, result, 'Id'});
            }
        }

        return result;
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper intSaveRecord() {
        return super.intSaveRecord();
    }

    public GNE_MCCO_CRM_Base_Ctrl.DataWrapper saveContactRecord(String inputDataWrapperInJSON) {
        dataWrapper = getDataWrapperInstance();
        this.inputDataWrapper = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, GNE_MCCO_CRM_Contact_Controller.DataWrapper.class);
        return super.intSaveRecord();
    }

    public void setInputDataWrapper(String inputDataWrapperInJSON) {
        this.inputDataWrapper = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, GNE_MCCO_CRM_Contact_Controller.DataWrapper.class);
    }

    public GNE_MCCO_CRM_Base_Ctrl.DataWrapper getInputDataWrapper(){
        return this.inputDataWrapper;
    }

    public void setDataWrapper(DataWrapper dw) {
        this.dataWrapper = dw;
    }


    public class DataWrapper extends GNE_MCCO_CRM_Base_Ctrl.DataWrapper {
        private String contactName;
        private String contactPhoto;
        public String contactId;
        private Datetime createdDate;
        private Datetime lastModifiedDate;
        private String otherTitle;
        private String otherFunction;
        private Id accountId;

        public DataWrapper(Boolean isExternalMode) {
          super();
        }

        private DataWrapper() {}
    }

    @RemoteAction @ReadOnly
    public static DataWrapper initViewModuleData(Map<String, String> params) {
        return (DataWrapper)(new GNE_MCCO_CRM_Contact_Controller()).init(params);
    }

    @RemoteAction @ReadOnly
    public static DataWrapper initNewEditModuleData(Map<String, String> params) {
        return (DataWrapper)(new GNE_MCCO_CRM_Contact_Controller()).init(params);
    }

    @RemoteAction
    public static DataWrapper saveRecord(Map<String, String> params) {
    	DataWrapper dw = (DataWrapper)JSON.deserialize(params.get('saveData'), DataWrapper.class);
		String firstName;
		String lastName;
		String contactId;
		String accountId;
		for(Field f : dw.inputFields){
			if(f.name.equalsIgnoreCase('firstname')){
				firstName = (String)f.getValue();
			} else if (f.name.equalsIgnoreCase('lastname')){
				lastName = (String)f.getValue();
			} else if (f.name.equalsIgnoreCase('contactId')){
				contactId = (String)f.getValue();
			} else if (f.name.equalsIgnoreCase('accountId')){
				accountId = (String)f.getValue();
			}
		}
		if(String.isEmpty(contactId) ){
    		Contact existingContact = iPhone_DAO.getContactByFirstAndLastName(firstName, lastName, accountId);
			if(existingContact != null) {
				dw.contactId = existingContact.Id;
				dw.recordDescribe.recordId = existingContact.Id;
			}
		}
        return (DataWrapper)(new GNE_MCCO_CRM_Contact_Controller()).saveRecord(dw, (Map<String, String>)JSON.deserialize(params.get('extraFields'), Map<String, String>.class));
    }

    @RemoteAction @ReadOnly
    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchAccounts (Map<String, String> params) {
        return GNE_SFA2_SearchAccounts_Controller.searchHCOs(params.get('searchValue'), Integer.valueOf(params.get('recordLimit')), false);
    }

    @RemoteAction @ReadOnly
    public static SearchContactWrapper searchContacts (Map<String, String> params) {
        String accountIds = '';
        if (String.isEmpty(params.get('accountIds'))) {
            accountIds = getAccounts(getUserTerritories(UserInfo.getUserId()));
        } else {
            accountIds = params.get('accountIds');
        }

        List<String> acctIds = new List<String>();
        if (String.isNotEmpty(accountIds)) {
            for (String s : accountIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0, 1) + '0000' + s.substring(1));
            }
        }

        String query = 'SELECT Id, Name, Developer_Title_gne__c, Account.Name, Email FROM Contact WHERE Name Like \'' + params.get('searchValue') + '\' AND Active_gne__c = true and IsPersonAccount = false AND';

        if (String.isNotEmpty(params.get('selectedContact'))) {
            query += ' (AccountId IN : acctIds OR Id = \'' + params.get('selectedContact') + '\')';
        } else {
            query += ' AccountId IN : acctIds';
        }

        query += ' LIMIT 50';
        System.debug('##### Query ' + query);

        return new SearchContactWrapper(accountIds, Database.query(query));
    }

    @RemoteAction @ReadOnly
    public static List<SearchUserWrapper> searchUsers (Map<String, String> params) {
        List<SearchUserWrapper> result = new List<SearchUserWrapper>();
        String query = 'SELECT Id, Name, Email, SmallPhotoUrl FROM User WHERE Name Like \'' + params.get('searchValue') + '\' AND IsActive = true ORDER BY Name';
        query += ' LIMIT 50';

        System.debug('##### Query ' + query);

        for (User u : Database.query(query)) {
            result.add(new SearchUserWrapper(u.Id, u.Name, u.Email, u.SmallPhotoUrl));
        }

        return result;
    }

    private static List<String> getUserTerritories(Id userId) {
        List<String> result = new List<String>();
        List<Territory2> territories = new List<Territory2>();
        List<Territory2> userTopTerritories = getUserTopTerritories(userId);
        if (!userTopTerritories.isEmpty()) {
            territories.addAll(userTopTerritories);
            getChildTerritories(userTopTerritories, territories);
        }

        for (Territory2 terr : territories) {
            result.add(terr.Name);
        }

        return result;
    }

    private static void getChildTerritories(List<Territory2> parentTerritories, List<Territory2> result) {
        List<Territory2> childrenTerritories = getChildrenTerritories(parentTerritories, result);
        if (!childrenTerritories.isEmpty()) {
            result.addAll(childrenTerritories);
            getChildTerritories(childrenTerritories, result);
        }
    }

    private static List<Territory2> getUserTopTerritories(Id userId) {
        return  [
                    SELECT
                    Id,
                    Name,
                    External_id_gne__c,
                    ParentTerritory2Id
                    FROM
                    Territory2
                    WHERE
                    Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = : userId)
                    ORDER BY Name
                ];
    }

    private static List<Territory2> getChildrenTerritories(List<Territory2> parentTerritories, List<Territory2> result) {
        return  [
                    SELECT
                    Id,
                    Name,
                    External_id_gne__c,
                    ParentTerritory2Id
                    FROM
                    Territory2
                    WHERE
                    ParentTerritory2Id IN : parentTerritories
                    ORDER BY ParentTerritory2Id
                ];
    }

    private static String getAccounts(List<String> territories) {
        String result = '';
        for (TSF_vod__c tsf : [SELECT Account_vod__c FROM TSF_vod__c WHERE External_Id_vod__c != null AND Address_vod__c != null AND Territory_vod__c IN : territories AND Account_vod__r.IsPersonAccount = false LIMIT 49000]) {
            String minAcctId = String.valueOf(tsf.Account_vod__c).substring(3, 4) + String.valueOf(tsf.Account_vod__c).substring(8, 18);
            if (!result.contains(minAcctId)) {
                result += minAcctId + ',';
            }
        }
        return result.removeEnd(',');
    }

    public class SearchContactWrapper {
        private String accountIds {get; set;}
        private List<Contact> contacts {get; set;}

        public SearchContactWrapper(String accountIds, List<Contact> contacts) {
            this.accountIds = accountIds;
            this.contacts = contacts;
        }
    }

    public class SearchUserWrapper {
        private Id userId {get; set;}
        private String userName {get; set;}
        private String userEmail {get; set;}
        private String smallPhotoUrl {get; set;}

        public SearchUserWrapper(Id userId, String userName, String userEmail, String smallPhotoUrl) {
            this.userId = userId;
            this.userName = userName;
            this.userEmail = userEmail;
            this.smallPhotoUrl = smallPhotoUrl;
        }
    }
}