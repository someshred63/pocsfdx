/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-02-18
*  Description: gSFA Application Dispatcher
*  
*  Modification History
*  Date        Name        Description         
*************************************************************/
public with sharing class GNE_SFA2_App_Dispatcher_Controller {
    
    public String browser {get; set;}
    GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
    Map<String, Boolean> appToSalesRosterMap = new Map<String, Boolean>();
     
    public GNE_SFA2_App_Dispatcher_Controller() {
        try {
            fillAppToSalesRosterMap();
        } catch (Exception ex) {
            System.debug(GlobalUtils.getExceptionDescription(ex));
            GNE_SFA2_Util.redirectToErrorPage('User Sales Roster configuration is not valid.', Apexpages.currentPage().getUrl(), ex.getMessage());
        }
     }
     
     
     public PageReference selectApplicationAndNavigate () {
        try {
            String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');

            if(GNE_SFA2_Util.isCanadaINFUUser()) {
                PageReference pr = Page.EMS_Concur_Interaction_Connector;
                pr.setredirect(true);
                return pr;
            }

            if(!isBrowserSupported(userAgent)){
                PageReference pr = Page.GNE_SFA2_Browser_Not_Supported;
                pr.setredirect(true);
                return pr;
            }
            String switchToApplication = ApexPages.currentPage().getParameters().get('application');
            String targetURL = ApexPages.currentPage().getParameters().get('targetURL');
            
            System.debug('switchToApplication '+switchToApplication);
            System.debug('targetURL ' + targetURL);
            if(switchToApplication == null) {            
                if(appToSalesRosterMap.containsKey(userApplicationContext.App_Name_gne__c) && appToSalesRosterMap.get(userApplicationContext.App_Name_gne__c) == true) {
                    // there is a Sales Roster record with the same Application name as selected
                    switchToApplication = userApplicationContext.App_Name_gne__c;
                    System.debug('switchToApplication'+switchToApplication);
                } else {
                    // select first application from assigned User Sales Rosters
                    switchToApplication = getFirstAvailableApplication();
                    System.debug('switchToApplication'+switchToApplication);
                }
            }

            Set<String> chatterPermissionSetNames = GNE_Chatter_Permission_Set_Name__c.getAll().keySet();
            List<PermissionSetAssignment> permissionSetAssignment = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = : UserInfo.getUserId() AND PermissionSet.Name IN : chatterPermissionSetNames];
            if(!permissionSetAssignment.isEmpty()) {
                List<LoginHistory> lastLogin = [SELECT LoginTime FROM LoginHistory where UserId = :UserInfo.getUserId() order by LoginTime desc limit 1];
                if (!lastLogin.isEmpty()) { 
                    DateTime currentDateTime = System.now();
                    if ((currentDateTime > lastLogin[0].LoginTime.addSeconds(-2)) && (currentDateTime < lastLogin[0].LoginTime.addSeconds(4))) {
                      switchToApplication = 'gCollaborate';
                      targetURL = '/_ui/core/chatter/ui/ChatterPage?tsid=02u70000000RinU';
                    } 
                }
            }            
            
            return GNE_SFA2_Application_Util.switchUserToApplication(switchToApplication, targetURL);
        } catch (Exception ex) {
            System.debug(GlobalUtils.getExceptionDescription(ex));
            return GNE_SFA2_Util.redirectToErrorPage('User Sales Roster configuration is not valid.', Apexpages.currentPage().getUrl(), ex.getMessage());
        }
    }
    
    private void fillAppToSalesRosterMap() {
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = GNE_SFA2_Application_Util.getUserSalesRosters(UserInfo.getUserId());
        for (SFA2_User_Sales_Roster_gne__c userSalesRoster : userSalesRosterList) {
            appToSalesRosterMap.put(userSalesRoster.Sales_Roster_gne__r.Type_gne__c, userSalesRoster.Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c);
        }
    }
    
    private String getFirstAvailableApplication() {
        String result;
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = GNE_SFA2_Application_Util.getUserSalesRosters(UserInfo.getUserId(), true);
        for (SFA2_User_Sales_Roster_gne__c userSalesRoster : userSalesRosterList) {
            if(userSalesRoster.Sales_Roster_gne__r.Type_gne__c != null) {
                result = userSalesRoster.Sales_Roster_gne__r.Type_gne__c;
                break;
            }
        }
        return result;
    }
    
    private Boolean isBrowserSupported(String userAgent){
        system.debug('User browser: '+ userAgent);
        Set<String>browsersSupported = new Set<String>();
        for(GNE_SFA2_Browsers_Supported__c b: GNE_SFA2_Browsers_Supported__c.getall().values()){
            browsersSupported.add(b.name.toLowerCase());
        }
        String userBrowser = getBrowserFromUserAgent(userAgent);
        system.debug('Browsers supported: '+browsersSupported+'; user browser: '+userBrowser);
        if(browsersSupported.contains('all') || browsersSupported.contains(userBrowser)){
                return true;
        }
        return false;
    }
    
    //base on http://web-hound.com/blog/?p=46
    private String getBrowserFromUserAgent(String userAgent){
        if(userAgent.contains('MSIE')){
            return 'ie';
        }else if(userAgent.contains('Firefox/')){
            return 'firefox';
        }else if(userAgent.contains('Chrome/')){
            return 'chrome';
        }else if(userAgent.contains('Safari/') && !userAgent.contains('Chrome/')){
            return 'safari';
        }else if(userAgent.contains('Opera/') && !userAgent.contains('Firefox/')){
            return 'opera';
        }
        return 'other';
    }
        
}