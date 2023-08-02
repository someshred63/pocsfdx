@isTest(seeAllData=false)
private class CloseFields_Test {
    static testMethod void TestMethodForStatusChange() {
        Id devRecordTypeId = Schema.SObjectType.Issue_Log__c.getRecordTypeInfosByName().get('New Issue Log').getRecordTypeId();
        Issue_Log__c issuelog= new Issue_Log__c(Issue_Type__c='New',
                                                Open_Date__c=Date.today(),
                                                Issue_Description__c='test',
                                                Reporting_Period__c='2021 Q3',
                                                Affected_NDC__c='N/A',
                                                Attestation_Required__c='Yes',
                                                Issue_Status__c='Open',                                                
                                                RecordTypeid=devRecordTypeId);
        insert issuelog;
        try{
            issuelog.Issue_Status__c='Closed';
            
            update issuelog;
            
        }
        catch(exception exp){}
        /* */
    }
    
}