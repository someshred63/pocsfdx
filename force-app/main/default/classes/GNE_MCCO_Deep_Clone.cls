global class GNE_MCCO_Deep_Clone {
    
    /*Deep Clone*/
    /*****************************************************************
    //  This function does all the work behind the 'Clone'          //
    //  button on the Account Plan Page.  It will take an Account   //
    //  Plan and all related Strategies and Objectives and make     //
    //  Copies of them.                                             //
    *****************************************************************/
                                                /*Author: Omear Syed*/
    
    Webservice static String Deep_Clone(String AccPlanID){
        String Status = 'SUCCESS';
        
       //Retrieve the Account Plan Info. and Related Account Goal IDs
        Account_Plan_vod__c plan = [Select (Select ID from AccountGoal__r), (Select b.SystemModstamp, b.Percent_Patient_Population_gne__c, b.Payer_gne__c, 
        b.OwnerId, b.Name, b.MayEdit, b.LastModifiedDate, b.LastModifiedById, b.IsLocked, b.IsDeleted, b.Id, b.CreatedDate, b.CreatedById, b.Account_Plan_gne__c 
        From Account_Plan_Payers__r b),a.Year_gne__c, a.Weaknesses__c, a.Type__c, a.Threats__c, a.SystemModstamp, a.Strengths__c, a.Status__c, a.RecordTypeId, a.Public_gne__c, a.Profitability_Drivers_gne__c, 
        a.Product_gne__c, a.Percent_Complete_vod__c, a.Opportunities__c, 
        a.Name, a.MayEdit, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.Key_Pain_Points_gne__c, 
        a.Key_Corporate_Objectives_gne__c, a.IsLocked, a.IsDeleted, a.Id, a.GNE_Value_Proposition_gne__c, a.Description_vod__c, a.CreatedDate, 
        a.CreatedById, a.Classification_gne__c, a.Assessment_of_Need_gne__c, a.Account_vod__c  From 
        Account_Plan_vod__c a where ID = :AccPlanID];
        
        
        set<ID> AccGoalIDS_set = new set<ID>();
        
        //Populate set of Related Account Goal IDs 
        for(Account_Goal_and_Objective_gne__c g : plan.AccountGoal__r){
            AccGoalIDS_set.add(g.id);
        }
        
        //Retrieve related Account Goal and Related Strategy IDs
        /*List<Account_Goal_and_Objective_gne__c> AccGoals = [Select (Select ID from Account_Plan_Strategies__r), ID from Account_Goal_and_Objective_gne__c 
        where ID IN :AccGoalIDS_set];*/
                
        Map<ID,Account_Goal_and_Objective_gne__c> AccGoals_map = new Map<ID, Account_Goal_and_Objective_gne__c>([Select (Select ID from 
        Account_Plan_Strategies__r),  a.Type__c, a.SystemModstamp, a.RecordTypeId, a.OwnerId, a.Objective_gne__c,
        a.Name, a.MayEdit, a.LastModifiedDate, a.LastModifiedById, a.IsLocked, a.IsDeleted, a.Id, a.Goal_gne__c, a.CreatedDate, 
        a.CreatedById, a.Completed_gne__c, a.Account_Plan_gne__c from Account_Goal_and_Objective_gne__c a where a.ID IN :AccGoalIDS_set]);
        
        set<ID> AccStratIDs_set = new set<ID>();
        
        //Populate set of Related Account Plan Strategy IDs
        for(Account_Goal_and_Objective_gne__c g : accGoals_Map.values()){
            for(Account_Plan_Strategy_gne__c strat : g.Account_Plan_Strategies__r){
                AccStratIDs_set.add(strat.id);
            }   
        }
        
        //Retrieve related Account Strategies and related Tactic information
        Map<ID, Account_Plan_Strategy_gne__c> AccStrats_map = new Map<ID, Account_Plan_Strategy_gne__c>([Select (Select Type_vod__c, Tactic_r_gne__c, 
        Tactic_i_gne__c, Tactic_e_gne__c, Tactic_b_gne__c, Tactic_a_gne__c, SystemModstamp, Strategy_gne__c, Status_gne__c, Responsibility_gne__c,
        RecordTypeId, Product__c, Product_Tactic_vod__c, Product_Strategy_vod__c, Objective_gne__c, Name, MayEdit, LastModifiedDate, 
        LastModifiedById, IsLocked, IsDeleted, Id, Due_Date_gne__c, Description_vod__c, CreatedDate, CreatedById, Complete_vod__c, 
        Account_vod__c, Account_Plan_vod__c, Account_Plan_Strategy_gne__c from Account_Tactics__r), a.Tactics_r_gne__c, a.Tactics_i_gne__c, 
        a.Tactics_e_gne__c, a.Tactics_b_gne__c, a.Tactics_a_gne__c, a.SystemModstamp, a.Strategy_gne__c, a.RecordTypeId, a.Name, a.MayEdit, 
        a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.IsLocked, a.IsDeleted, a.Id, a.CreatedDate, a.CreatedById, a.Account_gne__c, 
        a.Account_Objective_gne__c from Account_Plan_Strategy_gne__c a where ID IN :AccStratIDs_set]);              
        
        /****************************Account Plan********************/
        
        //The Cloned Account Plan record
        Account_Plan_vod__c plan_clone = plan.clone(false);     
        plan_clone.name = plan_clone.Name+' (Copy)';
        
        try{
            insert(plan_clone);
        }catch(DmlException e){Status = e.getMessage(); System.debug(e.getMessage());}
        if(Status != 'SUCCESS'){ return Status;}
        
        System.debug('********ACCOUNT_PLAN_CLONE.ID:'+Plan_clone.ID);
        
        /****************************Account Plan Payer********************/
        List<Account_Plan_Payer_gne__c> payer_clones = new List<Account_Plan_Payer_gne__c>();
        if(!plan.Account_Plan_payers__r.isEmpty()){
            for(Account_Plan_Payer_gne__c app : plan.Account_Plan_Payers__r){
                Account_Plan_Payer_gne__c app_clone = app.clone(false);
                app_clone.Account_Plan_gne__c = Plan_clone.ID;
                payer_clones.add(app_clone);
            }   
        }
        
        try {
            insert(payer_clones);
        }catch(DmlException e){Status = e.getMessage(); System.debug(e.getMessage());}
        if(Status != 'SUCCESS'){return Status;}
        
        System.debug('**********ACCOUNT_PLAN_PAYER_CLONEs:'+payer_clones);        
        
        /****************************Account Goals & Objectives********************/
        
        //List to hold all goals with no strategies *CONSIDER CHANGING NAME IF WE DON'T NEED A LIST OF EMPTYGOALS BUT JUST ALL UNIQUE GOALS
        List<Account_Goal_and_Objective_gne__c> emptyGoals = new List<Account_Goal_and_Objective_gne__c>();
                
        
        //Map to contain Related Strategy ID's to there Cloned Account Goal record - There will be duplicate Goals for each related Strategy
        Map<ID,Account_Goal_and_Objective_gne__c> AccGoalsClones_map = new Map<ID,Account_Goal_and_Objective_gne__c>();
                
        for(Account_Goal_and_Objective_gne__c goal : accGoals_Map.values()){
            //Clone the current goal - while making sure the id is blanked out
            Account_Goal_and_Objective_gne__c goal_clone = goal.clone(false);                   
            goal_clone.Account_Plan_gne__c = plan_clone.ID;
            
            //MAY BE REDUDNANT
            emptyGoals.add(goal_clone); 
            
            //If there are related strategies for this goal iterate through all strategies and populate the AccGoalsClones_map
            //otherwise add the cloned goal to the emptyGoal list
            if(goal.Account_Plan_Strategies__r.size() > 0){             
                for(Account_Plan_Strategy_gne__c strat : goal.Account_Plan_Strategies__r){
                    if(!AccGoalsClones_Map.containsKey(strat.id)){
                        AccGoalsClones_Map.put(strat.id, goal_clone);
                    }
                }                               
            }                                   
        }
        
        try{
            insert(emptyGoals);
        }catch(DmlException e){Status = e.getMessage(); System.debug(e.getMessage());}
        if(Status != 'SUCCESS'){ return Status;}
        
        /****************************Account Strategy********************/
        
        //List to hold all goals with no strategies *CONSIDER CHANGING NAME IF WE DON'T NEED A LIST OF EMPTYGOALS BUT JUST ALL UNIQUE GOALS
        List<Account_Plan_Strategy_gne__c> strat_clones = new List<Account_Plan_Strategy_gne__c>();
                
        
        //Map to contain Related Strategy ID's to there Cloned Account Goal record - There will be duplicate Goals for each related Strategy
        Map<ID,Account_Plan_Strategy_gne__c> AccStratsClones_map = new Map<ID,Account_Plan_Strategy_gne__c>();
        
        for(Account_Plan_Strategy_gne__c strat : AccStrats_map.values()){
            Account_Plan_Strategy_gne__c strat_clone = strat.clone(false);          
            strat_clone.Account_Objective_gne__c = AccGoalsClones_Map.get(strat.id).ID;                     
            strat_clones.add(strat_clone);
            
            if(strat.Account_Tactics__r.size() > 0){                
                for(Account_Tactic_vod__c tactic : Strat.Account_Tactics__r){
                    if(!AccStratsClones_map.containsKey(tactic.id)){
                        AccStratsClones_map.put(tactic.id, strat_clone);
                    }
                }                               
            } 
        }
        
        try{
            insert(strat_clones);
        }catch(DmlException e){Status = e.getMessage(); System.debug(e.getMessage());}
        if(Status != 'SUCCESS'){ return Status;}
        
        /***************TACTIC CREATION*************/
        
        //List to hold all goals with no strategies *CONSIDER CHANGING NAME IF WE DON'T NEED A LIST OF EMPTYGOALS BUT JUST ALL UNIQUE GOALS
        List<Account_Tactic_vod__c> Tactic_clones = new List<Account_Tactic_vod__c>();
                                
        for(Account_Plan_Strategy_gne__c strat : AccStrats_map.values()){
            for(Account_Tactic_vod__c tactic : strat.Account_Tactics__r){
                Account_Tactic_vod__c tactic_clone = tactic.clone(false);               
                tactic_clone.Account_Plan_Strategy_gne__c = AccStratsClones_map.get(tactic.id).ID;
                tactic_clone.Account_Plan_vod__c = plan_clone.ID;
                tactic_clone.Objective_gne__c = AccStratsclones_map.get(tactic.id).Account_Objective_gne__c;                                
                tactic_clones.add(tactic_clone);
            }
        }           
        
        try{
            insert(tactic_clones);
        }catch(DmlException e){Status = e.getMessage(); System.debug(e.getMessage());}
        if(Status != 'SUCCESS'){ return Status;}
        
        
        /*************DEBUGS***********/
        System.debug('***ACCOUNT PLAN:'+plan);
        for(Account_Goal_and_Objective_gne__c goal : accGoals_Map.values()){
            System.debug('---> Related Goals:'+goal);
            for(Account_Plan_Strategy_gne__c strat : goal.Account_Plan_Strategies__r){
                System.debug('----> Related Strategies:'+strat);
                    Account_Plan_Strategy_gne__c strat_map = AccStrats_map.get(strat.id);                   
                    for(Account_Tactic_vod__c tactic : strat_map.Account_Tactics__r){
                        System.debug('----> Related Tactics:'+tactic);
                    }
            }           
        }
        //Appends the ID to the Status
        Status+=','+plan_clone.Id;
        return Status;                                              
    }       
}