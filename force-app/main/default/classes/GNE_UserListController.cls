// Get users where 'Customer Portal User', 'Customer Portal Manager'

public class GNE_UserListController 
{
    
    private List<User> MDOs = new List<User>();
    private integer fnamelen;
    private integer lnamelen;
    private string fname;
    private string lname;
    private string searchfname;
    private string searchlname;
    private string selected_email = '';
    private ApexPages.Message myerrorMsg;
    private string env = '';
    private string ProcStatus;
    private Map<string, String> environment_var_val = new Map<String, String>();
    private List<string> ProfileList = new List<string>(); 
    PageReference pView = new PageReference('/apex/GNE_CM_View_MDO');
    PageReference pSrch = new PageReference('/apex/GNE_CM_Search_MDO');
    
    public GNE_UserListController(ApexPages.StandardController controller) 
    {
        environment_var(); 
    }
    
    /*******************************/
    // Get selected email.
    /*******************************/
    public string getselected_email()
    {
        return selected_email;
    }
    
    /*******************************/
    // Get FN from textbox.
    /*******************************/
    public string getsearchfname()
    {
        return searchfname;
    }
    
    /*******************************/
    // Set FN from textbox.
    /*******************************/  
    public void setsearchfname(String f)
    {
        this.searchfname = f;
    }
    
    /*******************************/
    // Get LN from textbox.
    /*******************************/
    public string getsearchlname()
    {
        return searchlname;
    }
    
    /*******************************/
    // Set LN from textbox.
    /*******************************/  
    public void setsearchlname(String f)
    {
        this.searchlname = f;
    }
    
    /*******************************/
    // Environment variable.
    /*******************************/ 
    public string getEmailEnvVar() 
    {
        return environment_var_val.get('MDOEmail');
    }
    
    /*******************************/
    // Debugging property.
    /*******************************/ 
    public string getProcStatus() 
    {
        return ProcStatus;
    }
    
    public void environment_var() 
    {
        String username = UserInfo.getUserName();
        env = '';
        
        environment_var_val.clear();
        if(username.indexOf('@gene.com') > 0 && username.indexOf('@gene.com.') <0) 
        {
            env= 'prod'; 
        }
        else if(username.indexOf('@gene.com.') >0)
        {
            env = username.Substring(username.indexOf('@gene.com.')+10, username.length());
        }
        else if(username.indexOf('.gene') > 0 && username.indexOf('.gene.') <0) 
        env= 'prod'; 
        else if(username.indexOf('.gene.') >0)
        env=username.Substring(username.indexOf('.gene.')+6, username.length());
        
        Environment_Variables__c[] environ_list = [Select Environment__c, Key__c, Value__c 
                                                    from Environment_Variables__c where 
                                                    key__c in ('MDOEmail','PORTAL_PROFILE')
                                                    and Environment__c = :env order by key__c]; 
                                                    
         for (integer i = 0; i < environ_list.size(); i++)
         {
            environment_var_val.put(environ_list[i].Key__c, environ_list[i].Value__c); 
         }
    }
    
    public List<User> getMDOList()
    {
        return MDOs;
    }
    public PageReference stamp_Email()
    {
        selected_email = System.currentPageReference().getParameters().get('email');
        return pView;
    }
    
    public pagereference Back()
    {
        return pSrch;
    }

