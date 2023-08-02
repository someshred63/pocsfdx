public with sharing class GNE_MSL_ToT_User_Lookup {
	public Integer ResultSetLimit = 10;
    
    public String userType= 'MSL';
    public List<User> myUsers = new list<User>();
    
    public Boolean flagSortingRequired=false;
    public List<UserWrapperClass> wrappervariable = new list<UserWrapperClass>();
    public Integer recordCount = 0;    
    public Integer flg = 0; 
    public String sortExp = 'FullName';
    public String order = 'asc';
    public String previousSortField = null;
    public Integer iMaxSearch=1000; 
    public Integer ieSearchLimit=1000;  
    public String BrowserType = 'Other';
    public String ModeValue = 'Create';
    public String inputValue = '';
    Boolean isEdit = false;
    
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
    
    public GNE_MSL_ToT_User_Lookup(ApexPages.StandardController controller) 
    {
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
        flagSortingRequired=false;
        sErrMessage='';
    }

    public pagereference rerunSearch() {
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

		System.debug('iMaxSearch: ' + iMaxSearch);
		System.debug('ieSearchLimit: ' + ieSearchLimit);
        recordCount=0;
        flg=0;
        integer size=0;
        try
        {   
			flg = 1;
			if(userType=='MSL') // Return only MSL users in Referral Roster.
			{
                wrappervariable = new List<UserWrapperClass>();
                Map<Id,User> mapUser=new Map<Id,User>();
                System.debug('inputValue: ' + inputValue);
				if (inputValue == null || inputValue == '')
				{  
					 myUsers = [Select Id, Name, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c IN ('GNE-MedAffairs-MSL','GNE-MedAffairs-MSL-Manager') and isActive=true and ID <> :UserInfo.getUserId() order by name ];
				} else {
						Pattern pat=Pattern.Compile('\\*');
					 string srchname=pat.Matcher(inputValue).replaceall('%');
					 if (srchname.indexOf('%',0)==-1)
						 srchname=srchname+'%';
						myUsers = [Select Id, Name,Firstname,Lastname, isActive,department, UserRole.Name, title, phone, email, Profile_Name_gne__c from User u where Profile_name_gne__c IN ('GNE-MedAffairs-MSL','GNE-MedAffairs-MSL-Manager') and isActive=true and (Firstname like :srchname or Lastname like :srchname or Name like :srchname) and ID <> :UserInfo.getUserId() order by name ];
				}      
				System.debug('##### myUsers.size(): '+myUsers.size());
				if(myUsers!=null&& myUsers.size()>0)
				{   
				   wrappervariable = new List<UserWrapperClass>();
				   for(User uObj:myUsers)
				   {
						mapUser.put(uObj.id,uObj);
						wrappervariable.add(new UserWrapperClass(uObj,null));
				   }
				   
				   System.debug(' before size: ');
				   System.debug('wrappervariable.size() : '+wrappervariable.size());
				   List<UserWrapperClass> wrappervariableClone= new List<UserWrapperClass>();
				   for(UserWrapperClass userWrapperObj:wrappervariable)
				   {
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
			}  // End else if(userType=='MSL')
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
}