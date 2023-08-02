public class GNE_SFA2_Lookup_Ctrl_Engine {
	public Map<String,Map<String,LookupFieldData>> fieldData {get; private set;}
	
	public GNE_SFA2_Lookup_Ctrl_Engine() {
		fieldData = new Map<String,Map<String,LookupFieldData>>();
	}
	
	public void addFieldData(String sObjectName, String fieldName) {
		addFieldData(sObjectName, fieldName, 'Name', null, null);
	}
	
	public void addFieldData(String sObjectName, String fieldName,
			String columns, String whereExpressions, String availableRecordIds) {
		if(!fieldData.containsKey(sObjectName)) {
			fieldData.put(sObjectName,new Map<String,LookupFieldData>());
		}
		
		fieldData.get(sObjectName).put(fieldName, new LookupFieldData(
				columns, whereExpressions, availableRecordIds));
    }
	
	public class LookupFieldData {
		public String columns {get; private set;}
		public String whereExpressions {get; private set;}
		public String availableRecordIds {get; private set;}
		
		public LookupFieldData(String a_columns, String a_whereExpressions, String a_availableRecordIds) {
			columns = a_columns;
			whereExpressions = a_whereExpressions;
			availableRecordIds = a_availableRecordIds;
		}
	}
}