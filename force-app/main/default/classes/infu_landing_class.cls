public without sharing class infu_landing_class {
    static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
    static String DEFAULT_LOCALE_KEY = 'en_US';
    static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
    static String DEFAULT_LANG_LOC_KEY = 'en_US';

    public Pagereference autorun() {
        try {
            String usrUnixId = ApexPages.currentPage().getParameters().get('spenduser');
            system.debug('-----usrUnixId'+usrUnixId);
            All_User_Hierarchy_gne__c employee = getEmployees(usrUnixId);
            if(employee == null) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Employee does not exist.'));
                return null;
            }
            else if(!employee.Active_gne__c) {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Employee is not active.'));
                 return null;
            }
            User usr = getUser(usrUnixId);
            if(usr == null) {
                User newUser = createUser(employee);
                if(newUser == null) {
                    return null;
                }
            } else {
                if(!usr.IsActive) {
                    if(usr.Profile_Name_gne__c=='GNE-INFREQUENT-USER') {
                        activateUser(usr);
                    } else {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'Employee is not INFREQUENT user.'));
                        return null;
                    }
                }
            }
            string domainURL = '';
            MAP<String,AGS_Environment_Domain_gne__c> domains = AGS_Environment_Domain_gne__c.getAll();
            for(AGS_Environment_Domain_gne__c env_domain : domains.values()) {
                if (Site.getDomain().contains(env_domain.Site_Domain_gne__c)) {
                    domainURL = env_domain.SSO_Domain_gne__c;
                }
            }
            if(domainURL == '') {
                return null;
            }
            string targetPage = ApexPages.currentPage().getParameters().get('targetUrl');
            string caseId = ApexPages.currentPage().getParameters().get('caseid');
            string caseActionId = ApexPages.currentPage().getParameters().get('caseactionid');
            string interactionId = ApexPages.currentPage().getParameters().get('interactionid');
            string targetUrl = 'https://'+domainURL+targetPage+'?mode=confirm&usrUnixId='+usrUnixId+'&caseid=' + caseId; 
            targetUrl = targetUrl + '&caseactionid=' + caseActionId + '&interactionid=' + interactionId;
            PageReference pr = new PageReference(targetUrl);
            pr.setRedirect(true);
            return pr;
        } catch(Exception e) {
            return null;
        }
    }
    
    private void activateUser(User usr) {
        usr.IsActive = true;
        update usr;
    }
    
    private User getUser(String usrUnixId) {
        List<User> usrs = [Select id, name, isActive, Profile_Name_gne__c,External_ID_gne__c from user 
                            where External_ID_gne__c = :usrUnixId and UserType ='Standard' limit 1];
        if(usrs != null) {
            if(usrs.size() > 0) {
                return usrs[0];
            }
        }
        return null; 
    }
    
    private All_User_Hierarchy_gne__c getEmployees(String employee) {
        List<All_User_Hierarchy_gne__c> employees = [Select id, email_id__c,FirstName_gne__c,
                                                    LastName_gne__c,Active_gne__c,
                                                    User_External_Id_gne__c from All_User_Hierarchy_gne__c 
                                                    where (User_External_Id_gne__c = :employee and User_External_Id_gne__c !='') limit 1];
        if(employees != null) {
            if(employees.size()>0) {
                return employees[0];
            }
        }
        system.debug('---------------employees'+employees);
        return null;
    }
    
    private User createUser(All_User_Hierarchy_gne__c employee) {
        system.debug('-------employees'+employee);
        List<UserRole> stdRoles = [Select Id, name from UserRole where name = 'Standard User'];
        if (stdRoles.size() < 1) {
            return null;
        }  
        String domain = '';
        MAP<String,AGS_Environment_Domain_gne__c> domains = AGS_Environment_Domain_gne__c.getAll();
        for(AGS_Environment_Domain_gne__c env_domain : domains.values()) {
            if (Site.getDomain().contains(env_domain.Site_Domain_gne__c)) {
                domain = env_domain.Domain_gne__c;
            }
        }
        if(domain=='') {
            return null;
        }
        try {
            User newUser = new User();
            newUser.FirstName = employee.FirstName_gne__c;
            newUser.LastName = employee.LastName_gne__c;
            newUser.alias = employee.User_External_Id_gne__c;
            newUser.username = employee.User_External_Id_gne__c + domain;
            newUser.email = employee.email_id__c;
            newUser.TimeZoneSidKey = DEFAULT_TIME_ZN;
            newUser.LocaleSidKey = DEFAULT_LOCALE_KEY;
            newUser.EmailEncodingKey = DEFAULT_EMAIL_KEY;
            newUser.LanguageLocaleKey = DEFAULT_LANG_LOC_KEY;        
            newUser.CommunityNickname = employee.User_External_Id_gne__c;  
            newUser.External_ID_gne__c = employee.User_External_Id_gne__c;
            List<Profile> profiles = [Select Id, name from Profile where name = 'GNE-INFREQUENT-USER'];
            newUser.ProfileId = profiles[0].Id;
            newUser.IsActive = true;
            newUser.UserRoleId = stdRoles[0].Id;
            insert newUser;
            return newUser;
        } catch(Exception e) {
            return null;
        }
    }
}