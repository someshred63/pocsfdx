public with sharing class SPCM_CarsWholesalerPaymentsToApprove{

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
    
    String baseQuery = 'SELECT Id, Name, Approval_Status__c, WER_Requested_Amount__c, C_Ops_Issues_Number__c, WER_Receipt_Date_from_Wholesaler__c, Submitted_Date__c, Final_Approver__r.Name, Last_Approver__c, Debit_Memo_Number__c, X340B_ID_Number__c, HIN_ID_Number__c, DEA_ID_Number__c, Price_Group__c, LastModifiedBy.Name, LastModifiedById, LastModifiedDate FROM SPCM_CARS_Wholesaler_Exception_Payment__c WHERE Id IN :recordIds';
    
    //ctor
    public SPCM_CarsWholesalerPaymentsToApprove() {
        pageSize = 10;
        totalNoOfRecs = getPaymentsIdsCountFor('SPCM_CARS_Wholesaler_Exception_Payment__c');
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
            List<String> recordIds = getPaymentsIdsFor('SPCM_CARS_Wholesaler_Exception_Payment__c');
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

        for (SObject queryItem : queryResult)
        {
        	
        	EnhancedItem payment = new EnhancedItem();
        	
        	SPCM_CARS_Wholesaler_Exception_Payment__c record = (SPCM_CARS_Wholesaler_Exception_Payment__c)queryItem;
  
	        payment.recid 			= record.Id;
	        payment.name 			= record.Name;
	        payment.status 			= record.Approval_Status__c;
	        payment.amount 			= String.valueOf(record.WER_Requested_Amount__c);
	        payment.issues 			= record.C_Ops_Issues_Number__c;
	        payment.receiptdate 	= record.WER_Receipt_Date_from_Wholesaler__c.format();
	        payment.submitteddate 	= record.Submitted_Date__c.format();
	        payment.lastapprover 	= record.Final_Approver__r.Name;
	        payment.debit 			= record.Debit_Memo_Number__c;
	        payment.x340B 			= record.X340B_ID_Number__c;
	        payment.hin		 		= record.HIN_ID_Number__c;
	        payment.dea 			= record.DEA_ID_Number__c;
	        payment.pricegroup 		= record.Price_Group__c;
	        payment.lastModifiedBy 	= record.LastModifiedBy.Name;
	        payment.lastModifiedDate = record.LastModifiedDate.format();
	        payment.procInstanceWorkItem = piwiToObjectMap.get(record.Id).Id;
	        
            payments.add(payment);
            
        }
    }
    
    private void queryPayments() {
        List<String> recordIds = getPaymentsIdsFor('SPCM_CARS_Wholesaler_Exception_Payment__c');
        
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
        public String status {get;set;}
        public String amount {get;set;}
        public String issues {get;set;}
        public String receiptdate {get;set;}
        public String submitteddate {get;set;}
        public String lastapprover {get;set;}
        public String debit {get;set;}
        public String x340B {get;set;}
        public String hin {get;set;}
        public String dea {get;set;}
        public String pricegroup {get;set;}
        public String lastModifiedBy {get;set;}
        public String lastModifiedDate {get;set;}
        public String procInstanceWorkItem { get; set;}

    }
}