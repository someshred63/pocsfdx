public class SPLOA_Link_Submitted_Request_Controller {    
    @AuraEnabled 
    public static Boolean fetchUser(){        
        List<PermissionSetAssignment> pstList = new List<PermissionSetAssignment>(); 
        Boolean pSet=false;
        Id userId = Userinfo.getUserId();
        pstList = [SELECT AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =:Userinfo.getUserId()];
        if(!pstList.isEmpty()){
            for(PermissionSetAssignment pst :pstList){            
                if(pst.PermissionSet.Name=='C_Ops_SPLOA_View_Only_User'){
                    pSet=true;                                
                }    
            }    
        }
        return pSet;
    }
    @AuraEnabled
    public static List < C_Ops_SPLOA_Request__c > fetchRequest(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < C_Ops_SPLOA_Request__c > returnList = new List < C_Ops_SPLOA_Request__c > ();
        List < C_Ops_SPLOA_Request__c > lstOfRequests = [select id, Name, C_Ops_SPLOA_Request_Status__c from C_Ops_SPLOA_Request__c
                                                         where Name LIKE: searchKey];
        
        for (C_Ops_SPLOA_Request__c req: lstOfRequests) {
            returnList.add(req);
        }
        return returnList;
    }
    @AuraEnabled 
    public static List<C_Ops_SPLOA_Request__c> link_submittedRequest(List<String> slctRec, String recordId)
    {
        SPLOA_Link_Submitted_Request_Controller alc = new SPLOA_Link_Submitted_Request_Controller();
        List<C_Ops_SPLOA_Request__c> updateReqList = new List<C_Ops_SPLOA_Request__c>();
        List<C_Ops_SPLOA_Request__c> updateDocList = new List<C_Ops_SPLOA_Request__c>();
        system.debug('selected request'+slctRec);
        system.debug('selected recordId'+recordId);
        updateReqList = [SELECT Id,SPLOA_All_Documents__c FROM C_Ops_SPLOA_Request__c WHERE Id IN: slctRec ];
        system.debug('selected request'+updateReqList);
        for(C_Ops_SPLOA_Request__c req: updateReqList){           
            req.SPLOA_All_Documents__c=recordId;   
            updateDocList.add(req);
        }
        try{           
            update updateDocList;
        } catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }        
        return null;       
    }
}