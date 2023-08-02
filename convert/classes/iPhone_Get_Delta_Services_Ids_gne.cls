/*
This service is used by OTR to determined which services should be called for which accounts in new delta mode.
*/
@RestResource(UrlMapping='/iPhoneGetDeltaServicesIds/*')
global with sharing class iPhone_Get_Delta_Services_Ids_gne {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds, List<String> deltaServicesToCheck, List<String> territoryIds) {
        return iPhone_Commons_gne.buildResponse(
            new GetDeltaServicesResponseBuilder(accountIds, lastSyncDate, deltaServicesToCheck, unixId),
            new DeltaServicesIdsRequest(lastSyncDate, unixId, accountIds, deltaServicesToCheck, territoryIds)
        );
    }

    private class DeltaServicesIdsRequest extends iPhone_Commons_gne.DefaultDeltaArgs implements iPhoneBase.RequestTestable2 {
      private List<String> territoryIds;
      private List<String> deltaServicesToCheck;

      private DeltaServicesIdsRequest(String lastSyncDate, String unixId, List<String> accountIds, List<String> deltaServicesToCheck, List<Id> territoryIds) {
        super(lastSyncDate, unixId, accountIds);
        this.territoryIds = territoryIds;
        this.deltaServicesToCheck = deltaServicesToCheck;
      }

      public void testRequest() {
        new GetDeltaServicesResponseBuilder(this.accountIds, this.lastSyncDate, this.deltaServicesToCheck, this.unixId).build(this);
      }

      public System.Type getRequestType() {
        return DeltaServicesIdsRequest.class;
      }
    }

    class GetDeltaServicesResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        private List<String> accountIds;
        private Set<String> deltaServicesToCheck;
        private String lastSyncDate;
        private String unixId;
        private Map<String, Object> otrSettingsCacheMap;
        private transient Map<String,String> debugInfo;
        private transient List<Territory2> territories;
        private transient User currentUser;

        public GetDeltaServicesResponseBuilder(List<String> accountIds, String lastSyncDate, List<String> deltaServicesToCheck, String unixId){
            this.accountIds = accountIds;
            this.lastSyncDate = lastSyncDate;
            this.deltaServicesToCheck = new Set<String>(deltaServicesToCheck);
            this.unixId = unixId;
            this.otrSettingsCacheMap = new Map<String, Object>();
            this.debugInfo = new Map<String,String>();
        }

        public iPhone_Commons_gne.RestResponse build(Object args) {
            DeltaServicesIdsRequest request = (DeltaServicesIdsRequest)args;
            Datetime lastSynchronized = Datetime.valueOfGmt(lastSyncDate);
            System.debug('Limits: DML Rows: '+Limits.getDmlRows()+'/'+Limits.getLimitDmlRows()+', Queries: '+Limits.getQueries()+'/'+Limits.getLimitQueries()+', Query rows: '+Limits.getQueryRows()+'/'+Limits.getLimitQueryRows()+', CPU Time: '+Limits.getCpuTime()+'/'+Limits.getLimitCpuTime());
            
            Map<String, Set<Id>> accountsToObjectTypeMap = new Map<String, Set<Id>>();
            
            if(deltaServicesToCheck.contains('iPhoneGetUserDetails') && !checkCloseToLimits()){
                logActionStart('iPhoneGetUserDetails');
                accountsToObjectTypeMap.putAll(iPhoneGetUserDetails(lastSynchronized, unixId));
                logActionEnd('iPhoneGetUserDetails');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountBrandAffiliations') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountBrandAffiliations');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountBrandAffiliations(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountBrandAffiliations');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountSurveyResponses') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountSurveyResponses');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountSurveyResponses(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountSurveyResponses');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountSurveys') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountSurveys');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountSurveys(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountSurveys');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCalls') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCalls');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCalls(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCalls');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallDetails') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallDetails');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallDetails(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallDetails');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallDiscussions') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallDiscussions');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallDiscussions(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallDiscussions');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountAffiliations') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountAffiliations');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountAffiliations(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountAffiliations');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountPlans') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountPlans');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountPlans(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountPlans');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountTactics') && !checkCloseToLimits()){
                logActionStart('iPhoneGetUserDetails');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountTactics(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetUserDetails');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountAddresses') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountAddresses');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountAddresses(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountAddresses');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountMedicalCommunications') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountMedicalCommunications');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountMedicalCommunications(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountMedicalCommunications');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountDataChangeRequests') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountDataChangeRequests');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountDataChangeRequests(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountDataChangeRequests');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallSamples') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallSamples');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallSamples(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallSamples');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountDetails') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountDetails');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountDetails(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountDetails');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallKeyMessages') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallKeyMessages');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallKeyMessages(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallKeyMessages');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountContacts') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountContacts');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountContacts(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountContacts');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountSpeakerTrainings') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountSpeakerTrainings');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountSpeakerTrainings(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountSpeakerTrainings');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountEventAttendees') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountEventAttendees');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountEventAttendees(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountEventAttendees');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountSpeakerBureauMemberships') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountSpeakerBureauMemberships');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountSpeakerBureauMemberships(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountSpeakerBureauMemberships');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountTargetAndTiers') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountTargetAndTiers');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountTargetAndTiers(accountIds, getUserInfo(unixId).Id, lastSynchronized));
                logActionEnd('iPhoneGetAccountTargetAndTiers');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountSocMemberships') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountSocMemberships');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountSocMemberships(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountSocMemberships');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountDistributors') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountDistributors');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountDistributors(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountDistributors');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountHINNumbers') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountHINNumbers');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountHINNumbers(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountHINNumbers');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountPrepInformation') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountPrepInformation');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountPrepInformation(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountPrepInformation');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountPrepStrategies') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountPrepStrategies');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountPrepStrategies(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountPrepStrategies');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountProfileIDLicence') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountProfileIDLicence');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountProfileIDLicence(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountProfileIDLicence');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallAttendees') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallAttendees');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallAttendees(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallAttendees');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallPreCalls') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallPreCalls');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallPreCalls(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallPreCalls');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallPFGDetail') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallPFGDetail');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallPFGDetail(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallPFGDetail');
            }
            if(deltaServicesToCheck.contains('iPhoneGetPFGtoUserAccProductQtyLimit') && !checkCloseToLimits()){
                logActionStart('iPhoneGetPFGtoUserAccProductQtyLimit');
                accountsToObjectTypeMap.putAll(iPhoneGetPFGtoUserAccProductQtyLimit(accountIds, request.territoryIds, lastSynchronized));
                logActionEnd('iPhoneGetPFGtoUserAccProductQtyLimit');
            }
            if(deltaServicesToCheck.contains('iPhoneGetAccountMCEs') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountMCEs');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountMCEs(accountIds, request.territoryIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountMCEs');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetUserPreferences') && !checkCloseToLimits()){
                logActionStart('iPhoneGetUserPreferences');
                accountsToObjectTypeMap.putAll(iPhoneGetUserPreferences(accountIds, getCurrentUser(this.unixId), lastSynchronized));
                logActionEnd('iPhoneGetUserPreferences');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetReferralMSLs') && !checkCloseToLimits()){
                logActionStart('iPhoneGetReferralMSLs');
                accountsToObjectTypeMap.putAll(iPhoneGetReferralMSLs(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetReferralMSLs');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetAccountMappings') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountMappings');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountMappings(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountMappings');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetAccountLicences') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountLicences');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountLicences(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountLicences');
            }

            if(deltaServicesToCheck.contains('iPhoneGetAccountTdddLicences') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountTdddLicences');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountTdddLicences(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountTdddLicences');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallInteractionDetails') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallInteractionDetails');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallInteractionDetails(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallInteractionDetails');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallCategories') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallCategories');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallCategories(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallCategories');
            }
            
            if(deltaServicesToCheck.contains('iPhoneGetAccountCallThreats') && !checkCloseToLimits()){
                logActionStart('iPhoneGetAccountCallThreats');
                accountsToObjectTypeMap.putAll(iPhoneGetAccountCallThreats(accountIds, lastSynchronized));
                logActionEnd('iPhoneGetAccountCallThreats');
            }
            
            
            // TODO: Add "try-catch" in case of a situation when we hit any of the limits
            // (if above verification mechanism failed) and send response to OTR that this
            // service has to be called again using 2 or 3... chunks of account ids
            
            // TODO2 (after tests, if needed): Add verification "where we are" about above limits and in case we are close
            // to any limit, break work, store savepoint (some custom flag) and send response
            // to OTR that this service needs to be called again (then we will use flag stored
            // few secons ago) to begin from where we stopped.
            
            return new GetDeltaServicesResponse(accountsToObjectTypeMap, debugInfo);
        }

        private void logActionStart(String actionName) {
          this.debugInfo.put(actionName + '-SOQLs', String.valueOf(Limits.getQueries()));
          this.debugInfo.put(actionName + '-SOQLRows', String.valueOf(Limits.getQueryRows()));
          this.debugInfo.put(actionName + '-ExecTime', String.valueOf(System.now().getTime()));
        }

        private void logActionEnd(String actionName) {
          String startSoqls = this.debugInfo.get(actionName + '-SOQLs');
          String startSoqlRows = this.debugInfo.get(actionName + '-SOQLRows');
          String startTime = this.debugInfo.get(actionName + '-ExecTime');

          if(String.isNotBlank(startSoqls)) {
            this.debugInfo.put(actionName + '-SOQLs', String.valueOf(Limits.getQueries() - Integer.valueOf(startSoqls)));
            this.debugInfo.put(actionName + '-SOQLRows', String.valueOf(Limits.getQueryRows() - Integer.valueOf(startSoqlRows)));
            this.debugInfo.put(actionName + '-ExecTime', String.valueOf(System.now().getTime() - Long.valueOf(startTime)));
          }
        }

        private User getUserInfo(String unixId){
            return iPhone_DAO.getUserByExternalId(unixId);
        }

        private Boolean checkCloseToLimits(){
            System.debug('Limits in method: DML Rows: '+Double.valueOf(Limits.getDmlRows())+'/'+Double.valueOf(Limits.getLimitDmlRows())+', Queries: '+Double.valueOf(Limits.getQueries())+'/'+Double.valueOf(Limits.getLimitQueries())+', Query rows: '+Double.valueOf(Limits.getQueryRows())+'/'+Double.valueOf(Limits.getLimitQueryRows())+', CPU Time: '+Double.valueOf(Limits.getCpuTime())+'/'+Double.valueOf(Limits.getLimitCpuTime()));
            System.debug('Limits factor method: DML Rows: '+Double.valueOf(Limits.getDmlRows())/Double.valueOf(Limits.getLimitDmlRows())+', Queries: '+Double.valueOf(Limits.getQueries())/Double.valueOf(Limits.getLimitQueries())+', Query rows: '+Double.valueOf(Limits.getQueryRows())/Double.valueOf(Limits.getLimitQueryRows())+', CPU Time: '+Double.valueOf(Limits.getCpuTime())/Double.valueOf(Limits.getLimitCpuTime()));
            Double defaultLimitRatio = 0.01;
            Double limitQueriesRatio = getServiceSettingValue('DeltaLimitQueriesRatio', defaultLimitRatio);
            Double limitQueryRowsRatio = getServiceSettingValue('DeltaLimitQueryRowsRatio', defaultLimitRatio);
            if(Double.valueOf(Limits.getQueries())/Double.valueOf(Limits.getLimitQueries()) > limitQueriesRatio || Double.valueOf(Limits.getQueryRows())/Double.valueOf(Limits.getLimitQueryRows()) > limitQueryRowsRatio){
                System.debug('Limits in method: DML Rows: '+Limits.getDmlRows()+'/'+Limits.getLimitDmlRows()+', Queries: '+Limits.getQueries()+'/'+Limits.getLimitQueries()+', Query rows: '+Limits.getQueryRows()+'/'+Limits.getLimitQueryRows()+', CPU Time: '+Limits.getCpuTime()+'/'+Limits.getLimitCpuTime());
                return true;
            }
            return false;
        }

        private Double getServiceSettingValue(String key, Double defaultValue){
            if (this.otrSettingsCacheMap.containsKey(key)){
                return Double.valueOf(this.otrSettingsCacheMap.get(key));
            }
            Double result = null;
            String value = iPhoneBase.getServiceSettingValue(key);

            if (String.isNotBlank(value)){
                result = doubleTryParse(value);
            }

            if (result == null){
                result = defaultValue;
            }
            this.otrSettingsCacheMap.put(key, result);
            return result;
        }

        private Double doubleTryParse(String valueStr){
            Double result = null;
            try{
                result = Double.valueOf(valueStr);
            } catch(Exception ex){}
            return result;
        }

        private Map<String, Set<Id>> iPhoneGetUserDetails(Datetime lastSynchronized, String unixId){
            Map<Id, User> sobjList = new Map<Id, User>([SELECT Id FROM User WHERE External_ID_gne__c = :unixId AND LastModifiedDate >= :lastSynchronized]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetUserDetails', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountBrandAffiliations(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Product_Metrics_vod__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountBrandAffiliations', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountSurveys(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account__c FROM Survey_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountSurveys', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountSurveyResponses(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Survey_Response_gne__c> childAccountIdsMap = new Map<Id, Survey_Response_gne__c>([SELECT Survey_gne__r.Account__r.Id FROM Survey_Response_gne__c WHERE LastModifiedDate >= :lastSynchronized AND Survey_gne__r.Account__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Survey_gne__r.Account__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountSurveyResponses', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCalls(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Call2_vod__c WHERE Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND Account_vod__c IN :accountIds)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCalls', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallDetails(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Call2_Detail_vod__c> childAccountIdsMap = new Map<Id, Call2_Detail_vod__c>([SELECT Call2_vod__r.Account_vod__r.Id FROM Call2_Detail_vod__c WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND Call2_vod__r.Account_vod__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Call2_vod__r.Account_vod__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallDetails', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallDiscussions(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Call2_Discussion_vod__c> childAccountIdsMap = new Map<Id, Call2_Discussion_vod__c>([SELECT Call2_vod__r.Account_vod__r.Id FROM Call2_Discussion_vod__c WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND Call2_vod__r.Account_vod__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Call2_vod__r.Account_vod__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallDiscussions', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallPreCalls(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Call_Pre_Call_gne__c> childAccountIdsMap = new Map<Id, Call_Pre_Call_gne__c>([SELECT Call_gne__r.Account_vod__c FROM Call_Pre_Call_gne__c WHERE Call_gne__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call_gne__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND Call_gne__r.Account_vod__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Call_gne__r.Account_vod__c);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallPreCalls', childAccountIds);
            return accountIdsToObjectNameMap;
        }


        private Map<String, Set<Id>> iPhoneGetAccountCallSamples(List<String> accountIds, Datetime lastSynchronized){
            Set<Id> resultAccountIds = new Set<Id>();
            for (Call2_Sample_vod__c sampleRecord : [SELECT Call2_vod__r.Parent_Call_vod__c, Call2_vod__r.Account_vod__c, Call2_vod__r.Parent_Call_vod__r.Account_vod__c FROM Call2_Sample_vod__c WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND (
                Call2_vod__r.Parent_Call_vod__r.Account_vod__c IN :accountIds OR Call2_vod__r.Account_vod__c IN :accountIds)]) {
                if (sampleRecord.Call2_vod__r.Parent_Call_vod__c == null){
                    resultAccountIds.add(sampleRecord.Call2_vod__r.Account_vod__c);
                } else {
                    resultAccountIds.add(sampleRecord.Call2_vod__r.Parent_Call_vod__r.Account_vod__c);
                }
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
          accountIdsToObjectNameMap.put('iPhoneGetAccountCallSamples', resultAccountIds);
          return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountAffiliations(List<String> accountIds, Datetime lastSynchronized){
            Set<Id> resultAccountIds = new Set<Id>();
            for (Affiliation_vod__c aff : [SELECT From_Account_vod__c FROM Affiliation_vod__c WHERE From_Account_vod__c IN :accountIds AND (LastModifiedDate >= :lastSynchronized OR To_Account_vod__r.iPhone_Fields_LastModifiedDate_gne__c >= :lastSynchronized)]){
                resultAccountIds.add(aff.From_Account_vod__c);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountAffiliations', resultAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountPlans(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Account_Plan_vod__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountPlans', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountTactics(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Account_Tactic_vod__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountTactics', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountAddresses(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Address_vod__c WHERE CreatedDate >= :lastSynchronized OR iPhone_Fields_LastModifiedDate_gne__c >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountAddresses', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountMedicalCommunications(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM Medical_Communication_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountMedicalCommunications', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountDataChangeRequests(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM Change_Request_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountDataChangeRequests', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountDetails(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND (CreatedDate >= :lastSynchronized OR iPhone_Fields_LastModifiedDate_gne__c >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountDetails', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallKeyMessages(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Call2_Key_Message_vod__c WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallKeyMessages', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountContacts(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Contact> childAccountIdsMap = new Map<Id, Contact>([SELECT Account.Id FROM Contact WHERE LastModifiedDate >= :lastSynchronized AND Account.Id IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Account.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountContacts', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountSpeakerTrainings(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Speaker_Training_gne__c> childAccountIdsMap = new Map<Id, Speaker_Training_gne__c>([SELECT Interaction_ID_gne__r.Account_vod__r.Id FROM Speaker_Training_gne__c WHERE LastModifiedDate >= :lastSynchronized AND Interaction_ID_gne__r.Account_vod__r.Id IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Interaction_ID_gne__r.Account_vod__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountSpeakerTrainings', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountEventAttendees(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_vod__c FROM Event_Attendee_vod__c WHERE LastModifiedDate >= :lastSynchronized OR Medical_Event_vod__r.LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountEventAttendees', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountSpeakerBureauMemberships(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Speaker_Bureau_Membership_gne__c> childAccountIdsMap = new Map<Id, Speaker_Bureau_Membership_gne__c>([SELECT Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE LastModifiedDate >= :lastSynchronized AND Bureau_Member_gne__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Bureau_Member_gne__c);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountSpeakerBureauMemberships', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountTargetAndTiers(List<String> accountIds, Id userId, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>();
            Set<String> userTerritoriesNames = new Set<String>();
            for (Territory2 territory : [SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId)]){
                userTerritoriesNames.add(territory.Name);
            }
            if (userTerritoriesNames.size() > 0){
                Boolean newUserProductActivated = false;
                Set<Id> userProductIds = new Set<Id>();
                for (My_Setup_Products_vod__c userProduct : [SELECT Id, Product_vod__r.Id, CreatedDate, LastModifiedDate FROM My_Setup_Products_vod__c WHERE OwnerId = :userId AND Product_vod__r.Id != NULL]){
                    userProductIds.add(userProduct.Product_vod__r.Id);
                    if (newUserProductActivated == false){
                        newUserProductActivated = userProduct.CreatedDate >= lastSynchronized;
                    }
                }
                if (userProductIds.size() > 0){
                    if (newUserProductActivated == true){
                        sobjList.putAll([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_can_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Account_can_gne__c IN :accountIds AND Territory_gne__c IN :userTerritoriesNames AND Product_Catalog_gne__c IN :userProductIds)]);
                    } else {
                        sobjList.putAll([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_can_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Account_can_gne__c IN :accountIds AND Territory_gne__c IN :userTerritoriesNames AND Product_Catalog_gne__c IN :userProductIds AND LastModifiedDate >= :lastSynchronized)]);
                    }
                }
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountTargetAndTiers', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountSocMemberships(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM SFA2_Account_Society_Membership_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountSocMemberships', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountDistributors(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_ref_gne__c FROM Distributor_fpm_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountDistributors', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountHINNumbers(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_ref_gne__c FROM HIN_Number_fpm_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountHINNumbers', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountPrepInformation(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM SFA2_PREP_Account_Testing_Info_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountPrepInformation', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountPrepStrategies(List<String> accountIds, Datetime lastSynchronized){
            Set<Id> resultAccountIds = new Set<Id>();
            for (SFA2_PREP_Account_Testing_Strategy_gne__c prepTestingStrategy : [SELECT Account_gne__c FROM SFA2_PREP_Account_Testing_Strategy_gne__c WHERE Account_gne__c IN :accountIds AND Id IN (SELECT Account_Testing_Strategy_gne__c FROM SFA2_PREP_Account_MBO_gne__c WHERE LastModifiedDate >= :lastSynchronized)]){
                resultAccountIds.add(prepTestingStrategy.Account_gne__c);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountPrepStrategies', resultAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountProfileIDLicence(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_Name_gne__c FROM ProfileID_License_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountProfileIDLicence', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallAttendees(List<String> accountIds, Datetime lastSynchronized){
            Set<Id> resultAccountIds = new Set<Id>();
            for (Call2_vod__c attendeeRecord : [SELECT Parent_Call_vod__r.Account_vod__c FROM Call2_vod__c WHERE Parent_Call_vod__c != NULL AND Parent_Call_vod__r.Account_vod__c IN :accountIds AND Parent_Call_vod__r.Parent_Call_vod__c = NULL AND Parent_Call_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Parent_Call_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND EMS_International_Speaker_gne__c = NULL AND (LastModifiedDate >= :lastSynchronized OR Account_vod__r.iPhone_Fields_LastModifiedDate_gne__c >= :lastSynchronized OR Contact_vod__r.LastModifiedDate >= :lastSynchronized)]){
                resultAccountIds.add(attendeeRecord.Parent_Call_vod__r.Account_vod__c);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallAttendees', resultAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallPFGDetail(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM Call_PFG_Detail_gne__c WHERE Account_gne__c IN :accountIds AND Call_gne__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call_gne__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallPFGDetail', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetPFGtoUserAccProductQtyLimit(List<String> accountIds, List<String> territoryIds, Datetime lastSynchronized){
            Set<Id> resultAccIds = new Set<Id>();
            List<SFA2_PFG_Product_Limit_gne__c> pfgProdLimit = [SELECT Id FROM SFA2_PFG_Product_Limit_gne__c WHERE LastModifiedDate >= :lastSynchronized LIMIT 1];

            if(!pfgProdLimit.isEmpty()) {
                for(String accId : accountIds) {
                    resultAccIds.add(accId);
                }
            } else {
                List<Territory2> terrs = getTerritories(territoryIds);
                Set<String> terrNames = new Set<String>();

                for(Territory2 terr : terrs) {
                    terrNames.add(terr.Name);
                }

                List<SFA2_PFG_to_Territory_Detail_gne__c> pfgToTerrs = [SELECT Id FROM SFA2_PFG_to_Territory_Detail_gne__c WHERE Territory_Name_gne__c IN :terrNames AND LastModifiedDate >= :lastSynchronized];

                if(!pfgToTerrs.isEmpty()) {
                    for(String accId : accountIds) {
                        resultAccIds.add(accId);
                    }
                } else {
                    Map<Id, Account> sobjList = new Map<Id, Account>([
                      SELECT Id
                      FROM Account
                      WHERE Id IN :accountIds
                        AND Id IN (SELECT Account_gne__c FROM PFG_Staging_Account_Limit_Exception_gne__c WHERE Account_gne__c IN :accountIds AND LastModifiedDate >= :lastSynchronized)
                    ]);

                    sobjList.putAll(new Map<Id,Account>([
                      SELECT Id
                      FROM Account
                      WHERE Id IN :accountIds
                        AND Id IN (SELECT Account_gne__c FROM SFA2_PFG_to_Account_Detail_gne__c WHERE Account_gne__c IN :accountIds AND LastModifiedDate >= :lastSynchronized)
                    ]));

                    resultAccIds = sobjList.keySet();
                }
            }

            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
          accountIdsToObjectNameMap.put('iPhoneGetPFGtoUserAccProductQtyLimit', resultAccIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountMCEs(List<String> accountIds, List<String> territoryIds, Datetime lastSynchronized) {
          Set<String> teamCodes = new Set<String>();
          Set<String> subTeamCodes = new Set<String>();

          if(territoryIds!=null && !territoryIds.isEmpty()) {
            List<Territory2> terrs = getTerritories(territoryIds);

            for(Territory2 terr : terrs) {
              teamCodes.add(terr.Salesforce_Code_gne__c);
              subTeamCodes.add(terr.Salesforce_SubTeam_Code_gne__c);
            }
          }

          Map<Id, Account> sobjList = new Map<Id, Account>([
            SELECT Id
            FROM Account
            WHERE Id IN :accountIds
              AND Id IN (SELECT Account_gne__c
                         FROM MCE_gne__c
                         WHERE Account_gne__c IN :accountIds
                          AND LastModifiedDate >= :lastSynchronized
                          AND Team_Code_gne__c IN :teamCodes
                          AND Subteam_Code_gne__c IN :subTeamCodes)
          ]);

          Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
          accountIdsToObjectNameMap.put('iPhoneGetAccountMCEs', sobjList.keySet());
          return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetUserPreferences(List<String> accountIds, User user, Datetime lastSynchronized) {
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM User_Preference_gne__c WHERE User_gne__c = :user.Id AND Account_gne__c IN :accountIds AND LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetUserPreferences', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetReferralMSLs(List<String> accountIds, Datetime lastSynchronized) {
            Set<Id> ids = new Set<Id>();

            if(GNE_SFA2_ReferralUtil.isRosterChanged(lastSynchronized)) {
                ids.add(UserInfo.getUserId());
            }

            return new Map<String, Set<Id>>{'iPhoneGetReferralMSLs' => ids};
        }

        private Map<String, Set<Id>> iPhoneGetAccountMappings(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, FRM_HCO_Mapping_gne__c> childAccountIdsMap = new Map<Id, FRM_HCO_Mapping_gne__c>([SELECT FRM_HCO_Account_gne__c FROM FRM_HCO_Mapping_gne__c WHERE LastModifiedDate >= :lastSynchronized AND FRM_HCO_Account_gne__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).FRM_HCO_Account_gne__c);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountMappings', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountLicences(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM Prescriber_License_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountLicences', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountTdddLicences(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Account> sobjList = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds AND Id IN (SELECT Account_gne__c FROM TDDD_License_gne__c WHERE LastModifiedDate >= :lastSynchronized)]);
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountTdddLicences', sobjList.keySet());
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallThreats(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Call2_Threat_vod__c> childAccountIdsMap = new Map<Id, Call2_Threat_vod__c>([
                SELECT Call2_vod__r.Account_vod__r.Id 
                FROM Call2_Threat_vod__c 
                WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 
                    AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 
                AND LastModifiedDate >= :lastSynchronized 
                AND Call2_vod__r.Account_vod__c IN :accountIds
            ]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Call2_vod__r.Account_vod__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallThreats', childAccountIds);
            return accountIdsToObjectNameMap;
        }


        private List<Territory2> getTerritories(List<String> territoryIds) {
            if(territories==null) {
                territories = iPhone_DAO.getTerritories(territoryIds);
            }

            return territories;
        }

        private User getCurrentUser(String unixId) {
            if(currentUser==null) {
                currentUser = String.isNotBlank(unixId) ? iPhone_DAO.getUserByExternalId(unixId) : new User(Id = UserInfo.getUserId());
            }

            return currentUser;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallInteractionDetails(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Call2_Interaction_Detail_vod__c> childAccountIdsMap = new Map<Id, Call2_Interaction_Detail_vod__c>([SELECT Call2_vod__r.Account_vod__r.Id FROM Call2_Interaction_Detail_vod__c WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND Call2_vod__r.Account_vod__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Call2_vod__r.Account_vod__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallInteractionDetails', childAccountIds);
            return accountIdsToObjectNameMap;
        }

        private Map<String, Set<Id>> iPhoneGetAccountCallCategories(List<String> accountIds, Datetime lastSynchronized){
            Map<Id, Call2_Category_vod__c> childAccountIdsMap = new Map<Id, Call2_Category_vod__c>([SELECT Call2_vod__r.Account_vod__r.Id FROM Call2_Category_vod__c WHERE Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 AND LastModifiedDate >= :lastSynchronized AND Call2_vod__r.Account_vod__c IN :accountIds]);
            Set<Id> childAccountIds = new Set<Id>();
            for(Id objectId : childAccountIdsMap.keySet()){
                childAccountIds.add(childAccountIdsMap.get(objectId).Call2_vod__r.Account_vod__r.Id);
            }
            Map<String, Set<Id>> accountIdsToObjectNameMap = new Map<String, Set<Id>>();
            accountIdsToObjectNameMap.put('iPhoneGetAccountCallCategories', childAccountIds);
            return accountIdsToObjectNameMap;
        }
    }

    public class GetDeltaServicesResponse extends iPhone_Commons_gne.RestResponse {

        public Map<String, Set<Id>> accountsToObjectMap;

        public GetDeltaServicesResponse(Map<String, Set<Id>> accountsToObjectTypeMap, Map<String, String> debugInfo) {
            this.accountsToObjectMap = accountsToObjectTypeMap;

            if(debugInfo!=null) {
              this.debugInfo.putAll(debugInfo);
            }
        }
    }
}