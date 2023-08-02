public without sharing class gFRS_LockoutRequestExtension {
    
    private final ApexPages.StandardController stdCtrl;
    
    public final GFRS_Organization__c org { get; private set; }
    
    public final List<GFRS_Funding_Request__c> requests { get; private set; }
    
    public final List<GFRS_Funding_Request__c> refundRequests { get; private set; }
    
    public Boolean isInternal { get; set; }
    
    public gFRS_LockoutRequestExtension(final ApexPages.StandardController ctrl) {
        
        List<PermissionSetAssignment> lstPid=[SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'gFRS_Compliance_Flags_Notes' and AssigneeId=:userinfo.getUserId()];
        Group grp=[SELECT id, relatedid, name FROM Group WHERE name = 'GNE-GFRS-IMED Team'];
        List<GroupMember> lstgrp=[SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:grp.id and UserOrGroupId=:userinfo.getUserId()];
        
        if(lstPid.size()>0 || lstgrp.size()>0){
            isInternal=true;
            try {
                final Map<String, String> params = ApexPages.currentPage().getParameters();
                final GFRS_Organization__c[] orgs = String.isBlank(params.get('orgId')) ? new GFRS_Organization__c[]{ } : [
                    SELECT Id, Name, RecordType.Name FROM GFRS_Organization__c
                    WHERE Id = :params.get('orgId') LIMIT 1
                ];
                org = orgs.isEmpty() ? new GFRS_Organization__c() : orgs[0];
            } catch (QueryException e) {
                ApexPages.addMessages(e);
            } finally {
                requests = new GFRS_Funding_Request__c[]{ };
                refundRequests = new GFRS_Funding_Request__c[]{ };
                findRequests();
            }
        }
        else{
            isInternal=false;    
            try {
                final Map<String, String> params = ApexPages.currentPage().getParameters();
                final GFRS_Organization__c[] orgs = String.isBlank(params.get('orgId')) ? new GFRS_Organization__c[]{ } : [
                    SELECT Id, Name, RecordType.Name FROM GFRS_Organization__c
                    WHERE Id = :params.get('orgId') LIMIT 1
                ];
                org = orgs.isEmpty() ? new GFRS_Organization__c() : orgs[0];
            } catch (QueryException e) {
                ApexPages.addMessages(e);
            } finally {
                //requests = new GFRS_Funding_Request__c[]{ };
                    //findRequests();
            }
            
        }
        
        
        
        
    }
    
    
    
    
    public void findRequests() {
        requests.clear();
        refundRequests.clear();
        
        list<gFRS_Tasks__c> tasks = new list<gFRS_Tasks__c>();
        map<Id, gFRS_Tasks__c> taskMap = new map<Id, gFRS_Tasks__c>();
        Date lockOutDate = Date.today();
        lockOutDate = lockOutDate.addDays(-91);
        
        tasks = [SELECT Id, Name, Action_Type__c, gFRS_Funding_Request__c FROM gFRS_Tasks__c WHERE Action_Type__c = 'Reconciliation' AND gFRS_Funding_Request__r.Organization__c = :org.Id ];
        for(gFRS_Tasks__c tsk : tasks){
            taskMap.put(tsk.gFRS_Funding_Request__c, tsk);
        }
        
        for (GFRS_Funding_Request__c req : org.Id == null ? new GFRS_Funding_Request__c[]{ } : [
            SELECT Name,Program_End_Date_max__c,CreatedBy.Name,CreatedBy.Email,CreatedBy.External_ID_gne__c,LastModifiedBy.Name, LastModifiedById, OwnerId,Owner.name, RecordType.Name, Sub_Status__c, Status__c, Event_Program_Title__c, Reconciliation_due_date__c
            FROM GFRS_Funding_Request__c
            WHERE Organization__c = :org.Id
            AND Program_End_Date_max__c <= :lockOutDate AND Id IN: taskMap.keyset()
        ]) {
            requests.add(req);
        }
        system.debug('@@@'+requests);
        
        list<gFRS_Tasks__c> refundTasks = new list<gFRS_Tasks__c>();
        map<Id, gFRS_Tasks__c> taskMap2 = new map<Id, gFRS_Tasks__c>();
        Date lockOutDate2 = Date.today();
        lockOutDate2 = lockOutDate2.addDays(-31);
        
        refundTasks = [SELECT Id, Name, Action_Type__c, gFRS_Funding_Request__c FROM gFRS_Tasks__c WHERE Action_Type__c = 'Refund' AND gFRS_Funding_Request__r.Organization__c = :org.Id ];
        for(gFRS_Tasks__c tsk2 : refundTasks){
            taskMap2.put(tsk2.gFRS_Funding_Request__c, tsk2);
        }
        
        for (GFRS_Funding_Request__c req : org.Id == null ? new GFRS_Funding_Request__c[]{ } : [
            SELECT Name,Program_End_Date_max__c,Refund_Request_Date__c,Refund_due_date__c,CreatedBy.Name,CreatedBy.Email,CreatedBy.External_ID_gne__c,LastModifiedBy.Name, LastModifiedById, OwnerId,Owner.name, RecordType.Name, Sub_Status__c, Status__c, Event_Program_Title__c, Reconciliation_due_date__c
            FROM GFRS_Funding_Request__c
            WHERE Organization__c = :org.Id
            AND Refund_Request_Date__c <= :lockOutDate2 AND Id IN: taskMap2.keyset()
        ]) {
            refundRequests.add(req);
        }
    } 
    public pagereference Backmethod(){
        String id = ApexPages.currentPage().getParameters().get('id');
        Pagereference pg =  new Pagereference('/'+org.id); 
        pg.setRedirect(true);
        return pg;
    }
    
}