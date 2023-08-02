public virtual class GNE_SFA2_S2S_ServiceEngine implements GNE_SFA2_S2S_Interface.EngineInterface, GNE_SFA2_Scheduler.Schedulable {
    private Enum HttpMethod {GET, POST}
    
    private static GNE_SFA2_S2S_Interface.EngineInterface sEngine;
    
    protected transient String externalSystem;
    protected transient String feature;
    protected transient String serviceName;
    protected transient String hMethod;
    protected transient Map<String,String> params;
    protected transient GNE_SFA2_S2S_Interface.RestServiceInterface service;
    protected transient GNE_SFA2_S2S_Interface.RequestInterface request;
    protected transient GNE_SFA2_S2S_Interface.ResponseInterface response;
    protected transient GNE_SFA2_S2S_Interface.RecordInterface rec;
    protected transient Boolean isCallOrExecute;
    protected transient DebugInfo dInfo;
    protected transient Map<String,GNE_SFA2_S2S_Interface.DebugActionInterface> debugActions;
    
    public static GNE_SFA2_S2S_Interface.EngineInterface getServiceEngine() {
        if(sEngine==null) {
            sEngine = new GNE_SFA2_S2S_ServiceEngine();
        }
        
        return sEngine;
    }
    
    public static void setServiceEngine(GNE_SFA2_S2S_Interface.EngineInterface serviceEngine) {
        sEngine = serviceEngine;
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestPostMethod(String externalSystem, String feature,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature).callRestPostMethod(service, request, null, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestPostMethod(String externalSystem, String feature, String serviceName,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature, serviceName).callRestPostMethod(service, request, null, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestPostMethod(String externalSystem, String feature,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, Map<String,String> params, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature).callRestPostMethod(service, request, params, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestPostMethod(String externalSystem, String feature, String serviceName,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, Map<String,String> params, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature, serviceName).callRestPostMethod(service, request, params, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestGetMethod(String externalSystem, String feature,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature).callRestGetMethod(service, null, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestGetMethod(String externalSystem, String feature, String serviceName,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature, serviceName).callRestGetMethod(service, null, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestGetMethod(String externalSystem, String feature,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, Map<String,String> params, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature).callRestGetMethod(service, params, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface callRestGetMethod(String externalSystem, String feature, String serviceName,
            GNE_SFA2_S2S_Interface.RestServiceCallInterface service, Map<String,String> params, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature, serviceName).callRestGetMethod(service, params, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface executeRestPostMethod(String externalSystem, String feature,
            GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature).executeRestPostMethod(service, request, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface executeRestPostMethod(String externalSystem, String feature, String serviceName,
            GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature, serviceName).executeRestPostMethod(service, request, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface executeRestGetMethod(String externalSystem, String feature,
            GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature).executeRestGetMethod(service, responseClass);
    }
    
    public static GNE_SFA2_S2S_Interface.ResponseInterface executeRestGetMethod(String externalSystem, String feature, String serviceName,
            GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, System.Type responseClass) {
        return getServiceEngine().initServiceEngine(externalSystem, feature, serviceName).executeRestGetMethod(service, responseClass);
    }
    
    public GNE_SFA2_S2S_ServiceEngine() {}
    
    public virtual GNE_SFA2_S2S_Interface.EngineInterface initServiceEngine(String externalSystem, String feature) {
        return initServiceEngine(externalSystem, feature, null);
    }
    
    public virtual GNE_SFA2_S2S_Interface.EngineInterface initServiceEngine(String externalSystem, String feature, String serviceName) {
        this.externalSystem = externalSystem;
        this.feature = feature;
        this.serviceName = String.isNotBlank(serviceName) ? serviceName : GNE_SFA2_S2S_Config.getServiceName(this.feature);
        return this;
    }
    
    public virtual System.Type getSelfClass() {
        return GNE_SFA2_S2S_ServiceEngine.class;
    }
    
    public virtual String getExternalSystemName() {
        return this.externalSystem;
    }
    
    public virtual String getFeatureName() {
        return this.feature;
    }
    
    public virtual String getServiceName() {
        return this.serviceName;
    }
    
    public virtual String getHttpMethod() {
        return this.hMethod;
    }
    
    public virtual Map<String,String> getParams() {
        if(this.params==null) {
            this.params = new Map<String,String>();
        }
        
        return this.params;
    }
    
    public virtual GNE_SFA2_S2S_Interface.RestServiceInterface getService() {
        return this.service;
    }
    
    public virtual String getServiceProperty(String propName) {
        Map<String,String> serviceProps = (Map<String,String>)GNE_SFA2_S2S_Config.getServiceProperties(getExternalSystemName(), getFeatureName(), getServiceName());
        return serviceProps.get(propName);
    }
    
    public virtual GNE_SFA2_S2S_Interface.RequestInterface getRequest() {
        return this.request;
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface getResponse() {
        return this.response;
    }
    
    public virtual String getLocalId() {
        return this.rec!=null ? this.rec.getLocalId() : null;
    }
    
    public virtual String getExtId() {
        return this.rec!=null ? this.rec.getExtId() : null;
    }
    
    public virtual Boolean isCallOrExecute() {
        return this.isCallOrExecute==true;
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface callRestPostMethod(GNE_SFA2_S2S_Interface.RestServiceCallInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, System.Type responseClass) {
        return callRestMethod(service, HttpMethod.POST, request, null, responseClass);
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface callRestPostMethod(GNE_SFA2_S2S_Interface.RestServiceCallInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, Map<String,String> params, System.Type responseClass) {
        return callRestMethod(service, HttpMethod.POST, request, params, responseClass);
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface callRestGetMethod(GNE_SFA2_S2S_Interface.RestServiceCallInterface service, System.Type responseClass) {
        return callRestMethod(service, HttpMethod.GET, null, null, responseClass);
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface callRestGetMethod(GNE_SFA2_S2S_Interface.RestServiceCallInterface service, Map<String,String> params, System.Type responseClass) {
        return callRestMethod(service, HttpMethod.GET, null, params, responseClass);
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface executeRestPostMethod(GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, GNE_SFA2_S2S_Interface.RequestInterface request, System.Type responseClass) {
        return executeRestMethod(service, HttpMethod.POST, request, RestContext.request!=null ? RestContext.request.params : null, responseClass);
    }
    
    public virtual GNE_SFA2_S2S_Interface.ResponseInterface executeRestGetMethod(GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, System.Type responseClass) {
        return executeRestMethod(service, HttpMethod.GET, null, RestContext.request!=null ? RestContext.request.params : null, responseClass);
    }
    
    protected virtual GNE_SFA2_S2S_Interface.ResponseInterface callRestMethod(GNE_SFA2_S2S_Interface.RestServiceCallInterface service, HttpMethod hMethod, GNE_SFA2_S2S_Interface.RequestInterface request, Map<String,String> params, System.Type responseClass) {
        initService(service, hMethod, request, params, responseClass, true);
        
        try {
            if(!GNE_SFA2_S2S_Config.isFeatureEnabled(getFeatureName())) {
                throw GNE_SFA2_S2S_Util.createException((String.isBlank(getFeatureName()) ? 'S2S' : getFeatureName()) + 'Disabled');
            }
        
            onRestEngineStart();
            
            List<String> paramKeysAndValues = new List<String>();
            
            if(params!=null) {
                for(String key : params.keySet()) {
                    String val = params.get(key);
                    paramKeysAndValues.add(key + '=' + (val!=null ? EncodingUtil.urlEncode(val, 'UTF-8') : ''));
                }
            }
            
            HttpRequest req = new HttpRequest();
            String endPoint = String.format('callout:{0}/services/apexrest/{1}', new String[]{
                getNamedCredentialKey(),
                getServiceName() 
            });

            endPoint += !paramKeysAndValues.isEmpty() ? ('?' + String.join(paramKeysAndValues, '&')) : '';
            req.setEndpoint(endPoint);
            req.setMethod(hMethod.name());
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);
            
            if(request!=null) {
                if(request.getActor()==null) {
                    GNE_SFA2_S2S_Util.Actor currentUser = new GNE_SFA2_S2S_Util.Actor(UserInfo.getUserId());
                    currentUser.fetchWithLocalUser();
                    request.setActor(currentUser);
                }
                Map<String,Object> requestUntyped = new Map<String,Object>{
                    'object' => getServiceProperty('object'),
                    'method' => getServiceProperty('method'),
                    'request' => request
                };
                System.debug(JSON.serialize(requestUntyped));
                req.setBody(JSON.serialize(requestUntyped));
            } else if(hMethod==HttpMethod.POST) {
                req.setHeader('Content-Length', '0');
            }
            
            HTTPResponse res = (new Http()).send(req);
            System.debug('res.getStatus()=' + res.getStatus());
            System.debug('res.getStatusCode()=' + res.getStatusCode());
            System.debug('res.getBody()=' + res.getBody());
            
            if(res.getStatus()=='OK' && res.getStatusCode()==200) {
                Map<String,Object> responseUntyped = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                if(responseUntyped.containsKey('responseStatusCode')) {
                    if(responseUntyped.get('responseStatusCode')!='200') {
                        throw new GNE_SFA2_S2S_Util.HttpException((String)responseUntyped.get('responseStatusCode'), (String)responseUntyped.get('responseMessage'));
                    } else if(responseUntyped.get('resultData')!=null) {
                        response = (GNE_SFA2_S2S_Interface.ResponseInterface)JSON.deserialize(JSON.serialize(responseUntyped.get('resultData')), responseClass);
                    }
                } else {
                    response = (GNE_SFA2_S2S_Interface.ResponseInterface)JSON.deserialize(res.getBody(), responseClass);
                }   
            } else {
                throw new GNE_SFA2_S2S_Util.HttpException(res.getStatusCode()!=null ? String.valueOf(res.getStatusCode()) : null, res.getStatus());
            }
        } catch(Exception ex) {
            onRestEngineError(ex);
        } finally {
            onRestEngineFinish();
        }
        
        return response;
    }
    
    protected virtual void initService(GNE_SFA2_S2S_Interface.RestServiceInterface service, HttpMethod hMethod, GNE_SFA2_S2S_Interface.RequestInterface request, Map<String,String> params, System.Type responseClass, Boolean isCallOrExecute) {
        this.service = service;
        this.hMethod = hMethod.name();
        this.request = request;
        this.params = params;
        this.response = (GNE_SFA2_S2S_Interface.ResponseInterface)responseClass.newInstance();
        this.isCallOrExecute = isCallOrExecute;
    }
    
    protected virtual String getNamedCredentialKey() {
        String namedCredentialBase = GNE_SFA2_S2S_Config.getNamedCredential(getExternalSystemName(), getFeatureName());
        String perUserNC = String.format('{0}_{1}', new String[]{namedCredentialBase, GNE_SFA2_S2S_Util.PER_USER_TAG});
        Boolean usePerUserCredential = ![select Id from ExternalDataUserAuth WHERE UserId = :UserInfo.getUserId() AND ExternalDataSource.Name = :perUserNC LIMIT 1].isEmpty();
        return usePerUserCredential && testConnection(perUserNC) ? perUserNC : namedCredentialBase;
    }
    
    protected virtual Boolean testConnection(String namedCredential) {
        Boolean isOK = false;
        
        try {
            HttpRequest testReq = new HttpRequest();
            testReq.setEndpoint(String.format('callout:{0}/services/data/v33.0', new String[]{namedCredential}));
            testReq.setMethod('GET');
            Http http = new Http();
            HTTPResponse testRes = http.send(testReq);
            isOK = testRes.getStatus()!='Unauthorized' && testRes.getStatusCode()!=401; 
        } catch(Exception ex) {}
        
        return isOk;
    }
    
    protected virtual GNE_SFA2_S2S_Interface.ResponseInterface executeRestMethod(GNE_SFA2_S2S_Interface.RestServiceExecuteInterface service, HttpMethod hMethod, GNE_SFA2_S2S_Interface.RequestInterface request, Map<String,String> params, System.Type responseClass) {
        initService(service, hMethod, request, params, responseClass, false);
        System.Savepoint sp = null;
        Boolean isOk = false;
        
        try {
            if(!GNE_SFA2_S2S_Config.isFeatureEnabled(getFeatureName())) {
                throw GNE_SFA2_S2S_Util.createException((String.isBlank(getFeatureName()) ? 'S2S' : getFeatureName()) + 'Disabled');
            }
            
            sp = Database.setSavepoint();
            onRestEngineStart();
            onExecuteRestMethod();
            isOk = true;
        } catch(Exception ex) {
            onRestEngineError(ex);
        } finally {
            if(!isOK && sp!=null) {
                Database.rollback(sp);
            }
            
            onRestEngineFinish();
        }
        
        return response; 
    }
    
    protected virtual GNE_SFA2_S2S_Interface.RestServiceCallInterface getCallService() {
        return getService()!=null && getService() instanceof GNE_SFA2_S2S_Interface.RestServiceCallInterface ? (GNE_SFA2_S2S_Interface.RestServiceCallInterface)getService() : null;
    }
    
    protected virtual GNE_SFA2_S2S_Interface.RestServiceExecuteInterface getExecuteService() {
        return getService()!=null && getService() instanceof GNE_SFA2_S2S_Interface.RestServiceExecuteInterface ? (GNE_SFA2_S2S_Interface.RestServiceExecuteInterface)getService() : null;
    }
    
    protected virtual GNE_SFA2_S2S_Interface.EngineListenerInterface getListener() {
        return getService()!=null && getService() instanceof GNE_SFA2_S2S_Interface.EngineListenerInterface ? (GNE_SFA2_S2S_Interface.EngineListenerInterface)getService() : null;
    }
    
    protected virtual GNE_SFA2_S2S_Interface.EngineErrorListenerInterface getErrorListener() {
        return getService()!=null && getService() instanceof GNE_SFA2_S2S_Interface.EngineErrorListenerInterface ? (GNE_SFA2_S2S_Interface.EngineErrorListenerInterface)getService() : null;
    }
    
    protected virtual GNE_SFA2_S2S_Interface.EngineLogListenerInterface getLogListener() {
        return getService()!=null && getService() instanceof GNE_SFA2_S2S_Interface.EngineLogListenerInterface ? (GNE_SFA2_S2S_Interface.EngineLogListenerInterface)getService() : null;
    }
    
    protected virtual void onRestEngineError(Exception ex) {
        response.addError(getLocalId(), getExtId(), ex instanceof GNE_SFA2_S2S_Interface.S2SExceptionInterface ? ((GNE_SFA2_S2S_Interface.S2SExceptionInterface)ex).getStatusCode() : ex.getTypeName(), ex.getMessage(), ex.getStackTraceString());
        
        if(getErrorListener()!=null) {
            getErrorListener().onRestEngineError(ex, this);
        }
    }
    
    public virtual GNE_SFA2_S2S_Interface.DebugInfoInterface getDebugInfo() {
        if(this.dInfo==null) {
            this.dInfo = new DebugInfo();
        }
        
        return this.dInfo;
    }
    
    protected virtual void setDebugInfo(DebugInfo dInfo) {
        this.dInfo = dInfo;
    }
    
    public virtual Map<String,GNE_SFA2_S2S_Interface.DebugActionInterface> getDebugActions() {
        if(this.debugActions==null) {
            this.debugActions = new Map<String,GNE_SFA2_S2S_Interface.DebugActionInterface>();
        }
        
        return this.debugActions;
    }
    
    protected virtual void onRestEngineStart() {
        getDebugInfo().onServiceStart();
        getResponse().onStart();
        List<GNE_SFA2_S2S_Interface.RecordInterface> recs = getRequest()!=null ? getRequest().getRecords() : null;
        
        if(recs!=null && !recs.isEmpty()) {
            String localId = isCallOrExecute() ? recs[0].getLocalId() : recs[0].getExtId();
            String extId = isCallOrExecute() ? recs[0].getExtId() : recs[0].getLocalId();
            this.rec = new GNE_SFA2_S2S_Util.Record(localId, extId);
        }

        if(getListener()!=null) {
            getListener().onRestEngineStart(this);
        }
    }
    
    protected virtual void onRestEngineFinish() {
        getResponse().onFinish();
        
        if(getListener()!=null) {
            try {
                getListener().onRestEngineFinish(this);
            } catch(Exception ex) {
                onRestEngineError(ex);
            }
        }
        
        getDebugInfo().onServiceFinish();
        
        if(GNE_SFA2_S2S_Config.isLogLevelEnabled(GNE_SFA2_S2S_Config.LogLevel.ERROR, getFeatureName())) {
            saveLogs();
        }
        
        setDebugInfo(null);
    }
    
    protected virtual void saveLogs() {
        saveLogs(response.getErrors(), response.isSuccess());
    }
    
    public virtual void saveLogs(List<GNE_SFA2_S2S_Interface.ErrorInterface> errs, Boolean isSuccess) {
        Map<String,SFA2_S2S_Log_gne__c> logsToSave = new Map<String,SFA2_S2S_Log_gne__c>();
        Database.DmlOptions dmlOpt = new Database.DmlOptions();
        dmlOpt.allowFieldTruncation = true;
        Boolean onlySuccessLogged = false;
        
        for(GNE_SFA2_S2S_Interface.ErrorInterface err : errs) {
            SFA2_S2S_Log_gne__c logRec = createLogRecord(err);
            logRec.setOptions(dmlOpt);
            logsToSave.put(logRec.Hash_Code_gne__c, logRec);
        }
        
        if(logsToSave.isEmpty() && (!isSuccess || GNE_SFA2_S2S_Config.isLogLevelEnabled(GNE_SFA2_S2S_Config.LogLevel.ALL, getFeatureName()))) {
            onlySuccessLogged = isSuccess;
            SFA2_S2S_Log_gne__c logRec = createLogRecord(new GNE_SFA2_S2S_Util.Error(onlySuccessLogged ? GNE_SFA2_S2S_UTIL.MESSAGE_CODE_SUCCESS : GNE_SFA2_S2S_UTIL.MESSAGE_CODE_FAIL, ''));
            logRec.setOptions(dmlOpt);
            logsToSave.put(logRec.Hash_Code_gne__c, logRec);
        }
        
        if(!logsToSave.isEmpty()) {
            Database.upsert(logsToSave.values(), SFA2_S2S_Log_gne__c.Hash_Code_gne__c, false);
            if(!onlySuccessLogged) {
                String executionTimeExpression  = GNE_SFA2_S2S_Config.getConfigItemValue(GNE_SFA2_S2S_Util.SCHEDULER_JOB_SUPPORT_EMAIL_NOTIFICATION + 'Time');
                
                if(executionTimeExpression!=null) {
                    GNE_SFA2_Scheduler.scheduleJob(this, GNE_SFA2_S2S_Util.SCHEDULER_JOB_SUPPORT_EMAIL_NOTIFICATION, executionTimeExpression);
                }
            }
        }
    }
    
    private SFA2_S2S_Log_gne__c createLogRecord(GNE_SFA2_S2S_Interface.ErrorInterface err) {
        String serviceName = getCallService()!=null && String.isNotBlank(getServiceProperty('object')) ? String.format('{0}/{1}/{2}', new String[]{getServiceName(), getServiceProperty('object'), getServiceProperty('method')}) : getServiceName();
        
        SFA2_S2S_Log_gne__c logRec = new SFA2_S2S_Log_gne__c();
        
        logRec.Local_Id_gne__c = err.getLocalId();
        logRec.External_Id_gne__c = err.getExtId();
        logRec.Full_Message_gne__c = err.getErrorMessage();
        logRec.Message_gne__c = err.getShortMessage();
        logRec.Message_Code_gne__c = err.getErrorCode();
        logRec.Stack_Trace_gne__c = err.getStackTrace();
        
        logRec.Local_Id_gne__c = logRec.Local_Id_gne__c!=null ? logRec.Local_Id_gne__c : getLocalId();
        logRec.External_Id_gne__c = logRec.External_Id_gne__c!=null ? logRec.External_Id_gne__c : getExtId();
        logRec.External_System_gne__c = getExternalSystemName();
        logRec.Feature_gne__c = getFeatureName();
        logRec.Service_Name_gne__c = serviceName;
        logRec.Http_Method_gne__c = getHttpMethod();
        logRec.Call_Or_Execute_gne__c = isCallOrExecute();
        logRec.Engine_Class_gne__c = getSelfClass().getName();
        logRec.Service_Class_gne__c = getService()!=null ? getService().getSelfClass().getName() : null;
        logRec.Request_Class_gne__c = getRequest()!=null ? getRequest().getSelfClass().getName() : null;
        logRec.Request_json_gne__c = getRequest()!=null ? JSON.serialize(getRequest()) : null;
        logRec.Params_json_gne__c = !getParams().isEmpty() ? JSON.serialize(params) : null;
        logRec.Response_Class_gne__c = getResponse()!=null ? getResponse().getSelfClass().getName() : null; 
        logRec.Response_json_gne__c = getResponse()!=null ? JSON.serialize(getResponse()) : null;
        logRec.User_Name_gne__c = getRequest()!=null && getRequest().getActor()!=null ? getRequest().getActor().getUserName() : UserInfo.getUserName();
        logRec.Debug_Info_json_gne__c = JSON.serialize(getDebugInfo());
        logRec.Last_Log_Date_gne__c = DateTime.now();
        
        if(getLogListener()!=null) {
            getLogListener().onLogCreate(logRec, err, this);
        }
        
        logRec.Hash_Code_gne__c = logRec.Hash_Code_gne__c!=null ? logRec.Hash_Code_gne__c : generateLogHashCode(logRec, err);
        return logRec;
    }
    
    public virtual void onExecuteRestMethod() {
        getExecuteService().executeRestMethod(this);
    }
    
    public void execute(GNE_SFA2_Scheduler.SchedulableContext sc) {
        if(sc.getJobType()==GNE_SFA2_S2S_Util.SCHEDULER_JOB_SUPPORT_EMAIL_NOTIFICATION) {
            GNE_SFA2_S2S_Util.sendSupportEmailNotification(sc.getQueuedDate());
        }
    }
    
    protected virtual String generateLogHashCode(SFA2_S2S_Log_gne__c logRec, GNE_SFA2_S2S_Interface.ErrorInterface err) {
        return string.valueof(System.hashCode(String.join(new String[]{
            logRec.Engine_Class_gne__c,
            String.isNotBlank(logRec.Local_Id_gne__c) ? logRec.Local_Id_gne__c : '',
            getLogDuplicateFormatDate(), 
            logRec.User_Name_gne__c, 
            logRec.Message_Code_gne__c, 
            logRec.Message_gne__c
        }, '')));
    }
    
    protected virtual String getLogDuplicateFormatDate() {
        String result = '';
        String logDuplicateDatePrecision = GNE_SFA2_S2S_Config.getConfigItemValue(GNE_SFA2_S2S_Config.ConfigItem.S2SLogDuplicateDatePrecision);
        logDuplicateDatePrecision = String.isNotBlank(logDuplicateDatePrecision) ? logDuplicateDatePrecision : 'yyyyMMddHHmmss';
        
        try {
            result = System.now().formatGmt(logDuplicateDatePrecision);
        } catch(Exception ex) {}
        
        return result;
    }
    
    public virtual class DebugInfo  implements GNE_SFA2_S2S_Interface.DebugInfoInterface {
        protected List<String> messages;
        protected Integer execTime;
        protected Map<String,String> apexLimitUsage;
        protected transient Long startMillis;
        protected transient Map<String,Integer> apexUsage;
        
        public DebugInfo() {
            
        }
        
        public List<String> getMessages() {
            if(this.messages==null) {
                this.messages = new List<String>();
            }
            
            return this.messages;
        }
        
        public void addMessage(String msg) {
            getMessages().add(msg);
        }
        
        public void onServiceStart() {
            this.startMillis = System.now().getTime();
            this.apexUsage = new Map<String,Integer>{
                'CpuTime' => Limits.getCpuTime(),
                'Queries' => Limits.getQueries(),
                'QueryRows' => Limits.getQueryRows(),
                'DMLStatements' => Limits.getDMLStatements(),
                'DMLRows' => Limits.getDMLRows(),
                'HeapSize' => Limits.getHeapSize(),
                'AggregateQueries' => Limits.getAggregateQueries()
            };
        }
        
        public void onServiceFinish() {
            if(this.startMillis!=null) {
                this.execTime = Integer.valueOf(System.now().getTime() - this.startMillis);
            }
            
            if(this.apexUsage!=null) {
                this.apexLimitUsage = new Map<String,String>{
	                'CpuTime' => String.valueOf(Limits.getCpuTime()-this.apexUsage.get('CpuTime')) + '/' + String.valueOf(Limits.getLimitCpuTime()),
	                'Queries' => String.valueOf(Limits.getQueries()-this.apexUsage.get('Queries')) + '/' + String.valueOf(Limits.getLimitQueries()),
	                'QueryRows' => String.valueOf(Limits.getQueryRows()-this.apexUsage.get('QueryRows')) + '/' + String.valueOf(Limits.getLimitQueryRows()),
	                'DMLStatements' => String.valueOf(Limits.getDMLStatements()-this.apexUsage.get('DMLStatements')) + '/' + String.valueOf(Limits.getLimitDMLStatements()),
	                'DMLRows' => String.valueOf(Limits.getDMLRows()-this.apexUsage.get('DMLRows')) + '/' + String.valueOf(Limits.getLimitDMLRows()),
	                'HeapSize' => String.valueOf(Limits.getHeapSize()-this.apexUsage.get('HeapSize')) + '/' + String.valueOf(Limits.getLimitHeapSize()),
	                'AggregateQueries' => String.valueOf(Limits.getAggregateQueries()-this.apexUsage.get('AggregateQueries')) + '/' + String.valueOf(Limits.getLimitAggregateQueries())
                };  
            }
        }
    }
}