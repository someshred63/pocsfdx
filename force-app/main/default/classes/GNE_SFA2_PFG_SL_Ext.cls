public with sharing class GNE_SFA2_PFG_SL_Ext extends GNE_SFA2_DynamicVFLoader {
	public PageBlockTableEngine approvalProcessListEngine {get; private set;}
    
    private ApexPages.Standardcontroller controller;
    
    
    
    public GNE_SFA2_PFG_SL_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PFG_SL_Layout');
        this.controller = controller;
        approvalProcessListEngine = new PageBlockTableEngine();
    }
    
    public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }
    
    public PageReference editClick(){
        PageReference pageref = controller.edit();
        pageref.setredirect(true);
        return pageref;
    }
    
    public List<ProcessInstance> getApprovalProcesses() {
    	return GNE_SFA2_PFG_Util.getApprovalProcesses(new Set<Id>{myObject.Id}).get(myObject.Id); 
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