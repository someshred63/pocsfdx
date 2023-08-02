@isTest 
public class AAR_Contacts_EmailOptOutBatch_Test {
    
    @testSetup static void createData(){
        Account acc = new Account();
        acc.Name = 'Test AAR Account';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AAR').getRecordTypeId();
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<10; i++){
            Contact c = new Contact();
            c.AccountId = acc.Id;
            c.FirstName = 'AAR FN';
            c.LastName = 'AAR LN';
            c.Email = 'aarcontact'+i+'@aartest.com';
            c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('AAR').getRecordTypeId();
            contacts.add(c);
        }
        insert contacts;
        
        CAN_SPAM_Settings__c css = new CAN_SPAM_Settings__c();
        css.Global_Optout_Endpoint__c = 'https://canspam.com';
        css.API_Key__c = 'test.1382832reyryeeiuryeeru';
        css.Response_Page_Size__c = 100;
        insert css;
    }

    @isTest static void test_AAR_Contacts_EmailOptOutBatch(){
        Test.startTest();

        AAR_Contacts_EmailOptOutBatch batch = new AAR_Contacts_EmailOptOutBatch();
        Database.executeBatch(batch);

        //Schedule the test job
        AAR_Contacts_EmailOptOutBatch.batchJobName = 'AAR_Contacts_EmailOptOutBatch_TEST';
        String jobId = AAR_Contacts_EmailOptOutBatch.scheduleMe();
        
        //Get the information from the CronTrigger API object
        List<CronTrigger> cts = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId LIMIT 1];       
        
        //Verify the job has not run
        System.assertEquals(0, cts[0].TimesTriggered);

        Test.stopTest();
    }
    
    public static HttpResponse getCANSPAMMockResponse(Integer statusCode){
        HttpResponse response = new HttpResponse();
        response.setHeader('recordCount', '2');
        response.setStatusCode(statusCode);
        String body = statusCode != 200 ? '' : 
            '[{"email":"aarcontact1@aartest.com","datetime":"2016-07-21T04:34:45.000Z","type":"global"},{"email":"aarcontact2@aartest.com","datetime":"2016-08-21T04:34:45.000Z","type":"global"}]';
        response.setBody(body);
        return response;
    }
}