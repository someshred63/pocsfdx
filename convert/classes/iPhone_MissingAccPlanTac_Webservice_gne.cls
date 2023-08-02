global with sharing class iPhone_MissingAccPlanTac_Webservice_gne {
	WebService String accountPlanIdsInput;
	WebService String accountTacticIdsInput;
	
	global class Response{
        WebService AccountPlans accountPlans;
        WebService AccountTactics accountTactics;
    }
    
    global class AccountPlans{
        WebService List<AccountPlanRow> row;
    }
    
    global class AccountTactics{
        WebService List<AccountTacticRow> row;
    }
    
    global class AccountTacticRow{
        WebService String id;
        WebService String name;
        WebService String accountPlan;
    }
    
    global class AccountPlanRow{
        WebService String id;
        WebService String name;
        WebService String account;
        WebService String segment;
        WebService String team;
    }
    
    static List<Account_Plan_vod__c> accountPlans(List<String> accountPlanIds){
        List<Account_Plan_vod__c> accountPlanList = new List<Account_Plan_vod__c>();

        accountPlanList = [SELECT
        						Id,
        						Name,
        						Account_vod__c,
        						Segment_gne__c,
        						Team_gne__c,
        						CreatedDate,
        						LastmodifiedDate
        					FROM
        						Account_Plan_vod__c
        					WHERE
            					Id
            				IN
            					:accountPlanIds];
        System.debug('accountPlanList: '+accountPlanList);
        return accountPlanList;
    }
    
    static List<Account_Tactic_vod__c> accountTactics(List<String> accountTacticIds){
        List<Account_Tactic_vod__c> accountTacticList = new List<Account_Tactic_vod__c>();

        accountTacticList = [SELECT
        						Id,
        						Name,
        						Account_vod__c,
        						Account_Plan_vod__c,
        						CreatedDate,
        						LastmodifiedDate
        					FROM
        						Account_Tactic_vod__c
        					WHERE
            					Id
            				IN
            					:accountTacticIds];
        System.debug('accountTacticList: '+accountTacticList);
        return accountTacticList;
    }
    
    Webservice static Response returnAccountPlansAndTactics(String accountPlanIdsInput, String accountTacticIdsInput){
        System.debug('accountPlanIdsInput: '+accountPlanIdsInput);
        System.debug('accountTacticIdsInput: '+accountTacticIdsInput);
        List<String> accountPlanIdList = new List<String>();
        List<String> accountTacticIdList = new List<String>();
        if(accountPlanIdsInput != null && accountPlanIdsInput != ''){
        	accountPlanIdList = accountPlanIdsInput.split(',');
        }
        if(accountTacticIdsInput != null && accountTacticIdsInput != ''){
        	accountTacticIdList = accountTacticIdsInput.split(',');
        }
        System.debug('accountPlanIdList: '+accountPlanIdList);
        System.debug('accountTacticIdList: '+accountTacticIdList);
        
        List<Account_Plan_vod__c> accountPlans = accountPlans(accountPlanIdList);
        List<Account_Tactic_vod__c> accountTactics = accountTactics(accountTacticIdList);
        
        Response result_set_sync = new Response();
        result_set_sync.accountPlans = new AccountPlans();
        result_set_sync.accountTactics = new AccountTactics();
        result_set_sync.accountPlans.row = new List<AccountPlanRow>();
        result_set_sync.accountTactics.row = new List<AccountTacticRow>();
        
        for(Account_Plan_vod__c accountPlan : accountPlans){
            AccountPlanRow newRow = new AccountPlanRow();
            newRow.id = accountPlan.Id;
            newRow.name = accountPlan.Name;
            newRow.account = accountPlan.Account_vod__c;
            newRow.segment = accountPlan.Segment_gne__c;
            newRow.team = accountPlan.Team_gne__c;
            result_set_sync.accountPlans.row.add(newRow);
        }
        
        for(Account_Tactic_vod__c accountTactic : accountTactics){
            AccountTacticRow newRow = new AccountTacticRow();
            newRow.id = accountTactic.Id;
            newRow.name = accountTactic.Name;
            newRow.accountPlan = accountTactic.Account_Plan_vod__c;
            result_set_sync.accountTactics.row.add(newRow);
        }
        return result_set_sync;
    }
}