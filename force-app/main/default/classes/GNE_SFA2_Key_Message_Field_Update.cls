/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/6/2013
*  Description: This class GNE_SFA2_Key_Message_Field_Update handles field updates on Key_Message_vod__c object on DML operations
*  This class is being used in GNE_SFA2_Key_Message_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Key_Message_Field_Update {
	// On Before Delete method
	public static void OnBeforeDelete (Map<Id,Key_Message_vod__c> oldKeyMsgMap,  List<Key_Message_vod__c> newKeyMsgList){
		keyMessageWithCallDelete(oldKeyMsgMap, newKeyMsgList);
	}
	//implemeted based on trigger Key_Message_vod  (before delete)
	private static void keyMessageWithCallDelete(Map<id, Key_Message_vod__c> oldKeyMsgMap, List<Key_Message_vod__c> newKeyMsgList){
		Set<Id> KeyMessageIds = oldKeyMsgMap.keySet();
		List <Call2_Key_Message_vod__c > msgs = [Select Id,Key_Message_vod__c  from Call2_Key_Message_vod__c where  Key_Message_vod__c in :KeyMessageIds];
		for (Integer i = 0; i < msgs.size();i++) {
			oldKeyMsgMap.get(msgs[i].Key_Message_vod__c).addError (Label.GNE_SFA2_Key_Message_should_not_be_deleted);
		}
	}
}