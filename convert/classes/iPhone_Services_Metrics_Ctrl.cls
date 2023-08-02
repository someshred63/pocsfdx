public with sharing class iPhone_Services_Metrics_Ctrl extends GNE_SFA2_Base_Ctrl {
    private static Map<String,String> chartNames = new Map<String,String>{
        'avgExecTime' => 'Avarage Time per Service',
        'avgCpuTime' => 'Avarage Cpu Time per Service',
        'avgSoqlTime' => 'Avarage SOQL and DML Time per Service',
        'size' => 'Number of service callouts'
    };
    
    private static Map<String,String> serviceShortNames = new Map<String,String> {
        'GetDeltaServicesResponseBuilder' => 'EnhDeltaService',
		'GetAccountCallDetailsResponseBuilder' => 'CallDetail',
		'GetAccountContactAffiliationsResponseBuilder' => 'ContactAff',
		'iPhoneGetDeletedRecordsResponseBuilder' => 'DeletedRec',
		'GetAccountEventCurriculumsResponseBuilder' => 'Curriculum',
		'GetAccountCallPFGDetailResponseBuilder' => 'CallPfgDetail',
		'GetAccountAffiliationsResponseBuilder' => 'Affiliation',
		'GetAccountContactsResponseBuilder' => 'Contact',
		'GetAccountTargetAndTiersResponseBuilder' => 'TaT',
		'GetAccountPrepInformationResponseBuilder' => 'PrepInfo',
		'GetAccountPrepStrategiesResponseBuilder' => 'PrepStrategy',
		'GetAccountDetailsResponseBuilder' => 'AccDetail',
		'GetAccountCallKeyMessagesResponseBuilder' => 'CallKeyMessage',
		'GetAccountCallsResponseBuilder' => 'Call',
		'NotificationResponseBuilder' => 'Notification',
		'GetAccountCallDiscussionsResponseBuilder' => 'CallDiscussion',
		'GetAccountBrandAffiliationResponseBuilder' => 'BrandAff',
		'iPhoneGetPFGtoUserAccProductQtyLimit' => 'PfgLimit',
		'GetBrandAffiliationFlexResponseBuilder' => 'BrandAffFlex',
		'GetAccountTerritoryFieldsResponseBuilder' => 'TSF',
		'GetAccountEventAttendeeResponseBuilder' => 'EventAttendee',
		'GetAccountCallSamplesResponseBuilder' => 'CallSample',
		'iPhoneGetAccountHINNumbersResponseBuilder' => 'HINNumber',
		'GetAccountAddressResponseBuilder' => 'AddressDetail',
		'GetAccountCallAttendeesResponseBuilder' => 'CallAttendee',
		'GetUsersResponseBuilder' => 'UserDetail',
		'iPhoneGetAccountDistributorsResponseBuilder' => 'Distributor',
		'GetAccountSurveyResponsesResponseBuilder' => 'SurveyResponse',
		'GetAccountMedicalCommResponseBuilder' => 'MedComm',
		'GetAccountTacticsResponseBuilder' => 'Tactic',
		'GetAccountDataChangeReqResponseBuilder' => 'DCR',
		'GetAccountSurveysResponseBuilder' => 'Survey',
		'GetAccountSpeakerTrainingsResponseBuilder' => 'SpeakerTraining',
		'GetAccountPlansResponseBuilder' => 'AccountPlan',
		'GetUserProductsConfigResponseBuilder' => 'ProductConfig',
		'GetProfileIdResponseBuilder' => 'ProfileId',
		'GetAccountSpeakerBureauMShipResponseBuilder' => 'SpeakerBureau',
		'GetAccountSocMembershipsResponseBuilder' => 'PrepSoc',
		'iPhone_Get_Account_MCEs_gne' => 'MCE',
		'iPhone_ManageAccount' => 'ManageAccount',
		'iPhone_ManageInteraction' => 'ManageCall',
		'UpdateContactExecutor' => 'UpdateContact',
		'CreateAccountDataChangeExecutor' => 'CreateAccountDataChange',
		'GetUserDetailsResponseBuilder' => 'UserDetail',
		'GetUserAccountsResponseBuilder' => 'Account',
		'GetUserQuestionnairesResponseBuilder' => 'Questionnaires',
		'ProductsResponseBuilder' => 'Product (new)',
		'GetUserPicklistsResponseBuilder' => 'Picklist',
		'GetConfigurationResponseBuilder' => 'Config',
		'GetTATASubTANotSupportAutoAsgmtResponseBuilder' => 'TATASubTANotSupportAutoAsgmt',
		'GetAccountCallPreCallsResponseBuilder' => 'PreCall',
		'GetUserRatingsConfigResponseBuilder' => 'UserRatings',
		'iPhone_Get_User_Preferences_gne' => 'Preference',
		'GetUserTerritoriesResponseBuilder' => 'Territory',
		'iPhone_SBC' => 'SBC'
		
    };
    
    @ReadOnly @RemoteAction 
    public static DataWrapper remoteActionDrawChart(String inputDataWrapperInJSON) {
        return (new iPhone_Services_Metrics_Ctrl()).drawChart(inputDataWrapperInJSON);
    }
    
    public iPhone_Services_Metrics_Ctrl(ApexPages.StandardController sctrl) {
        this();
    }
    
    public iPhone_Services_Metrics_Ctrl() {
        super();
    }
    
    protected override String getUiType() {
        return 'standard';
    }
    
    protected override Boolean pageDispatcher() {
        return true;
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
        this.params = params.clone();
        this.params.put('sObjectType', 'iPhone_Services_Log__c');
        return super.intInit(this.params);
    }
    
    protected virtual override void checkRecordAccess(RecordAccess rAccess) {
        // No validation, because no access is needed
    }
    
    protected override SObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        return new iPhone_Services_Log__c();
    }
    
    protected override GNE_SFA2_Base_Ctrl.RecordDescribe getRecordDescribe() {
        return new GNE_SFA2_Base_Ctrl.RecordDescribe(null, null, sObjectType, null, null, getRecordAccess(currentUser.id));
    }

    protected override GNE_SFA2_Base_Ctrl.RecordAccess getRecordAccess(String userId) {
        return new GNE_SFA2_Base_Ctrl.RecordAccess(true, true, true);
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }
    
    protected override GNE_SFA2_Base_Ctrl.Config getConfiguration(String recordTypeDeveloperName) {
        DataWrapper resultData = (DataWrapper)dataWrapper;
        getRecord(null);
        
        List<GNE_SFA2_Base_Ctrl.Button> buttons = new List<GNE_SFA2_Base_Ctrl.Button>();//{new GNE_SFA2_Base_Ctrl.Button('Refresh', 0, null)};
        
        GNE_SFA2_Base_Ctrl.Field blankSpace = new GNE_SFA2_Base_Ctrl.Field(null, null);
        blankSpace.changeToBlankSpace();
        
        List<GNE_SFA2_Base_Ctrl.Section> sections = new List<GNE_SFA2_Base_Ctrl.Section>{
            new GNE_SFA2_Base_Ctrl.Section('apiErrors', 'API Errors', 0, '', null),
            new GNE_SFA2_Base_Ctrl.Section('filter', 'Service Metrics Filter', 1, '', new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('profileMask', 'Profile Mask'),
                new GNE_SFA2_Base_Ctrl.Field('deltaOrInitialLoad', 'Service Mode'),
                new GNE_SFA2_Base_Ctrl.Field('userAlias', 'User Alias Mask'),
                new GNE_SFA2_Base_Ctrl.Field('lastNDays', 'Include Last N Days'),
                new GNE_SFA2_Base_Ctrl.Field('sfaBandOnly', 'SFA Brand Only?'),
	            new GNE_SFA2_Base_Ctrl.Field('countLimit', 'Callout Min Limit')
            })
        };
        
        for(String chartName : chartNames.keySet()) {
            sections.add(new GNE_SFA2_Base_Ctrl.Section(chartName, chartNames.get(chartName), sections.size(), '', null));
        }
        
        return new GNE_SFA2_Base_Ctrl.Config(GNE_SFA2_Base_Ctrl.VIEW_MODE, buttons, sections, new List<GNE_SFA2_Base_Ctrl.RelatedList>());
    }
    
    private DataWrapper drawChart(String inputDataWrapperInJSON) {
        this.dataWrapper = getDataWrapperInstance();
        Boolean isOk = false;

        try {
            this.inputDataWrapper = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, iPhone_Services_Metrics_Ctrl.DataWrapper.class);
            dataWrapper = intDrawChart();
            isOk = true;
        } catch (Exception ex) {
            handleException(ex);
        }

        dataWrapper.onActionFinish('drawChart');
        return (DataWrapper)dataWrapper;
    }
    
    private DataWrapper intDrawChart() {
        DataWrapper result = (DataWrapper)this.dataWrapper;
        DataWrapper inputData = (DataWrapper)this.inputDataWrapper;

        result.rows = new List<RowWrapper>();
        List<AggregateResult> aggRows = getAggregateData();
        
        for(AggregateResult aggRow : aggRows) {
            String serviceName = (String)aggRow.get('Service_name__c');
            Map<String,Object> values = new Map<String,Object>();
            
            for(String vType : new Set<String>{'avgExecTime', 'avgCpuTime', 'maxExecTime', 'size'}) {
                values.put(vType, aggRow.get(vType));
            }
            
            values.put('avgSoqlTime', ((Double)values.get('avgExecTime'))-((Double)values.get('avgCpuTime')));
            RowWrapper row = new RowWrapper(serviceShortNames.containsKey(serviceName) ? serviceShortNames.get(serviceName) : serviceName, values, serviceName);
            result.rows.add(row);
        }
        
        result.charts = new Map<String,ChartWrapper>();
        
        for(String chartName : chartNames.keySet()) {
            ChartWrapper cWrapper = new ChartWrapper(chartName, chartNames.get(chartName), 'Service', chartName=='size' ? 'Count' : 'Time [sec]');
            result.charts.put(chartName, cWrapper);
        }
        
        if(inputData.filter==null) {
            buildApiErrorsChart();
        }
        
        return result;
    }
    
    private void buildApiErrorsChart() {
        DataWrapper result = (DataWrapper)this.dataWrapper;
        result.charts.put('apiErrors', new ChartWrapper('apiErrors', 'Errors', 'Time', 'Number of Errors'));
        DateTime startDate = DateTime.newInstanceGmt(System.now().year()-2,1,1,0,0,0);
        
        List<iPhone_API_Errors__c> apiErrors = [
            SELECT CreatedDate, LastModifiedDate, CreatedBy.Profile.Name, CreatedBy.Alias, Request_Class__c, Request_Type__c, Request_Id__c
            FROM iPhone_API_Errors__c
            WHERE Application_Name__c = 'OTR'
                AND CreatedDate >= :startDate
            ORDER BY CreatedDate DESC
            LIMIT 100000
        ];
        
        String lastDateString = null;
        Set<String> visitedReqIds = new Set<String>();
        result.apiErrorRows = new List<RowWrapper>();
        
        for(iPhone_API_Errors__c apiErr : apiErrors) {
            String cDateString = apiErr.CreatedDate.formatGmt('yyyy-MM');
            String reqId = apiErr.Request_Id__c;
            
            if(reqId==null || visitedReqIds.contains(reqId)) {
                continue;
            } else {
                visitedReqIds.add(reqId);
                String otrVersion = reqId.substringAfter('_').substringAfter('_').substringBefore('_');       
                otrVersion = String.isNotBlank(otrVersion) ? otrVersion : 'Unknown';
                if(lastDateString!=cDateString) {
	                result.apiErrorRows.add(new RowWrapper(cDateString, new Map<String,Object>(), cDateString));
	            }
	            
	            RowWrapper row = result.apiErrorRows[result.apiErrorRows.size()-1];
	            row.values.put(otrVersion, (row.values.containsKey(otrVersion) ? (Integer)row.values.get(otrVersion) : 0) +1);
	            row.values.put('all', (row.values.containsKey('all') ? (Integer)row.values.get('all') : 0) +1);
	            lastDateString=cDateString;
            }
        }
    }
    
    private List<AggregateResult> getAggregateData() {
        DataWrapper inputData = (DataWrapper)this.inputDataWrapper;
        FilterWrapper filter = inputData.filter!=null ? inputData.filter : new FilterWrapper();
        Integer lastNDays = filter.getLastNDays();
        Date startDate = System.now().addDays(-lastNDays).dateGmt();
        
        return [
            SELECT Service_name__c, AVG(Execution_Time__c) avgExecTime, AVG(CPU_Time__c) avgCpuTime, count(Id) size, MAX(Execution_Time__c) maxExecTime
            FROM iPhone_Services_Log__c
            WHERE CreatedDate >= :startDate
                AND Is_using_delta__c IN :filter.getDeltaMode()
                AND CreatedBy.Profile.Name like :filter.getProfileMask()
                AND CreatedBy.Alias like :filter.getUserAliasMask()
            GROUP BY Service_name__c
            HAVING count(Id) >= :filter.getCountLimit()
            ORDER BY AVG(Execution_Time__c) DESC, Service_name__c
            LIMIT 200
            
        ];
    }
    
    private class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
        private Map<String,ChartWrapper> charts;
        private FilterWrapper filter;
        private List<RowWrapper> rows;
        private List<RowWrapper> apiErrorRows;
        
    }
    
    private class ChartWrapper {
        private String name;
        private String label;
        private String hTitle;
        private String vTitle;
        
        private ChartWrapper(String name, String label, String hTitle, String vTitle) {
            this.name = name;
            this.label = label;
            this.hTitle = hTitle;
            this.vTitle = vTitle;
        }
    }
    
    private class FilterWrapper {
        private String profileMask;
        private String userAlias;
        private Boolean sfaBandOnly;
        private Integer countLimit;
        private Integer lastNDays;
        private Boolean deltaOrInitialLoad; 
        
        private FilterWrapper() {}
        
        private String getProfileMask() {
            return sfaBandOnly==true ? 'GNE-SFA-%-CS' : String.isNotBlank(profileMask) ? ('%' + profileMask + '%') : '%';
        }
        
        private String getUserAliasMask() {
            return String.isNotBlank(userAlias) ? ('%' + userAlias + '%') : '%';
        }
        
        private Integer getCountLimit() {
            return countLimit!=null ? countLimit : 1;
        }
        
        private Integer getLastNDays() {
            return lastNDays!=null ? lastNDays : 7;
        }
        
        private Set<Boolean> getDeltaMode() {
            return deltaOrInitialLoad==null ? new Set<Boolean>{false,true} : new Set<Boolean>{deltaOrInitialLoad};
        }
    }
    
    private class RowWrapper {
        private String name;
        private Map<String,Object> values;
        private String label;
        
        private RowWrapper(String name, Map<String,Object> values, String label) {
            this.name = name;
            this.values = values;
            this.label = label;
        } 
    }
}