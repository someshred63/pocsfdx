public with sharing class GNE_SFA2_PFG_SL_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {
    public PageBlockTableEngine approvalProcessListEngine {get; private set;}
    
    private List<ProcessInstance> approvalProcessList;
    private Id currentUserId;
    private Boolean isCs;
    
    public GNE_SFA2_PFG_SL_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PFG_SL_Layout');
        approvalProcessListEngine = new PageBlockTableEngine();
    }
    
    public override PageReference init() {
    	additionalQueryFields.addAll(new Set<String>{'CreatedDate', 'LastModifiedDate'});
    	return super.init();
    }
    
    protected override void initController(ApexPages.StandardController controller) {
        currentUserId = UserInfo.getUserId();
        isCs = GNE_SFA2_PFG_Util.checkIsUserCS(currentUserId);
        
        if(controller.getRecord().Id == null){
            myObject = new SFA2_PFG_Storage_Location_gne__c();
            
            if(isCs) {
                myObject.put('User_gne__c', currentUserId);
            }
        }
        
        super.initController(controller);
    }
    
    public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }
    
    protected override void populateLookupInfos() {
        super.populateLookupInfos();
        lookupAvailableRecordIds.put('USER_GNE__C', String.join(new List<Id>(getLookupUserIds()),','));
        
        String lookupUserColumns = 'Name[display=true;searchBy=true],Email[searchBy=true],Profile_Name_gne__c[searchBy=true]';
        lookupColumns.put('USER_GNE__C', lookupUserColumns);
    }
    
    private Set<Id> getLookupUserIds() {
        Set<Id> userIds = GNE_SFA2_PFG_Util.getSubordinateCSs(currentUserId);
        
        if(userIds.isEmpty()) {
            // to be sure that no user will be available on the list
            userIds.add(UserInfo.getProfileId());
        }
        
        return userIds;
    }
    
    private void validate() {
    	List<String> errorMessages = new List<String>();
    	
    	// Check only the latest approval process. If it's pending, user cannot update the record.
	    for(ProcessInstance pi : getApprovalProcesses()) {
	    	if(pi.Status == GNE_SFA2_PFG_Util.APPROVAL_STATUS_PENDING) {
	    		errorMessages.add('Approval Process is still pending for current ' + SFA2_PFG_Storage_Location_gne__c.sObjectType.getDescribe().getLabel() + '.' +
	    			' You cannot edit a Storage Location pending approval. If you need to edit the location, please ensure the location is first rejected.');
	    	}
	    	break;
	    }
    	
    	if(!errorMessages.isEmpty())
            throw new GNE_SFA2_PFG_Base_Controller.InvalidInputValueException(errorMessages);
    }
    
    public PageReference saveSL() {
    	PageReference result = null;
    	try {
    		validate();
    		result = save();
    	} catch(GNE_SFA2_PFG_Base_Controller.InvalidInputValueException ex) {
            for(String errorMsg : ex.errorMessages) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,errorMsg));
            }
    	}
    	
    	return result;
    }
    
    public List<ProcessInstance> getApprovalProcesses() {
    	if(approvalProcessList==null) {
    		approvalProcessList = myObject.Id!=null 
    			? GNE_SFA2_PFG_Util.getApprovalProcesses(new Set<Id>{myObject.Id}).get(myObject.Id) 
    			: new List<ProcessInstance>();
    		approvalProcessList = approvalProcessList==null ? new List<ProcessInstance>() : approvalProcessList;
    	}
    	
    	return approvalProcessList; 
    }
    
    public class PageBlockTableEngine extends GNE_SFA2_PBT_Controller.ListenerEngine {
		
		public override Object getColumnValueForRecord(SObject obj, String columnName) {
			Object result = null;
			ProcessInstance pi = (ProcessInstance)obj;
			ProcessInstanceStep pis = (pi.Steps!=null && !pi.Steps.isEmpty()) ? pi.Steps[0] : null;
			ProcessInstanceWorkitem piw = (pi.Workitems!=null && !pi.Workitems.isEmpty()) ? pi.Workitems[0] : null;
			if(columnName == 'createdDate' && pis!=null) {
				result = pis.CreatedDate;
			} else if(columnName == 'stepStatus' && pis!=null) {
				result = pis.StepStatus;
			} else if(columnName == 'originalActor') {
				result = piw!=null ? piw.OriginalActor.Name : (pis!=null ? pis.OriginalActor.Name : null);
			} else if(columnName == 'actualActor') {
				result = piw!=null ? piw.Actor.Name : (pis!=null ? pis.Actor.Name : null);
			}
			
			return result;
		}
	}
}