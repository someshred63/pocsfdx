global class AGS_ST_DM_StatusBatchLauncher_gne implements Schedulable {
    global void execute(SchedulableContext sc) {
    	// Will run 22 or 42 minutes after full hour
        DateTime presentDate = system.now();
        Integer invokeMin = presentDate.minute();
        Integer invokeHour = presentDate.hour();
        if(invokeMin < 22) {
        	invokeMin = 22;
        } else if(invokeMin < 42) {
        	invokeMin = 42;
        } else {
        	invokeMin = 22;
        	invokeHour = presentDate.hour() + 1;
        }
        Integer presentDay = presentDate.day();
        Integer presentMonth = presentDate.month();
        Integer presentYear = presentDate.year();

        String scheduleTime = '0 ' + string.valueof(invokeMin) + ' ' + string.valueof(invokeHour) + ' ' + string.valueof(presentDay) + ' ' + string.valueof(presentMonth) + ' ? ' + string.valueof(presentYear);
        AGS_ST_DM_ChangingStatusScheduler_gne schedulerObj = new AGS_ST_DM_ChangingStatusScheduler_gne(); 
        system.schedule('AGS ST Changing Status Scheduler: ' + scheduleTime, scheduleTime, schedulerObj);
    }
}