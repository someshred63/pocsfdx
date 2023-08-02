public abstract with sharing class  GNE_ETL_DataSegregationVerificationJob implements Database.Stateful {
    private static final String TYPE_OBJECTPERMISSIONS = 'ObjectPermissions';

    protected String countryISOCode = 'USA';        

    protected String sandbox = '';
    String status = 'Data Segregation Ok';
    Integer NumOfRulesProcessed = 0;
    Integer NumOfRulesDataSegregationFailed = 0;
    Data_Segregation_Master_gne__c dsMaster = null;
    private List<GNE_FRM_DataSegregationJob.ActionType> actionsToPerform = new List<GNE_FRM_DataSegregationJob.ActionType>();

    protected void init () {
        sandbox = Utilities.getEnvironmentName();
    }
        
    protected void doExecute (Database.BatchableContext BC, List<SObject> sObjectList) {            
        try {            
            Boolean isFRMjob = countryISOCode == 'FRM' ? true : false;
            List<Data_Segregation_Automated_Log_gne__c> automatedLogList = new List<Data_Segregation_Automated_Log_gne__c>();
            
            if ( dsMaster == null ) {                
                  dsMaster = (Data_Segregation_Master_gne__c) sObjectList[0].getSObject('Data_Segregation_Master_gne__r');
            }
            
            for (SObject sObjectRecord : sObjectList) {                                  
                Data_Segregation_Checklist_gne__c checkRule = (Data_Segregation_Checklist_gne__c) sObjectRecord;
                DateTime queryStartTime = System.now();                                                
                List<SObject> dataList;
                //extended logic for FRM
                if(isFRMjob) {
                    clearIssues(checkRule.Data_Segregation_Master_gne__c);
                    Group[] territoryGroups = getTerritoryGroups(checkRule);//don't change variable name! It is using in string query in checkRule
                    Set<String> terNames = getTerritoriesName(checkRule);
                    dataList = Database.query(checkRule.query_text_gne__c);
                    if(!dataList.isEmpty() && actionMapping.get(checkRule.Handler_gne__c) != null){
                        if(isAutomaticIssuesRemoval_ON()){
	                        actionsToPerform.add(actionMapping.get(checkRule.Handler_gne__c));
	                    }
                    }
                    
                } else {
                    dataList = Database.query(checkRule.query_text_gne__c);
                }

                NumOfRulesProcessed++;                
                if ( !dataList.isEmpty()) {
                    if(checkRule.Type_gne__c == TYPE_OBJECTPERMISSIONS){
                        createAutomatedLogForObjectPermission(queryStartTime, dataList, checkRule, automatedLogList);
                    } else {
                        automatedLogList.add(createAutomatedLog(queryStartTime, dataList, checkRule));
                    }
                    NumOfRulesDataSegregationFailed++;
                }                                                                  
            }

            if (automatedLogList.size() > 0 ) {                
                insert automatedLogList;
                if ( status != 'Data Segregation Issue') {                
                    status = 'Data Segregation Issue';
                    dsMaster.status_gne__c = status;
                    update dsMaster;
                }
            } else {
                dsMaster.status_gne__c = status;
                update dsMaster;
            }
        } catch (Exception e){
            GNE_ETL_EventTaskReplicator_Utility.writeErrorLog('Data Segregation Check : ' + countryISOCode ,'executeBatch', e);            
        }
    }
    
    protected Database.QueryLocator getQueryLocator () {
        return Database.getQueryLocator ([
            SELECT Id, Record_Id_FieldName_gne__c, Type_gne__c, Query_Text_gne__c, Active_gne__c, Data_Segregation_Master_gne__r.Id, 
                Data_Segregation_Master_gne__r.Status_gne__c, Data_Segregation_Master_gne__r.Deactive_UserList_gne__c, Data_Segregation_Master_gne__c,
                Handler_gne__c 
            FROM Data_Segregation_Checklist_gne__c 
            WHERE Active_gne__c = true 
                AND Data_Segregation_Master_gne__r.name = :countryISOCode
            ORDER BY query_run_sequence_gne__c ASC 
        ]);
    }
    
    protected void doFinish(Database.BatchableContext BC){

        try {
            if (status == 'Data Segregation Issue' && countryISOCode != 'FRM') {
                    Set<String> userNameSet = new Set<String>();
                    for (String userName : dsMaster.Deactive_UserList_gne__c.split(',') ) {
                        if ( sandbox.equalsIgnoreCase('PROD') )
                           userNameSet.add ( userName );
                        else 
                           userNameSet.add ( userName +'.' + sandbox );
                    }
                GNE_ETL_EventTaskReplicator_Utility.deactiveUsers(userNameSet, 'Data Segregation Check : ' + countryISOCode, 'doFinish');      
                }
                                
            AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, ApexClass.Name, JobItemsProcessed, TotalJobItems, CreatedBy.Email, createdDate, completedDate 
                FROM AsyncApexJob 
                WHERE Id =:BC.getJobId()
                              ];
            User createdUser = a.CreatedBy;
            ApexClass batchApexClass = a.ApexClass;
                                              
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = System.Label.DataSegregation_Support_Email_List_gne.split(',');            
            mail.setToAddresses(toAddresses);
            mail.setSubject('Data Segregation Job Completed for ' + + countryISOCode + ' w/ status ' + status);

            mail.setPlainTextBody('The batch Apex job ' + batchApexClass.Name + 
                            '(' + countryISOCode + ') processed. Status -  '  + status + '.\n\n'  + 
                            'Batches with ' + a.NumberOfErrors + ' failures.\n' + 
                            'Batch Job StartTime / CompletedTime ' + 
                            a.CreatedDate + '/' + a.CompletedDate +  '.\n\n' + 
                            'Number Of Rules Read/Processed ' + NumOfRulesProcessed + '\n' + 
                            'Number Of Data Segregation Rules Failed ' + NumOfRulesDataSegregationFailed  + '\n');
                              
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
             GNE_ETL_EventTaskReplicator_Utility.writeErrorLog('Data Segregation Check : ' + countryISOCode ,'doFinish', e);            
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getStackTraceString() );    
        }
        if(isSomethingToProcess()){
            GNE_FRM_DataSegregationJob batchJob = new GNE_FRM_DataSegregationJob(actionsToPerform);
            Database.executeBatch(batchJob);
        }
    }
    
    private Data_Segregation_Automated_Log_gne__c createAutomatedLog(DateTime queryStartTime, List<SObject> dataList, Data_Segregation_Checklist_gne__c checkRule){
        return new Data_Segregation_Automated_Log_gne__c(
            Data_Segregation_Master_gne__c = checkRule.Data_Segregation_Master_gne__c,
            Discrepancy_Record_Id_gne__c = (String ) dataList[0].get(checkRule.Record_Id_FieldName_gne__c),
            Data_Segregation_Rule_gne__c = checkRule.Id,
            Description_gne__c = (String )dataList[0].get(checkRule.Record_Id_FieldName_gne__c),
            QueryStartTime_gne__c = queryStartTime,
            QueryEndTime_gne__c = System.now()
        );
    }
    
    private void createAutomatedLogForObjectPermission(DateTime queryStartTime, List<SObject> dataList, Data_Segregation_Checklist_gne__c checkRule, List<Data_Segregation_Automated_Log_gne__c> automatedLogList){      
        Data_Segregation_Automated_Log_gne__c dsa = createAutomatedLog(queryStartTime, dataList, checkRule);
        sObject sObj = dataList[0];
        if(Schema.ObjectPermissions.getSObjectType() == sObj.getSObjectType()){
            Map<Id, Profile> correctProfileWithPermissions = new Map<Id, Profile>([
                SELECT Id 
                FROM Profile 
                WHERE Name IN 
                ('GNE-Archive', 'GNE-CM-OPS', 'GNE-SFA-Ops', 'GNE-SPCM-Ops', 'GNE-SYS-ADMIN-DATA', 'GNE-SYS-ADMIN-MCCO','GNE-SYS-ADMIN-SBL', 'GNE-SYS-DataSupport-Merge',
                 'GNE-SYS-Support','Premier Support User','Super-SYS-AutomatedJob','System Administrator','System Administrator-SFDC Use- PLEASE DO NOT MODIFY')
            ]);
            
            for(ObjectPermissions objPer : (ObjectPermissions[])dataList ){
                try{
                    if(objPer.Parent.ProfileId != null){
                        if(!correctProfileWithPermissions.containsKey(objPer.Parent.ProfileId)){
                            dsa.Discrepancy_Record_Id_gne__c = objPer.Parent.ProfileId;
                            automatedLogList.add(dsa);
                            return;
                        }
                        
                    }
                } catch (Exception ex) {
                    System.debug(ex.getMessage());
                    dsa.Description_gne__c = ex.getMessage();
                    automatedLogList.add(dsa);
                    return;
                } 	                   
            }            
        }
    }
    /**
    * FRM methods and variables
    */
    private Boolean isSomethingToProcess() {
        return !actionsToPerform.isEmpty();
    }
    
    private Group[] getTerritoryGroups(Data_Segregation_Checklist_gne__c checkRule) {
        Group[] groups;
        if(checkRule.Handler_gne__c == 'AccountShareTerritory'){
            groups = [
                SELECT Id from Group 
                WHERE Type='Territory' 
                AND RelatedId IN (
                    SELECT Id
                    FROM Territory2
                     WHERE External_id_gne__c Like 'GNE-US;MCCO;FRM;%' 
                        AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%')
                 )
            ];
        }
        return groups;
    }
    
    private Set<String> getTerritoriesName(Data_Segregation_Checklist_gne__c checkRule){
        Set<String> terNames = new Set<String>();
        if(checkRule.Handler_gne__c == 'removingTSF'){
            for(Territory2 t : [SELECT Id, name, External_id_gne__c FROM Territory2 WHERE (External_id_gne__c Like 'GNE-US;MCCO;FRM;%')]){
               terNames.add(t.Name);
            }
        }
        return terNames;
    }
    
    private void clearIssues(Id masterId) {
        delete [SELECT Id FROM Data_Segregation_Automated_Log_gne__c WHERE Data_Segregation_Master_gne__c = : masterId];
    }
    
    private Map<String, GNE_FRM_DataSegregationJob.ActionType> actionMapping = new Map<String, GNE_FRM_DataSegregationJob.ActionType> {
        'UpdateUserRole' => GNE_FRM_DataSegregationJob.ActionType.UpdateUserRole,
        'UpdateUserProfile' => GNE_FRM_DataSegregationJob.ActionType.UpdateUserProfile,
        'AccountShareTerritory' => GNE_FRM_DataSegregationJob.ActionType.AccountShareTerritory,
        'RemoveGroupMembers' => GNE_FRM_DataSegregationJob.ActionType.RemoveGroupMembers,
        'removingTSF' => GNE_FRM_DataSegregationJob.ActionType.RemovingTSF,
        'changeOwnerNonFRMContact' => GNE_FRM_DataSegregationJob.ActionType.changeOwnerNonFRMContact,
        'changeOwnerNonFRMAccount' => GNE_FRM_DataSegregationJob.ActionType.changeOwnerNonFRMAccount,
        'changeOwnerFRMAccount' => GNE_FRM_DataSegregationJob.ActionType.changeOwnerFRMAccount,
        'changeOwnerFRMContact' => GNE_FRM_DataSegregationJob.ActionType.changeOwnerFRMContact,
        'UsersUpdate'=> GNE_FRM_DataSegregationJob.ActionType.UsersUpdate
    };

    private static Boolean isAutomaticIssuesRemoval_ON() {
        return GNE_Foun_Misc_Config_Items_gne__c.getValues('VisiblityIssuesRemoval') != null && GNE_Foun_Misc_Config_Items_gne__c.getValues('VisiblityIssuesRemoval').Configuration_Value_gne__c == 'REMOVAL_IS_ON';
    }
}