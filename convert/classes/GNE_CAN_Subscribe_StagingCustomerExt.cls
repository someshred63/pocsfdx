public with sharing class GNE_CAN_Subscribe_StagingCustomerExt 
{	
	public List<Stg_SFA_Subscribe_Apex_Job_Error__c> relatedErrors {
		get; private set;
	}
	
	public List<Account> relatedAccounts {
		get; private set;
	}
	
	public Stg_SFA_Cust_Can__c stagingCustomer {
		get; private set;
	}
		
	public Boolean isSubscribeRunning { 
		get{
			return this.batchRunner.isRunning;
		}
	}
	  
	final ApexPages.StandardController controller;	
	final GNE_CAN_Subscribe_BatchRunner batchRunner;
				 
	public GNE_CAN_Subscribe_StagingCustomerExt(ApexPages.StandardController controller){   
		controller.addFields(new List<String>{'Cust_class_can__c', 'Name', 'Roche_Cust_Id_can__c', 'Src_Cust_Id_can__c'});	                 		
 		this.stagingCustomer = (Stg_SFA_Cust_Can__c)controller.getRecord();
 		
 		this.controller = controller;
		this.batchRunner = this.createBatchRunner();
	}
	
	public PageReference initController() {
		refreshRelatedLists();
		return null;
	}
			 
	public PageReference subscribeAction(){				
		try{		
			this.batchRunner.run();					
			showInfoMessage(this.batchRunner.stateMessage);		
		}
		catch (Exception e) {	
            showErrorMessage(e);
        }
        return null;
	}

	public PageReference editAction(){				
		return controller.edit();
	}													
	
	public PageReference refreshView(){					
		String stateMsg = this.batchRunner.stateMessage;
		if(hasValue(stateMsg))
			showInfoMessage(stateMsg);
			
		if(!isSubscribeRunning) {
			refreshRelatedLists();
		}		
		return null;			
	}
	
	private void refreshRelatedLists() {
		Set<String> rocheIds = new Set<String>{stagingCustomer.Roche_Cust_Id_can__c};
		Set<String> sfdcIds = stagingCustomer.Src_Cust_Id_can__c==null ? new Set<String>() : new Set<String>{stagingCustomer.Src_Cust_Id_can__c};
		
		relatedErrors = GNE_CAN_Subscribe_DAO.getErrorsByRocheIds(rocheIds);
		relatedAccounts = GNE_CAN_Subscribe_DAO.getAccountsBySfdcIds(sfdcIds);
	}					 
	
	private GNE_CAN_Subscribe_BatchRunner createBatchRunner(){
		Set<Id> stgIds = new Set<Id>{this.stagingCustomer.Id};
		 		
		if('HCO' == this.stagingCustomer.Cust_class_can__c)	{
			return GNE_CAN_Subscribe_BatchRunner.newInstanceForHCO(stgIds);
		} else if('HCP' == this.stagingCustomer.Cust_class_can__c)	{
			return GNE_CAN_Subscribe_BatchRunner.newInstanceForHCP(stgIds);
		} else {
			System.debug('Unsupported Customer Class: ' + this.stagingCustomer.Cust_class_can__c);
			return null;
		}				
	}
			 
	private void showInfoMessage(String message){
    	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, message);
	   	ApexPages.addMessage(msg);
    } 
    
    private void showErrorMessage(Exception e){
    	 ApexPages.addMessages(e);
    } 
    
    private Boolean hasValue(String s){
    	return (s!=null) && (s.trim()!='');    	
    }
}