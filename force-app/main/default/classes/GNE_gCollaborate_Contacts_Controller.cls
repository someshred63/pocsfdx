public with sharing class GNE_gCollaborate_Contacts_Controller {

    public static final String ACCT_PREFIX = '001';
    public String accountIds {get; private set;}

    public GNE_gCollaborate_Contacts_Controller() {
        accountIds = getAccounts(getUserTerritories(UserInfo.getUserId()));
    }

    private List<String> getUserTerritories(Id userId) {
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

    private void getChildTerritories(List<Territory2> parentTerritories, List<Territory2> result) {
        List<Territory2> childrenTerritories = getChildrenTerritories(parentTerritories, result);
        if (!childrenTerritories.isEmpty()) {
            result.addAll(childrenTerritories);
            getChildTerritories(childrenTerritories, result);
        }
    }

    private List<Territory2> getUserTopTerritories(Id userId) {
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

    private List<Territory2> getChildrenTerritories(List<Territory2> parentTerritories, List<Territory2> result) {
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

    private String getAccounts(List<String> territories) {
        String result = '';
        for (TSF_vod__c tsf : [SELECT Account_vod__c FROM TSF_vod__c WHERE External_Id_vod__c != null AND Address_vod__c != null AND Territory_vod__c IN : territories AND Account_vod__r.IsPersonAccount = false LIMIT 49000]) {
            String minAcctId = String.valueOf(tsf.Account_vod__c).substring(3,4) + String.valueOf(tsf.Account_vod__c).substring(8,18);
            if(!result.contains(minAcctId)) {
                result += minAcctId + ',';
            }
        }
        return result.removeEnd(',');
    }

    @RemoteAction @ReadOnly
    public static Integer getAcctCount() {
        String query = 'SELECT count() FROM Account WHERE IsPersonAccount = false AND Status_gne__c = \'Active\'';
        return Database.countQuery(query);
    }

    @RemoteAction
    public static Integer getContactsCount(String minAcctIds, String search) {
        List<String> acctIds = new List<String>();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        String query = 'SELECT count() FROM Contact WHERE Active_gne__c = true AND AccountId IN : acctIds';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ' OR Account.Name Like \'%' + search + '%\'';
            query += ' OR (Title_gne__c Like \'%' + search + '%\' AND Title_gne__c != \'Other\')';
            query += ' OR Title Like \'%' + search + '%\'';
            query += ')';
        }

        query += ' LIMIT 50000';

        return Database.countQuery(query);
    }

    @RemoteAction
    public static Integer getAccountsCount(String minAcctIds, String search) {
        List<String> acctIds = new List<String>();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        String query = 'SELECT count() FROM Account WHERE Id IN : acctIds';
        if (!String.isEmpty(search)) {
            query += ' AND Name Like \'%' + search + '%\'';
        }

        return Database.countQuery(query);
    }

    @RemoteAction
    public static List<ContactWrapper> getContacts(String minAcctIds, Integer displayLength, Integer displayStart, String search) {
        List<String> acctIds = new List<String>();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        List<ContactWrapper> result = new List<ContactWrapper>();

        String query = 'SELECT Id, Name, FirstName, LastName, Account.Name, Email, RecordType.Name, Phone, Cell_Phone_frm_gne__c, Title_gne__c, Function_gne__c, Title, Function_Other_gne__c, Active_gne__c FROM Contact WHERE Active_gne__c = true AND AccountId IN : acctIds';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ' OR Account.Name Like \'%' + search + '%\'';
            query += ' OR (Title_gne__c Like \'%' + search + '%\' AND Title_gne__c != \'Other\')';
            query += ' OR Title Like \'%' + search + '%\'';
            query += ')';
        }
        query += ' ORDER BY Name ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }

        System.debug('##### Query === ' + query);

        for (Contact c : Database.query(query)) {
            result.add(new ContactWrapper(c.Id, c.RecordType.Name, c.Name, c.FirstName, c.LastName, c.Account.Name, c.Email, c.Phone, c.Cell_Phone_frm_gne__c, c.Title_gne__c, c.Function_gne__c, c.Title, c.Function_Other_gne__c, c.Active_gne__c));
        }

        result.sort();
        return result;
    }

    @RemoteAction
    public static List<AccountWrapper> searchAccounts(String minAcctIds, Integer displayLength, Integer displayStart, String search) {
        List<String> acctIds = new List<String>();
        if(String.isNotEmpty(minAcctIds)) {
            for(String s : minAcctIds.split(',')) {
                acctIds.add(ACCT_PREFIX + s.substring(0,1) + '0000' + s.substring(1));
            }
        }

        List<AccountWrapper> result = new List<AccountWrapper>();

        String query = 'SELECT Id, Name FROM Account WHERE Id IN : acctIds';
        if (!String.isEmpty(search)) {
            query += ' AND Name Like \'%' + search + '%\'';
        }
        query += ' ORDER BY Name ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }

        System.debug('##### Query === ' + query);

        for (Account a : Database.query(query)) {
            result.add(new AccountWrapper(a.Id, a.Name));
        }

        result.sort();
        return result;
    }

    @RemoteAction
    public static Contact saveContact(Id id, String firstName, String lastName, String email, String phone, String cellPhone, String title, String funct, String titleName, String functionName, Boolean active) {
        Contact c = [SELECT Id, FirstName, LastName, Email, Phone, Cell_Phone_frm_gne__c, Title_gne__c, Function_gne__c, Title, Function_Other_gne__c, Active_gne__c FROM Contact WHERE Id = : id];
        c.FirstName = firstName;
        c.LastName = lastName;
        c.Email = email;
        c.Phone = phone;
        c.Cell_Phone_frm_gne__c = cellPhone;
        c.Title_gne__c = title;
        c.Function_gne__c = funct;
        c.Title = titleName;
        c.Function_Other_gne__c = functionName;
        c.Active_gne__c = active;
        update c;
        return c;
    }

    @RemoteAction
    public static Contact createContact(String firstName, String lastName, Id accountId, String email, String phone, String cellPhone, String title, String funct, String titleName, String functionName) {
        Contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.AccountId = accountId;
        c.Email = email;
        c.Phone = phone;
        c.Cell_Phone_frm_gne__c = cellPhone;
        c.Title_gne__c = title;
        c.Function_gne__c = funct;
        c.Title = titleName;
        c.Function_Other_gne__c = functionName;
        insert c;
        return c;
    }


    /* WRAPPER CLASS */

    public class ContactWrapper implements Comparable {

        private Id id {get; set;}
        private String recordType {get; set;}
        private String name {get; set;}
        private String firstName {get; set;}
        private String lastName {get; set;}
        private String accountName {get; set;}
        private String email {get; set;}
        private String phone {get; set;}
        private String cellPhone {get; set;}
        private String title {get; set;}
        private String funct {get;set;}
        private String titleName {get; set;}
        private String functionName {get;set;}
        private Boolean active {get; set;}

        public ContactWrapper(Id id, String recordType, String name, String firstName, String lastName, String accountName, String email, String phone, String cellPhone, String title, String funct, String titleName, String functionName, Boolean active) {
            this.id = id;
            this.recordType = recordType;
            this.name = name;
            this.firstName = firstName;
            this.lastName = lastName;
            this.accountName = accountName;
            this.email = email;
            this.phone = phone;
            this.cellPhone = cellPhone;
            this.title = title;
            this.funct = funct;
            this.titleName = titleName;
            this.functionName = functionName;
            this.active = active;
        }

        public Integer compareTo(Object compareTo) {
            ContactWrapper comparableData = (ContactWrapper)compareTo;
            Integer result = 0;
            if (this.name == comparableData.name) {
                result = 0;
            } else if (this.name > comparableData.name) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }

    public class AccountWrapper implements Comparable {

        private Id id {get; set;}
        private String name {get; set;}

        public AccountWrapper(Id id, String name) {
            this.id = id;
            this.name = name;
        }

        public Integer compareTo(Object compareTo) {
            AccountWrapper comparableData = (AccountWrapper)compareTo;
            Integer result = 0;
            if (this.name == comparableData.name) {
                result = 0;
            } else if (this.name > comparableData.name) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }
}