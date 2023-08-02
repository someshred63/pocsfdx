public with sharing class GNE_SFA2_SBC_Profiler {
	private Enum ActionMetricType {QUERY, QUERY_ROWS, EXEC_TIME}
	
	private static Long startMilis;
	private static Integer actionCount;
	private static List<Integer> heapNumbers;
	private static Map<String,Map<ActionMetricType,Object>> actionMetrics; 
	private static SFA2_SBC_Profiler_Log_gne__c sessionLog;
	private static List<SFA2_SBC_Profiler_Log_Action_gne__c> logActions;
	private static Map<String,List<SFA2_SBC_Profiler_Log_Action_gne__c>> logActionsMap;
	
	public static void logStart(String searchQuery) {
		PageReference pRef = ApexPages.currentPage();
		logStart(searchQuery, pRef!=null ? pRef.getURL().substringBefore('?') : null);
	}
	
	public static void logStart(String searchQuery, String location) {
		if(sessionLog==null) {
			startMilis = System.now().getTime();
			actionCount = 0;
			heapNumbers = new List<Integer>{0};
			actionMetrics = new Map<String,Map<ActionMetricType,Object>>();
			logActions = new List<SFA2_SBC_Profiler_Log_Action_gne__c>();
			logActionsMap = new Map<String,List<SFA2_SBC_Profiler_Log_Action_gne__c>>();
			
			createActionMetrics('MAIN_LOG');
			sessionLog = new SFA2_SBC_Profiler_Log_gne__c(
				Search_Query_gne__c = searchQuery,
				Location_gne__c = location
			);
		}
	}
	
	public static void setSiperianResultSize(Integer size) {
		if(sessionLog!=null) {
			sessionLog.Siperian_Result_Size_gne__c = size;
		}
	}
	
	public static void setSiperianData(Integer size, Integer totalSize, Integer pageNumber, Integer pageSize, Integer pageCount, Boolean queryMore) {
		if(sessionLog!=null) {
			sessionLog.Siperian_Result_Size_gne__c = size;
			sessionLog.Siperian_Result_Total_Size_gne__c = totalSize;
			sessionLog.Siperian_Result_Page_Number_gne__c = pageNumber;
			sessionLog.Siperian_Result_Query_More_gne__c = queryMore==true;
			sessionLog.Siperian_Result_Page_Size_gne__c = pageSize;
			sessionLog.Siperian_Result_Page_Count_gne__c = pageCount;
		}
	}
	
	public static void logEnd() {
		logEnd(null);
	}
	
	public static void logEnd(Integer resultSize) {
		if(sessionLog!=null) {
			Map<ActionMetricType,Object> aMetrics = actionMetrics.get('0_MAIN_LOG');
			Long endMilis = System.now().getTime();
			sessionLog.Execution_Time_gne__c = endMilis - startMilis;
			sessionLog.Execution_Time_gne__c = endMilis - (Long)aMetrics.get(ActionMetricType.EXEC_TIME);
			sessionLog.Query_Statements_gne__c = Limits.getQueries() - (Integer)aMetrics.get(ActionMetricType.QUERY);
			sessionLog.Query_Rows_gne__c = Limits.getQueryRows() - (Integer)aMetrics.get(ActionMetricType.QUERY_ROWS);
			sessionLog.Result_Size_gne__c = resultSize;
			
			if(System.isBatch() || System.isFuture() || System.isScheduled()) {
				intLogEnd();
			} else {
				futureLogEnd(JSON.serialize(sessionLog), JSON.serialize(logActions));
			}
		}
	}
	
	@future
	public static void futureLogEnd(String sessionLogInJSON, String logActionsInJSON) {
		sessionLog = (SFA2_SBC_Profiler_Log_gne__c)JSON.deserialize(sessionLogInJSON,SFA2_SBC_Profiler_Log_gne__c.class); 
		logActions = (List<SFA2_SBC_Profiler_Log_Action_gne__c>)JSON.deserialize(logActionsInJSON,List<SFA2_SBC_Profiler_Log_Action_gne__c>.class);
		intLogEnd();
	}
	
	private static void intLogEnd() {
		Database.DMLOptions dmlOpt = new Database.DMLOptions();
       	dmlOpt.allowFieldTruncation = true;
       	dmlOpt.optAllOrNone = false;
		
		if(sessionLog.Id==null) {
			Database.insert(sessionLog,dmlOpt);
		} else {
			Database.update(sessionLog,dmlOpt);
		}
		
		List<SFA2_SBC_Profiler_Log_Action_gne__c> lActionsToInsert = new List<SFA2_SBC_Profiler_Log_Action_gne__c>();
		List<SFA2_SBC_Profiler_Log_Action_gne__c> lActionsToUpdate = new List<SFA2_SBC_Profiler_Log_Action_gne__c>();
		
		for(SFA2_SBC_Profiler_Log_Action_gne__c lAction : logActions) {
			if(lAction.Id==null) {
				lAction.SBC_Profiler_Log_ref_gne__c = sessionLog.Id;
				lActionsToInsert.add(lAction);
			} else {
				lActionsToUpdate.add(lAction);
			}
			
		}
		
		if(!lActionsToInsert.isEmpty()) {
			Database.insert(lActionsToInsert,dmlOpt);
		}
		
		if(!lActionsToUpdate.isEmpty()) {
			Database.update(lActionsToUpdate,dmlOpt);
		}
	}
	
	public static void logActionStart(String actionName) {
		if(sessionLog!=null) {
			actionCount++;
			heapNumbers[heapNumbers.size()-1] = heapNumbers[heapNumbers.size()-1] + 1;
			List<String> hierarchyOrder = new List<String>();
			
			for(Integer idx : heapNumbers) {
				hierarchyOrder.add(String.valueOf(idx));
			}
			
			heapNumbers.add(0);
			createActionMetrics(actionName);
			SFA2_SBC_Profiler_Log_Action_gne__c logAction = new SFA2_SBC_Profiler_Log_Action_gne__c(
				Action_Name_gne__c = actionName,
				Order_gne__c = actionCount,
				Heap_Order_gne__c = String.join(hierarchyOrder, '.')
			);
			
			logActions.add(logAction);
			
			if(!logActionsMap.containsKey(actionName)) {
				logActionsMap.put(actionName, new List<SFA2_SBC_Profiler_Log_Action_gne__c>());
			}
			
			logActionsMap.get(actionName).add(logAction);
		}
	}
	
	public static void setLogActionDescription(String actionName, String description) {
		if(sessionLog!=null) {
			SFA2_SBC_Profiler_Log_Action_gne__c logAction = logActionsMap.get(actionName)[logActionsMap.get(actionName).size()-1];
			logAction.Description_gne__c = description;
			logAction.Full_Description_gne__c = description;
		}
	}
	
	public static void logActionEnd(String actionName) {
		if(sessionLog!=null) {
			heapNumbers.remove(heapNumbers.size()-1);
			SFA2_SBC_Profiler_Log_Action_gne__c logAction = logActionsMap.get(actionName).remove(logActionsMap.get(actionName).size()-1);
			Integer actionNo = logAction.Order_gne__c.intValue();
			Map<ActionMetricType,Object> aMetrics = actionMetrics.get(actionNo + '_' + actionName);
			Long endMilis = System.now().getTime();
			
			logAction.Execution_Time_gne__c = endMilis - (Long)aMetrics.get(ActionMetricType.EXEC_TIME);
			logAction.Query_Statements_gne__c = Limits.getQueries() - (Integer)aMetrics.get(ActionMetricType.QUERY);
			logAction.Query_Rows_gne__c = Limits.getQueryRows() - (Integer)aMetrics.get(ActionMetricType.QUERY_ROWS);
		}
	}
	
	private static void createActionMetrics(String actionName) {
		actionMetrics.put(actionCount + '_' + actionName, new Map<ActionMetricType,Object>{
			ActionMetricType.QUERY => Limits.getQueries(),
			ActionMetricType.QUERY_ROWS => Limits.getQueryRows(),
			ActionMetricType.EXEC_TIME => System.now().getTime()
		});
	}
}