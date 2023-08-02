public with sharing class GNE_SFAC_Planned_Frequency_Controller {

	private final ApexPages.standardController theController;
	private final Account acc;
    private Id accountId;
    public List<PlannedFrequency> plannedFrequencyList { get; set;}
    public Boolean editMode { get; set;}

    private List<TSF_vod__c> tsfList;
    private Map<String, List<TSF_vod__c>> accountAllTSFs;
    private Set<String> userTerritoriesNames;

	private Set<String> canadaProfiles = new Set<String> {
			'RCanada-SFA-Manager',
			'RCanada-SFA-Ops',
			'RCanada-SFA-RAMA',
			'RCanada-SFA-ReadOnly',
			'RCanada-SFA-SAM',
			'RCanada-SFA-TS',
			'RCanada-SYS-AutomatedJob'
	};

	private Boolean isCanadaUser {get; set;}
	private String userProfileName {get; set;}
	Map<String, String> relatedTerritories = new Map<String, String>();

	public class PlannedFrequency implements Comparable {
		public Id tsfId { get; set;}
		public String territory { get; set;}
		public String plannedFrequency { get; set;}
		public Boolean editable { get; set;}
		public String territoryShort {
			get{
				if(territory != null){
					return territory.substring(territory.indexOf('-')+1,territory.length());
				}else {
					return '';
				}
			}
			set;
		}

        public Integer compareTo(Object compareTo) {
            PlannedFrequency otherObj = (PlannedFrequency)compareTo;

            if (this.territoryShort > otherObj.territoryShort) {
                return 1;
            }

            return -1;
        }
	}

	public String saveResultsMsgError { get; set;}
	public String saveResultsMsgInfo { get; set;}

	public Integer rpCount {
		get{
			return plannedFrequencyList.size();
		}
		 set;
	}

	public GNE_SFAC_Planned_Frequency_Controller(ApexPages.StandardController controller) {
		this.acc = (Account)controller.getRecord();
        theController = controller;
        accountId = acc.Id;

        editMode = false;

		userProfileName = [Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
		isCanadaUser = canadaProfiles.contains(userProfileName) ? true : false;

        //prepare Account part
        accountAllTSFs = prepareTSFMap(accountId);
		if(isCanadaUser) {
			relatedTerritories = getRelatedTerritories(accountAllTSFs);
		}
		plannedFrequencyList = preparePlannedFrequencyList(accountAllTSFs);

        //prepare user part
        Id uId = UserInfo.getUserId();
        userTerritoriesNames = getUserTerritoriesNames(uId);
		for(String terrName : userTerritoriesNames){
			for(PlannedFrequency planFreq : plannedFrequencyList){
				if(terrName == planFreq.territory){
					planFreq.editable = true;
				}
			}
		}

    }

    public PageReference enterEditMode(){
    	editMode = true;
    	return null;
    }

    public PageReference cancelEditMode(){
    	editMode = false;

        //prepare Account part
        accountAllTSFs = prepareTSFMap(accountId);
		plannedFrequencyList = preparePlannedFrequencyList(accountAllTSFs);

        //prepare user part
        Id uId = UserInfo.getUserId();
        userTerritoriesNames = getUserTerritoriesNames(uId);
		for(String terrName : userTerritoriesNames){
			for(PlannedFrequency planFreq : plannedFrequencyList){
				if(terrName == planFreq.territory){
					planFreq.editable = true;
				}
			}
		}
    	return null;
    }

	public PageReference saveChanges(){

		List<TSF_vod__c> tsfToUpdate = new List<TSF_vod__c>();

		try {
			for(PlannedFrequency planFreq : plannedFrequencyList){
				if(planFreq.editable != null && planFreq.editable == true){
					for(TSF_vod__c tsf : accountAllTSFs.get(planFreq.territory)){
						if(planFreq.plannedFrequency != null && planFreq.plannedFrequency != ''){
							tsf.Planned_Frequency_can_gne__c = Double.valueOf(planFreq.plannedFrequency);
						}
					}
					tsfToUpdate.addAll(accountAllTSFs.get(planFreq.territory));
				}
			}

			update tsfToUpdate;
			saveResultsMsgInfo = 'Changes saved successfuly';
			saveResultsMsgError ='';
			editMode = false;
		} catch (TypeException e) {
			saveResultsMsgError = 'Please enter correct Planned Frequency values';
			saveResultsMsgInfo = '';
		} catch (Exception e) {
			saveResultsMsgError = 'Error during saving: '+ e;
			saveResultsMsgInfo = '';
		}

		return null;
	}

    public static Set<String> getUserTerritoriesNames(Id uId){

    	// Get user territories
		List<UserTerritory2Association> userTerritories = [Select u.Id,u.Territory2Id
											   from UserTerritory2Association u
											   where u.userid = :uId];

        List<ID> terrIds = new List<ID>();

        for(UserTerritory2Association terrId :userTerritories) {
            terrIds.add(terrId.Territory2Id);
        }

		// Get territory detail
		List<Territory2> accountTerritories = [Select t.Id, t.Name, t.Territory_Number_gne__c
			       							  from Territory2 t
			        						  where t.id in :terrIds];

        Set<String> territoryLevelTerrNames = new Set<String>();
        for(Territory2 terrId :accountTerritories) {
        	territoryLevelTerrNames.add(terrId.Name);
        }

        return territoryLevelTerrNames;

    }

    private List<TSF_vod__c> getAllAccountTSFs(Id accountId){
        List<TSF_vod__c> tsfsList = [Select t.Id,
        				  t.Territory_vod__c,
			              t.Account_vod__c,
			              Planned_Frequency_can_gne__c
			       From TSF_vod__c t
			       where t.Account_vod__c = :AccountId];
    	return tsfsList;
    }

    private List<TSF_vod__c> getTSFs(Id accountId, List<String> territoryLevelTerrNames){

    	// Get the Terrritory level Data
        List<TSF_vod__c> tsfsList = [Select t.Id,
        				  t.Territory_vod__c,
			              t.Account_vod__c
			       From TSF_vod__c t
			       where t.Account_vod__c = :AccountId
			       		 and
			             t.Territory_vod__c in :territoryLevelTerrNames];
    	return tsfsList;
    }

    private Map<String, List<TSF_vod__c>> prepareTSFMap(Id accountId){
    	Map<String, List<TSF_vod__c>> resultTSFMap = new Map<String, List<TSF_vod__c>>();

    	List<TSF_vod__c> allTsfs = getAllAccountTSFs(accountId);
    	for(TSF_vod__c tsf : allTsfs){
    		if(resultTSFMap.containsKey(tsf.Territory_vod__c)){
    			resultTSFMap.get(tsf.Territory_vod__c).add(tsf);
    		}else{
    			List<TSF_vod__c> newTSFList = new List<TSF_vod__c>();
    			newTSFList.add(tsf);
    			resultTSFMap.put(tsf.Territory_vod__c,newTSFList);
    		}
    	}

    	return resultTSFMap;
    }

    private List<PlannedFrequency> preparePlannedFrequencyList(Map<String, List<TSF_vod__c>> accountAllTSFs){

    	List<PlannedFrequency> resultPlannedFrequency = new List<PlannedFrequency>();

    	for(String terrName : accountAllTSFs.keySet()){
			String plannedFrequency = String.valueOf(accountAllTSFs.get(terrName).get(0).Planned_Frequency_can_gne__c);
			if(!isCanadaUser) {
				resultPlannedFrequency.add(preparePlannedFrequency(terrName, plannedFrequency, false));
			} else {
				if(relatedTerritories.containsKey(terrName)) {
					if(!String.valueOf(relatedTerritories.get(terrName)).contains('INACTIVE TERRITORIES')) {
						resultPlannedFrequency.add(preparePlannedFrequency(terrName, plannedFrequency, false));
					}
				}
			}
    	}

        resultPlannedFrequency.sort();

    	return resultPlannedFrequency;
    }

	private PlannedFrequency preparePlannedFrequency(String terrName, String plannedFrequency, Boolean editable) {
		PlannedFrequency planFreq = new PlannedFrequency();
		planFreq.territory = terrName;
		planFreq.plannedFrequency = plannedFrequency;
		planFreq.editable = editable;
		return planFreq;
	}

	private Map<String, String> getRelatedTerritories(Map<String, List<TSF_vod__c>> accountAllTSFs) {
		Set<String> territoryNameTmpSet = accountAllTSFs.keySet();
		Map<String, String> allRelatedterritoriesMap = new Map<String, String>();
		for(Territory2 territory : [
				SELECT Name, External_Id_gne__c
				FROM Territory2
				WHERE Name IN :territoryNameTmpSet]) {
			allRelatedterritoriesMap.put(territory.Name, territory.External_Id_gne__c);
		}
		return allRelatedterritoriesMap;
	}

}