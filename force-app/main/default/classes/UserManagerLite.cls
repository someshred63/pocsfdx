global without sharing class UserManagerLite
{ 
    static String DEFAULT_TIME_ZN = 'America/Los_Angeles';
    static String DEFAULT_LOCALE_KEY = 'en_US';
    static String DEFAULT_EMAIL_KEY = 'ISO-8859-1';
    static String DEFAULT_LANG_LOC_KEY = 'en_US';
    public static String X_UserID { get; set; }
   
    public Pagereference autorun()
    {
        try
        {
            Concur_WebServicesCalls cw = new Concur_WebServicesCalls();
            //string o = itemization('443426@roche.com','https://implementation.concursolutions.com/api/expense/expensereport/v1.1/report/n$pSkLiyn6MxYnpEhVm$pc$pBO6GUja$s$scEL/entry/n6WTCxtvPWqnuZdbNxn9fPXYk2asFIrH8');
            
            // string id = 'a7fQ00000004CNJIA2';
            //List<Concur_Expense_Post_gne__c> ce = [Select c.Amount_gne__c, c.Business_Purpose__c, c.Concur_Expense_gne__c, c.CreatedDate, c.Expense_Status_gne__c, c.ExpKey_gne__c, c.Id, c.Interaction_Name_Aprimo_Site_ID_gne__c, c.Item_Url_gne__c, c.Link_to_HCP_Interaction__c, c.Link_to_HCP_Program__c, c.Name, c.SFDC_Attendee_Count_gne__c, c.SFDC_Expense_Type_gne__c, c.SFDC_Transaction_Date_gne__c, c.Transaction_Amount_gne__c, c.XUserID_gne__c from Concur_Expense_Post_gne__c c where id = :id];
            //string o = cw.postExpenseReport(ce[0]);
            //string o = expenseEntryDetails('628173@roche.com','https://implementation.concursolutions.com/api/expense/expensereport/v1.1/report/n$pSkLiyn6MReFZ6EUQbQJlDC8sdcL0iOG/entry/n6WTCxtvOK99uhqtinRiQKe2IpGd9xJ67');
            string xuserid = ApexPages.currentPage().getParameters().get('xuserid');
			string itemurl = ApexPages.currentPage().getParameters().get('itemurl'); 
			string o = expenseEntryDetails(xuserid,itemurl);
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR ,o));
            return null;
        }
        catch(Exception e)
        {
            Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c='UserManagerLite',Error_Category_gne__c='',
            Error_Message_gne__c='',Method_Name_gne__c= '', Object_Name_gne__c='',System_Error_Message_gne__c='');
            insert error;
            return null;
        } 
    }
    
    private Map<String,All_User_Hierarchy_gne__c> getEmployees(String creator,String owner)
    {
        List<All_User_Hierarchy_gne__c> employees = [Select id, email_id__c,FirstName_gne__c,LastName_gne__c,Persistent_Id_gne__c,Active_gne__c,User_External_Id_gne__c from All_User_Hierarchy_gne__c where (Persistent_Id_gne__c = :creator and Persistent_Id_gne__c != '') or (User_External_Id_gne__c = :owner)];
        system.debug('---------------employees'+employees);
        Map<String,All_User_Hierarchy_gne__c> employeesMap = new Map<string,All_User_Hierarchy_gne__c>();
        for(All_User_Hierarchy_gne__c employee: employees)
        {
            if(employee.Persistent_Id_gne__c == creator)
                employeesMap.put(employee.Persistent_Id_gne__c,employee);  
            if(employee.User_External_Id_gne__c == owner)
                employeesMap.put(employee.User_External_Id_gne__c,employee);  
        }
        return employeesMap;
    }
    
    private Map<String,User> getUsers(Map<String,String> MapAUH)
    {
        
        List<User> users = [Select id, name, isActive, Profile_Name_gne__c,External_ID_gne__c from user where External_ID_gne__c in :MapAUH.keySet()];
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
        try
        {
            for(User usr:usersToActivate)
            {
                usr.isActive = true;
            }
            update usersToActivate;
        }
        catch(Exception e)
        {
            Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c='UserManagerLite',Error_Category_gne__c='',
            Error_Message_gne__c='',Method_Name_gne__c= '', Object_Name_gne__c='',System_Error_Message_gne__c='');
            insert error;
        } 
    }
    
    private Map<String,User> createUsers(Map<String,All_User_Hierarchy_gne__c> employees,string creator, string owner)
    {
        List<User> users = new List<User>();
        Map<String,User> createdUsers = new Map<String,User>();
        try
        {
            for(All_User_Hierarchy_gne__c employee: employees.values())
            {
                User newUser = new User();
                newUser.FirstName = employee.FirstName_gne__c;
                newUser.LastName = employee.LastName_gne__c;
                newUser.alias = employee.User_External_Id_gne__c;
                newUser.username = employee.User_External_Id_gne__c + '@gene.com.dev';
                newUser.email = employee.email_id__c;
                newUser.TimeZoneSidKey = DEFAULT_TIME_ZN;
                newUser.LocaleSidKey = DEFAULT_LOCALE_KEY;
                newUser.EmailEncodingKey = DEFAULT_EMAIL_KEY;
                newUser.LanguageLocaleKey = DEFAULT_LANG_LOC_KEY;        
                newUser.CommunityNickname = employee.User_External_Id_gne__c;  
                newUser.External_ID_gne__c = employee.User_External_Id_gne__c;
                List<Profile> profiles = [Select Id, name from Profile where name = 'GNE-INFREQUENT-USER'];
                newUser.ProfileId = profiles[0].Id;
                users.add(newUser);
            }
            //insert users;
            for(User usr: users)
            {
                if(employees.get(usr.External_Id_gne__c).Persistent_Id_gne__c == creator)
                    createdUsers.put(employees.get(usr.External_Id_gne__c).Persistent_Id_gne__c,usr);
                if(owner !='')
                {
                    if(usr.External_Id_gne__c == owner)
                        createdUsers.put(usr.External_Id_gne__c,usr);
                }
            }
            return createdUsers;
        }
        catch(Exception e)
        {
            Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c='UserManagerLite',Error_Category_gne__c='',
            Error_Message_gne__c='',Method_Name_gne__c= '', Object_Name_gne__c='',System_Error_Message_gne__c='');
            insert error;
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
        return owner.id;
        else
        return null;
    }
    
    public String itemization(String XUserID,String entryEndpoint)
    {
        try 
        {
            Map<String,String> responseParameters = new Map<String,String>();
            if(XUserID !=null && XUserID !='' && entryEndpoint !=null && entryEndpoint !='')
            {
                HttpRequest req = new HttpRequest(); 
                req.setMethod('GET');
                req.setHeader('Content-Type','application/xml');
                req.setEndpoint(entryEndpoint);
                Concur_Oauth oa = new Concur_Oauth();
                //oa.sign(req,XUserID); 
                Http h = new Http();
                HttpResponse res = h.send(req);
                return res.getBody();
            }
            return '';
        }
        catch(Exception e)
        {
            Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c='Concur_WebServicesCalls',Error_Category_gne__c='webservice',
            Error_Message_gne__c='Problem with Get webservice call',Method_Name_gne__c= 'expenseEntryDetails', Object_Name_gne__c='HttpRequest',System_Error_Message_gne__c=e.getMessage(),Content_gne__c=XUserID+','+entryEndpoint);
            insert error;
            return null;
        } 
    }
    
    public String expenseEntryDetails(String XUserID,String entryEndpoint)
    {
        try
        {
                HttpRequest req = new HttpRequest(); 
                req.setMethod('GET');
                req.setHeader('Content-Type','application/xml');
                req.setEndpoint(entryEndpoint);
                Concur_Oauth oa = new Concur_Oauth();
                String env = GlobalUtils.getEnvironment();
                string consumer_key = '';
                string consumer_secret = '';
	            MAP<String,Concur_Environment_Domain_gne__c> domains = Concur_Environment_Domain_gne__c.getAll();
	            system.debug('-------------domains'+domains);
	            system.debug('-------------Site.getDomain()'+Site.getDomain());
				for(Concur_Environment_Domain_gne__c env_domain : domains.values())
	            {
	                if (env_domain.Name.contains(env))
	                {
	                    consumer_key = env_domain.Consumer_key_gne__c;
						consumer_secret = env_domain.Consumer_secret_gne__c;
	                }
	            }
                oa.sign(req,XUserID,consumer_key,consumer_secret);
                Http h = new Http();
                HttpResponse res = h.send(req);
                return res.getBody();
        }
        catch(Exception e)
        {
            Concur_Error_Log_gne__c error = new Concur_Error_Log_gne__c(Class_Name_gne__c='Concur_WebServicesCalls',Error_Category_gne__c='webservice',
            Error_Message_gne__c='Problem with Get webservice call',Method_Name_gne__c= 'expenseEntryDetails', Object_Name_gne__c='HttpRequest',System_Error_Message_gne__c=e.getMessage(),Content_gne__c=XUserID+','+entryEndpoint);
            insert error;
            return null;
        } 
    }
    
}