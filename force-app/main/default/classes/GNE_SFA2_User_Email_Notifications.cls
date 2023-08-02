/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-10
*  Description: This is a helper class for GNE_SFA2_User_Trigger for handling User email notifications
*  Test class: GNE_SFA2_User_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
public with sharing class GNE_SFA2_User_Email_Notifications {
	
	private static Integer salesforceUserCount = null;
	
	public static String buildUsersList(List<User> userList) {
		String result = '<ul>';
		for(User user : userList) {
			result += '<li>' + user.Name + '</li>';
		}
		result += '</ul>';
		return result;
	}
	
	private static void sendLimitNotification(List<User> triggerNew) {
		GNE_SFA2_User_Count_Notification__c userCountCustomSetting = GNE_SFA2_User_Count_Notification__c.getInstance('Default');
		GNE_SFA2_User_Max_Count__c userMaxCountCustomSetting = GNE_SFA2_User_Max_Count__c.getInstance('Default');
		GNE_SFA2_User_Notification_Email__c userNotificationEmailCustomSetting = GNE_SFA2_User_Notification_Email__c.getInstance('Default');
		// check if custom settings are set
		if(userCountCustomSetting == null || userMaxCountCustomSetting == null || userNotificationEmailCustomSetting == null) {
			return;
		}
		Integer notificationUserCountLimit = Integer.valueOf(GNE_SFA2_User_Count_Notification__c.getInstance('Default').User_count__c);
		Integer maxUserCountLimit = Integer.valueOf(GNE_SFA2_User_Max_Count__c.getInstance('Default').User_count__c);
		String notificationEmail = GNE_SFA2_User_Notification_Email__c.getInstance('Default').Email__c;
		if(salesforceUserCount == null) {
			salesforceUserCount = [ SELECT count() FROM User WHERE isActive = true AND profile.userlicense.name = 'Salesforce' ];
		}
		List<User> deactivatedUsers = new List<User>();
		List<User> usersAboveLimit = new List<User>();
		Boolean sendEmail = false;
		for (User user : triggerNew){
		 	if(user.isActive && salesforceUserCount >= maxUserCountLimit){
		        user.isActive = false;
		        deactivatedUsers.add(user);
		        sendEmail = true;
		    }
		    
		    if (salesforceUserCount > notificationUserCountLimit){
		    	sendEmail = true;
		    	usersAboveLimit.add(user);
		    }
		    // we need to increase counter in case there is more Users in this insert scope.
		    salesforceUserCount++;
		}
		
		// send notification if necessary
		if(sendEmail) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         	mail.setToAddresses(new String[] {notificationEmail});
         	mail.setSubject('Salesforce.com User License Limit Excedded');
         	mail.setHtmlBody(String.format(System.Label.User_count_notification_email_content, new List<String> { String.valueOf(notificationUserCountLimit), String.valueOf(salesforceUserCount), buildUsersList(usersAboveLimit), buildUsersList(deactivatedUsers)} ));
         	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	
	public static void onBeforeInsert(List<User> triggerNew) {
		sendLimitNotification(triggerNew);	
	}
}