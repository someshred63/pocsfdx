public without sharing class Concur_SFDC_redir_Test 
{ 
    static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
    static String DEFAULT_LOCALE_KEY = 'en_US';
    static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
    static String DEFAULT_LANG_LOC_KEY = 'en_US';
    
    public static string ownerId = '';
    
    public Pagereference autorun()
    {
        try
        {
            Map<String,All_User_Hierarchy_gne__c> usersToCreate = new Map<String,All_User_Hierarchy_gne__c>();
            List<User> usersToActivate = new List<User>();
            
            Concur_WebServicesCalls concur_ws = new Concur_WebServicesCalls();
            
            Map<String,String> expense_details = concur_ws.expenseEntryDetailsForTest(ApexPages.currentPage().getParameters().get('xuserid'),
                                                                               ApexPages.currentPage().getParameters().get('itemurl'),ownerId);
            /*
            if(ApexPages.currentPage().getParameters().get('itemurl').contains('Itemizations'))
            {
                expense_details = concur_ws.itemization(ApexPages.currentPage().getParameters().get('xuserid'),
                                                        ApexPages.currentPage().getParameters().get('itemurl'),ownerId);
            }*/
            system.debug('------------expense_details'+expense_details);
            if(expense_details == null)
            {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'900'));
                return null;
            }
            else if(expense_details.size() < 1)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'900'));
                return null;
            }
            
            string creatorPersId = '';
            string ownerUnixId = '';
            if(ApexPages.currentPage().getParameters().get('xuserid') !=null && ApexPages.currentPage().getParameters().get('xuserid') != '')
            {
                creatorPersId = ApexPages.currentPage().getParameters().get('xuserid').substring(0,ApexPages.currentPage().getParameters().get('xuserid').indexOf('@'));
            }
            if(expense_details.get('OwnerWs') !=null && expense_details.get('OwnerWs') != '')
            {
                ownerUnixId = expense_details.get('OwnerWs');
            }
            Map<String,All_User_Hierarchy_gne__c> employees = getEmployees(creatorPersId,ownerUnixId);
            All_User_Hierarchy_gne__c creatorAUH = employees.get(creatorPersId);
            All_User_Hierarchy_gne__c ownerAUH = employees.get(ownerUnixId);
            Map<String,User> validUsers = new Map<String,User>();
            system.debug('-------------------creatorAUH'+creatorAUH);
            system.debug('-------------------ownerAUH'+ownerAUH);
            Map<String,String> MapAUH = new Map<String,String>();
            boolean ownerEqualCreator = false;
            if(creatorAUH==null)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'201'));
                return null;
            }
            else if(!creatorAUH.Active_gne__c)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'202'));
                return null;
            }
            else
            {
                MapAUH.put(creatorAUH.User_External_Id_gne__c,creatorAUH.Persistent_Id_gne__c);
            }
            if(expense_details.get('ExpenseName') == 'Business Meal with HCPs')//Business Meal with HCPs
            {
                if(expense_details.get('OwnerWs') != null && expense_details.get('OwnerWs') != '')
                {
                    if(ownerAUH == null)
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'203'));
                        return null;
                    }
                    if(ownerAUH.User_External_Id_gne__c != creatorAUH.User_External_Id_gne__c)
                    {
                        if(!ownerAUH.Active_gne__c)
                        {
                            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'204'));
                            return null;
                        }
                        else
                        {
                            MapAUH.put(ownerAUH.User_External_Id_gne__c,ownerAUH.Persistent_Id_gne__c);
                        }
                    }
                    else
                    {
                        ownerEqualCreator = true;
                    }
                }
            }
            system.debug('----------MapAUH'+MapAUH);
            Map<String,User> users = getUsers(MapAUH);  
            User creator = users.get(creatorAUH.Persistent_Id_gne__c); 
            system.debug('------------------creator'+creator); 
            system.debug('------------------users'+users);
            if(creator != null) 
            {
                if(!creator.IsActive)
                {
                    if(creator.Profile_Name_gne__c=='GNE-INFREQUENT-USER')
                    {
                        usersToActivate.add(creator);
                    }
                    else
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'205'));
                        return null;
                    }
                }
                validUsers.put(creatorAUH.Persistent_Id_gne__c,creator);
            }
            else
            {
                system.debug('----------usr creation');
                usersToCreate.put(creatorAUH.User_External_Id_gne__c,creatorAUH);
            }
            if(expense_details.get('ExpenseName') == 'Business Meal with HCPs') //Business Meal with HCPs
            {
                if(expense_details.get('OwnerWs') != null && expense_details.get('OwnerWs') != '')
                {
                    if(ownerAUH !=null && !ownerEqualCreator)  
                    {
                        User owner = users.get(ownerAUH.Persistent_Id_gne__c); 
                        if(owner != null)   
                        {
                            if(!owner.IsActive)
                            {
                                if(owner.Profile_Name_gne__c=='GNE-INFREQUENT-USER')
                                {
                                    usersToActivate.add(owner);
                                }
                                else
                                {
                                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'206'));
                                    return null;
                                }
                            }
                            validUsers.put(ownerAUH.Persistent_Id_gne__c,owner);
                        }
                        else
                        { 
                            system.debug('---------------owner creatrion');
                            usersToCreate.put(ownerAUH.User_External_Id_gne__c,ownerAUH);
                        }
                    }
                }
            }
            if(usersToActivate.size()>0)
            {
                activateUsers(usersToActivate);
            }
            system.debug('-------------usersToCreate'+usersToCreate);
            if(usersToCreate.size()>0)
            {
                Map<String,User> createdUsers = createUsers(usersToCreate,creatorPersId,
                                                            ownerAUH.Persistent_Id_gne__c);
                if(createdUsers != null)
                {
                    if(createdUsers.size() != usersToCreate.size())
                    {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'700'));
                        return null;
                    }
                }
                else
                {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'700'));
                    return null;
                }
                for(String persistent_id:createdUsers.keySet())
                {
                    validUsers.put(persistent_id,createdUsers.get(persistent_id));
                }
            }
            system.debug('-------------validUsers'+validUsers);
            string url_parameters = '?ExpenseType='+expense_details.get('ExpenseName');
            url_parameters += '&ExpKey='+expense_details.get('ExpenseKey');
            url_parameters += '&ItemUrl='+ApexPages.currentPage().getParameters().get('itemurl');
            url_parameters += '&ReportCreator='+validUsers.get(creatorPersId).id;
            url_parameters += '&ReportOwner='+getOwner(validUsers.get(ownerAUH.Persistent_Id_gne__c));
            url_parameters += '&TransactionAmount='+expense_details.get('TransactionAmount');
            url_parameters += '&Amount='+expense_details.get('PostedAmount');
            url_parameters += '&TransactionDate='+expense_details.get('TransactionDate').substring(0,expense_details.get('TransactionDate').indexOf('T'));
            url_parameters += '&XUserID='+ApexPages.currentPage().getParameters().get('xuserid');
            url_parameters += '&TimeStamp='+datetime.now();
            system.debug('----------url_parameters'+url_parameters);
            String env = GlobalUtils.getEnvironment();
            system.debug('-----------env'+env);
            string domainURL = '';
            
            MAP<String,Concur_Environment_Domain_gne__c> domains = Concur_Environment_Domain_gne__c.getAll();
            for(Concur_Environment_Domain_gne__c env_domain : domains.values())
            {
                if (env_domain.Name.contains(env))
                {
                    domainURL = env_domain.SSO_Domain_gne__c;
                }
            }
            if(domainURL == '')
            {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'602'));
                return null;
            }
            system.debug('-----------domainURL'+domainURL);
            if(expense_details.get('ExpenseName').trim() == 'Business Meal with HCPs') //Business Meal with HCPs
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM ,'redirected to Business Meal with HCPs'));
                return null;
                //PageReference pr = new PageReference('/apex/ConcurHCPmealsPage'+url_parameters);
                //pr.setRedirect(true);
                //return pr;
            }
            else if(expense_details.get('ExpenseName').trim() == 'Logistics for HCP Programs')
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM ,'redirected to Logistics for HCP Programs'));
                return null;
            }
            else if(expense_details.get('ExpenseName').trim() == 'Business Meals at HCP Programs')  
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM ,'redirected to Business Meals at HCP Programs'));
                return null;
            }
            else
            {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'601'));
                return null;
            }
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,'600'));
            return null;
        } 
    }
    
    private Map<String,All_User_Hierarchy_gne__c> getEmployees(String creator,String owner)
    {
        List<All_User_Hierarchy_gne__c> employees = [Select id, email_id__c,FirstName_gne__c,
                                                    LastName_gne__c,Persistent_Id_gne__c,Active_gne__c,
                                                    User_External_Id_gne__c from All_User_Hierarchy_gne__c 
                                                    where (Persistent_Id_gne__c = :creator and Persistent_Id_gne__c != '')
                                                     or (Persistent_Id_gne__c = :owner and Persistent_Id_gne__c !='')];
        system.debug('---------------employees'+employees);
        Map<String,All_User_Hierarchy_gne__c> employeesMap = new Map<string,All_User_Hierarchy_gne__c>();
        for(All_User_Hierarchy_gne__c employee: employees)
        {
            if(employee.Persistent_Id_gne__c == creator)
            {
                employeesMap.put(employee.Persistent_Id_gne__c,employee);
            } 
            if(employee.User_External_Id_gne__c == owner)
            {
                employeesMap.put(employee.User_External_Id_gne__c,employee);
            }
        }
        return employeesMap;
    }
    
    private Map<String,User> getUsers(Map<String,String> MapAUH)
    {
        
        List<User> users = [Select id, name, isActive, Profile_Name_gne__c,External_ID_gne__c from user 
                            where External_ID_gne__c in :MapAUH.keySet()];
        Map<String,User> usersMap = new Map<string,User>();
        for(User usr: users)
        {
            usersMap.put(MapAUH.get(usr.External_ID_gne__c),usr);
            system.debug('------------MapAUH.get(usr.External_ID_gne__c)'+MapAUH.get(usr.External_ID_gne__c));  
        }
        return usersMap;
    }
    
    private void activateUsers(List<User> usersToActivate)
    {
        system.debug('----------usersToActivate'+usersToActivate);
        try
        {
            for(User usr:usersToActivate)
            {
                usr.isActive = true;
            }
            //update usersToActivate;
        }
        catch(Exception e)
        {
        } 
    }
    
    private Map<String,User> createUsers(Map<String,All_User_Hierarchy_gne__c> employees,string creator, string owner)
    {
        system.debug('-------employees'+employees);
        List<User> users = new List<User>();
        Map<String,User> createdUsers = new Map<String,User>();
        List<UserRole> stdRoles = [Select Id, name from UserRole where name = 'Standard User'];
        if (stdRoles.size() < 1)
        {
            return createdUsers;
        }  
        String domain = '';
        String env = GlobalUtils.getEnvironment();
        MAP<String,Concur_Environment_Domain_gne__c> domains = Concur_Environment_Domain_gne__c.getAll();
        for(Concur_Environment_Domain_gne__c env_domain : domains.values())
        {
            if (env_domain.Name.contains(env))
            {
                domain = env_domain.Domain_gne__c;
            }
        }
        if(domain=='')
        {
            return null;
        }
        try
        {
            for(All_User_Hierarchy_gne__c employee: employees.values())
            {
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
                users.add(newUser);
            }
            //insert users;
            for(User usr: users)
            {
                createdUsers.put(employees.get(usr.External_Id_gne__c).Persistent_Id_gne__c,usr);
            }
            system.debug('------------createdUsers'+createdUsers);
            return createdUsers;
        }
        catch(Exception e)
        {
            return null;
        }
    } 
    
    private Date getTransactionDate(String dateString)
    {
        String day = dateString.substring(dateString.lastIndexOf('-')+1,dateString.length());
        String month = dateString.substring(dateString.indexOf('-')+1,dateString.lastIndexOf('-'));
        String year = dateString.substring(0,dateString.indexOf('-'));
        String validDate = month + '/' + day + '/' + year;
        system.debug('------------validdate'+validDate);
        return date.parse(validDate);
    }
    
    private ID getOwner(User owner)
    {
        if(owner!=null)
        {
            return owner.id;
        }
        else
        {
            return null;
        }
    }
    
    public PageReference mainForTest(String ownerUnixId)
    {
        ownerId = ownerUnixId;
        PageReference pr = autorun();
        return pr;
    }
}