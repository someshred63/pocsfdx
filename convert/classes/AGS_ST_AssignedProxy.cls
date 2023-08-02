public without sharing class AGS_ST_AssignedProxy 
{
    public String associationId {get;private set;}
    public String firstName {get; private set;}
    public String lastName {get;private set;}       
    public String email {get;private set;}
    
    public static List<AGS_ST_AssignedProxy> getPhysicianProxies()
    {  
        try
        {
            List<AGS_ST_Proxy_Association_gne__c> proxiesAssociations = AGS_ST_DbUtils.findAllPhysicianProxiesST(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id);
            
            List<AGS_ST_AssignedProxy> tmpApList = new List<AGS_ST_AssignedProxy>();
            for(AGS_ST_Proxy_Association_gne__c a : proxiesAssociations)
            {
                AGS_ST_AssignedProxy tmpAp = new AGS_ST_AssignedProxy();
                tmpAp.firstName = a.Physician_As_Proxy_ST_gne__r.First_name__c;
                tmpAp.lastName = a.Physician_As_Proxy_ST_gne__r.Last_name__c;
                tmpAp.email = a.Physician_As_Proxy_ST_gne__r.Email_address__c;
                tmpAp.associationId = a.Id;
                tmpApList.add(tmpAp);
            }
            return tmpApList;
         }
         catch(Exception e)
         {
            System.debug('getPhysicianProxies exception, userId: ' + UserInfo.getUserId());
            System.debug(e);
            return new List<AGS_ST_AssignedProxy>();
         }
    }
    
    public static List<AGS_ST_AssignedProxy> getNonPhysicianProxies ()
    {                               
        try
        {
            List<AGS_ST_Proxy_Association_gne__c> proxiesAssociations = AGS_ST_DbUtils.findAllNonPhysicianProxiesST(AGS_ST_DbUtils.findAgsStUserByUserId(UserInfo.getUserId()).id);
                            
            List<AGS_ST_AssignedProxy> tmpApList = new List<AGS_ST_AssignedProxy>();
            for(AGS_ST_Proxy_Association_gne__c a : proxiesAssociations)
            {
                AGS_ST_AssignedProxy tmpAp = new AGS_ST_AssignedProxy();
                tmpAp.firstName = a.Proxy_gne__r.FirstName_gne__c;
                tmpAp.lastName = a.Proxy_gne__r.LastName_gne__c;
                tmpAp.email = a.Proxy_gne__r.User_gne__r.Email;
                tmpAp.associationId = a.Id;
                tmpApList.add(tmpAp);
            }
            return tmpApList;                               
         }
         catch(Exception e)
         {
            System.debug('getNonPhysicianProxies exception, userId: ' + UserInfo.getUserId());
            System.debug(e);            
            return new List<AGS_ST_AssignedProxy>();
         }     
    }    
    
    public static List<AGS_ST_AssignedProxy> getProxyPhysicians()
    {
        try
        {
            List<AGS_ST_Proxy_Association_gne__c> proxiesAssociations = AGS_ST_DbUtils.findAllProxyPhysiciansST(UserInfo.getUserId());
            
            List<AGS_ST_AssignedProxy> tmpApList = new List<AGS_ST_AssignedProxy>(); 
            for(AGS_ST_Proxy_Association_gne__c a : proxiesAssociations)
            {
                AGS_ST_AssignedProxy tmpAp = new AGS_ST_AssignedProxy();
                tmpAp.firstName = a.AGS_ST_User_gne__r.First_name__c;
                tmpAp.lastName = a.AGS_ST_User_gne__r.Last_name__c;
                tmpAp.email = a.AGS_ST_User_gne__r.Email_address__c;
                tmpAp.associationId = a.Id;
                tmpApList.add(tmpAp);
            }
            return tmpApList;               
         }
         catch(Exception e)
         {
            System.debug('getProxyPhysicians exception, userId: ' + UserInfo.getUserId());
            System.debug(e);                        
            return new List<AGS_ST_AssignedProxy>();
         } 
    }
    
    public static List<AGS_ST_AssignedProxy> getAssigneePhysicians()
    {
        try
        {
            List<AGS_ST_Proxy_Association_gne__c> proxiesAssociations = AGS_ST_DbUtils.findAllAssigneePhysiciansST(UserInfo.getUserId());
            
            List<AGS_ST_AssignedProxy> tmpApList = new List<AGS_ST_AssignedProxy>(); 
            for(AGS_ST_Proxy_Association_gne__c a : proxiesAssociations)
            {
                AGS_ST_AssignedProxy tmpAp = new AGS_ST_AssignedProxy();
                tmpAp.firstName = a.AGS_ST_User_gne__r.First_name__c;
                tmpAp.lastName = a.AGS_ST_User_gne__r.Last_name__c;
                tmpAp.email = a.AGS_ST_User_gne__r.Email_address__c;
                tmpAp.associationId = a.Id;
                tmpApList.add(tmpAp);
            }
            return tmpApList;               
         }
         catch(Exception e)
         {
            System.debug('getAssigneePhysicians exception, userId: ' + UserInfo.getUserId());
            System.debug(e);                                    
            return new List<AGS_ST_AssignedProxy>();
         } 
    }


}