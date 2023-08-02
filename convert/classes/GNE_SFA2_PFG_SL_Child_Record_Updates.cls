public with sharing class GNE_SFA2_PFG_SL_Child_Record_Updates {
    
    private static void submitSLforApproval(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        Integer reqIdx = 0;
        Integer idx = 0;
        Map<Id,SFA2_PFG_Storage_Location_gne__c> triggerNewMap = new Map<Id,SFA2_PFG_Storage_Location_gne__c>(triggerNew);
        Map<Integer,Integer> reqIdxToStorageLocIdx = new Map<Integer,Integer>();
        
        // Insert - always submit
        if (triggerOld==null) {
            for(SFA2_PFG_Storage_Location_gne__c slNew : triggerNew) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments(GNE_SFA2_PFG_SL_Trigger_Helper.APPROVAL_COMMENT);
                req.setObjectId(slNew.id);
                requests.add(req);
                reqIdxToStorageLocIdx.put(reqIdx++,idx);
                idx++;
            }
        } else { // Update - submit only if address fieds were changed
            Set<Id> pendingList = new Set<Id> ();
        
            for(ProcessInstance pr : [Select Id, Status, TargetObjectId from ProcessInstance 
                                      where Status = :GNE_SFA2_PFG_Util.APPROVAL_STATUS_PENDING and TargetObjectId IN :triggerNew]) {
                pendingList.add(pr.TargetObjectId);
            }
    		
            for(SFA2_PFG_Storage_Location_gne__c slNew : triggerNew) {
                if(slNew.Address_Changed_gne__c && !pendingList.contains(slNew.Id)) {
                
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(GNE_SFA2_PFG_SL_Trigger_Helper.APPROVAL_COMMENT);
                    req.setObjectId(slNew.id);
                    requests.add(req);
                    reqIdxToStorageLocIdx.put(reqIdx++,idx);
                }
                idx++;
            }
        }
        
        if(!requests.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(requests, false);
            if(results!=null) {
            	reqIdx = 0;
            	for(Approval.ProcessResult pr : results) {
            		if(!pr.isSuccess()) {
            			SFA2_PFG_Storage_Location_gne__c slNew = triggerNew.get(reqIdxToStorageLocIdx.get(reqIdx));
            			for(Database.Error err : pr.getErrors()) {
            				slNew.addError(err.getMessage());
            			}
            		}
            		reqIdx++;
            	}
            }
        }
    }

    public static void onAfterUpdate(List<SFA2_PFG_Storage_Location_gne__c> triggerOld, List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        submitSLforApproval(triggerOld, triggerNew);
    }

    public static void onAfterInsert(List<SFA2_PFG_Storage_Location_gne__c> triggerNew) {
        submitSLforApproval(null, triggerNew);
    }
    
    public static void onAfterDelete(List<SFA2_PFG_Storage_Location_gne__c> triggerOld) {
    
    }
}