public class GNE_My_Territory_Team_Batch_Helper implements Database.Batchable<sObject>, Database.Stateful {
    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, USPS_Address_gne__c, Zip_Code_gne__c FROM Zip_to_Territory_gne__c');
    }
    public void execute(Database.BatchableContext BC, List<Zip_to_Territory_gne__c> scope) {
        update scope;
    }
    public void finish(Database.BatchableContext BC){}

    public static Map<Id, String> findProducts(List<Territory2> terrs) {
        return fetchProductNames(prepareQueryForTeamMaping(terrs));
    }

    private static Map<Id, String> fetchProductNames (String query) {
        Map<Id,String> prodId2TA = new Map<Id,String> ();
        for(Team_Mapping_gne__c tm: (Team_Mapping_gne__c[])Database.query(query)){
            prodId2TA.put(tm.Product_gne__c,tm.Product_gne__r.Therapeutic_Area_vod__c );
        }

        return prodId2TA;
    }

    private static String prepareQueryForTeamMaping(List<Territory2> terrs){
        String query =
            'SELECT Product_gne__c, Product_gne__r.Name, Product_gne__r.Therapeutic_Area_vod__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c '+
            'FROM Team_Mapping_gne__c WHERE (';
            Boolean isFirst = true;
            for(Territory2 ter : terrs){
                if(isFirst){
                    isFirst = false;
                    query += '(Salesforce_Code_gne__c = \''+ter.Salesforce_Code_gne__c+'\' AND Salesforce_SubTeam_Code_gne__c = \''+ter.Salesforce_SubTeam_Code_gne__c+'\') ';
                } else {
                    query += ' OR (Salesforce_Code_gne__c = \''+ter.Salesforce_Code_gne__c+'\' AND Salesforce_SubTeam_Code_gne__c = \''+ter.Salesforce_SubTeam_Code_gne__c+'\')';
                }
            }
            query += ') AND Product_gne__r.Brand_Code_gne__c != \'NONE\' ';

        return query;
    }

    public static Messaging.SingleEmailMessage prepareEmail(BatchStatistic[] statistics) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        GNE_Foun_Misc_Config_Items_gne__c emailConf = GNE_Foun_Misc_Config_Items_gne__c.getValues('MyTerritoryTeamBatchNotfyEmail');
        String emailAddr = emailConf != null && emailConf.Configuration_Value_gne__c != null ? emailConf.Configuration_Value_gne__c : UserInfo.getUserEmail();
        List<String> emails = emailAddr.split(';');
        mail.setToAddresses(emails);
        mail.setSubject('My_Territory_Team_Batch Demon ');
        mail.setHtmlBody(prepareStatisticText(statistics));

        return mail;
    }

    private static String prepareStatisticText(BatchStatistic[] statistics) {
        String textBody = '';
        statistics.sort();
        for(BatchStatistic bs : statistics){
            textBody += createTableForSingleStatistic(bs);
        }
        return textBody;
    }

    private static String createTableForSingleStatistic(BatchStatistic stat) {
        String recordForQueryRows = stat.recordForQueryRows == '---' ? '' : '('+stat.recordForQueryRows+')';
        String txt = '<B>Process name: </B>'+stat.processName + '<BR/>';
        txt+= '<B>Mode: </B>'+stat.mode + '<BR/>';
        txt+= '<B>Process order: </B>'+stat.orderOfExecute + '<BR/>';
        txt+= '<B>Process started: </B>'+stat.processStart + '<BR/>';
        txt+= '<B>Process finished: </B>'+stat.processEnd + '<BR/>';
        txt+= '<B>Max queries: </B>'+stat.maxQueries +'/' + Limits.getLimitQueries() + ' <BR/>';
        txt+= '<B>Max query Rows: </B>'+stat.maxQueryRows +'/' + Limits.getLimitQueryRows() +''+recordForQueryRows+ '<BR/>';
        txt+= '<B>Max CPU time: </B>'+stat.maxCpuTime +'/' + Limits.getLimitCpuTime() + '<BR/>';
        if(stat.limitForAgregateResults!=null)txt+= '<B>Max Rows for AggregateResult: </B>'+stat.limitForAgregateResults +' (' + stat.territoryForAgregateResults + ')<BR/>';
        txt+= '<B>Records deleted: </B>'+stat.deletedRecords + '<BR/>';
        txt+= '<B>Process runed : </B>'+stat.timesExecuted + ' times<BR/>';
        
        txt+= '<B>Exceptions: </B>'+stat.exceptions + '<BR/>';
        txt+= '----------------------------------------------------------<BR/>';
        return txt;
    }

    public static Boolean isExceededLimitsForQueryRows(String countQuery, String sId, DateTime lastCompletedBatchStarted, GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic) {
        Integer counter;
        if(Test.isRunningTest()){
            return false;
        }
        try{
            HttpRequest req = new HttpRequest();
            String lastModifiedStr = String.valueOf(lastCompletedBatchStarted).replace(' ','T');
            lastModifiedStr += 'Z';
            countQuery = countQuery.remove(':');
            countQuery = countQuery.replace('lastCompletedBatchStarted', lastModifiedStr);
            countQuery = countQuery.replace(' ','+');
            req.setEndpoint('https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v41.0/query/?q='+countQuery);
            req.setMethod('GET');
            String autho = 'Bearer '+ sId;
            req.setHeader('Authorization', autho);
            req.setTimeout(120000);

            Http http = new Http();
            HTTPResponse res = http.send(req);

            if(res.getStatusCode() == 200){
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                counter = (Integer)resMap.get('totalSize') != null ? (Integer)resMap.get('totalSize') : Limits.getLimitQueryRows() ;
                System.debug('API Response '+counter);
            } else {
                batchStatistic.exceptions.add(res.getStatus());
                counter = Limits.getLimitQueryRows();
            }
        } catch (Exception ex) {
            return false;
        }

        return counter + Limits.getQueryRows() >= Limits.getLimitQueryRows();
    }

    public class BatchStatistic implements Comparable{
        public Integer orderOfExecute {get;set;}
        public String processName {get;set;}
        public Datetime processStart {get;set;}
        public Datetime processEnd {get;set;}
        public String[] exceptions {get;set;}
        public Integer maxQueries {get;set;}
        public Integer maxQueryRows {get;set;}
        public Integer maxCpuTime {get;set;}
        public Integer deletedRecords {get;set;}
        public Integer timesExecuted {get;set;}
        public String mode {get;set;}
        public Boolean allTerritories {get;set;}
        public Datetime delta {get;set;}
        public String recordForQueryRows {get;set;}
        public Integer limitForAgregateResults {get;set;}
        public String  territoryForAgregateResults {get;set;}

        public BatchStatistic(String processName) {
            processStart = System.now();
            orderOfExecute = 1;
            maxQueries = 0;
            maxQueryRows = 0;
            maxCpuTime = 0;
            deletedRecords = 0;
            this.processName = processName;
            this.exceptions = new String[]{};
            timesExecuted = 1;
            mode = 'ALL_TERRITORIES';
            recordForQueryRows = '---';
        }

        public BatchStatistic(String processName, Integer prev) {
            this(processName);
            this.orderOfExecute = prev + 1;
        }

        public void setDelta(Datetime deltaTime){
            this.delta = deltaTime;
            this.mode = 'DELTA FROM :'+delta;
        }

        public void updateStatistic() {
            Integer queries = Limits.getQueries();
            Integer queryRows = Limits.getQueryRows();
            Integer cpuTime = Limits.getCpuTime();
            maxQueries = queries > maxQueries ? queries : maxQueries;
            maxQueryRows = queryRows > maxQueryRows ? queryRows : maxQueryRows;
            maxCpuTime = cpuTime > maxCpuTime ? cpuTime : maxCpuTime;
        }
        
        public void updateLimitsForAggregateResults(Integer counter, String terrNumber){
            if(limitForAgregateResults == null || counter > limitForAgregateResults){
                limitForAgregateResults = counter;
                territoryForAgregateResults = terrNumber;
            }
        }

        public void updateStatistic(String record) {
            Integer queries = Limits.getQueries();
            Integer queryRows = Limits.getQueryRows();
            Integer cpuTime = Limits.getCpuTime();
            recordForQueryRows = queryRows > maxQueryRows ? record :recordForQueryRows;
            maxQueries = queries > maxQueries ? queries : maxQueries;
            maxQueryRows = queryRows > maxQueryRows ? queryRows: maxQueryRows;
            maxCpuTime = cpuTime > maxCpuTime ? cpuTime : maxCpuTime;
        }

        public void markFinised() {
            processEnd = System.now();
        }

        public Integer compareTo(Object compareTo) {
            Integer result = 0;
            BatchStatistic stats = (BatchStatistic)compareTo;
            if(this.orderOfExecute > stats.orderOfExecute){
                result = 1;
            } else if(this.orderOfExecute < stats.orderOfExecute) {
                result = -1;
            }
            return result;
        }
    }
}