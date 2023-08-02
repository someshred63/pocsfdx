public without sharing class CFAR_ConfigUtil {

	public static void setDisabled(String fieldName, List<String> itemsToDisable) {
		CFAR_Setting_gne__c setting = CFAR_Setting_gne__c.getInstance(UserInfo.getProfileId());
		String fieldValue = '';
		for (String item : itemsToDisable) {
			fieldValue += item + '\n';
		}
		setting.put(fieldName, fieldValue);
		upsert setting;
	}

	public static Boolean isEnabled(final String fieldName, List<String> itemNames) {
		CFAR_Setting_gne__c settingInstance = CFAR_Setting_gne__c.getInstance(UserInfo.getProfileId());
		String fieldValue = String.valueOf(settingInstance.get(fieldName));
		if (fieldValue == null) {
			return true;
		}
		if (fieldValue == '*') {
			return false;
		}
		for (String itemName : itemNames) {
			if (fieldValue.containsIgnoreCase(itemName)) {
				return false;
			}
		}
		return true;
	}

	public static Boolean isTriggerEnabled(List<String> triggerNames){
		return isEnabled('Disabled_Triggers_gne__c', triggerNames);
	}
}