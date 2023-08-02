public with sharing class SPCM_UsersReportController {
    
    //public
    public string query {get; set;}
    public List<SelectOption> BusinessRoles {get; set;}
    public String BusinessRoleFilter {get; 
     set{
            BusinessRoleFilter = value;
            createQuery();
        }
    }
    public String UserFilter {get; 
     set{
            UserFilter = value;
            createQuery();
        }
    }
    public date DateFilterFrom {get; 
     set{
            DateFilterFrom = value;
            createQuery();
        }
    }
    public date DateFilterTo {get; 
     set{
            DateFilterTo = value;
            createQuery();
        }
    }
    
    public ApexPages.StandardSetController UsersSet {
        get{
            
            if (UsersSet == null){
                createQuery();
            }
            return UsersSet;
        }
        set;
    }
    
    private without sharing class BusinessRoleFetch {
    	public Set<String> getBusinesRoleNames() {
    		Set<String> restricted = new Set<String> {
    			'Channel View'
    		};
    		restricted.addAll(SPCM_UsersReportController.itRolesList);
    		
    		Set<String> result = new Set<String>();
    		for (GNE_Business_Role__c record : [SELECT Name FROM GNE_Business_Role__c ORDER bY Name ASC]) {
    			boolean add = true;
    			for (String restrict : restricted) {
    				if (record.Name.toLowerCase().contains(restrict.toLowerCase())) {
    					add = false;
    					break;
    				}
    			}
    			if (add) {
    				result.add(record.Name);
    			}
    		}
    		return result;
    	} 
    }
    
    //private
    private List<string> businessRolesList = new List<String> (new BusinessRoleFetch().getBusinesRoleNames() );
    
    private static List<string> itRolesList = new List<string> { 'EC IT Control Manager', 'EC IT Support', 'EC SFDC IT Administrator', 'SPCM Systems Administrator'};
    
    private string getItRolesString{
        get {
            if (! string.isBlank(getItRolesString)) return getItRolesString;
            getItRolesString = '';
            for (string s : itRolesList){
                getItRolesString += '\'' + s + '\' ,';
            }
            getItRolesString = getItRolesString.removeEnd(',');
            return getItRolesString;
        }
        set;
    }
    
    private string getBusinessRolesString{
        get {
            if (! string.isBlank(getBusinessRolesString)) return getBusinessRolesString;
            getBusinessRolesString = '';
            for (string s : businessRolesList){
                getBusinessRolesString += '\'' + s + '\' ,';
            }
            getBusinessRolesString = getBusinessRolesString.removeEnd(',');
            return getBusinessRolesString;
        }
        set;
    }
    

    //ctor
    public SPCM_UsersReportController(ApexPages.StandardController controller) 
    {
        FetchBusinessRoles();
    }
    

    
    public PageReference nullAction()
    {
        return null;
    }
    
    public PageReference Export()
    {
        return Page.SPCM_Users_Report_Download;
    }
    
    public List<User_Business_Role_gne__c> getUsers()
    {
        return (List<User_Business_Role_gne__c>) UsersSet.getRecords();
    }
    
    private void createQuery()
    {
        query = 'SELECT Business_Role_gne__c, Role_Assigned_Date_gne__c, user_gne__r.name, ' +
                                'user_gne__r.username, user_gne__r.alias, user_gne__r.isActive, user_gne__r.Profile_name_gne__c, ' +
                                'user_gne__r.manager.name, user_gne__r.LastLoginDate, user_gne__r.CreatedDate, ' +
                                'user_gne__r.CreatedBy.Name, user_gne__r.LastModifiedDate, user_gne__r.LastModifiedBy.name ' +
                                'FROM User_Business_Role_gne__c WHERE ' +
                         BuildQueryCondition() +
                 'order by user_gne__r.lastname, user_gne__r.firstname limit 3000';
            system.debug(query);
        UsersSet = new ApexPages.StandardSetController(Database.getQueryLocator(query));        
        UsersSet.setPageSize(500);
    }

    private string BuildQueryCondition()
    {
        string filter = '';
        
        //create business role filter
        if (string.isBlank(BusinessRoleFilter))
            filter += 'Business_Role_gne__c in ( ' + getBusinessRolesString + ',' + getItRolesString + ' ) ';
        else if (BusinessRoleFilter == 'IT'){
            filter += 'Business_Role_gne__c in (' + getItRolesString + ') ';
        }
        else if (BusinessRoleFilter == 'Business'){
            filter += 'Business_Role_gne__c in (' + getBusinessRolesString + ') ';
        }
        else
            filter += 'Business_Role_gne__c like \''+ BusinessRoleFilter + '\' ';
        
        //create date filter
        if (DateFilterFrom != null){
            filter += ' AND user_gne__r.LastModifiedDate >= ' + string.valueOf(DateFilterFrom) + 'T00:00:00Z ';
        }
        if (DateFilterTo != null){
            filter += ' AND user_gne__r.LastModifiedDate <= ' + string.valueOf(DateFilterTo) + 'T00:00:00Z ';
        }
        
        //create user filter
        if (! string.isBlank(UserFilter))
                filter += ' AND user_gne__r.name like' + '\'%' + UserFilter + '%\' ';
            
        return filter;
    }
    
    private void FetchBusinessRoles()
    {
        Set<string> BusinessRolesSet = new Set<string>();
        BusinessRoles = new List<selectOption> 
        {
            new SelectOption('', 'All'),
            new SelectOption('IT', 'All IT Users'),
            new SelectOption('Business', 'All Business Users')
        };
        
        for(string r : businessRolesList)
                BusinessRoles.Add(new SelectOption(r, r));
        
        for(string r : itRolesList)
                BusinessRoles.Add(new SelectOption(r, r));
    }

    // ------------Pagination methods

    public Boolean hasNext {
        get {
            return UsersSet.getHasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return UsersSet.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get { return UsersSet.getPageNumber(); }
        set;
    }

    public void first() {
        UsersSet.first();
    }

    public void last() {
        UsersSet.last();
    }

    public void previous() {
        UsersSet.previous();
    }

    public void next() {
        UsersSet.next();
    }

    public void cancel() {
        UsersSet.cancel();
    }
}