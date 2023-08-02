public class GNE_MED_MedAffairs_User_Lookup
{
    public Integer ResultSetLimit = 10;
    
    public String userType= 'MSL';
    public List<User> myUsers = new list<User>();
    public List<Referral_Roster_gne__c> RepRoster = new list<Referral_Roster_gne__c>();
    public List<Referral_Roster_gne__c> lstMSLRepRoster = new list<Referral_Roster_gne__c>();
    public List<Referral_Roster_gne__c> lstAllMedAffairsRepRoster = new list<Referral_Roster_gne__c>();
    
    public Boolean flagSortingRequired=false;
    public List<Referral_Roster_Detail_gne__c> RepRosterDetail = new list<Referral_Roster_Detail_gne__c>();
    public List<UserWrapperClass> wrappervariable = new list<UserWrapperClass>();
    public Integer recordCount = 0;    
    public Integer flg = 0; 
    public String sortExp = 'FullName';
    public String order = 'asc';
    public String previousSortField = null;
    public Integer iMaxSearch=1000; 
    public Integer ieSearchLimit=1000;  
    public String BrowserType { get; set; }
    public String ModeValue { get; set; }    
    public String inputValue = '';
    Boolean isEdit = false;
    /*Boolean isIEBrowser = false;
    Boolean isNotIEBrowser = false;*/
    //public String ModeValue = System.currentPagereference().getParameters().get('Mode');
    //public String inputValue = System.currentPagereference().getParameters().get('SearchValue');    
    
    public String sErrMessage{get; set;}
    public string getResultCount()
    {
        string SearchResult = 'Salesforce Search Results: '+recordCount;
        return SearchResult;   
    }
    
    public Boolean getisEdit()
    {
        if(ModeValue == 'Edit')
            isEdit = true;
        else if(ModeValue == 'Create')
            isEdit = false;
        else
            isEdit = false;
        return isEdit;
    }
    /*
    public Boolean getisIEBrowser()
    {
        if(BrowserType == 'IE')
            isIEBrowser = true;
        else
            isIEBrowser = false;
        return isIEBrowser;
    }
    public Boolean getisNotIEBrowser()
    {
        if(BrowserType != 'IE')
            isNotIEBrowser = true;
        else
            isNotIEBrowser = false;
        return isNotIEBrowser;
    }*/
    
    public GNE_MED_MedAffairs_User_Lookup(ApexPages.StandardController controller) 
    {    	
    	BrowserType = 'Other';
    	ModeValue = 'Create';
        ModeValue = ApexPages.currentPage().getParameters().get('Mode');
        inputValue = ApexPages.currentPage().getParameters().get('SearchValue');
        BrowserType = System.currentPagereference().getParameters().get('BrowserType');
        System.debug('inputValue: ' + inputValue);
        System.debug('BrowserType: ' + BrowserType);
        /*
        if(BrowserType == 'IE')
            iMaxSearch = 17;            
        else
            iMaxSearch = 100;
        */
        System.debug('iMaxSearch: ' + iMaxSearch);
        System.debug('ieSearchLimit: ' + ieSearchLimit);
        sErrMessage='';
        //userType= 'MSL';      
    }


   public void test() {
        //return null;
        //lookupUsers();
        //System.debug('####### inputValue'+inputValue);
        flagSortingRequired=false;
        sErrMessage='';
    }

    public pagereference rerunSearch() {
        //lookupUsers();
       sErrMessage='';
       return null;
    }

     public String getInputValue() {
      return inputValue;
   }

    public void setInputValue(String s) {
        if(s != null && s !=''){
            s.Replace('*','%');
        }
      inputValue = s;
    }

    public String getuserType() {
        return userType;
    }
    
    public void setuserType(String userType) { this.userType = userType; }
 	
    public List<UserWrapperClass> getMyUser() {
        /*
        if(BrowserType == 'IE')
            iMaxSearch = 17;            
        else
            iMaxSearch = 100;
        */
        System.debug('iMaxSearch: ' + iMaxSearch);
        System.debug('ieSearchLimit: ' + ieSearchLimit);
        if(flagSortingRequired==false)
        {
            System.debug('Hello from getMyUser');
            return lookupUsers();
        }
        else
        return wrappervariable;
    }
 
    public list<UserWrapperClass> lookupUsers()
    {
    System.debug('Hello from lookupUsers');
    flagSortingRequired=false;
    sErrMessage='';
    /*
    if(BrowserType == 'IE')
        iMaxSearch = 17;            
    else
        iMaxSearch = 100;
    */
    System.debug('iMaxSearch: ' + iMaxSearch);
    System.debug('ieSearchLimit: ' + ieSearchLimit);
        recordCount=0;
        flg=0;
        integer size=0;
        try
        {   
                flg = 1;
                if(userType=='All') // Return MSL users in Referral roster, MSL-Managers, MCL users, MCL Managers, SP users, SP Managers
                {
                    Map<Id,User> mapUser=new Map<Id,User>();
                    Map<Id,Referral_Roster_gne__c> mapRoster=new Map<Id,Referral_Roster_gne__c>();
                    Map<Id,Referral_Roster_Detail_gne__c> mapRosterDetail=new Map<Id,Referral_Roster_Detail_gne__c>();
                    
                    if (inputValue == null || inputValue == '') 
                        {  
                            wrappervariable = new List<UserWrapperClass>();   
                            myUsers = [Select Id, Name,Firstname,Lastname,isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c in ('GNE-MedAffairs-MSL','GNE-MedAffairs-MSL-Manager','GNE-MedAffairs-SP','GNE-MedAffairs-SP-Manager') and isActive=true order by name];     
                            Set<Id> userNonMSL=new Set<Id>(); 
                            if(myUsers!=null&& myUsers.size()>0)
                            {
                                if(myUsers!=null && myUsers.size()>iMaxSearch)
                                {
                                    sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                }
                                else{
                                    sErrMessage='';
                                }
                                for(User uObj:myUsers)
                                {
                                    mapUser.put(uObj.id,uObj);
                                    System.debug('###### uObj.name'+uObj.name);
                                    String strName=uObj.name;
                                    System.debug('###### strName'+strName);
                                    System.debug('###### strName.length()'+strName.length());
                                }
                                RepRoster=[Select User_gne__c,(Select Therapeutic_Area_gne__c From Referral_Roster_Details__r limit 1),User_gne__r.Title, User_gne__r.Email, User_gne__r.Name, User_gne__r.Phone, User_gne__r.Profile_Name_gne__c, User_gne__r.userrole.name from Referral_Roster_gne__c  where user_gne__c in :myUsers and User_gne__r.Profile_Name_gne__c in ('GNE-MedAffairs-MSL','GNE-MedAffairs-MSL-Manager','GNE-MedAffairs-SP','GNE-MedAffairs-SP-Manager') order by user_gne__r.name ];
                                System.debug('##### ALL RepRoster'+RepRoster);
                                if(RepRoster!=null && RepRoster.size()>0)
                                {
                                    if(RepRoster!=null && RepRoster.size()>iMaxSearch)
                                    {
                                        sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                    }
                                    else{
                                        sErrMessage='';
                                    }
                                    List<User> lstMSLuser=new List<User>(); 
           
                                    for(Referral_Roster_gne__c rosterObj:RepRoster)
                                    {
                                        mapRoster.put(rosterObj.id,rosterObj);
                                    }
                                    
                                    for(Referral_Roster_gne__c rosterObj:RepRoster)
                                    {
                                                    
                                        if(mapUser.containsKey(rosterObj.user_gne__c))
                                        {
                                            if(rosterObj.Referral_Roster_Details__r!=null && rosterObj.Referral_Roster_Details__r.size()>0)
                                                wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),rosterObj.Referral_Roster_Details__r[0].Therapeutic_Area_gne__c));
                                            else
                                                wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),null));
                                            
                                        }
                                        if(!userNonMSL.Contains(rosterObj.User_gne__c))
                                        {
                                            userNonMSL.add(rosterObj.User_gne__c);
                                        }          
                                                    
                                    }
                                    for(User userObj:myUsers)
                                    {
                                        if(!userNonMSL.Contains(userObj.id) && userObj.Profile_Name_gne__c!='GNE-MedAffairs-MSL')
                                        {
                                            wrappervariable.add(new UserWrapperClass(userObj,null));
                                        }
                                    }
                                    List<UserWrapperClass> wrappervariableClone= new List<UserWrapperClass>();
                                    for(UserWrapperClass userWrapperObj:wrappervariable)
                                    {
                                        //System.debug('##### ALL userWrapperObj'+userWrapperObj);
                                        wrappervariableClone.add(userWrapperObj);
                                    }
                                    wrappervariable.clear();
                                    size=0;
                                    if(BrowserType == 'IE'){
                                        if(wrappervariableClone.size()<=ieSearchLimit)
                                            size=wrappervariableClone.size();                                       
                                        else
                                            size=ieSearchLimit-1;
                                    }
                                    else{
                                        if(wrappervariableClone.size()<=iMaxSearch)
                                            size=wrappervariableClone.size();
                                        else
                                            size=iMaxSearch-1;
                                    }
                                    
                                    System.debug('###### before size');
                                    System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                    System.debug('###### wrappervariable'+wrappervariable);
                                    for(integer i=0;i<size;i++)
                                    {
                                        wrappervariable.add(wrappervariableClone[i]);
                                    }
                                    System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                    System.debug('###### wrappervariableClone.size()'+wrappervariableClone.size());
                                    if(BrowserType == 'IE'){
                                        if(wrappervariableClone!=null && wrappervariableClone.size()>ieSearchLimit)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(ieSearchLimit)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                    else{
                                        if(wrappervariableClone!=null && wrappervariableClone.size()>iMaxSearch)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                }
                                else
                                {
                                    size=0;
                                    if(BrowserType == 'IE'){
                                        if(myUsers.size()<=ieSearchLimit)
                                            size=myUsers.size();
                                        else
                                            size=ieSearchLimit-1;
                                    }
                                    else{
                                        if(myUsers.size()<=iMaxSearch)
                                            size=myUsers.size();
                                        else
                                            size=iMaxSearch-1;
                                    }
                                    for(integer i=0;i<size;i++)
                                    {
                                        if(myUsers[i].Profile_Name_gne__c!='GNE-MedAffairs-MSL')
                                        {
                                            System.debug('#### myUsers[i]=>'+myUsers[i]);
                                            wrappervariable.add(new UserWrapperClass(myUsers[i],''));
                                        }                                   
                                    }
                                    System.debug('###### myUsers.size()'+myUsers.size());
                                    if(BrowserType == 'IE'){
                                        if(myUsers!=null && myUsers.size()>ieSearchLimit)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(ieSearchLimit)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                    else{
                                        if(myUsers!=null && myUsers.size()>iMaxSearch)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                }
                            }  
                            
                        }
                        else if (inputValue.length() >= 1)
                        {           
                            wrappervariable = new List<UserWrapperClass>();
                            Pattern pat=Pattern.Compile('\\*');
                            string srchname=pat.Matcher(inputValue).replaceall('%');
                            if (srchname.indexOf('%',0)==-1)
                                srchname=srchname+'%';
                            
                            Set<Id> userNonMSL=new Set<Id>(); 
                            wrappervariable = new List<UserWrapperClass>();
                            myUsers.clear();
                            myUsers = [Select Id, Name,Firstname,Lastname, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c in ('GNE-MedAffairs-MSL','GNE-MedAffairs-MSL-Manager','GNE-MedAffairs-SP','GNE-MedAffairs-SP-Manager') and isActive=true and (Firstname like :srchname or Lastname like :srchname or Name like :srchname) order by name];                           
                            if(myUsers!=null&& myUsers.size()>0)
                            {
                                if(myUsers!=null && myUsers.size()>iMaxSearch)
                                    {
                                        sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                    }
                                    else{
                                        sErrMessage='';
                                    }
                                for(User uObj:myUsers)
                                {
                                    mapUser.put(uObj.id,uObj);
                                }
                                RepRoster=[Select User_gne__c,(Select Therapeutic_Area_gne__c From Referral_Roster_Details__r limit 1), User_gne__r.Title, User_gne__r.Email, User_gne__r.Name,User_gne__r.Firstname,User_gne__r.Lastname, User_gne__r.Phone, User_gne__r.Profile_Name_gne__c, User_gne__r.userrole.name from Referral_Roster_gne__c  where user_gne__c in :myUsers and User_gne__r.Profile_Name_gne__c in ('GNE-MedAffairs-MSL','GNE-MedAffairs-MSL-Manager','GNE-MedAffairs-SP','GNE-MedAffairs-SP-Manager') and (User_gne__r.Firstname like :srchname or User_gne__r.Lastname like :srchname or User_gne__r.Name like :srchname) order by user_gne__r.name ];
                                System.debug('##### RepRoster'+RepRoster);
                                System.debug('##### srchname'+srchname);
                                if(RepRoster!=null&& RepRoster.size()>0)
                                {
                                
                                    //RepRosterDetail=[Select Id, Product_TA_SubTA_gne__c, Referral_Roster_gne__c,Referral_Roster_gne__r.user_gne__c, State_gne__c, TA_SubTA_gne__c,Roster_User_gne__c from Referral_Roster_Detail_gne__c where Referral_Roster_gne__c in :RepRoster and Roster_User_gne__c like :srchname order by Roster_User_gne__c ];
                                    if(RepRoster!=null && RepRoster.size()>iMaxSearch)
                                    {
                                        sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                    }
                                    else{
                                        sErrMessage='';
                                    }
                                    System.debug('#### myUsers'+myUsers);    
                                    wrappervariable = new List<UserWrapperClass>();
                                    
                                    for(Referral_Roster_gne__c rosterObj:RepRoster)
                                    {
                                        mapRoster.put(rosterObj.id,rosterObj);
                                    }
                                    for(Referral_Roster_gne__c rosterObj:RepRoster)
                                    {
                                        if(mapUser.containsKey(rosterObj.user_gne__c))
                                        {
                                            if(rosterObj.Referral_Roster_Details__r!=null && rosterObj.Referral_Roster_Details__r.size()>0)
                                                wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),rosterObj.Referral_Roster_Details__r[0].Therapeutic_Area_gne__c));
                                            else
                                                wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),null));
                                        }
                                        if(!userNonMSL.Contains(rosterObj.User_gne__c))
                                        {
                                            userNonMSL.add(rosterObj.User_gne__c);
                                        }          
                                    }
                                    for(User userObj:myUsers)
                                    {
                                        if(!userNonMSL.Contains(userObj.id) && userObj.Profile_Name_gne__c!='GNE-MedAffairs-MSL')
                                        {
                                            wrappervariable.add(new UserWrapperClass(userObj,null));
                                        }
                                    }
                                    List<UserWrapperClass> wrappervariableClone= new List<UserWrapperClass>();
                                    for(UserWrapperClass userWrapperObj:wrappervariable)
                                    {
                                        //System.debug('##### ALL userWrapperObj'+userWrapperObj);
                                        wrappervariableClone.add(userWrapperObj);
                                    }
                                    wrappervariable.clear();
                                    size=0;
                                    if(BrowserType == 'IE'){
                                        if(wrappervariableClone.size()<=ieSearchLimit)
                                            size=wrappervariableClone.size();
                                        else
                                            size=ieSearchLimit-1;
                                    }
                                    else{
                                        if(wrappervariableClone.size()<=iMaxSearch)
                                            size=wrappervariableClone.size();
                                        else
                                            size=iMaxSearch-1;
                                    }
                                    
                                    System.debug('###### before size');
                                    System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                    System.debug('###### wrappervariable'+wrappervariable);
                                    for(integer i=0;i<size;i++)
                                    {
                                        wrappervariable.add(wrappervariableClone[i]);
                                    }
                                    System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                    System.debug('###### wrappervariableClone.size()'+wrappervariableClone.size());
                                    
                                    if(BrowserType == 'IE'){
                                        if(wrappervariableClone!=null && wrappervariableClone.size()>ieSearchLimit)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(ieSearchLimit)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                    else{
                                        if(wrappervariableClone!=null && wrappervariableClone.size()>iMaxSearch)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                }
                                else
                                {
                                    size=0;
                                    if(BrowserType == 'IE'){
                                        if(myUsers.size()<=ieSearchLimit)
                                            size=myUsers.size();
                                        else
                                            size=ieSearchLimit-1;
                                    }
                                    else{
                                        if(myUsers.size()<=iMaxSearch)
                                            size=myUsers.size();
                                        else
                                            size=iMaxSearch-1;
                                    }
                                    for(integer i=0;i<size;i++)
                                    {
                                        if(myUsers[i].Profile_Name_gne__c!='GNE-MedAffairs-MSL')
                                        {
                                            System.debug('#### myUsers[i]=>'+myUsers[i]);
                                            wrappervariable.add(new UserWrapperClass(myUsers[i],''));
                                        }                                   
                                    }
                                    System.debug('###### myUsers.size()'+myUsers.size());
                                    if(BrowserType == 'IE'){
                                        if(myUsers!=null && myUsers.size()>ieSearchLimit)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(ieSearchLimit)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                    else{
                                        if(myUsers!=null && myUsers.size()>iMaxSearch)
                                        {
                                            sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                        }
                                        else{
                                            sErrMessage='';
                                        }
                                    }
                                }
                            }   
                            
                            
                           
                        }
                            System.debug('#### wrappervariable=>'+wrappervariable);
                } // End if(userType=='All')    
                        
                         if(userType=='MSL') // Return only MSL users in Referral Roster.
                        {
                                wrappervariable = new List<UserWrapperClass>();
                                Map<Id,User> mapUser=new Map<Id,User>();
                                Map<Id,Referral_Roster_gne__c> mapRoster=new Map<Id,Referral_Roster_gne__c>();
                                Map<Id,Referral_Roster_Detail_gne__c> mapRosterDetail=new Map<Id,Referral_Roster_Detail_gne__c>();
                                System.debug('inputValue: ' + inputValue);
                               if (inputValue == null || inputValue == '')
                                {  
                                    myUsers = [Select Id, Name, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c = 'GNE-MedAffairs-MSL' and isActive=true order by name ]; 
                                    System.debug('##### myUsers.size(): '+myUsers.size());
                                    if(myUsers!=null&& myUsers.size()>0)
                                    {   
                                        RepRoster=[Select User_gne__c,(Select Therapeutic_Area_gne__c From Referral_Roster_Details__r limit 1), User_gne__r.Title, User_gne__r.Email, User_gne__r.Name, User_gne__r.Phone, User_gne__r.Profile_Name_gne__c, User_gne__r.userrole.name from Referral_Roster_gne__c  where user_gne__c in :myUsers and User_gne__r.Profile_Name_gne__c = 'GNE-MedAffairs-MSL' order by user_gne__r.name ];
                                        //System.debug('##### referral recordCount'+RepRoster);
                                        if(RepRoster!=null&& RepRoster.size()>0)
                                        {
                                            wrappervariable = new List<UserWrapperClass>();
                                            for(User uObj:myUsers)
                                            {
                                                mapUser.put(uObj.id,uObj);
                                            }
                                            for(Referral_Roster_gne__c rosterObj:RepRoster)
                                            {
                                                mapRoster.put(rosterObj.id,rosterObj);
                                            }
                                            
                                            for(Referral_Roster_gne__c rosterObj:RepRoster)
                                            {
                                                
                                                    if(mapUser.containsKey(rosterObj.user_gne__c))
                                                    {
                                                        if(rosterObj.Referral_Roster_Details__r!=null && rosterObj.Referral_Roster_Details__r.size()>0)
                                                            wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),rosterObj.Referral_Roster_Details__r[0].Therapeutic_Area_gne__c));
                                                        else
                                                            wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),null));
                                                    }
                                               
                                                
                                            }
                                            
                                            System.debug(' before size: ');
                                            System.debug('wrappervariable.size() : '+wrappervariable.size());
                                            List<UserWrapperClass> wrappervariableClone= new List<UserWrapperClass>();
                                            for(UserWrapperClass userWrapperObj:wrappervariable)
                                            {
                                                //System.debug('##### ALL userWrapperObj'+userWrapperObj);
                                                wrappervariableClone.add(userWrapperObj);
                                            }
                                            wrappervariable.clear();
                                            size=0;
                                            if(BrowserType == 'IE'){
                                                if(wrappervariableClone.size()<=ieSearchLimit)
                                                    size=wrappervariableClone.size();
                                                else
                                                    size=ieSearchLimit-1;
                                            }
                                            else{
                                                if(wrappervariableClone.size()<=iMaxSearch)
                                                    size=wrappervariableClone.size();
                                                else
                                                    size=iMaxSearch-1;
                                            }
                                            System.debug('###### before size '+ size);
                                            System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                            System.debug('###### wrappervariableClone.size()'+wrappervariableClone.size());                                   
                                            for(integer i=0;i<size;i++)
                                            {
                                                wrappervariable.add(wrappervariableClone[i]);
                                            }
                                            System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                            System.debug('###### wrappervariableClone.size()'+wrappervariableClone.size());
                                            
                                            if(BrowserType == 'IE'){
                                                if(wrappervariableClone!=null && wrappervariableClone.size()>ieSearchLimit)
                                                {
                                                    sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(ieSearchLimit)+'). Please refine your search criteria.';
                                                }
                                                else{
                                                    sErrMessage='';
                                                }
                                            }
                                            else{
                                                if(wrappervariableClone!=null && wrappervariableClone.size()>iMaxSearch)
                                                {
                                                    sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                                }
                                                else{
                                                    sErrMessage='';
                                                }
                                            }
                                        }
                                    }
                                }           
                                else if (inputValue.length() >= 1)
                                {           
                                    wrappervariable = new List<UserWrapperClass>();
                                   
                                   System.debug('##### inputValue: '+inputValue);
                                    Pattern pat=Pattern.Compile('\\*');
                                    string srchname=pat.Matcher(inputValue).replaceall('%');
                                    if (srchname.indexOf('%',0)==-1)
                                        srchname=srchname+'%';
                                    System.debug('##### MSL srchname'+srchname);
                                    //myUsers = [Select Id, Name, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c like 'GNE-MedAffairs-MSL' and isActive=true and Name like :srchname order by name ];
                                    myUsers = [Select Id, Name,Firstname,Lastname, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c like 'GNE-MedAffairs-MSL' and isActive=true and (Firstname like :srchname or Lastname like :srchname or Name like :srchname) order by name ];
                                    //RepRoster=[Select User_gne__c, (Select Therapeutic_Area_gne__c From Referral_Roster_Details__r limit 1),User_gne__r.Title, User_gne__r.Email, User_gne__r.Name, User_gne__r.Phone, User_gne__r.Profile_Name_gne__c, User_gne__r.userrole.name from Referral_Roster_gne__c  where user_gne__c in :myUsers and User_gne__r.Profile_Name_gne__c = 'GNE-MedAffairs-MSL' and User_gne__r.Name like :srchname order by user_gne__r.name ];
                                    RepRoster=[Select User_gne__c, (Select Therapeutic_Area_gne__c From Referral_Roster_Details__r limit 1),User_gne__r.Title, User_gne__r.Email, User_gne__r.Name,User_gne__r.Firstname,User_gne__r.Lastname, User_gne__r.Phone, User_gne__r.Profile_Name_gne__c, User_gne__r.userrole.name from Referral_Roster_gne__c  where user_gne__c in :myUsers and User_gne__r.Profile_Name_gne__c = 'GNE-MedAffairs-MSL' and (User_gne__r.Firstname like :srchname or User_gne__r.Lastname like :srchname or User_gne__r.Name like :srchname) order by user_gne__r.name ];
                                    System.debug('##### input RepRoster'+RepRoster);                                    if(RepRoster!=null && RepRoster.size()>iMaxSearch)
                                    {
                                        sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                    }
                                    else{
                                        sErrMessage='';
                                    }
                                    List<UserWrapperClass> wrappervariableClone= new List<UserWrapperClass>();
                                    mapUser.clear();
                                    mapRoster.clear();
                                    mapRosterDetail.clear();
                                    for(User uObj:myUsers)
                                    {
                                        mapUser.put(uObj.id,uObj);
                                    }
                                    for(Referral_Roster_gne__c rosterObj:RepRoster)
                                    {
                                        mapRoster.put(rosterObj.id,rosterObj);
                                    }
                                    
                                    for(Referral_Roster_gne__c rosterObj:RepRoster)
                                    {
                                                
                                        if(mapUser.containsKey(rosterObj.user_gne__c))
                                        {
                                            System.debug('#### rosterObj'+rosterObj);
                                            
                                            if(rosterObj.Referral_Roster_Details__r!=null && rosterObj.Referral_Roster_Details__r.size()>0)
                                                wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),rosterObj.Referral_Roster_Details__r[0].Therapeutic_Area_gne__c));
                                            else
                                                wrappervariable.add(new UserWrapperClass(mapUser.get(rosterObj.user_gne__c),null));
                                        }
                                               
                                                
                                    }
                                        
                                    System.debug('##### MSL filter wrappervariable'+wrappervariable);
                                    System.debug('###### MSL filter wrappervariable.size()'+wrappervariable.size());
                                    //List<UserWrapperClass> wrappervariableClone= new List<UserWrapperClass>();
                                        for(UserWrapperClass userWrapperObj:wrappervariable)
                                        {
                                            //System.debug('##### ALL userWrapperObj'+userWrapperObj);
                                            wrappervariableClone.add(userWrapperObj);
                                        }
                                        wrappervariable.clear();
                                        size=0;
                                        if(BrowserType == 'IE'){
                                            if(wrappervariableClone.size()<=ieSearchLimit)
                                                size=wrappervariableClone.size();
                                            else
                                                size=ieSearchLimit-1;
                                        }
                                        else{
                                            if(wrappervariableClone.size()<=iMaxSearch)
                                                size=wrappervariableClone.size();
                                            else
                                                size=iMaxSearch-1;
                                        }
                                        System.debug('###### before size' + size);
                                        System.debug('###### wrappervariable.size()'+wrappervariable.size());
                                        System.debug('###### wrappervariableClone.size()'+wrappervariableClone.size());
                                        System.debug('###### wrappervariable'+wrappervariable);
                                        for(integer i=0;i<size;i++)
                                        {
                                            wrappervariable.add(wrappervariableClone[i]);
                                        }
                                        
                                        if(BrowserType == 'IE'){
                                            if(wrappervariableClone!=null && wrappervariableClone.size()>ieSearchLimit)
                                            {
                                                sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(ieSearchLimit)+'). Please refine your search criteria.';
                                            }
                                            else{
                                                sErrMessage='';
                                            }
                                        }
                                        else{
                                            if(wrappervariableClone!=null && wrappervariableClone.size()>iMaxSearch)
                                            {
                                                sErrMessage='The search returned more than the maximum number of rows ('+String.valueOf(iMaxSearch)+'). Please refine your search criteria.';
                                            }
                                            else{
                                                sErrMessage='';
                                            }
                                        }

                                }
                            
                        }// End else if(userType=='MSL')
                        
                        
                    //dosort(); 
            
        } // End of try
        catch(exception e)   
        {
        //do nothing    
        }
        return wrappervariable;   
   } // End of lookupUsers
 
   
       public List<Selectoption> getselection()
    {
        List<selectoption> selection = new List<Selectoption>();     
        selection.add(new selectoption('MSL','MSL'));
        //selection.add(new selectoption('MCL','MCL'));
        selection.add(new selectoption('ALL','ALL'));
        return selection;
    }   

    
    public String sortField
    {
        get
        {
            return sortExp;
        }
        set
        {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
        }
    }
   
    private String sortDirection = 'ASC';
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortField == null || sortField == '')
          return 'ASC';
        else
         return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    public void doSort(){

    System.debug('Hello from doSort');
    
        
        //system.debug('*******sortField 1: '+ sortField);

        if(sortField == null)
        
        
        //system.debug('*******sortField 2: '+ sortField);
        //System.debug('*******Previous sort field 1: '+ previousSortField);


        /*This checks to see if the same header was click two times in a row, if so 
        it switches the order.*/
        if(previousSortField == sortField){
            order = 'desc';
            previousSortField = null;
        }
        else
        {
            previousSortField = sortField;
        }
        
        //System.debug('*******Previous sort field 2: '+ previousSortField);
        //System.debug('*******Order: '+ Order);
        //System.debug('*******sortDirection: '+ sortDirection);
        //System.debug('*******Wrapper var field: '+ wrappervariable);
        
        //To sort the table we simply need to use this one line, nice!
        GNE_MED_MedAffairs_superSort.sortListWrapper(wrappervariable,sortField,sortDirection);
        flagSortingRequired=true;
        //System.debug('*******Wrapper var field after Sorting:' + wrappervariable);
    }
    
    
    
} // End of class GNE_MED_MedAffairs_User_Lookup