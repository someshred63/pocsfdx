global with sharing class iPhone_AccountPlanTactic_Webservice_gne {

	WebService String accountIdsInput;
	WebService DateTime lastSyncDate;
	
	
	global class Response{
        WebService AccountPlans accountPlans;
        WebService AccountTactics accountTactics;
    }
    
    global class AccountPlans{
        WebService AccountPlansRows rows;
    }
    
    global class AccountTactics{
        WebService AccountTacticsRows rows;
    }
    
    global class AccountPlansRows{
        WebService AddedAccountPlan added;
        WebService UpdatedAccountPlan updated;
        Webservice String deleted = '';
    }
    
    global class AccountTacticsRows{
        WebService AddedAccountTactic added;
        WebService UpdatedAccountTactic updated;
        Webservice String deleted = '';
    }
    
    global class AddedAccountTactic{
        WebService List<AccountTacticRow> row;
    }
    
    global class UpdatedAccountTactic{
        WebService List<AccountTacticRow> row;
    }
    
    global class AddedAccountPlan{
        WebService List<AccountPlanRow> row;
    }
    
    global class UpdatedAccountPlan{
        WebService List<AccountPlanRow> row;
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
        WebService Boolean isActive;
    }
    
    static List<Account_Plan_vod__c> accountPlans(List<String> accountIdList){
        List<Account_Plan_vod__c> accountPlanList = new List<Account_Plan_vod__c>();

        accountPlanList = [SELECT
        						Id,
        						Name,
        						Account_vod__c,
        						Segment_gne__c,
        						Team_gne__c,
        						CreatedDate,
        						Active_vod__c,
        						LastmodifiedDate
        					FROM
        						Account_Plan_vod__c
        					WHERE
            					Account_vod__c
            				IN
            					:accountIdList];
        System.debug('accountPlanList: '+accountPlanList);
        return accountPlanList;
    }
    
    static List<Account_Tactic_vod__c> accountTactics(List<Account_Plan_vod__c> accountPlans){
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
            					Account_Plan_vod__c
            				IN
            					:accountPlans];
        System.debug('accountTacticList: '+accountTacticList);
        return accountTacticList;
    }
    
    static List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountPlans(DateTime lastSyncDate){
        List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountPlansList = new List<FRM_Deleted_Account_Plan_Tactic_gne__c>();

        deletedAccountPlansList = [SELECT
        						Id,
        						Object_Name_gne__c,
        						Record_Id_gne__c,
        						CreatedDate,
        						LastmodifiedDate
        					FROM
        						FRM_Deleted_Account_Plan_Tactic_gne__c
        					WHERE
            					Object_Name_gne__c = 'Account_Plan_vod__c'
            				AND CreatedDate >= :lastSyncDate];
        System.debug('deletedAccountPlansList: '+deletedAccountPlansList);
        return deletedAccountPlansList;
    }
    
    static List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountTactics(DateTime lastSyncDate){
        List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountTacticsList = new List<FRM_Deleted_Account_Plan_Tactic_gne__c>();

        deletedAccountTacticsList = [SELECT
        						Id,
        						Object_Name_gne__c,
        						Record_Id_gne__c,
        						CreatedDate,
        						LastmodifiedDate
        					FROM
        						FRM_Deleted_Account_Plan_Tactic_gne__c
        					WHERE
            					Object_Name_gne__c = 'Account_Tactic_vod__c'
            				AND CreatedDate >= :lastSyncDate];
        System.debug('deletedAccountTacticsList: '+deletedAccountTacticsList);
        return deletedAccountTacticsList;
    }
    
    
	Webservice static Response returnAccountPlansAndTactics(DateTime lastSyncDate, String accountIdsInput){
        System.debug('accountIdsInput: '+accountIdsInput);
        List<String> accountIdList = new List<String>();
        if(accountIdsInput != null && accountIdsInput != ''){
        	accountIdList = accountIdsInput.split(',');
        }
        System.debug('accountIdList: '+accountIdList);
        
        List<Account_Plan_vod__c> accountPlans = accountPlans(accountIdList);
        List<Account_Tactic_vod__c> accountTactics = accountTactics(accountPlans);
        
        Response result_set_sync = new Response();
        result_set_sync.accountPlans = new AccountPlans();
        result_set_sync.accountTactics = new AccountTactics();
        result_set_sync.accountPlans.rows = new AccountPlansRows();
        result_set_sync.accountTactics.rows = new AccountTacticsRows();
        
        // initial load
        if(lastSyncDate == null){
            result_set_sync.accountPlans.rows.added = new AddedAccountPlan();
            result_set_sync.accountPlans.rows.added.row = new List<AccountPlanRow>();
            result_set_sync.accountTactics.rows.added = new AddedAccountTactic();
            result_set_sync.accountTactics.rows.added.row = new List<AccountTacticRow>();
            
            for(Account_Plan_vod__c accountPlan : accountPlans){
                AccountPlanRow newRow = new AccountPlanRow();
                newRow.id = accountPlan.Id;
                newRow.name = accountPlan.Name;
                newRow.account = accountPlan.Account_vod__c;
                newRow.segment = accountPlan.Segment_gne__c;
                newRow.team = accountPlan.Team_gne__c;
                newRow.isActive = accountPlan.Active_vod__c;
                result_set_sync.accountPlans.rows.added.row.add(newRow);
            }
            
            for(Account_Tactic_vod__c accountTactic : accountTactics){
                AccountTacticRow newRow = new AccountTacticRow();
                newRow.id = accountTactic.Id;
                newRow.name = accountTactic.Name;
                newRow.accountPlan = accountTactic.Account_Plan_vod__c;
                result_set_sync.accountTactics.rows.added.row.add(newRow);
            }
        // delta
        } else {
        	List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountPlansList = deletedAccountPlans(lastSyncDate);
        	List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountTacticsList = deletedAccountTactics(lastSyncDate);
        	Integer deletedAccountPlanCounter = 0;
            Integer deletedAccountTacticCounter = 0;
        	
            result_set_sync.accountPlans.rows.added = new AddedAccountPlan();
            result_set_sync.accountPlans.rows.updated = new UpdatedAccountPlan();
            result_set_sync.accountPlans.rows.added.row = new List<AccountPlanRow>();
            result_set_sync.accountPlans.rows.updated.row = new List<AccountPlanRow>();
            result_set_sync.accountTactics.rows.added = new AddedAccountTactic();
            result_set_sync.accountTactics.rows.updated = new UpdatedAccountTactic();
            result_set_sync.accountTactics.rows.added.row = new List<AccountTacticRow>();
            result_set_sync.accountTactics.rows.updated.row = new List<AccountTacticRow>();
            
            for(Account_Plan_vod__c accountPlan : accountPlans){
                AccountPlanRow newRow = new AccountPlanRow();
                newRow.id = accountPlan.Id;
                newRow.name = accountPlan.Name;
                newRow.account = accountPlan.Account_vod__c;
                newRow.segment = accountPlan.Segment_gne__c;
                newRow.team = accountPlan.Team_gne__c;
                newRow.isActive = accountPlan.Active_vod__c;
                if(accountPlan.CreatedDate >= lastSyncDate){
                    result_set_sync.accountPlans.rows.added.row.add(newRow);
                }else if(accountPlan.CreatedDate < lastSyncDate && accountPlan.LastmodifiedDate >= lastSyncDate){
                    result_set_sync.accountPlans.rows.updated.row.add(newRow);
                }
            }
            
            for(FRM_Deleted_Account_Plan_Tactic_gne__c deletedAccountPlan : deletedAccountPlansList){
            	deletedAccountPlanCounter++;
            	if(deletedAccountPlanCounter != deletedAccountPlansList.size()){
                    result_set_sync.accountPlans.rows.deleted += deletedAccountPlan.Record_Id_gne__c +',';
                } else {
                    result_set_sync.accountPlans.rows.deleted += deletedAccountPlan.Record_Id_gne__c;
                }
            }
            
            for(Account_Tactic_vod__c accountTactic : accountTactics){
                AccountTacticRow newRow = new AccountTacticRow();
                newRow.id = accountTactic.Id;
                newRow.name = accountTactic.Name;
                newRow.accountPlan = accountTactic.Account_Plan_vod__c;
                
                if(accountTactic.CreatedDate >= lastSyncDate){
                    result_set_sync.accountTactics.rows.added.row.add(newRow);
                }
                else if(accountTactic.CreatedDate < lastSyncDate && accountTactic.LastmodifiedDate >= lastSyncDate){
                    result_set_sync.accountTactics.rows.updated.row.add(newRow);
                }
            }
            
            for(FRM_Deleted_Account_Plan_Tactic_gne__c deletedAccountTactic : deletedAccountTacticsList){
            	deletedAccountTacticCounter++;
            	if(deletedAccountTacticCounter != deletedAccountTacticsList.size()){
                    result_set_sync.accountTactics.rows.deleted += deletedAccountTactic.Record_Id_gne__c +',';
                } else {
                    result_set_sync.accountTactics.rows.deleted += deletedAccountTactic.Record_Id_gne__c;
                }
            }
        }
        return result_set_sync;
    }
}