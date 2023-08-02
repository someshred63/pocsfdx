public class C_Ops_Submitted_Req_Controller {
    public void clearfieldsuponstatuschange(List<C_Ops_SPLOA_Request__c> newList, List<C_Ops_SPLOA_Request__c> oldList){
        Map<Id,C_Ops_SPLOA_Request__c> oldMap = new Map<Id,C_Ops_SPLOA_Request__c>();
        
        for(C_Ops_SPLOA_Request__c rcd:oldList){           
            oldMap.put(rcd.Id,rcd);          
        }
        for(C_Ops_SPLOA_Request__c req:newList){
            if(req.C_Ops_SPLOA_Request_Status__c!= 'Denied' && req.Id != null 
               && oldMap.get(req.Id)!= null &&  oldMap.get(req.Id).C_Ops_SPLOA_Request_Status__c == 'Denied'
              ){
                  req.Denial_Reason__c = '';
                  req.Date_Denied_If_Applicable__c = null;
              }
            else if(req.C_Ops_SPLOA_Request_Status__c == 'On Hold' && req.Id != null
                    && oldMap.get(req.Id)!= null  && oldMap.get(req.Id).C_Ops_SPLOA_Request_Status__c != 'On Hold'
                    && req.Assign_To__c != null){
                        // req.Assign_To__c = null;
                    }
            else if(req.C_Ops_SPLOA_Request_Status__c == 'On Hold' && req.Id != null && 
                    oldMap.get(req.Id)!= null && string.isBlank(oldMap.get(req.Id).Assign_To__c)  && req.Assign_To__c != null){
                        req.C_Ops_SPLOA_Request_Status__c = 'In Process';
                    }
        }
    }
    
}