public with sharing class GNE_SFA2_PFG_ViewRequest_Controller extends GNE_SFA2_PFG_TransViewController {
    
    public ListController listController { get; private set; }
    
    public String selectedRecordsString {get; set;}
    
    public GNE_SFA2_PFG_ViewRequest_Controller() {
        listController = new ListController(this, SFA2_PFG_Transaction_gne__c.SObjectType.getDescribe().getName());
    }
    
    public PageReference approveSelected() {
        PageReference result = null;
        List<String> trxIdsStr = String.isNotBlank(selectedRecordsString) ? selectedRecordsString.split(',') : null;
        
        if(trxIdsStr!=null && !trxIdsStr.isEmpty()) {
        	Set<Id> trxIds = new Set<Id>();
        	for (String trxStr : trxIdsStr){
        		trxIds.add((Id)trxStr);
        	}        	
            try {                
                GNE_SFA2_PFG_Util.approveOrders(trxIds);                
            } catch(DMLException e){
            	// Managed by Salesforce -> validation error messages are added to pageMessages component in vf page
            } catch(Exception ex) {
                result = setErrorPageReference(ex);
            }
        } else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.PFG_Request_Required));
    	}
        
        return result;
    }
    
    public class ListController extends GNE_SFA2_PFG_TransViewController.ListController {
        
        public ListController(GNE_SFA2_PFG_ViewRequest_Controller parentController, String objName) {
            super(parentController, objName);
            
            if(parentController.isManager) {
                customFilterVariable_10 = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED};
                customFilterVariable_9 = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED};
            } else if(parentController.isCs) {
                customFilterVariable_9 = new Set<String>{
                    GNE_SFA2_PFG_Util.TRANSACTION_STATUS_SUBMITTED,
                    GNE_SFA2_PFG_Util.TRANSACTION_STATUS_APPROVED
                };
            }
        }
        
        public String getCustomListPageName() {
            return 'PFG Requests';
        }
            
        public override String getCustomFilterExpression(GNE_SFA2_List_View_Setup_Ext.ConditionItem cItem) {
            String customFilter = '';
            String fieldName = cItem.field.toUpperCase();
            String genShipFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.Generate_Shipment_Flag__c).toUpperCase();
            String statusFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.Status_gne__c).toUpperCase();
            Boolean isManager = parentController.isManager;
            
            if(fieldName == genShipFieldName) {
                customFilter = (isManager) ? (fieldName + ' IN :customFilterVariable_10') : null;
            } else if(fieldName == statusFieldName) { //
                customFilter = (customFilterVariable_9!=null) ? (fieldName + ' IN :customFilterVariable_9') : null;
            } else {
                customFilter = super.getCustomFilterExpression(cItem);
            }
            
            return customFilter;
        }
    }
}