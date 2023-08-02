public with sharing class GNE_SFA2_PFG_REST_Utils {
    
    public static final String DEFAULT_DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss.S';
    public static final String DEFAULT_DATE_FORMAT = 'yyyy-MM-dd';
    public static final String DATE_TIME_DYNAMIC_SOQL_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    
    public static String formatDateTime(DateTime dateTimeValue) {
        return formatDateTime(dateTimeValue, DEFAULT_DATETIME_FORMAT);
    }
    
    public static String formatDateTime(DateTime dateTimeValue, String dateTimeFormat) {
        return dateTimeValue!=null ? dateTimeValue.format(dateTimeFormat) : '';
    }
    
    public static String formatDateTimeGmt(DateTime dateTimeValue){
        return dateTimeValue!=null ? dateTimeValue.formatGmt(DEFAULT_DATETIME_FORMAT) : '';
    }
    
    public static String formatDateTimeSOQL(DateTime dateTimeValue){
        return dateTimeValue != null ? dateTimeValue.formatGmt(DATE_TIME_DYNAMIC_SOQL_FORMAT) : '';
    }
    
    public static String formatDate(DateTime dateValue) {
        return formatDateTime(dateValue, DEFAULT_DATE_FORMAT);
    }
    
    public static String formatDate(DateTime dateValue, String dateFormat) {
        return dateValue!=null ? dateValue.format(dateFormat) : '';
    }
    
    public static DateTime parseDateTime(String dateTimeString) {
        return parseDateTime(dateTimeString, 'PST');
    }
    
    public static DateTime parseDateTimeGmt(String dateTimeString) {
        return parseDateTime(dateTimeString, 'GMT');
    }
    
    public static DateTime parseDateTime(String dateTimeString, String timeZoneName) {
        DateTime result = String.isNotBlank(dateTimeString) ? DateTime.valueOfGmt(dateTimeString) : null;
        return result!=null ? result.addSeconds(-TimeZone.getTimeZone(timeZoneName).getOffset(result)/1000) : null;
    }
    
    
    
    public class ExceptionInfo {
        public String stackTrace;
        public String typeName;
        public String cause; 
        public Integer lineNumber;
        public String message;
         
        public ExceptionInfo(Exception ex) {
            Exception cEx = ex.getCause();
            
            stackTrace  = ex.getStackTraceString();
            typeName    = ex.getTypeName();
            cause       = cEx!=null ? cEx.getMessage() : '';
            lineNumber  = ex.getLineNumber();
            message     = ex.getMessage();
        }
    }
}