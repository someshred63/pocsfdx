public without sharing class CORE_Pub_Party_Controller{

    public CORE_Pub_Party_Controller(ApexPages.StandardController controller) {
    
    }

    @RemoteAction
    public static CORE_Pub_Party__c executeSubscribe(String partyId) {
    	String pId = [Select Party_Id_gne__c from CORE_Pub_Party__c where id = :partyId].Party_Id_gne__c;
        CORE_Subscribe_Object__c subscribeObject = [select id from CORE_Subscribe_Object__c limit 1];
		Core_Subscribe_Job__c job = new Core_Subscribe_Job__c(Name= 'SubscribeParty_'+pId, Status_gne__c='New', Subscribe_Object_gne__c = subscribeObject.Id);
		insert job;
		Set<String>parties = new Set<String>();
		parties.add(pId);
		CORE_Subscribe_Process subProcess = new CORE_Subscribe_Process();
		subProcess.executeSubscribeASI(parties, job.id);
        return [SELECT LastModifiedDate, LastModifiedById, LastModifiedBy.Name, Last_Sub_Exec_gne__c, Sub_Exec_Status_gne__c, Comments_gne__c FROM CORE_Pub_Party__c WHERE Id = :partyId LIMIT 1];
    }
}