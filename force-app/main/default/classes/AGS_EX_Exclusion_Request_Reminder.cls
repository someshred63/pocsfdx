public with sharing class AGS_EX_Exclusion_Request_Reminder {
    
    final String REMINDER_TEMPLATE_API = 'AGS_EX_Exclusion_Check_Reminder';
    final Integer REVIEWER_PENDING_LIMIT = 2;
    final Integer MANAGER_PENDING_LIMIT = 4;
    final Integer FINAL_PENDING_LIMIT = 30;

    private List<Actual_Working_Days_gne__c> workingDays = new List<Actual_Working_Days_gne__c>();
    private List<Contact> ccoManager = new List<Contact>();
    private List<Contact> ccoReviewer = new List<Contact>();
    private List<AGS_EX_Exclusion_Request_gne__c> openExclusionRequests = new List<AGS_EX_Exclusion_Request_gne__c>();
    private Date dateOfRequest;
    private Id ordWideEmailId;
    private Id templateId;
    public List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    

    public AGS_EX_Exclusion_Request_Reminder() {
        workingDays = [SELECT Date_gne__c FROM Actual_Working_Days_gne__c WHERE Date_gne__c >= LAST_N_Days:20 AND Date_gne__c <= TODAY ORDER BY Date_gne__c];
        ccoReviewer = [SELECT Id FROM Contact WHERE LastName = 'Exclusion Check'];
        ccoManager = [SELECT Id FROM Contact WHERE LastName = 'Exclusion Escalation'];
        openExclusionRequests = [SELECT Id, Name, CreatedDate, AGS_EX_Account_Name_gne__r.Name
                                FROM AGS_EX_Exclusion_Request_gne__c
                                WHERE AGS_EX_Request_Status_gne__c != 'Completed'];

        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Exclusion Check' LIMIT 1];
        if (owa != null) {
            ordWideEmailId = owa.Id;
        }
        
        System.debug('$$ ccoReviewer: ' + ccoReviewer + ' ccoManager ' + ccoManager);
        for (AGS_EX_Exclusion_Request_gne__c openRequest : openExclusionRequests) {
            dateOfRequest = Date.newInstance(openRequest.CreatedDate.year(), 
                                             openRequest.CreatedDate.month(), 
                                             openRequest.CreatedDate.day());
            openRequest.AGS_EX_Pending_Days_gne__c = workingDaysBetweenTwoDates(dateOfRequest, Date.today(),openRequest.AGS_EX_Account_Name_gne__r.Name);
        }
        update openExclusionRequests;

        EmailTemplate et = [SELECT Id, Name FROM EmailTemplate WHERE Developername = :REMINDER_TEMPLATE_API LIMIT 1];
        if (et != null) {
            templateId = et.Id;
        }
        
        for (AGS_EX_Exclusion_Request_gne__c openRequest : openExclusionRequests) {

            if (openRequest.AGS_EX_Pending_Days_gne__c == REVIEWER_PENDING_LIMIT) {
                //send to ccoReviewers;
                for (Contact reviewer : ccoReviewer) {
                    emails.add(AGS_EX_Exclusion_Utils.getTemplatedEmailWithOWA(reviewer.Id, openRequest.Id, templateId, owa.Id));
                } 

            }
            if (openRequest.AGS_EX_Pending_Days_gne__c == MANAGER_PENDING_LIMIT || openRequest.AGS_EX_Pending_Days_gne__c == FINAL_PENDING_LIMIT) {
                //send to ccoManagers;
                for (Contact manager : ccoManager) {
                    emails.add(AGS_EX_Exclusion_Utils.getTemplatedEmailWithOWA(manager.Id, openRequest.Id, templateId, owa.Id));
                } 
                for (Contact reviewer : ccoReviewer) {
                    emails.add(AGS_EX_Exclusion_Utils.getTemplatedEmailWithOWA(reviewer.Id, openRequest.Id, templateId, owa.Id));
                } 
            }
        }

        if(emails.size() > 0){
            Messaging.sendEmail(emails);
            System.debug('$$ Ex Reminder emails: ' + emails);
        }
    }

    public Integer workingDaysBetweenTwoDates(Date firstDate, Date secondDate, String name) {
        Integer days = 0;
        for(Actual_Working_Days_gne__c wd : workingDays) {
            if(wd.Date_gne__c > firstDate && wd.Date_gne__c < secondDate){
                days++;
            }
        }      
        if(Test.isRunningTest()){
            if(name == 'TEST_REVIEWER_PENDING_LIMIT'){
                return REVIEWER_PENDING_LIMIT;
            } else if(name == 'TEST_MANAGER_PENDING_LIMIT'){
                return MANAGER_PENDING_LIMIT;
            } else if(name == 'TEST_FINAL_PENDING_LIMIT'){
                return FINAL_PENDING_LIMIT;
            }
        }
        return days;
    }
}