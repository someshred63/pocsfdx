/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2013-08-06
*  Description: This is a controller for GNE_SFA2_Browser_Support Page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Browser_Not_Supp_Controller {
       
    public List<AvailableApp> availableApps {get;set;}
    public Boolean appsExists {get;set;}
    
    public GNE_SFA2_Browser_Not_Supp_Controller() {
        availableApps = prepareAvailableApps();
        appsExists = !availableApps.isEmpty();
    }
    
    public List<AvailableApp> prepareAvailableApps() {
        List<AvailableApp> result = new List<AvailableApp>();
        
        for(SFA2_User_Sales_Roster_gne__c app : [ SELECT Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.App_URL_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c =: UserInfo.getUserId() AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = false AND Sales_Roster_gne__r.Is_SFA2_Available_gne__c = true ]) {
            result.add(new AvailableApp(app.Sales_Roster_gne__r.Type_gne__c, app.Sales_Roster_gne__r.App_URL_gne__c));
        }
        /*
        for(SFA2_User_Sales_Roster_gne__c app : [ SELECT Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.App_URL_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c =: UserInfo.getUserId() AND Sales_Roster_gne__r.Type_gne__c NOT IN ('SFA-US','MedAffairs','TLCRM','MCCO','SFA-Canada','ICCalc') ]) {
            result.add(new AvailableApp(app.Sales_Roster_gne__r.Type_gne__c, app.Sales_Roster_gne__r.App_URL_gne__c));
        }
        */
        
        return result;
    }
    
    public class AvailableApp {
            
        public String appName {get;set;}
        public String url {get;set;}
        
        public AvailableApp(String appName, String url) {
            this.appName = appName;
            this.url = url;
        }
    }
    
}