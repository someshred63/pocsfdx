public with sharing class GNE_SFA2_ExternalIdUpdater {
	public static List<SObject> setExternalId(List<SOBject> sobjs) {
		return setExternalId(sobjs, 'External_Id_gne__c');
	}
	
	public static List<SObject> setExternalId(List<SOBject> sobjs, String fieldName) {
		String fieldNameBase = fieldName.toLowerCase();
		
		for(String fieldSufix : new String[]{'_gne_can__c', '_can_gne__c', '_gne__c', '_can__c', '_vod__c'}) {
			fieldNameBase = fieldNameBase.substringBefore(fieldSufix);
		}

		String formulaFieldName = fieldNameBase + '_calc' + fieldName.toLowerCase().substringAfter(fieldNameBase);
		return setExternalId(sobjs, fieldName, formulaFieldName);
	}
	
	public static List<SObject> setExternalId(List<SOBject> sobjs, String fieldName, String formulaFieldName) {
		List<SObject> changedRecs = new List<SObject>();
		for(SObject sobj : sobjs) {
		    String oldValue = (String)sobj.get(fieldName);
		    sobj.put(fieldName, sobj.get(formulaFieldName));
		    String newValue = (String)sobj.get(fieldName);
		    
		    if(!(String.isNotBlank(oldValue) ? oldValue : '').equals(String.isNotBlank(newValue) ? newValue : '')) {
                changedRecs.add(sobj);
            }
		}
		
		return changedRecs;
	}
}