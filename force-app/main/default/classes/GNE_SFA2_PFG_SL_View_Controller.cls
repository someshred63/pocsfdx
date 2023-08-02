public with sharing class GNE_SFA2_PFG_SL_View_Controller extends GNE_SFA2_PFG_Base_Controller {
    
    public ListController listController { get; private set; }
    public String selectedRecordsString {get; set;}
    
    public GNE_SFA2_PFG_SL_View_Controller(ApexPages.StandardController controller){
        listController = new ListController(SFA2_PFG_Storage_Location_gne__c.SObjectType.getDescribe().getName());
    }
    
    protected override PageReference intInitCotroller() {
        return null;
    }
    
    public PageReference approveSelected() {
        return approveOrRejectSelected(true);
    }
    
    public PageReference rejectSelected() {
        return approveOrRejectSelected(false);
    }
    
    private Boolean validate(List<String> slIds, Map<Id, SFA2_PFG_Storage_Location_gne__c> slIdToStatus) {
    	Boolean isValid = true;
    	
    	if(slIds.isEmpty()) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.PFG_StorageLocation_Required));
        	isValid = false;
    	} else {
    		List<String> notSubmittedNames = new List<String>();
    		Integer errorIdx = 0;
    		
    		for(Id slId : slIds) {
                if(slIdToStatus.get(slId).Status_gne__c == GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_APPROVED || slIdToStatus.get(slId).Status_gne__c == GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_REJECTED) {
                	errorIdx++;
                	if(errorIdx>10) {
                		notSubmittedNames.add('...');
                		break;
                	} else {
                		notSubmittedNames.add(slIdToStatus.get(slId).Name);
                	}
                	
                }
        	}
        	if(!notSubmittedNames.isEmpty()){
        		String slNamesInString = String.join(notSubmittedNames,', ');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(System.Label.PFG_StorageLocation_Approval_Error, new String[]{slNamesInString}))); 
            	isValid = false;
        	}
    	}
    	
    	return isValid;
    }
    
    private PageReference approveOrRejectSelected(Boolean approveOrReject){
    	PageReference result = null;
    	List<String> slIds = selectedRecordsString.split(',');
        Map<Id, SFA2_PFG_Storage_Location_gne__c> slIdToStatus = GNE_SFA2_PFG_DAO.getStorageLocationsStatusesMap(slIds);
        
        if(validate(slIds, slIdToStatus)) {
        	try {
	            GNE_SFA2_PFG_Util.approveOrRejectStorageLocations(UserInfo.getUserId(), slIdToStatus.keySet(), approveOrReject);
	        } catch(Exception ex) {
	            result = setErrorPageReference(ex);
	        }
        }
        
        return result;
    }
    
    public class ListController extends GNE_SFA2_List_View_Base_Controller{
        public ListController(String objName) {
            super(objName);
        }
    }
}