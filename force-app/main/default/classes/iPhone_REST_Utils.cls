public with sharing class iPhone_REST_Utils {
	
	public class ExceptionInfo {
		public String stackTrace;
		public String typeName;
		public String cause; 
		public Integer lineNumber;
		public String message;
		 
		public ExceptionInfo(Exception ex) {
			Exception cEx = ex.getCause();
			
			stackTrace	= ex.getStackTraceString();
			typeName	= ex.getTypeName();
			cause		= cEx!=null ? cEx.getMessage() : '';
			lineNumber	= ex.getLineNumber();
			message		= ex.getMessage();
		}
	}
	
	public static final String DEFAULT_DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss.S';
	public static final String DEFAULT_DATE_FORMAT = 'yyyy-MM-dd';
	
	public static final DateTime ZERO_DATE = DateTime.newInstance(0);	
	
	private static Boolean isDeltaMode = false;
	private static DateTime lastSyncDate;
	
	public static Boolean IsDeltaMode() {
		return isDeltaMode;
	}
	
	public static DateTime getLastSyncDate() {
		return lastSyncDate;
	}
	
	public static void SetDeltaMode(DateTime lastSyncDateValue ) {
		isDeltaMode = (lastSyncDate = lastSyncDateValue)!=null;
	}
	
	public static String formatDateTime(DateTime dateValue) {
		return formatDateTime(dateValue, DEFAULT_DATETIME_FORMAT);
	}
	
	public static String formatDateTime(DateTime dateValue, String dateTimeFormat) {
		return dateValue!=null ? dateValue.format(dateTimeFormat) : '';
	}
	
	public static String formatDate(DateTime dateValue) {
		return formatDateTime(dateValue, DEFAULT_DATE_FORMAT);
	}
	
	public static String formatDate(DateTime dateValue, String dateFormat) {
		return dateValue!=null ? dateValue.format(dateFormat) : '';
	}
	
	public static DateTime parseDateTime(String dateTimeString) {
		return (dateTimeString!=null && dateTimeString!='') ? DateTime.valueof(dateTimeString) : null;
	}
	
	public static Boolean getOnlyTargetedAccounts(){
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
		//base on custom settings check if current user profile fit pattern
		for (GNE_SFA2_OTR_My_Target_Profiles__c config : [SELECT name FROM GNE_SFA2_OTR_My_Target_Profiles__c]){
			if (profileName.toUpperCase().startsWith(config.Name.toUpperCase())){
				return true;
			}		
		}
		return false;
	}
	
	public static Boolean getOnlyHCOSAccounts(){
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
		//base on custom settings check if current user profile fit pattern
		for (String configProfileName : GNE_SFA2_OTR_HCOS_Only_Profiles__c.getAll().keyset()){
			if (profileName.startsWithIgnoreCase(configProfileName)){
				return true;
			}		
		}
		return false;
	}

	public static Boolean isAMSAccount(Account acc) {
		Boolean result = null;

		if (acc != null) {
			result = !acc.IsPersonAccount && (acc.stewardship_system_name_gne__c != null) && acc.stewardship_system_name_gne__c.equalsIgnoreCase('ams'); 
		}

		return result;
	}
}