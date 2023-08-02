public with sharing class GNE_SFA2_Account_Tactic_Edit_Ext {
    
    private String accountPlanId {get; set;}
    private String accountId {get; set;}
    private List<FRM_Account_Tactic_gne__c> frmAccountTactics {get; set;}
    public List<SelectOption> frmAccountTacticsSelectOptions {get; set;}
    public Account_Plan_vod__c accountPlan {get; set;}
    private String accountPlanTeam {get; set;}
    public Boolean isEdit {get; set;}
    public List<GNE_SFA2_MCCO_FRM_Account_TacticItem> accountTacticItems {get; set;}
    public Integer selectedTacticItemId {get; set;}
    //private Account_Tactic_vod__c accountTactic;
    public GNE_SFA2_Account_Tactic_Edit_Ext (ApexPages.standardController controller){
        Account_Tactic_vod__c accountTactic = (Account_Tactic_vod__c)controller.getRecord();
        System.debug('Account_Tactic_vod__c on entry: '+accountTactic);
        Integer intCount=[SELECT count() FROM Account_Tactic_vod__c WHERE Id = :accountTactic.Id];
        if(accountTactic != null && intCount>0)
        {        
            accountTacticItems = new List<GNE_SFA2_MCCO_FRM_Account_TacticItem>();
            accountTactic = [SELECT
                     Id,
                     Name,
                     Account_vod__c,
                     Account_Plan_vod__c,
                     Frequency_gne__c,
                     Tactic_a_gne__c,
                     Tactic_b_gne__c,
                     Tactic_e_gne__c,
                     Tactic_i_gne__c,
                     Tactic_r_gne__c
              FROM
                  Account_Tactic_vod__c
              WHERE
                  Id = :accountTactic.Id];

              accountPlanId = accountTactic.Account_Plan_vod__c;
              accountId = accountTactic.Account_vod__c;
              addTacticItem(accountTactic); // create Tactic Item with existing Account_Tactic_vod__c record
              System.debug('Account_Tactic_vod__c after select: '+accountTactic);
          }              
    
    // query Account_Plan
        frmAccountTactics = new List<FRM_Account_Tactic_gne__c>();
        if(accountPlanId != null){
            accountPlan = [SELECT Id, Segment_gne__c, Team_gne__c FROM Account_Plan_vod__c where Id = :accountPlanId];
            System.debug('accountPlan: '+accountPlan);
            
            String accountPlanTeam = accountPlan.Team_gne__c;
            // query FRM_Account_Tactics    
            if(accountPlan.Segment_gne__c == null || accountPlan.Segment_gne__c == ''){
              frmAccountTactics = [SELECT Id,
                            FRM_Group_gne__c,
                            Value_gne__c,
                            Frequency_gne__c,
                            Segment_gne__c
                        FROM FRM_Account_Tactic_gne__c
                        WHERE FRM_Group_gne__c = :accountPlanTeam];
            } else {
              frmAccountTactics = [SELECT Id,
                            FRM_Group_gne__c,
                            Value_gne__c,
                            Frequency_gne__c,
                            Segment_gne__c
                        FROM FRM_Account_Tactic_gne__c
                        WHERE FRM_Group_gne__c = :accountPlanTeam
                        AND Segment_gne__c = :accountPlan.Segment_gne__c];
            }
        }
        
        
    // create select options
    frmAccountTacticsSelectOptions = new List<SelectOption>();
        frmAccountTacticsSelectOptions.add(new SelectOption('','--None--'));
        for(FRM_Account_Tactic_gne__c frmAccountTactic : frmAccountTactics){
            frmAccountTacticsSelectOptions.add(new SelectOption(frmAccountTactic.Id, frmAccountTactic.Value_gne__c));
        }
    }
    
    public PageReference cancel() {
        //Cancel and back to account plan 
        PageReference pageRef = new PageReference('/'+accountPlanId);
        system.debug('accountPlanId: '+accountPlanId);
        return pageRef;
    }
    
    public PageReference save() {
        PageReference pageRef = new PageReference('/'+accountPlanId);
        
        List <Account_Tactic_vod__c> accountTacticsForUpsert = new List<Account_Tactic_vod__c>();
        
        for (GNE_SFA2_MCCO_FRM_Account_TacticItem tacticItem : accountTacticItems) {
          String frmAccountTacticId = tacticItem.value;
          Account_Tactic_vod__c accountTactic = tacticItem.accountTactic;
          
          System.debug('frequency: '+accountTactic.Frequency_gne__c);
          System.debug('name: '+accountTactic.Name);
          System.debug('accountTactic: '+accountTactic);
          System.debug('frmAccountTacticId: '+frmAccountTacticId);
          
          //accountTactic.Name = 'to be removed - test only!';
          if(frmAccountTacticId == null){
	        String message = 'Please provide Tactic for all elements.';
	        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,message));
	        return null;  
	      } else {
	        for(FRM_Account_Tactic_gne__c frmAccountTactic : frmAccountTactics){
	          if(frmAccountTactic.Id == frmAccountTacticId){
	            accountTactic.Name = frmAccountTactic.Value_gne__c;
	            accountTactic.Frequency_gne__c = frmAccountTactic.Frequency_gne__c;
	          }
	        }
	      }
  
  		  String teamChar = String.isNotBlank(accountPlanTeam) ? String.valueOf(accountPlanTeam.charAt(0)).toLowerCase() : null;
        		
          if(String.isNotBlank(teamChar) && accountPlanTeam.endsWith('FRM')) {
        	accountTactic.put('Team_' + teamChar + '_gne__c', accountTactic.Name);
          }

          accountTacticsForUpsert.add(accountTactic);
        } 
        
        
        upsert accountTacticsForUpsert;
        
        return pageRef;
    }
    
    public void addTactic() {
      addTacticItem(null);
    }
    
    public void removeTactic() {
      if (selectedTacticItemId==null) return;
      accountTacticItems.remove(selectedTacticItemId);
      
      // Update position index for all tactic items which were placed after removed item. 
      for (Integer i = selectedTacticItemId;i<accountTacticItems.size();i++) {
        accountTacticItems[i].id -= 1;
      }
    }
    
    private void addTacticItem(Account_Tactic_vod__c accountTactic) {
      if(accountTactic==null) // if not set, create new object with current accountPlan and Account.
        accountTactic = new Account_Tactic_vod__c(
                    Frequency_gne__c = null,
                      Account_Plan_vod__c = accountPlanId,
                      Account_vod__c = accountId);
    
      accountTacticItems.add(new GNE_SFA2_MCCO_FRM_Account_TacticItem(
                        accountTacticItems.size(),null,accountTactic));
    }
    
    // Wrapper class for Account_Tactic_vod__c record. Holds also information about:
    // - selected FRM_Account_Tactic_gne__c dictionary record,
    // - position index in controller's Tactic Items List.
    public class GNE_SFA2_MCCO_FRM_Account_TacticItem {
      public String value {get; set;} // Id of FRM_Account_Tactic_gne__c record
      public Integer id {get; set;} // position index in controller's items list  
      public Account_Tactic_vod__c accountTactic {get; set;} // new or existing Account_Tactic_vod__c record
      
      public GNE_SFA2_MCCO_FRM_Account_TacticItem(Integer newId, String newValue, 
                  Account_Tactic_vod__c newAccountTactic) {
        value = newValue;
        id = newId;
        accountTactic = newAccountTactic;
      }
    }
}