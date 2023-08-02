public with sharing class SRW_HomePageRouterController {
	
	
	public PageReference routeToTarget(){
		
		User tempU = [Select ContactId from User where id= :UserInfo.getUserId()][0];

		system.debug(tempU.COntactId);
		SRW_Security_Community_Data__c[] tmpSecur = null;
		if(tempU.COntactId!= null){
			tmpSecur = [select Id from SRW_Security_Community_Data__c where Trading_Partner_gne__r.Contact_gne__c = :tempU.ContactId  and SecurityAnswer__c != null];
			system.debug(tmpSecur);
			if(tmpSecur.size() == 0){tmpSecur = null;}
		}
		system.debug('MICK: User is : ' + UserInfo.getUserType());
        if(UserInfo.getUserType() == 'Guest'){
            return new PageReference('/site/SiteLogin.apexp');
        } 
        else if((UserInfo.getUserType() == 'PowerPartner' || 'PowerCustomerSuccess'.equals(UserInfo.getUserType())) && tmpSecur != null){
        	return Page.SRW_SubmitSalesData;
        }
        
        else if((UserInfo.getUserType() == 'PowerPartner' || 'PowerCustomerSuccess'.equals(UserInfo.getUserType())) && tmpSecur == null){
        	return Page.SRW_SetPassword;
            //return Page.SRW_SetSecurityQA;
        }
        
        else if(UserInfo.getUserType() == 'Standard'){
           	return Page.SRW_TradingPartnerManagement;
        } else return new PageReference('/site/SiteLogin.apexp');
    }
}