public with sharing class GNE_SFA2_S2S_Log_Controller {
    public   ApexPages.StandardController                               stdController                  {get;set;}
    public   SFA2_S2S_Log_gne__c                                        log_S2S                        {get;set;}
    public   Boolean                                                    isServiceActionButtonRendered  {get;set;}
    private  String                                                     jsonRequest;
    private  PageReference                                              afterDeletePageRef;
    private  GNE_Foun_Misc_Config_Items_gne__c                          OTR_Service_Action_Auth_Key;
    private  GNE_Foun_Misc_Config_Items_gne__c                          OTR_Service_Action_BundleId;
    private  GNE_Foun_Misc_Config_Items_gne__c                          OTR_Service_Action_Endpoint;

    public GNE_SFA2_S2S_Log_Controller(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        log_S2S = (SFA2_S2S_Log_gne__c) stdController.getRecord();

        try {
            log_S2S = [SELECT Id, RecordType.DeveloperName, Response_json_gne__c, Full_Message_gne__c, UnixId__c, Message_Code_gne__c FROM SFA2_S2S_Log_gne__c WHERE Id = :log_S2S.Id];
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }

        if(log_S2S.RecordType.DeveloperName == 'Service_Action') {
            isServiceActionButtonRendered = true;
        } else {
            isServiceActionButtonRendered = false;
        }

        OTR_Service_Action_Auth_Key = GNE_Foun_Misc_Config_Items_gne__c.getValues('OTR_KEY_GOOGLEAPI');
        OTR_Service_Action_BundleId = GNE_Foun_Misc_Config_Items_gne__c.getValues(getBundleId());
        OTR_Service_Action_Endpoint = GNE_Foun_Misc_Config_Items_gne__c.getValues('OTR_ENDPOINT_GOOGLEAPI');

        String objectIdentifier = String.valueOf(log_S2S.Id);
        objectIdentifier = objectIdentifier.substring(0,3);
        afterDeletePageRef = new PageReference('/' + objectIdentifier + '/o');
    }

    private static String getBundleId() {
        String bundleName = 'OTR_BUNDLE_ID_GOOGLEAPI';
        if(isProductionEnv()) {
            bundleName = 'PROD_' + bundleName;
        } else {
            String sandboxName = UserInfo.getUserName().substringAfterLast('.');
            bundleName = sandboxName.toUpperCase() + '_' + bundleName;
        }

        return bundleName;
    }
    
    private static Boolean isProductionEnv() {
        return ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    public PageReference sendPushNotification() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(OTR_Service_Action_Endpoint.Configuration_Value_gne__c);

        jsonRequest = '{"to": "/topics/' + log_S2S.UnixId__c + '", "priority": "high", "content_available": true, "restricted_package_name" : "' + OTR_Service_Action_BundleId.Configuration_Value_gne__c + '","notification": {"title": ""}, "data": {"get_snapshot": true}}';

        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization', OTR_Service_Action_Auth_Key.Configuration_Value_gne__c);
        req.setBody(jsonRequest);

        log_S2S.Message_Code_gne__c = '';
        log_S2S.Full_Message_gne__c = '';

        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            log_S2S.Response_json_gne__c = res.getBody();
            log_S2S.Message_Code_gne__c = res.getStatus();
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }

        try {
            update log_S2S;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }

        return reloadPageRef();
    }

    public PageReference linkToEditPage() {
        return new PageReference('/' + log_S2S.Id + '/e?retURL=/' + log_S2S.Id + '&saveURL=/' + log_S2S.Id);
    }

    public PageReference deleteRecord() {
        try {
          delete log_S2S;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }

        return afterDeletePageRef;
    }

    public PageReference reloadPageRef() {
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
}