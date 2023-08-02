public with sharing class SPCM_CarsPaymentsToApprove {

	public Integer pageSize{get;set;}
    public Integer noOfPages{get;set;}
    public Integer pageNumber{get;set;}
    public Integer totalNoOfRecs {get; set;}
    public List<EnhancedItem> payments {get;set;}
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
        queryPayments();
    }
    
    private String orderByPhrase() {
        return ' ORDER BY ' + sortField + ' ' + sortDir;
    }
    
    String baseQuery = 'SELECT Id, Name, Year__c, Period__c, Approval_Status__c, Appr_Approver_1_Original__c, Payment_Due_Date__c, Contract_Number__c, Customer_Name__r.name, Approval_Amount__c, Submitted_Date__c, Claim_Number__c, Last_Approver__r.name, Payment_Type__r.name, LastModifiedBy.name, LastModifiedDate FROM SPCM_CARS_Payment_Packet__c WHERE Id IN :recordIds';
    
    //ctor
    public SPCM_CarsPaymentsToApprove() {
        pageSize = 10;
        totalNoOfRecs = getPaymentsIdsCountFor('SPCM_CARS_Payment_Packet__c');
        payments = new List<EnhancedItem>();
        getInitialPaymentsSet();  
    }
    
    private integer getPaymentsIdsCountFor (String objectName) {
        return getPaymentsIdsFor(objectName).size();
    }
    
    public PageReference getInitialPaymentsSet() {
        pageNumber = 0;
        noOfPages = totalNoOfRecs/pageSize;
        
        if (Math.mod(totalNoOfRecs, pageSize) > 0)
            noOfPages++;
        
        try{
            List<String> recordIds = getPaymentsIdsFor('SPCM_CARS_Payment_Packet__c');
            createPaymentsList(Database.query(baseQuery + orderByPhrase () + ' LIMIT ' + pageSize));
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public PageReference next() {
        pageNumber++;
        queryPayments();
        return null;
    }

    public PageReference previous() {
        pageNumber--;
        if (pageNumber < 0)
            return null;
        queryPayments();
        return null;
    }

    private List<String> getPaymentsIdsFor(String objectName) {
        List<Schema.DescribeSObjectResult> result = Schema.describeSObjects(new String[]{objectName});
        String objId = result.get(0).getKeyPrefix();

        String userId = UserInfo.getUserId();
        piwis = [SELECT id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ActorId=:userId];
        List<String> recordIds = new List<String>();
        for (ProcessInstanceWorkItem piwi : piwis) {
            String recordId = (String) piwi.ProcessInstance.TargetObjectId;
            if (recordId.startsWith(objId)){
                recordIds.add(recordId);
                piwiToObjectMap.put(recordId, piwi);
            }
        }
        
        return recordIds;    
    }
    
    private void createPaymentsList(List<SObject> queryResult) {
        payments.clear();

        //get original approvers names from ids
        List<string> approverIds = new List<string>();
        List<user> approvers = new List<user>();
        
        for (SObject s : queryResult) {
            approverIds.add((String) s.get('Appr_Approver_1_Original__c'));
        }
        approvers = [select id, name from User where id in :approverIds];
        Map<id, user> approverNamesMap = new Map<Id, user>(approvers);

        for (integer i = 0; i < queryResult.size(); i++){
            
            

            payments.add(new EnhancedItem(
                    (Id) queryResult[i].get('Id'),
                    (String) queryResult[i].get('Name'),
                    (String)queryResult[i].get('Year__c'),
                    (String)queryResult[i].get('Period__c'),
                    (String) queryResult[i].get('Approval_Status__c'),
                    approverNamesMap.get((Id) queryResult[i].get('Appr_Approver_1_Original__c')) == null ? '' : approverNamesMap.get((Id) queryResult[i].get('Appr_Approver_1_Original__c')).name,
                    ((Date)queryResult[i].get('Payment_Due_Date__c')).format(),
                    (String) queryResult[i].get('Contract_Number__c'),
                    ((SPCM_Customer_Name__c)queryResult[i].getSObject('Customer_Name__r')).name,
                    ((decimal) queryResult[i].get('Approval_Amount__c')).format(),
                    ((Date)queryResult[i].get('Submitted_Date__c')).format(),
                    (String) queryResult[i].get('Claim_Number__c'),
                    ((User)queryResult[i].getSObject('Last_Approver__r')).name,
                    ((SPCM_Payment_Type__c)queryResult[i].getSObject('Payment_Type__r')).name,
                    ((User)queryResult[i].getSObject('LastModifiedBy')).name,
                    ((DateTime)queryResult[i].get('LastModifiedDate')).format(),
                    piwiToObjectMap.get((Id) queryResult[i].get('Id')).Id
				));
        }
    }
    
    private void queryPayments() {
        List<String> recordIds = getPaymentsIdsFor('SPCM_CARS_Payment_Packet__c');
        
        Integer offset = pageNumber * pageSize;
        query = baseQuery + orderByPhrase() + ' LIMIT '+ pageSize +' OFFSET '+ offset;
        try {          
            List<SObject> results = Database.query(query);
            createPaymentsList(results);
        } catch(Exception e){
            ApexPages.addMessages(e);
        }
    }

    List<ProcessInstanceWorkItem> piwis;
    Map<id, ProcessInstanceWorkItem> piwiToObjectMap = new Map<id, ProcessInstanceWorkItem>();

    public class EnhancedItem {
        public Id recid {get;set;}
        public String name {get;set;}
        public String year {get;set;}
        public String period {get;set;}
        public String status {get;set;}
        public String approver1 {get;set;}
        public String dueDate {get;set;}
        public String contractNumber {get;set;}
        public String custName {get;set;}
        public String amount {get;set;}
        public String submittedDate {get;set;}
        public String claimNumber {get;set;}
        public String lastApprover {get;set;}
        public String paymentType {get;set;}
        public String lastModifiedBy {get;set;}
        public String lastModifiedDate {get;set;}
        public String procInstanceWorkItem {get;set;}
        
        EnhancedItem(String rid, String n, String yer, String per, String stat, String appr, String due, String contNum, String cname,
        			String am, String subm, String claim, String lastAppr, String type, String modBy, String modDate, string procInstWorkItem) {
            recId = rid;
            name = n;
            year = yer;
            period = per ;
			status = stat ;
			approver1 = appr;
			dueDate = due ;
			contractNumber = contNum;
			custName = cname;
			amount = am ;
			submittedDate = subm ;
			claimNumber = claim ;
			lastApprover = lastAppr ;
			paymentType = type ;
			lastModifiedBy = modBy ;
			lastModifiedDate = modDate;
            procInstanceWorkItem = procInstWorkItem;
        }
    }
}