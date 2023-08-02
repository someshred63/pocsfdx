public with sharing class GNE_SFA2_PFG_Trans_Ext extends GNE_SFA2_DynamicVFLoader{
	private ApexPages.Standardcontroller controller;
	public SFA2_PFG_Transaction_gne__c transactionObject {get; set;}
	public String recordTypeVisName {get; set;}
	public List<SFA2_PFG_Transaction_gne__c> relatedTransactions {get;set;}
	public Boolean isDtp {get; set;}
	public Boolean isOrder { get; private set; }
	
	public GNE_SFA2_PFG_Trans_Ext(ApexPages.StandardController controller){
		super(controller,'/apex/GNE_SFA2_PFG_Transactions_Layout');
		this.controller = controller;
		
		SFA2_PFG_Transaction_gne__c mainTrx = GNE_SFA2_PFG_DAO.getTransactionById(myObject.Id)[0];
		myObject = mainTrx;
		recordTypeVisName = mainTrx.Transaction_Type_gne__c;
		isDtp = mainTrx.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
		isOrder = 
			recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER || 
			recordTypeVisName == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF;
		relatedTransactions = getRelatedTransactions();		
	}
	
	public String getPfgActiveMenuItem() {
    	return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }
	
	private List<SFA2_PFG_Transaction_gne__c> getRelatedTransactions(){
		SFA2_PFG_Transaction_gne__c mainTrx = (SFA2_PFG_Transaction_gne__c)myObject;
		
		if((mainTrx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER ||
			mainTrx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF ||
			mainTrx.Transaction_Type_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT)&&
		   mainTrx.Transaction_Ref_Number_gne__c!=null) {
			return GNE_SFA2_PFG_DAO.getPfgTransactionsByRefNo(new Set<String>{mainTrx.Transaction_Ref_Number_gne__c});	
		} else {
			return new List<SFA2_PFG_Transaction_gne__c>{mainTrx};
		}
    }
}