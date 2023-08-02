/************************************************************
*  @author: Lukasz Kozminski, contractors Roche
*  Date: 2016-01-20
*  Description: This is a util class for creating notifications
*  
*************************************************************/
public without sharing class GNE_SFA2_Notification_Handler {
	
	public static final String MAPPING_CHANGE_TYPE = 'Account Mappings';
	
	public static void onAfterInsertTSF(List<TSF_vod__c>tsfes){
		createNotifications(tsfes, GNE_SFA2_Notification_Ctrl.ADD_ACCOUNT_TYPE);
	}
	
	public static void onAfterDeleteTSF(List<TSF_vod__c>tsfes){
		createNotifications(tsfes, GNE_SFA2_Notification_Ctrl.REMOVE_ACCOUNT_TYPE);
	}
	
	public static void onAfterDeleteMapping(List<FRM_HCO_Mapping_gne__c>mappings){
		createNotifications(mappings, GNE_SFA2_Notification_Ctrl.REMOVE_MAPPING_TYPE);
	}
	
	public static void onAfterInsertMapping(List<FRM_HCO_Mapping_gne__c>mappings){
		createNotifications(mappings, GNE_SFA2_Notification_Ctrl.ADD_MAPPING_TYPE);
	}
	
	public static void createNotificationOnAccountUpdate(List<Account>triggerOld, List<Account>triggerNew){
		List<Notification_gne__c> notifications = new List<Notification_gne__c>();
    	Map<String, Schema.SObjectField> fSchema = Schema.SObjectType.Account.fields.getMap();
    	
		for(Integer i = 0; i < triggerOld.size(); i++){
			Account oldAccount = triggerOld[i];
			Account newAccount = triggerNew[i];
    		for (GNE_SFA2_Account_Tracked_Fields__c field : GNE_SFA2_Account_Tracked_Fields__c.getall().values()){
    			if(newAccount.isPersonAccount == field.isPersonAccount_gne__c){
	    			if(oldAccount.get(field.Name) != newAccount.get(field.Name)){
	    				String oldValue = (String)oldAccount.get(field.Name) == null ? '': (String)oldAccount.get(field.Name);
	    				if(oldValue.length()>255){
	    					oldValue = oldValue.substring(0,255);
	    				}
	    				String newValue = (String)newAccount.get(field.Name) == null ? '': (String)newAccount.get(field.Name);
	    				if(newValue.length()>255){
	    					newValue = oldValue.substring(0,255);
	    				}
						notifications.add(
		    				new Notification_gne__c(
		       					Record_Id_gne__c = newAccount.Id,
		   						Record_Name_gne__c = newAccount.isPersonAccount ? newAccount.Full_Name_gne__pc : newAccount.name,
		   						Change_Type_gne__c = newAccount.isPersonAccount ? GNE_SFA2_Notification_Ctrl.CHANGE_HCP_TYPE : GNE_SFA2_Notification_Ctrl.CHANGE_HCO_TYPE,
		   						Changed_Field_gne__c = fSchema.get(field.Name).getDescribe().getLabel(),
		   						Old_value_gne__c = oldValue,
		   						New_value_gne__c = newValue
		   					)
			       		);	    			
		    		}
    			}
			}
		}
		if(!notifications.isEmpty()){
			insert notifications;
		}
	}
	
	public static void createNotificationOnAddressUpdate(List<Address_vod__c>triggerOld, List<Address_vod__c>triggerNew){
		List<String>trackedFields = new List<String>();  
		for(GNE_SFA2_Address_Tracked_Fields__c trackedFied: GNE_SFA2_Address_Tracked_Fields__c.getall().values()){
			trackedFields.add(trackedFied.Name);
		}
		
    	List<Notification_gne__c> notifications = new List<Notification_gne__c>();
    	Map<String, Schema.SObjectField> fSchema = Schema.SObjectType.Address_vod__c.fields.getMap();
    	
    	List<Id> accIds = new List<Id>();
		for(Integer i = 0; i < triggerOld.size(); i++){
			Address_vod__c oldAddress = triggerOld[i];
			Address_vod__c newAddress = triggerNew[i];
			   	
	    	for (String field : trackedFields){
	    		if(oldAddress.get(field) != newAddress.get(field)){
	    			accIds.add(newAddress.Account_vod__c);
	    		}
	    	}
		}
		Map<Id, Account>accounts = new Map<Id, Account>([SELECT Id, Name, Full_Name_gne__pc, Main_Address_gne__c, isPersonAccount, (SELECT id, Call_Datetime_vod__c, Parent_Address_vod__c FROM Call2_vod__r WHERE Completed_gne__c=true ORDER BY Call_Datetime_vod__c DESC LIMIT 1) FROM Account WHERE id IN :accIds]);
		
		for(Integer i = 0; i < triggerOld.size(); i++){
			Address_vod__c oldAddress = triggerOld[i];
			Address_vod__c newAddress = triggerNew[i];
			Account acc = accounts.get(newAddress.Account_vod__c);
			if(acc != null){
				Call2_vod__c lastInteraction = acc.Call2_vod__r.isEmpty() ? null : acc.Call2_vod__r[0];
				if(acc != null && ((lastInteraction != null && lastInteraction.Parent_Address_vod__c == newAddress.Id) || (lastInteraction == null && acc.Main_Address_gne__c == newAddress.Id))){
			    	for (String field : trackedFields){
			    		if(oldAddress.get(field) != newAddress.get(field)){
							notifications.add(
			       				new Notification_gne__c(
			       					Record_Id_gne__c = newAddress.Account_vod__c,
			   						Record_Name_gne__c = acc.isPersonAccount ? acc.Full_Name_gne__pc : acc.Name,
			   						Change_Type_gne__c = acc.isPersonAccount ? GNE_SFA2_Notification_Ctrl.CHANGE_HCP_TYPE : GNE_SFA2_Notification_Ctrl.CHANGE_HCO_TYPE,
			   						Changed_Field_gne__c = fSchema.get(field).getDescribe().getLabel(),
			   						Old_value_gne__c = (String)oldAddress.get(field),
			   						New_value_gne__c = (String)newAddress.get(field)
			       				)
					       	);	    			
				    	}
		    		}
		    	}
			}
		}
		if(!notifications.isEmpty()){
			insert notifications;
		}
	}
	
	 private static void createNotifications(List<TSF_vod__c>tsfes, String changeType){
		List<Notification_gne__c> notifications = new List<Notification_gne__c>();
		List<Id>accountIds = new List<Id>();
    	for (TSF_vod__c tsf : tsfes){
    		if (String.isNotBlank(tsf.Account_vod__c)) {
    			accountIds.add(tsf.Account_vod__c);
    		}
    	}
       	Map<Id, Account>accountMap = new Map<Id, Account>([SELECT Id, Name, Full_Name_gne__pc, isPersonAccount, RecordType.developerName FROM Account WHERE Id IN :accountIds]);
       	
       	for (TSF_vod__c tsf : tsfes){
       		if (accountMap.containsKey(tsf.Account_vod__c)) {
	       		Account acc = accountMap.get(tsf.Account_vod__c);
	    		Notification_gne__c notification = new Notification_gne__c(
	       				Record_Id_gne__c = tsf.Account_vod__c,
	   					Territory_gne__c = tsf.Territory_vod__c,
	   					Change_Type_gne__c = changeType,
	       				Record_Name_gne__c = acc.isPersonAccount ? acc.Full_Name_gne__pc : acc.Name,
	       				Account_Record_Type_Name_gne__c = acc.RecordType.developerName
	       		);
	    		notifications.add(notification);
       		}
       	}
        if (!notifications.isEmpty()){
        	insert notifications;
        }
	}
	
	private static void createNotifications(List<FRM_HCO_Mapping_gne__c>mappings, String changeType){
		List<Notification_gne__c> notifications = new List<Notification_gne__c>();
		
		List<Id>accountIds = new List<Id>();
		List<Id>userIds = new List<Id>();
    	for (FRM_HCO_Mapping_gne__c mapping : mappings){
    		accountIds.add(mapping.FRM_HCO_Account_gne__c);
    		userIds.add(mapping.createdById);
    	}
       	Map<Id, Account>accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
       	Map<Id, User>userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);
       	
       	for (FRM_HCO_Mapping_gne__c mapping : mappings){

    		Notification_gne__c notification = new Notification_gne__c(
       				Record_Id_gne__c = mapping.FRM_HCO_Account_gne__c,
   					Change_Type_gne__c = MAPPING_CHANGE_TYPE,
       				Record_Name_gne__c = accountMap.get(mapping.FRM_HCO_Account_gne__c).Name,
       				Description_gne__c = getDescription(changeType, mapping, userMap.get(mapping.createdbyid))
       		);
    		notifications.add(notification);
       	}
        if (!notifications.isEmpty()){
        	insert notifications;
        }
	}
	
	private static String getDescription(String changeType, FRM_HCO_Mapping_gne__c mapping, User creator){
		String description;
		String mappingDesciption;
		if(String.isEmpty(mapping.HCP_SFA_Prescriber_Address_Line_2_gne__c)){
			mappingDesciption = '{0} {1}, {2}, {3}, {4}, {5}';
			mappingDesciption = String.format(mappingDesciption, new List<String>{mapping.HCP_SFA_Prescriber_First_Name_gne__c, mapping.HCP_SFA_Prescriber_Last_Name_gne__c, mapping.HCP_SFA_Prescriber_Address_Line_1_gne__c, mapping.HCP_SFA_City__c, mapping.HCP_SFA_State_gne__c, mapping.HCP_SFA_Zip_gne__c});
		} else {
			mappingDesciption = '{0} {1}, {2}, {3}, {4}, {5}, {6}';
			mappingDesciption = String.format(mappingDesciption, new List<String>{mapping.HCP_SFA_Prescriber_First_Name_gne__c, mapping.HCP_SFA_Prescriber_Last_Name_gne__c, mapping.HCP_SFA_Prescriber_Address_Line_1_gne__c, mapping.HCP_SFA_Prescriber_Address_Line_2_gne__c, mapping.HCP_SFA_City__c, mapping.HCP_SFA_State_gne__c, mapping.HCP_SFA_Zip_gne__c});
		}
		
		if(changeType == GNE_SFA2_Notification_Ctrl.REMOVE_MAPPING_TYPE){
			description = 'Unmapped<br/>By User: {0}<br/>HCP@Address: {1}';
			description = String.format(description, new List<String>{creator.Name, mappingDesciption});
		} else if(changeType == GNE_SFA2_Notification_Ctrl.ADD_MAPPING_TYPE && !mapping.Is_Auto_Mapped_gne__c){
			description = 'New Mapping Created<br/>By User: {0}<br/>HCP@Address: {1}';
			description = String.format(description, new List<String>{creator.Name ,mappingDesciption});
		} else if(changeType == GNE_SFA2_Notification_Ctrl.ADD_MAPPING_TYPE && mapping.Is_Auto_Mapped_gne__c){
			description = 'Auto-mapped<br/>HCP@Address: {0}';
			description = String.format(description, new List<String>{mappingDesciption});
		}
		return description;
	}
}