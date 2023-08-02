public with sharing class GNE_SFA2_Account_Plan_List_Controller extends CMT_PaginationBase{              

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
	private SFA2_Configuration_Object_gne__c pageConfiguration;

	public GNE_SFA2_Account_Plan_List_Controller(){
		init();  
		frmAccountTeamFilter = frmAccountTeamsSelectOptions[0].getValue();             
		accPlans = retrieveAccPlans();
		Boolean isNext = false;
		part=0;
		firstPage = true;
		lastPage = false;
		limitedAccPlans = retrieveFirstPart(accPlans);                
	}           

	//Initializes all vars
	private void init(){
		pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Account_Plan_vod__c');     
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
		List<Schema.PicklistEntry> pList = Account_Plan_vod__c.Team_gne__c.getDescribe().getPicklistValues();

		for(Schema.PicklistEntry ple : pList) {
			frmAccountTeamsSelectOptions.add(new SelectOption(ple.getValue(), ple.getLabel())); 
		}
		
		frmAccountTeamsSelectOptions.sort();   
	}


	public PageReference NewB(){
		PageReference pageref = new PageReference('/apex/GNE_SFA2_Account_Plan_Edit_Create_Layout?retUrl=/apex/GNE_SFA2_Account_Plan_List');
		pageref.setredirect(true);
		return pageref;        
	}

	//Retrieves all account plans
	private List<Account_Plan_vod__c> retrieveAccPlans(){
		List<Account_Plan_vod__c>accPlansTMP = new List<Account_Plan_vod__c>();          

		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
		Pattern p = Pattern.compile('GNE-MCCO-FRM-((\\w+)-{0,1}(\\w*))');
		Matcher m = p.matcher(profileName);
		Boolean isFrmManager = false;
		
		if(!m.find() || profileName.contains('OPS')) {
			groupName = 'ADMIN';
		} else {
			groupName = m.group(1);
			
			if(isFrmManager=(m.group(3)=='Manager')) {
				frmAccountTeamFilter = m.group(2);
			}
		}
		
		if(groupName == 'ADMIN'){
			accPlansTMP = [select ID, Name, CreatedByID, LastModifiedDate, Account_vod__r.Name, Segment_gne__c, Team_gne__c
			from Account_Plan_vod__c where Team_gne__c = :frmAccountTeamFilter order by LastModifiedDate Desc];
		} else if(isFrmManager){
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
		if(allSize < amount + CHUNK_SIZE){
			for(Integer i=amount; i<allSize; i++){
				limitedAccPlans.add(tmpPlans[i]);  
			}
			lastPage = true;
		}else{
			for(Integer i=amount; i<=amount+100; i++){
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
		if(amount > 200){
			for(Integer i=amount-200; i<=amount-CHUNK_SIZE; i++){
				limitedAccPlans.add(tmpPlans[i]);
			}
			part -= CHUNK_SIZE;
			firstPage = false;
		}else{
			for(Integer i=0; i<=CHUNK_SIZE; i++){
				limitedAccPlans.add(tmpPlans[i]);  
			}
			part -= CHUNK_SIZE;
			firstPage = true;
		}
		lastPage = false;
		
		return limitedAccPlans;
	}

	public PageReference nextPart(){  
		limitedAccPlans = retrieveNextPart(accPlans, part);
		return null;
	}

	public PageReference previousPart(){
		limitedAccPlans = retrievePreviousPart(accPlans, part);
		return null;
	}

	public PageReference viewAP(){
		PageReference newpage = new PageReference('/'+this.accPlanID+'?retURL='+ApexPages.currentPage().getURL());
		newpage.setRedirect(true);
		return newpage;  
	}

	public PageReference changeTeam(){
		init();               
		accPlans = retrieveAccPlans();
		Boolean isNext = false;
		part=0;
		firstPage = true;
		lastPage = false;   
		limitedAccPlans = retrieveFirstPart(accPlans); 
		return null;
	}

	public String getActiveMenuItem(){
		String result = '';
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
		}
		return result;
	}
}