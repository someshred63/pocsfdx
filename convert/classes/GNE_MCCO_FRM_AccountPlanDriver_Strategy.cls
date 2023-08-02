public with sharing class GNE_MCCO_FRM_AccountPlanDriver_Strategy {
    
    public String stratId {get; set;}
    public String objId {get; set;}
    public String stratName {get; set;}
    public Account_Plan_Strategy_gne__c actStrat {get; set;}
    public List<Strategy_obj> strat_list = new List<Strategy_obj>();
//    public List<Account_Tactic_vod__c> actTact_list {get; set;}
    public List<Strategy_obj> actTact_list {get; set;}
    public Boolean createCase {get; set;}
    public Account_Goal_and_Objective_gne__c ago {get; set;}
    public String tacId {get; set;}
    public String tacId2 {get; set;}
    
    List<Account_Tactic_vod__c> del_list = new List<Account_Tactic_vod__c>();
    //List<Strategy_obj> del_list = new List<Strategy_obj>();

    public GNE_MCCO_FRM_AccountPlanDriver_Strategy (ApexPages.standardController controller){
        
        //Grab parameters from URL
        stratId = ApexPages.currentPage().getParameters().get('stratId');
        objId = ApexPages.currentPage().getParameters().get('obj_id');
        system.debug('stratId: '+stratId);
        //Initialize Structures
        actStrat = new Account_Plan_Strategy_gne__c();
//        actTact_list = new List<Account_Tactic_vod__c>();
            actTact_list = new List<Strategy_obj>();
        //If we are in modify case...
        if (stratId != null && stratId != ''){
            createCase = false;
            
            
            actStrat = [select id,
                        Account_Objective_gne__c,
                        Strategy_gne__c,
                        Account_gne__c
                        from Account_Plan_Strategy_gne__c
                        where id=:stratId];
                        
            List<Account_Tactic_vod__c> accountTactics = [select id,
                            Name,
                            Account_vod__c,
                            Objective_gne__c,
                            Account_Plan_Strategy_gne__c,
                            Status_gne__c,
                            Due_Date_gne__c,
                            Responsibility_gne__c,
                            Tactic_a_gne__c,
                            Tactic_b_gne__c,
                            Tactic_e_gne__c,
                            Tactic_i_gne__c,
                            Tactic_r_gne__c
                            from Account_Tactic_vod__c
                            where Account_Plan_Strategy_gne__c =:stratId];
            
            for(Account_Tactic_vod__c a : accountTactics){               
                strategy_obj obj = new strategy_obj();
                obj.ID = this.generateHash();
                obj.tact = a;
                actTact_list.add(obj);
            }                          
            
        }
        else {
            //We are in NEW Case
            createCase = true;
            if (objId != null && objId != '' )
            ago = [select Account_Plan_gne__r.Account_vod__c from Account_Goal_and_Objective_gne__c where id=:objId];
            
                
                
        }
    }
    
    public PageReference cancel() {
        //Cancel all actions 
        PageReference pageRef = new PageReference('/'+objId);
        system.debug('IDOBJ: '+objId);
        //pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference addTactic() {
                system.debug('Tactic1: '+actTact_list);
        //Add a Tactic to the Display
        Account_Tactic_vod__c tac = new Account_Tactic_vod__c();
        if (createCase) {
            tac.Account_vod__c = Ago.Account_Plan_gne__r.Account_vod__c;

        }
        else {
            tac.Account_vod__c = actStrat.Account_gne__c;
            tac.Account_Plan_Strategy_gne__c = stratId; 
        }
        
        strategy_obj sObj = new strategy_obj();
        sObj.ID = this.generateHash();
        sObj.tact = tac;
//        actTact_list.add(tac);
        actTact_list.add(sObj);
        
        return null;
        
    }
    public PageReference saveAll() {
        
        String userProf = [select Name from Profile where id=:Userinfo.getProfileId()].Name; 
        
        system.debug('Tactic2: '+objId);
        
        if (actStrat.Account_Objective_gne__c == null)
        actStrat.Account_Objective_gne__c = objId;
        
        
        system.debug('STRAT: '+actStrat);
        upsert  actStrat;
        
        for (Integer i=0; i<actTact_list.size();i++) {
            
            if (userProf.contains('AFRM') || userProf.contains('system'))
            actTact_list[i].tact.name = actTact_list[i].tact.Tactic_a_gne__c;
            else if (userProf.contains('BFRM'))
            actTact_list[i].tact.name = actTact_list[i].tact.Tactic_b_gne__c;
            else if (userProf.contains('EFRM'))
            actTact_list[i].tact.name = actTact_list[i].tact.Tactic_e_gne__c;
            else if (userProf.contains('IFRM'))
            actTact_list[i].tact.name = actTact_list[i].tact.Tactic_i_gne__c;
            else if (userProf.contains('RFRM'))
            actTact_list[i].tact.name = actTact_list[i].tact.Tactic_r_gne__c;
            
            
                                                
            if (actTact_list[i].tact.Account_Plan_Strategy_gne__c == null)
            actTact_list[i].tact.Account_Plan_Strategy_gne__c = actStrat.Id;
        }
        
        
        system.debug('TAC LIST: '+actTact_list);
        
        List<Account_Tactic_vod__c> tactics = new List<Account_Tactic_vod__c>();
        for(Strategy_Obj sobj : actTact_list){
            tactics.add(sObj.tact);
        }
        
//        upsert actTact_list;
        upsert tactics;
        
        
        //Perform Deletions if necessary 
        if (del_list.size() >0)
        delete del_list;
        
        PageReference pageRef = new PageReference('/'+objId);
        system.debug('IDOBJ: '+objId);
        //pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference delTac() {
        
        system.debug('tacId: '+tacId);
        system.debug('tacId34234: '+actTact_list);
        for (Integer i=0; i<actTact_list.size(); i++){
            //system.debug('**tacID:'+tacID);
            //system.debug('**tacID.size():'+tacID.length());
            //system.debug('**actTact:'+actTact_list[i].Id);
                        
            //if (actTact_list[i].tact.Id == tacId){
            system.debug('****IDS:'+actTact_list[i].ID+' + ' +tacID);
            if (actTact_list[i].Id == tacId){                
                if(actTact_list[i].tact.id != null){
                    system.debug('****inner');
                    del_list.add(actTact_list[i].tact);              
                }
                actTact_list.remove(i);
                system.debug('REMOVED, NEW LIST:'+actTact_list);
            }            
        }
                        
        //delete [select id  from Account_Tactic_vod__c where id=:tacId];
         
        PageReference pageRef = ApexPages.currentPage();
        //pageRef.setRedirect(true);      
        System.debug('***here');
//        return pageRef;
        return null;
        
    }
    
    
    public string generateHash() {
        string chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz';
        integer stringLength = 8;
        string hash = '';
        for (integer i = 0; i < stringLength; i++) {
            integer rnum = Math.floor(Math.random() * chars.length()).intValue();
            hash += chars.substring(rnum,rnum+1);
        }
        return hash;
    }        
   
   public class strategy_obj {
       public String ID {get; set;}
       public Account_Tactic_vod__c tact {get; set;}
   }    
}