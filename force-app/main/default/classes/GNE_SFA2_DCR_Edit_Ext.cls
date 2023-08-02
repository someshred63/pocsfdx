public without sharing class GNE_SFA2_DCR_Edit_Ext {
    
    public Boolean loadComplete {
        get {
            if (loadComplete == null) {
                loadComplete = false;
            }
            return loadComplete;
        }
        set;
    }

    public PageReference loadComplete() {
        loadComplete = true;
        return null;
    }
    
    private final ApexPages.StandardController stdController;
    public Change_Request_gne__c changeRequest;
    
    public enum ViewUserType {Requestor, RequestDataAnalyst, VendorDataAnalyst} 

    public ViewUserType userType = ViewUserType.RequestDataAnalyst;
    
    public boolean getRequestor() {
        return ( userType == ViewUserType.Requestor );  
    }

    public boolean getVendorDataAnalyst() {
        return ( userType == ViewUserType.VendorDataAnalyst );  
    }

    public boolean getRequestDataAnalyst() {
        return ( userType == ViewUserType.RequestDataAnalyst );  
    }
    
    public Change_Request_gne__c getChangeRequest() {
        return changeRequest;   
    }
    
    public boolean editPage { get; set; }
    public String userIdToViewLink {get;set;}
    private SFA2_Configuration_Object_gne__c pageConfiguration;         
    
    public GNE_SFA2_DCR_Edit_Ext (ApexPages.StandardController stdController) {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Change_Request_gne__c');        
        this.stdController = stdController;    
        
        changeRequest = GNE_SFA2_DCR_Util.getDCR((Id)stdController.getRecord().get('Id'));
        
        Id userId = UserInfo.getUserId();
        
        if ((changeRequest.createdById == userId)){ 
            userType = ViewUserType.Requestor;
            
            if ((changeRequest.status_gne__c == 'Need Info') || 
                    (changeRequest.status_gne__c == 'Ready to Close') )
            editPage = true;
        }            
        else if ( ChangeRequestControllerHelper.isVendor(userId) && 
                changeRequest.status_gne__c == 'Ready for Data Vendor') {
            userType = ViewUserType.VendorDataAnalyst;
            editPage = true;
        }
        
        
        if ( (userType == ViewUserType.RequestDataAnalyst)   && 
                (changeRequest.assigned_analyst_gne__c == null) &&
                (ApexPages.currentPage().getURL().contains('/GNE_SFA2_DCR_Edit') )     
                )
        changeRequest.assigned_analyst_gne__c =  userId;             
    }

    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
    
    public PageReference updateDCR() {

        PageReference pageRef = null;

        try {            
            if ( changeRequest != null ) {
                System.debug ('tmpViewDCR.updateDCR called by user ' + UserInfo.getUserName() );
                //changeRequest.Status_gne__c = selectedStatus;
                update changeRequest;
                

                if ( getRequestor() ) {
                    pageRef = new PageReference('/apex/GNE_SFA2_DCR');
                    pageRef.setRedirect(true);
                } else {
                    String retURL = ApexPages.currentPage().getParameters().get('retURL');
                    if ( retURL != null ) {
                        pageRef = new PageReference ( retURL );
                        pageRef.setRedirect(true);                          
                    } else { 
                        //String changeRequestPrefix = Schema.SObjectType.Change_Request_gne__c.getKeyPrefix();
                        //pageRef = new PageReference ('/' + changeRequestPrefix );
                        pageRef = new PageReference ('/'+changeRequest.id);
                        pageRef.setRedirect(true);
                    }                           
                    
                }
                
                /*
                    if ( getVendorDataAnalyst() ) {
                        String changeRequestPrefix = Schema.SObjectType.Change_Request_gne__c.getKeyPrefix();
                        pageRef = new PageReference ('/' + changeRequestPrefix );
                        pageRef.setRedirect(true);
                    } else {
                        pageRef = (new ApexPages.StandardController(changeRequest)).view();
                        pageRef.setRedirect(true);
                    }
                */                           
                
            } else {                
                System.debug ('changeRequest is null in updateDCR method..');   
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }            
        return pageRef;
    }
    
    public PageReference editPageLayout() {
        
        if ( changeRequest.RecordType.Name.startsWith('HCO') || 
                changeRequest.RecordType.Name.startsWith('HCP') ) 
        return null;                  
        
        // backward compability of existing DCRs records 
        // use old page layout with embedded javascript
        // Force.com -> instead of layout with js we will render our custom page with the same js included
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_DCR_Edit_Alternative_Layout?id='+changeRequest.Id);  
        //pageRef.getParameters().put('nooverride', '1');  
        //pageRef.getParameters().put('id', changeRequest.Id);  
        pageRef.setRedirect(true);
        return pageRef;  
        
    }
    
    public boolean hasCanadaProfile 
    {
        get {
            return GNE_SFA2_Util.isCanadaUser();
        } 
        set;
    }
    
    //get list of available statues via Custom Setting 
    public List<SelectOption> statuses {
        get {
            List<SelectOption> options;
            if(statuses == null){
                options = new List<SelectOption>();
                //options.add(new SelectOption('', ''));
                
                Map <String, GNE_SFA_Canada_DCR_Statuses__c> statusesMap = GNE_SFA_Canada_DCR_Statuses__c.getAll();
                if(statusesMap != null && statusesMap.size() > 0){
                    for (GNE_SFA_Canada_DCR_Statuses__c row : statusesMap.values()){
                        options.add(new SelectOption(row.Name, row.Name));                            
                    }
                    //sortSelectOptions(options, 1, options.size() - 1);
                    statuses = removeDups(options);
                }
            }
            //selectedStatus = changeRequest.Status_gne__c;    
            return statuses;    
        } set;
    }
    
    private List<SelectOption> removeDups(List<SelectOption> inList){
        List<SelectOption> newList = new List<SelectOption>{};
        String currVal;
        for (SelectOption row : inList)
        {
            if (currVal != row.getLabel())
            {
                newList.add(row); 
            }
            currVal = row.getLabel();
        }     
        return newList;   
    }

    private static void sortSelectOptions(List<SelectOption> a, Integer lo0, Integer hi0) {
        Integer lo = lo0;
        Integer hi = hi0;
        
        if (lo >= hi) {
            return;
        } else if( lo == hi - 1 ) {
            
            if (a[lo].getLabel() > a[hi].getLabel()) {
                SelectOption o = a[lo];
                a[lo]         = a[hi];
                a[hi]         = o;
            }
            return;
        }
        SelectOption pivot = a[(lo + hi) / 2];
        a[(lo + hi) / 2] = a[hi];
        a[hi] = pivot;
        while( lo < hi ) {
            while (a[lo].getLabel() <= pivot.getLabel() && lo < hi) { lo++; }
            while (pivot.getLabel() <= a[hi].getLabel() && lo < hi ) { hi--; }
            
            if( lo < hi ){
                SelectOption o = a[lo];
                a[lo]         = a[hi];
                a[hi]         = o;
            }
        }
        
        a[hi0] = a[hi];
        a[hi] = pivot;
        
        sortSelectOptions(a, lo0, lo-1);
        sortSelectOptions(a, hi+1, hi0);
    }
    
     public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref; 
    }
}