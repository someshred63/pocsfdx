public with sharing class GNE_MCCO_Account_Plan_Tab_ctrlr_gne extends CMT_PaginationBase{              
   
   public String accPlanID {get; set;}         
   public List<Account_Plan_vod__c> accPlans {get; set;}         
   public List<Account_Plan_vod__c> limitedAccPlans {get;set;}   
   private ID userID = userinfo.getUserID();   
   private set<ID> users = new set<ID>();   
   private set<ID> redirectProfileIDs = new set<ID>();
   private Map<ID, List<ID>> usr_to_terr = new Map<ID, List<ID>>();
   private Map<ID,List<ID>> terr_to_groups = new Map<ID, List<ID>>();
   private Map<ID, set<ID>> groups_to_userAcc_map = new Map<ID, set<ID>>();
   private List<ID> accountIDs = new List<ID>();      
   private String groupName;
   public List<SelectOption> frmAccountTeamsSelectOptions {get; set;}
   public String frmAccountTeamFilter {get; set;}
   
   public Integer part {get; set;}
   public Boolean firstPage {get; set;}
   public Boolean lastPage {get; set;}
   private static final Integer CHUNK_SIZE = 100;
   
   public GNE_MCCO_Account_Plan_Tab_ctrlr_gne(){    
     init();  
     frmAccountTeamFilter = 'AFRM';             
     //retrieveUsers();
     accPlans = retrieveAccPlans();
     Boolean isNext = false;
     part=0;
     firstPage = true;
     lastPage = false;
     limitedAccPlans = retrieveFirstPart(accPlans);                
   }           
   
   //Initializes all vars
   private void init(){     
     //this.plans = new ApexPages.StandardSetController(this.accPlans);  
     set<ID> tempSet = new set<ID>();
       tempSet.add(userID);

       usr_to_terr =  EM3_Calendar_util.usr_to_terr(tempSet);
	   terr_to_groups = EM3_Calendar_util.terr_to_groups();
       groups_to_userAcc_map = EM3_Calendar_util.groups_to_userAcc_map();
       for(set<ID> idSet : groups_to_userAcc_map.values()){
         for(ID accID : idSet){
           accountIDs.add(accID);
         }
       }
     // create select options
     frmAccountTeamsSelectOptions = new List<SelectOption>();
        frmAccountTeamsSelectOptions.add(new SelectOption('AFRM','AFRM'));
        frmAccountTeamsSelectOptions.add(new SelectOption('BFRM','BFRM'));
        frmAccountTeamsSelectOptions.add(new SelectOption('EFRM','EFRM'));
        frmAccountTeamsSelectOptions.add(new SelectOption('IFRM','IFRM'));
        frmAccountTeamsSelectOptions.add(new SelectOption('RFRM','RFRM'));             
   }

   
  /* public PageReference toRedirect(){
     set<String> profilesForRedirection = new set<String>();
     profilesForRedirection.add('GNE-MCCO-FRM-OPS');
     profilesForRedirection.add('GNE-MCCO-PFT-OPS');
     profilesForRedirection.add('GNE-SYS-AutomatedJob');
     profilesForRedirection.add('GNE-SYS-DataSupport');
     profilesForRedirection.add('GNE-SYS-No-Access');
     profilesForRedirection.add('GNE-SYS-ReadOnly');
     profilesForRedirection.add('GNE-SYS-Restricted Sys Admin');
     profilesForRedirection.add('GNE-SYS-SFDC-Premium-Support');
     profilesForRedirection.add('GNE-SYS-SOIM');
     profilesForRedirection.add('GNE-SYS-SOIM-nonSSO');
     profilesForRedirection.add('GNE-SYS-SpringCM');
     profilesForRedirection.add('GNE-SYS-Support');
     profilesForRedirection.add('GNE-SYS-Support-Offshore');
     profilesForRedirection.add('GNE-SYS-Support-UserRPT');
     profilesForRedirection.add('GNE-SYS-UserMgr');
     profilesForRedirection.add('System Administrator');
     
     set<ID> profileIDs = new set<ID>();
     for( Profile p : [Select ID from Profile where Name IN :profilesForRedirection]){
       profileIDs.add(p.ID);
     }
          
     if(profileIDs.contains(Userinfo.getProfileID())){       
       Schema.Describesobjectresult result = Schema.Sobjecttype.Account_Plan_vod__c;          
       PageReference newpage = new PageReference('/'+result.getKeyPrefix()+'/o');     
        newpage.setRedirect(true);
        system.debug('***NewPage:'+newPage);
        return newpage;  
     }else return null;     
   }*/
   
   /*private void retrieveUsers(){
     List<User_Hierarchy_gne__c> hierarchy = [
       select User_Id_frm_gne__c, Level7_UserId_gne__c, Level6_UserId_gne__c, Level5_UserId_gne__c, 
       Level4_UserId_gne__c, Level3_UserId_gne__c, Level2_UserId_gne__c, Level1_UserId_gne__c 
       From User_Hierarchy_gne__c where (Level7_UserID_gne__c = :userID) OR
       (Level6_UserID_gne__c = :userID) OR (Level5_UserID_gne__c = :userID) OR 
       (Level4_UserID_gne__c = :userID) OR (Level3_UserID_gne__c = :userID) OR
       (Level2_UserID_gne__c = :userID) OR (Level1_UserID_gne__c = :userID) 
     ];
     
     if(hierarchy.isEmpty()){system.debug('***isEmpty()');this.users.add(this.userID);}else{            
       for(User_Hierarchy_gne__c uh : hierarchy){
         this.users.add(uh.User_Id_frm_gne__c);
       }
     }
     system.debug('***Hierarchy:'+hierarchy+'\t***Users:'+this.users);
   }*/
   
   public PageReference NewB(){
       Schema.Describesobjectresult result = Schema.Sobjecttype.Account_Plan_vod__c;
       PageReference newpage = new PageReference('/'+result.getKeyPrefix()+'/e');     
        newpage.setRedirect(true);
        system.debug('***NewPage:'+newPage);
        return newpage;
   }
   
   //Retrieves all account plans
   private List<Account_Plan_vod__c> retrieveAccPlans(){
     List<Account_Plan_vod__c>accPlansTMP = new List<Account_Plan_vod__c>();          
     /*this.accPlans = [select ID, Name, CreatedByID, LastModifiedDate, Account_vod__r.Name, Segment_gne__c, Team_gne__c
     from Account_Plan_vod__c where ((CreatedByID IN :this.users) OR 
     (LastModifiedByID IN :this.users)) AND Account_vod__c IN :accountIDs order by LastModifiedDate Desc Limit 1000];*/
     String profileName = [select Name from Profile where id=:Userinfo.getProfileId()].Name;
        if (profileName.contains('AFRM')){
            groupName = 'AFRM';
			if(profileName.contains('AFRM-Manager')){
				groupName = 'AFRM-Manager';
				frmAccountTeamFilter = 'AFRM';
			}
        } else if (profileName.contains('BFRM')){
          groupName = 'BFRM';
		  if(profileName.contains('BFRM-Manager')){
				groupName = 'BFRM-Manager';
				frmAccountTeamFilter = 'BFRM';
			}
        } else if (profileName.contains('EFRM')){
          groupName = 'EFRM';
		  if(profileName.contains('EFRM-Manager')){
				groupName = 'EFRM-Manager';
				frmAccountTeamFilter = 'EFRM';
			}
        } else if (profileName.contains('IFRM')) {
          groupName = 'IFRM';
		  if(profileName.contains('IFRM-Manager')){
				groupName = 'IFRM-Manager';
				frmAccountTeamFilter = 'IFRM';
			}
        } else if (profileName.contains('RFRM')){
          groupName = 'RFRM';
		  if(profileName.contains('RFRM-Manager')){
				groupName = 'RFRM-Manager';
				frmAccountTeamFilter = 'RFRM';
			}
        } else {
          groupName = 'ADMIN';
        }
        System.debug('groupName: '+groupName);
        System.debug('frmAccountTeamFilter: '+frmAccountTeamFilter );
     	System.debug('account ids: '+accountIDs);
     if(groupName == 'ADMIN'){
       accPlansTMP = [select ID, Name, CreatedByID, LastModifiedDate, Account_vod__r.Name, Segment_gne__c, Team_gne__c
               from Account_Plan_vod__c where Team_gne__c = :frmAccountTeamFilter order by LastModifiedDate Desc];
     } else if(groupName == 'AFRM-Manager' || groupName == 'BFRM-Manager' || groupName == 'EFRM-Manager' || groupName == 'IFRM-Manager' || groupName == 'RFRM-Manager'){
		accPlansTMP = [select ID, Name, CreatedByID, LastModifiedDate, Account_vod__r.Name, Segment_gne__c, Team_gne__c
               from Account_Plan_vod__c where Team_gne__c = :frmAccountTeamFilter order by LastModifiedDate Desc];
	 }else{
       accPlansTMP = [select ID, Name, CreatedByID, LastModifiedDate, Account_vod__r.Name, Segment_gne__c, Team_gne__c
               from Account_Plan_vod__c where Account_vod__c IN :accountIDs and Team_gne__c = :groupName order by LastModifiedDate Desc];
     }
     return accPlansTMP;                          
   }
   
   private List<Account_Plan_vod__c> retrieveFirstPart(List<Account_Plan_vod__c> tmpPlans) {
   Integer allSize = tmpPlans.size();
   limitedAccPlans = new List<Account_Plan_vod__c>();
   
   if(allSize >= 100) {
        for(Integer i=0; i<100; i++) {
            limitedAccPlans.add(tmpPlans[i]);  
        }
   } else {                     // all records fit in one page
        for(Integer i=0; i<allSize; i++) {
            limitedAccPlans.add(tmpPlans[i]);  
        }
        firstPage = true;
        lastPage = true;
   }
    part += CHUNK_SIZE;

    return limitedAccPlans;
   }
   
   private List<Account_Plan_vod__c> retrieveNextPart(List<Account_Plan_vod__c> tmpPlans, Integer amount) {
   Integer allSize = tmpPlans.size();
     limitedAccPlans = new List<Account_Plan_vod__c>();
       if(allSize < amount + CHUNK_SIZE)
       {
         for(Integer i=amount; i<allSize; i++)
         {
           limitedAccPlans.add(tmpPlans[i]);  
         }
         lastPage = true;
       }
       else
       {
         for(Integer i=amount; i<=amount+100; i++)
         {
           limitedAccPlans.add(tmpPlans[i]);
         }
         part += CHUNK_SIZE;
         lastPage = false;
       }
       
       firstPage = false;
       return limitedAccPlans;
   }
   
   private List<Account_Plan_vod__c> retrievePreviousPart(List<Account_Plan_vod__c> tmpPlans, Integer amount) {
   Integer allSize = tmpPlans.size();
     limitedAccPlans = new List<Account_Plan_vod__c>();
       if(amount > 200)
       {
        for(Integer i=amount-200; i<=amount-CHUNK_SIZE; i++)
        {
          limitedAccPlans.add(tmpPlans[i]);
        }
        part -= CHUNK_SIZE;
        firstPage = false;
       }
       else
       {
         for(Integer i=0; i<=CHUNK_SIZE; i++)
         {
           limitedAccPlans.add(tmpPlans[i]);  
         }
         part -= CHUNK_SIZE;
         firstPage = true;
       }
       lastPage = false;
       
       return limitedAccPlans;
   }
   
   public PageReference nextPart()
   {  
     limitedAccPlans = retrieveNextPart(accPlans, part);
     return null;
   }
   
   public PageReference previousPart()
   {
     limitedAccPlans = retrievePreviousPart(accPlans, part);
     return null;
   }
   
   public PageReference viewAP(){
     PageReference newpage = new PageReference('/'+this.accPlanID);
      newpage.setRedirect(true);
      return newpage;  
   }
   
   public PageReference changeTeam(){
     init();               
     //retrieveUsers();
     accPlans = retrieveAccPlans();
     Boolean isNext = false;
     part=0;
     firstPage = true;
     lastPage = false;   
     limitedAccPlans = retrieveFirstPart(accPlans); 
     return null;
   }
   
}