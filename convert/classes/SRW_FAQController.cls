public without sharing class SRW_FAQController {
	public SRW_FAQController() {
		
	}

	public List<SRW_Custom_Message_gne__c> getFAQ() {
		return [select Id, Question_Number_gne__c, Answer_gne__c, Question_gne__c, Type_gne__c from SRW_Custom_Message_gne__c where Type_gne__c = 'FAQ' order by Question_Number_gne__c];
	}

}