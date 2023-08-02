public without sharing class AGS_ST_DbUtils {
    // Values of the prefix used in Id values of the User and Group objects.
    public static final String USER_PREFIX = Schema.SObjectType.User.getKeyPrefix();
    public static final String GROUP_PREFIX = Schema.SObjectType.Group.getKeyPrefix();

    public static String getDidYouKnowText() {
        List<AGS_ST_FAQ_DYK_gne__c> dykList = [SELECT Did_You_Know_Text_gne__c,Did_You_Know_Label_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Did you know'];
        String jsonString = JSON.serialize(dykList);
        return jsonString;
    }

    public static String getFAQ() {
        List<AGS_ST_FAQ_DYK_gne__c> faqList = [SELECT Question_number_gne__c,Answer_gne__c,Question_gne__c,TC_Description_Text_gne__c,Type_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'FAQ'];
        String jsonString = JSON.serialize(faqList);
        return jsonString;
    }

    public static String getFAQ_SunshineAct() {
        List<AGS_ST_FAQ_DYK_gne__c> faqList = [SELECT Question_number_gne__c,Answer_gne__c,Question_gne__c,TC_Description_Text_gne__c,Type_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE (Type_gne__c = 'FAQ' OR Type_gne__c = 'About Sunshine Act')];
        String jsonString = JSON.serialize(faqList);
        return jsonString;
    }

    public static String getTermsAndConditions() {
        List<AGS_ST_FAQ_DYK_gne__c> faqList = [SELECT TC_Description_Text_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Terms Conditions'];
        return faqList[0].TC_Description_Text_gne__c ;
    }

    public static List<Account> findAccountByStateLicence(String licence, String state) {
        System.debug('Searching for account with licence: ' + licence + ' state: ' + state);
        if (AGS_ST_Utils.hasValue(licence) && AGS_ST_Utils.hasValue(state)) {
            try {
                Address_vod__c addr = [SELECT Account_vod__r.Id FROM Address_vod__c WHERE License_vod__c = :licence AND State_vod__c = :state LIMIT 1];
                List<Account> accounts = [SELECT Id,PersonContactId FROM Account WHERE Id = :addr.Account_vod__r.Id];
                if (accounts != null) {
                    if (accounts.size() > 0) {
                        System.debug('Account found with id: ' + Account.id + ' for licence: ' + licence + ' state: ' + state);
                        return accounts;
                    }
                }
                return null;
            } catch (QueryException e) {
                System.debug('No account found for licence: ' + licence + ' state: ' + state);
                System.debug(e);
                return null;
            }
        }
        return null;
    }

    public static List<Account> findAccountByNpi(String npi) {
        System.debug('Searching for account with npi: ' + npi);
        if (AGS_ST_Utils.hasValue(npi)) {
            try {
                List<Account> accounts = [SELECT Id,PersonContactId FROM Account WHERE NPI_vod__c = :npi];
                System.debug('--' + accounts);
                if (accounts != null) {
                    if (accounts.size() > 0) {
                        System.debug('Account found with id: ' + accounts + ' for npi: ' + npi);
                        return accounts;
                    }
                }
                return null;
            } catch (QueryException e) {
                System.debug('No account found for npi: ' + npi);
                return null;
            }
        }
        return null;
    }

    public static Account findAccountById(Id acctId) {
        try {
            List<Account> accounts = [SELECT Id,PersonContactId FROM Account WHERE Id = :acctId LIMIT 1];
            System.debug('--' + accounts);
            if (accounts != null) {
                if (accounts.size() > 0) {
                    System.debug('Account found with id: ' + accounts[0].Id);
                    return accounts[0];
                }
            }
            return null;
        } catch (QueryException e) {
            System.debug('No account found for id: ' + acctId);
            return null;
        }
    }

    public static List<User> findUserByAccountId(String accountId) {
        if (AGS_ST_Utils.hasValue(accountId)) {
            try {
                List<User> tmpUser = [SELECT Id, Email,Username FROM User WHERE AccountId = :accountId];
                return tmpUser;
            } catch (QueryException qe) {
                return null;
            }
        }
        return null;
    }

    /** @date 6/11/2013
    * @Author Pawel Sprysak
    * @description Get User Id FROM User BY Account Id
    * @param String accountId (Account Id)
    * @return Id
    */
    public static Id findGneUserIdByAccountId(String accountId) {
        if (!String.isBlank(accountId)) {
            try {
                Id idVal = [SELECT Id FROM User WHERE Profile_Name_gne__c IN ('GNE-LWO-USER', 'GNE-CM-IHCP-PROFILE') AND AccountId = :accountId].Id;
                return idVal;
            } catch (QueryException qe) {
                return null;
            }
        }
        return null;
    }

    public static AGS_ST_User_gne__c findAgsStUserByNpi(String npi) {
        if (AGS_ST_Utils.hasValue(npi)) {
            try {
                AGS_ST_User_gne__c agsStUser = [SELECT Id, Email_address__c,SFDC_User__c,Mapped_Account__c FROM AGS_ST_User_gne__c WHERE NPI_gne__c = :npi LIMIT 1];
                return agsStUser;
            } catch (QueryException e) {
                return null;
            }
        }
        return null;
    }

    public static AGS_ST_User_gne__c findAgsStUserByStateLicence(String licence, String state) {
        if (AGS_ST_Utils.hasValue(licence) && AGS_ST_Utils.hasValue(state)) {
            try {
                AGS_ST_User_gne__c agsStUser = [SELECT Id, Email_address__c,SFDC_User__c,Mapped_Account__c FROM AGS_ST_User_gne__c WHERE State_License_gne__c = :licence AND State_License_State_gne__c = :state LIMIT 1];
                return agsStUser;
            } catch (QueryException e) {
                return null;
            }
        }
        return null;
    }

    public static AGS_ST_User_gne__c findAgsStUserById(String AgsStId) {
        try {
            AGS_ST_User_gne__c agsStUser = [
                    SELECT
                            Id,
                            AssistRx_Tries_gne__c,
                            SFDC_User__r.Id,
                            SFDC_User__r.Username,
                            SFDC_User__r.IsActive,
                            SFDC_User__r.ContactId,
                            Mapped_Account__c,
                            SFDC_User__c,
                            First_name__c,
                            Last_name__c,
                            Phone_number__c,
                            Email_address__c,
                            AGS_ST_Registration_gne__r.City_gne__c,
                            AGS_ST_Registration_gne__r.State_gne__c,
                            AGS_ST_Registration_gne__r.Street_Address_gne__c,
                            AGS_ST_Registration_gne__r.Zip_gne__c,
                            NPI_gne__c,
                            State_License_gne__c,
                            State_License_State_gne__c,
                            Name,
                            AGS_ST_Registration_gne__c,
                            Communication_on_changes_gne__c,
                            Communication_When_Transfer_Posted_gne__c,
                            Phone_number_ext__c,
                            Specialty_gne__c,
                            IsLocked_gne__c,
                            Last_Password_Modified_Date__c,
                            Reset_Password_Email_Sent_Date__c,
                            Activation_Hash_Number__c,
                            AGS_ST_Registration_gne__r.ssn_gne__c,
                            AGS_ST_Registration_gne__r.dob_gne__c,
                            AGS_ST_Registration_gne__r.Gender_gne__c,
                            Registration_Status__c,
                            Mapped_Account_MDM_Id__c
                    FROM
                            AGS_ST_User_gne__c
                    WHERE
                            Id = :AgsStId
            ];
            return agsStUser;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    /* Methods gets data needed for user creation after assistrx verification */
    public static AGS_ST_User findRegistrationUserData(Id stUserId) {
        try {
            AGS_ST_User_gne__c agsStUserObj = [SELECT First_name__c, Last_name__c, Phone_number__c, Email_address__c, NPI_gne__c,State_License_gne__c,State_License_State_gne__c, AGS_ST_Registration_gne__c FROM AGS_ST_User_gne__c WHERE Id = :stUserId];
            AGS_ST_Registration_gne__c RegObj = [SELECT City_gne__c,State_gne__c, Street_Address_gne__c, Zip_gne__c, Gender_gne__c, ssn_gne__c, dob_gne__c FROM AGS_ST_Registration_gne__c WHERE Id = :agsStUserObj.AGS_ST_Registration_gne__c];
            AGS_ST_User tmpUser = new AGS_ST_User();
            System.debug('--agsStUserObj ' + agsStUserObj + '--RegObj ' + RegObj);
            tmpUser.firstName = agsStUserObj.First_name__c;
            tmpUser.lastName = agsStUserObj.Last_name__c;
            tmpUser.email = agsStUserObj.Email_address__c;
            tmpUser.phone = agsStUserObj.Phone_number__c;
            tmpUser.npi = agsStUserObj.NPI_gne__c;
            tmpUser.stateLicence = agsStUserObj.State_License_gne__c;
            tmpUser.licenceStateCode = agsStUserObj.State_License_State_gne__c;
            tmpUser.street = RegObj.Street_Address_gne__c;
            tmpUser.city = RegObj.City_gne__c;
            tmpUser.state = RegObj.State_gne__c;
            tmpUser.gender = RegObj.Gender_gne__c;
            tmpUser.zip = RegObj.Zip_gne__c;
            tmpUser.ssn = RegObj.ssn_gne__c;
            tmpUser.dob = AGS_ST_Utils.dateToString(RegObj.dob_gne__c, 'MM/dd/yyyy');
            System.debug('--tmpUser' + tmpUser);
            return tmpUser;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static void incrementAgsStUserLogTries(Id agsStUserId) {
        try {
            AGS_ST_User_gne__c stUser = AGS_ST_DbUtils.findAgsStUserById(agsStUserId);
            if (null == stUser.AssistRx_Tries_gne__c) {
                stUser.AssistRx_Tries_gne__c = 0;
            }

            if (stUser.AssistRx_Tries_gne__c >= getMaxARXTries() - 1) {
                System.debug('It\'s ' + (stUser.AssistRx_Tries_gne__c + 1) + ' try. User has been locked');
                stUser.IsLocked_gne__c = true;
            }

            stUser.AssistRx_Tries_gne__c++;

            update stUser;
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public static Integer getMaxARXTries() {
        // @todo get max tries number from custom setting
        return 3;
    }

    public static AGS_ST_User_gne__c findAgsStUser(String firstName, String lastName, String email) {
        try {
            AGS_ST_User_gne__c agsStUser = [SELECT Id,Email_address__c,First_name__c,Last_name__c FROM AGS_ST_User_gne__c WHERE /*First_name__c=:firstName and Last_name__c=:lastName and */ Email_address__c = :email LIMIT 1];
            return agsStUser;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static AGS_ST_User_gne__c findAgsStUserByUserId(Id usrId) {
        System.debug('findAgsStUserByUserId(' + usrId + ')');
        try {
            String query = 'SELECT Alert_New_Payments_Amount_gne__c,Alert_New_Payments_gne__c,Alert_Frequency_gne__c,Alert_Dispute_Updates_gne__c,Phone_number__c,Phone_number_ext__c,isTCaccepted__c,Id,Email_address__c,First_name__c,Last_name__c,SFDC_User__r.username,Mapped_Account_MDM_Id__c,SFDC_User__r.LastLoginDate,Filter_amount__c,Filter_date_from_gne__c,Filter_date_to_gne__c,Filter_date_range_gne__c,Research_Spends_Date_From_gne__c,Research_Spends_Date_Range_gne__c,Research_Spends_Date_To_gne__c,Research_Spends_Filter_Amount_gne__c,Mapped_Account__r.Specialties_gne__c,Mapped_Account__c,Dispute_Contact_preferences_gne__c from AGS_ST_User_gne__c where SFDC_User__c = \'' + usrId + '\'';
            AGS_ST_User_gne__c agsStUser = Database.query(query);
            return agsStUser;
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
        return null;
    }

    public static AGS_ST_User_gne__c findAgsStUser(String usrId, String hash) {
        try {
            AGS_ST_User_gne__c agsStUser = [SELECT isTCaccepted__c,Id,SFDC_User__c,Reset_Password_Email_Sent_Date__c,Last_Password_Modified_Date__c,SFDC_User__r.Username FROM AGS_ST_User_gne__c WHERE Id = :usrId AND Activation_Hash_Number__c = :hash];
            return agsStUser;
        } catch (Exception e) {
            return null;
        }
        return null;
    }
/*
    public static User findUserById(Id usrId)
    {
        try
        {
            User usr = [SELECT Id,AccountId,ContactId,Email,IsActive,firstname,lastname,username from User where id = :usrId];
            return usr;
        }
        catch(Exception e)
        {
            return null;
        }
        return null;
    }
*/
    public static User findUserByProxyId(Id proxyId) {
        try {
            AGS_ST_Proxy_gne__c proxy = [SELECT User_gne__c FROM AGS_ST_Proxy_gne__c WHERE Id = :proxyId];
            User usr = [SELECT Id,AccountId,Email,IsActive,FirstName,LastName,Username FROM User WHERE Id = :proxy.User_gne__c];
            return usr;
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    public static User findUserById(String usrId) {
        try {
            User usr = [SELECT Id,AccountId,ContactId,Email,IsActive,FirstName,LastName,Username,FederationIdentifier,IsPortalEnabled FROM User WHERE Id = :usrId];
            return usr;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static Id findProfileIdByName(String name) {
        try {
            Profile p = [SELECT Id FROM Profile WHERE Name = :name];
            return p.Id;
        } catch (QueryException qe) {
            return null;
        }
    }

    public static Id findRoleIdByName(String name) {
        try {
            UserRole ur = [SELECT Id FROM UserRole WHERE Name = :name];
            return ur.Id;
        } catch (QueryException qe) {
            return null;
        }
    }

    public static PermissionSet findPermissionSetByName(String name) {
        try {
            PermissionSet p = [SELECT Id FROM PermissionSet WHERE Name = :name];
            return p;
        } catch (QueryException qe) {
            return null;
        }
    }

    public static Id findUserIdByEmail(String email) {
        try {
            List<User> usersFound = [SELECT Id FROM User WHERE Username = :email ORDER BY CreatedDate DESC LIMIT 1];
            if (usersFound.size() == 1) {
                return usersFound[0].Id;
            }

            return null;
        } catch (QueryException e) {
            return null;
        }
    }

    public static Boolean assignPermissionSetToUser(String assigneeId) {
        try {
            PermissionSetAssignment psaObj = new PermissionSetAssignment();
            psaObj.PermissionSetId = findPermissionSetByName('AGS_ST_PermissionSet_gne').Id;
            psaObj.AssigneeId = assigneeId;
            insert psaObj;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Future
    public static void removePermissionSetFromUser(String userId) {
        try {
            PermissionSetAssignment[] psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :findPermissionSetByName('AGS_ST_PermissionSet_gne').Id];
            if (psa.size() > 0) {
                delete psa[0];
            }
        } catch (Exception e) {
            System.debug('Permission Set removal failed. user id=' + userId);
        }
    }

    public static Boolean hasPermission(Id userId, String permissionName) {
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :findPermissionSetByName(permissionName).Id];
        if (psa != null && psa.size() > 0) {
            return true;
        }
        return false;
    }

    public static User findUser(String firstName, String lastName, String email) {
        try {
            User user = [SELECT Id, ProfileId, IsActive, FirstName, LastName, Email FROM User WHERE /*firstname =: firstName and lastname=: lastName and */ Email = :email];
            return user;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static AGS_ST_Proxy_gne__c findProxyById(String proxyId) {
        try {
            AGS_ST_Proxy_gne__c[] proxy = [SELECT Id, FirstName_gne__c, LastName_gne__c, User_gne__r.Id, User_gne__r.Email, Last_Password_Modified_Date_gne__c FROM AGS_ST_Proxy_gne__c WHERE Id = :proxyId];
            return proxy[0];
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static AGS_ST_Proxy_gne__c findProxyByUserId(String userId) {
        System.debug('findProxyByUserId(' + userId + ')');
        try {
            AGS_ST_Proxy_gne__c[] proxy = [SELECT Id, FirstName_gne__c, LastName_gne__c, tcAccepted_gne__c, User_gne__r.Id, User_gne__r.Email FROM AGS_ST_Proxy_gne__c WHERE User_gne__c = :userId];
            return proxy[0];
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static Id findProxyId(String firstName, String lastName, String email) {
        try {
            AGS_ST_Proxy_gne__c proxy = [SELECT Id FROM AGS_ST_Proxy_gne__c WHERE /*FirstName_gne__c =:firstName AND LastName_gne__c=:lastName AND*/ User_gne__r.Email = :email];
            return proxy.Id;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static GNE_CM_MPS_SIMS_User_Management__c findSimsUserManagementById(String simsUserMngId) {
        try {
            GNE_CM_MPS_SIMS_User_Management__c simsUserManagement = [SELECT Email_Address__c, First_Name__c, Last_Name__c, Phone_Number__c FROM GNE_CM_MPS_SIMS_User_Management__c WHERE Id = :simsUserMngId];
            return simsUserManagement;
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public static AGS_ST_Proxy_Association_gne__c findProxyAssociationForProxyST(String agsStUserId, String proxyId) {
        try {
            AGS_ST_Proxy_Association_gne__c obj = [SELECT Id FROM AGS_ST_Proxy_Association_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId AND Proxy_gne__c = :proxyId];
            return obj;
        } catch (QueryException e) {
            return null;
        }
    }

    public static AGS_ST_Proxy_Association_gne__c findProxyAssociationForPhisicianProxyST(String agsStUserId, String phisicianAsProxyId) {
        try {
            AGS_ST_Proxy_Association_gne__c obj = [SELECT Id FROM AGS_ST_Proxy_Association_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId AND Physician_As_Proxy_ST_gne__c = :phisicianAsProxyId];
            return obj;
        } catch (QueryException e) {
            return null;
        }
    }

    public static AGS_ST_Proxy_Association_gne__c findProxyAssociationById(String id) {
        try {
            AGS_ST_Proxy_Association_gne__c obj = [SELECT Id, Proxy_gne__r.Id, AGS_ST_User_gne__r.SFDC_User__c FROM AGS_ST_Proxy_Association_gne__c WHERE Id = :id];
            return obj;
        } catch (QueryException e) {
            return null;
        }
    }

    public static Boolean nonPhysicianProxyHasAssociations(String proxyId) {
        try {
            AGS_ST_Proxy_Association_gne__c[] assoc = [SELECT Id FROM AGS_ST_Proxy_Association_gne__c WHERE Proxy_gne__c = :proxyId];
            return assoc.size() > 0;
        } catch (Exception e) {
            return null;
        }
    }

    public static Boolean deleteProxyAssociation(String id) {
        try {
            AGS_ST_Proxy_Association_gne__c proxyAssoc = AGS_ST_DbUtils.findProxyAssociationById(id);
            delete proxyAssoc;
            return true;
        } catch (Exception e) {
            System.debug('ProxyAssociation deletion failed. Association id=' + id);
            return false;
        }
    }

    public static Boolean checkProxyExistsST(String agsStUserId, String proxyId) {
        AGS_ST_Proxy_Association_gne__c[] isAssociattionProxy = [SELECT Id FROM AGS_ST_Proxy_Association_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId AND Proxy_gne__c = :proxyId];
        AGS_ST_Proxy_Association_gne__c[] isAssociationPhysician = [SELECT Id FROM AGS_ST_Proxy_Association_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId AND Physician_As_Proxy_ST_gne__c = :proxyId];
        if (isAssociattionProxy.size() > 0 || isAssociationPhysician.size() > 0) {
            return true;
        }
        return false;
    }

    public static AGS_ST_Proxy_Association_gne__c[] findAllPhysicianProxiesST(String agsStUserId) {
        try {
            AGS_ST_Proxy_Association_gne__c[] proxies = [SELECT Physician_As_Proxy_ST_gne__r.First_name__c,Physician_As_Proxy_ST_gne__r.Last_name__c,Physician_As_Proxy_ST_gne__r.Email_address__c FROM AGS_ST_Proxy_Association_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId AND Proxy_gne__c = NULL];
            return proxies;
        } catch (Exception e) {
            return null;
        }
    }

    public static AGS_ST_Proxy_Association_gne__c[] findAllNonPhysicianProxiesST(String agsStUserId) {
        try {
            AGS_ST_Proxy_Association_gne__c[] proxies = [SELECT Proxy_gne__r.FirstName_gne__c,Proxy_gne__r.LastName_gne__c,Proxy_gne__r.User_gne__r.Email FROM AGS_ST_Proxy_Association_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId AND Physician_As_Proxy_ST_gne__c = NULL];
            return proxies;
        } catch (Exception e) {
            return null;
        }
    }

    public static AGS_ST_Proxy_Association_gne__c createProxyAssociationForPhysicianST(String physicianAgsStUserId, String physicianAsAProxyAgsStUserId) {
        try {
            AGS_ST_Proxy_Association_gne__c association = new AGS_ST_Proxy_Association_gne__c(/*@todo remove seting MPS_User after deleting field from objectMPS_User_gne__c='a8SS00000000ncqMAA',*/AGS_ST_User_gne__c = physicianAgsStUserId, Physician_As_Proxy_ST_gne__c = physicianAsAProxyAgsStUserId);
            insert association;
            return association;
        } catch (Exception e) {
            return null;
        }
    }

    public static AGS_ST_Proxy_Association_gne__c createProxyAssociationForNonPhysicianST(String physicianAgsStUserId, String proxyId) {
        try {
            AGS_ST_Proxy_Association_gne__c association = new AGS_ST_Proxy_Association_gne__c(/*@todo remove seting MPS_User after deleting field from objectMPS_User_gne__c='a8SS00000000ncqMAA'*/AGS_ST_User_gne__c = physicianAgsStUserId, Proxy_gne__c = proxyId);
            insert association;
            return association;
        } catch (Exception e) {
            return null;
        }
    }

    public static Account findAccountById(String id) {
        System.debug('Searching for account with id: ' + id);
        try {
            List<Account> acct = [SELECT PersonContactId,PersonEmail FROM Account WHERE Id = :id];
            if (acct.size() > 0) return acct[0];
        } catch (Exception e) {
            System.debug('No account found for id: ' + id);
            return null;
        }
        return null;
    }

    public static Id insertAccount(String firstName, String lastName, String email) {
        try {
            RecordType[] rc = [SELECT Id FROM RecordType WHERE Name = 'Professional_vod'];

            Account account = new Account(RecordTypeId = rc[0].Id, FirstName = firstName, LastName = lastName, PersonEmail = email);
            insert account;
            return account.Id;
        } catch (Exception e) {
            return null;
        }
    }

    public static List<AGS_ST_Proxy_Association_gne__c> findAllProxyPhysiciansST(String id) {
        try {
            List<AGS_ST_Proxy_Association_gne__c> proxyPhysicians = [SELECT AGS_ST_User_gne__r.First_name__c,AGS_ST_User_gne__r.Email_address__c,AGS_ST_User_gne__r.Last_name__c FROM AGS_ST_Proxy_Association_gne__c WHERE Proxy_gne__r.User_gne__c = :id];
            return proxyPhysicians;
        } catch (Exception e) {
            return null;
        }
    }

    public static List<AGS_ST_Proxy_Association_gne__c> findAllAssigneePhysiciansST(String id) {
        try {
            List<AGS_ST_Proxy_Association_gne__c> proxyPhysicians = [SELECT AGS_ST_User_gne__r.First_name__c,AGS_ST_User_gne__r.Email_address__c,AGS_ST_User_gne__r.Last_name__c FROM AGS_ST_Proxy_Association_gne__c WHERE Physician_As_Proxy_ST_gne__r.SFDC_User__c = :id];
            return proxyPhysicians;
        } catch (Exception e) {
            return null;
        }
    }

    public static Id insertUser(String firstName, String lastName, String email, String contactId) {
        Id profileId = AGS_ST_DbUtils.findProfileIdByName('GNE-AGS-ST-External Profile');
        Id roleId = AGS_ST_DbUtils.findRoleIdByName('portal.a Customer Person Account');
        User u = new User(
                Alias = 'standt',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Email = email,
                LastName = lastName,
                FirstName = firstName,
                Username = email + '.gene.dev',
                //userroleid = roleId,
                ProfileId = profileId,
                ContactId = contactId
        );
        insert u;
        return u.Id;
    }

    public static Id insertUserNonSSO(String firstName, String lastName, String email, String contactId) {
        Id profileId = AGS_ST_DbUtils.findProfileIdByName('GNE-CM-IHCP-PROFILE');
        Id roleId = AGS_ST_DbUtils.findRoleIdByName('portal.a Customer Person Account');
        User u = new User(
                Alias = 'standt',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Email = email,
                LastName = lastName,
                FirstName = firstName,
                Username = email,
                //userroleid = roleId,
                ProfileId = profileId,
                ContactId = contactId,
                IsActive = false
        );
        insert u;
        return u.Id;
    }

    public static Id insertIHCPUser(String st_status, String mps_status, String lwo_status, String cob, String coj, String dob) {
        System.debug('InsertIHCPUser: st_status=' + st_status + ' mps_status=' + mps_status + ' lwo_status=' + lwo_status);
        GNE_CM_IHCP_User__c u = new GNE_CM_IHCP_User__c(
                AGS_ST_Status__c = st_status,
                LWO_Status__c = lwo_status,
                MPS_Status__c = mps_status,
                Security_Question_Answer_City_Of_Birth__c = cob,
                Security_Question_Answer_City_Of_Job__c = coj,
                Security_Question_Answer_Day_Of_Birth__c = dob
        );
        insert u;
        return u.Id;
    }

    public static void updateIHCPStatus(String iHcpId, String userId) {
        User u = findUserById(userId);
        GNE_CM_IHCP_User__c ihcpUser = AGS_ST_DbUtils.getIHCPUserById(iHcpId);
        ihcpUser.Name = u.Username;
        ihcpUser.Email_Address__c = u.Username;
        ihcpUser.SFDC_User__c = userId;
        ihcpUser.AGS_ST_Status__c = 'Approved';
        update ihcpUser;
    }

    public static GNE_CM_IHCP_User__c getIHCPUser(Id userId) {
        try {
            return [SELECT Id, AGS_ST_Status__c, LWO_Status__c, MPS_Status__c, SFDC_User__c,SFDC_User__r.Username,Security_Question_Answer_City_Of_Birth__c,Security_Question_Answer_City_Of_Job__c,Security_Question_Answer_Day_Of_Birth__c FROM GNE_CM_IHCP_User__c WHERE SFDC_User__c = :userId LIMIT 1][0];
        } catch (Exception e) {
            return null;
        }
    }

    public static GNE_CM_IHCP_User__c getIHCPUserById(Id iHcpId) {
        try {
            return [SELECT Id, AGS_ST_Status__c, LWO_Status__c, MPS_Status__c, SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE Id = :iHcpId LIMIT 1][0];
        } catch (Exception e) {
            return null;
        }
    }

    public static GNE_CM_IHCP_User__c findIHcpUserByUserName(String username) {
        try {
            return [SELECT User_Name__c,Id,IsLocked__c,Locked_Date_Time__c,Login_Failed__c,Security_Question_Answer_City_Of_Birth__c,Security_Question_Answer_City_Of_Job__c,Security_Question_Answer_Day_Of_Birth__c,AGS_ST_Status__c, LWO_Status__c, MPS_Status__c, SFDC_User__c FROM GNE_CM_IHCP_User__c WHERE User_Name__c = :username LIMIT 1][0];
        } catch (Exception e) {
            return null;
        }
    }

    public static GNE_CM_IHCP_User__c updateIhcpUserLockStatus(GNE_CM_IHCP_User__c usr) {
        if (usr.Login_Failed__c != null) {
            usr.Login_Failed__c++;
        } else {
            usr.Login_Failed__c = 1;
        }

        if (usr.Login_Failed__c > 2) {
            usr.Login_Failed__c = 0;
            usr.IsLocked__c = true;
            usr.Locked_Date_Time__c = Datetime.now();
        }
        update usr;
        return usr;
    }

    public static void resetIhcpUserLockStatus(GNE_CM_IHCP_User__c usr) {
        usr.Login_Failed__c = 0;
        usr.IsLocked__c = false;
        usr.Locked_Date_Time__c = null;
        update usr;
    }

    public static void updateStUserLastPasswordModifiedDateByUser(Id userId) {
        try {
            System.debug('START updateStUserLastPasswordModifiedDateByUser:' + userId);
            AGS_ST_User_gne__c stUser = findAgsStUserByUserId(userId);
            stUser.Last_Password_Modified_Date__c = System.now();
            stUser.Activation_Hash_Number__c = null;
            update stUser;
            System.debug('OK updateStUserLastPasswordModifiedDateByUser : ' + stUser.Id);
        } catch (Exception e) {
            System.debug('FAILED updateStUserLastPasswordModifiedDateByUser');
            System.debug(e);
        }
    }

    public static void updateStUserResetPasswordModifiedDateByUser(AGS_ST_User_gne__c agsStUsr) {
        try {
            agsStUsr.Last_Password_Modified_Date__c = Datetime.now();
            agsStUsr.Reset_Password_Email_Sent_Date__c = null;
            agsStUsr.Activation_Hash_Number__c = null;
            update agsStUsr;
        } catch (Exception e) {
            System.debug('FAILED updateStUserResetPasswordModifiedDateByUser');
            System.debug(e);
        }
    }

    @Future
    public static void updateProxyLastPasswordModifiedDateByProxyId(Id proxyId) {
        try {
            AGS_ST_Proxy_gne__c proxy = findProxyById(proxyId);
            proxy.Last_Password_Modified_Date_gne__c = System.now();
            update proxy;
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public static String checkMPSorLWO(Id usrId) {
        String ret = '';
        GNE_CM_IHCP_User__c ihcpUser = getIHCPUser(usrId);
        if (ihcpUser != null) {
            if (ihcpUser.MPS_Status__c == 'Submitted') ret = 'MPS';
            if (ihcpUser.LWO_Status__c == 'Submitted') ret = 'LWO';
        }
        return ret;
    }

    public static String checkProxyOrPhysician(Id userId) {
        AGS_ST_Proxy_gne__c[] proxy = [SELECT Id FROM AGS_ST_Proxy_gne__c WHERE User_gne__c = :userId];
        AGS_ST_User_gne__c[] physician = [SELECT Id FROM AGS_ST_User_gne__c WHERE SFDC_User__c = :userId];
        if (proxy.size() > 0) return 'proxy';
        if (physician.size() > 0) return 'physician';
        return '';
    }

    public static void updateSTUser(String stUserId, String userId) {
        System.debug('Updating stUser data, stUserId: ' + stUserId + ', userId: ' + userId);

        User usr = findUserById(userId);
        if (usr == null) {
            System.debug('No user found for userId: ' + userId);
            return;
        }

        AGS_ST_User_gne__c stUser = findAgsStUserById(stUserId);
        if (stUser != null) {
            if (stUser.Mapped_Account__c != null && stUser.SFDC_User__c != null) {
                System.debug('User already assigned to stUser object, stUser update skipped');
                return;
            }
        } else {
            System.debug('No stUser found for stUserId: ' + stUserId);
            return;
        }

        try {
            stUser.Mapped_Account__c = usr.AccountId;
            stUser.SFDC_User__c = userId;
            update stUser;

            System.debug('stUser successfully updated: ' + stUserId + ' userId: ' + userId);
        } catch (Exception e) {
            System.debug('Error while updating stUser: ' + stUserId + ' userId: ' + userId);
            System.debug(e);
        }
    }

    public static PageReference getSite(String name) {
        String domain = AGS_ST_Utils.getCustomSettingsIntExt().Site_Domain_gne__c; //'gene.sunshine.cs1.force.com';Site.getDomain();
        Site s = [SELECT Status, Subdomain, UrlPathPrefix FROM Site WHERE Name = :name][0];
        PageReference pr = new PageReference(domain + '/' + s.urlPathPrefix);
        System.debug('Site URL created: ' + pr.getUrl());
        return pr;
    }

    public class CustomSOQLQuery {
        List<String> whereClauses;
        List<String> fieldClauses;
        String objApiName;

        public customSOQLQuery() {
            whereClauses = new List<String>();
            whereClauses.clear();
            fieldClauses = new List<String>();
            fieldClauses.clear();
            objApiName = '';
        }

        public void addWhereCondition(String cond) {
            whereClauses.add(cond);
        }

        public void addQueryField(String field) {
            fieldClauses.add(field);
        }

        public void addObjectApiName(String objApiName) {
            this.objApiName = objApiName;
        }

        public String getQuery() {

            String query = 'SELECT';
            for (String field : fieldClauses) {
                query += ' ' + field + ',';
            }
            query = query.substring(0, query.length() - 1); // delete last comma

            query += ' FROM ' + objApiName;

            if (whereClauses.size() > 0) {
                query += ' WHERE';
                for (String wh : whereClauses) {
                    query += ' ' + wh + ' AND';
                }
                query = query.substring(0, query.length() - 4); // delete last 'AND'
            }
            return query;
        }
    }

    @Future
    public static void insertAssistRxManagement(Id userId, String level, String error, String status, String wsparams, String response) {
        System.debug('insertAssistRxManagement: userId=' + userId + ', level=' + level + ', error=' + error + ', status=' + status + ', wsparams=' + wsparams + ', response=' + response);
        AGS_ST_AssistRx_Management_gne__c arxm = new AGS_ST_AssistRx_Management_gne__c(
                AGS_ST_User_gne__c = userId,
                AssistRx_Level_gne__c = level,
                Error_gne__c = error,
                Status_gne__c = status,
                WS_Call_Parameters_Long_gne__c = wsparams,
                WS_Call_Response_Long_gne__c = response
        );
        insert arxm;
        System.debug('insertAssistRxManagement: success');
    }

    public static Boolean isStUserLocked(String stUserId) {
        Boolean ret;
        try {
            ret = [SELECT IsLocked_gne__c FROM AGS_ST_User_gne__c WHERE Id = :stUserId][0].IsLocked_gne__c;
            System.debug('isStUserLocked - user locked:' + ret);
            return ret;
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
        return false;
    }

    @Future
    public static void clearProxyForPhysicianDisputes(String disputeOwnerUserId, String proxyId) {
        System.debug('clearProxyForPhysicianDisputes:' + disputeOwnerUserId + ',' + proxyId);
        AGS_ST_Dispute_List_gne__c[] dl = [SELECT Id, AGS_ST_Proxy_gne__c FROM AGS_ST_Dispute_List_gne__c WHERE OwnerId = :disputeOwnerUserId AND AGS_ST_Proxy_gne__c = :proxyId];
        if (dl != null) {
            System.debug('clearProxyForPhysicianDisputes, size: ' + dl.size());
            if (dl.size() > 0) {
                for (Integer i = 0; i < dl.size(); i++) {
                    dl[i].AGS_ST_Proxy_gne__c = null;
                }
                update dl;
            }
        }
        System.debug('clearProxyForPhysicianDisputes END');
    }

    public static AGS_ST_Proxy_gne__c insertNewProxy(String firstName, String lastName, Id userId) {
        AGS_ST_Proxy_gne__c newProxy = new AGS_ST_Proxy_gne__c(FirstName_gne__c = firstName, LastName_gne__c = lastName, User_gne__c = userId);
        insert newProxy;

        return newProxy;
    }

    public static Boolean unlockStUser(AGS_ST_User_gne__c stUser) {
        if (stUser != null) {
            if (stUser.IsLocked_gne__c == true) {
                stUser.IsLocked_gne__c = false;
                stUser.AssistRx_Tries_gne__c = 0;
                update stUser;
                return true;
            }
        }
        return false;
    }

    public static List<AGS_ST_AssistRx_Management_gne__c> getAssistRxManagementForAgsStUserId(String agsStUserId) {
        try {
            List<AGS_ST_AssistRx_Management_gne__c> arxm = [SELECT AssistRx_Level_gne__c,CreatedDate,Name,Score_gne__c,Status_gne__c, WS_Call_Parameters_Long_gne__c,WS_Call_Response_Long_gne__c FROM AGS_ST_AssistRx_Management_gne__c WHERE AGS_ST_User_gne__c = :agsStUserId ORDER BY CreatedDate DESC];
            return arxm;
        } catch (Exception e) {
            System.debug('getAssistRxManagementForAgsStUserId failed, agsStUserId: ' + agsStUserId);
            System.debug(e);

            return new List<AGS_ST_AssistRx_Management_gne__c>();
        }
    }

    public static List<AGS_ST_User_gne__c> getStUsersByNpiOrStateLicence(String searchString) {
        try {
            List<AGS_ST_User_gne__c> result = [SELECT Id,Name,First_name__c,Last_name__c,Email_address__c FROM AGS_ST_User_gne__c WHERE NPI_gne__c = :searchString OR State_License_gne__c = :searchString];
            return result;
        } catch (Exception e) {
            System.debug('getStUsersByNpiOrStateLicence failed, searchString: ' + searchString);
            System.debug(e);

            return new List<AGS_ST_User_gne__c>();
        }
    }

    public static List<AGS_ST_SFDC_Registration_Error_Log_gne__c> getRegistrationErrorLogForStUser(String stUserId, String area) {
        return getRegistrationErrorLogForStUserAndAreaList(stUserId, new List<String>{
                area
        });
    }
    public static List<AGS_ST_SFDC_Registration_Error_Log_gne__c> getRegistrationErrorLogForStUserAndAreaList(String stUserId, List<String> areaList) {
        try {
            return [
                    SELECT Name,Class_gne__c,Content_gne__c,Error_Message_gne__c, Method_gne__c,AGS_ST_User_gne__c,CreatedDate
                    FROM AGS_ST_SFDC_Registration_Error_Log_gne__c
                    WHERE AGS_ST_User_gne__c = :stUserId AND Area_gne__c IN :areaList AND Error_Message_gne__c != 'Login success'
                    ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            System.debug('getRegistrationErrorLogForStUserId failed, stUserId: ' + stUserId);
            System.debug(e);
            return new List<AGS_ST_SFDC_Registration_Error_Log_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get ST User List FROM AGS_ST_User_gne__c object BY MDM Id List
    * @param List<String> mdmSpendList (MDM Id List)
    * @return List<AGS_ST_User_gne__c>
    */
    public static List<AGS_ST_User_gne__c> getAgsStUserByMDMIdList(List<String> mdmSpendList) {
        try {
            return [SELECT Id, SFDC_User__r.Contact.Account.MDMID_gne__c, SFDC_User__r.Username FROM AGS_ST_User_gne__c WHERE SFDC_User__r.Contact.Account.MDMID_gne__c IN :mdmSpendList];
        } catch (QueryException e) {
            return new List<AGS_ST_User_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get ST User FROM AGS_ST_User_gne__c object BY MDM Id
    * @param String mdmSpend (MDM Id)
    * @return AGS_ST_User_gne__c
    */
    public static AGS_ST_User_gne__c getAgsStUserByMDMId(String mdmSpend) {
        try {
            return [SELECT Id, SFDC_User__r.Id, SFDC_User__r.Contact.Account.MDMID_gne__c, SFDC_User__r.Username FROM AGS_ST_User_gne__c WHERE SFDC_User__r.Contact.Account.MDMID_gne__c = :mdmSpend LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Dispute Details FROM Dispute Management object BY Dispute Id
    * @param Id disputeId (Dispute Management Id)
    * @return AGS_ST_DisputeManagement_gne__c
    */
    public static AGS_ST_DisputeManagement_gne__c getDisputeDetailsByDisputeManagementId(String disputeId) {
        try {
            return [SELECT Name, Dispute_List_gne__c, Dispute_List_gne__r.Name, Dispute_List_gne__r.CreatedDate, Dispute_List_gne__r.Owner.name, Dispute_List_gne__r.Owner.LastName, Dispute_List_gne__r.Owner.Username, Preferred_communication_method_gne__c, Preferred_communication_value_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId];
        } catch (Exception e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Dispute Detail List FROM Dispute Management object BY Dispute Id List (different fields than in getDisputeDetailListByIdList2 method)
    * @param List<Id> disputeId
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    public static List<AGS_ST_DisputeManagement_gne__c> getDisputeDetailListByIdList(List<Id> idList) {
        try {
            return [SELECT Id, Name, Dispute_List_gne__r.IsCmsDispute_gne__c, Dispute_List_gne__r.CmsDisputeId_gne__c, Amount_frm_gne__c, Drug_Name_frm_gne__c, Form_Of_Payment_frm_gne__c, Nature_Of_Payment_frm_gne__c, Owner.Name, Internal_Status_gne__c, Dispute_Resolver_gne__r.Owner.Name, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, Drug_Name_gne__c, Dispute_List_gne__r.Form_Of_Payment_gne__c, Dispute_List_gne__r.Nature_Of_Payment_gne__c, Dispute_List_gne__r.Drug_Name_gne__c, Dispute_List_gne__r.Amount_gne__c, AGS_Spend_Expense_Transaction_gne__r.Party1_Name_gne__c, AGS_Spend_Expense_Transaction_gne__r.Party1_Specialty_gne__c, AGS_Spend_Expense_Transaction_gne__r.Party1_NPI_gne__c, AGS_Spend_Expense_Transaction_gne__r.Party2_Name_gne__c, CreatedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id IN :idList];
        } catch (Exception e) {
            return new List<AGS_ST_DisputeManagement_gne__c>();
        }
    }
/*
    public static String getDisputeDetailQueryStringByIdList(List<Id> idList) {

        String qr = 'SELECT Dispute_Resolver_gne__c, Id, Name, Owner.Name, Amount_frm_gne__c, Drug_Name_frm_gne__c, Form_Of_Payment_frm_gne__c, Nature_Of_Payment_frm_gne__c, Internal_Status_gne__c, Dispute_Resolver_gne__r.Owner.Name, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, Drug_Name_gne__c, Dispute_List_gne__r.Form_Of_Payment_gne__c, Dispute_List_gne__r.Nature_Of_Payment_gne__c, Dispute_List_gne__r.Drug_Name_gne__c, Dispute_List_gne__r.Amount_gne__c, AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.First_Name_gne__c, AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Last_Name_gne__c, AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.NPI_gne__c, AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Specialty_gne__c, CreatedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c FROM AGS_ST_DisputeManagement_gne__c';
        if(idList != null && !idList.isEmpty())
            qr+= ' WHERE Id in (';

        for(ID spendId : idList) {
            qr+= '\''+spendId+'\',';
        }
        qr = qr.substring(0,qr.length()-1);
        if(idList != null && !idList.isEmpty())
            qr+= ') ';

        return qr;
    }
*/
    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Dispute Detail List FROM Dispute Management object BY Dispute Id List (different fields than in getDisputeDetailListByIdList method)
    * @param List<Id> disputeId
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    public static List<AGS_ST_DisputeManagement_gne__c> getDisputeDetailListByIdList2(List<Id> idList) {
        try {
            return [SELECT Id, Name, Owner.Name, Amount_frm_gne__c, Drug_Name_frm_gne__c, Form_Of_Payment_frm_gne__c, Nature_Of_Payment_frm_gne__c, Internal_Status_gne__c, Dispute_Resolver_gne__r.OwnerId, Dispute_Resolver_gne__r.Owner.Name, Drug_Name_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, CreatedDate, LastModifiedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c, Dispute_List_gne__r.Owner.Name, Dispute_List_gne__r.Amount_gne__c, Dispute_List_gne__r.Drug_Name_gne__c, Dispute_List_gne__r.Nature_Of_Payment_gne__c, Dispute_List_gne__r.Form_Of_Payment_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id IN :idList];
        } catch (Exception e) {
            return new List<AGS_ST_DisputeManagement_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Spend Expense Transaction with ONLY Logical Delete Flag BY Dispute Id
    * @param Id spendId (Spend Expense Transaction Id)
    * @return AGS_Spend_Expense_Transaction_gne__c
    */
    public static AGS_Spend_Expense_Transaction_gne__c getSpendWithLogicalDeleteFlagId(String spendId) {
        try {
            return [SELECT Id, LogicalDeleteFlag_gne__c FROM AGS_Spend_Expense_Transaction_gne__c WHERE Id = :spendId];
        } catch (Exception e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get fields FROM Dispute Management object BY Event Id and Physician Id (LIMIT to 8000)
    * @param String eventId (Unique Transaction Id)
    * @param Id physicianId (Physician User Id)
    * @param String sortField
    * @param String sortOrder
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    public static List<AGS_ST_DisputeManagement_gne__c> getDisputesByEventAndPhysicianId(String eventId, Id physicianId, String sortField, String sortOrder) {
        try {
            if (sortField == null || sortField.equals('')) {
                return [SELECT Id, Name, Owner.Name, Internal_Status_gne__c, Dispute_Resolver_gne__r.OwnerId, Dispute_Resolver_gne__r.Owner.Name, Dispute_List_gne__r.Owner.Name, Drug_Name_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, CreatedDate, LastModifiedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c = :eventId AND Dispute_List_gne__r.OwnerId != :physicianId LIMIT 8000];
            } else {
                String selectQuery = 'SELECT Id, Name, Owner.Name, Internal_Status_gne__c, Dispute_Resolver_gne__r.OwnerId, Dispute_Resolver_gne__r.Owner.Name, Dispute_List_gne__r.Owner.Name, Drug_Name_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, CreatedDate, LastModifiedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c = \'' + eventId + '\' AND Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' LIMIT 8000';
                return Database.query(selectQuery);
            }
        } catch (QueryException e) {
            return new List<AGS_ST_DisputeManagement_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only Id's FROM Dispute Management object BY Event Id and Physician Id (LIMIT to 8000)
    * @param String eventId (Unique Transaction Id)
    * @param Id physicianId (Physician User Id)
    * @param String sortField
    * @param String sortOrder
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    public static List<AGS_ST_DisputeManagement_gne__c> getDisputesIdsByEventAndPhysicianId(String eventId, Id physicianId, String sortField, String sortOrder) {
        try {
            if (sortField == null || sortField.equals('')) {
                return [SELECT Id FROM AGS_ST_DisputeManagement_gne__c WHERE AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c = :eventId AND Dispute_List_gne__r.OwnerId != :physicianId LIMIT 8000];
            } else {
                String selectQuery = 'SELECT Id FROM AGS_ST_DisputeManagement_gne__c WHERE AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c = \'' + eventId + '\' AND Dispute_List_gne__r.OwnerId != \'' + physicianId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' LIMIT 8000';
                return Database.query(selectQuery);
            }
        } catch (QueryException e) {
            return new List<AGS_ST_DisputeManagement_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get fields FROM Dispute Management object BY Physician Id (LIMIT to 8000)
    * @param Id physicianId (Physician User Id)
    * @param String sortField
    * @param String sortOrder
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    public static List<AGS_ST_DisputeManagement_gne__c> getDisputesByPhysicianId(Id physicianId, String sortField, String sortOrder) {
        try {
            if (sortField == null || sortField.equals('')) {
                return [SELECT Id, Name, Owner.Name, Internal_Status_gne__c, Dispute_Resolver_gne__r.OwnerId, Dispute_Resolver_gne__r.Owner.Name, Dispute_List_gne__r.Owner.Name, Drug_Name_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, CreatedDate, LastModifiedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = :physicianId LIMIT 8000];
            } else {
                String selectQuery = 'SELECT Id, Name, Owner.Name, Internal_Status_gne__c, Dispute_Resolver_gne__r.OwnerId, Dispute_Resolver_gne__r.Owner.Name, Dispute_List_gne__r.Owner.Name, Drug_Name_gne__c, Amount_gne__c, Form_Of_Payment_gne__c, Nature_Of_Payment_gne__c, CreatedDate, LastModifiedDate, AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' LIMIT 8000';
                return Database.query(selectQuery);
            }
        } catch (QueryException e) {
            return new List<AGS_ST_DisputeManagement_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only Id's FROM Dispute Management object BY Physician Id (LIMIT to 8000)
    * @param Id physicianId (Physician User Id)
    * @param String sortField
    * @param String sortOrder
    * @return List<AGS_ST_DisputeManagement_gne__c>
    */
    public static List<AGS_ST_DisputeManagement_gne__c> getDisputesIdsByPhysicianId(Id physicianId, String sortField, String sortOrder) {
        try {
            if (sortField == null || sortField.equals('')) {
                return [SELECT Id FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = :physicianId LIMIT 8000];
            } else if (!String.isBlank(sortOrder)) {
                String selectQuery = '';
                if (sortOrder.toLowerCase().equals('asc')) {
                    selectQuery = 'SELECT Id FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS FIRST LIMIT 8000';
                } else if (sortOrder.toLowerCase().equals('desc')) {
                    selectQuery = 'SELECT Id FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS LAST LIMIT 8000';
                }
                return Database.query(selectQuery);
            } else {
                String selectQuery = 'SELECT Id FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' LIMIT 8000';
                System.debug('---------- getDisputesByPhisician selectQuery ' + selectQuery);
                return Database.query(selectQuery);
            }
        } catch (QueryException e) {
            return new List<AGS_ST_DisputeManagement_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for checking, is there any disputes for particular physician, but for other resolvers
    * @param Id physicianId (Physician Id)
    * @param Id disputeResolverId (Dispute Resolver Id)
    * @return Boolean
    */
    public static Boolean isDisputeCollision(Id physicianId, Id disputeResolverId) {
        try {
            String selectQuery = 'SELECT Name FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' AND (Internal_Status_gne__c = \'In Progress\' OR Internal_Status_gne__c = \'Assigned\') AND Dispute_Resolver_gne__r.OwnerId != \'' + disputeResolverId + '\' LIMIT 1';
            if (Database.query(selectQuery).size() > 0) {
                return true;
            } else {
                return false;
            }
        } catch (QueryException e) {
            return false;
        }
    }

    /** @date 8/20/2013
    * @Author Pawel Sprysak
    * @description Method for checking, is there any disputes for particular physician, but for other resolvers
    * @param Id physicianId (Physician Id)
    * @param Id disputeResolverId (Dispute Resolver Id)
    * @param Id thisDisputeId (Id of Dispute to compare)
    * @return Boolean
    */
    public static Boolean isDisputeCollision(Id physicianId, Id disputeResolverId, Id thisDisputeId) {
        try {
            String selectQuery = 'SELECT Name FROM AGS_ST_DisputeManagement_gne__c WHERE Dispute_List_gne__r.OwnerId = \'' + physicianId + '\' AND (Internal_Status_gne__c = \'In Progress\' OR Internal_Status_gne__c = \'Assigned\') AND Dispute_Resolver_gne__r.OwnerId != \'' + disputeResolverId + '\' AND Id != \'' + thisDisputeId + '\' LIMIT 1';
            if (Database.query(selectQuery).size() > 0) {
                return true;
            } else {
                return false;
            }
        } catch (QueryException e) {
            return false;
        }
    }

    /** @date 24/9/2014
    * @Author Konrad Malinowski
    * @description Method for checking CMS Dispute ID uniqueness
    * @param String cmsDisputeId
    * @param String disputeId
    * @return Boolean
    */
    public static Boolean isCmsDisputeIdUnique(String cmsDisputeId, String disputeId) {
        return ([
                SELECT COUNT()
                FROM AGS_ST_DisputeManagement_gne__c
                WHERE Dispute_List_gne__r.CmsDisputeId_gne__c = :cmsDisputeId
                AND Id != :disputeId
        ] == 0);
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Method for getting Disputes Report Id
    * @return String
    */
    public static Id getDisputesReportId() {
        try {
            return [SELECT Id FROM Report WHERE DeveloperName = 'AGS_ST_Disputes_Reports_gne' LIMIT 1].Id;
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only Dispute Name FROM Dispute Management BY Dispute Id
    * @param Id disputeId (Dispute Management Id)
    * @return String
    */
    public static String getDisputeNameById(Id disputeId) {
        try {
            return [SELECT Name FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId].Name;
        } catch (QueryException e) {
            return '';
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only Dispute External Status FROM Dispute Management BY Dispute Id
    * @param Id disputeId (Dispute Management Id)
    * @return String
    */
    public static String getDisputeExternalStatusById(Id disputeId) {
        try {
            return [SELECT External_Status_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId].External_Status_gne__c;
        } catch (QueryException e) {
            return '';
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only is Private flag FROM Dispute Management BY Dispute Id
    * @param Id disputeId (Dispute Management Id)
    * @return AGS_ST_DisputeManagement_gne__c
    */
    public static AGS_ST_DisputeManagement_gne__c getDisputeIsPrivateFlagByDispId(Id disputeId) {
        try {
            return [SELECT isPrivate__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only is Private flag FROM Dispute List BY Dispute Id
    * @param Id disputeListId (Dispute List Id)
    * @return AGS_ST_Dispute_List_gne__c
    */
    public static AGS_ST_Dispute_List_gne__c getDisputeListIsPrivateFlagByDispId(Id disputeListId) {
        try {
            return [SELECT isPrivate_gne__c FROM AGS_ST_Dispute_List_gne__c WHERE Id = :disputeListId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only Dispute Last Modified Date FROM Dispute Management BY Dispute Id
    * @param Id disputeId (Dispute Management Id)
    * @return Datetime
    */
    public static Datetime getDisputeModifiedDateById(Id disputeId) {
        try {
            return [SELECT LastModifiedDate FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId].LastModifiedDate;
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get only Dispute Internal Status FROM Dispute Management BY Dispute Id
    * @param Id disputeId (Dispute Management Id)
    * @return String
    */
    public static String getDisputeInternalStatusById(Id disputeId) {
        try {
            return [SELECT Internal_Status_gne__c FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId].Internal_Status_gne__c;
        } catch (QueryException e) {
            return '';
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Dispute Resolver BY Id
    * @param Id resolverId (Dispute Resolver Id)
    * @return AGS_ST_DisputeResolver_gne__c
    */
    public static AGS_ST_DisputeResolver_gne__c getResolverById(Id resolverId) {
        try {
            return [SELECT Id, Owner.Name, OwnerId FROM AGS_ST_DisputeResolver_gne__c WHERE Id = :resolverId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get number of rows for External Disputes related to given Spend Expense Transaction
    * @param Id spendId (Spend Expense Transaction Id)
    * @return Integer
    */
    public static Integer getDMNumForSpend(Id spendId) {
        try {
            Integer dm = [SELECT COUNT() FROM AGS_ST_DisputeManagement_gne__c WHERE isPrivate__c = FALSE AND AGS_Spend_Expense_Transaction_gne__c = :spendId AND Internal_Status_gne__c != 'Corrected Pending SSR' AND Internal_Status_gne__c != 'Resolved No Correction' AND Internal_Status_gne__c != 'Resolved With Correction' LIMIT 1];
            return dm;
        } catch (QueryException e) {
            return 0;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get ALL Dispute Resolver List FROM Dispute Resolver
    * @return List<AGS_ST_DisputeResolver_gne__c>
    */
    public static List<AGS_ST_DisputeResolver_gne__c> getResolverList() {
        try {
            return [SELECT OwnerId, Owner.Name FROM AGS_ST_DisputeResolver_gne__c];
        } catch (QueryException e) {
            return new List<AGS_ST_DisputeResolver_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Dispute Note&Attachment Details FROM Dispute Note and Attachment BY Object Id
    * @param Id dnaId (Dispute Note and Attachment Id)
    * @return AGS_ST_Dispute_Note_and_Attachment_gne__c
    */
    public static AGS_ST_Dispute_Note_and_Attachment_gne__c getDisputeNotesAndAttById(Id dnaId) {
        try {
            return [SELECT Id,Communication_Date_gne__c,Dispute_Status_gne__c,Communication_Method_gne__c,Communication_Type_gne__c,isPrivate_gne__c,LastModifiedById,LastModifiedDate,Email_Type_gne__c FROM AGS_ST_Dispute_Note_and_Attachment_gne__c WHERE Id = :dnaId];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Dispute Note&Attachment List FROM Dispute Note and Attachment BY Dispute Id - Limited to 1000
    * @param Id disputeId (Dispute Management Id)
    * @param String sortField (Sort by this field)
    * @param String sortOrder (Sorting order)
    * @return List<AGS_ST_Dispute_Note_and_Attachment_gne__c>
    */
    public static List<AGS_ST_Dispute_Note_and_Attachment_gne__c> getDisputeNotesAndAtt(Id disputeId, String sortField, String sortOrder) {
        try {
            if (sortField == null || sortField.equals('')) {
                return [SELECT Id,About_gne__c,Communication_Date_gne__c,Dispute_Status_gne__c,Communication_Method_gne__c,Communication_Type_gne__c,isPrivate_gne__c,LastModifiedById,LastModifiedDate,Email_Type_gne__c,CreatedDate FROM AGS_ST_Dispute_Note_and_Attachment_gne__c WHERE AGS_ST_Dispute_Management_gne__c = :disputeId LIMIT 1000];
            } else {
                String selectQuery = 'SELECT id,About_gne__c,Communication_Date_gne__c,Dispute_Status_gne__c,Communication_Method_gne__c,Communication_Type_gne__c,isPrivate_gne__c,LastModifiedById,LastModifiedDate,Email_Type_gne__c,CreatedDate from AGS_ST_Dispute_Note_and_Attachment_gne__c WHERE AGS_ST_Dispute_Management_gne__c = \'' + disputeId + '\' ORDER BY ' + sortField + ' ' + sortOrder + ' LIMIT 1000';
                return Database.query(selectQuery);
            }
        } catch (QueryException e) {
            return new List<AGS_ST_Dispute_Note_and_Attachment_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Note Map FROM Note BY Parent Id's - Limited 1000
    * @param Set<Id> naList (List of Notes Parent Id's)
    * @return Map<String,Note>
    */
    public static Map<String, Note> getNotesByNotesAndAttachments(Set<Id> naList) {
        try {
            Map<String, Note> notesMap = new Map<String, Note>();
            for (Note n : [SELECT Id,Body,ParentId FROM Note WHERE ParentId IN :naList LIMIT 1000]) {
                notesMap.put(n.ParentId, n);
            }
            return notesMap;
        } catch (QueryException e) {
            return new Map<String, Note>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Attachment Map FROM Attachment BY Parent Id's - Limited 1000
    * @param Set<Id> naList (List of Attachments Parent Id's)
    * @return Map<String,Attachment>
    */
    public static Map<String, Attachment> getAttachmentsByNotesAndAttachments(Set<Id> naList) {
        try {
            Map<String, Attachment> attachmentsMap = new Map<String, Attachment>();
            for (Attachment a : [SELECT Id,Name,ParentId FROM Attachment WHERE ParentId IN :naList LIMIT 1000]) {
                attachmentsMap.put(a.ParentId, a);
            }
            return attachmentsMap;
        } catch (QueryException e) {
            return new Map<String, Attachment>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Attachment List FROM Attachment BY Parent Id
    * @param Id dnaId (Parent Id)
    * @return List<Attachment>
    */
    public static List<Attachment> getAttachmentsByNoteAndAttachmentId(Id dnaId) {
        try {
            List<Attachment> attachments = [SELECT Id,Name FROM Attachment WHERE ParentId = :dnaId];
            return attachments;
        } catch (QueryException e) {
            return new List<Attachment>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Note FROM Note BY Parent Id
    * @param Id dnaId (Parent Id)
    * @return Note
    */
    public static Note getNoteByNoteAndAttachmentId(Id dnaId) {
        try {
            Note notes = [SELECT Id,Body FROM Note WHERE ParentId = :dnaId LIMIT 1];
            return notes;
        } catch (QueryException e) {
            return new Note();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Adding notes for dispute explanations
    * @param String disputeId (Dispute Id)
    * @param String (Note value)
    * @param String about (Category value)
    * @return String
    */
    public static String saveDisputeNotesFromDisputeId(String disputeId, String noteTxt, String about) {
        try {
            AGS_ST_Dispute_Note_and_Attachment_gne__c na = new AGS_ST_Dispute_Note_and_Attachment_gne__c(About_gne__c = about, AGS_ST_Dispute_Management_gne__c = disputeId, isHCP_gne__c = true, isPrivate_gne__c = false);
            insert na;
            Note n = new Note(Body = noteTxt, ParentId = na.Id, Title = 'HCP Dispute Note', IsPrivate = false);
            insert n;
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Transaction FROM Spend Expense Transaction BY Transaction Id
    * @param Id spendId (Spend Expense Transaction Id)
    * @return AGS_Spend_Expense_Transaction_gne__c
    */
    public static AGS_Spend_Expense_Transaction_gne__c getSpendExpTransById(Id spendId) {
        try {
            return [
                    SELECT LogicalDeleteFlag_gne__c,Primary_Recipient_MDM_ID_gne__c,Secondary_Recipient_MDM_ID_gne__c,Form_Of_Payment_gne__c,Nature_Of_Payment_gne__c,Id,Allocated_Transaction_Amount_gne__c,Event_Date_gne__c,Event_Actual_Attendee_Count_gne__c,Event_Planned_Attendee_Count_gne__c,Source_Transaction_Amount_gne__c,Source_System_Code_gne__c,Report_Code_gne__c, (SELECT AGS_Brand__c FROM AGS_expense_products_intercations1__r)
                    FROM AGS_Spend_Expense_Transaction_gne__c
                    WHERE Id = :spendId
                    LIMIT 1
            ];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Transaction List FROM Spend Expense Transaction BY Transaction Id List
    * @param List<Id> spendId (Spend Expense Transaction Id List)
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    public static List<AGS_Spend_Expense_Transaction_gne__c> getSpendExpTransListByIdList(List<Id> spendIdList) {
        try {
            return [SELECT Id, Name, Primary_Recipient_MDM_ID_gne__c, Secondary_Recipient_MDM_ID_gne__c, Allocated_Transaction_Amount_gne__c, Event_Actual_Attendee_Count_gne__c, Event_Date_gne__c, Event_City_gne__c, Party1_Name_gne__c, Party2_Name_gne__c FROM AGS_Spend_Expense_Transaction_gne__c WHERE Id IN :spendIdList];
        } catch (QueryException e) {
            return new List<AGS_Spend_Expense_Transaction_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Transaction List FROM Spend Expense Transaction BY Query
    * @param String selectQuery (SOQL Query for Spend Expense Transaction)
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    public static List<AGS_Spend_Expense_Transaction_gne__c> getSpendExpTransactionByQuery(String selectQuery) {
        try {
            return Database.query(selectQuery);
        } catch (QueryException e) {
            return new List<AGS_Spend_Expense_Transaction_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get row number for query
    * @param String selectQuery (SOQL Query for Spend Expense Transaction)
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    public static Integer getCountByQuery(String countQuery) {
        try {
            return Database.countQuery(countQuery);
        } catch (QueryException e) {
            return 0;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Transaction List FROM Spend Expense Transaction BY Primary Recipient AND Event Id - Limited to 5000
    * @param Id primaryRecipient (CCO Primary Recipient Id)
    * @param String eventId (Unique Transaction Id)
    * @return List<AGS_Spend_Expense_Transaction_gne__c>
    */
    /*
    public static List<AGS_Spend_Expense_Transaction_gne__c> getSpendExpTransByRecipientAndEventId(Id primaryRecipient, String eventId) {
        try {
            return [SELECT Id, Name, CreatedDate FROM AGS_Spend_Expense_Transaction_gne__c WHERE Report_Code_gne__c = 'XC_MON' AND Primary_Recipient_gne__c = :primaryRecipient AND Unique_Transaction_Id_gne__c = :eventId LIMIT 5000];
        } catch(QueryException e) {
            return new List<AGS_Spend_Expense_Transaction_gne__c>();
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Product Interaction Brands FROM Expense Products Interaction BY Spend Transaction Id
    * @param Id transactionId (Spend Expense Transaction Id)
    * @return String
    */
    public static String getExpenseProductInteractionByTransactionId(Id transactionId) {
        try {
            String epiReturn = '';
            for (AGS_Expense_Products_Interaction__c epi : [SELECT AGS_Brand__c FROM AGS_Expense_Products_Interaction__c WHERE Expense_Transaction_ID_gne__c = :transactionId ORDER BY AGS_Brand__c ASC]) {
                if (epiReturn.equals('')) epiReturn = epi.AGS_Brand__c; else epiReturn += ',' + epi.AGS_Brand__c;
            }
            return epiReturn;
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Held Transaction Junctions FROM Held And Dispute Junction BY Dispute Id and Direct Indicator Flag - Limited
    * @param Id disputeId (Dispute Id)
    * @param Boolean directIndicator (Direct Indicator Flag value)
    * @param Integer num (Limit number)
    * @return List<AGS_ST_Held_And_Dispute_Junction_gne__c>
    */
    /* HD Decommissioning 
    public static List<AGS_ST_Held_And_Dispute_Junction_gne__c> getHeldListByDispIdAndDirectIndicator(Id disputeId, String directIndicator, Integer num) {
        try {
            return [SELECT AGS_ST_Held_Transaction_gne__r.Id, AGS_ST_Held_Transaction_gne__r.Name, AGS_ST_Held_Transaction_gne__r.CreatedDate, AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c, AGS_ST_Held_Transaction_gne__r.AGS_Spend_Expense_Transaction_gne__c, AGS_ST_Held_Transaction_gne__r.Source_Transaction_Amount_gne__c, AGS_ST_Dispute_Management_gne__c, AGS_ST_Held_Transaction_gne__r.SRC_EXP_KEY_GNE__c FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE AGS_ST_Dispute_Management_gne__r.Id = :disputeId AND AGS_ST_Direct_Relationship_Indicator_gne__c = :directIndicator AND AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c != 'No Longer Valid' ORDER BY CreatedDate DESC LIMIT :num];
        } catch(QueryException e) {
            return new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Held Transaction Junctions FROM Held And Dispute Junction BY Dispute Id and Direct Indicator Flag - Limited
    * @param Id disputeId (Dispute Id)
    * @param Id spendId
    * @return List<AGS_ST_Held_And_Dispute_Junction_gne__c>
    */
    /* HD Decommissioning 
    public static List<AGS_ST_Held_And_Dispute_Junction_gne__c> getHeldListByDispIdAndSpendId(Id disputeId, String heldKey) {
        try {
            return [SELECT AGS_ST_Held_Transaction_gne__r.Id, AGS_ST_Held_Transaction_gne__r.Name, AGS_ST_Held_Transaction_gne__r.CreatedDate, AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE AGS_ST_Dispute_Management_gne__r.Id = :disputeId AND AGS_ST_Held_Transaction_gne__r.SRC_EXP_KEY_GNE__c = :heldKey AND AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c = 'No Longer Valid' ORDER BY CreatedDate DESC LIMIT 10000];
        } catch(QueryException e) {
            return new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get All not processed by batch Held Transaction Junctions FROM Held And Dispute Junction
    * @return List<AGS_ST_Held_And_Dispute_Junction_gne__c>
    */
    /* HD Decommissioning 
    public static List<AGS_ST_Held_And_Dispute_Junction_gne__c> getAllNotProcessedHeldJuncList() {
        try {
            return [SELECT Id, AGS_ST_ProcessedByEmailBatch_gne__c FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE AGS_ST_ProcessedByEmailBatch_gne__c = false];
        } catch(QueryException e) {
            return new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Held Transaction Junctions FROM Held And Dispute Junction BY Held Transaction Id
    * @param Id heldId (Held Transaction Id)
    * @param Integer limitSize (limit for SOQL query)
    * @return List<AGS_ST_Held_And_Dispute_Junction_gne__c>
    */
    /* HD Decommissioning 
    public static List<AGS_ST_Held_And_Dispute_Junction_gne__c> getHeldJuncListByHeldId(Id heldId, Integer limitSize) {
        try {
            return [SELECT AGS_ST_Dispute_Management_gne__r.Id, AGS_ST_Dispute_Management_gne__r.Name, AGS_ST_Dispute_Management_gne__r.isPrivate__c, AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c, AGS_ST_Direct_Relationship_Indicator_gne__c, LastModifiedDate FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE AGS_ST_Held_Transaction_gne__c = :heldId ORDER BY CreatedDate DESC LIMIT :limitSize];
        } catch(QueryException e) {
            return new List<AGS_ST_Held_And_Dispute_Junction_gne__c>();
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get number of related helds for particular Dispute Management object - limited to 2
    * @param Id disputeId (Dispute Management Id)
    * @return Integer (value from 0 to 2)
    */
    /* HD Decommissioning 
    public static Integer getRelatedHeldNumByDispId(Id disputeId) {
        try {
            return [SELECT COUNT() FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE AGS_ST_Dispute_Management_gne__c = :disputeId LIMIT 2];
        } catch(QueryException e) {
            return 0;
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Held Transaction List FROM Held Transaction BY Held Transaction Id's
    * @param List<Id> idList (Held Transaction Id List)
    * @return List<AGS_ST_Held_Transaction_gne__c>
    */
    /* HD Decommissioning 
    public static List<AGS_ST_Held_Transaction_gne__c> getHeldListByIdList(List<Id> idList) {
        try {
            return [SELECT Held_Transaction_Process_Status_Code_gne__c, Source_Transaction_Amount_gne__c FROM AGS_ST_Held_Transaction_gne__c WHERE Id IN :idList];
        } catch(QueryException e) {
            return new List<AGS_ST_Held_Transaction_gne__c>();
        }
    }

    public static List<AGS_ST_Held_Transaction_gne__c> getHeldListByMDMIdList(String mdmId, Integer limitSize) {
        try {
            if(String.isBlank(mdmId))
                return new List<AGS_ST_Held_Transaction_gne__c>();
            else
                return [SELECT Id,Name,SRC_EXP_KEY_GNE__c,Held_Transaction_Process_Status_Code_gne__c,Source_Transaction_Amount_gne__c,MDM_ID_GNE__c,CreatedDate FROM AGS_ST_Held_Transaction_gne__c WHERE MDM_ID_GNE__c =:mdmId and Held_Transaction_Process_Status_Code_gne__c != 'No Longer Valid' order by CreatedDate desc LIMIT :limitSize];
        } catch(QueryException e) {
            return new List<AGS_ST_Held_Transaction_gne__c>();
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Spend Recipient FROM CCO Case Recipient BY Id
    * @param Id recipientId (Spend Recipient Id)
    * @return AGS_CCO_Case_Recipient_gne__c
    */
    /*
    public static AGS_CCO_Case_Recipient_gne__c getRecipientById(Id recipientId) {
        try {
            return [SELECT Id, Address_Line_1_gne__c, Address_line_2_gne__c, City_gne__c, First_Name_gne__c, Last_Name_gne__c, NPI_gne__c, RCH_Category_gne__c, Reciepient_Title_gne__c, Specialty_gne__c, State_gne__c, Zip_gne__c FROM AGS_CCO_Case_Recipient_gne__c WHERE Id = :recipientId LIMIT 1];
        } catch(QueryException e) {
            return null;
        }
    }
    */

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Recipient License State BY Recipient MDM Id
    * @param Id recipientId (Spend Recipient MDM Id)
    * @return AGS_Recipient_License_State_gne__c
    */
    public static AGS_Recipient_License_State_gne__c getLicenseByRecipientId(Id recipientId) {
        try {
            return [SELECT License_State_gne__c, State_License_Number_gne__c, AGS_Recipient_MDM_ID_gne__c FROM AGS_Recipient_License_State_gne__c WHERE AGS_Recipient_MDM_ID_gne__c = :recipientId LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Recipient License State List BY Recipient MDM Id List
    * @param List<Id> recipientIdList (Spend Recipient MDM Id List)
    * @return List<AGS_Recipient_License_State_gne__c>
    */
    public static List<AGS_Recipient_License_State_gne__c> getLicenseByRecipientIdList(List<Id> recipientIdList) {
        try {
            return [SELECT License_State_gne__c, State_License_Number_gne__c, AGS_Recipient_MDM_ID_gne__c FROM AGS_Recipient_License_State_gne__c WHERE AGS_Recipient_MDM_ID_gne__c IN :recipientIdList LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Recipient Speciality List
    * @return List<AGS_ST_RecipientSpeciality_gne__c>
    */
    public static List<AGS_ST_RecipientSpeciality_gne__c> getRecipientSpecialityList() {
        try {
            return [SELECT Speciality_Name_gne__c FROM AGS_ST_RecipientSpeciality_gne__c ORDER BY Speciality_Name_gne__c ASC];
        } catch (QueryException e) {
            return new List<AGS_ST_RecipientSpeciality_gne__c>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get User Id BY Recipient MDM Id
    * @param String mdmId (Spend Recipient MDM Id)
    * @return Id
    */
    public static Id getUserIdByMDMID(String mdmId) {
        try {
            return [SELECT Id FROM User WHERE Contact.Account.MDMID_gne__c = :mdmId LIMIT 1].Id;
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get Profile BY Profile Id
    * @param Id profileId (Profile Id)
    * @return Profile
    */
    public static Profile getProfileNameById(Id profileId) {
        try {
            return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        } catch (QueryException e) {
            return null;
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Get sObject List (only History Objects) BY Parent Id (Limit to 1000)
    * @param String objectType (History object type)
    * @param String parentId (Parent Id)
    * @return List<sObject>
    */
    public static List<SObject> getHistoryByTypeAndParentId(String objectType, String parentId) {
        return Database.query('SELECT CreatedBy.Name, CreatedBy.Id, CreatedDate, Field, OldValue, NewValue FROM ' + objectType + '  WHERE ParentId = \'' + parentId + '\' ORDER BY CreatedDate ASC LIMIT 1000');
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Only detail type products not owned by GNE-SFA-Canada-Queue are part of display list. Product name needs
    * to be truncated till first '-' and the list should not contain duplicates.
    * @return List<SelectOption>
    */
    public static List<SelectOption> getDrugNames() {
        try {
            List<SelectOption> result = new List<SelectOption>();//{new SelectOption('', '-NONE-')};
            //Set<String> tmp = new Set<String>();
            for (AGS_Brand_gne__c product : [SELECT Brand_Name__c FROM AGS_Brand_gne__c]) {
                //tmp.add(product.Brand_Name__c.replaceAll('-.*', '').trim());
                result.add(new SelectOption(product.Brand_Name__c.trim(), product.Brand_Name__c.trim()));
            }
            //for (String s : tmp) {
            //    result.add(new SelectOption(s, s));
            //}
            result.sort();
            return result;
        } catch (QueryException e) {
            return new List<SelectOption>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Returns the set of user Ids belonging directly or indirectly to groups having given Ids.
    * Because a group can contain other groups, the method walks through all group members and
    * collects not only the users belonging directly to the group, but also belonging indirectly
    * (by being the members of the descendant groups).
    * Remarks: This is a recursive method - it can raise limit exceptions in case if the group
    * nesting level is high.
    * @param List<Id> groupIds
    * @return Set<Id>
    */
    public static Set<Id> getUserIdsFromGroupsByGroupIds(List<Id> groupIds) {
        Set<Id> result = new Set<Id>();
        for (GroupMember gm : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIds]) {
            Id uog = gm.UserOrGroupId;
            String s = (String) uog;
            if (s.startsWith(USER_PREFIX)) {
                result.add(uog);
            } else if (s.startsWith(GROUP_PREFIX)) {
                result.addAll(getUserIdsFromGroupsByGroupIds(new List<Id>{
                        uog
                }));
            }
        }
        return result;
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Returns the set of users belonging directly or indirectly to groups having given Ids.
    * Because a group can contain other groups, the method walks through all group members and
    * collects not only the users belonging directly to the group, but also belonging indirectly
    * (by being the members of the descendant groups).
    * Remarks: This method call other method which is a recursive method - it can raise limit
    * exceptions in case if the group nesting level is high.
    * @param List<Id> groupIds
    * @return Set<Id>
    */
    public static Set<User> getUsersFromGroupsByGroupIds(List<Id> groupIds) {
        try {
            Set<User> result = new Set<User>();
            List<Id> userIds = new List<Id>();
            userIds.addAll(getUserIdsFromGroupsByGroupIds(groupIds));
            for (User u : [SELECT Id, Name, IsActive, Profile_Name_gne__c FROM User WHERE Id IN :userIds]) {
                result.add(u);
            }
            return result;
        } catch (QueryException e) {
            return new Set<User>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Returns the set of users belonging directly or indirectly to groups having given names.
    * Because a group can contain other groups, the method walks through all group members and
    * collects not only the users belonging directly to the group, but also belonging indirectly
    * (by being the members of the descendant groups).
    * Remarks: This method call other method which is a recursive method - it can raise limit
    * exceptions in case if the group nesting level is high.
    * @param List<String> groupNames
    * @return Set<User>
    */
    public static Set<User> getUsersFromGroupsByGroupNames(List<String> groupNames) {
        try {
            List<Id> groupIds = new List<Id>();
            for (Group g : [SELECT Id FROM Group WHERE Name IN :groupNames]) {
                groupIds.add(g.Id);
            }
            return getUsersFromGroupsByGroupIds(groupIds);
        } catch (QueryException e) {
            return new Set<User>();
        }
    }

    /** @date 9/3/2012
    * @Author Pawel Sprysak
    * @description Returns the set of groups being queues assigned to objects with given type names.
    * @param List<String> objectTypeNames
    * @return Set<Group>
    */
    public static Set<Group> getQueuesForObjectTypes(List<String> objectTypeNames) {
        try {
            Set<Group> result = new Set<Group>();
            List<Id> qids = new List<Id>();
            for (QueueSobject q : [SELECT QueueId FROM QueueSobject WHERE SobjectType IN :objectTypeNames AND Queue.Name LIKE 'AGS_ST_%']) {
                qids.add(q.QueueId);
            }
            for (Group g : [SELECT Id, Name FROM Group WHERE Id IN :qids]) {
                result.add(g);
            }
            return result;
        } catch (QueryException e) {
            return new Set<Group>();
        }
    }

    public static Boolean updateUserActiveStatus(String userId, Boolean active) {
        try {
            User usr = findUserById(userId);
            usr.IsActive = active;
            update usr;

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static User findUserByUserName(String usrName) {
        try {
            User usr = [SELECT Id, Username FROM User WHERE Username = :usrName LIMIT 1];
            return usr;
        } catch (Exception e) {
            return null;
        }
    }

    public static AGS_ST_User_gne__c findAgsStUserByEmail(String email) {
        if (AGS_ST_Utils.hasValue(email)) {
            try {
                AGS_ST_User_gne__c agsStUser = [SELECT Id, First_name__c, Last_name__c, SFDC_User__r.Username, Email_address__c, SFDC_User__c, Mapped_Account__c FROM AGS_ST_User_gne__c WHERE SFDC_User__r.Email = :email];
                return agsStUser;
            } catch (QueryException e) {
                System.debug('No agsStUser found for email: ' + email + '. ' + e.getStackTraceString());
                return null;
            }
        }
        return null;
    }

    public static List<AGS_ST_HCP_HelpDesk_Comm_gne__c> getHelpDeskCommunicationsForStUsr(String agsStUsrId) {
        return [SELECT Id,Communication_Channel_gne__c,Communication_Note_gne__c,Communication_Reason_gne__c,CreatedDate FROM AGS_ST_HCP_HelpDesk_Comm_gne__c WHERE AGS_ST_User_gne__c = :agsStUsrId ORDER BY CreatedDate DESC];
    }

    public static List<AGS_ST_User_gne__c> getStForHelpDeskSeatch(String npiSearch, String firstNameSearch, String lastNameSearch, String usernameSearch, String citySearch, String stateSearch, String zipSearch, String stateLicenseNoSearch, String stateLicenseStateSearch, String gender) {
        CustomSOQLQuery csq = new customSOQLQuery();
        csq.fieldClauses = new List<String>{
                'NPI_gne__c', 'First_name__c', 'Last_name__c', 'SFDC_User__r.Username', 'AGS_ST_Registration_gne__r.City_gne__c', 'AGS_ST_Registration_gne__r.Gender_gne__c', 'AGS_ST_Registration_gne__r.State_gne__c', 'AGS_ST_Registration_gne__r.Zip_gne__c', 'State_License_gne__c', 'State_License_State_gne__c'
        };
        if (npiSearch != '') {
            csq.whereClauses.add('NPI_gne__c like \'' + npiSearch + '\'');
        }
        if (firstNameSearch != '') {
            csq.whereClauses.add('First_name__c like \'' + firstNameSearch + '\'');
        }
        if (lastNameSearch != '') {
            csq.whereClauses.add('Last_name__c like \'' + lastNameSearch + '\'');
        }
        if (usernameSearch != '') {
            csq.whereClauses.add('SFDC_User__r.Username like \'' + usernameSearch + '\'');
        }
        if (citySearch != '') {
            csq.whereClauses.add('AGS_ST_Registration_gne__r.City_gne__c like \'' + citySearch + '\'');
        }
        if (stateSearch != null) {
            csq.whereClauses.add('AGS_ST_Registration_gne__r.State_gne__c = \'' + stateSearch + '\'');
        }
        if (zipSearch != '') {
            csq.whereClauses.add('AGS_ST_Registration_gne__r.Zip_gne__c like \'' + zipSearch + '\'');
        }
        if (stateLicenseNoSearch != '') {
            csq.whereClauses.add('State_License_gne__c like \'' + stateLicenseNoSearch + '\'');
        }
        if (stateLicenseStateSearch != '') {
            csq.whereClauses.add('State_License_State_gne__c = \'' + stateLicenseStateSearch + '\'');
        }
        if (gender != null) {
            csq.whereClauses.add('AGS_ST_Registration_gne__r.Gender_gne__c = \'' + gender + '\'');
        }
        csq.addObjectApiName('AGS_ST_User_gne__c');
        System.debug('----csq.getQuery()' + csq.getQuery());
        return Database.query(csq.getQuery());
    }

    public static Id createAgsStUser(AGS_ST_User stUser) {
        System.debug('---st user --' + stUser);
        AGS_ST_Registration_gne__c registration = new AGS_ST_Registration_gne__c();
        registration.State_gne__c = stUser.state;
        registration.City_gne__c = stUser.city;
        registration.Street_Address_gne__c = stUser.suite + ' ' + stUser.street;
        registration.Zip_gne__c = stUser.zip;
        registration.ssn_gne__c = stUser.ssn;
        registration.dob_gne__c = AGS_ST_Utils.stringToDate(stUser.dob);
        if ((stUser.gender == null) || (stUser.gender == '')) {
            registration.Gender_gne__c = stUser.gender;
        }
        insert registration;
        AGS_ST_User_gne__c usr = new AGS_ST_User_gne__c();
        usr.Email_address__c = stUser.email;
        usr.First_name__c = stUser.firstName;
        usr.Last_name__c = stUser.lastName;
        usr.Mapped_Account__c = null; // it is updated in the next registration step
        usr.Phone_number__c = stUser.phone;
        usr.Phone_number_ext__c = '';
        usr.SFDC_User__c = null; // it is updated in the next registration step
        usr.NPI_gne__c = stUser.npi;
        usr.State_License_gne__c = stUser.stateLicence;
        usr.State_License_State_gne__c = stUser.licenceStateCode;
        usr.Communication_on_changes_gne__c = '';
        usr.Communication_When_Transfer_Posted_gne__c = '';
        usr.AGS_ST_Registration_gne__c = registration.Id;
        insert usr;
        return usr.Id;
    }

    public static Id createNewUserNonSSO(AGS_ST_User stUser, String userName, String profileName, String contactId, String roleName) {
        Id profileId = AGS_ST_DbUtils.findProfileIdByName(profileName);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.emailHeader.triggerUserEmail = false;
        User u = new User(
                Alias = 'standt',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                Email = stUser.email,
                LastName = stUser.lastName,
                FirstName = stUser.firstName,
                Phone = stUser.phone,
                Street = stUser.street,
                City = stUser.city,
                State = stUser.state,
                Username = userName,
                ProfileId = profileId,
                ContactId = contactId
        );
        u.setOptions(dmo);
        insert u;
        return u.Id;
    }

    public static Address_vod__c getGoldAddressByAccountId(Id acctId) {
        // 71% of the accounts have an address with the Gold Address indicator set, and the logic should choose these first.
        // If no address with the Gold Address indicator exists, then the logic should choose the address with the Shipping indicator set.
        // If no address with either the Gold Address or the Shipping address indicator exists, then it should select an address row having
        // the most recent update date, and the address selected will have one or more of the following indicators set: Business, Mailing, Primary, Home
        System.debug(' ------ accountID ' + acctId);
        List<Address_vod__c> addrs = [SELECT Id,LastModifiedDate,Name,City_vod__c,State_vod__c,Zip_vod__c,Business_vod__c,Mailing_vod__c,Primary_vod__c,Home_vod__c,AMS_gold_record_gne__c,Shipping_vod__c FROM Address_vod__c WHERE Account_vod__c = :acctId AND (Business_vod__c = TRUE OR Mailing_vod__c = TRUE OR Primary_vod__c = TRUE OR Home_vod__c = TRUE OR AMS_gold_record_gne__c = TRUE OR Shipping_vod__c = TRUE) ORDER BY LastModifiedDate DESC];//GOLD_RECORD_gne__c=true];
        Address_vod__c lastUpdated, shipping;
        for (Address_vod__c addr : addrs) {
            if (addr.AMS_gold_record_gne__c == true) {
                return addr;
            } else if (addr.Shipping_vod__c == true) {
                shipping = addr;
            } else if (lastUpdated == null) {
                lastUpdated = addr;
            }
        }
        if (shipping != null) {
            return shipping;
        } else if (lastUpdated != null) {
            return lastUpdated;
        } else {
            return new Address_vod__c();
        }
    }

    @Future
    public static void updateContactEmail(Id contactId, String contactEmail) {
        Contact c = [SELECT Id,Email FROM Contact WHERE Id = :contactId];
        c.Email = contactEmail;
        update c;
    }

    /** @date 4/10/2014
    * @Author Pawel Sprysak
    * @description Future method for updating CMS Payment Id and Home Payment Id on Disputes after chaning values on Spend Expense Transaction
    * @param List<Id> spendIds, Map<Id, String> cmsPaymentIdMap, Map<Id, String> homePaymentIdMap
    */
    @Future
    public static void updateCmsAndHomeDisputeValues(List<Id> spendIds, Map<Id, String> cmsPaymentIdMap, Map<Id, String> homePaymentIdMap) {
        try {
            List<AGS_ST_DisputeManagement_gne__c> disputesToUpdate = [
                    SELECT Id, CMS_Payment_ID_gne__c, Home_Payment_ID_gne__c, AGS_Spend_Expense_Transaction_gne__c
                    FROM AGS_ST_DisputeManagement_gne__c
                    WHERE AGS_Spend_Expense_Transaction_gne__c IN :spendIds
            ];
            if (disputesToUpdate.size() > 0) {
                for (AGS_ST_DisputeManagement_gne__c disp : disputesToUpdate) {
                    disp.CMS_Payment_ID_gne__c = cmsPaymentIdMap.get(disp.AGS_Spend_Expense_Transaction_gne__c);
                    disp.Home_Payment_ID_gne__c = homePaymentIdMap.get(disp.AGS_Spend_Expense_Transaction_gne__c);
                }
                update disputesToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error while trying to update CMS Payment ID and Home Payment ID.');
        }
    }
}