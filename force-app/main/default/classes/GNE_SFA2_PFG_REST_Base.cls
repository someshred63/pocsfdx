public with sharing abstract class GNE_SFA2_PFG_REST_Base {
	public abstract class ResultSet {
        public Boolean success = false;
        public GNE_SFA2_PFG_REST_Utils.ExceptionInfo error;
        public Map<String, String> debugInfo = new Map<String,String>();
        public transient DateTime startTimeStamp = System.now();
    }
    
    public ResultSet processInputObjects(List<Object> inputObjects, ResultSet result) {
    	ResultSet prevResult = result.clone();
    	
    	try {
    		GNE_SFA2_PFG_Util.addSessionLabel(String.valueOf(this).substringBefore(':'));
    		
			intProcessInputObjects(inputObjects, result);
			
			System.Savepoint sp = Database.setSavepoint();
			
			try {
				executeDmls(result);
				result.success = true;
			} finally {
				if(!result.success) {
					Database.rollback(sp);
				} 
				
				if(result.debugInfo!=null) {
					result.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
					result.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
					result.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
                	result.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
					result.debugInfo.put('dmlStatements', Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
					result.debugInfo.put('dmlRows', Limits.getDmlRows() + '/' + Limits.getLimitDmlRows());
					result.debugInfo.put('execTime', String.valueOf(System.now().getTime() - result.startTimeStamp.getTime()));
				}
			}
		} catch(Exception ex) {
			GNE_SFA2_PFG_Util.handleException(ex);
			result = prevResult;
			result.error = new GNE_SFA2_PFG_REST_Utils.ExceptionInfo(ex);
		} finally {
			GNE_SFA2_PFG_Util.intReportExceptions();
		}
			
		return result;
    }
    
    public ResultSet prepareOutputObjects(String lastSyncDate, ResultSet result) {
    	return prepareOutputObjects(GNE_SFA2_PFG_REST_Utils.parseDateTime(lastSyncDate), result);
    }
    
    public ResultSet prepareOutputObjects(Object inputData, ResultSet result) {
    	ResultSet prevResult = result.clone();
    	
    	try {
    		GNE_SFA2_PFG_Util.addSessionLabel(String.valueOf(this).substringBefore(':'));
    		
    		intPrepareOutputObjects(inputData, result);	
    		result.success = true;
        } catch(Exception ex) {
        	GNE_SFA2_PFG_Util.handleException(ex);
            result = prevResult;
            result.error = new GNE_SFA2_PFG_REST_Utils.ExceptionInfo(ex);
        } finally {
        	if(result.debugInfo!=null) {
                result.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
                result.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
                result.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
                result.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
                result.debugInfo.put('execTime', String.valueOf(System.now().getTime() - result.startTimeStamp.getTime()));
            }
            
            GNE_SFA2_PFG_Util.intReportExceptions();
        }
        
    	return result;
    }
    
    protected virtual void intProcessInputObjects(List<Object> inputObjects, ResultSet result) {}
    
    protected virtual void intPrepareOutputObjects(Object inputData, ResultSet result) {
    	intPrepareOutputObjects((DateTime)inputData, result);
    }
    
    protected virtual void intPrepareOutputObjects(DateTime lastSyncDate, ResultSet result) {}
    protected virtual void executeDmls(ResultSet result) {}
    
    
}