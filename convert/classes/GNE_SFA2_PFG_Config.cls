public with sharing class GNE_SFA2_PFG_Config {
	private enum ConfigItem {ActiveBrandsForDTP, ActiveBrandsForHC, HoTerritoryName, DetailedReportsLink, StatusReportLink, ErrorNotificationEmail, InteractionQtyLimits, ActiveBrandsForHCPSpec}
	
	private static final String LIST_SEPARATOR = ';';
	private static final String EMAIL_SETTING_PREFIX = 'email:';
	private static final String HO_EMAIL_TAG = 'HomeOffice';
	public static final String SCHEDULE_JOB_PREFIX = 'Scheduler:Job';
	private static final Pattern INTARACTION_QTY_LIMITS_REGEXP_PATTERN = Pattern.compile('\\[([^:]+):([^:]+):([^\\]]*)\\]');
	
	public static final Set<String> ACTIVE_BRANDS_FOR_DTP;
	public static final Set<String> ACTIVE_BRANDS_FOR_HC;
	public static final Set<String> ACTIVE_BRANDS;
	public static final String HO_TERRITORY_NAME;
	public static final String HO_EMAIL;
	public static final Map<String,String> VENDOR_EMAIL_MAP;
	public static final String PFG_MAIN_PAGE = 'GNE_SFA2_PFG_MyPFG';
	public static final String DCR_MAIN_PAGE = 'GNE_SFA2_DCR';
	public static final String DETAILED_REPORTS_LINK;
	public static final String STATUS_REPORT_LINK;
	public static final List<String> ERROR_NOTIFICATION_EMAILS;
	public static final Map<String,String> SCHEDULE_JOBS_INFO;
	public static final Map<String,Map<String,Integer>> INTERACTION_QTY_LIMITS_PER_BRAND;
	public static final Set<String> ACTIVE_BRANDS_FOR_HCP_SPEC;
	
	public static Map<String, GNE_SFA2_PFG_Config_Items_gne__c> configItemsMap;
	
	static {
		configItemsMap = GNE_SFA2_PFG_Config_Items_gne__c.getAll();
		
		String itemValue = getItemValue(ConfigItem.ActiveBrandsForDTP.name()); 
		if(String.isNotBlank(itemValue)) {
			ACTIVE_BRANDS_FOR_DTP = new Set<String>(itemValue.split(LIST_SEPARATOR));
		} else {
			ACTIVE_BRANDS_FOR_DTP = new Set<String>();
		}
		
		itemValue = getItemValue(ConfigItem.ActiveBrandsForHC.name());
		if(String.isNotBlank(itemValue)) {
			ACTIVE_BRANDS_FOR_HC = new Set<String>(itemValue.split(LIST_SEPARATOR));
		} else {
			ACTIVE_BRANDS_FOR_HC = new Set<String>();
		}
		
		ACTIVE_BRANDS = ACTIVE_BRANDS_FOR_DTP.clone();
		ACTIVE_BRANDS.addAll(ACTIVE_BRANDS_FOR_HC);
		
		itemValue = getItemValue(ConfigItem.ActiveBrandsForHCPSpec.name());
		if (String.isNotBlank(itemValue)){
			ACTIVE_BRANDS_FOR_HCP_SPEC = new Set<String>(itemValue.split(LIST_SEPARATOR));
		} else {
			ACTIVE_BRANDS_FOR_HCP_SPEC = new Set<String>();
		}
		
		HO_TERRITORY_NAME = getItemValue(ConfigItem.HoTerritoryName.name(), 'HO Virtual Territory');
		DETAILED_REPORTS_LINK = getItemValue(ConfigItem.DetailedReportsLink.name());
		STATUS_REPORT_LINK = getItemValue(ConfigItem.StatusReportLink.name());
		
		itemValue = getItemValue(ConfigItem.ErrorNotificationEmail.name());
		if(String.isNotBlank(itemValue)) {
			ERROR_NOTIFICATION_EMAILS = itemValue.split(LIST_SEPARATOR);
		} else {
			ERROR_NOTIFICATION_EMAILS = new List<String>();
		}
		
		VENDOR_EMAIL_MAP = new Map<String,String>();
		SCHEDULE_JOBS_INFO = new Map<String,String>();
		INTERACTION_QTY_LIMITS_PER_BRAND = new Map<String,Map<String,Integer>>();
		String interactionQtyLimitItemName = ConfigItem.InteractionQtyLimits.name();
		
		for(String settingName : configItemsMap.keySet()) {
			Boolean isActive = configItemsMap.get(settingName).Is_Active_gne__c;
			String sValue = configItemsMap.get(settingName).Value_gne__c;
			String sArgs = configItemsMap.get(settingName).Arguments_gne__c;
			
			if(settingName.startsWithIgnoreCase(EMAIL_SETTING_PREFIX)) {
				String emailValue = sValue;
				String vendorName = settingName.substringAfter(EMAIL_SETTING_PREFIX);
				
				if(String.isNotBlank(emailValue) && String.isNotBlank(vendorName)) {
					VENDOR_EMAIL_MAP.put(vendorName, emailValue);
					
					if(vendorName == HO_EMAIL_TAG) {
						HO_EMAIL = emailValue;
					}
				}
			// Scheduler Settings
			} else if(settingName.startsWithIgnoreCase(SCHEDULE_JOB_PREFIX)) {
				SCHEDULE_JOBS_INFO.put(settingName, JSON.serialize(new Map<String,String>{'JOB_INFO' => sValue, 'JOB_ARGS' => sArgs, 'IS_ACTIVE' => String.valueOf(isActive)}));
			// Interaction Qty Limits Settings
			} else if(settingName.startsWithIgnoreCase(interactionQtyLimitItemName) && isActive) {
				String qtyLimitsValue = sValue;
				Matcher m = INTARACTION_QTY_LIMITS_REGEXP_PATTERN.matcher(qtyLimitsValue!=null ? qtyLimitsValue : '');
				
				while(m.find()) {
					String brandName = m.group(1);
					String distMethod = m.group(2);
					String qtyLimitText = m.group(3);
					
					if(!INTERACTION_QTY_LIMITS_PER_BRAND.containsKey(brandName)) {
						INTERACTION_QTY_LIMITS_PER_BRAND.put(brandName, new Map<String,Integer>());
					}
					
					INTERACTION_QTY_LIMITS_PER_BRAND.get(brandName).put(distMethod, (String.isNotBlank(qtyLimitText) ? Integer.valueOf(qtyLimitText) : null));
				}
			}
		}
	}
	
	private static String getItemValue(String itemName) {
		return getItemValue(itemName, null);
	}
	
	private static String getItemValue(String itemName, String defaultValue) {
		String itemValue = configItemsMap.containsKey(itemName) ? configItemsMap.get(itemName).Value_gne__c : null; 
		
		if(String.isBlank(itemValue)) {
			itemValue = defaultValue;
		}
		
		return itemValue;
	}
}