global class ELF_Scheduler implements Schedulable {

        public string twoDigits(String inputString){
            if(inputString.length() == 1){
                inputString = '0' + inputString;
            }

        return inputString;
        }

        global void execute(SchedulableContext sc) {

            //Derive Parameters for Current Time
            DateTime isRightNow = System.Now();
            String isYrNow = string.valueOf(isRightNow.year());
            String isMoNow = twoDigits(string.valueOf(isRightNow.month()));
            String isDyNow = twoDigits(string.valueOf(isRightNow.day()));
            String isHrNow = twoDigits(string.valueOf(isRightNow.hour()));
            String isMnNow = twoDigits(string.valueOf(isRightNow.minute()));
            String isNowCron = '0 '+ isMnNow + ' ' + isHrNow + ' ' + isDyNow + ' ' + isMoNow + ' ? ' + isYrNow;
            String isNowName = isYrNow + '-' + isMoNow + '-' + isDyNow + '-' + isHrNow + ':' + isMnNow;

            //Get Appropriate Rescheduling Interval
            String SFDC2InsightsRecordName2Use;
            if(Test.isRunningTest()){
                SFDC2InsightsRecordName2Use = 'thisisatest';
            }
            else{
                SFDC2InsightsRecordName2Use = 'Default App Settings';
            }
            SFDC2Insights__c sfdc2Insights = SFDC2Insights__c.getValues(SFDC2InsightsRecordName2Use);
            Integer frequencyMn = integer.valueOf(sfdc2Insights.PollingFrequency__c);

            //Derive Parameters for Next Scheduled Runtime
            DateTime isNextRun = isRightNow.addMinutes(frequencyMn);
            String isYrNextRun = string.valueOf(isRightNow.year());
            String isMoNextRun = twoDigits(string.valueOf(isNextRun.month()));
            String isDyNextRun = twoDigits(string.valueOf(isNextRun.day()));
            String isHrNextRun = twoDigits(string.valueOf(isNextRun.hour()));
            String isMnNextRun = twoDigits(string.valueOf(isNextRun.minute()));
            String isNextRunCron = '0 '+ isMnNextRun  + ' ' + isHrNextRun  + ' ' + isDyNextRun  + ' ' + isMoNextRun  + ' ? ' + isYrNextRun;
            String isNextRunName = isYrNextRun + '-' + isMoNextRun + '-' + isDyNextRun + '-' + isHrNextRun + ':' + isMnNextRun;
        
            Id my_id; 
            String query = 'SELECT CreatedById, CreatedDate, EventType, Id, LastModifiedDate, LogDate, LogFile, LogFileContentType, LogFileLength FROM EventLogFile WHERE CreatedDate < TOMORROW'; 
                
            II.generateJson();

            //Schedule Next Job
            ELF_Scheduler m = new Elf_Scheduler();
            String jobName = 'EventLogFile_' + isNextRUnName;

            System.Debug('GMP - Reschedule JobName = ' + JobName + ' CRON = ' + isNextRunCron);

            String jobID = system.schedule(jobName, isNextRunCron, m);
    }
}