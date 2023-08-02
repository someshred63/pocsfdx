public class SRW_Utils {
	
	public static SRW_Settings__c getSRWCustomSettingByName(String name) {
		Map<String,SRW_Settings__c> settings = SRW_Settings__c.getAll();
		if(settings.containsKey(name))
			return settings.get(name);

		return null;
	}

	public static String getActiveSettingByName(String name) {
		SRW_Settings__c setting = getSRWCustomSettingByName(name);
		if(setting!=null && setting.IsActive_gne__c)
			return setting.Value_gne__c;
		return null;
	}

	public static String getSettingByName(String name) {
		SRW_Settings__c setting = getSRWCustomSettingByName(name);
		if(setting!=null)
			return setting.Value_gne__c;
		return null;
	}

	public static List<SRW_Settings__c> getSRWCustomSettingByPrefix(String prefix) {
		Map<String,SRW_Settings__c> settings = SRW_Settings__c.getAll();
		List<SRW_Settings__c> settingsToReturn = new List<SRW_Settings__c>();
		for(String settingName : settings.keySet()) {
			if(settingName.startsWith(prefix))
				settingsToReturn.add(settings.get(settingName));
		}
		return settingsToReturn;
	}

	public static List<String> getActiveSettingsByPrefix(String prefix) {
		List<SRW_Settings__c> settings = getSRWCustomSettingByPrefix(prefix);
		List<String> settingsToReturn = new List<String>();
		for(SRW_Settings__c setting : settings) {
			if(setting.IsActive_gne__c)
				settingsToReturn.add(setting.Value_gne__c);
		}	
		return settingsToReturn;
	}
}