public with sharing class GNE_SFA2_PFG_IC_ListView_Controller extends GNE_SFA2_PFG_Base_Controller  {
    public List_Controller listController { get; private set; }
    public String title { get; private set; }
    
    public GNE_SFA2_PFG_IC_ListView_Controller(ApexPages.StandardController controller){
        title = SFA2_PFG_Inventory_Count_gne__c.SObjectType.getDescribe().getLabel() + ' View';
        listController = new List_Controller(SFA2_PFG_Inventory_Count_gne__c.SObjectType.getDescribe().getName());
    }
    
    protected override PageReference intInitCotroller() {
        return null;
    }
    
    public class List_Controller extends GNE_SFA2_List_View_Base_Controller {
        public List_Controller(String objName) {
            super(objName);
            // populate available users depending on current user role. 
			customFilterVariable_1 = GNE_SFA2_PFG_Util.getSubordinateCSs(UserInfo.getUserId());
        }
        
        public override virtual String getCustomFilterExpression(GNE_SFA2_List_View_Setup_Ext.ConditionItem cItem) {
			String customFilter = '';
			String fieldName = cItem.field.toUpperCase();
			String userFieldName = String.valueOf(SFA2_PFG_Inventory_Count_gne__c.Inventory_For_gne__c).toUpperCase();
			
			if(fieldName == userFieldName) {
				customFilter = fieldName + ' IN :customFilterVariable_1'; 
			}
			
			return customFilter;
		}
    }
}