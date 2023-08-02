public class GNE_ReltioResendBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable, Database.AllowsCallouts{
    public Enum ActionType {SendDCRs, SendAffiliations, StatusUpdate}
    private BatchJobObject batchJob;
    private List<ActionType> actionsToPerform;
    private ActionType currentaction;
    
    public void execute(SchedulableContext sc){
        GNE_ReltioResendBatch batch = new GNE_ReltioResendBatch();
        Database.executeBatch(batch, 5);
    }
    
    public GNE_ReltioResendBatch(){
        actionsToPerform = new List<ActionType>{ActionType.SendDCRs, ActionType.SendAffiliations, ActionType.StatusUpdate};        
        currentAction = actionsToPerform[0];
        System.debug('init '+actionsToPerform);
    }
    
    public GNE_ReltioResendBatch(List<ActionType> actionsToPerform) {
        this.actionsToPerform = actionsToPerform;
        if(!actionsToPerform.isEmpty()){
            currentaction = actionsToPerform[0];
        }    
    }
    
    
    public Database.QueryLocator start(Database.batchableContext bc) {
        return getQueryForCurrentAction();   
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> sObjectList){
        if(currentaction == ActionType.StatusUpdate) {
            String reqBody = createReqBody(sObjectList);
            GNE_ReltioCreateRequestDCR.updateStatusFromReltio(reqBody);
        } else {
            for(SObject record : sObjectList) {
                try{
                    GNE_ReltioCreateRequest.sendRequest(record, GNE_ReltioCreateRequest.OperationType.INS);
                } catch (Exception ex) {
                    System.debug(ex.getMessage() + ' stack : '+ex.getStackTraceString());                
                }            
            }
        }        
    }
    
    public void finish(Database.BatchableContext BC){
        actionsToPerform.remove(0);
        if(actionsToPerform.isEmpty()){
            //doFinish(BC);
            System.debug('finish batch jobs');
        } else {
            ActionType atp = actionsToPerform[0];
            Integer scopeSize = atp == ActionType.StatusUpdate ? 20 : 1;
            System.debug('Action: '+atp + '  size '+scopeSize);
            GNE_ReltioResendBatch batch = new GNE_ReltioResendBatch(actionsToPerform);
            Database.executeBatch(batch, scopeSize);
        }
    }
    
    private String createReqBody(List<SObject> sObjectList) {
        List<DataWrapper> dataColl = createCollection(sObjectList);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeObjectField('dcrRequestDetails', dataColl);
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    private List<DataWrapper> createCollection(List<SObject> sObjectList) {
        List<DataWrapper> result = new List<DataWrapper>();
        for(SObject so : sObjectList) {
            DataWrapper dw = new DataWrapper();
            Change_Request_gne__c cr = (Change_Request_gne__c)so;
            dw.name = cr.MDM_DCR_Id_gne__c;
            result.add(dw);
        }
        
        return result;
    }
    
    public class DataWrapper {
        public String name;
    }
    
    private Database.QueryLocator getQueryForCurrentAction() {
        Database.QueryLocator result;
        if(currentaction == ActionType.SendDCRs) {
            result =  getQueryLocator();
        } else if(currentaction == ActionType.SendAffiliations) {
            result = getQueryForAffiliation();
        } else if(currentaction == ActionType.StatusUpdate) {
            result = getQueryLocatorForStatusUpdate();
        }
        return result;
    }
    
    private Database.QueryLocator getQueryLocatorForStatusUpdate() {
        return Database.getQueryLocator ([
            SELECT MDM_DCR_Id_gne__c, MDM_DCR_Status_gne__c
            FROM Change_Request_gne__c 
            WHERE MDM_DCR_Status_gne__c = 'AWAITING_REVIEW' AND MDM_DCR_Id_gne__c != null
        ]);
    }
    
    private Database.QueryLocator getQueryLocator() {
        return Database.getQueryLocator ([
            SELECT Name, First_Name_DCR_gne__c, Last_Name_DCR_gne__c,Suffix_DCR_gne__c, Professional_Type_DCR_gne__c,Credentials_DCR_gne__c,
                Specialties_HCP_DCR_gne__c, Type_gne__c, Account_gne__c, OwnerId, CreatedById, CreatedDate,
                LastModifiedDate, LastModifiedById, Notes_gne__c, Reason_dcr_gne__c, Account_Type_DCR_gne__c, New_Organization_Name_gne__c,
                Current_Address_gne__c, Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, State_gne__c,
                Zip_gne__c, License_State_gne__c, License_Number_gne__c, Status_gne__c, License_Expiration_Date_gne__c, License_Overwrite_Expiration_Date_gne__c,
                License_Sample_ability_gne__c, Adjusted_License_Expiration_Date_gne__c, RecordTypeId 
            FROM Change_Request_gne__c 
            WHERE Status_gne__c = 'Waiting To Send To Reltio' AND MDM_DCR_Id_gne__c = null
        ]);
    }
    
    private Database.QueryLocator getQueryForAffiliation() {
        return Database.getQueryLocator([
            SELECT Name, Record_Status_gne__c,From_Account_vod__c, OwnerId, CreatedById, CreatedDate, LastModifiedDate,
                   LastModifiedById, Note_gne__c, To_Account_vod__c
            FROM Affiliation_vod__c
            WHERE (MDM_Status_gne__c = 'SUBMISSION FAILURE' OR MDM_Status_gne__c = 'WAITING TO SEND TO RELTIO' ) AND MDM_Reltio_Id_gne__c = null
        ]);
    }
    
    public class BatchJobObject {
        private ActionType currentAction;
    	private List<ActionType> actionsToPerform;
    }

}