public class GNE_SFA2_PREP_Testing_Objectives_Ctrl extends GNE_SFA2_PREP_Base_Ctrl {
	public Id accId {get; private set;}
	public String changeStatusErrorMessage {get; private set;}
	public String changeStatusQuestion {get; private set;}
	public String sendEmailNotificationQuestion {get; private set;}
	
	private transient List<TestingStrategyWrapper> tStrategies;
	private transient String accStatus;
	private transient List<String> columnHeaders = new List<String>{'Strategy', 'Status'};
	private transient Map<String,String> statusDescriptions = GNE_SFA2_PREP_Util.StatusDescriptions;
	private transient List<String> availableStatuses = new List<String>{
			GNE_SFA2_PREP_Util.PREP_STATUS_RED,
			GNE_SFA2_PREP_Util.PREP_STATUS_YELLOW,
			GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN,
			GNE_SFA2_PREP_Util.PREP_STATUS_DARK_GREEN,
			GNE_SFA2_PREP_Util.PREP_STATUS_GRAY
	};
	
	private transient Boolean sendEmailNotificationMode;
	private transient EmailData emailData;
	private transient User manager;
	private transient Account acc;
	private transient Boolean isHco;
	private transient Boolean canEdit;
	
	public GNE_SFA2_PREP_Testing_Objectives_Ctrl() {
		this((Id)ApexPages.currentPage().getParameters().get('id'));
	}
	
