public with sharing class GNE_DCR_Portal_Ctrl implements GNE_SFA2_S2S_Interface.RestServiceCallInterface {

    public GNE_DCR_Portal_Ctrl() {}

    public virtual System.Type getSelfClass() {
        return GNE_DCR_Portal_Ctrl.class;
    }

    @RemoteAction
    public static List<GNE_DCR_Util.DCRListWrapper> getDCRsBasedOnListView(Map<String, String> params, String whereConditions) {
        List<GNE_DCR_Util.DCRListWrapper> result = new List<GNE_DCR_Util.DCRListWrapper>();
        List<Id> dcrIds = new List<Id>();
        for(Change_Request_gne__c dcr : Database.query('SELECT Id FROM Change_Request_gne__c' + (whereConditions != null && whereConditions != '' ? ' ' + whereConditions : ''))) {
            dcrIds.add(dcr.Id);
        }
        DCRWithoutSharing dcrWS = new DCRWithoutSharing();

        result.addAll(dcrWS.getRecords(dcrIds));

        //Call to MA
        try {
            Map<String, String> maParams = new Map<String, String>{'object' => 'DCR', 'method' => 'getDCRList'};
            maParams.putAll(params);
            result.addAll(getDCRsListFromExternalSource(GNE_DCR_Util.MA_SYSTEM_NAME, GNE_DCR_Util.MA_FEATURE_DCR_GET_LIST, maParams));
        } catch (Exception ex) {
            System.debug(ex);
        }

        //Call to PACT
        try {
            result.addAll(getDCRsListFromExternalSource(GNE_DCR_Util.PACT_SYSTEM_NAME, GNE_DCR_Util.PACT_FEATURE_DCR_GET_LIST, params));
        } catch (Exception ex) {
            System.debug(ex);
        }

        return result;
    }

    public static List<GNE_DCR_Util.DCRListWrapper> getDCRsListFromExternalSource(String systemName, String featureName, Map<String, String> params) {
        List<GNE_DCR_Util.DCRListWrapper> result = new List<GNE_DCR_Util.DCRListWrapper>();
        
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(featureName)) {
            try {
                GNE_SFA2_S2S_Interface.ResponseInterface response = GNE_SFA2_S2S_ServiceEngine.callRestGetMethod(
                    systemName,
                    featureName,
                    new GNE_DCR_Portal_Ctrl(),
                    params,
                    GNE_DCR_Util.ResultDCRListWrapper.class);
                
                result.addAll((List<GNE_DCR_Util.DCRListWrapper>)response.getRecords());
            } catch(Exception ex) {
                throw ex;
            }
        }
        
        return result;
    }

    public String getRecordTypeDeveloperNamesMap() {
        Map<String, String> result = new Map<String, String>();
        for(RecordType r : [SELECT Name, DeveloperName FROM RecordType WHERE SobjectType = 'Change_Request_gne__c']) {
            result.put(r.Name, r.DeveloperName);
        }

        return JSON.serialize(result);
    }

    public without sharing class DCRWithoutSharing {

        DCRWithoutSharing() {}

        public List<GNE_DCR_Util.DCRListWrapper> getRecords(List<Id> dcrIds) {

            List<GNE_DCR_Util.DCRListWrapper> result = new List<GNE_DCR_Util.DCRListWrapper>();
            for(Change_Request_gne__c dcr : Database.query(GNE_DCR_Util.BASE_QUERY + ' WHERE Id IN :dcrIds')) {
                result.add(new GNE_DCR_Util.DCRListWrapper(dcr, null));
            }

            return result;
        }
    }

}