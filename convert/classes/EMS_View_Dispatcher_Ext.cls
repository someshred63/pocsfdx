public with sharing class EMS_View_Dispatcher_Ext {
    private String sObjectType;
    private String sObjectId;
    private String urlParameters;
    private string sObjectURLId;
    private Boolean isSFA2User;
    private Boolean hasEMSCanadaAppContext;
    private UserRecordAccess recordAccess;
    private String userProfile;

    public EMS_View_Dispatcher_Ext(ApexPages.StandardController stdController) {
        sObjectURLId = System.currentPageReference().getParameters().get('id');
        recordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :sObjectURLId LIMIT 1];
        userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if (recordAccess != null && recordAccess.HasReadAccess == true) {
            sObjectType = String.valueOf(stdController.getRecord().getSObjectType());
            sObjectId = stdController.getRecord().Id;
            System.PageReference pageReference = System.currentPageReference();
            if (pageReference != null) {
                Map<String, String> parameters = pageReference.getParameters();
                if (parameters != null && parameters.size() > 0) {
                    urlParameters = '?';
                    for (String key : parameters.keyset()) {
                        if (urlParameters != '?') {
                            urlParameters += '&';
                        }
                        urlParameters += String.format('{0}={1}', new String[]{
                                key, parameters.get(key)
                        });
                    }
                }
            }
        }
    }

    public PageReference doRedirect() {
        isSFA2User = GNE_SFA2_Util.isSFA2UserForUI();
        String switchToApplication = ApexPages.currentPage().getParameters().get('application');

        // for all SFA2 users open SFA2 custom page
        if (isSFA2User) {
            //Check if user has EMS-Canada app contex
            hasEMSCanadaAppContext = (EMS_Util.getUserApplication() == 'EMS-Canada') ? true : false;

            // Before open the page, check if Event details are visible (a user has access to) in a Payment Request ...
            if (sObjectType == 'EMS_Speaker_Role_gne__c') {
                EMS_Speaker_Role_gne__c paymentRequest = [SELECT EMS_Event_gne__c FROM EMS_Speaker_Role_gne__c WHERE Id = :sObjectId LIMIT 1];
                if (String.isNotBlank(paymentRequest.EMS_Event_gne__c)) {
                    recordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :paymentRequest.EMS_Event_gne__c LIMIT 1];
                }
            }
            // ... or Transaction record
            if (sObjectType == 'EMS_Transaction_gne__c') {
                EMS_Transaction_gne__c transactionRecord = [SELECT EMS_Speaker_Role_gne__c, EMS_Speaker_Role_gne__r.EMS_Event_gne__c FROM EMS_Transaction_gne__c WHERE Id = :sObjectId LIMIT 1];
                if (String.isBlank(transactionRecord.EMS_Speaker_Role_gne__c) && String.isBlank(transactionRecord.EMS_Speaker_Role_gne__r.EMS_Event_gne__c)) {
                    recordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :transactionRecord.EMS_Speaker_Role_gne__r.EMS_Event_gne__c LIMIT 1];
                }
            }

            // if user doesn't have the record level access, need to redirect to the Access Denied page.
            if (recordAccess != null && !recordAccess.HasReadAccess) {
                PageReference accessDeniedPage = Page.GNE_SFA2_Access_Denied;
                accessDeniedPage.setredirect(true);
                return accessDeniedPage;
            }

            String pageURL;
            if (sObjectType == 'EMS_Budget_Product_gne__c') {
                pageUrl = getPageUrlFormated('EMS_Budget_Product_Layout');
            } else if (sObjectType == 'EMS_Budget_Region_gne__c') {
                pageUrl = getPageUrlFormated('EMS_Budget_Region_Layout');
            } else if (sObjectType == 'EMS_Budget_Territory_gne__c') {
                pageUrl = getPageUrlFormated('EMS_Budget_Territory_Layout');
            } else if (sObjectType == 'EMS_Fund_Request_gne__c') {
                pageUrl = getPageUrlFormated('EMS_Fund_Request_Layout');
            } else if (sObjectType == 'EMS_Event__c' && hasEMSCanadaAppContext == TRUE) {
                pageUrl = getPageUrlFormated('EMS_Event_Layout');
            } else if (sObjectType == 'EMS_Event__c' && hasEMSCanadaAppContext == FALSE) {
                pageUrl = getPageUrlFormated('EMS_Event_Simplified_Layout');
            } else if (sObjectType == 'EMS_Cost_Center_gne__c') {
                pageUrl = getPageUrlFormated('EMS_Cost_Center_Layout');
            } else if (sObjectType == 'GNE_User_Delegation__c') {
                pageUrl = getPageUrlFormated('GNE_User_Delegation_Layout');
            } else if (sObjectType == 'EMS_Cost_Center_Type_gne__c') {
                pageUrl = getPageUrlFormated('EMS_Cost_Center_Types_Layout');
            } else if (sObjectType == 'EMS_Speaker_Role_gne__c') {
                Integer newTransactionsCount = [SELECT count() FROM EMS_Transaction_gne__c WHERE EMS_Speaker_Role_gne__c = :sObjectId AND RecordTypeId != null];
                if (newTransactionsCount > 0) {
                    // new transaction
                    pageUrl = getPageUrlFormated('EMS_Payment_Request_Edit_Create_Layout');
                } else {
                    // old transaction
                    pageUrl = getPageUrlFormated('EMS_Speaker_Role_Edit_Create_Layout');
                }
            } else if (sObjectType == 'EMS_Transaction_gne__c') {
                Integer newTransactionsCount = [SELECT count() FROM EMS_Transaction_gne__c WHERE Id = :sObjectId AND RecordTypeId != null];
                if (newTransactionsCount > 0) {
                    // new transaction
                    pageUrl = getPageUrlFormated('EMS_Payment_Request_Edit_Create_Layout');
                } else {
                    // old transaction
                    pageUrl = getPageUrlFormated('EMS_Transaction_Edit_Create_Layout');
                }
            }

            if (!String.isEmpty(switchToApplication)) {
                return GNE_SFA2_Application_Util.switchUserToApplication(switchToApplication, pageURL);
            } else {
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }
        } else {
            // standard layout
            PageReference pageref = new PageReference('/' + sObjectId + '?nooverride=1');
            pageref.setredirect(true);
            return pageref;
        }

        return null;
    }

    private String getPageUrlFormated(String vfPageName) {
        String pageUrl;
        if (!String.isBlank(urlParameters)) {
            pageUrl = String.format('/apex/{0}{1}', new String[]{
                    vfPageName, urlParameters
            });
        } else {
            pageUrl = String.format('/apex/{0}?id={1}', new String[]{
                    vfPageName, sObjectId
            });
        }
        return pageUrl;
    }
}