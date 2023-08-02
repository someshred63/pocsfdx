/**********************************************************************************************************************
Purpose: ROBOCOPS-350
Expire current contract IAP request when its renewal request is processed.   
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raju Manche  10/13/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
trigger SPLOA_Expire_Renewal_Request on C_Ops_SPLOA_Request__c (after update) {
    C_Ops_SPLOA_Request__c oldRequest = trigger.old[0];
    if(Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> oldRequestsId = new Set<Id>();
        List<C_Ops_SPLOA_Request__c> oldReqUpdatedList = new List<C_Ops_SPLOA_Request__c> ();
        for(C_Ops_SPLOA_Request__c req: trigger.new) {
            if(oldRequest.C_Ops_SPLOA_Request_Status__c!='Processed' && req.C_Ops_SPLOA_Request_Status__c == 'Processed' && (req.SPLOA_Renewal__c) && req.SPLOA_Parent_Process_Request__c!=null) {
                oldRequestsId.add(req.SPLOA_Parent_Process_Request__c);
            } 
        }
        if(!oldRequestsId.isEmpty()){
            oldReqUpdatedList =[SELECT Id, C_Ops_SPLOA_Request_Status__c FROM C_Ops_SPLOA_Request__c WHERE Id IN : oldRequestsId and Renew_Request_Submitted__c=TRUE];
        }
        if(!oldReqUpdatedList.isEmpty()){        
            for(C_Ops_SPLOA_Request__c oldReq : oldReqUpdatedList){            
                if( oldReq.C_Ops_SPLOA_Request_Status__c != 'Expired'){                
                    oldReq.C_Ops_SPLOA_Request_Status__c = 'Expired';
                }
            }
            update oldReqUpdatedList;
        }        
    }
}