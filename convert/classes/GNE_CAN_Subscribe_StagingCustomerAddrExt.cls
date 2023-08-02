public with sharing class GNE_CAN_Subscribe_StagingCustomerAddrExt {
	public Stg_SFA_Cust_Addr_Can__c stagingCustomerAddr {get; private set;}
	public List<Stg_SFA_Subscribe_Apex_Job_Error__c> relatedErrors {get; private set;}
	public List<Address_vod__c> relatedAddresses {get; private set;}
	
	public GNE_CAN_Subscribe_StagingCustomerAddrExt(ApexPages.StandardController controller){   
		controller.addFields(new List<String>{'Roche_Addr_Id_can__c', 'Name', 'Src_Addr_Id_can__c'});	                
 		
 		stagingCustomerAddr = (Stg_SFA_Cust_Addr_Can__c)controller.getRecord();		
	}
	
	public PageReference initController() {
		
		Set<String> rocheIds = new Set<String>{stagingCustomerAddr.Roche_Addr_Id_can__c};
		Set<String> sfdcIds = new Set<String>{stagingCustomerAddr.Src_Addr_Id_can__c};
		relatedErrors = GNE_CAN_Subscribe_DAO.getErrorsByRocheAddressIds(rocheIds);
		relatedAddresses = GNE_CAN_Subscribe_DAO.getAddressesBySfdcIds(sfdcIds);
	
		return null;
	} 

}