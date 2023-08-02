/*
Class Name: GNE_AccountPlan_History_Ctrl
Used In :  GNE_AP_History, GNE_AP_Status
Purpose/Overview :  
Author: Kishore Chandolu
Modified By : Pawe? Piskorz
Created Date: 11/04/2013
*/
public class GNE_AccountPlan_History_Ctrl extends GNE_AP_Base_Class{ 

    public GNE_AccountPlan_History_Ctrl(ApexPages.StandardController controller){
        super();
    }
    
    public GNE_AccountPlan_History_Ctrl(){
        super();
    }
    
    public List<AP_Account_Planning_gne__c> getHistoricalAccountPlanning(){
        return GNE_AP_DAO.getHistoricalAccountPlans();
    }
    
    public List<AP_Account_Planning_gne__c> getActiveAccountPlanning(){
    	return GNE_AP_DAO.getActiveAccountPlans();
    }
    
    public PageReference redirectToTerrPlanning(){
         PageReference redirect = new PageReference('/apex/GNE_AP_Territory_Planning');
         redirect.setRedirect(true);
         redirect.getParameters().put('planId', accountPlanId); 
         redirect.getParameters().put('csUserId', csUserId);          
         return redirect;
     }
}