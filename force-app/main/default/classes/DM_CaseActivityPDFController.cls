public with sharing class DM_CaseActivityPDFController {
    private final Case displayedCase;
    public ActivityWrapper recordToDisplay { get; set; }
    public static final Set<String> ACTIVITIES_SUBJECTS_EXCLUDED = new Set<String>{'Reported Potential Adverse Event - Live', 'Reported Potential Adverse Event - VM', 'Reported Potential Adverse Event - Document'};
    
    public String appDenialDateFormatted {
        get {
            return appDenialDateFormatted;
        }
        set;
    }

    public String insEliDateFormatted {
        get {
            return insEliDateFormatted;
        }
        set;
    }

    public String enrSignedDateFormatted {
        get {
            return enrSignedDateFormatted;
        }
        set;
    }

    public String referredDateFormatted {
        get {
            return referredDateFormatted;
        }
        set;
    }

    public String eliDocReceivedDateFormatted {
        get {
            return eliDocReceivedDateFormatted;
        }
        set;
    }       
         
    public String dateTimeClosedFormatted {
        get {
            return dateTimeClosedFormatted;
        }
        set;
    }       

    public String enrRecDateFormatted {
        get {
            return enrRecDateFormatted;
        }
        set;
    }         

    public DM_CaseActivityPDFController(ApexPages.StandardController standardController) {
        
        if (!Test.isRunningTest()) {
            standardController.addFields(new List<String>{'CaseNumber', 'Approval_Denial_Date_gne__c', 'Insurance_Eligibility_Determination_Date__c', 'Enroll_SMN_Form_Signed_Date_gne__c', 'Referred_By_Date_gne__c', 'Eligibility_Document_Received_Date_gne__c', 'ClosedDate', 'Enrollment_Form_Rec_gne__c'});           
        }
        this.displayedCase = (Case)standardController.getRecord();
        this.prepareRecords();

        Datetime denialDate = displayedCase.Approval_Denial_Date_gne__c;
        if(denialDate != null) {
            appDenialDateFormatted = denialDate.format();
        }

        Datetime insEliDate = displayedCase.Insurance_Eligibility_Determination_Date__c;
        if(insEliDate != null) {
            insEliDateFormatted = insEliDate.format();
        }

        Datetime enrSignedDate = displayedCase.Enroll_SMN_Form_Signed_Date_gne__c;
        if(enrSignedDate != null) {
            enrSignedDateFormatted = enrSignedDate.format();
        }

        Datetime referredDate = displayedCase.Referred_By_Date_gne__c;
        if(referredDate != null) {
            referredDateFormatted = referredDate.format();
        }

        Datetime eliDocReceivedDate = displayedCase.Eligibility_Document_Received_Date_gne__c;
        if(eliDocReceivedDate != null) {
            eliDocReceivedDateFormatted = eliDocReceivedDate.format();
        }                

        Datetime dateTimeClosed = displayedCase.ClosedDate;
        if(dateTimeClosed != null) {
            dateTimeClosedFormatted = dateTimeClosed.format();
        }           

        Datetime enrRecDate = displayedCase.Enrollment_Form_Rec_gne__c;
        if(enrRecDate != null) {
            enrRecDateFormatted = enrRecDate.format();
        }            
    }

    private void prepareRecords() {
        String displayedCaseId = this.displayedCase.Id;
        Set<String> taskRelatedToIds = new Set<String>();
        Set<String> BIs = new Set<String>();
        taskRelatedToIds.add(displayedCaseId);
        
        for (Benefit_Investigation_gne__c bi : [SELECT Id FROM Benefit_Investigation_gne__c WHERE Case_BI_gne__c = :displayedCaseId]) {
            taskRelatedToIds.add(bi.Id);
            BIs.add(BI.Id);
        }
        for (Shipment_gne__c ship : [SELECT Id FROM Shipment_gne__c WHERE Case_Shipment_Request_gne__c = :displayedCaseId OR Case_Shipment_gne__c = :displayedCaseId]) {
            taskRelatedToIds.add(ship.Id);
        }
        for (Insurance_gne__c ins : [SELECT Id FROM Insurance_gne__c WHERE Case_Insurance_gne__c = :displayedCaseId]) {
            taskRelatedToIds.add(ins.Id);
        }
        for (Prior_Authorization_gne__c pa : [SELECT Id FROM Prior_Authorization_gne__c WHERE Benefit_Investigation_gne__c IN :BIs]) {
            taskRelatedToIds.add(pa.Id);
        }
        for (Alternative_Funding_gne__c addSup : [SELECT Id FROM Alternative_Funding_gne__c WHERE Case_gne__c = :displayedCaseId]) {
            taskRelatedToIds.add(addSup.Id);
        }
        
        List<Task> activitiesRelatedToCase = new List<Task>();
        activitiesRelatedToCase = [SELECT CreatedBy.Id, CreatedDate, LastModifiedBy.Id, LastModifiedDate, OwnerId, Activity_Type_gne__c, Anticipated_Next_Step_gne__c, Closed_Date_gne__c,
                                          Creator_Comments_gne__c, Description, ActivityDate, Id, WhoId, Preferred_Language_gne__c, Priority, Process_Category_gne__c, 
                                          WhatId, Status, SMS_gne__c, Subject, Type, Owner.Name, What.Name, Who.Name, CreatedBy.Name, LastModifiedBy.Name
                                   FROM Task
                                   WHERE WhatId IN :taskRelatedToIds AND Subject NOT IN :ACTIVITIES_SUBJECTS_EXCLUDED AND isDeleted = false order by LastModifiedDate desc ALL ROWS ];
        this.recordToDisplay = new ActivityWrapper(this.displayedCase.CaseNumber, this.displayedCase.Id, activitiesRelatedToCase);  
    }
    
    public class ActivityWrapper {
        public String taskParentName { get; set; }
        public String taskParentId { get; set; }
        public List<Task> activitiesRelatedToParent { 
            get {
                if (activitiesRelatedToParent == null) {
                    activitiesRelatedToParent = new List<Task>();
                }
                return activitiesRelatedToParent;           
            }
            private set; 
        }
        
        public ActivityWrapper(String taskParentName, String taskParentId, List<Task> activitiesRelatedToParent) {
            this.taskParentName = taskParentName;
            this.taskParentId = taskParentId;
            this.activitiesRelatedToParent.addAll(activitiesRelatedToParent);
        }
    }
}