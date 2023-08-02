public with sharing class CFAR_Address_Book_Dispatcher extends CFAR_BaseController {
	
	public Pagereference getTargetUrl {get;set;}
	
	public CFAR_Address_Book_Dispatcher() {
		super();
		getTargetUrl();
	}
	
	public Pagereference getTargetUrl(){
		PageReference newPage;
    	String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    	String id;
    	newPage = new PageReference('/apex/CFAR_AddressBookNew');
    	
    	//for read only and average user check if there's related CFAR contact and if so, add its id to target URL
    	if (getIsReadOnly() || getIsAverageUser()) {
    		String userId = UserInfo.getUserId();
    		List<CFAR_Contact_gne__c> CFARContactForCurrentUser = [select Id from CFAR_Contact_gne__c where User_ref_gne__c = :userId limit 1];
    		if (CFARContactForCurrentUser != null && !CFARContactForCurrentUser.isEmpty()) {
    			id = CFARContactForCurrentUser[0].Id;
    		}
    	}    	
    	if(id != null) {
    		newPage.getParameters().put('id', id);
    	}	
    	if(retUrl != null) {
    		newPage.getParameters().put('retURL', retUrl);
    	}
    	
    	newPage.setRedirect(true);
    	return newPage;
	}
}