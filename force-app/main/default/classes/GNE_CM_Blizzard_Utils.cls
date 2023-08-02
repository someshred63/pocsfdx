public with sharing class GNE_CM_Blizzard_Utils {

    public static final Date CURRENT_DATE = Date.today();
    
    public static final Date ELIGIBLE_ADOT_START_DATE;
    public static final Date ELIGIBLE_ADOT_END_DATE;
    public static final DateTime PAN_EXPIRATION_DATETIME;
    public static final Date ADOT_SUBMISSION_END_DATE;
    
    
    public static final Date BR_CURRENT_YEAR_BATCH_START_DATE;
    public static final Date BR_CURRENT_YEAR_BATCH_END_DATE;

    static {
        Integer currentYear = Date.today().year();
        Integer nextYear = currentYear + 1;
        Integer previousYear = currentYear - 1;
        
        GNE_CM_MPS_Custom_Setting__c cs = GNE_CM_MPS_Custom_Setting__c.getInstance('MPS_Configuration');
        ADOT_SUBMISSION_END_DATE = cs.Blizzard_Submission_End_Date__c != null ? cs.Blizzard_Submission_End_Date__c : Date.newInstance(currentYear, 12,31);
            
        ELIGIBLE_ADOT_START_DATE = cs.ADOT_Schedule_Start_Date__c != null ? cs.ADOT_Schedule_Start_Date__c : Date.newInstance(nextYear, 1, 2);
        
        ELIGIBLE_ADOT_END_DATE = cs.ADOT_Schedule_End_Date__c != null ? cs.ADOT_Schedule_End_Date__c : Date.newInstance(nextYear, 2, 27);
        
        PAN_EXPIRATION_DATETIME = DateTime.newInstance(ELIGIBLE_ADOT_END_DATE, Time.newInstance(0,0,0,0));

        Set<String> bRListOfJobsToStart = new Set<String>{'GNE_CM_BRC_Actemra_Batch', 'GNE_CM_BRC_Lucentis_Batch'};
        Set<String> bRListOfJObsToEnd = new Set<String>{'GNE_CM_BR_EndOfBlizzard_Cleanup'};
        BR_CURRENT_YEAR_BATCH_START_DATE = cs.Blizzard_Submission_Start_Date__c !=null? cs.Blizzard_Submission_Start_Date__c : Date.newInstance(previousYear, 11, 08);
        
        for (Benefits_Reverification_Schedulers_gne__c brJobs : [SELECT Id, Job_Name__c, Schedule_Date_gne__c, Last_Date_Of_Month__c, Day_of_Month__c, Month__c FROM Benefits_Reverification_Schedulers_gne__c]) {
            /*if (bRListOfJobsToStart.contains(brJobs.Job_Name__c) && BR_CURRENT_YEAR_BATCH_START_DATE==null) {
                BR_CURRENT_YEAR_BATCH_START_DATE = Date.newInstance(CURRENT_DATE.year(), Integer.valueOf(brJobs.Month__c), Integer.valueOf(brJobs.Day_of_Month__c));
            }*/
            if (bRListOfJObsToEnd.contains(brJobs.Job_Name__c)) {
                BR_CURRENT_YEAR_BATCH_END_DATE = Date.newInstance(CURRENT_DATE.year()+1, Integer.valueOf(brJobs.Month__c), Integer.valueOf(brJobs.Day_of_Month__c)).addDays(-1);
                if (BR_CURRENT_YEAR_BATCH_END_DATE == CURRENT_DATE)
                {
                    break;
                }
            }
        }
        /*if (BR_CURRENT_YEAR_BATCH_START_DATE == null) {
            BR_CURRENT_YEAR_BATCH_START_DATE = Date.newInstance(nextYear, 11, 10);
        }*/
        if (BR_CURRENT_YEAR_BATCH_END_DATE == null) {
            BR_CURRENT_YEAR_BATCH_END_DATE = Date.newInstance(nextYear, 12, 31);
        }
    }
    
    public static Boolean isBlizzardPeriod(Date dateParam) {
        return (dateParam >= BR_CURRENT_YEAR_BATCH_START_DATE && dateParam <= ELIGIBLE_ADOT_END_DATE);
    }
    
    public static Boolean isBlizzardSubmissionPeriod(Date dateParam) {
        return (dateParam >= BR_CURRENT_YEAR_BATCH_START_DATE && dateParam <= ADOT_SUBMISSION_END_DATE);
    }
    
    public static Boolean isAdotEligible(Date dateToCheck) {
        return (dateToCheck >= ELIGIBLE_ADOT_START_DATE && dateToCheck <= ELIGIBLE_ADOT_END_DATE);
    }
}