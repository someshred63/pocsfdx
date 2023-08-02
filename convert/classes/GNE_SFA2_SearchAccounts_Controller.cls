global with sharing virtual class GNE_SFA2_SearchAccounts_Controller {

    private final static Integer RECORD_QUERY_LIMIT = 50;
    public String searchString { get; set; }
    public Boolean showAvailableAccounts { get; set; }
    public Boolean showTruncatedInfo { get; set; }
    public List<AccountWrapper> availableAccounts { get; set; }
    public Boolean showProcessingInfo { get; set; }

    public GNE_SFA2_SearchAccounts_Controller() {
        availableAccounts = new List<AccountWrapper>();
    }

    /*Search accounts in user territories. Result is limited to specific size given as parameter */
    public static List<SimpleAccountWrapper>searchAccounts(String searchString, Integer recordLimit, Boolean onlyPersonAccounts) {
        List<SimpleAccountWrapper> result = new List<SimpleAccountWrapper>();
        List<String>terrNames = new List<String>();
        for (Territory2 terr : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
            terrNames.add(terr.Name);
        }
        System.debug('##### Territory === ' + terrNames);
        if (!terrNames.isEmpty()) {
            if (onlyPersonAccounts) {
                for (Account acc : [
                        SELECT Id, FirstName, LastName, Territory_vod__c, Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE), IsPersonAccount
                        FROM Account
                        WHERE Name LIKE :searchString AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :terrNames) AND IsPersonAccount = TRUE
                        ORDER BY LastName, FirstName
                        LIMIT :recordLimit
                ]) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    if (acc.Address_vod__r.isEmpty()) {
                        result.add(new SimpleAccountWrapper(acc, null));
                    } else {
                        for (Address_vod__c address : acc.Address_vod__r) {
                            if (result.size() == recordLimit) {
                                break;
                            }
                            result.add(new SimpleAccountWrapper(acc, address));
                        }
                    }
                }
            } else {
                for (Account acc : [
                        SELECT Id, FirstName, LastName, Territory_vod__c, Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE), IsPersonAccount
                        FROM Account
                        WHERE Name LIKE :searchString AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :terrNames)
                        ORDER BY Name
                        LIMIT :recordLimit
                ]) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    if (acc.Address_vod__r.isEmpty()) {
                        result.add(new SimpleAccountWrapper(acc, null));
                    } else {
                        for (Address_vod__c address : acc.Address_vod__r) {
                            if (result.size() == recordLimit) {
                                break;
                            }
                            result.add(new SimpleAccountWrapper(acc, address));
                        }
                    }
                }
            }
        }
        return result;
    }

    /*Search HCOs in user territories. Result is limited to specific size given as parameter */
    public static List<SimpleAccountWrapper>searchHCOs(String searchString, Integer recordLimit, Boolean myTargetsOnly) {
        List<SimpleAccountWrapper> result = new List<SimpleAccountWrapper>();
        List<String>terrNames = new List<String>();
        for (Territory2 terr : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
            terrNames.add(terr.Name);
        }
        if (!terrNames.isEmpty()) {
            if (myTargetsOnly) {
                for (Account acc : [
                        SELECT Id, FirstName, LastName, Territory_vod__c, Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE), IsPersonAccount
                        FROM Account
                        WHERE Name LIKE :searchString AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :terrNames AND My_Target_vod__c = TRUE) AND IsPersonAccount = FALSE
                        ORDER BY LastName, FirstName
                        LIMIT :recordLimit
                ]) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    if (acc.Address_vod__r.isEmpty()) {
                        result.add(new SimpleAccountWrapper(acc, null));
                    } else {
                        for (Address_vod__c address : acc.Address_vod__r) {
                            if (result.size() == recordLimit) {
                                break;
                            }
                            result.add(new SimpleAccountWrapper(acc, address));
                        }
                    }
                }
            } else {
                for (Account acc : [
                        SELECT Id, FirstName, LastName, Territory_vod__c, Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE), IsPersonAccount
                        FROM Account
                        WHERE Name LIKE :searchString AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :terrNames) AND IsPersonAccount = FALSE
                        ORDER BY Name
                        LIMIT :recordLimit
                ]) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    if (acc.Address_vod__r.isEmpty()) {
                        result.add(new SimpleAccountWrapper(acc, null));
                    } else {
                        for (Address_vod__c address : acc.Address_vod__r) {
                            if (result.size() == recordLimit) {
                                break;
                            }
                            result.add(new SimpleAccountWrapper(acc, address));
                        }
                    }
                }
            }
        }
        return result;
    }


    private static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean onlyOrganizationAccounts, Boolean myTargetsOnly, List<Id> ignoredIds, Boolean searchAccounts, Boolean searchContacts, Boolean searchEmployees, String applicationName, Id userId) {
        return searchAccountsContactsEmployees(searchString, recordLimit, allAccounts, onlyPersonAccounts, onlyOrganizationAccounts, myTargetsOnly, ignoredIds, searchAccounts, searchContacts, searchEmployees, applicationName, userId, null);
    }

    /*Search accounts and contacts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * onlyPersonAccounts - flags mark if only person account should be queried
    * myTargetsOnly - flags mark if only targeted accounts should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    * searchAccounts - if flag marked user accounts are searched
    * searchContacts - if flag marked contacts are searched
    * searchEmployee - if flag marked users are searched
    * additionalCondition - string with some conditions in soql in format 'somefield1 = somevalue and somefield2 = somevalue ...'
    */
    private static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean onlyOrganizationAccounts, Boolean myTargetsOnly, List<Id> ignoredIds, Boolean searchAccounts, Boolean searchContacts, Boolean searchEmployees, String applicationName, Id userId, String additionalCondition) {
        if (ignoredIds == null) {
            ignoredIds = new List<Id>();
        }
        if (additionalCondition == null) {
            additionalCondition = '';
        } else {
            additionalCondition += ' AND ';
        }
        List<List<SObject>> soslAccounts = [FIND :searchString IN NAME FIELDS RETURNING Account(Id WHERE Id NOT IN :ignoredIds LIMIT :recordLimit)];
        List<Account> filteredAccounts = (List<Account>) soslAccounts[0];
        Map<String, String> queryMap = new Map<String, String>();       // map of queries based on the criteria
        queryMap.put('PERSON_NON_TARGET', 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c in :terrNames) AND Id IN :filteredAccounts AND name LIKE :searchString AND isPersonAccount=true ORDER BY Name');

        queryMap.put('ALL_NON_TARGET', 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c in :terrNames) AND Id IN :filteredAccounts AND name LIKE :searchString ORDER BY Name');

        queryMap.put('PERSON_TARGET', 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c in :terrNames AND My_Target_vod__c = true) AND Id IN :filteredAccounts AND name LIKE :searchString AND isPersonAccount=true ORDER BY Name');

        queryMap.put('ALL_TARGET', 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c in :terrNames AND My_Target_vod__c = true) AND Id IN :filteredAccounts AND name LIKE :searchString ORDER BY Name');

        queryMap.put('PERSON_NO_TSF', 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' Id IN :filteredAccounts AND name LIKE :searchString AND isPersonAccount=true ORDER BY Name');

        queryMap.put('ALL_NO_TSF', 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' Id IN :filteredAccounts AND name LIKE :searchString AND ORDER BY Name');

        queryMap.put('ORGANIZATION_FROM_TSF', 'SELECT Id, Name, Account_Type_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ' +
                'WHERE ' + additionalCondition + ' IsPersonAccount = false AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN : terrNames ) AND Id IN :filteredAccounts AND name LIKE :searchString ORDER BY Name');

        List<SimpleAccountWrapper> result = new List<SimpleAccountWrapper>();
        List<String>terrNames = new List<String>();

        for (Territory2 terr : GNE_SFA2_Util.getUserTerritories(String.isNotBlank(userId) ? userId : UserInfo.getUserId())) {
            terrNames.add(terr.Name);
        }
        if (searchAccounts) {
            if (!terrNames.isEmpty() || GNE_SFA2_Util.isCanadaINFUUser()) {
                // select right query
                String query;
                if (allAccounts && onlyPersonAccounts) {
                    query = queryMap.get('PERSON_NO_TSF');
                } else if (allAccounts && !onlyPersonAccounts) {
                    query = queryMap.get('ALL_NO_TSF');
                } else if (onlyPersonAccounts && !myTargetsOnly) {
                    query = queryMap.get('PERSON_NON_TARGET');
                } else if (!onlyPersonAccounts && !myTargetsOnly) {
                    query = queryMap.get('ALL_NON_TARGET');
                } else if (onlyPersonAccounts && myTargetsOnly) {
                    query = queryMap.get('PERSON_TARGET');
                } else if (!onlyPersonAccounts && myTargetsOnly) {
                    query = queryMap.get('ALL_TARGET');
                } else if (onlyOrganizationAccounts) {
                    query = queryMap.get('ORGANIZATION_FROM_TSF');
                }
                if (GNE_SFA2_Util.isCanadaINFUUser()) {
                    query = queryMap.get('PERSON_NO_TSF');
                }
                System.debug('***Query: ' + query);
                for (Account acc : Database.query(query)) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    if (acc.Address_vod__r.isEmpty()) {
                        result.add(new SimpleAccountWrapper(acc, null));
                    } else {
                        for (Address_vod__c address : acc.Address_vod__r) {
                            if (result.size() == recordLimit) {
                                break;
                            }
                            result.add(new SimpleAccountWrapper(acc, address));
                        }
                    }
                }
            }
        }
        if (searchContacts) {
            if (result.size() < recordLimit) {
                Set<Id>accountsIds = new Set<Id>();
                String soslString = searchString;
                soslString = soslString.remove('%');
                soslString = '*' + soslString + '*';
                List<List<SObject>> soslContacts = [FIND :soslString IN NAME FIELDS RETURNING CONTACT( Id, FirstName, LastName, Name, AccountId, isPersonAccount, Type_gne__c WHERE isPersonAccount = FALSE AND Active_gne__c = TRUE ORDER BY name LIMIT :(recordLimit - result.size()))];
                List<Contact> contacts = (List<Contact>) soslContacts[0];

                for (Contact contact : contacts) {
                    accountsIds.add(contact.AccountId);
                }
                Map<Id, Account>accounts = new Map<Id, Account>([SELECT Id, IsPersonAccount, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE) FROM Account WHERE Id IN :accountsIds]);

                for (Contact contact : contacts) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    if (accounts.get(contact.AccountId).Address_vod__r.isEmpty()) {
                        result.add(new SimpleAccountWrapper(contact, null));
                    } else {
                        for (Address_vod__c address : accounts.get(contact.AccountId).Address_vod__r) {
                            result.add(new SimpleAccountWrapper(contact, address));
                            if (result.size() == recordLimit) {
                                break;
                            }
                        }
                    }
                }
            }
        }
        if (searchEmployees) {
            if (result.size() < recordLimit) {
                List<User> users;
                if (applicationName != null) {
                    users = [
                            SELECT Id, Name, City, CompanyName, ContactId, Country, FirstName, IsActive, LastName, UserType
                            FROM User
                            WHERE Id IN (SELECT User_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE Sales_Roster_gne__r.Type_gne__c = :applicationName)
                            AND Name LIKE :searchString AND IsActive = TRUE
                            LIMIT :(recordLimit - result.size())
                    ];
                } else {
                    if (GNE_SFA2_Util.isCanadaINFUUser()) {
                        users = [SELECT Id, Name, City, CompanyName, ContactId, Country, FirstName, IsActive, LastName, UserType FROM User WHERE Name LIKE :searchString AND IsActive = TRUE AND Profile.Name LIKE 'RCanada%' LIMIT :(recordLimit - result.size())];
                    } else {
                        users = [SELECT Id, Name, City, CompanyName, ContactId, Country, FirstName, IsActive, LastName, UserType FROM User WHERE Name LIKE :searchString AND IsActive = TRUE LIMIT :(recordLimit - result.size())];
                    }
                }
                for (User u : users) {
                    if (result.size() == recordLimit) {
                        break;
                    }
                    result.add(new SimpleAccountWrapper(u, null));
                }
            }
        }
        return result;
    }

    /*Search accounts and contacts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * onlyPersonAccounts - flags mark if only person account should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    */

    public static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean onlyPersonAccounts, List<Id>ignoredIds) {
        return searchAccountsContactsEmployees(searchString, recordLimit, false, onlyPersonAccounts, false, false, ignoredIds, true, true, true, null, null);
    }

    /*Search accounts and contacts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * onlyPersonAccounts - flags mark if only person account should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    * userId - id of current context user
    */

    public static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean onlyPersonAccounts, List<Id>ignoredIds, Id userId) {
        return searchAccountsContactsEmployees(searchString, recordLimit, false, onlyPersonAccounts, false, false, ignoredIds, true, true, true, null, userId);
    }

    public static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean onlyPersonAccounts, List<Id>ignoredIds, Boolean searchContacts, Id userId) {
        return searchAccountsContactsEmployees(searchString, recordLimit, false, onlyPersonAccounts, false, false, ignoredIds, true, searchContacts, true, null, userId);
    }

    /*Search all accounts / accounts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * onlyPersonAccounts - flags mark if only person account should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    */

    public static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean myTargetsOnly, List<Id>ignoredIds) {
        return searchAccountsContactsEmployees(searchString, recordLimit, allAccounts, onlyPersonAccounts, false, false, ignoredIds, true, true, true, null, null);
    }

    /*Search all accounts / accounts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * allAccounts - search on all accounts (ignore territories)
    * onlyPersonAccounts - flags mark if only person account should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    * searchEmployees - search for users
    */

    public static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean myTargetsOnly, Boolean searchEmployees, List<Id>ignoredIds) {
        return searchAccountsContactsEmployees(searchString, recordLimit, allAccounts, onlyPersonAccounts, false, false, ignoredIds, true, true, searchEmployees, null, null);
    }

    /*Search accounts and contacts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * onlyPersonAccounts - flags mark if only person account should be queried
    * myTargetsOnly - flags mark if only targeted accounts should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    * applicationName - the name of application that the users have to have access to
    */
    public static List<SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean onlyPersonAccounts, Boolean myTargetsOnly, List<Id> ignoredIds) {
        return searchAccountsContactsEmployees(searchString, recordLimit, false, onlyPersonAccounts, false, myTargetsOnly, ignoredIds, true, true, true, null, null);
    }

    /*Search all accounts / accounts in user territories. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * allAccounts - search on all accounts (ignore territories)
    * onlyPersonAccounts - flags mark if only person account should be queried
    * myTargetsOnly - flags mark if only targeted accounts should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    * applicationName - the name of application that the users have to have access to
    */
    public static List<SimpleAccountWrapper>searchAccountsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean myTargetsOnly, List<Id> ignoredIds, String applicationName) {
        return searchAccountsContactsEmployees(searchString, recordLimit, allAccounts, onlyPersonAccounts, false, myTargetsOnly, ignoredIds, true, false, true, applicationName, null);
    }

    /*Search users. Result is limited to specific size given as parameter
    * searchString - string used as filter for name
    * recordLimit - result is limited to this number
    * onlyPersonAccounts - flags mark if only person account should be queried
    * myTargetsOnly - flags mark if only targeted accounts should be queried
    * ignoredIds - id of accounts and contacts excluded from results
    * applicationName - the name of application that the users have to have access to
    */
    public static List<SimpleAccountWrapper>searchEmployees(String searchString, Integer recordLimit, Boolean onlyPersonAccounts, Boolean myTargetsOnly, List<Id> ignoredIds, String applicationName) {
        return searchAccountsContactsEmployees(searchString, recordLimit, false, onlyPersonAccounts, false, myTargetsOnly, ignoredIds, false, false, true, applicationName, null);
    }

    public static List<SimpleAccountWrapper>searchOrganizationAccounts(String searchString, Integer recordLimit, List<Id> ignoredIds, Id userId) {
        return searchOrganizationAccounts(searchString, recordLimit, ignoredIds, userId);
    }

    public static List<SimpleAccountWrapper>searchOrganizationAccounts(String searchString, Integer recordLimit, List<Id> ignoredIds, Id userId, String condition) {
        return searchAccountsContactsEmployees(searchString, recordLimit, false, false, true, false, ignoredIds, true, false, false, null, userId, condition);
    }

    public PageReference searchAccounts() {
        showProcessingInfo = true;
        availableAccounts.clear();
        showTruncatedInfo = false;
        String query = '%' + searchString + '%';
        List<String>terrNames = new List<String>();
        for (Territory2 terr : [SELECT Id, Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId()) ORDER BY Name]) {
            terrNames.add(terr.Name);
        }
        if (!terrNames.isEmpty()) {
            for (Account acc : [
                    SELECT Id, FirstName, LastName, Territory_vod__c, Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE), IsPersonAccount
                    FROM Account
                    WHERE Name LIKE :query AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c = :terrNames) AND IsPersonAccount = TRUE
                    ORDER BY Name
                    LIMIT :RECORD_QUERY_LIMIT
            ]) {
                if (availableAccounts.size() == RECORD_QUERY_LIMIT) {
                    showTruncatedInfo = true;
                    break;
                }
                if (acc.Address_vod__r.isEmpty()) {
                    availableAccounts.add(new AccountWrapper(acc, null));
                } else {
                    for (Address_vod__c address : acc.Address_vod__r) {
                        availableAccounts.add(new AccountWrapper(acc, address));
                        if (availableAccounts.size() == RECORD_QUERY_LIMIT) {
                            break;
                        }
                    }
                }
            }

            if (availableAccounts.size() < RECORD_QUERY_LIMIT) {
                Set<Id>accountsIds = new Set<Id>();
                String soslString = searchString;
                soslString = soslString.remove('%');
                soslString = '*' + soslString + '*';
                System.debug('**sosl string ' + soslString);
                List<List<SObject>> searchContacts = [FIND :soslString IN NAME FIELDS RETURNING CONTACT( Id, FirstName, LastName, Name, AccountId, IsPersonAccount WHERE isPersonAccount = FALSE AND Active_gne__c = TRUE ORDER BY name LIMIT :(RECORD_QUERY_LIMIT - availableAccounts.size()))];
                System.debug('**sosl result **' + searchContacts);
                List<Contact> contacts = (List<Contact>) searchContacts[0];

                for (Contact contact : contacts) {
                    accountsIds.add(contact.AccountId);
                }
                Map<Id, Account>accounts = new Map<Id, Account>([SELECT Id, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = TRUE AND Primary_vod__c = TRUE) FROM Account WHERE Id IN :accountsIds]);

                for (Contact contact : contacts) {
                    if (availableAccounts.size() == RECORD_QUERY_LIMIT) {
                        showTruncatedInfo = true;
                        break;
                    }
                    if (accounts.get(contact.AccountId).Address_vod__r.isEmpty()) {
                        availableAccounts.add(new AccountWrapper(contact, null));
                    } else {
                        for (Address_vod__c address : accounts.get(contact.AccountId).Address_vod__r) {
                            availableAccounts.add(new AccountWrapper(contact, address));
                            if (availableAccounts.size() == RECORD_QUERY_LIMIT) {
                                break;
                            }
                        }
                    }
                }
            }
        }
        showAvailableAccounts = true;
        return null;
    }

    protected void clearForm() {
        availableAccounts.clear();
        searchString = '';
        showTruncatedInfo = false;
        showAvailableAccounts = false;
        showProcessingInfo = false;
    }

    global class SimpleAccountWrapper {
        public Id accountId { get; set; }
        public Id addressId { get; set; }
        public String accountDescription { get; set; }
        public String addressDescription { get; set; }
        public String recordType { get; set; }
        public Boolean isContact { get; set; }
        public Boolean isUser { get; set; }
        public transient SObject record;

        public SimpleAccountWrapper(Account account, Address_vod__c address) {
            this.accountId = account.Id;
            this.record = account;
            if (address != null) {
                this.addressId = address.Id;
            }
            if (account.IsPersonAccount) {
                this.accountDescription = getAccountDescription(account);
                this.recordType = 'HCP';
            } else {
                this.accountDescription = account.Name;
                this.recordType = 'HCO';
            }
            this.addressDescription = getAddressDesciption(address);
            this.isContact = false;
            this.isUser = false;
        }

        public SimpleAccountWrapper(Contact contact, Address_vod__c address) {
            if (address != null) {
                this.addressId = address.Id;
            }
            this.accountDescription = getContactDescription(contact);
            this.addressDescription = getAddressDesciption(address);
            if (contact.IsPersonAccount) {
                this.recordType = 'HCP';
                this.isContact = false;
                this.accountId = contact.AccountId;
            } else {
                if (GNE_SFA2_Util.getCurrentUserProfileName().contains('FPM')) {
                    this.recordType = contact.Type_gne__c;
                } else {
                    this.recordType = 'Contact';
                }
                this.isContact = true;
                this.accountId = contact.Id;
            }
            this.record = contact;
            this.isUser = false;
        }

        public SimpleAccountWrapper(User user, String address) {
            this.accountDescription = getUserDescription(user);
            this.addressDescription = user.CompanyName;
            this.recordType = 'Employee';
            this.isContact = false;
            this.accountId = user.Id;
            this.record = user;
            this.isUser = true;
        }
    }

    global class AccountWrapper {
        public Account account { get; set; }
        public Contact contact { get; set; }
        public String description { get; set; }
        public String addressDescription { get; set; }
        public Address_vod__c address { get; set; }
        public String recordType { get; set; }
        public Boolean selected { get; set; }

        public AccountWrapper(Account account, Address_vod__c address) {
            this.account = account;
            this.address = address;
            this.description = getAccountDescription(account);
            this.addressDescription = getAddressDesciption(address);
            this.recordType = 'HCP';
        }

        public AccountWrapper(Contact contact, Address_vod__c address) {
            this.contact = contact;
            this.address = address;
            this.description = getContactDescription(contact);
            this.addressDescription = getAddressDesciption(address);
            this.recordType = 'Contact';
        }
    }

    public static String getContactDescription(Contact contact) {
        String result = '';
        if (String.isNotEmpty(contact.LastName)) {
            result += contact.LastName;
        }
        if (String.isNotEmpty(contact.FirstName)) {
            result += ', ' + contact.FirstName;
        }
        return result;
    }

    public static String getAccountDescription(Account account) {
        String result = '';
        if (String.isNotEmpty(account.LastName)) {
            result += account.LastName;
        }
        if (String.isNotEmpty(account.FirstName)) {
            result += ', ' + account.FirstName;
        }
        return result;
    }

    public static String getUserDescription(User user) {
        String result = '';
        if (String.isNotEmpty(user.LastName)) {
            result += user.LastName;
        }
        if (String.isNotEmpty(user.FirstName)) {
            result += ', ' + user.FirstName;
        }
        return result;
    }

    public static String getAddressDesciption(Address_vod__c address) {
        String description = '';
        if (address == null) {
            return description;
        }
        if (String.isNotEmpty(address.Name)) {
            description = address.Name;
        } else {
            return description;
        }

        if (String.isNotEmpty(address.City_vod__c)) {
            description += ', ' + address.City_vod__c;
        } else {
            return description;
        }

        if (String.isNotEmpty(address.State_vod__c)) {
            description += ', ' + address.State_vod__c;
        } else {
            return description;
        }

        if (String.isNotEmpty(address.Zip_vod__c)) {
            description += ', ' + address.Zip_vod__c;
        } else {
            return description;
        }
        return description;
    }
}