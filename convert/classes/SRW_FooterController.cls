public with sharing class SRW_FooterController {
	public SRW_FooterController() {
		
	}

	@RemoteAction
    public static String retrievePrivacyPolicy() {
    	List<SRW_Custom_Message_gne__c> msgs = [select Id, Question_Number_gne__c, Answer_gne__c, Question_gne__c, Type_gne__c from SRW_Custom_Message_gne__c where Type_gne__c = 'Privacy Policy'];
    	if(msgs != null && msgs.size() > 0) {
    		return msgs.get(0).Answer_gne__c;
    	}
    	return '';
  	}

	@RemoteAction
    public static String retrieveCopyrights() {
    	List<SRW_Custom_Message_gne__c> msgs = [select Id, Question_Number_gne__c, Answer_gne__c, Question_gne__c, Type_gne__c from SRW_Custom_Message_gne__c where Type_gne__c = 'Copyrights'];
    	if(msgs != null && msgs.size() > 0) {
    		return msgs.get(0).Answer_gne__c;
    	}
    	return '';
  	}

  	@RemoteAction
    public static String retrieveTermsOfUse() {
    	List<SRW_Custom_Message_gne__c> msgs = [select Id, Question_Number_gne__c, Answer_gne__c, Question_gne__c, Type_gne__c from SRW_Custom_Message_gne__c where Type_gne__c = 'Terms of Use'];
    	if(msgs != null && msgs.size() > 0) {
    		return msgs.get(0).Answer_gne__c;
    	}
    	return '';
  	}

}