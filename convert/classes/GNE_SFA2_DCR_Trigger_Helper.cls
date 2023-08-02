public without sharing class GNE_SFA2_DCR_Trigger_Helper {
	
	public static final String LICENSE_ISSUE_RECORD_TYPE_NAME = 'License/Sampleability Info';
	private static Map<String,Id> licIssueRecordTypeIdCache;
	private static Boolean inDcrTrig = false;
	private static Map<String, Id> queueNamesToIds;
	
	public static void setDcrTrig(Boolean p_inDcrTrig) {
        inDcrTrig = p_inDcrTrig;
    }
            
    public static Boolean inDcrTrig()  {
        return inDcrTrig;
    }
	
	public static Id getLicIssueRecordTypeId() {
		if(licIssueRecordTypeIdCache == null) {
			Schema.RecordTypeInfo rtInfo = Change_Request_gne__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(LICENSE_ISSUE_RECORD_TYPE_NAME);
			licIssueRecordTypeIdCache = new Map<String,Id>{LICENSE_ISSUE_RECORD_TYPE_NAME => (rtInfo!=null ? rtInfo.getRecordTypeId() : null)};
		}
		return licIssueRecordTypeIdCache.get(LICENSE_ISSUE_RECORD_TYPE_NAME);
	}
	
	public static Integer getMinutesToWait(){
		try{
			return (Integer.valueOf(System.Label.DCRClosedBySystemMinutesToWait) - 1);
		}
		catch(Exception e){
			return 1440 * 12;
		}
	}
	
	public static String getProfileName(ID userId){
		User p = [SELECT Id, Name, Profile.Name FROM User WHERE Id =: userId ];
		if(p!=null){
			return p.profile.Name;
		}
		return null;
	}
	
	public static Id getQueueId(String queueName){
		Id result = null;
		if(queueNamesToIds == null) {
			queueNamesToIds = new Map<String, Id>();
			for(Group gr : [SELECT Id, Name FROM Group WHERE Type='Queue']) {
				queueNamesToIds.put(gr.Name, gr.Id);
			}
		}

		if(queueNamesToIds.containsKey(queueName)) {
			result = queueNamesToIds.get(queueName);
		}

		return result;
	}

	public static void sendToReltio(List<Change_Request_gne__c> newTrigger) {
		for(Change_Request_gne__c cr : newTrigger) {
			GNE_ReltioCreateRequest.sendRequest(cr, GNE_ReltioCreateRequest.OperationType.INS);
		}
	}
}