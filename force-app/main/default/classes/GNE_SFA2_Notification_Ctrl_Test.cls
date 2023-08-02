@isTest
private class GNE_SFA2_Notification_Ctrl_Test {

	@isTest
	public static void getNotificationsTest(){
		String profileName = 'GNE-SFA-';
		List<GNE_SFA2_Notification_Ctrl.Notification> notificationList;
		User user = selectUserWithSpecifiedProfile(profileName, true);
		Id territoryId = [SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :user.Id LIMIT 1].Territory2Id;
		Territory2 terr2 = [SELECT Name FROM Territory2 WHERE id =: territoryId];
		Id notificationId = createNotification(terr2.Name);
		Notification_gne__c queriedNotification = [SELECT Id, Name, Record_Name_gne__c, Change_Type_gne__c, Changed_Field_gne__c FROM Notification_gne__c WHERE Id = :notificationId];
		System.runAs(user) {
			PageReference pageReference = Page.GNE_SFA2_Notifications;
			Test.setCurrentPage(pageReference);
			GNE_SFA2_Notification_Ctrl controller = new GNE_SFA2_Notification_Ctrl();
			Test.startTest();
			notificationList = controller.getNotifications();
			Test.stopTest();
		}
		System.assertEquals(1, notificationList.size());
		System.assertEquals(queriedNotification.Id, notificationList[0].Id);
		System.assertEquals(queriedNotification.Record_Name_gne__c, notificationList[0].name);
		System.assertEquals(queriedNotification.Change_Type_gne__c, notificationList[0].changeType);
		System.assertEquals(queriedNotification.Changed_Field_gne__c, notificationList[0].changeField);
	}

	private static Id createNotification(String territory) {
		Notification_gne__c notification = new Notification_gne__c(Territory_gne__c = territory);
		insert notification;
		return notification.Id;
	}

	private static User selectUserWithSpecifiedProfile(String profileName, Boolean territoryRequired){
		String profileNameUpd = '%' + profileName + '%';
		List<Profile> profiles = [SELECT Id FROM Profile WHERE Name LIKE :profileNameUpd];
		system.assertNotEquals(0, profiles.size(), 'No profile with Name like ' + profileName + ' found.');
		List<User> users;
		if(territoryRequired){
			users = [SELECT Id FROM User WHERE ProfileId IN :profiles AND IsActive = true AND Id IN (Select UserId FROM UserTerritory2Association)];
		} else {
			users = [SELECT Id FROM User WHERE ProfileId IN :profiles AND IsActive = true];
		}
		system.assertNotEquals(0, users.size(), 'No users with profile like ' + profileName + ' found. Territory2 required = ' + territoryRequired);
		return users[0];
	}

	@isTest
	public static void notificationClassTest(){
		Datetime dt1 = Datetime.newInstance(2016, 3, 3);
		Datetime dt2 = Datetime.newInstance(dt1.year(), dt1.month(), dt1.day());
		GNE_SFA2_Notification_Ctrl.Notification n = new GNE_SFA2_Notification_Ctrl.Notification(
			'id',
			'name',
			'changeType',
			'changeField',
			dt1,
			'newValue',
			'oldValue',
			'territory',
			null,
			null,
			null,
			false
		);

		System.assertEquals('id', n.id);
		System.assertEquals('name', n.name);
		System.assertEquals('changeType', n.changeType);
		System.assertEquals('changeField', n.changeField);
		System.assertEquals(dt2, n.createdDate);
		System.assertEquals('newValue', n.newValue);
		System.assertEquals('oldValue', n.oldValue);
		System.assertEquals('territory', n.territory);
		System.assertEquals('', n.description);
	}
}