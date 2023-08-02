public class GNE_FRM_Synchronize_Records_With_MDM {
    private static final String SERVICE_DEFAULT_NAMESPACE = 'tns';
    public enum DML_Type {DML_INSERT, DML_UPDATE}
    private static Map<Id, RecordType> recordTypesMap = new Map<Id, RecordType>([
        SELECT Id, DeveloperName
        FROM RecordType
        WHERE SobjectType = 'Account' AND DeveloperName = 'FRM_HCO'
    ]);
    private static Map<DML_Type, String> dml2Service = new Map<DML_Type, String>{
        DML_Type.DML_UPDATE => 'UpdateHCOByProfile',
        DML_Type.DML_INSERT => 'CreateHCOByProfile'
    };
    private static final String SERVICE_NAMESPACE = getSiperianServiceNS() + ':';

    public static void syncOnAccountUpsert(Account acc, Address_vod__c address, DML_Type action, Boolean isFuture) {
        if(isCriteriaForProcessMeet(acc)) {
            String body = createReqBody(acc, address, action);
            String endPoint = fetchEndPoint(action);

            if(isFuture) {
                runSynchronizationFuture(body, endPoint, acc.Id, address.Id, action.Name());
            } else {
                runSynchronization(body, endPoint, acc.Id, address.Id, action.Name());
            }
        }
    }

    @future(callout=true)
    private static void runSynchronizationFuture(String reqBody, String endPoint, Id accId, Id addressId, String action) {
        runSynchronization(reqBody, endPoint, accId, addressId, action);
    }

    private static void runSynchronization(String reqBody, String endPoint, Id accId, Id addressId, String action) {
        Http h = new Http();
        HttpRequest request = createHttpRequest(reqBody, endPoint);
        HttpResponse resp =  h.send(request);

        performUpdateOnSFSide(resp, accId, addressId, action);

        logErrors(request, resp, accId);
        System.debug('response '+ resp.getBody());
    }

    private static HttpRequest createHttpRequest(String body, String endPoint) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        req.setEndpoint(endPoint);
        req.setBody(body);
        return req;
    }

    private static String fetchEndPoint(DML_Type action){
        String endPoint = 'http://endpoint-not-set';
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('SBCMdmSiperianEndPoint') != null) {
            endPoint = GNE_Foun_Misc_Config_Items_gne__c.getValues('SBCMdmSiperianEndPoint').Configuration_Value_gne__c + dml2Service.get(action);
        }
        return endPoint;
    }

    private static String createReqBody(Account acc, Address_vod__c address, DML_Type action) {
        HCORequest hr = new HCORequest(acc, address, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_INSERT);
        String jsonStr = JSON.serialize(hr);
        String jsonStrTns = jsonStr.replaceAll('"([^"]+)":', '"' + SERVICE_NAMESPACE + '$1":');
        System.debug(' jsonStrTns '+jsonStrTns);
        return jsonStrTns;
    }

    private static void performUpdateOnSFSide(HttpResponse response, Id accountId, Id addressId, String action) {
        if(response.getStatus() == 'OK' && response.getStatusCode() == 200 ) {
            String bodyInJSON = response.getBody().replaceAll(SERVICE_NAMESPACE, '');
            HCOResponse hco = (HCOResponse)JSON.deserializeStrict(bodyInJSON, HCOResponse.class);
            System.debug('bodyInJSON '+bodyInJSON);
            System.debug('response '+response);

            if(hco.Error == null) {
                Account acc = [SELECT MDMID_gne__c, MDM_Synch_Status_gne__c FROM Account WHERE Id = : accountId];
                Address_vod__c address = [SELECT MDM_Address_ID_gne__c FROM Address_vod__c WHERE Id = :addressId];
                String accMdmId = hco.getAccountMdmId(action);
                String addrMdmId = hco.getAddressMdmId(action);

                if(String.isNotBlank(accMdmId) && (acc.MDMID_gne__c != accMdmId ||
                   acc.MDM_Synch_Status_gne__c != GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED)
                  ) {
                    acc.MDMID_gne__c = accMdmId;
                    acc.MDM_Synch_Status_gne__c = GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED;
                    executeDML(DML_Type.DML_UPDATE, new List<Account>{acc});
                }
                if(String.isNotBlank(addrMdmId) && address.MDM_Address_ID_gne__c != addrMdmId) {
                    address.MDM_Address_ID_gne__c = addrMdmId;
                    executeDML(DML_Type.DML_UPDATE, new List<Address_vod__c>{address});
                }

            } else {
                System.debug(hco.Error.message );
            }

        } else {
            System.debug('Status Code: ' + response.getStatusCode());
        }
    }

    private static void executeDML(DML_Type action, List<sObject> records) {
        if(action == DML_Type.DML_INSERT){
            Database.SaveResult[] sResults = Database.insert(records, false);
            handleErrors(sResults);
        } else if (action == DML_Type.DML_UPDATE){
            Database.SaveResult[] sResults = Database.update(records, false);
            handleErrors(sResults);
        } else {
            System.debug('Unknow action type: '+ action);
        }
    }

    private static void handleErrors(List<Database.SaveResult> sResults){
        for(Database.SaveResult sr : sResults) {
            if(!sr.isSuccess()) {
                handleException(sr.getErrors());
            }
        }
    }

    private static void handleException(Database.Error[] errors) {
        for(Database.Error err : errors) {
            System.debug('DML Error: ' + err.getMessage());
        }
    }

    private static void logErrors(HttpRequest request, HttpResponse resp, Id accId) {
        Error_Log_gne__c errorLog = new Error_Log_gne__c();
        errorLog.Code_Type__c = 'Apex Class';
        errorLog.Error_Level_gne__c = 'Low';
        errorLog.Login_Time__c = System.now();
        errorLog.Object_Name__c = 'Account';
        errorLog.Snippet_Name__c = 'GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert';
        errorLog.Record_Id_gne__c = accId;
        errorLog.User_Name__c = UserInfo.getUserName() ;
        Boolean isErrorToSave = false;

        if(resp.getStatusCode() != 200) {
            isErrorToSave = true;
            errorLog.Error_Description__c = 'Status Code: '+ resp.getStatusCode();
            errorLog.Error_Description__c += '. EndPoint: '+ request.getEndpoint();
        } else {
            String bodyInJSON = resp.getBody().replaceAll(SERVICE_NAMESPACE, '');
            HCOResponse hco = (HCOResponse)JSON.deserializeStrict(bodyInJSON, HCOResponse.class);
            if(hco.putCreateHCOResponse == null && hco.putPpdateHCOResponse == null){
                isErrorToSave = true;
                errorLog.Error_Description__c = 'Empty Response from MDM';
            }
            if(hco.Error != null){
                isErrorToSave = true;
                errorLog.Error_Description__c = 'Status Code: '+ resp.getStatusCode();
                errorLog.Error_Description__c += '. Service Error: '+ hco.Error;
            }
        }
        if(isErrorToSave) {
            insert errorLog;
        }
    }

    private static Boolean isCriteriaForProcessMeet(Account acc) {
        Boolean isFeatureEnabled = GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled') != null
            && GNE_Foun_Misc_Config_Items_gne__c.getValues('SyncMdmEnabled').Configuration_Value_gne__c == 'Enabled';
        Boolean isRecordApplicable = recordTypesMap.containsKey(acc.RecordTypeId);

        return isFeatureEnabled && isRecordApplicable && (System.isBatch() || GNE_SFA2_Util.isFrmUser());
    }

    private static String getSiperianServiceNS(){
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('SBCMdmSiperianServiceNS') != null) {
            return GNE_Foun_Misc_Config_Items_gne__c.getValues('SBCMdmSiperianServiceNS').Configuration_Value_gne__c;
        }
        return SERVICE_DEFAULT_NAMESPACE;
    }

    private class HCOResponse{
        private ErrorData Error;
        private OrganizationDetails putCreateHCOResponse;
        private OrganizationDetails putPpdateHCOResponse;
        public String getAccountMdmId(String action) {
            String createAccountMdmId = action == DML_Type.DML_INSERT.Name() && putCreateHCOResponse != null ?
                putCreateHCOResponse.newOrganizationDetails.newOrganization.mdmId : null;
            String updateAccountMdmId = action == DML_Type.DML_UPDATE.Name() && putPpdateHCOResponse != null ?
                putPpdateHCOResponse.updatedOrganizationDetails.updatedOrganization.mdmId : null;
            return action == DML_Type.DML_INSERT.Name() ? createAccountMdmId : updateAccountMdmId;
        }

        public String getAddressMdmId(String action) {
            String createAddresMdmId = action == DML_Type.DML_INSERT.Name() && putCreateHCOResponse != null ?
                putCreateHCOResponse.newOrganizationDetails.newOrganization.mdmAddressId : null;
            String updateAddresMdmId = action == DML_Type.DML_UPDATE.Name() && putPpdateHCOResponse != null ?
                putPpdateHCOResponse.updatedOrganizationDetails.updatedOrganization.mdmAddressId : null;
            return action == DML_Type.DML_INSERT.Name() ? createAddresMdmId : updateAddresMdmId;
        }
    }

    private class OrganizationDetails{
        private Organization newOrganizationDetails;
        private Organization updatedOrganizationDetails;
    }

    private class Organization{
        private Details newOrganization;
        private Details updatedOrganization;
    }

    private class Details{
        private String mdmId;
        private String mdmAddressId;
    }

    private class ErrorData {
        private String code;
        private String message;
    }

    private class HCORequest {
        private String sfdcId;
        private String organizationName;
        private String status;
        private HOCReqOrgType orgType;
        private String streetAddress;
        private String cityName;
        private String stateCode;
        private String zipCode;
        private String sfdcAddressId;
        private String stewardshipCode;
        private String suiteNumber;
        private String latitude;
        private String longitude;
        ReqTeamCodes teamCode;

        public HCORequest(Account acc, Address_vod__c address, DML_Type action) {
            sfdcId = acc.Id;
            organizationName = acc.name;
            status = action == DML_Type.DML_INSERT ? 'Active' : acc.MDMID_Status_gne__c;
            orgType = new HOCReqOrgType();
            HOCReqCode rc = new HOCReqCode();
            rc.Code = recordTypesMap.get(acc.RecordTypeId).DeveloperName;
            rc.Value = acc.Account_Type_gne__c;
            orgType.orgTypeData.add(rc);
            streetAddress = address.Name;
            cityName = address.City_vod__c;
            stateCode = address.State_vod__c;
            zipCode = address.Zip_vod__c;
            sfdcAddressId = address.Id;
            stewardshipCode = acc.Stewardship_System_Name_gne__c;
            suiteNumber = address.Address_line_2_vod__c == null ? ' ' : address.Address_line_2_vod__c;
            latitude = address.Location_gne__Latitude__s == null ? ' ' : String.valueOf(address.Location_gne__Latitude__s);
            longitude = address.Location_gne__Longitude__s == null ? ' ' : String.valueOf(address.Location_gne__Longitude__s);
            teamCode = new ReqTeamCodes();
            teamCode.value = fetchTeamCodes(acc);
        }

        private Set<String> fetchTeamCodes(Account acc) {
            Set<String> teamCodes = new Set<String>();
            Id userId = System.isBatch() ? acc.OwnerId : UserInfo.getUserId();

            List<Territory2> userTerritories = GNE_SFA2_Util.getUserTerritories(userId);
            for(Territory2 uTerr : userTerritories) {
                if(String.isNotBlank(uTerr.Salesforce_Code_gne__c)) {
                    teamCodes.add(uTerr.Salesforce_Code_gne__c);
                }
            }

            if(teamCodes.isEmpty()) teamCodes.add('FRM');
            return teamCodes;
        }
    }

    private class ReqTeamCodes{
        Set<String> value;
    }

    private class HOCReqOrgType{
        List<HOCReqCode> orgTypeData = new List<HOCReqCode>();
    }

    private class HOCReqCode{
        String Code;
        String Value;
    }
}