    public PageReference getMDOs() 
    {
       if (searchfname != Null && searchfname.trim() != '')
       {
           fnamelen = searchfname.length();
       }
       else
       {
           fnamelen = 0;
       }
       if (searchlname != Null && searchlname.trim() != '')
       {
           lnamelen = searchlname.length();
       }
       else
       {
           lnamelen = 0;
       }
       MDOs = new List<User>();
       ProfileList.clear();
       
       try
       {
       
       //Get the list of profile.
       ProcStatus = environment_var_val.get('PORTAL_PROFILE');
       if (environment_var_val.containskey('PORTAL_PROFILE') && environment_var_val.get('PORTAL_PROFILE').length() > 0)
        {
           ProfileList = environment_var_val.get('PORTAL_PROFILE').split(',',0);  
           for (integer zcnt=0;zcnt < ProfileList.size();zcnt++)
           {
               ProfileList[zcnt] = ProfileList[zcnt].trim();
           }
        }
       else
        {
            throw new GNE_CM_Exception ('Portal profiles no described by Administrator.');
        }
        
       //Start search operation.
       if(fnamelen == 0 && lnamelen == 0)
       {
            MDOs = [SELECT Id, Email, Name,FirstName, LastName, Contact.Receive_emails_Patient_Cases_gne__c, 
                    Username,ProfileId 
                    FROM USER WHERE Profile.Name IN: ProfileList
                    AND Contact.Receive_emails_Patient_Cases_gne__c = 'Yes'
                    LIMIT 50];   
                /************************ DEBUG ************************/
                system.debug('If FN and LN are not given.');
                /************************ DEBUG ************************/                   
       }
       else
       { 
            /************************ DEBUG ************************/
            system.debug('Either FN OR LN are given.Processing.....');
            /************************ DEBUG ************************/
            Pattern pat = Pattern.Compile('\\*');
            
            fname = pat.Matcher(searchfname).replaceall('%');
            if (fname.indexOf('%',0) == -1)
            fname = fname + '%'; 
            
            lname = pat.Matcher(searchlname).replaceall('%');
            if (lname.indexOf('%',0) == -1)
            lname = lname + '%'; 
                
            // If FN is given and LN is not given.
            if (fnamelen >= 2 && lnamelen == 0)
            {
                MDOs = [SELECT Id, Email, Name,FirstName, LastName, Contact.Receive_emails_Patient_Cases_gne__c, Username 
                FROM USER WHERE FirstName LIKE:fname 
                AND Profile.Name IN: ProfileList
                AND Contact.Receive_emails_Patient_Cases_gne__c = 'Yes'
                LIMIT 50];
                /************************ DEBUG ************************/
                system.debug('FN is given and LN is not given.');
                /************************ DEBUG ************************/
            }
            
            // If LN is given and FN is not given. 
            else if(lnamelen >= 2 && fnamelen == 0)
            {
                MDOs = [SELECT Id, Email, Name,FirstName, LastName, Contact.Receive_emails_Patient_Cases_gne__c, Username 
                FROM USER WHERE LastName LIKE:lname 
                AND Profile.Name IN: ProfileList
                AND Contact.Receive_emails_Patient_Cases_gne__c = 'Yes'
                LIMIT 50];
                /************************ DEBUG ************************/
                system.debug('LN is given and FN is not given.');
                /************************ DEBUG ************************/
            }
            
            // If LN and FN are given.
            else if(lnamelen >= 2 && fnamelen >= 2)
            {
                MDOs = [SELECT Id, Email, Name, FirstName, LastName, Contact.Receive_emails_Patient_Cases_gne__c, Username 
                FROM USER WHERE 
                FirstName LIKE:fname 
                AND LastName LIKE:lname 
                AND Profile.Name IN: ProfileList
                AND Contact.Receive_emails_Patient_Cases_gne__c = 'Yes'
                LIMIT 50];
                /************************ DEBUG ************************/
                system.debug('LN and FN are given.');
                /************************ DEBUG ************************/
            }
            else if((lnamelen < 2 || fnamelen < 2)
                    || (lnamelen >= 2 || fnamelen < 2)
                    || (lnamelen >= 2 || fnamelen < 2))
            {
                /************************ DEBUG ************************/
                system.debug('Invalid search condition.');
                /************************ DEBUG ************************/
                throw new GNE_CM_Exception('Enter more than 2 characters for search');
            }
            
        }
        if (MDOs.size() == 0)
        {
            throw new GNE_CM_Exception('No MDO found with this name.');
        }
        else
        {
            //p.setRedirect(true);
            return pView;
        }
        }//end of try
        catch(exception e)
        { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getmessage()));
            return null;
        }
    }
}