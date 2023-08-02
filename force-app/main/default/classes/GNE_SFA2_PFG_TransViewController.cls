public with sharing virtual class GNE_SFA2_PFG_TransViewController extends GNE_SFA2_PFG_Base_Controller {
    public ListController listController { get; set; }
    
    public GNE_SFA2_PFG_TransViewController() {
        listController = new ListController(this, 'SFA2_PFG_Transaction_gne__c');
    }
    
    
    public virtual class ListController extends GNE_SFA2_List_View_Base_Controller {
    	protected GNE_SFA2_PFG_TransViewController parentController;
    	
		public ListController(GNE_SFA2_PFG_TransViewController parentController, String objName) {
			super(objName);
			this.parentController = parentController;
			
			// populate available users depending on current user role. 
			customFilterVariable_1 = GNE_SFA2_PFG_Util.getSubordinateCSs(UserInfo.getUserId());
			customFilterVariable_2 = GNE_SFA2_PFG_Util.getTerritoryNamesForUser(UserInfo.getUserId());
		}
		
		public String getCustListPageName() {
			Boolean dtpActive = parentController.hasActiveDtpBrands;
			Boolean hcActive = parentController.hasActiveHcBrands;
			
			String pageName = null;
			
			if(dtpActive && hcActive) {
				pageName = 'All Transactions';
			} else if(dtpActive) {
				pageName = 'All DTP Transactions';
			} else if(hcActive) {
				pageName = 'All HC Transactions';
			}
			
            return pageName;
        }
		
		public override virtual String getCustomFilterExpression(GNE_SFA2_List_View_Setup_Ext.ConditionItem cItem) {
			String customFilter = '';
			String fieldName = cItem.field.toUpperCase();
			String fromUserFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.From_User_gne__c).toUpperCase();
			String toUserFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.To_User_gne__c).toUpperCase();
			String fromTerritoryFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.From_Territory_Name_gne__c).toUpperCase();
			String toTerritoryFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.To_Territory_Name_gne__c).toUpperCase();
			String recordTypeFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.RecordTypeId).toUpperCase();
			
			if(fieldName == fromUserFieldName || fieldName == toUserFieldName) {
				customFilter = fieldName + ' IN :customFilterVariable_1'; 
			} else if(fieldName.contains(fromUserFieldName) && fieldName.contains(toUserFieldName) &&
			          fieldName.contains(fromTerritoryFieldName) && fieldName.contains(toTerritoryFieldName)) {
				String userVariableName = 'customFilterVariable_1';
				String terrVariableName = 'customFilterVariable_2';
				customFilter = '(' + String.join(new List<String>{
						fromUserFieldName + ' IN :' + userVariableName, 
						toUserFieldName + ' IN :' + userVariableName,
						fromTerritoryFieldName + ' IN :' + terrVariableName, 
						toTerritoryFieldName + ' IN :' + terrVariableName
					}, ' OR ') + ')';
			} else if(fieldName.contains(fromUserFieldName) && fieldName.contains(toUserFieldName)) {
				String variableName = 'customFilterVariable_1';
				customFilter = '(' + fromUserFieldName + ' IN :' + variableName + ' OR ' 
						+ toUserFieldName + ' IN :' + variableName + ')';
			} else if(fieldName == recordTypeFieldName) { // Record Type filter
				String recTypeName = cItem.value;
				customFilter = recordTypeFieldName + ' ' + (cItem.operator == 'eq' ? '=' : '<>' ) + ' \'' + GNE_SFA2_PFG_Util.getTransactionRecordTypeId(recTypeName) + '\'';
			} else if(fieldName.contains(fromTerritoryFieldName) && fieldName.contains(toTerritoryFieldName)) {
				String variableName = 'customFilterVariable_2';
				customFilter = '(' + fromTerritoryFieldName + ' IN :' + variableName + ' OR ' 
						+ toTerritoryFieldName + ' IN :' + variableName + ')';
			}
			
			return customFilter;
		}
    }
}