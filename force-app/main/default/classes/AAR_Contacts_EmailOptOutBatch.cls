/**
 * @author Venky Kambham
 * @date 1/25/2021
 * @description Batch Apex class for updating email opt-out times of ARM Contacts.
 * @jira-stories ROBOCOPS-444, ROBOCOPS-538
 * 
 * @Usage (in anonymous apex) :
 * AAR_Contacts_EmailOptOutBatch.scheduleMe() or AAR_Contacts_EmailOptOutBatch.scheduleMe(cronExp,jobName,batchSize);
 */
public class AAR_Contacts_EmailOptOutBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    Integer RESPONSE_PAGE_SIZE = 1000;
    Integer RESPONSE_STATUS_CODE = 200;
    public Map<String,DateTime> optoutEmailsMap = new Map<String,DateTime>();
        
    //Get all the contacts which are opted out of emails
    public Database.QueryLocator start(Database.BatchableContext bc){
         //Get full list of Opted out Emails from CAN-SPAM
        optoutEmailsMap = getGlobalOptoutList(); // Calling this in start method to avoid error: Callout from scheduled Apex not supported
        
        return Database.getQueryLocator(
            'SELECT Id, Name, Email, HasOptedOutOfEmail, AAR_Opt_In_Date__c, Global_Opt_Out_Date__c '+
            'FROM Contact WHERE RecordType.DeveloperName = \'AAR\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        try{
            processEmailGlobalOptouts(scope);
        }catch(Exception e){
            System.debug('ARM Contacts CAN-SPAM Opt-out Processing Error*** '+e.getMessage()+' @ '+e.getStackTraceString());
        }        
    }

    public void processEmailGlobalOptouts(List<Contact> contacts){
        if(optoutEmailsMap.isEmpty()) return;
        
        List<Contact> contacts2Update = new List<Contact>();
        for(Contact c : contacts){
            String email = c.Email?.toLowerCase();
            if(optoutEmailsMap.containsKey(email)){                
                c.Global_Opt_Out_Date__c = optoutEmailsMap.get(email);
                c.HasOptedOutOfEmail = c.AAR_Opt_In_Date__c == null || c.Global_Opt_Out_Date__c > c.AAR_Opt_In_Date__c;
                contacts2Update.add(c);
            }
        }
        update contacts2Update;
    }
    
    public Map<String,DateTime> getGlobalOptoutList(){
        return getGlobalOptoutList(null);
    }
    
    //Fetch full list of opted-out emails from CAN-SPAM
    public Map<String,DateTime> getGlobalOptoutList(Integer responsePageSize){
        Map<String,DateTime> email2OptoutTime = new Map<String,DateTime>();
                
        CAN_SPAM_Settings__c css = CAN_SPAM_Settings__c.getOrgDefaults();
        if(String.isBlank(css.Global_Optout_Endpoint__c) || String.isBlank(css.API_Key__c)) return email2OptoutTime;
        
        RESPONSE_PAGE_SIZE = css.Response_Page_Size__c != null ? css.Response_Page_Size__c.intValue() : RESPONSE_PAGE_SIZE;
        Integer pageSize = responsePageSize > RESPONSE_PAGE_SIZE ? responsePageSize : RESPONSE_PAGE_SIZE;
        Long totalPages = 1;
        Long page = 1;
        do{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndPoint(css.Global_Optout_Endpoint__c+'?page='+page+'&pageSize='+pageSize);
            request.setTimeout(120000);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/vnd.meltmedia.unify.global-opts.public.user-opts.v1+json');
            request.setHeader('Authorization', 'Bearer '+css.API_Key__c);
            
            HttpResponse response = !Test.isRunningTest() ? http.send(request) :
                                    AAR_Contacts_EmailOptOutBatch_Test.getCANSPAMMockResponse(RESPONSE_STATUS_CODE);
            
            System.debug('CAN-SPAM Request***'+request);
            System.debug('CAN-SPAM Response***'+response);
            System.debug('CAN-SPAM Response body***'+response.getBody());    
            
            if(response.getStatusCode() == 200){
                Decimal recordCount = Decimal.valueOf(response.getHeader('recordCount'));
                Decimal resDec = recordCount.divide(pageSize,2);
                totalPages = resDec.round(System.RoundingMode.UP);

                //Parse entire JSON response.
                JSONParser parser = JSON.createParser(response.getBody());
                String email = '';
                DateTime optoutTime = null;
                while(parser.nextToken() != null){
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                        email = '';
                        optoutTime = null;
                    }
                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'email'){
                        parser.nextValue();
                        email = parser.getText();
                    }
                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'datetime'){
                        parser.nextValue();
                        optoutTime = parser.getDateTimeValue();
                    }
                    if(String.isNotBlank(email) && optoutTime != null)
                        email2OptoutTime.put(email.toLowerCase(), optoutTime);
                }
            }
            page++;
        }while(page <= totalPages);
        
        return email2OptoutTime;
    }
    
    public void finish(Database.BatchableContext bc){}

    //Schedular part
    public static String CRON_EXP = '0 0 4 * * ?';  //Every day at 4AM
    public static String batchJobName = 'ARM Contacts CAN-SPAM Opt-out Processing';
    public static Integer batchSize = 200;
    
    //Invoke this method to schedule the batch every day at 1am
    public static String scheduleMe() {
        return scheduleMe(CRON_EXP,batchJobName,batchSize);
    }
    
    //Invoke this method to schedule the batch mentioned time
    public static String scheduleMe(String cronExp, String jobName, Integer size) {
        CRON_EXP = String.isNotBlank(cronExp) ? cronExp : CRON_EXP;
        batchJobName = String.isNotBlank(jobName) ? jobName : batchJobName;
        batchSize = size != null ? size : batchSize;
        
        AAR_Contacts_EmailOptOutBatch sc = new AAR_Contacts_EmailOptOutBatch();
        return System.schedule(batchJobName, CRON_EXP, sc);
    }
    
    //Schedular execute
    public void execute(SchedulableContext sc) {
        AAR_Contacts_EmailOptOutBatch batch = new AAR_Contacts_EmailOptOutBatch(); 
        Database.executeBatch(batch, batchSize);
    }
}