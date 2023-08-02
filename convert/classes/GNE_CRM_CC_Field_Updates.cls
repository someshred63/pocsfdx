public with sharing class GNE_CRM_CC_Field_Updates {
	
    public static void setExternalIdValue(List<GNE_CRM_CC_Question__c> triggerNew){
    	for(GNE_CRM_CC_Question__c question :triggerNew){
    		question.External_Id__c = question.Inquiry__c.replace(' ', '_').replace('/', '_') + '_' + String.valueOf(question.Order__c) + '_' + question.Question__c.substringBefore('?').replace(' ', '_').replace('/', '_');
    	}
    }
}