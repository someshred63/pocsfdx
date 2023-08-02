public class GNE_AP_Navigation_Controller {
    public String url{get; set;}
    public String accountPlanId{get; set;}
    public String csUserId{get; set;}
     
    private final static Integer DEFAULT_LENGTH_LIMIT = 1900;

    private static SFA2_User_Preferences_gne__c userPref;
    static{
        try {
            userPref = [SELECT Id FROM SFA2_User_Preferences_gne__c WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
        }
        catch(Exception e) {
            userPref = new SFA2_User_Preferences_gne__c();          
        } 
     }

    public GNE_AP_Navigation_Controller(){
         accountPlanId = ApexPages.currentPage().getParameters().get('planId');
         csUserId = ApexPages.currentPage().getParameters().get('csUserId');  
     }
     
    public PageReference navigate(){
         PageReference redirect = new PageReference(url);
         redirect.setRedirect(true);
         if(String.isNotEmpty(accountPlanId)){
            redirect.getParameters().put('planId', accountPlanId);
         }          
         if(String.isNotEmpty(csUserId)){
            redirect.getParameters().put('csUserId', csUserId);
         }
         
         return redirect;
     }
    
    public Boolean getReturnToCrmVisible() {
        return GNE_SFA2_Util.isCCCrmUser();
    }
    
    public String getAplicationName() {
        String appName = 'gSFA';
        if(GNE_SFA2_Util.isCCCrmUser() ) {
            appName = 'CRM';
        }
        return appName;
    }

    public static void setLastVisitedPage() {
        String currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        userPref.Last_page_visited_gne__c = currentPageName;
        upsert userPref;
    }

    public PageReference navigateToSalesData() {
        setLastAndNextVisitedPage('GNE_AP_SalesData');
        String accountList = getAccountsList();
        PageReference pageRef = new PageReference(envUrl + ',' + accountList);      
        pageRef.setRedirect(true);

        return pageRef;
    }     

    public static void setLastAndNextVisitedPage(String nextPageName) {
        String currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        userPref.Last_page_visited_gne__c = currentPageName + ';' + nextPageName;
        upsert userPref;
    }
    
     
     public String getAccountsList(){
        String commaSepratedList ='';
        for(AP_Account_User_gne__c apAccount: [SELECT AP_Account_gne__r.OrgId_gne__c FROM AP_Account_User_gne__c WHERE CS_User_gne__c =:UserInfo.getUserId() ORDER BY lastModifiedDate DESC]){
            if(!apAccount.AP_Account_gne__r.OrgId_gne__c.startsWith(GNE_AP_Util.AP_INTERNAL_ACCOUNT_PREFIX)){
                if(commaSepratedList.length() + apAccount.AP_Account_gne__r.OrgId_gne__c.length() + 1 < DEFAULT_LENGTH_LIMIT){
                    commaSepratedList += apAccount.AP_Account_gne__r.OrgId_gne__c + ',' ;
                }else{
                    break;
                }
            }
        }
        commaSepratedList = commaSepratedList.removeEnd(',');
        return commaSepratedList;
    }
    
    public Boolean getIsFE(){
        return GNE_AP_Util.isFE();
    }
    
    public Boolean getIsFM(){
        return GNE_AP_Util.isFM();
    }
    
    public Boolean getIsDataViewerAdmin(){
        return GNE_AP_Util.getIsDataViewerAdmin();
    }
    
    public Boolean getIsBioOnc(){
        return GNE_AP_Util.getIsBioOncUser(UserInfo.getUserId());
    }
    
    public String envUrl{
         get{
             return Utilities.getGlobalVariable('GNE_AP_SalesData');
         }
         private set;
    }
}