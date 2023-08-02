global with sharing class CFAR_TeamContactsReport_Helper {

	public static List<String> trialStatuses = new List<String>();

	public static List<String> getAvailableTrialStatuses(){
		for(CFAR_Trial_Status_gne__c status : [SELECT Name, id FROM CFAR_Trial_Status_gne__c]){
			if(String.valueOf(status.Name) != 'Admin Fix'){
				trialStatuses.add(String.valueOf(status.id));
			}
		}
	trialStatuses.add('');

	return trialStatuses;
	}

	public static String secureParam(String val) {
		if (String.isNotBlank(val)) {
			val = String.escapeSingleQuotes(val);
		}
		return val;
	}
}