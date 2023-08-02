global class GNE_SFA2_Canada_RefreshQueAccountsBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {

    private DateTime lastProcessExecutionTime;
    private Boolean scheduledExecution = true;

    public GNE_SFA2_Canada_RefreshQueAccountsBatch() {

    }

    public GNE_SFA2_Canada_RefreshQueAccountsBatch(Datetime lastProcessExecutionTime) {
        this.lastProcessExecutionTime = lastProcessExecutionTime;
        this.scheduledExecution = false;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GNE_SFA2_Canada_RefreshQueAccountsBatch(), 20);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Territories_can_gne__c, Audience_Type_gne__c FROM Questionnaire_gne__c WHERE Freeze_Surveys_gne__c = false AND Hide_Surveys_gne__c = false AND Region_Code_gne__c = 2';
        if(this.scheduledExecution) {
            this.lastProcessExecutionTime = getLastProcessExecutionTime(bc);
            if(this.lastProcessExecutionTime == null) {
                this.lastProcessExecutionTime = DateTime.newInstance(2017, 5, 11);
            }
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Questionnaire_gne__c> questionnaires = (List<Questionnaire_gne__c>) scope;
        List<QuestionnaireAccount_gne__c> toInsert = new List<QuestionnaireAccount_gne__c>();
        Set<QuestionnaireAccount_gne__c> toUpsert = new Set<QuestionnaireAccount_gne__c>();
        Schema.SObjectField extIdField = QuestionnaireAccount_gne__c.Fields.Questionnaire_Account_ExKey_gne__c;
        Map<String, String> territoriesWithId;
        try {
            for(Questionnaire_gne__c questionnaire : questionnaires) {
                if(questionnaire.Territories_can_gne__c != null) {
                   territoriesWithId = createTerritoriesMap(questionnaire.Territories_can_gne__c.split(';'));
                   String tsfQuery;
                   tsfQuery = GNE_SFA_Canada_AssignTerritoryBatch.getTsfQuery(checkIfTargeted(questionnaire.Audience_Type_gne__c), territoriesWithId);
                   DateTime lastExec = this.lastProcessExecutionTime;
                   if(tsfQuery != null) {
                        tsfQuery += ' AND LastModifiedDate > :lastExec';
                        List<TSF_vod__c> tsfs = Database.query(tsfQuery);
                        if(!tsfs.isEmpty()){
                            for(TSF_vod__c tsf : tsfs) {
                                toUpsert.add(new QuestionnaireAccount_gne__c(Account__c = tsf.Account_vod__c, Questionnaire_gne__c = questionnaire.Id,
                                Questionnaire_Account_ExKey_gne__c = tsf.Account_vod__c + '_' + questionnaire.Id));
                            }
                        }
                        tsfs.clear();
                    }
                }
            }
            toInsert = new List<QuestionnaireAccount_gne__c>(toUpsert);
            List<Database.Saveresult> result;
            Database.UpsertResult[] lur = Database.upsert(toInsert, extIdField, false);
        }
        catch(Exception ex) {
            GNE_SFA2_ErrorBundle_Util.writeErrorLog('Questionnaire_gne__c','execute',ex);
        }
    }

    global void finish(Database.BatchableContext bc) {

    }

    private Map<String,String> createTerritoriesMap(List<String> territoriesNames) {
        List<Territory2> territories = [SELECT Id, Name FROM Territory2 WHERE Name IN :territoriesNames];
        Map<String, String> territoriesMap = new Map<String, String>();
        for(Territory2 territory : territories) {
            territoriesMap.put(territory.Id, territory.Name);
        }
        return territoriesMap;
    }

    private Boolean checkIfTargeted(String audienceType) {
        return audienceType == 'Targeted';
    }

    private DateTime getLastProcessExecutionTime(Database.BatchableContext BC) {
        DateTime lastProcessExecutionTime = null;
        Id currentJobId = BC.getJobId();
        String className = GNE_SFA2_Canada_RefreshQueAccountsBatch.class.getName();

        for(AsyncApexJob job : [SELECT CreatedDate
                                FROM AsyncApexJob
                                WHERE ApexClass.Name = :className
                                    AND Id <> :currentJobId
                                    AND ParentJobId = null
                                    AND JobType = 'BatchApex'
                                    AND Status = 'Completed'
                                ORDER BY CreatedDate desc
                                LIMIT 1]) {
            lastProcessExecutionTime = job.CreatedDate;
        }

        System.debug('lastProcessDateTime = ' + lastProcessExecutionTime);
        return lastProcessExecutionTime;
    }

}