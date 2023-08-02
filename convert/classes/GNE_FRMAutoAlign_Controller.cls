public class GNE_FRMAutoAlign_Controller {

    static final String BATCH_FRMAUTOALIGN       = 'GNE_Batch_FRMAutoAlign';    
    static final String BATCH_INSERTACCOUNTSHARE = 'GNE_Batch_InsertFRMAutoAlignments';
    
    case_acct_frm_auto_align_gne__c frm_autoalign = new case_acct_frm_auto_align_gne__c();
    
    public DateTime lastSuccessfulCompletionDate { set; get; }
        
    public case_acct_frm_auto_align_gne__c getAutoAlign () {
        return 	frm_autoalign;
    }
        
    void lastSuccessfulRunDate () {    	    	
    	AsyncApexJob[] asyncApexJobList 
    	                          =  [Select Id, CreatedDate, Status, NumberOfErrors, 
                                      JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                      from AsyncApexJob 
                                      where     NumberOfErrors = 0
                                            and status in ('Completed') 
                                            and ApexClass.Name = :GNE_FRMAutoAlign_Controller.BATCH_FRMAUTOALIGN 
                                      order by CreatedDate desc];

        if ( asyncApexJobList.size() > 0 ) {                                            
        	lastSuccessfulCompletionDate = asyncApexJobList[0].CreatedDate;
        }  
    }
    
    public GNE_FRMAutoAlign_Controller() {
    	lastSuccessfulRunDate();
    	frm_autoalign.account_aligned_date_gne__c = lastSuccessfulCompletionDate;
    	if ( frm_autoalign.account_aligned_date_gne__c == null ) {
    	   frm_autoalign.account_aligned_date_gne__c = DateTime.now().addDays(-365);	
    	}
    }
    

    public boolean getEnableBatch() {
        return isRunning();
    }
    
    public String BatchProcessStatus { set; get; }
    
    boolean isRunning () {
    	BatchProcessStatus = '';
        AsyncApexJob[] asyncApexJobList = [Select Id, Status, NumberOfErrors, 
			                               JobItemsProcessed, TotalJobItems,  
			                               ApexClass.Name 
			                               from AsyncApexJob 
			                               where (ApexClass.Name = 
			                                 :GNE_FRMAutoAlign_Controller.BATCH_FRMAUTOALIGN or 
			                                 ApexClass.Name =
			                                 :GNE_FRMAutoAlign_Controller.BATCH_INSERTACCOUNTSHARE)
			                               and status in ('Processing','Queued') ];
			                                             
        if ( asyncApexJobList.size() > 0 )  	{
        	ApexClass apexClass   = asyncApexJobList[0].ApexClass;
        	String batchApexClass = apexClass.Name;		                                          	
            BatchProcessStatus = 'Batch Program ' + batchApexClass + 
                                 ' in progress.  Total / Processed / Error Job counts : ' + 
                                  asyncApexJobList[0].TotalJobItems + '/' +
                                  asyncApexJobList[0].JobItemsProcessed + '/' + 
                                  asyncApexJobList[0].NumberOfErrors;
                                 
            return True;
        }
        return false;            	   
    }
    
    public void process() { 
        lastSuccessfulRunDate();
    }
    
    
    public void runBatchAutoAlign() {
        try {
            database.executeBatch(new GNE_Batch_FRMAutoAlign(frm_autoalign.account_aligned_date_gne__c));
        } catch (Exception e) {
            ApexPages.addMessages(e);                   
        }                	
    }
    
    public void runBatchAccountShare() {
    	try {
	        database.executeBatch(new GNE_Batch_InsertFRMAutoAlignments());
    	} catch (Exception e) {
            ApexPages.addMessages(e);                   
        }            
    }
    
}