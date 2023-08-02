public with sharing class GNE_AP_DAO {
	public static final Integer MAX_RECORD_COUNT = Integer.valueOf(Utilities.getGlobalVariable('GNE_FCR_History_Records_Limit'));
	
	public static List<AP_Account_User_gne__c> getUserAccounts(Id userId){
		return [SELECT Id, Name, Account_CSUser_gne__c, CS_User_gne__c, AP_Account_gne__r.Address_gne__c, AP_Account_gne__r.Name, AP_Account_gne__r.OrgId_gne__c, AP_Account_gne__c FROM AP_Account_User_gne__c
				WHERE CS_User_gne__c = :userId ORDER BY LastModifiedDate DESC];
	}
	
	public static List<AP_Account_Planning_gne__c> getActiveAccountPlans(){
		return [SELECT Id, Name, Display_Status_gne__c, Status_gne__c, Action_gne__c, DM_Comments_gne__c, Date_Approved_gne__c, CS_User_gne__c, DM_User_gne__c, DM_User_gne__r.Name, LastModifiedDate, Territory_Id_gne__c,
						(SELECT id FROM AP_Plan_Details__r) 
		 FROM AP_Account_Planning_gne__c WHERE Status_gne__c != :GNE_AP_Util.AP_ARCHIVED ORDER By Name ASC NULLS LAST LIMIT :MAX_RECORD_COUNT]; 
	}
	
	public static List<AP_Account_Planning_gne__c> getHistoricalAccountPlans(){
	    return [SELECT Id, Name, Display_Status_gne__c, Status_gne__c, Action_gne__c, DM_Comments_gne__c, Date_Approved_gne__c, Date_Archived_gne__c, CS_User_gne__c, DM_User_gne__c, LastModifiedDate, Territory_Id_gne__c FROM AP_Account_Planning_gne__c WHERE Status_gne__c = :GNE_AP_Util.AP_ARCHIVED ORDER By Date_Archived_gne__c DESC NULLS LAST LIMIT :MAX_RECORD_COUNT]; 
	}
	
	public static List<AP_Account_Planning_gne__c> getAllAccountPlans(){
	    return [SELECT Id, Name, CreatedDate, Display_Status_gne__c, Status_gne__c, Action_gne__c, DM_Comments_gne__c, Date_Approved_gne__c, Date_Archived_gne__c, CS_User_gne__c, DM_User_gne__c, LastModifiedDate, Territory_Id_gne__c FROM AP_Account_Planning_gne__c ORDER By CreatedDate DESC NULLS LAST LIMIT :MAX_RECORD_COUNT]; 
	}
	
	public static AP_Account_Planning_gne__c getActiveAccountPlan(Id feUserId){
		List<AP_Account_Planning_gne__c> accPlans = [SELECT Id, CS_User_gne__c, DM_User_gne__c, DM_Comments_gne__c, Status_gne__c, Territory_Id_gne__c FROM AP_Account_Planning_gne__c WHERE CreatedById = :feUserId and Status_gne__c != :GNE_AP_Util.AP_ARCHIVED];
		if(accPlans.size() == 1){
			return accPlans.get(0);
		}else if(accPlans.size() == 0){
			return null;
		}
		throw new APException('Wrong data. Only one Account Plan could be active.');
	}
	
	public static List<AP_Account_gne__c> getAccounts(Set<Id>accountIds){
		return [SELECT Id, Name, Address_gne__c, OrgId_gne__c FROM AP_Account_gne__c WHERE Id IN : accountIds];
	}
	
	public static List<AP_Detail_gne__c> getAccountPlanDetailsForAccount(Id accountId){ 
		return [SELECT Id, Name, AP_Account_gne__c, AP_Account_gne__r.Id, AP_Account_gne__r.Name, Comments_gne__c, CreatedById, Team_Member_gne__c, Time_Line_gne__c, Objective_gne__c, Tactic_gne__c, Resource_gne__c, Product_gne__c, Product_gne__r.Name
				FROM AP_Detail_gne__c WHERE AP_Account_gne__c =:accountId];
	}
	
	public static List<AP_Detail_gne__c> getAccountPlanDetails(Id accountPlanId){ 
		return [SELECT Id, Name, AP_Account_gne__c, AP_Account_Planning_gne__r.Date_Archived_gne__c, AP_Account_gne__r.Id, AP_Account_gne__r.Name, AP_Account_gne__r.OrgId_gne__c, Comments_gne__c, 
						CreatedById, Team_Member_gne__c, Team_Member_Comments_gne__c , Time_Line_gne__c, Objective_gne__c, LastModifiedDate , Tactic_gne__c, Resource_gne__c, Product_gne__c, Product_gne__r.Name
				FROM AP_Detail_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId ORDER BY LastModifiedDate DESC LIMIT :MAX_RECORD_COUNT];
	}
	
	public static AP_Account_Planning_gne__c getAccountPlan(Id accountPlanId){
		return [SELECT Id, CreatedById, CreatedDate, CS_User_gne__c, CS_User_gne__r.FirstName, CS_User_gne__r.LastName, CS_User_gne__r.Email, Date_Approved_gne__c, Date_Archived_gne__c, Date_Returned_gne__c, Name,
						Date_Submitted_gne__c, DM_User_gne__c, DM_User_gne__r.Email, LastModifiedById, OwnerId, LastModifiedDate, Status_gne__c, Action_gne__c, Display_Status_gne__c, DM_Comments_gne__c, Territory_Number_gne__c, Territory_Id_gne__c 
				FROM AP_Account_Planning_gne__c where Id=:accountPlanId];
	}
	
	
	public static List<AP_Territory_Planning_gne__c>getTerritoryPlanns(Id accountPlanId){
		return [SELECT Id, Name, CS_User_gne__c, DM_User_gne__c, AP_Account_Planning_gne__c, Message_gne__c, Territory_Name_gne__c, TP_Category_gne__c, Title_gne__c FROM AP_Territory_Planning_gne__c WHERE AP_Account_Planning_gne__c=:accountPlanId];
	}
	
	/*Return manager Id for user. If not exists return null.*/
	public static Id getUserManagerId(Id userId){
		List<User> managerCred = [SELECT ManagerId FROM User WHERE Id = :userId];
		if(managerCred.size() > 0 && managerCred.get(0).ManagerId != null){
			return managerCred.get(0).ManagerId;
		}
		return null;
	}
	
	public static List<Product_vod__c>getUserBrands(Id userId){
    	List<My_Setup_Products_vod__c> setupProducts = [SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = :userId AND Product_vod__c != null AND Product_vod__r.Name != null];                                  
		Set<Id>productIds = new Set<Id>();
		for(My_Setup_Products_vod__c setupProduct: setupProducts){
			productIds.add(setupProduct.Product_vod__c);
		}
		if(!productIds.isEmpty()){
			return [SELECT Id, Name FROM Product_vod__c WHERE Id IN :productIds];
		}
		return new List<Product_vod__c>();
    }
    
    public static List<AP_ResourceRequest_gne__c> getAllResources(){
		List<SFA2_User_Sales_Roster_gne__c> franchise = GNE_AP_Util.getFranchiseId(Userinfo.getUserId());
		if(!franchise.isEmpty()){
			return GNE_AP_Util.getResourceRequest(franchise.get(0).Sales_Roster_gne__r.Franchise__r.Id);
		} else {
			Id franchiseId = GNE_AP_Util.getFranchiseIdFromTerritoryMapping(Userinfo.getUserId());
			if(franchiseId != null){
				return GNE_AP_Util.getResourceRequest(franchiseId);
			}
		}
		return new List<AP_ResourceRequest_gne__c>();
	}
	
	class APException extends Exception{
		
	}
	
	public static AP_Plan_Detail_Storage_gne__c getUserStorage(String userId){
		List<AP_Plan_Detail_Storage_gne__c>storages = [SELECT Id, Name, AP_Account_gne__c, Comments_gne__c, Objective_gne__c, Resource_gne__c, Tactic_gne__c, Team_Member_Comments_gne__c, Team_Member_gne__c, Time_Line_gne__c, Session_Id_gne__c, Product_gne__c
														FROM AP_Plan_Detail_Storage_gne__c WHERE CreatedById = :userId];
		if(!storages.isEmpty()){
			return storages.get(0);
		}
		return null;							
	}
	
	public static Boolean isPlanContainsDetails(String accountPlanId){
		Boolean result = false;
		if(!String.isEmpty(accountPlanId)){
			Integer details = [SELECT count() FROM AP_Detail_gne__c WHERE AP_Account_Planning_gne__c = :accountPlanId];
			if(details > 0){
				result = true;
			}
		}
		return result;
	}
}