	public GNE_SFA2_PREP_Testing_Objectives_Ctrl(Id a_accId) {
		super();
		accId = a_accId;
		sendEmailNotificationMode = false;
		manager = GNE_SFA2_PREP_DAO.getUser(UserInfo.getUserId()).Manager;
		UserRecordAccess ura = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), accId);
		canEdit = ura.HasEditAccess;
		changeStatusErrorMessage = String.format(System.Label.GNE_SFA2_PREP_STATUS_CHANGE_ERROR, new String[]{GNE_SFA2_PREP_Util.PREP_STATUS_DARK_GREEN});
		changeStatusQuestion = String.format(System.Label.GNE_SFA2_PREP_STATUS_CHANGE_QUESTION, new String[]{GNE_SFA2_PREP_Util.PREP_STATUS_GREEN, '[MBO#]'}).replaceAll('\\\\n', '<br/>');
		
		buildTestingStrategyList();
		
		if(manager!=null) {
			String accName = acc.Name;
			String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
			sendEmailNotificationQuestion = String.format(System.Label.GNE_SFA2_PREP_MANAGER_NOTIFICATION_QUESTION, new String[]{GNE_SFA2_PREP_Util.PREP_STATUS_GREEN, manager.Name}).replaceAll('\\\\n', '<br/>');
			emailData = new EmailData(
				manager!=null ? new String[]{formatEmail(manager)} : new String[]{},
				new String[]{},
				String.format(System.Label.GNE_SFA2_PREP_MANAGER_NOTIFICATION_SUBJECT, new String[]{accName, GNE_SFA2_PREP_Util.PREP_STATUS_GREEN}),
				String.format(System.Label.GNE_SFA2_PREP_MANAGER_NOTIFICATION_BODY, new String[]{accID, accName, baseUrl, GNE_SFA2_PREP_Util.PREP_STATUS_GREEN})
			);
		}
	}
	
	private void buildTestingStrategyList() {
		tStrategies = new List<TestingStrategyWrapper>();
		
		Map<String,SFA2_PREP_Account_Testing_Strategy_gne__c> aStrategiesMap = new Map<String,SFA2_PREP_Account_Testing_Strategy_gne__c>();
		Map<String,SFA2_PREP_Account_MBO_gne__c> aMBOsMap = new Map<String,SFA2_PREP_Account_MBO_gne__c>();
		
		for(SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy : GNE_SFA2_PREP_Util.getActiveForAccountStrategies(new Set<Id>{accId})) {
			aStrategiesMap.put(GNE_SFA2_PREP_Util.getRecordKey(aStrategy), aStrategy);
			
			for(SFA2_PREP_Account_MBO_gne__c aMBO : aStrategy.Account_MBOs_gne__r) {
				aMBOsMap.put(GNE_SFA2_PREP_Util.getRecordKey(aMBO), aMBO);
			}
		}
		
		for(SFA2_PREP_Testing_Strategy_gne__c tStrategy : GNE_SFA2_PREP_Util.getActiveForAccountTestingStrategiesWithMBOs()) {
			String aStrategyKey = GNE_SFA2_PREP_Util.getRecordKey(tStrategy) + '_' + accId;
			SFA2_PREP_Account_Testing_Strategy_gne__c aStrategy = aStrategiesMap.get(aStrategyKey);
			List<TestingMboWrapper> mboWrappers = new List<TestingMboWrapper>();
			
			if(aStrategy==null) {
				aStrategy = new SFA2_PREP_Account_Testing_Strategy_gne__c(
					Testing_Strategy_gne__c = tStrategy.Id,
					Testing_Strategy_gne__r = tStrategy, 
					Account_gne__c = accId,
					Status_gne__c = GNE_SFA2_PREP_Util.PREP_STATUS_RED
				);
			}
			
			Set<String> mboStatuses = new Set<String>();
			
			for(SFA2_PREP_MBO_gne__c mbo : tStrategy.MBOs_gne__r) {				
				String aMboKey = GNE_SFA2_PREP_Util.getRecordKey(mbo) + '_' + accId;						
				SFA2_PREP_Account_MBO_gne__c aMBO = aMBOsMap.get(aMboKey);					
				if(aMBO==null) {
					aMBO = new SFA2_PREP_Account_MBO_gne__c(
						MBO_gne__c = mbo.Id, MBO_gne__r = mbo, 
						Account_Testing_Strategy_gne__c = aStrategy.Id, Account_Testing_Strategy_gne__r = aStrategy, 
						Status_gne__c = (String.isNotBlank(mbo.Default_Status_gne__c) ? mbo.Default_Status_gne__c : GNE_SFA2_PREP_Util.PREP_STATUS_RED)
					);
				}
				mboStatuses.add(aMBO.Status_gne__c);
				TestingMboWrapper mboWrapper = new TestingMboWrapper(aMBO);
				mboWrappers.add(mboWrapper);
			}
			
			if(aStrategy.Id==null && mboStatuses.size()==1 && mboStatuses.contains(GNE_SFA2_PREP_Util.PREP_STATUS_GRAY)) {
				aStrategy.Status_gne__c = GNE_SFA2_PREP_Util.PREP_STATUS_GRAY;
			}
			
			mboWrappers.sort();
			tStrategies.add(new TestingStrategyWrapper(aStrategy, mboWrappers));
		}
		
		for(Account accRec : GNE_SFA2_PREP_Util.getAccountsWithStatus(new Set<Id>{accId})) {
			acc = accRec;
			String oldAccStatus = accStatus; 
			accStatus = acc.PREP_Status_gne__c;
			isHco = !acc.IsPersonAccount;
			sendEmailNotificationMode = 
					   manager!=null && !acc.IsPersonAccount
					&& oldAccStatus!=accStatus
					&& accStatus==GNE_SFA2_PREP_Util.PREP_STATUS_GREEN;
		}
	}
	
	private void save() {
		Boolean isOk = false;
		System.SavePoint sp = Database.setSavepoint();
		
		try {
			intSave();
			isOk = true;
		} finally {
			if(!isOK) {
				Database.rollback(sp);
			}
		}
	}

	private void intSave() {
		List<SFA2_PREP_Account_Testing_Strategy_gne__c> strategiesToUpsert = new List<SFA2_PREP_Account_Testing_Strategy_gne__c>();
		List<SFA2_PREP_Account_MBO_gne__c> mbosToUpsert = new List<SFA2_PREP_Account_MBO_gne__c>();
		
		for(TestingStrategyWrapper tsWrapper : tStrategies) {
			if(tsWrapper.isChanged()) {
				tsWrapper.updateStatus();
				strategiesToUpsert.add(tsWrapper.record);
			}			
		}
		
		if(!strategiesToUpsert.isEmpty()) {
			upsert strategiesToUpsert;
		}

		for(TestingStrategyWrapper tsWrapper : tStrategies) {
			for(TestingMboWrapper mboWrapper : tsWrapper.mbos) {
				if(mboWrapper.isChanged()) {
					mboWrapper.updateStatus();
					
					if(mboWrapper.isNew) {
						mboWrapper.record.Account_Testing_Strategy_gne__c = tsWrapper.record.Id;
					}
					
					mbosToUpsert.add(mboWrapper.record);
				}
			}
		}
		
		if(!mbosToUpsert.isEmpty()) {
			upsert mbosToUpsert;
		}
	}
	
	private void sendEmail() {
		for(Messaging.SendemailResult sendResult : GNE_SFA2_PREP_Util.sendEmailNotification(emailData.to, emailData.cc, emailData.subject, emailData.body)) {
			if(sendResult.isSuccess()) {
				infoMessages.add(System.Label.GNE_SFA2_PREP_MANAGER_NOTIFICATION_SEND);
			} else {
				for(Messaging.SendEmailError err : sendResult.getErrors()) {
					errorMessages.add(String.format(System.Label.GNE_SFA2_PREP_MANAGER_NOTIFICATION_ERROR, new String[]{err.getMessage()}));
				}
			}
		}
	}
	
	@RemoteAction @ReadOnly
	public static ControllerData getInitData(String accId) {
  		ControllerData result = new ControllerData(accId);
	
	  	try {
	  		result.copyFrom(result.ctrl);
	  	} catch(Exception ex) {
	  		result.retURL = getErrorPageUrl('getInitData', ex);
	  	}
	  	
	  	result.onActionFinish('getInitData');
	  	return result;
	}
	
	@RemoteAction @ReadOnly
	public static List<String> getAvailableEmailContacts(String accId) {
		List<String> emailContacts = new List<String>();
		
		for(User prepUser : GNE_SFA2_PREP_DAO.getPrepUsers()) {
			emailContacts.add(formatEmail(prepUser));
			
			if(prepUser.Manager!=null) {
				emailContacts.add(formatEmail(prepUser.Manager));
			}
		}
		
		return emailContacts;
	}
	
	@RemoteAction
	public static ControllerData updateStatus(String accId, String ctrlDataInJSON) {
		ControllerData result = new ControllerData(accId);
		try {
			((ControllerData)JSON.deserialize(ctrlDataInJSON, ControllerData.class)).copyTo(result.ctrl);
			((GNE_SFA2_PREP_Testing_Objectives_Ctrl)result.ctrl).save();
			((GNE_SFA2_PREP_Testing_Objectives_Ctrl)result.ctrl).buildTestingStrategyList();
			result.copyFrom(result.ctrl);
	  	} catch(Exception ex) {
	  		result.retURL = getErrorPageUrl('updateStatus', ex);
	  	}
	  	
	  	result.onActionFinish('updateStatus');
	  	return result;
	}
	
	@RemoteAction
	public static ControllerData sendEmail(String accId, String ctrlDataInJSON) {
		ControllerData result = new ControllerData(accId);
		try {
			((ControllerData)JSON.deserialize(ctrlDataInJSON, ControllerData.class)).copyTo(result.ctrl);
			((GNE_SFA2_PREP_Testing_Objectives_Ctrl)result.ctrl).sendEmail();
			result.copyFrom(result.ctrl);
	  	} catch(Exception ex) {
	  		result.retURL = getErrorPageUrl('sendEmail', ex);
	  	}
	  	
	  	result.onActionFinish('sendEmail');
	  	return result;
	}
	
	
	private static String formatEmail(User u) {
		return String.format('{0} <{1}>', new String[]{u.Name, u.Email});
	}
	
	private static String getErrorPageUrl(String actionName, Exception ex) {
  		return GNE_SFA2_PREP_Base_Ctrl.setErrorPageReference(
  				actionName, ex, Page.GNE_SFA2_PREP_Testing_Objectives).getUrl();
  	}
	
	public class ControllerData extends GNE_SFA2_PREP_Base_Ctrl.ControllerData {
		@TestVisible private String accId;
		@TestVisible private List<TestingStrategyWrapper> tStrategies;
		@TestVisible private List<String> columnHeaders;
		@TestVisible private Map<String,String> statusDescriptions;
		@TestVisible private List<String> availableStatuses;
		@TestVisible private String accStatus;
		@TestVisible private Boolean sendEmailNotificationMode;
		@TestVisible private EmailData emailData;
		@TestVisible private Boolean canEdit;
		@TestVisible private Boolean isHco;
		
		public ControllerData(String a_accId) {
			super();
			ctrl = new GNE_SFA2_PREP_Testing_Objectives_Ctrl(a_accId);
		}
		
		protected override void copyFrom(GNE_SFA2_PREP_Base_Ctrl a_ctrl) {
			super.copyFrom(a_ctrl);
			accId = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).accId;
			accStatus = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).accStatus;
			tStrategies = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).tStrategies;
			columnHeaders = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).columnHeaders;
			statusDescriptions = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).statusDescriptions;
			availableStatuses = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).availableStatuses;
			sendEmailNotificationMode = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).sendEmailNotificationMode;
			emailData = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).emailData;
			canEdit = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).canEdit;
			isHco = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).isHco;
		}
		
		protected override void copyTo(GNE_SFA2_PREP_Base_Ctrl a_ctrl) {
			super.copyTo(a_ctrl);
			((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).accStatus = accStatus;
			((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).emailData = emailData;
			
			Integer tsIdx = 0;
			for(TestingStrategyWrapper tsWrappper : tStrategies) {
				TestingStrategyWrapper tsWrapperCtrl = ((GNE_SFA2_PREP_Testing_Objectives_Ctrl)a_ctrl).tStrategies[tsIdx++];
				tsWrapperCtrl.status = tsWrappper.status;
				tsWrapperCtrl.statusDescription = tsWrappper.statusDescription;
				
				Integer mboIdx = 0;
				for(TestingMboWrapper mboWrapper : tsWrappper.mbos) {
					TestingMboWrapper mboWrapperCtrl = tsWrapperCtrl.mbos[mboIdx++];
					mboWrapperCtrl.status = mboWrapper.status;
					mboWrapperCtrl.statusDescription = mboWrapper.statusDescription;
				}
			}
		}
	}
	
	public class TestingStrategyWrapper extends GNE_SFA2_PREP_Util.TestingStrategyWrapper {
		@TestVisible public transient SFA2_PREP_Account_Testing_Strategy_gne__c record;
		@TestVisible private String key;
		@TestVisible private String name;
		@TestVisible private String status;
		@TestVisible private String statusDescription;
		@TestVisible private Boolean isNew;
		@TestVisible private List<TestingMboWrapper> mbos;
		
		public TestingStrategyWrapper(SFA2_PREP_Account_Testing_Strategy_gne__c a_record, List<TestingMboWrapper> a_mbos) {
			super(a_record.Testing_Strategy_gne__r, null);
			mbos = a_mbos;
			record = a_record;
			key = GNE_SFA2_PREP_Util.getRecordKey(record); 
			name = nm;
			status = a_record.Status_gne__c;
			statusDescription = GNE_SFA2_PREP_Util.StatusDescriptions.get(a_record.Status_gne__c);
			isNew = record.Id==null;
		}
		
		private Boolean isChanged() {
			return String.isBlank(record.Id);
		}
		
		public void updateStatus() {
			record.Status_gne__c = status;
		}
	}
	
	public class TestingMboWrapper extends GNE_SFA2_PREP_Util.TestingMboWrapper {
		@TestVisible public transient SFA2_PREP_Account_MBO_gne__c record;
		@TestVisible private String key;
		@TestVisible private String name;
		@TestVisible private Integer no;
		@TestVisible private String status;
		@TestVisible private String statusDescription;
		@TestVisible private Boolean isNew;
		
		public TestingMboWrapper(SFA2_PREP_Account_MBO_gne__c a_record) {
			super(a_record.MBO_gne__r);
			record = a_record;
			key = GNE_SFA2_PREP_Util.getRecordKey(record); 
			name = a_record.Mbo_gne__r.Name;
			String noFromName = name.replaceAll('[\\D\\s]','');
			no = String.isNotBlank(noFromName) ? Integer.valueOf(noFromName) : 0;
			status = a_record.Status_gne__c;
			statusDescription = GNE_SFA2_PREP_Util.StatusDescriptions.get(a_record.Status_gne__c);
			isNew = record.Id==null;
		}
		
		private Boolean isChanged() {
			return String.isBlank(record.Id) || record.Status_gne__c!=status;
		}
		
		public void updateStatus() {
			record.Status_gne__c = status;
		}
	}
	
	public class EmailData {
		public String[] to;
		public String[] cc;
		public String subject;
		public String body;
		
		public EmailData(String[] a_to, String[] a_cc, String a_subject, String a_body) {
			to = a_to;
			cc = a_cc;
			subject = a_subject;
			body = a_body;
		}
	}
}