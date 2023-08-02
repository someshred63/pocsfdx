global with sharing class EMS_SearchUtils {
    global static List<AccountWrapper> searchInternationalSpeakers(String searchString, Integer recordLimit) {
        List<AccountWrapper> result = new List<AccountWrapper>();
        for (EMS_International_Speaker_gne__c ihcp : [
                SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c, Address_gne__c, Country_gne__c
                FROM EMS_International_Speaker_gne__c
                WHERE (
                        First_Name_gne__c LIKE :searchString
                        OR Last_Name_gne__c LIKE :searchString
                        OR Name LIKE :searchString
                )
                AND Is_Active_gne__c = TRUE
                LIMIT :recordLimit
        ]) {
            result.add(new AccountWrapper(ihcp));
        }
        return result;
    }

    //noinspection ApexUnusedDeclaration
    public static List<AccountWrapper> searchAccounts(String searchString, Integer recordLimit, String whereClause) {
        List<AccountWrapper> result = new List<AccountWrapper>();

        String accountFields = 'SELECT Id, HCP_Stakeholder_Type_gne__c, Tier_Level_gne__c, Account_Type_gne__c, FirstName, LastName, Territory_vod__c, Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true), IsPersonAccount FROM Account ';

        List<String>terrNames = new List<String>();
        for (EMS_Util.EMS_Territory terr : EMS_Util.getUserTerritories(UserInfo.getUserId())) {
            terrNames.add(terr.Name);
        }

        for (Account acc : Database.query(accountFields + whereClause)) {
            if (result.size() == recordLimit) {
                break;
            }

            if (acc.Address_vod__r.isEmpty()) {
                result.add(new AccountWrapper(acc, null));
            } else {
                for (Address_vod__c address : acc.Address_vod__r) {
                    if (result.size() == recordLimit) {
                        break;
                    }

                    result.add(new AccountWrapper(acc, address));
                }
            }
        }

        return result;
    }

    public static List<AccountWrapper> searchEmployees(String searchString, Integer recordLimit, String applicationName) {
        List<AccountWrapper> result = new List<AccountWrapper>();

        List<User> users = new List<User>();
        if (String.isNotBlank(applicationName)) {
            users = [
                    SELECT Id, Name, City, CompanyName, ContactId, Country, FirstName, IsActive, LastName, UserType
                    FROM User
                    WHERE Id IN (
                            SELECT User_gne__c
                            FROM SFA2_User_Sales_Roster_gne__c
                            WHERE Sales_Roster_gne__r.Type_gne__c = :applicationName
                    )
                    AND Name LIKE :searchString AND IsActive = TRUE
                    LIMIT :recordLimit
            ];
        } else {
            users = [SELECT Id, Name, City, CompanyName, ContactId, Country, FirstName, IsActive, LastName, UserType FROM User WHERE Name LIKE :searchString AND IsActive = TRUE LIMIT :recordLimit];
        }

        for (User u : users) {
            if (result.size() == recordLimit) {
                break;
            }
            result.add(new AccountWrapper(u, null));
        }

        return result;
    }

    public static List<AccountWrapper> searchAffiliatedHCOs(List<Id> selectedHCOIds, Integer recordLimit) {
        List<AccountWrapper> result = new List<AccountWrapper>();
        List<Id> accountIds = new List<Id>();
        Integer counter = 0;
        if (selectedHCOIds.size() > 0) {
            List<Affiliation_vod__c> affiliations = [SELECT Name, From_Account_vod__c, To_Account_Type_gne__c, To_Account_vod__c, To_Contact_vod__c FROM Affiliation_vod__c WHERE From_Account_vod__c IN :selectedHCOIds AND To_Account_vod__c != NULL];
            for (Affiliation_vod__c affiliation : affiliations) {
                accountIds.add(affiliation.To_Account_vod__c);
            }

            List<Account> accounts = [SELECT Id, FirstName, LastName, Territory_vod__c, Name, IsPersonAccount FROM Account WHERE Id IN :accountIds AND IsPersonAccount = TRUE ORDER BY LastName, FirstName LIMIT 100];
            for (Account acc : accounts) {
                if (counter++ > recordLimit) {
                    break;
                }
                result.add(new AccountWrapper(acc, null));
            }
        }
        return result;
    }

    global class AccountWrapper {
        public String description { get; private set; }
        public String addressDescription { get; private set; }
        public String recordType { get; private set; }
        public String objectId { get; private set; }

        public String accountType { get; private set; }
        public String stakeholder { get; private set; }
        public String tier { get; private set; }

        public AccountWrapper(Account account, Address_vod__c address) {
            description = GNE_SFA2_SearchAccounts_Controller.getAccountDescription(account);
            addressDescription = GNE_SFA2_SearchAccounts_Controller.getAddressDesciption(address);
            objectId = account.Id;

            if (account.IsPersonAccount) {
                recordType = 'HCP';
                description = GNE_SFA2_SearchAccounts_Controller.getAccountDescription(account);
            } else {
                recordType = 'HCO';
                description = account.Name;
            }

            setAccountDetails(account);
        }

        public AccountWrapper(User user, String address) {
            description = GNE_SFA2_SearchAccounts_Controller.getUserDescription(user);
            addressDescription = String.isNotBlank(address) ? address : user.CompanyName;
            recordType = 'Employee';
            objectId = user.Id;

            setAccountDetails(null);
        }

        public AccountWrapper(EMS_International_Speaker_gne__c speaker) {
            objectId = speaker.Id;
            description = speaker.Last_Name_gne__c + ', ' + speaker.First_Name_gne__c;
            recordType = 'iHCP';

            if (speaker.Country_gne__c != null && speaker.Address_gne__c != null) {
                addressDescription = speaker.Address_gne__c + ', ' + speaker.Country_gne__c;
            } else if (speaker.Country_gne__c != null) {
                addressDescription = speaker.Country_gne__c;
            } else {
                addressDescription = '';
            }

            accountType = '';
            stakeholder = '';
            tier = '';
        }

        private void setAccountDetails(Account account) {
            if (account != null) {
                accountType = account.Account_Type_gne__c;
                stakeholder = account.HCP_Stakeholder_Type_gne__c;
                tier = account.Tier_Level_gne__c;
            }

            accountType = String.isBlank(accountType) ? '' : accountType;
            stakeholder = String.isBlank(stakeholder) ? '' : stakeholder;
            tier = String.isBlank(tier) ? '' : tier;
        }
    }
}