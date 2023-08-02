global with sharing class GNE_SFA2_PFG_Scheduler implements Schedulable {
    private static final String CONFIG_SEPARATOR = ';';
	private static List<SchedulerProcess> processesToExecute;
	private static Map<String,SchedulerProcess> allProcesses;
	private static Map<String,GNE_SFA2_PFG_Config_Items_gne__c> settingsRecords;
	
    global void execute(SchedulableContext ctx)  {
    	executeJobs();
    }
    
	public static void executeJobs() {
		try {
			readConfiguration();
		
			for(SchedulerProcess sProcess: processesToExecute) {
				sProcess.executeSchedulerProcess();
			}
		} finally {
			GNE_SFA2_PFG_ExceptionHandler.reportExceptions();
		}
	}
	
	public static void activateJob(System.Type scheduleProcessClass) {
		activateJob(scheduleProcessClass, null);
	}
	
	public static void activateJob(System.Type scheduleProcessClass, Object args) {
		if(System.isBatch() || System.isFuture() || System.isScheduled()) {
    		intActivateJob(scheduleProcessClass.getName(), args!=null ? JSON.serialize(args) : null);
    	} else {
    		Set<String> sLabels = GNE_SFA2_PFG_ExceptionHandler.getSessionLabels();
    		futureActivateJob(scheduleProcessClass.getName(), args!=null ? JSON.serialize(args) : null, sLabels!=null ? JSON.serialize(sLabels) : null);
    	}
    }
	
	@future
	public static void futureActivateJob(String scheduleProcessClassName, String argsJSON, String sessionLabelsJSON) {
		if(sessionLabelsJSON!=null) {
			GNE_SFA2_PFG_ExceptionHandler.setSessionLabels((Set<String>)JSON.deserializeStrict(sessionLabelsJSON, Set<String>.class));
		}
		
		intActivateJob(scheduleProcessClassName, argsJSON);
	}
	
	public static void intActivateJob(String scheduleProcessClassName, String argsJSON) {
		try {
			readConfiguration();
			
			SchedulerProcess sProcess = allProcesses.get(scheduleProcessClassName);
			GNE_SFA2_PFG_Config_Items_gne__c settingRecord;
			if(sProcess!=null) {
				setProcessArguments(sProcess, argsJSON);
				settingRecord = settingsRecords.get(scheduleProcessClassName);
			} else {
				sProcess = createSchedulerProcess(scheduleProcessClassName, argsJSON);
				
				if(sProcess!=null) {
					settingRecord = new GNE_SFA2_PFG_Config_Items_gne__c(
							Name = getNextJobName(),
							Value_gne__c = String.join(new String[]{'* * *', scheduleProcessClassName}, CONFIG_SEPARATOR)
					);
				}
			}
			
			if(settingRecord!=null) {
				settingRecord.Arguments_gne__c = getProcessArguments(sProcess);
				settingRecord.Is_Active_gne__c = true;
				upsert settingRecord;
			}
		} catch(Exception ex) {
			GNE_SFA2_PFG_ExceptionHandler.handleException(ex);
		} finally {
			GNE_SFA2_PFG_ExceptionHandler.reportExceptions();
		}
	}
	
	private static String getNextJobName() {
		Integer nextJobNumber = 1;
		String nextJobName = GNE_SFA2_PFG_Config.SCHEDULE_JOB_PREFIX + nextJobNumber;
		Set<String> existingKeys = GNE_SFA2_PFG_Config.SCHEDULE_JOBS_INFO.keySet();
		
		while(existingKeys.contains(nextJobName)) {
			nextJobName = GNE_SFA2_PFG_Config.SCHEDULE_JOB_PREFIX + (++nextJobNumber);
		}
		
		return nextJobName;
	}
	
	public static void deactivateJob(System.Type scheduleProcessClass) {
		if(System.isBatch() || System.isFuture() || System.isScheduled()) {
    		intDeactivateJob(scheduleProcessClass.getName());
    	} else {
    		Set<String> sLabels = GNE_SFA2_PFG_ExceptionHandler.getSessionLabels();
    		futureDeactivateJob(scheduleProcessClass.getName(), sLabels!=null ? JSON.serialize(sLabels) : null);
    	}
	}
	
	@future
	public static void futureDeactivateJob(String scheduleProcessClassName, String sessionLabelsJSON) {
		if(sessionLabelsJSON!=null) {
			GNE_SFA2_PFG_ExceptionHandler.setSessionLabels((Set<String>)JSON.deserializeStrict(sessionLabelsJSON, Set<String>.class));
		}
		
		intDeactivateJob(scheduleProcessClassName);
	}
	
	public static void intDeactivateJob(String scheduleProcessClassName) {
    	try {
			readConfiguration();
			GNE_SFA2_PFG_Config_Items_gne__c settingRec = settingsRecords.get(scheduleProcessClassName);
			
			if(settingRec!=null) {
				settingRec.Arguments_gne__c = null;
				settingRec.Is_Active_gne__c = false;
				update settingRec;
			}
    	} catch(Exception ex) {
			GNE_SFA2_PFG_ExceptionHandler.handleException(ex);
		} finally {
			GNE_SFA2_PFG_ExceptionHandler.reportExceptions();
		}
	}
	
	public static void readConfiguration() {
		DateTime dTimeNow = System.now();
		processesToExecute = new List<SchedulerProcess>();
		allProcesses = new Map<String,SchedulerProcess>();
		settingsRecords = new Map<String,GNE_SFA2_PFG_Config_Items_gne__c>();
		
		for(String jobKey : GNE_SFA2_PFG_Config.SCHEDULE_JOBS_INFO.keySet()) {
			String jobInfo = GNE_SFA2_PFG_Config.SCHEDULE_JOBS_INFO.get(jobKey);
			Map<String,String> jobInfoMap = (Map<String,String>)JSON.deserialize(jobInfo, Map<String,String>.class);
			String jobInfoString = jobInfoMap!=null ? jobInfoMap.get('JOB_INFO') : null;
			String jobArgsString = jobInfoMap!=null ? jobInfoMap.get('JOB_ARGS') : null;
			Boolean isActive = jobInfoMap!=null ? Boolean.valueOf(jobInfoMap.get('IS_ACTIVE')) : null;
			
			String[] jobData = (jobInfoString!=null ? jobInfoString : '').split(CONFIG_SEPARATOR);
			Integer dataSize = jobData.size();
				
			if(dataSize>0) {
				String className = jobData[dataSize-1];
				Boolean shouldBeExecutedNow = false;
					
				try {
					shouldBeExecutedNow = isActive && (dataSize>1 ? (new CronExpression(jobData[0]).matches(dTimeNow)) : true);
				} catch(CronParserException cpe) {
					GNE_SFA2_PFG_ExceptionHandler.handleException(cpe);
				}
				
				SchedulerProcess sProcess = createSchedulerProcess(className, jobArgsString);
				
				if(sProcess!=null) {
					allProcesses.put(className, sProcess);
					settingsRecords.put(className, GNE_SFA2_PFG_Config.configItemsMap.get(jobKey));
					
					if(shouldBeExecutedNow) {
						processesToExecute.add(sProcess);
					}
				}
			}
		}
	}
	
	private static SchedulerProcess createSchedulerProcess(String className, String processArgs) {
		System.Type sProcessType = System.Type.forName(className!=null ? className : '');
		SchedulerProcess sProcess;
				
		if(sProcessType!=null) {
			try {
				sProcess = (SchedulerProcess)sProcessType.newInstance();
			} catch(System.TypeException ex) {
				GNE_SFA2_PFG_ExceptionHandler.handleException(new NotValidProcessClassException(className, null));
			}
		} else {
			GNE_SFA2_PFG_ExceptionHandler.handleException(new NotValidProcessClassException(className, null));
		}
		
		setProcessArguments(sProcess, processArgs);
		
		return sProcess;
	}
	
	private static void setProcessArguments(SchedulerProcess sProcess, String processArgs) {
		if(sProcess!=null && processArgs!=null && sProcess instanceof SchedulerProcessWithArguments) {
			((SchedulerProcessWithArguments)sProcess).setArguments(processArgs);
		}
	}
	
	private static String getProcessArguments(SchedulerProcess sProcess) {
		String argsJSON;
		
		if(sProcess!=null && sProcess instanceof SchedulerProcessWithArguments) {
			argsJSON = ((SchedulerProcessWithArguments)sProcess).getArguments();
		}
		
		return argsJSON;
	}
	
	public class CronExpression {
		private String dayOfMonth;
		private String month;
		private String dayOfWeek;
		
		private Set<Integer> validDaysOfMonth;
		private Set<Integer> validMonths;
		private Set<Integer> validDaysOfWeek;
		
		private final String COLUMN_SEPARATOR = ' ';
		private final String CRON_ALL_VALUES_CHAR = '*';
		private final String CRON_NO_SPECIFIC_VALUE_CHAR = '?';
		private final String CRON_LIST_SEPARATOR = ',';
		private final String CRON_RANGE_SEPARATOR = '-';
		private final String ORDERED_DAY_NAMES = 'SUN,MON,TUE,WED,THU,FRI,SAT';
		private final String ORDERED_MONTH_NAMES = 'JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC';
		
		public CronExpression(String cronExpr) {
			String[] columns = cronExpr.split(COLUMN_SEPARATOR);
			
			if(columns.size()==3) {
				String dayOfMonthData = columns[0];
				String monthData = columns[1];
				String dayOfWeekData = columns[2];
				
				validDaysOfMonth = getAvailableValues(dayOfMonthData, 1,31, null);
				validMonths = getAvailableValues(monthData, 1,12, ORDERED_MONTH_NAMES);
				validDaysOfWeek = getAvailableValues(dayOfWeekData, 1,7, ORDERED_DAY_NAMES);
			} else {
				throw new CronParserException(cronExpr, cronExpr);
			}
		}
		
		private Set<Integer> getAvailableValues(String inputData, Integer startIdx, Integer endIdx, String orderedTextValues) {
			// Empty set means that all values are available
			Set<Integer> availableValues = new Set<Integer>();
			
			if(!inputData.equals(CRON_ALL_VALUES_CHAR) && !inputData.equals(CRON_NO_SPECIFIC_VALUE_CHAR)) {
				for(String listElement : inputData.split(CRON_LIST_SEPARATOR)) {
					String ulistElement = listElement.toUpperCase();
					String rangeStartElement = ulistElement;
					String rangeEndElement = ulistElement;
					
					if(ulistElement.contains(CRON_RANGE_SEPARATOR)) {
						String[] range = ulistElement.split(CRON_RANGE_SEPARATOR);
						rangeStartElement = range[0];
						rangeEndElement = range[1];
					}
					
					Integer elementStartIdx = null, elementEndIdx = null;
					
					try{
						elementStartIdx = (orderedTextValues!=null && rangeStartElement.length()==3 && orderedTextValues.indexOf(rangeStartElement)!=-1) 
							? (orderedTextValues.indexOf(rangeStartElement)/4+1)
							: Integer.valueOf(rangeStartElement);
							
						elementEndIdx = (orderedTextValues!=null && rangeStartElement.length()==3 && orderedTextValues.indexOf(rangeEndElement)!=-1) 
							? (orderedTextValues.indexOf(rangeEndElement)/4+1)
							: Integer.valueOf(rangeEndElement);
							
					} catch(System.TypeException ex) {
						throw new CronParserException(listElement, inputData);
					}
					
					if(elementStartIdx<startIdx || elementStartIdx>endIdx) {
						throw new CronParserException(listElement, inputData, rangeStartElement + ' is out of range ' + startIdx + CRON_RANGE_SEPARATOR + endIdx);
					} else if(elementEndIdx<startIdx || elementEndIdx>endIdx) {
						throw new CronParserException(listElement, inputData, rangeEndElement + ' is out of range ' + startIdx + CRON_RANGE_SEPARATOR + endIdx);
					} else if(elementStartIdx>elementEndIdx) {
						throw new CronParserException(listElement, inputData, 'try maybe \'' + rangeEndElement + CRON_RANGE_SEPARATOR + rangeStartElement + '\'');
					}
					
					for(Integer i = elementStartIdx; i<=elementEndIdx; i++) {
						availableValues.add(i);
					}
				}
			} 
			
			return availableValues;
			
		}
		
		public Boolean matches(DateTime a_dTime) {
			Integer a_dayOfMonth = a_dTime.day();
			Integer a_month = a_dTime.month();
			Integer a_dayOfWeek = ORDERED_DAY_NAMES.indexOf(a_dTime.format('E').toUpperCase())/4 + 1;
			
			Boolean isLastDayOfMonth = a_dTime.addDays(1).day() < a_dayOfMonth;
			
			Boolean dayOfMothMatches = validDaysOfMonth.isEmpty() || validDaysOfMonth.contains(a_dayOfMonth) || (isLastDayOfMonth && isLastDayOfMonthAvailable(a_dayOfMonth));
			Boolean mothMatches = validMonths.isEmpty() || validMonths.contains(a_month);
			Boolean dayOfWeekMatches = validDaysOfWeek.isEmpty() || validDaysOfWeek.contains(a_dayOfWeek);
			
			return dayOfMothMatches && mothMatches && dayOfWeekMatches;
		}
		
		private Boolean isLastDayOfMonthAvailable(Integer lastDayOfMonth) {
			List<Integer> validDays = new List<Integer>(validDaysOfMonth);
			validDays.sort();
			return lastDayOfMonth < validDays[validDays.size()-1];
		}
	}
	
	public class CronParserException extends Exception {
		public CronParserException(String element, String inputText) {
			this(element, inputText, null);
		}
		
		public CronParserException(String element, String inputText, String additionalInfo) {
			this('Couldn\'t parse \'' + inputText + '\'. Reason: \'' + element + '\' is not correct CRON Format' + (additionalInfo!=null ? ', ' + additionalInfo : ''));
		}
	}
	
	public class NotValidProcessClassException extends Exception {
		public NotValidProcessClassException(String className, Boolean notNeededArg) {
			this('\'' + className + '\' doesn\'t exist or doesn\'t implement ' + SchedulerProcess.class.getName());
		}
	}
	
	public interface SchedulerProcess {
		void executeSchedulerProcess();
	}
	
	public interface SchedulerProcessWithArguments extends SchedulerProcess {
		void setArguments(String argsJSON);
		String getArguments();
	}
}