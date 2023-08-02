public with sharing class GNE_SFA2_SBM_Export_Ctrl {

	public List<Speaker_Bureau_Membership_gne__c> SBMs { get; private set; }
	public String docName { get; private set; }
	public List<String> fieldNames { get; private set; }
	public Map<String, String> headerByApiName { get; private set; }

	public GNE_SFA2_SBM_Export_Ctrl() {
		SBMs = new List<Speaker_Bureau_Membership_gne__c>();
		String bureauId = ApexPages.currentPage().getParameters().get('br_id');
		if (String.isNotBlank(bureauId)) {
			String fieldCSV = getFieldListFromRelatedListConfig();
			SBMs = getRecordsToExport(fieldCSV, bureauId);
			fieldNames = fieldCSV.split(',');
			headerByApiName = getColumnHeaders(fieldNames);
			docName = 'SBM-List.xls';
		}
		else {
			docName = 'no-records.xls';
		}
	}



	private String getFieldListFromRelatedListConfig() {
		List<SFA2_Configuration_Object_Detail_gne__c> configurations = GNE_SFA2_ViewAll.getUIConfigurationObjectDetails('Speaker_Bureau_gne__c', '', 'Speaker_Bureau_Membership_gne__c');
		if (!configurations.isEmpty()) {
            GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(configurations.get(0).Attributes_gne__c);
            return attributesWrapper.fieldsCSV.replace('#/', '');
        }
        else {
        	return 'Name';
        }
	}

	private List<Speaker_Bureau_Membership_gne__c> getRecordsToExport(String fieldList, String bureauId) {
		List<Speaker_Bureau_Membership_gne__c> result = new List<Speaker_Bureau_Membership_gne__c>();
		if (String.isNotBlank(fieldList)) {
			String query = 'SELECT ' + fieldList + ' FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Bureau_ID_gne__c = \'' + bureauId + '\'';
			query = query.replace('Bureau_Member_gne__c', 'Bureau_Member_gne__r.Name');
			result = (List<Speaker_Bureau_Membership_gne__c>)Database.query(query);
		}
		return result;
	}

	private Map<String, String> getColumnHeaders(List<String> fieldNames) {
        Map<String, String> result = new Map<String, String>();
        for(String fieldName : fieldNames) {
            String label = Schema.SObjectType.Speaker_Bureau_Membership_gne__c.fields.getMap().get(fieldName).getDescribe().getLabel();
            result.put(fieldName, label);
        }
        return result;
    }
}