public class GNE_SFA2_PREP_Config {
	private enum ConfigItem {TestTypes, RootTerritoryNumber}
	
	public static Map<String, String> TestTypeToApiNameMap = new Map<String, String>();
	//public static Map<String, GNE_SFA2_PREP_Config_Items_gne__c> configItemsMap;
	public static String RootTerritoryNumber;
	
	static {
		//configItemsMap = GNE_SFA2_PREP_Config_Items_gne__c.getAll();
		
		/*String itemValue = getItemValue(ConfigItem.TestTypes.name()); 
		if(String.isNotBlank(itemValue)) {
			TestTypeToApiNameMap = (Map<String, String>)JSON.deserialize(itemValue, Map<String, String>.class);
		} else {
			TestTypeToApiNameMap = new Map<String, String>();
		}*/
		
		for(String testTypeName : TestTypeToApiNameMap.keySet()) {
			TestTypeToApiNameMap.put(testTypeName.toLowerCase(), TestTypeToApiNameMap.get(testTypeName));
		}
		/*
		itemValue = getItemValue(ConfigItem.RootTerritoryNumber.name()); 
		if(String.isNotBlank(itemValue)) {
			RootTerritoryNumber = itemValue;
		}*/
	}
	
	/*private static String getItemValue(String itemName) {
		return getItemValue(itemName, null);
	}
	
	private static String getItemValue(String itemName, String defaultValue) {
		String itemValue = configItemsMap.containsKey(itemName) ? configItemsMap.get(itemName).Value_gne__c : null; 
		
		if(String.isBlank(itemValue)) {
			itemValue = defaultValue;
		}
		
		return itemValue;
	}*/
	
	public static String getTestTypeApiName(String testType){
		return TestTypeToApiNameMap.get(testType==null ? null : testType.toLowerCase());
	}
	
	public static String getRootTerritoryNumber() {
		return RootTerritoryNumber;
	}
}