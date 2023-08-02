public class GNE_MED_RequestedBy_User_Lookup
{
    public List<User> myUsers = new list<User>();
    public Integer recordCount = 0;    
    
    public Integer iMaxSearch=1000; 
    public Integer ieSearchLimit=1000;  
    public String BrowserType { get; set; }
    public String ModeValue { get; set; }
    public String inputValue = '';
    //Boolean isEdit = false;
    public String sErrMessage{get; set;}
    public string getResultCount()
    {
        string SearchResult = 'Salesforce Search Results: '+recordCount;
        return SearchResult;   
    }
    /*
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
    */
    public GNE_MED_RequestedBy_User_Lookup(ApexPages.StandardController controller) 
    {
    	BrowserType = 'Other';
    	ModeValue = 'Create';
        ModeValue = ApexPages.currentPage().getParameters().get('Mode');
        inputValue = ApexPages.currentPage().getParameters().get('SearchValue');
        BrowserType = System.currentPagereference().getParameters().get('BrowserType');
        System.debug('inputValue: ' + inputValue);
        System.debug('BrowserType: ' + BrowserType);
        
        System.debug('iMaxSearch: ' + iMaxSearch);
        System.debug('ieSearchLimit: ' + ieSearchLimit);
        sErrMessage='';
        //userType= 'MSL';      
    }


   public void test() {
        System.debug('####### inputValue'+inputValue);
        //flagSortingRequired=false;
        sErrMessage='';
    }
    /*
    public pagereference rerunSearch() {
        //lookupUsers();
       sErrMessage='';
       return null;
    }
    */
     public String getInputValue() {
      return inputValue;
   }

    public void setInputValue(String s) {
        if(s != null && s !=''){
            s.Replace('*','%');
        }
      inputValue = s;
    }
    /*
    public String getuserType() {
        return userType;
    }
    public void setuserType(String userType) { this.userType = userType; }
    */
    
    public List<User> getMyUser() {
        System.debug('iMaxSearch: ' + iMaxSearch);
        System.debug('ieSearchLimit: ' + ieSearchLimit);
        return lookupUsers();
    }
 
    public list<User> lookupUsers()
    {
    System.debug('Hello from lookupUsers');
    sErrMessage='';
    System.debug('iMaxSearch: ' + iMaxSearch);
    System.debug('ieSearchLimit: ' + ieSearchLimit);
        recordCount=0;
        
        try
        {   
            
            System.debug('inputValue: ' + inputValue);
            if (inputValue == null || inputValue == '')
            {  
                myUsers = [Select Id, Name, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c like 'GNE-MCCO%' and isActive=true order by name]; 
                System.debug('##### myUsers.size(): '+myUsers.size());
                
            }           
            else if (inputValue.length() >= 1)
            {           
                System.debug('##### inputValue: '+inputValue);
                Pattern pat=Pattern.Compile('\\*');
                string srchname=pat.Matcher(inputValue).replaceall('%');
                if (srchname.indexOf('%',0)==-1)
                    srchname=srchname+'%';
                System.debug('##### MSL srchname'+srchname);
                myUsers = [Select Id, Name,Firstname,Lastname, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c like 'GNE-MCCO%' and isActive=true and (Firstname like :srchname or Lastname like :srchname or Name like :srchname) order by name];
            }
            if(myUsers!=null&& myUsers.size()>0)
            {   
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
            else{
                sErrMessage='No records found, please set the appropriate filter criteria to select the user.';
            }
        } // End of try
        catch(exception e)   
        {
        //do nothing    
        }
        return myUsers;   
   } // End of lookupUsers
 
    /*
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
        //flagSortingRequired=true;
        //System.debug('*******Wrapper var field after Sorting:' + wrappervariable);
    }
    */
    
    
} // End of class GNE_MED_RequestedBy_User_Lookup