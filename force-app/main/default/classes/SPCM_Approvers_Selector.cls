public without sharing class SPCM_Approvers_Selector {
    ApexPages.StandardController controller;
    
    public SPCM_Approvers_Selector(ApexPages.StandardController sc) {
        controller = sc;
    }
    
    public String approver2 {get; set;}
    
    public List<SelectOption> getAvailableLevel2() {
        Id currentUser = UserInfo.getUserId();
        String recId = controller.getId();
        SPCM_CARS_Contract_Summary_Form__c rec = [SELECT Appr_Approver_1__c, Appr_Approval_Level__c, Initiated_By__c FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id=:recId LIMIT 1];
        //String approverId = [SELECT Appr_Approver_1__c,  FROM SPCM_CARS_Contract_Summary_Form__c WHERE Id=:recId LIMIT 1].Appr_Approver_1__c;
		String approverId = rec.Appr_Approver_1__c;
		Decimal levelNumber = rec.Appr_Approval_Level__c;
		String initiatedBy = rec.Initiated_By__c;
		
        List<SPCM_Approval_Process_Level__c> approvers = [SELECT Id, User__r.Name 
                FROM SPCM_Approval_Process_Level__c 
                WHERE Level_Number__c = :levelNumber AND Approval_Process__r.Name = 'SPCM CARS Contract Summary Form' 
                AND User__c != null AND User__c != :currentUser AND User__c != :approverId AND User__c != :initiatedBy];

        List<SelectOption> options = new List<SelectOption>();
        for (SPCM_Approval_Process_Level__c l : approvers) {
            options.add(new SelectOption(l.Id, l.User__r.Name));
        }
        
        return options;
    }
    
    public PageReference reroute() {
    	SPCM_CARS_Contract_Summary_Form__c rec = (SPCM_CARS_Contract_Summary_Form__c) controller.getRecord();
        
        List<SPCM_Approval_Process_Level__c> level = [SELECT Id, User__c, Level_Number__c FROM SPCM_Approval_Process_Level__c WHERE Id=:approver2];

        if (level.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Approval process configuration is invalid.'));
            return null;
        }
        
        try {
        	updateProcessWorkitem(rec.Id, level.get(0).User__c);
        
        	SPCM_CARSContractSummaryFormUtils.UpdateLevelApprover(rec, level.get(0).Level_Number__c, level.get(0).Id);
        } catch (DMLException dmle) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only current approver or Salesforce administrator can reroute this request.'));
        	
        	return null;
        }
                
        return new PageReference('/' + rec.Id);
    }
    
    private void updateProcessWorkitem(Id recId, Id userId) {
    	ProcessInstanceWorkitem workitem = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:recId];
    	workitem.ActorId = userId;
    	update workitem;
    }
}