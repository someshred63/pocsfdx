public with sharing class GNE_MCCO_FRM_AccountPlanDriver_Objective {
	
	public Account_Plan_Strategy_gne__c strat_display {get; set;}
	public List<Account_Tactic_vod__c> actTactics {get; set;}
	public List<Strategy_x> m_list {get; set;}
	public Strategy_x m_2 {get; set;}
	public Boolean addCase {get; set;}
	public Boolean step2 {get; set;}
	public String ObjectiveId{get; set;}
	public String AccountId {get; set;}
	public String stratId_del {get; set;}
	
	//Used for Edit Display
	public Strategy_x m_3 {get; set;}
	public String stratId {get; set;}
	
	public GNE_MCCO_FRM_AccountPlanDriver_Objective (ApexPages.Standardcontroller controller) {
        strat_display = new Account_Plan_Strategy_gne__c();
        addCase = false;
        step2 = false;
        m_list = new List<Strategy_x>();
      	ObjectiveId = ApexPages.currentPage().getParameters().get('id');
        
        
        Map<Id, Account_Plan_Strategy_gne__c> actStrat_map = new Map<Id, Account_Plan_Strategy_gne__c>([select id,
        																								Account_Objective_gne__c,
        																								Strategy_gne__c,
        																								Account_gne__c
        																								from Account_Plan_Strategy_gne__c
        																								where Account_Objective_gne__c=:objectiveId]);
     	
     	//Quick and Dirty: Set AccountId
     	//AccountId = actStrat_map.values()[0].Account_gne__c;
     	
     	Map<Id, Account_Tactic_vod__c> actTactic_map = new Map<Id, Account_Tactic_vod__c>([select id,
       																				   	   Name,
       																				   	   Account_vod__c,
       																				   	   Objective_gne__c,
       																				  	   Account_Plan_Strategy_gne__c,
       																				  	   Status_gne__c,
       																				  	   Due_Date_gne__c,
       																				  	   Responsibility_gne__c,
       																				  	   LastModifiedDate
       																				   	   from Account_Tactic_vod__c
       																				   	   where Account_Plan_Strategy_gne__c in:actStrat_map.keySet() order by lastModifiedDate]);																								
        
    	for (Account_Plan_Strategy_gne__c s_x : actStrat_map.values()) {        		      			        	
        		Strategy_x strat = new Strategy_x();
        		strat.accountStrat = s_x;
        		strat.tactic_list = new List<Account_Tactic_vod__c>();
        			        			
        		for (Account_Tactic_vod__c at_x : actTactic_map.values()) {
        			if (at_x.Account_Plan_Strategy_gne__c == s_x.Id){
	        			strat.tactic_List.add(at_x);
        			}
        		}
        	m_list.add(strat);
    	}        																
	
	}


	public class Strategy_x {
		
		public Account_Plan_Strategy_gne__c accountStrat{get; set;}
		public List<Account_Tactic_vod__c> tactic_list {get; set;} 
	}
	
	public PageReference new_strat() {
		
		PageReference pageRef = new PageReference('/apex/GNE_MCCO_FRM_AccountPlanPage_Strategy?&obj_id='+ObjectiveId);
		
		return pageRef;		
	}
	public PageReference delStrat() {
		
		Account_Plan_Strategy_gne__c del_Strat = new Account_Plan_Strategy_gne__c(id=stratId_del);
		delete del_strat;
		
		delete [select id from Account_Tactic_vod__c where Account_Plan_Strategy_gne__c=:del_Strat.Id];
		
		PageReference pageRef = ApexPages.currentPage();
		pageRef.setRedirect(true);		

		return pageRef;
		
	}
//Derilict - this code was moved to another controller
/*
	public PageReference addStrat () {
		
		addCase = true;		
		PageReference pageRef = ApexPages.currentPage();
		
		return pageRef;
	}
	
	public PageReference cancel() {
		addCase=false;
		step2=false;
		PageReference pageRef = ApexPages.currentPage();
		return pageRef;
	}
		
	public PageReference next() {
		m_2 = new Strategy_x();
		m_2.accountStrat = new Account_Plan_Strategy_gne__c();
		m_2.accountStrat.Strategy_gne__c = strat_display.Strategy_gne__c;
				
		List<String> tacticNames = new List<String>();
		system.debug('TACTICS INCOMING: '+strat_display.Tactics_a_gne__c);
		if (strat_display.Tactics_a_gne__c != null && strat_display.Tactics_a_gne__c !='') {
			system.debug('I made it');
			tacticNames.addall(strat_display.Tactics_a_gne__c.split(';'));
			system.debug('LIst: '+tacticNames);			
		}
		else if (strat_display.Tactics_b_gne__c != null && strat_display.Tactics_a_gne__c !='') {
			tacticNames.addall(strat_display.Tactics_b_gne__c.split(';'));	
		}
		else if (strat_display.Tactics_e_gne__c != null && strat_display.Tactics_a_gne__c !='') {
			tacticNames.addall(strat_display.Tactics_e_gne__c.split(';'));	
		}
		else if (strat_display.Tactics_i_gne__c != null && strat_display.Tactics_a_gne__c !='') {
			tacticNames.addall(strat_display.Tactics_i_gne__c.split(';'));	
		}
		else if (strat_display.Tactics_r_gne__c != null && strat_display.Tactics_a_gne__c !='') {
			tacticNames.addall(strat_display.Tactics_r_gne__c.split(';'));	
		}				
		else 
		  return null;
		 
		 m_2.tactic_list = new List<Account_Tactic_vod__c>(); 
		 for (String s : tacticNames) {
		 	Account_Tactic_vod__c tac = new Account_Tactic_vod__c();
		 	tac.Name = s;
		 	tac.Account_vod__c = AccountId;
		 	m_2.tactic_list.add(tac);
		 }
		 
		system.debug('m_2: '+m_2);
		PageReference pageRef = ApexPages.currentPage();
		step2 = true;
		return null;
	}	
		
	public PageReference save() {
		m_2.accountStrat.Account_Objective_gne__c= ObjectiveId;
		
		insert m_2.accountStrat;
		
		for (integer i=0;i<m_2.tactic_list.size();i++) {		
			m_2.tactic_list[i].Account_Plan_Strategy_gne__c = m_2.accountStrat.Id;
		}
		
		insert m_2.tactic_list;
		addCase=false;
		step2=false;
		PageReference pageRef = ApexPages.currentPage();
		pageRef.setRedirect(true);
		return pageRef;
		
	}	
	
	public PageReference edit_Main() {
	
		m_3.accountStrat = new Account_Plan_Strategy_gne__c ();
		m_3.accountStrat = [select Id, Name, Strategy_gne__c from Account_Plan_Strategy_gne__c where id=:stratId];
		
		m_3.tactic_list = new List<Account_Tactic_vod__c>([select id, Name, Status_gne__c, Due_Date_gne__c, Responsibility_gne__c from Account_Tactic_vod__c where Account_Plan_Strategy_gne__c =:stratId]);
		
		
		
		PageReference pageRef = ApexPages.currentPage();
		//pageRef.setRedirect(true);
		return pageRef;
	}	
		
		
		
		*/

		
		
	
}