global without sharing class Concur_SFDC_redir {
    static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
    static String DEFAULT_LOCALE_KEY = 'en_US';
    static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
    static String DEFAULT_LANG_LOC_KEY = 'en_US';
    final static String CONCUR_PERMISSION_SET_NAME = 'CONCUR_User_gne';

    public PageReference autorun() {
        String itemUrl = ApexPages.currentPage().getParameters().get('itemurl');
        String xUserId = ApexPages.currentPage().getParameters().get('xuserid');
        try {
            Map<String, All_User_Hierarchy_gne__c> usersToCreate = new Map<String, All_User_Hierarchy_gne__c>();
            Map<String, User> createdUsers;
            List<User> usersToActivate = new List<User>();

            //call to Concur webservice
            Map<String, String> expense_details = Concur_WebServicesCalls.expenseEntryDetails(xUserId, itemUrl);
            System.debug('------------expense_details' + expense_details);
            if (expense_details == null || expense_details.isEmpty()) {
                insertErrorFuture('Concur_SFDC_redir', 'webServiceGet', 'Bad response', 'autorun', 'HttpRequest',
                        'Bad response', '', itemUrl, xUserId, '900');
                PageReference pr = new PageReference('/concur_errorpage?errorCode=900');
                pr.setRedirect(true);
                return pr;
            }

            String creatorPersId = '';
            String ownerUnixId = '';
            if (String.isNotBlank(xUserId)) {
                creatorPersId = xUserId.substring(0, xUserId.indexOf('@')); //creator persistent id
            }
            String ownerWs = expense_details.get('OwnerWs');
            if (String.isNotBlank(ownerWs)) {
                ownerUnixId = ownerWs; //owner unix id
            }
            Map<String, All_User_Hierarchy_gne__c> employees = getEmployees(creatorPersId, ownerUnixId);
            All_User_Hierarchy_gne__c creatorAUH = employees.get(creatorPersId);
            All_User_Hierarchy_gne__c ownerAUH = employees.get(ownerUnixId);
            Map<String, User> validUsers = new Map<String, User>();
            System.debug('-------------------creatorAUH' + creatorAUH);
            System.debug('-------------------ownerAUH' + ownerAUH);
            Map<String, String> MapAUH = new Map<String, String>();
            Boolean ownerEqualCreator = false;
            if (creatorAUH == null) {//if creator does not exist
                insertErrorFuture('Concur_SFDC_redir', 'Employee', 'Creator does not exist in AUH', 'autorun',
                        'All_User_Hierarchy', 'Creator not exist in AUH', ''
                        , itemUrl, xUserId, '201');
                PageReference pr = new PageReference('/concur_errorpage?errorCode=201');
                pr.setRedirect(true);
                return pr;
            } else if (!creatorAUH.Active_gne__c) {//if creator is no longer employee
                insertErrorFuture('Concur_SFDC_redir', 'Employee', 'Creator inactive in AUH', 'autorun',
                        'All_User_Hierarchy', 'Creator inactive in AUH', ''
                        , itemUrl, xUserId, '202');
                PageReference pr = new PageReference('/concur_errorpage?errorCode=202');
                pr.setRedirect(true);
                return pr;
            } else {
                MapAUH.put(creatorAUH.User_External_Id_gne__c, creatorAUH.Persistent_Id_gne__c);
            }
            if (String.isNotBlank(ownerWs)) {
                if (ownerAUH == null) {//if owner does not exist in AUH
                    insertErrorFuture('Concur_SFDC_redir', 'Employee', 'Owner not exists in AUH', 'autorun',
                            'All_User_Hierarchy', 'Owner does not exist in AUH', 'creator unixid ' + creatorAUH.User_External_Id_gne__c
                            , itemUrl, xUserId, '203');
                    PageReference pr = new PageReference('/concur_errorpage?errorCode=203');
                    pr.setRedirect(true);
                    return pr;
                }
                if (ownerAUH.User_External_Id_gne__c != creatorAUH.User_External_Id_gne__c) // if owner is different than creator
                {
                    if (!ownerAUH.Active_gne__c) //if owner is no longer employee
                    {
                        insertErrorFuture('Concur_SFDC_redir', 'Employee', 'Owner inactive in AUH', 'autorun',
                                'All_User_Hierarchy', 'Owner inactive in AUH', 'creator unixid ' + creatorAUH.User_External_Id_gne__c
                                , itemUrl, xUserId, '204');
                        PageReference pr = new PageReference('/concur_errorpage?errorCode=204');
                        pr.setRedirect(true);
                        return pr;
                    } else {
                        MapAUH.put(ownerAUH.User_External_Id_gne__c, ownerAUH.Persistent_Id_gne__c);
                    }
                } else {
                    ownerEqualCreator = true; //owner equal creator
                }
            }
            System.debug('----------MapAUH' + MapAUH);
            Map<String, User> users = getUsers(MapAUH);   // checking user accounts for owner/creator
            User creator = users.get(creatorAUH.Persistent_Id_gne__c);
            System.debug('------------------creator' + creator);
            System.debug('------------------users' + users);
            if (creator != null) {
                if (!creator.IsActive) {
                    usersToActivate.add(creator);
                }
                validUsers.put(creatorAUH.Persistent_Id_gne__c, creator);
            } else {
                System.debug('----------usr creation');
                usersToCreate.put(creatorAUH.User_External_Id_gne__c, creatorAUH);
            }
            if (String.isNotBlank(ownerWs) && ownerAUH != null && !ownerEqualCreator) {
                User owner = users.get(ownerAUH.Persistent_Id_gne__c);
                if (owner != null) {
                    if (!owner.IsActive) {
                        usersToActivate.add(owner);
                    }
                    validUsers.put(ownerAUH.Persistent_Id_gne__c, owner);
                } else {
                    System.debug('---------------owner creatrion');
                    usersToCreate.put(ownerAUH.User_External_Id_gne__c, ownerAUH);
                }

            }
            if (usersToActivate.size() > 0) {
                activateUsers(usersToActivate);
            }
            System.debug('-------------usersToCreate' + usersToCreate);
            if (usersToCreate.size() > 0) {
                createdUsers = createUsers(usersToCreate, creatorPersId,
                        ownerAUH.Persistent_Id_gne__c);
                if (createdUsers != null) {
                    if (createdUsers.size() != usersToCreate.size()) //should be the same # of users created and need to be created
                    {
                        PageReference pr = new PageReference('/concur_errorpage?errorCode=700');
                        pr.setRedirect(true);
                        return pr;
                    }
                } else {
                    PageReference pr = new PageReference('/concur_errorpage?errorCode=700');
                    pr.setRedirect(true);
                    return pr;
                }
                for (String persistent_id : createdUsers.keySet()) {
                    validUsers.put(persistent_id, createdUsers.get(persistent_id));
                }
            }
            //add users to the table to efficiently deactivate them in the batch
            Set<Id> createdAndActivatedUsers = new Set<Id>();
            if (createdUsers != null) {
                for (User u : createdUsers.values()) {
                    createdAndActivatedUsers.add(u.Id);
                }
            }
            if (usersToActivate != null) {
                for (User u : usersToActivate) {
                    createdAndActivatedUsers.add(u.Id);
                }
            }
            addCreatedAndActivatedUsersToTable(createdAndActivatedUsers);
            //

            ownerAUH = (ownerAUH == null) ? creatorAUH : ownerAUH;

            assignPermissionSet(creator);

            System.debug('-------------validUsers' + validUsers);
            String url_parameters = '?ExpenseType=' + expense_details.get('ExpenseName');
            url_parameters += '&ExpKey=' + expense_details.get('ExpenseKey');
            url_parameters += '&ItemUrl=' + itemUrl;
            url_parameters += '&ReportCreator=' + validUsers.get(creatorPersId).Id;
            url_parameters += '&ReportOwner=' + getOwner(validUsers.get(ownerAUH.Persistent_Id_gne__c));
            url_parameters += '&TransactionAmount=' + expense_details.get('TransactionAmount');
            url_parameters += '&Amount=' + expense_details.get('PostedAmount');
            url_parameters += '&TransactionDate=' + expense_details.get('TransactionDate').substring(0, expense_details.get('TransactionDate').indexOf('T'));
            url_parameters += '&XUserID=' + xUserId;
            url_parameters += '&LocationName=' + expense_details.get('LocationName');
            url_parameters += '&TimeStamp=' + Datetime.now();
            url_parameters += '&OwnerPersId=' + ownerAUH.Persistent_Id_gne__c + '@roche.com';

            System.debug('----------url_parameters' + url_parameters);
            String env = GlobalUtils.getEnvironment();
            System.debug('-----------env' + env);
            String domainURL = '';

            Map<String, Concur_Environment_Domain_gne__c> domains = Concur_Environment_Domain_gne__c.getAll();
            for (Concur_Environment_Domain_gne__c env_domain : domains.values()) {
                if (Site.getDomain().contains(env_domain.Site_Domain_gne__c)) {
                    domainURL = env_domain.SSO_Domain_gne__c;
                }
            }
            if (domainURL == '') {
                insertErrorFuture('Concur_SFDC_redir', 'Redir', 'Redirect problem', 'autorun',
                        'None', 'Salesforce my domain does not exist', 'Site domain ' + Site.getDomain()
                        , itemUrl, xUserId, '601');
                PageReference pr = new PageReference('/concur_errorpage?errorCode=601');
                pr.setRedirect(true);
                return pr;
            }
            System.debug('-----------domainURL' + domainURL);
            if (expense_details.get('ExpenseName').trim() == 'Business Meal with HCPs') //Business Meal with HCPs
            {
                PageReference pr = new PageReference('https://' + domainURL + '/apex/ConcurHCPmealsPage' + url_parameters);
                pr.setRedirect(true);
                return pr;
            } else if (expense_details.get('ExpenseName').trim() == 'Logistics for HCP Programs') {
                PageReference pr = new PageReference('https://' + domainURL + '/apex/ConcurHCPProgramLogistics' + url_parameters);
                pr.setRedirect(true);
                return pr;
            } else if (expense_details.get('ExpenseName').trim() == 'Business Meals at HCP Programs') {
                PageReference pr = new PageReference('https://' + domainURL + '/apex/ConcurHCPProgramMeals' + url_parameters);
                pr.setRedirect(true);
                return pr;
            } else {
                insertErrorFuture('Concur_SFDC_redir', 'Redir', 'Redirect problem', 'autorun',
                        'None', 'There was a problem with redirect', 'Expense Name ' + expense_details.get('ExpenseName').trim() + ', Domain ' + domainURL + ',URL parameters ' + url_parameters
                        , itemUrl, xUserId, '601');
                PageReference pr = new PageReference('/concur_errorpage?errorCode=601');
                pr.setRedirect(true);
                return pr;
            }
        } catch (Exception e) {
            insertErrorFuture('Concur_SFDC_redir', 'User', 'Problem with redirect', 'autorun', 'User', e.getMessage(), e.getStackTraceString()
                    , itemUrl, xUserId, '600');
            PageReference pr = new PageReference('/concur_errorpage?errorCode=600');
            pr.setRedirect(true);
            return pr;
        }
    }

    private void assignPermissionSet(User u) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :CONCUR_PERMISSION_SET_NAME];
        List<PermissionSetAssignment> existingAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :ps.Id];
        if (existingAssignments.isEmpty()) {
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        }
    }

    private Map<String, All_User_Hierarchy_gne__c> getEmployees(String creator, String
            owner) {
        List<All_User_Hierarchy_gne__c> employees = [
                SELECT Id, email_id__c, FirstName_gne__c,
                        LastName_gne__c, Persistent_Id_gne__c, Active_gne__c,
                        User_External_Id_gne__c
                FROM All_User_Hierarchy_gne__c
                WHERE (Persistent_Id_gne__c = :creator AND Persistent_Id_gne__c != '')
                OR (User_External_Id_gne__c = :owner AND User_External_Id_gne__c != '')
        ];
        System.debug('---------------employees' + employees);
        Map<String, All_User_Hierarchy_gne__c> employeesMap = new Map<String, All_User_Hierarchy_gne__c>();
        for (All_User_Hierarchy_gne__c employee : employees) {
            if (employee.Persistent_Id_gne__c == creator) {
                employeesMap.put(employee.Persistent_Id_gne__c, employee);
            }
            if (employee.User_External_Id_gne__c == owner) {
                employeesMap.put(employee.User_External_Id_gne__c, employee);
            }
        }
        return employeesMap;
    }

    private Map<String, User> getUsers(Map<String, String> MapAUH) {
        List<User> users = [
                SELECT Id, Name, IsActive, Profile_Name_gne__c, External_ID_gne__c
                FROM User
                WHERE External_ID_gne__c IN :MapAUH.keySet() AND UserType = 'Standard'
        ];
        Map<String, User> usersMap = new Map<String, User>();
        for (User usr : users) {
            usersMap.put(MapAUH.get(usr.External_ID_gne__c), usr);
            System.debug('------------MapAUH.get(usr.External_ID_gne__c)' + MapAUH.get(usr.External_ID_gne__c));
        }
        return usersMap;
    }

    private void activateUsers(List<User> usersToActivate) {
        System.debug('----------usersToActivate' + usersToActivate);
        String usernames = '';
        try {
            for (User usr : usersToActivate) {
                usr.IsActive = true;
                usernames = +usr.Name + ',';
            }
            update usersToActivate;
        } catch (Exception e) {
            System.debug(e);
            insertErrorFuture('Concur_SFDC_redir', 'User', 'Problem with user activation', 'activateUsers', 'User', e.getMessage(), 'User names to activate' + usernames, ApexPages.currentPage().getParameters().get('itemurl'), ApexPages.currentPage().getParameters().get('xuserid'), '600');
        }
    }

    private Map<String, User> createUsers(Map<String, All_User_Hierarchy_gne__c> employees, String creator, String owner) {
        System.debug('-------employees' + employees);
        List<User> users = new List<User>();
        Map<String, User> createdUsers = new Map<String, User>();
        List<UserRole> stdRoles = [SELECT Id, Name FROM UserRole WHERE Name = 'Standard User'];
        if (stdRoles.size() < 1) {
            return createdUsers;
        }
        String domain = '';

        Map<String, Concur_Environment_Domain_gne__c> domains = Concur_Environment_Domain_gne__c.getAll();
        for (Concur_Environment_Domain_gne__c env_domain : domains.values()) {
            if (Site.getDomain().contains(env_domain.Site_Domain_gne__c)) {
                domain = env_domain.Domain_gne__c;
            }
        }
        String itemUrl = ApexPages.currentPage().getParameters().get('itemurl');
        String xUserId = ApexPages.currentPage().getParameters().get('xuserid');
        if (domain == '') {
            insertErrorFuture('Concur_SFDC_redir', 'User', 'Problem in user creation', 'createUsers', 'User', 'Problem with domain', 'creator ' + creator + ',owner ' + owner + ',Site domain ' + Site.getDomain()
                    , itemUrl, xUserId, '601');
            return null;
        }
        try {
            for (All_User_Hierarchy_gne__c employee : employees.values()) {
                User newUser = new User();
                newUser.FirstName = employee.FirstName_gne__c;
                newUser.LastName = employee.LastName_gne__c;
                newUser.Alias = employee.User_External_Id_gne__c;
                newUser.Username = employee.User_External_Id_gne__c + domain;
                newUser.Email = employee.email_id__c;
                newUser.TimeZoneSidKey = DEFAULT_TIME_ZN;
                newUser.LocaleSidKey = DEFAULT_LOCALE_KEY;
                newUser.EmailEncodingKey = DEFAULT_EMAIL_KEY;
                newUser.LanguageLocaleKey = DEFAULT_LANG_LOC_KEY;
                newUser.CommunityNickname = employee.User_External_Id_gne__c;
                newUser.External_ID_gne__c = employee.User_External_Id_gne__c;
                List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-INFREQUENT-USER'];
                newUser.ProfileId = profiles[0].Id;
                newUser.IsActive = true;
                newUser.UserRoleId = stdRoles[0].Id;
                users.add(newUser);
            }
            insert users;
            for (User usr : users) {
                createdUsers.put(employees.get(usr.External_ID_gne__c).Persistent_Id_gne__c, usr);
            }
            System.debug('------------createdUsers' + createdUsers);
            return createdUsers;
        } catch (Exception e) {
            insertErrorFuture('Concur_SFDC_redir', 'User', 'Problem with user creation', 'createUsers', 'User', e.getMessage(), 'creator ' + creator + ',owner ' + owner + ',Site domain ' + Site.getDomain()
                    , itemUrl, xUserId, '700');
            return null;
        }
    }

    private Id getOwner(User owner) {
        if (owner != null) {
            return owner.Id;
        } else {
            return null;
        }
    }

    @Future
    private static void addCreatedAndActivatedUsersToTable(Set<Id> userIds) {
        List<GNE_Concur_User__c> toInsert = new List<GNE_Concur_User__c>();
        for (Id uId : userIds) {
            toInsert.add(new GNE_Concur_User__c(User_gne__c = uId));
        }
        if (!toInsert.isEmpty()) {
            Database.insert(toInsert, false);
        }
    }

    @Future
    public static void insertErrorFuture(String className, String errorCategory, String errorMessage, String methodName, String objectName, String systemErrorMessage, String Content, String ItemUrl, String XUserID, String ErrorCode) {
        ItemUrl = ItemUrl == null ? ItemUrl : ItemUrl.substring(0, Math.min(254, ItemUrl.length()));
        Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c = className,
                Error_Category_gne__c = errorCategory, Error_Message_gne__c = errorMessage, Method_Name_gne__c = methodName,
                Object_Name_gne__c = objectName, System_Error_Message_gne__c = systemErrorMessage, Content_gne__c = Content, Item_Url_gne__c = ItemUrl, XUserID_gne__c = XUserID, Error_Code_gne__c = ErrorCode);
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        dml.optAllOrNone = false;
        Database.insert(error, dml);
    }
}