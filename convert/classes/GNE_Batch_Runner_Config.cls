public without sharing class GNE_Batch_Runner_Config {
	
	private enum ConfigItem {ACTIVE_BATCHES_MAX_SIZE, EMAIL, ORG_WIDE_EMAIL_ADDRESS, CRON}
	
	private static Integer activeBatchesMaxSize;
	private static Id orgWideEmailAddressId;
	private static Map<String,List<String>> emailConfig;
	private static Map<String,List<String>> scheduleConfig;
	private static final Integer ACTIVE_BATCHES_MAX_SIZE_DEFAULT = 10;
	private static final String DEFAULT_EMAIL_GROUP  = 'DEFAULT';
	
	static {
		init();
	}
	
	private static void init() {
		emailConfig = new Map<String,List<String>>();
		scheduleConfig = new Map<String,List<String>>();
		
		List<GNE_Batch_Runner_Config_Items_gne__c> allItems = GNE_Batch_Runner_Config_Items_gne__c.getAll().values();
		Map<String, GNE_Batch_Runner_Config_Items_gne__c> configItemsMap = new Map<String, GNE_Batch_Runner_Config_Items_gne__c>();
		
		for(GNE_Batch_Runner_Config_Items_gne__c item : allItems) {
			configItemsMap.put(item.Key_gne__c, item);
		}
		
		String itemName = ConfigItem.ACTIVE_BATCHES_MAX_SIZE.name();
		String itemValue = configItemsMap.containsKey(itemName) ? configItemsMap.get(itemName).Value_gne__c : null; 
		if(String.isNotBlank(itemValue)) {
			activeBatchesMaxSize = Integer.valueOf(itemValue);
		} else {
			activeBatchesMaxSize = ACTIVE_BATCHES_MAX_SIZE_DEFAULT;
		}
		
		itemName = ConfigItem.ORG_WIDE_EMAIL_ADDRESS.name();
        itemValue = configItemsMap.containsKey(itemName) ? configItemsMap.get(itemName).Value_gne__c : null; 
        if(String.isNotBlank(itemValue)) {
            for(OrgWideEmailAddress owea : [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName= :itemValue LIMIT 1]) {
                orgWideEmailAddressId = owea.Id;
            }
        }
		
		String emailPrefix = ConfigItem.EMAIL.name() + ':';
		String schedulePrefix = ConfigItem.CRON.name() + ':';
		
		for(GNE_Batch_Runner_Config_Items_gne__c item : allItems) {
			String settingName = item.Key_gne__c;
			
			if(settingName.startsWithIgnoreCase(emailPrefix)) {
				String emailValue = item.Value_gne__c;
				String batchName = settingName.substringAfter(emailPrefix);
				
				if(String.isNotBlank(emailValue) && String.isNotBlank(batchName)) {
					batchName = batchName.toUpperCase();
					
					if(!emailConfig.containsKey(batchName)) {
						emailConfig.put(batchName, new List<String>());
					}
					
					emailConfig.get(batchName).addAll(emailValue.split(';'));
				}
			}
			else if(settingName.startsWithIgnoreCase(schedulePrefix)){
				String scheduleValue = item.Value_gne__c;
				String batchName = settingName.substringAfter(schedulePrefix);

				if(String.isNotBlank(scheduleValue) && String.isNotBlank(batchName)) {
					batchName = batchName.toUpperCase();

					if(!scheduleConfig.containsKey(batchName)) {
						scheduleConfig.put(batchName, new List<String>());
					}

					scheduleConfig.get(batchName).add(scheduleValue);
				}
			}
		}
	}
	
	public static Integer getActiveBatchesMaxSize() {
		return activeBatchesMaxSize;
	}
	
	public static Id getOrgWideEmailAddressId() {
        return orgWideEmailAddressId;
    }
	
	public static List<String> getEmailsFromStackTrace() {
		StackTraceException ex = new StackTraceException();
		String stackTraceText = ex.getStackTraceString();
		System.debug('stackTraceText = ' + stackTraceText);
		
		Pattern classNamePattern = Pattern.compile('Class\\.(\\w+)\\W');
		Matcher classNameMatcher = classNamePattern.matcher(stackTraceText);
		List<String> emails = new List<String>();

		while(classNameMatcher.find()) {
			String className = classNameMatcher.group(1);
			emails.addAll(getEmailsForBatch(className));
		}
		
		return !emails.isEmpty() ? emails : getDefaultEmails();
	}
	
	public static List<String> getEmailsForBatchWithDefault(String batchName) {
		List<String> emails = getEmailsForBatch(batchName);
		return !emails.isEmpty() ? emails : getDefaultEmails();
	}
	
	public static List<String> getEmailsForBatch(String batchName) {
		String key = batchName.toUpperCase();
		return emailConfig.containsKey(key) ? emailConfig.get(key) : new List<String>(); 
	}
	
	public static List<String> getDefaultEmails() {
		return getEmailsForBatch(DEFAULT_EMAIL_GROUP); 
	}

	public static List<String> getScheduleForBatch(String scheduleName) {
		String key = scheduleName.toUpperCase();
		return scheduleConfig.containsKey(key) ? scheduleConfig.get(key) : new List<String>();
	}

	private class StackTraceException extends Exception {}
}