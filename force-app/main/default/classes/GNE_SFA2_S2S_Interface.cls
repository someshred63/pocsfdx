public class GNE_SFA2_S2S_Interface {
    public interface RestServiceCallInterface extends RestServiceInterface {}
    
    public interface RestServiceExecuteInterface extends RestServiceInterface {
        void executeRestMethod(EngineInterface engine);
    }
    
    public interface RestServiceInterface {
        System.Type getSelfClass();
    }
    
    public interface EngineListenerInterface {
        void onRestEngineStart(EngineInterface engine);
        void onRestEngineFinish(EngineInterface engine);
    }
    
    public interface EngineErrorListenerInterface {
        void onRestEngineError(Exception ex, EngineInterface engine);
    }
    
    public interface EngineLogListenerInterface {
        void onLogCreate(SFA2_S2S_Log_gne__c logRec, ErrorInterface err, EngineInterface engine);
    }
    
    public interface EngineInterface {
        System.Type getSelfClass();
        String getExternalSystemName();
        String getFeatureName();
        String getHttpMethod();
        String getServiceName();
        String getServiceProperty(String propName);
        String getLocalId();
        String getExtId();
        Map<String,String> getParams();
        RestServiceInterface getService();
        RequestInterface getRequest();
        ResponseInterface getResponse();
        
        EngineInterface initServiceEngine(String extSystem, String feature);
        EngineInterface initServiceEngine(String extSystem, String feature, String serviceName);
        
        ResponseInterface callRestPostMethod(RestServiceCallInterface service, RequestInterface request, System.Type responseClass);
        ResponseInterface callRestPostMethod(RestServiceCallInterface service, RequestInterface request, Map<String,String> params, System.Type responseClass);
        ResponseInterface callRestGetMethod(RestServiceCallInterface service, System.Type responseClass);
        ResponseInterface callRestGetMethod(RestServiceCallInterface service, Map<String,String> params, System.Type responseClass);
        
        ResponseInterface executeRestPostMethod(RestServiceExecuteInterface service, RequestInterface request, System.Type responseClass);
        ResponseInterface executeRestGetMethod(RestServiceExecuteInterface service, System.Type responseClass);
        
        void saveLogs(List<ErrorInterface> errs, Boolean isSuccess);
        DebugInfoInterface getDebugInfo();
        Map<String,DebugActionInterface> getDebugActions();
    }
    
    public interface RequestInterface {
        System.Type getSelfClass();
        ActorInterface getActor();
        void setActor(ActorInterface actor);
        List<RecordInterface> getRecords();
        Boolean isAllOrNone();
    }
    
    public interface ActorInterface extends RecordInterface {
        String getAlias();
        String getUnixId();
        String getFedId();
        String getUserName();
        String getName();
        String getFirstName();
        String getLastName();
        String getEmail();
        String getPhone();
        String getMobilePhone();
        String getProfileName();
        Boolean fetchWithLocalUser();
    }
    
    public interface PersonAccountInterface extends RecordInterface {
        String getMdmId();
        String getName();
        String getFirstName();
        String getLastName();
        String getMiddleName();
        String getStatus();
        String getProfType();
        String getCredentials();
        String getSpecialties();
        String getEmail();
        String getPhone();
        String getMobilePhone();
        String getFax();
        AddressInterface getAddress();
        Account searchOrCreate();
        Account searchOrCreate(AddressInterface address);
        Account getAccountRecord();
    }
    
    public interface AddressInterface extends RecordInterface {
        String getMdmId();
        String getName();
        String getSuite();
        String getCity();
        String getState();
        String getZip();
        String getZip4();
        String getCountry();
        String getStatus();
        Boolean isGold();
        Boolean isPrimary();
        Double getLatitude();
        Double getLongitude();
        Address_vod__c getAddressRecord();
    }
    
    public interface RecordInterface {
        String getLocalId();
        String getExtId();
        void setLocalId(String localId);
        void setExtId(String extId);
        Boolean isLocalRecord();
    }
    
    public interface ResponseInterface {
        System.Type getSelfClass();
        Boolean isSuccess();
        List<RecordInterface> getRecords();
        void addRecord(RecordInterface rec);
        List<ErrorInterface> getErrors();
        void onStart();
        void onFinish();
        void addError(String errorCode, String errorMessage);
        void addError(String errorCode, String errorMessage, Boolean failTransaction);
        void addError(String localId, String extId, String errorCode, String errorMessage);
        void addError(String localId, String extId, String errorCode, String errorMessage, String stackTrace);
        void addError(String localId, String extId, String errorCode, String errorMessage, String stackTrace, Boolean failTransaction);
    }
    
    public interface ErrorInterface {
        String getLocalId();
        String getExtId();
        String getErrorCode();
        String getErrorMessage();
        String getShortMessage();
        String getStackTrace();
    }
    
    public interface DebugInfoInterface {
        List<String> getMessages();
        void addMessage(String msg);
        void onServiceStart();
        void onServiceFinish();
    }
    
    public interface DebugActionInterface {
        String getName();
        DateTime getStartTime();
        DebugActionInterface start();
        DebugActionInterface start(String additionalMessage);
        DebugActionInterface end();
        DebugActionInterface end(String additionalMessage);
    }
    
    public interface S2SExceptionInterface {
        String getStatusCode();
    }
}