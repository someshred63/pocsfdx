public with sharing class EDM_Classification_ViewFormItem_Ctrl {

	static public Boolean isBusinessClassifcationPending {get; private set;}
	static public Boolean isClinicalClassifcationPending {get; private set;}
	public String newClinicalRequestUrl {get; private set;}
	public String newBusinessRequestUrl {get; private set;}
	public Id accountId {get; private set;}
	public sObject parentObj {get; set;}
	static public Date clinicalClassDate{get;set;}
	static public Date businessClassDate{get;set;}
	private static Boolean initialized = false;

	public EDM_Classification_ViewFormItem_Ctrl() {
		accountId = ApexPages.currentPage().getParameters().get('id');
		PageReference pr = Page.EDM_Classification_Request_Edit_Create;
		pr.getParameters().put('accountId', accountId);
		pr.getParameters().put('retUrl', '/' + accountId);
		pr.getParameters().put('typeOfClassification', 'Business');
		newBusinessRequestUrl = pr.getUrl();
		pr.getParameters().put('typeOfClassification', 'Clinical');
		newClinicalRequestUrl = pr.getUrl();
		//check if pending
		if (!initialized) {
			initialized = true;

            Map<String, EDM_Classification_Request_gne__c> classificationRequestsByType = EDM_Classification_Utils.getPendingClassificationRequestsByTypes(accountId);

            isBusinessClassifcationPending = classificationRequestsByType.containsKey('Business');
            isClinicalClassifcationPending = classificationRequestsByType.containsKey('Clinical');
            if (isClinicalClassifcationPending){
				clinicalClassDate = classificationRequestsByType.get('Clinical').CreatedDate.Date();
			}
			if (isBusinessClassifcationPending){
				businessClassDate = classificationRequestsByType.get('Business').CreatedDate.Date();
			}
		}		
	}

	public class ClassificationHistory {
		String classification { get; set; }
		String businessRole { get; set; }
		String clDate { get; set; }
		String clTime { get; set; }
		String cvLink { get; set; }
	}

	public class ClassifHistoryResult {
		Boolean showCV { get; set; }
		@testVisible
		Map<String, List<ClassificationHistory>> historyItems { get; set; }
	}

	@RemoteAction
	public static ClassifHistoryResult getClassificationHistory(String accountId) {
		List<EDM_Classification_Request_gne__c> classifications = [
												SELECT EDM_Account_gne__c, EDM_Status_gne__c, EDM_Type_of_Classification_gne__c, LastModifiedDate, EDM_Reviewed_Date_Formula_gne__c,
														EDM_Business_Classification_gne__c, EDM_Business_Classification_Date_gne__c, 
														EDM_Clinical_Classification_gne__c, EDM_Clinical_Classification_Date_gne__c, 
														EDM_CV_Attachment_Link_gne__c, EDM_Action_Taken_gne__c, EDM_Business_Role_gne__c
												FROM EDM_Classification_Request_gne__c 
												WHERE EDM_Account_gne__c = :accountId 
													AND EDM_Status_gne__c = 'Completed'
													AND EDM_Action_Taken_gne__c != 'Decline to Classify'
												ORDER BY EDM_Reviewed_Date_Formula_gne__c desc];
		
		ClassifHistoryResult result = new ClassifHistoryResult();
		result.showCV = GNE_SFA2_Util.getCurrentUserProfileName().toLowerCase() == 'gne-tls-ab-sb-admin' || EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
		result.historyItems = getClassificationHistoryMap(classifications);
		return result;
	}

	private static Map<String, List<ClassificationHistory>> getClassificationHistoryMap(List<EDM_Classification_Request_gne__c> classifications) {
		Map<String, List<ClassificationHistory>> result = new Map<String, List<ClassificationHistory>>();
		result.put('Business', new List<ClassificationHistory>());
		result.put('Clinical', new List<ClassificationHistory>());
		
		for (EDM_Classification_Request_gne__c item : classifications) {
			String type = item.EDM_Type_of_Classification_gne__c;

			ClassificationHistory historyItem = new ClassificationHistory();			
			historyItem.clDate = getFormattedDateOrTime(item.EDM_Reviewed_Date_Formula_gne__c,true);
			historyItem.clTime = getFormattedDateOrTime(item.EDM_Reviewed_Date_Formula_gne__c,false);
			historyItem.cvLink = item.EDM_CV_Attachment_Link_gne__c;
			historyItem.classification = item.EDM_Action_Taken_gne__c;
			if (type == 'Business') {
				historyItem.businessRole = item.EDM_Business_Role_gne__c;
			}

			if (result.containsKey(type)) {
				result.get(type).add(historyItem);
			}			
		}
		return result;
	}

	private static String getFormattedTime(Datetime toFormat) {
		String formatedDT = toFormat.format('MM/dd/yyyy hh:mm:ss a');
		List<String> dateTimeParts = formatedDT.split(' ');
		if (dateTimeParts.size() == 3) {
			return dateTimeParts[1] + ' ' + dateTimeParts[2];
		}
		return String.valueOf(toFormat.time());
	}

	private static String getFormattedDateOrTime(DateTime toFormat,Boolean isDate){
		String formatedDate = String.valueOfGmt(toFormat);
		List<String> dateParts = formatedDate.split(' ');
		if(isDate) {
			return dateParts[0];
		}
		return dateParts[1];		
	}
}