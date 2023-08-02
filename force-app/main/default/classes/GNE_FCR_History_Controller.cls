public without sharing class GNE_FCR_History_Controller{
	public Id dayPlanId {get; set;}
	public static final Integer MAX_RECORD_COUNT = Integer.valueOf(Utilities.getGlobalVariable('GNE_FCR_History_Records_Limit'));

	public void setLastVisitedPage() {        
        GNE_FCR_Navigation_Controller.setLastVisitedPage();        
    }
    
	public List<FCR_Days_Plan_gne__c> getFcrs(){
		return getArchivedDaysPlans();
	}

	public PageReference redirectToDetail(){
		PageReference redirect = new PageReference('/apex/GNE_FCR_Detail');
		redirect.setRedirect(true);
		redirect.getParameters().put('id', dayPlanId);
		return redirect;
	}

	public Boolean getIsFE(){
		return GNE_FCR_Util.getIsFE();
	}

	public Boolean getIsFR(){
		return GNE_FCR_Util.getIsFR();
	}

	public User getCurrentUser(){
		return [SELECT Id, Name, ManagerId FROM User WHERE id=:UserInfo.getUserId()];
	}

	public static List<FCR_Days_Plan_gne__c> getArchivedDaysPlans(){
    	String archivedStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS);
    	String completedStatus = GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS);
    	List<FCR_Days_Plan_gne__c>result;
    	List<Integer> versions = GNE_FCR_Util.getAvailableFCRVersions();

    	if(GNE_FCR_Util.isNsdRsdUser(UserInfo.getUserId())){
    		Set<Id> usersId = getUserIdsByTerritory();
    		result = [SELECT Id, CS_user_gne__r.Name, CS_user_gne__r.FirstName, CS_user_gne__r.LastName, Date_Field_Visit_gne__c, Version_gne__c,
			    			 FR_User_gne__c, FR_User_gne__r.Name, FR_User_gne__r.FirstName, FR_User_gne__r.LastName, Territory_Name_gne__c
			    		FROM FCR_Days_Plan_gne__c
			    		WHERE (Version_gne__c IN :versions AND Status_gne__c in (:archivedStatus, :completedStatus))
			    				AND (CS_User_gne__c in :usersId OR  FR_User_gne__c in :usersId OR FR_User_gne__c=:UserInfo.getUserId()) ORDER BY Date_Field_Visit_gne__c DESC LIMIT :MAX_RECORD_COUNT];
    	}else if(GNE_FCR_Util.getIsDataViewerAdmin()){
    		result = [SELECT Id, CS_user_gne__r.Name, CS_user_gne__r.FirstName, CS_user_gne__r.LastName, Date_Field_Visit_gne__c, Version_gne__c,
			    			 FR_User_gne__c, FR_User_gne__r.Name, FR_User_gne__r.FirstName, FR_User_gne__r.LastName, Territory_Name_gne__c
			    		FROM FCR_Days_Plan_gne__c
			    		WHERE (Version_gne__c IN :versions AND Status_gne__c = :archivedStatus) OR (Version_gne__c=1 AND Status_gne__c = 'Form Complete') ORDER BY Date_Field_Visit_gne__c DESC LIMIT :MAX_RECORD_COUNT];
    	}else if(GNE_FCR_Util.getIsFE()){
    		result = [SELECT Id, CS_user_gne__r.Name, CS_user_gne__r.FirstName, CS_user_gne__r.LastName, Date_Field_Visit_gne__c, Version_gne__c,
			    			 FR_User_gne__c, FR_User_gne__r.Name, FR_User_gne__r.FirstName, FR_User_gne__r.LastName, Territory_Name_gne__c
			    		FROM FCR_Days_Plan_gne__c
			    		WHERE ((Version_gne__c IN :versions AND Status_gne__c = :archivedStatus) OR (Version_gne__c=1 AND Status_gne__c = 'Form Complete')) AND CS_user_gne__c = :UserInfo.getUserId() ORDER BY Date_Field_Visit_gne__c DESC];
    	}else{
    		Set<Id> usersId = getUserIdsByTerritory();
    		result = [SELECT Id, CS_user_gne__r.Name, CS_user_gne__r.FirstName, CS_user_gne__r.LastName, Date_Field_Visit_gne__c, Version_gne__c,
			    			 FR_User_gne__c, FR_User_gne__r.Name, FR_User_gne__r.FirstName, FR_User_gne__r.LastName, Territory_Name_gne__c
			    		FROM FCR_Days_Plan_gne__c
			    		WHERE ((Version_gne__c IN :versions AND Status_gne__c = :archivedStatus) OR (Version_gne__c=1 AND Status_gne__c = 'Form Complete'))
			    				AND (CS_User_gne__c in :usersId OR  FR_User_gne__c in :usersId OR FR_User_gne__c=:UserInfo.getUserId()) ORDER BY Date_Field_Visit_gne__c DESC LIMIT :MAX_RECORD_COUNT];
    	}
    	return result;
    }

    private static Set<Id> getUserIdsByTerritory() {
    	Set<Id>userTerritoriesId = new Set<Id>();
		for(Territory2 territory: GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())){
			userTerritoriesId.add(territory.Id);
		}
		Set<Id>usersId = new Set<Id>();
		for(UserTerritory2Association ut: [SELECT UserId FROM UserTerritory2Association WHERE Territory2Id IN :userTerritoriesId]){
			usersId.add(ut.UserId);
		}

		return usersId;
    }

    public String getCSUserHeader() {
    	return GNE_FCR_Util.isNsdRsdUser(UserInfo.getUserId()) ? 'Clinical Specialist' : 'Employee';
    }

    public String getFRUserHeader() {
    	return GNE_FCR_Util.isNsdRsdUser(UserInfo.getUserId()) ? 'Manager' : 'Reviewer';
    }
}