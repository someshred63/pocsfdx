public without sharing class AGS_ST_SIMS_RegistrationHelper_gne 
{         
    public final String SIMS_WEBSERVICE_ENDPOINT = 'https://extsimsit.gene.com/idm/ext/mvc/ext/users';

    public Boolean registerUser(String stUserId)
    {
        System.debug('------ registr helper');
        AGS_ST_User_gne__c stUser = AGS_ST_DbUtils.findAgsStUserById(stUserId);
        if(stUser == null)
        {
            System.debug('No stUser found for stUserId: ' + stUserId);
            return false;
        }
        
        AGS_ST_SIMS_WebServiceClient simsWsClient = new AGS_ST_SIMS_WebServiceClient(this.SIMS_WEBSERVICE_ENDPOINT);
        Boolean success = simsWsClient.createSimsUser(stUser.First_name__c, stUser.Last_name__c, /*stUser.Phone_number__c*/ '0', stUser.Email_address__c);      
        if(success)
        {
            //createSimsRecordForStUser(stUser.id);
            return true;
        }
        
        return false;               
    }
    
    public Boolean registerProxy(String proxyId, String userId)
    {
        AGS_ST_Proxy_gne__c proxy = AGS_ST_DbUtils.findProxyById(proxyId);
        User usr = AGS_ST_DbUtils.findUserById(userId);
        if(proxy == null)
        {
            System.debug('No proxy found for proxyId: ' + proxyId);
            return false;
        }
        
        system.debug('---'+proxyId);
        system.debug('---'+usr.Email);
        AGS_ST_SIMS_WebServiceClient simsWsClient = new AGS_ST_SIMS_WebServiceClient(this.SIMS_WEBSERVICE_ENDPOINT);
        Boolean success = simsWsClient.createSimsUser(proxy.FirstName_gne__c, proxy.LastName_gne__c, /*stUser.Phone_number__c*/ '0', usr.Email);        
        if(success)
        {
            //createSimsRecordForStUser(stUser.id);
            return true;
        }
        
        return false;               
    }   
    private Id createSimsRecordForStUser(String stUserId)
    {
        System.debug('Creating SIMS record (GNE_CM_MPS_SIMS_User_Management__c) for stUserId: ' + stUserId);                                
        try 
        {   
            GNE_CM_MPS_SIMS_User_Management__c simsUser = new GNE_CM_MPS_SIMS_User_Management__c();         
            simsUser.MPS_User__c = stUserId;            
            simsUser.Workflow_State__c = 'READY_FOR_PICKUP';
            insert simsUser;
            
            System.debug('SIMS record created (GNE_CM_MPS_SIMS_User_Management__c) for stUserId: ' + stUserId + ', simsUserId: ' + simsUser.Id);            
            return simsUser.Id;             
        }
        catch(Exception e) 
        {
            System.debug('SIMS USER MNG. INSERT FAILED');
            System.debug(Logginglevel.ERROR, e);
            
            String content = 'type: ' + e.getTypeName() + ' line:' + e.getLineNumber() + ' stack: ' + e.getStackTraceString();
            AGS_ST_Utils.logRegistrationError('AGS_ST_SIMSRegistrationHelper__gne', content, e.getMessage(), 'createSimsRecordForStUser', null, null, null);
        }
        return null;
    }
    
    
    
    
}