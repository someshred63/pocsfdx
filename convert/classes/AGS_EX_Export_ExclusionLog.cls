public with sharing class AGS_EX_Export_ExclusionLog {

	String viewID;
	String columnsString;	
	List<String> fieldLabels;

	public ApexPages.StandardSetController ssc { get; set; }
	public List<AGS_EX_Exclusion_Check_gne__c> resultList { get; set; }
	public List<AGS_EX_Exclusion_Check_gne__c> displayList { get; set; }
	public Set<String> fieldAPINames { get; set; }
	public List<String> listFieldAPINames { get; set; }
	public Map<String, String> apiToLabel { get; set; }

	public AGS_EX_Export_ExclusionLog() {
		viewID = ApexPages.currentPage().getparameters().get('viewId');
		columnsString = ApexPages.currentPage().getparameters().get('columns');

		
		listFieldAPINames = new List<String>();

		fieldLabels = columnsString.split(',');
		Map<String, SObjectField> fieldMap = getFieldMapForExclusionCheck();
		Map<String, String> labelToAPI = getFieldAPINamesByLabel(fieldMap);
		apiToLabel = getLabelsByFieldAPIName(fieldMap);

		fieldAPINames = new Set<String>();
		for (String label : fieldLabels) {
			if (label == 'Created By Alias') {
				fieldAPINames.add('CreatedBy.Alias');
				apiToLabel.put('CreatedBy.Alias', label);
			}
			else if (label == 'Created By') {
				fieldAPINames.add('CreatedBy.Name');
				apiToLabel.put('CreatedBy.Name', label);
			}
			else if (label == 'Last Modified By Alias') {
				fieldAPINames.add('LastModifiedBy.Alias');
				apiToLabel.put('LastModifiedBy.Alias', label);
			}
			else if (label == 'Last Modified By') {
				fieldAPINames.add('LastModifiedBy.Name');
				apiToLabel.put('LastModifiedBy.Name', label);
			}
			else if (label == 'Exclusion Request') {
				fieldAPINames.add('AGS_EX_Exclusion_Request_gne__r.Name');
				apiToLabel.put('AGS_EX_Exclusion_Request_gne__r.Name', label);
			}
			else if (label == 'Reviewed By') {
				fieldAPINames.add('AGS_EX_Reviewer_Name_gne__r.Name');
				apiToLabel.put('AGS_EX_Reviewer_Name_gne__r.Name', label);
			}
			else if (label == 'Received Connection Name') {
				fieldAPINames.add('ConnectionReceived.ConnectionName');
				apiToLabel.put('ConnectionReceived.ConnectionName', label);
			}
			else if (label == 'Sent Connection Name') {
				fieldAPINames.add('ConnectionSent.ConnectionName');
				apiToLabel.put('ConnectionSent.ConnectionName', label);
			}
			else if (label == 'Attachment') {
				fieldAPINames.add('AGS_EX_Check_Attachment_gne__c');
				apiToLabel.put('AGS_EX_Check_Attachment_gne__c', label);
			}
			else {
				fieldAPINames.add(labelToAPI.get(label));
			}
		}
		
		listFieldAPINames.addAll(fieldAPINames);
		String query ='SELECT ' + String.join(listFieldAPINames, ',') + ' FROM AGS_EX_Exclusion_Check_gne__c';
		System.debug('$$ query' + query);
		ssc = new ApexPages.StandardSetController(Database.getQueryLocator(query));
		ssc.setPageSize(1000);
		ssc.setFilterId(viewID);
		resultList = ssc.getRecords();
		addBaseURLToDownloadLinks();
	}

	private Map<String, SObjectField> getFieldMapForExclusionCheck() {
		return Schema.SObjectType.AGS_EX_Exclusion_Check_gne__c.getsObjectType().getDescribe().Fields.getMap();
	}

	private Map<String, String> getFieldAPINamesByLabel(Map<String, SObjectField> fieldMap) {
		Map<String, String> labelToAPI = new Map<String, String>();
		for(String f :  fieldMap.keySet()) {
			labelToAPI.put(String.valueOf(fieldMap.get(f).getDescribe().getLabel()), String.valueOf(fieldMap.get(f).getDescribe().getSobjectField()));
		}
		return labelToAPI;
	}

	private Map<String, String> getLabelsByFieldAPIName(Map<String, SObjectField> fieldMap) {
		Map<String, String> apiToLabel = new Map<String, String>();
		for(String f :  fieldMap.keySet()) {
			apiToLabel.put(String.valueOf(fieldMap.get(f).getDescribe().getSobjectField()), String.valueOf(fieldMap.get(f).getDescribe().getLabel()));
		}
		return apiToLabel;
	}

	private void addBaseURLToDownloadLinks() {
		if (fieldAPINames.contains('AGS_EX_Check_Attachment_gne__c')) {
			for (AGS_EX_Exclusion_Check_gne__c check : resultList) {
				if (!String.isBlank(check.AGS_EX_Check_Attachment_gne__c)) {
					check.AGS_EX_Check_Attachment_gne__c = System.URL.getSalesforceBaseUrl().toExternalForm() + check.AGS_EX_Check_Attachment_gne__c;
				}				
			}
		}	
	}
}