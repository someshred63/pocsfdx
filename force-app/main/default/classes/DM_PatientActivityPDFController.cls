public with sharing class DM_PatientActivityPDFController {
    private final Patient_gne__c displayedPatient;
    public DM_CaseActivityPDFController.ActivityWrapper recordToDisplay { get; set; }
    
    public DM_PatientActivityPDFController(ApexPages.StandardController standardController) {
        if (!Test.isRunningTest()) {
            standardController.addFields(new List<String>{'Name', 'pat_first_name_gne__c', 'Patient_ID_gne__c'});           
        }
        this.displayedPatient = (Patient_gne__c)standardController.getRecord();
        this.prepareRecords();
    }
    
    private void prepareRecords() {
        String displayedPatientId = this.displayedPatient.Id;
        List<Task> activitiesRelatedToPatient = new List<Task>();
        activitiesRelatedToPatient = [SELECT CreatedBy.Id, CreatedDate, LastModifiedBy.Id, LastModifiedDate, OwnerId, Activity_Type_gne__c, Anticipated_Next_Step_gne__c, Closed_Date_gne__c,
                                          Creator_Comments_gne__c, Description, ActivityDate, Id, WhoId, Preferred_Language_gne__c, Priority, Process_Category_gne__c, 
                                          WhatId, Status, SMS_gne__c, Subject, Type, Owner.Name, What.Name, Who.Name, CreatedBy.Name, LastModifiedBy.Name
                                      FROM Task
                                      WHERE WhatId = :displayedPatientId AND Subject NOT IN :DM_CaseActivityPDFController.ACTIVITIES_SUBJECTS_EXCLUDED AND isDeleted = false order by LastModifiedDate desc ALL ROWS ];
        this.recordToDisplay = new DM_CaseActivityPDFController.ActivityWrapper(this.displayedPatient.pat_first_name_gne__c + ' ' + this.displayedPatient.Name, this.displayedPatient.Patient_ID_gne__c, activitiesRelatedToPatient);   
    }
}