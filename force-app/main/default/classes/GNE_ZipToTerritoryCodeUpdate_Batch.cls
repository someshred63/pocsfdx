public class GNE_ZipToTerritoryCodeUpdate_Batch implements Database.Batchable<SObject>, Database.Stateful {
    private Map<String, TerritoryWrapper> number2territory;
    private DateTime lastCompletedBatchStarted;
    private Boolean allTerritory = false;
    private DateTime startProcess;
    private DateTime endProcess;
    private Integer updatedRecords = 0;
    private Integer errors = 0;
    private Integer totalProcessedRecords = 0;
    private Map <String, Object> params;

    public GNE_ZipToTerritoryCodeUpdate_Batch(Boolean allTerritory, Map <String, Object> params){
        this.allTerritory = allTerritory;
        this.params = params;
        this.startProcess = params.get('startTime') != null ? (DateTime)params.get('startTime') : System.now();
    }

    public GNE_ZipToTerritoryCodeUpdate_Batch(Boolean allTerritory) {
        this(allTerritory, new Map<String, String>());
        this.startProcess = System.now();
    }

    public GNE_ZipToTerritoryCodeUpdate_Batch() {
        this(false, new Map<String, String>());
        this.startProcess = System.now();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = prepareQuery();
        Set<String> territoriesNumbers = number2territory.KeySet();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Zip_to_Territory_gne__c> scope) {
        totalProcessedRecords += scope.size();
        Zip_to_Territory_gne__c [] toUpdate = new Zip_to_Territory_gne__c[]{};

        for(Zip_to_Territory_gne__c record : scope){
            TerritoryWrapper terrWrapp = number2territory.get(record.Territory_Number_gne__c) != null ? number2territory.get(record.Territory_Number_gne__c) : null;
            if(terrWrapp != null && (terrWrapp.subCode != record.Salesforce_SubTeam_Code_gne__c || terrWrapp.code != record.Salesforce_Code_gne__c)) {
                record.Salesforce_SubTeam_Code_gne__c = terrWrapp.subCode;
                record.Salesforce_Code_gne__c = terrWrapp.code;
                System.debug(record);
                toUpdate.add(record);
            }
        }

        Database.SaveResult[] srs = Database.update(toUpdate, false);

        for(Database.SaveResult sr : srs){
            if(sr.isSuccess() ){
                updatedRecords ++;
            } else {
                errors ++;
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        endProcess = System.now();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{prepareEmail()}, false);
    }

    private Messaging.SingleEmailMessage prepareEmail() {
        Datetime GMTStartDate = Datetime.newInstanceGmt(startProcess.yearGmt(),startProcess.monthGmt(),startProcess.dayGmt(),startProcess.hourGmt(),startProcess.minute(),startProcess.second());
        GNE_Foun_Misc_Config_Items_gne__c emailConf = GNE_Foun_Misc_Config_Items_gne__c.getValues('SubscribeNotfyEmail');
        String emailAddr = emailConf != null && emailConf.Configuration_Value_gne__c != null ? emailConf.Configuration_Value_gne__c : UserInfo.getUserEmail();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{emailAddr});
        mail.setSubject('Zip To Terr Demon '+GMTStartDate.format('MM/dd/yyyy HH:mm a ', 'Europe/Londyn'));
        mail.setPlainTextBody(prepareTexBody(GMTStartDate));

        return mail;
    }

    private String prepareTexBody(Datetime GMTStartDate) {
        Datetime GMTStopDate = Datetime.newInstanceGmt(endProcess.yearGmt(),endProcess.monthGmt(),endProcess.dayGmt(),endProcess.hourGmt(),endProcess.minute(),endProcess.second());
        Decimal millisecs = Decimal.valueOf(endProcess.getTime() - startProcess.getTime());
        Decimal dHours = Integer.valueOf(millisecs/1000/60/60);
        Decimal dMinutes =  math.mod(Integer.valueOf(millisecs/1000/60), 60);
        Decimal dSeconds =  math.mod(Integer.valueOf(millisecs/1000), 60);
        String diffHours =  String.valueOf(dHours)+ ' hour(s) ' ;
        String diffMinutes =  String.valueOf(dMinutes)+ ' minute(s) ' ;
        String diffSeconds =  String.valueOf(dseconds)+ ' second(s) ' ;
        Integer batchOneErrors = params.get('errors') != null ? (Integer)params.get('errors') : 0;
        Integer batchOneInsert = params.get('inserted') != null ? (Integer)params.get('inserted') : 0;
        Integer batchOneTotal = params.get('total') != null ? (Integer)params.get('total') : 0;
        Integer batchOneDeleted = params.get('delete') != null ? (Integer)params.get('delete') : 0;

        String textBody =
            'Process start time: ' + GMTStartDate.format('MM/dd/yyyy HH:mm:ss', 'Europe/Londyn')+' GMT\n'+
            'Process end time: ' + GMTStopDate.format('MM/dd/yyyy HH:mm:ss', 'Europe/Londyn') +' GMT\n'+
            'Running time: ' + diffHours + diffMinutes + diffSeconds +
            '\n\nMetrics for: Zip To Territory\n' +
            'Total numbers of processed records: ' + (totalProcessedRecords + batchOneTotal) + '\n' +
            'Number of successfully updated records: ' + updatedRecords + '\n'+
            'Number of successfully inserted records: ' + batchOneInsert + '\n'+
            'Number of successfully deleted records: ' + batchOneDeleted + '\n'+
            'Number of error during DML: ' + (errors + batchOneErrors);

        return textBody;
    }

    private String prepareQuery(){
        number2territory = new Map<String, TerritoryWrapper>();
        String initQuery = prepareInitQuery();
        getNecessaryTerritories(initQuery);

        return
            'SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c '+
            'FROM Zip_to_Territory_gne__c '+
            'WHERE Territory_Number_gne__c IN : territoriesNumbers ';
    }

    private void getNecessaryTerritories(String initQuery) {
        List<Territory2> allTerritories = Database.query(initQuery);
        Set<String> affectedTerrNumbers = new Set<String>();
        for(Territory2 terr : allTerritories){
            if(terr.Territory_Number_gne__c != null){
                affectedTerrNumbers.add(terr.Territory_Number_gne__c);
            }
        }

        //we have to got all active territories to prevent to change to null
        //if we deactive one territory but there are still an active territory
        allTerritories.addAll([
            SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, external_id_gne__c
            FROM Territory2
            WHERE Territory_Number_gne__c IN : affectedTerrNumbers
                AND (NOT External_id_gne__c LIKE 'INACTIVE TERRITORIES%')
        ]);

        for(Territory2 terr : allTerritories){
            TerritoryWrapper terrWrapper;
            if(number2territory.get(terr.Territory_Number_gne__c) == null){
                terrWrapper = new TerritoryWrapper(terr);
            } else {
                terrWrapper = number2territory.get(terr.Territory_Number_gne__c);
                terrWrapper.updateTerritoryWrapper(terr);
            }
            number2territory.put(terr.Territory_Number_gne__c, terrWrapper);
        }
    }

    private String prepareInitQuery() {
        AsyncApexJob [] apexJobs = [
            SELECT CreatedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'GNE_ZipToTerritoryCodeUpdate_Batch'
                AND ParentJobId = null
                AND Status = 'Completed'
                AND JobType = 'BatchApex'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        lastCompletedBatchStarted = apexJobs.isEmpty() ? null : apexJobs[0].CreatedDate;
        //to get all territories to scope we set param allTerritory to true
        String lastModifiedDateCondition = lastCompletedBatchStarted == null || allTerritory ? '' : ' AND LastModifiedDate > :lastCompletedBatchStarted';

        String query = 'SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, external_id_gne__c '+
            'FROM Territory2 '+
            'WHERE (External_id_gne__c LIKE \'GNE-US%\' OR External_id_gne__c  LIKE \'INACTIVE TERRITORIES%\') '+
            '    AND Territory_Number_gne__c != null ' + lastModifiedDateCondition;

        return query;
    }

    class TerritoryWrapper {
        Boolean isActive = false;
        String code;
        String subCode;
        String territoryNumber;

        public TerritoryWrapper(Territory2 terr) {
            this.territoryNumber = terr.Territory_Number_gne__c;
            if(!terr.External_id_gne__c.startsWithIgnoreCase('INACTIVE TERRITORIES')) {
                this.code = terr.Salesforce_Code_gne__c;
                this.subCode = terr.Salesforce_SubTeam_Code_gne__c;
                this.isActive = true;
            }
        }

        public void updateTerritoryWrapper(Territory2 terr){
            if(!isActive && !terr.External_id_gne__c.startsWithIgnoreCase('INACTIVE TERRITORIES')){
                this.code = terr.Salesforce_Code_gne__c;
                this.subCode = terr.Salesforce_SubTeam_Code_gne__c;
                this.isActive = true;
            }
        }
    }
}