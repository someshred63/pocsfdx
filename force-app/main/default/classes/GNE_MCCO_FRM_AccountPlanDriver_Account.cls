public with sharing class GNE_MCCO_FRM_AccountPlanDriver_Account {
    
    //Account Plan Id
    public String AccountPlanId {get; set;}
    //List to Return to page
    public List<Objective_x> m_list = new List<Objective_x>();
    //OBJ to delete
    public String objId_del {get; set;}
    //Account Plan Name    
    public String AccountPlanName {get; set;}
    
    public GNE_MCCO_FRM_AccountPlanDriver_Account (ApexPages.StandardController controller){
        this.AccountPlanId  = [select ID,Name from Account_Plan_vod__c where ID = :controller.getID()].ID;              
        this.AccountPlanName = [select ID,Name from Account_Plan_vod__c where ID = :controller.getID()].Name;              
        
        Map<Id, Account_Goal_and_Objective_gne__c> actGO_map = new Map<Id, Account_Goal_and_Objective_gne__c> ([select id,
                                                                                                                Objective_gne__c
                                                                                                                from Account_Goal_and_Objective_gne__c
                                                                                                                where Account_Plan_gne__c=:AccountPlanId]);
        
        Map<Id, Account_Plan_Strategy_gne__c> actStrat_map = new Map<Id, Account_Plan_Strategy_gne__c>([select id,
                                                                                                        Account_Objective_gne__c,
                                                                                                        Strategy_gne__c
                                                                                                        from Account_Plan_Strategy_gne__c
                                                                                                        where Account_Objective_gne__c in:actGO_map.keySet()]);
       
        Map<Id, Account_Tactic_vod__c> actTactic_map = new Map<Id, Account_Tactic_vod__c>([select id,
                                                                                           Name,
                                                                                           Account_vod__c,
                                                                                           Objective_gne__c,
                                                                                           Account_Plan_Strategy_gne__c,
                                                                                           Status_gne__c,
                                                                                           Due_Date_gne__c,
                                                                                           Responsibility_gne__c
                                                                                           from Account_Tactic_vod__c
                                                                                           where Account_Plan_Strategy_gne__c in:actStrat_map.keySet()]);                                                                                               
                                                                    
        
        for (Account_Goal_and_Objective_gne__c a_x : actGO_map.values()) {                      
            Objective_x obj = new Objective_x();
            obj.accountObj = a_x;           
            obj.strat_list = new List<Strategy_x>();
            
            for (Account_Plan_Strategy_gne__c s_x : actStrat_map.values()) {                                
                 if(s_x.Account_Objective_gne__c == a_x.Id){                
                    Strategy_x strat = new Strategy_x();
                    strat.accountStrat = s_x;
                    strat.tactic_list = new List<Account_Tactic_vod__c>();
                                            
                    for (Account_Tactic_vod__c at_x : actTactic_map.values()) {
                        if (at_x.Account_Plan_Strategy_gne__c == s_x.Id){
                            strat.tactic_List.add(at_x);
                        }
                    }
                        
                    obj.Strat_list.add(strat);
                 }
            }
            m_list.add(obj);
        }
        
        
        
    }        
    
    public class Objective_x {

        public Account_Goal_and_Objective_gne__c accountObj {get; set;}
        public List<Strategy_x> strat_list {get; set;}
    }
    
    public class Strategy_x {
        
        public Account_Plan_Strategy_gne__c accountStrat{get; set;}
        public List<Account_Tactic_vod__c> tactic_list {get; set;} 
    }
    
    public List<Objective_x> getOBjectives () {
        return m_list;
    }
    
    public PageReference delObj () {
        
        Account_Goal_and_Objective_gne__c obj_x = new Account_Goal_and_Objective_gne__c(id=objId_del);
        List<Account_Plan_Strategy_gne__c> strats_x = new List<Account_Plan_Strategy_gne__c>();
        List<Account_Tactic_vod__c> tacs_x = new List<Account_Tactic_vod__c>();
        strats_x = [select id, (select id from Account_Tactics__r) from Account_Plan_Strategy_gne__c where Account_Objective_gne__c=:obj_x.Id];
        
        for (Account_Plan_Strategy_gne__c a_s : strats_x) {
            tacs_x.addall(a_s.Account_Tactics__r);
        }
        
        system.debug('Tactics for deletion: '+tacs_x.size());
        
        //Perform Deletes
        if (tacs_x.size() > 0)
        delete tacs_x;
        
        delete obj_x;
        
        
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);      

        return pageRef;
    }
}