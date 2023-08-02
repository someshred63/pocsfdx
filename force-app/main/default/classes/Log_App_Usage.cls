public class Log_App_Usage {
    private App_Usage__c au;
    public Log_App_Usage(String app, ID uid){
        List<App_Usage__c> users=[select App_name__c, User__c, latest_access__c, Initial_Access__c,Access_Count__c, last_session__c 
            from App_Usage__c where App_name__c=:app and User__c=:uid ];
        If (users==null || users.size()==0) {
            au=new App_Usage__c();   
            au.App_name__c=app;
            au.User__c=uid;
            au.Initial_Access__c=system.now();
            au.last_session__c=Userinfo.getSessionId();
            au.Access_Count__c=1;
        } else au=users[0];
    }
    public void logUserUsage(){        
        au.latest_access__c=system.now();        
        if(au.last_session__c!=Userinfo.getSessionId()) {
            au.Access_Count__c+=1;
            au.last_session__c=Userinfo.getSessionId();
        }
        upsert au;
    }

}