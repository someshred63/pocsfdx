public with sharing class GNE_AP_Status_Ctrl extends GNE_AP_Base_Class {
	
	public List<AP_Account_Planning_gne__c> getHistoricalAccountPlanning(){
        return GNE_AP_DAO.getHistoricalAccountPlans();
    }
    
    public List<AP_Account_Planning_gne__c> getAllAccountPlanning(){
        return GNE_AP_DAO.getAllAccountPlans();
    }
    
    public Boolean getIsHCOUser(){
    	return GNE_AP_Util.getIsDataViewerAdmin();
    }
    
    public List<AccountPlannWrapper> getActiveAccountPlanning(){
    	List<AccountPlannWrapper>result = new List<AccountPlannWrapper>();
    	for(AP_Account_Planning_gne__c plan: GNE_AP_DAO.getActiveAccountPlans()){
	   		Boolean isActionRequired = false;
	   		Boolean isSubmitButtonEnabled = plan.AP_Plan_Details__r.size() > 0;
			if(getIsFE() && plan.CS_User_gne__c == UserInfo.getUserId() && (plan.Status_gne__c == GNE_AP_Util.AP_IN_PROGRESS || plan.Status_gne__c == GNE_AP_Util.AP_RETURNED || plan.Status_gne__c == GNE_AP_Util.AP_APPROVED)){
				isActionRequired = true;
			}else if(getIsFM() && plan.DM_User_gne__c == UserInfo.getUserId() && (plan.Status_gne__c == GNE_AP_Util.AP_SUBMITTED || plan.Status_gne__c == GNE_AP_Util.AP_APPROVED)){
				isActionRequired = true;
			}
			result.add(new AccountPlannWrapper(plan, isActionRequired, isSubmitButtonEnabled)); 
    	}
    	
    	return result;
    }
    
    public PageReference redirectToTerrPlanning(){
         PageReference redirect = new PageReference('/apex/GNE_AP_Territory_Planning');
         redirect.setRedirect(true);
         redirect.getParameters().put('planId', accountPlanId); 
         redirect.getParameters().put('csUserId', csUserId);          
         return redirect;
    }
    
     public PageReference redirectToPdf(){
         PageReference redirect = new PageReference('/apex/GNE_AP_Preview_Report');
         redirect.setRedirect(true);
         redirect.getParameters().put('planId', accountPlanId); 
         redirect.getParameters().put('csUserId', csUserId);          
         return redirect;
     }
     
    @RemoteAction
	public static List<User>getFMUsers(){
		return GNE_FCR_DAO.getAvailableFRs(UserInfo.getUserId());
	}
	
	class AccountPlannWrapper{
		public AP_Account_Planning_gne__c plan {get; set;}
		public Boolean isActionRequired {get; set;}
		public Boolean isSubmitButtonEnabled {get; set;}
		
		public AccountPlannWrapper(AP_Account_Planning_gne__c plan, Boolean isActionRequired, Boolean isSubmitButtonEnabled){
			this.plan = plan;
			this.isActionRequired = isActionRequired;
			this.isSubmitButtonEnabled = isSubmitButtonEnabled;
		}
	}
}