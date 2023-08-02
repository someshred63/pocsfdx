public class GNE_AP_Landing_Page{

	public Pagereference loadPage(){
		PageReference pageRef = null;
		if (GNE_AP_Util.isFE()){
			AP_Account_Planning_gne__c activePlan = GNE_AP_DAO.getActiveAccountPlan(Userinfo.getUserId());
			if(activePlan == null){
				activePlan = GNE_AP_Util.createNewAccountPlan();
				insert activePlan;
			}
			pageref = new PageReference('/apex/GNE_AP_Territory_Planning');
			pageref.setRedirect(true);
			pageref.getParameters().put('planId', activePlan.Id);
			pageref.getParameters().put('csUserId', activePlan.CS_User_gne__c);
		}else if (GNE_AP_Util.isFM()){
			pageref = new PageReference('/apex/GNE_AP_Status');
		}else if (GNE_AP_Util.getIsDataViewerAdmin()){
			pageref = new PageReference('/apex/GNE_AP_History');
		}else{
			return GNE_AP_Util.redirectToErrorPage('You dont have sufficient access to the application. Please contact the Administrator!', Apexpages.currentPage().getUrl(), 'User doesnt have application access.');
		}
		return pageref;
	}
}