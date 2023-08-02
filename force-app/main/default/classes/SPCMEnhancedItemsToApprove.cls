public with sharing class SPCMEnhancedItemsToApprove {
    public Integer pageSize{get;set;}
    public Integer noOfPages{get;set;}
    public Integer pageNumber{get;set;}
    private Integer totalNoOfRecs;
    public List<EnhancedItem> approvals {get;set;}
    public String query {get;set;}
	public String sortField {
    	get  { 
    		if (sortField == null) {
    			sortField = 'Name'; 
    		} 
    		return sortField;  
    	}
    	set;
  	}
  	public String sortDir {
    	get  { 
    		if (sortDir == null) {
    			sortDir = 'ASC'; 
    		}
    		return sortDir;  
    	}
    	set;
  	}
  	public String mode {get; set;} 

	public void toggleSort() {
    	sortDir = sortDir.equals('ASC') ? 'DESC' : 'ASC';
		queryApprovals();
	}
	
	private String orderByPhrase() {
		return ' ORDER BY ' + sortField + ' ' + sortDir;
	}
	
    String baseQuery = 'SELECT Id, Name, Agreement_Type__r.Name, Customer_Name__r.Name, Initiator_Comments__c, Contract_Title__c, Submitted_Date__c, Requested_Final_Approval_Date__c, Initiated_By__r.Name FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id IN :recordIds';
        
    public SPCMEnhancedItemsToApprove() {
        pageSize = 10;
        totalNoOfRecs = getApprovalIdsCountFor('SPCM_CARS_Contract_Summary_Form__c');
        approvals = new List<EnhancedItem>();
        getInitialApprovalsSet();  
    }
    
    private integer getApprovalIdsCountFor (String objectName) {
		return getApprovalIdsFor(objectName).size();
    }
    
    public PageReference getInitialApprovalsSet() {
        pageNumber = 0;
        noOfPages = totalNoOfRecs/pageSize;
        
        if (Math.mod(totalNoOfRecs, pageSize) > 0)
            noOfPages++;
        
        try{
            List<String> recordIds = getApprovalIdsFor('SPCM_CARS_Contract_Summary_Form__c');
            createApprovalsList(Database.query(baseQuery + orderByPhrase () + ' LIMIT ' + pageSize));
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public PageReference next() {
        pageNumber++;
        queryApprovals();
        return null;
    }

    public PageReference previous() {
        pageNumber--;
        if (pageNumber < 0)
            return null;
        queryApprovals();
        return null;
    }

    private List<String> getApprovalIdsFor(String objectName) {
    	List<Schema.DescribeSObjectResult> result = Schema.describeSObjects(new String[]{objectName});
		String objId = result.get(0).getKeyPrefix();

        String userId = UserInfo.getUserId();
        List<ProcessInstanceWorkItem> piwis = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ActorId=:userId];
        List<String> recordIds = new List<String>();
        for (ProcessInstanceWorkItem piwi : piwis) {
        	String recordId = (String) piwi.ProcessInstance.TargetObjectId;
        	if (recordId.startsWith(objId))
	            recordIds.add(recordId);
        }
        
        return recordIds;    
    }
    
    private void createApprovalsList(List<SObject> queryResult) {
        approvals.clear();
        for (SObject s : queryResult) {
            approvals.add(new EnhancedItem(
            		(Id) s.get('Id'),
            		(String) s.get('Name'),
            		((SPCM_Agreement_Type__c) s.getSObject('Agreement_Type__r')).Name, 
            		((SPCM_Customer_Name__c) s.getSObject('Customer_Name__r')).Name, 
            		(String) s.get('Initiator_Comments__c'), 
            		((Date) s.get('Submitted_Date__c')).format(), 
            		((Date) s.get('Requested_Final_Approval_Date__c')).format(), 
            		((User) s.getSObject('Initiated_By__r')).Name));
        }
    }
    
    private void queryApprovals() {
        List<String> recordIds = getApprovalIdsFor('SPCM_CARS_Contract_Summary_Form__c');
        
        Integer offset = pageNumber * pageSize;
        query = baseQuery + orderByPhrase() + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        try {          
            List<SObject> results = Database.query(query);
            createApprovalsList(results);
        } catch(Exception e){
            ApexPages.addMessages(e);
        }
    }

    public class EnhancedItem {
    	public Id recid {get;set;}
    	public String name {get;set;}
        public String agrType {get;set;}
        public String custName {get;set;}
        public String initiatorComments {get;set;}
        public String subDate {get;set;}
        public String reqDate {get;set;}
        public String initiatedBy {get;set;}
        
        EnhancedItem(String rid, String n, String type, String cname, String initComments, String sdate, String rdate, String init) {
        	recId = rid;
        	name = n;
            agrType = type;
            custName = cname;
            initiatorComments = initComments;
            subDate = sdate;
            reqDate = rdate;
            initiatedBy = init;
        }
    }
}