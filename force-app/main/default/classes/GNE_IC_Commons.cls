/******************************************************************************************
*  @author: Michal Hrycenko, Roche
*  @email: michal.hrycenko@contractors.roche.com
*  Created: 01/31/2014
*  Application : IC Calculator iPhone/iPad App.
*******************************************************************************************/
global class GNE_IC_Commons {
	
	public static DateTime startTimeStamp;

	/*
        A template method - builds a webservice response object. Specialized for a 'data
        retrieval' requests. The response object contains a reqested data and an operation
        status (and some debugging information).
    */
    public static RestResponse buildResponse(ResponseBuilder builder, Object args) {
        setStartTimeStamp();
        System.debug('Building Response: ' + args);
        RestResponse response = null;
        try {
            response = builder.build(args);
            response.setSuccessStatus();
        } catch (Exception ex) {
            response = new BasicResponse(ex);
            response.setErrorStatus(ex);
        }
        System.debug('Response: ' + response);
        return response;
    }

    private class BasicResponse extends RestResponse {

        public BasicResponse() {
            setSuccessStatus();
        }

        public BasicResponse(Exception ex) {
            setErrorStatus(ex);
        }
    }

    public interface ResponseBuilder {
        RestResponse build(Object args);
    }

    private class ExceptionInfo {
        public String stackTrace;
        public String typeName;
        public String cause;
        public Integer lineNumber;
        public String message;

        public ExceptionInfo(Exception ex) {
            Exception cEx = ex.getCause();

            stackTrace  = ex.getStackTraceString();
            typeName    = ex.getTypeName();
            cause       = cEx != null ? cEx.getMessage() : '';
            lineNumber  = ex.getLineNumber();
            message     = ex.getMessage();
        }
    }

    public static void setStartTimeStamp() {
        if (startTimeStamp == null) {
            startTimeStamp = System.now();
        }
    }

    public class gneICException extends Exception {
    
    }

	/*
        A base class for all webservice response objects. Contains an operation status and
        some debugging information.
    */
    global abstract class RestResponse {
        public Boolean success = false;
        public ExceptionInfo error;
        public Map<String,String> debugInfo = new Map<String, String>();

        public void setSuccessStatus() {
            this.success = true;
            this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
            this.debugInfo.put('cpuTime', Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());

            if (GNE_IC_Commons.startTimeStamp != null) {
                this.debugInfo.put('execTime', String.valueOf(System.now().getTime() - GNE_IC_Commons.startTimeStamp.getTime()));
            }
        }

        public void setErrorStatus(Exception ex) {
            this.success = false;
            this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());

            if (GNE_IC_Commons.startTimeStamp != null) {
                this.debugInfo.put('execTime', String.valueOf(System.now().getTime() - GNE_IC_Commons.startTimeStamp.getTime()));
            }

            this.error = new ExceptionInfo(ex);
            System.debug('failed: ' + this.error);
        }
    }

}