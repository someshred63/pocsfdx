/************************************************************
*  @author: Lukasz Kozminski, contractors Roche
*  Date: 2016-01-20
*  Description: This is a controller for Notifications
*
*  Modification History
*  Date        Name        Description
* 2017-02-15  kozminsl	Frm support
*
*************************************************************/
public with sharing class GNE_SFA2_Notification_Ctrl {

	public static final String CHANGE_HCP_TYPE = 'HCP Changes';
	public static final String CHANGE_HCO_TYPE = 'HCO Changes';
	public static final String REMOVE_ACCOUNT_TYPE = 'Removals from Territory';
	public static final String ADD_MAPPING_TYPE = 'ADD Mapping';
	public static final String REMOVE_MAPPING_TYPE = 'REMOVE Mapping';

	public static final String ADD_ACCOUNT_TYPE = 'Additions to Territory';
	public static final Integer DAYS_NUMBER = 30;
	public static final Integer NOTIFICATION_LIMIT = 900;

	public String iconBase64 { get; private set; }

	public GNE_SFA2_Notification_Ctrl(){
		iconBase64	= '/img/icon/custom51_100/pencil32.png';
	}

	public List<Notification> getNotifications(){
		List<String> territories = new List<String>();
		for(Territory2 territory : GNE_SFA2_HCP_Helper.getUserTopTerritories(UserInfo.getUserId())){
			territories.add(territory.Name);
		}
		List<Notification>notifications = new List<Notification>();
		Set<Id>uniqeIds = new Set<Id>();
		for(Notification notification : getNotifications(UserInfo.getUserId(), territories, null)){
			if(uniqeIds.add(notification.Id)){
				notifications.add(notification);
			}
		}
		return notifications;
	}

	/*Return notification for user. If territories == null than result all notifications from all users territories, otherwise return notification for territories specified in method argument.
	If lastSyncDate == null than return notification from last 30 days, otherwise return notifications newest than lastSyncDate.*/
	public static List<Notification>getNotifications(Id userId, List<String>territories, DateTime lastSyncDate){
		String changeType = GNE_SFA2_Util.isFrmUser() ? CHANGE_HCO_TYPE : CHANGE_HCP_TYPE;
		if(lastSyncDate == null){
			lastSyncDate = getDateNDaysBefore(DAYS_NUMBER);
		}
		Map<String, Schema.SObjectField> fSchema = Schema.SObjectType.Account.fields.getMap();

		Map<Id, List<String>>accountsToTerritories;
		if(GNE_SFA2_Util.isFrmUser()){
			accountsToTerritories = getFRMAccounts(userId, territories);
		}else {
			accountsToTerritories = GNE_SFA2_HCP_Helper.getUserPersonAccounts(userId, territories);
		}
		List<Notification>result = new List<Notification>();

		for(Notification_gne__c notification: [SELECT id, Change_Type_gne__c, Changed_Field_gne__c, CreatedById, CreatedDate,  New_Value_gne__c, Old_value_gne__c, Record_Name_gne__c, Record_Id_gne__c, Territory_gne__c, Description_gne__c, Account_Record_Type_Name_gne__c  FROM Notification_gne__c WHERE
											 (Record_Id_gne__c IN :accountsToTerritories.keySet() OR Territory_gne__c IN :territories) AND CreatedById != :UserInfo.getUserId() AND CreatedDate > :lastSyncDate ORDER BY CreatedDate desc limit :NOTIFICATION_LIMIT]){
			if(notification.Territory_gne__c != null){
				if(GNE_SFA2_Util.isFrmUser()) {
					if(notification.Account_Record_Type_Name_gne__c == GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO) {
						result.add(new Notification(notification, accountsToTerritories.containsKey(notification.Record_Id_gne__c)));
					}
				}else if(notification.Account_Record_Type_Name_gne__c == GNE_SFA2_Account_Trigger_Helper.REC_TYPE_HCP || String.isEmpty(notification.Account_Record_Type_Name_gne__c)) {
					result.add(new Notification(notification, accountsToTerritories.containsKey(notification.Record_Id_gne__c)));
				}
			}else{
				if(accountsToTerritories.containsKey(notification.Record_Id_gne__c)){
					for(String terrId: accountsToTerritories.get(notification.Record_Id_gne__c)){
						Boolean showLink = accountsToTerritories.containsKey(notification.Record_Id_gne__c);
						result.add(new Notification(notification.Id, notification.Record_Name_gne__c, notification.Change_Type_gne__c, notification.Changed_Field_gne__c, notification.CreatedDate, notification.New_Value_gne__c , notification.Old_Value_gne__c, terrId, notification.Description_gne__c, notification.Account_Record_Type_Name_gne__c, notification.Record_Id_gne__c, showLink));
					}
				}
			}
		}
		return result;
	}

	private static Datetime getDateNDaysBefore(Integer nDays){
		Datetime dt = Datetime.now();
		dt = dt.addDays((-1)*nDays);
		return Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0, 0, 0);
	}

	public String getActiveMenuItem() {
		String result = 'Notifications';
		return result;
	}

	public class Notification{
		public String id {get; set;}
		public String name {get; set;}
		public String changeType {get; set;}
		public String changeField {get; set;}
		public Datetime createdDate {get; set;}
		public String newValue {get; set;}
		public String oldValue {get; set;}
		public String description {get; set;}
		public String territory {get; set;}
		public String accountRecType {get; set;}
		public String accountId {get; set;}
		public Boolean showLink {get; set;}

		public Notification(String id, String name, String changeType, String changeField, Datetime createdDate, String newValue, String oldValue, String territory, String description, String accountRecType, String accountId, Boolean showLink){
			this.id = id;
			this.name = name;
			this.changeType = changeType;
			this.changeField = changeField;
			this.createdDate = createdDate;
			this.newValue = truncateString(newValue, 100);
			this.oldValue = truncateString(oldValue, 100);
			this.territory = territory;
			if(changeType == CHANGE_HCP_TYPE || changeType == CHANGE_HCO_TYPE) {
				this.description = changeField + '<br/>' + 'Old value: ' + this.oldValue + '<br/>New value: ' + this.newValue;
			}else if(description != null) {
				this.description = description;
			}else{
				this.description = '';
			}
			this.accountRecType = accountRecType;
			this.accountId = accountId;
			this.showLink = showLink;
		}

		public Notification(Notification_gne__c notification, Boolean showLink) {
			this(notification.Id, notification.Record_Name_gne__c, notification.Change_Type_gne__c, notification.Changed_Field_gne__c, notification.CreatedDate, notification.New_Value_gne__c , notification.Old_Value_gne__c, notification.Territory_gne__c, notification.description_gne__c, notification.Account_Record_Type_Name_gne__c, notification.Record_Id_gne__c, showLink);
		}

		private String truncateString(String text, Integer maxLength){
			String result;
			if(text==null){
				result = '';
			}else if(text.length() < maxLength){
				result = text;
			}else{
				result = text.substring(0, maxLength-3)+'...';
			}
			return result;
		}
	}

	/*Return map: accountId -> list of user territories with this this account (only top territories, records from child territoies not included). Only FRM_HCO accounts are returned.*/
	public static Map<Id, List<String>> getFRMAccounts(String userId, List<String>territories){
		Map<Id, List<String>>result = new Map<Id, List<String>>();
		for(TSF_vod__c tsf : [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.RecordTypeId = :GNE_SFA2_Util.getFrmHcoAccountRecordTypeId()]){
			if(!result.containsKey(tsf.Account_vod__c)){
				result.put(tsf.Account_vod__c, new List<String>());
			}
			result.get(tsf.Account_vod__c).add(tsf.Territory_vod__c);
		 }
		 return result;
	}
}