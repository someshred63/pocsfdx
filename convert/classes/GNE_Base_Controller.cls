//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Base_Controller
//   PURPOSE: Base controller class 
// 
//     OWNER: 
//   CREATED: 05/2010
//--------------------------------------------------------------------------------
Public abstract Class GNE_Base_Controller
{  
    //----------------------------------------- ATTRIBUTES ---------------------------
    public String ClassName { get; set;}
    public Boolean IsTestCase { get; set;}

    // Remote Mode
    public Boolean isRemoteMode {get; set;}
    public String remoteMessage {get; set;}

    public void handleError(String className, String method, Exception ex) {
        showMessage( className + ':' + method + ':' + ex);
        ApexPages.addMessages(ex);
        writeErrorLog (null,'Error_Log_gne__c', 'GNE_Base_Controller', ex); 
    }

    public void showMessage(String message) {
        if(isRemoteMode == null || !isRemoteMode) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, message);
        ApexPages.addMessage( myMsg);
        } else {
            remoteMessage = message;
        }
    }

    public void showError(String message) {
        if(isRemoteMode == null || !isRemoteMode) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, message);
        ApexPages.addMessage( myMsg);
        } else {
            remoteMessage = message;
        }
    }        


    //----------------------------------------- LOG METHODS ---------------------------
    public void handleError(String method, Exception ex)
    {    	    	
        System.debug( method + ':' + ex);
    }

    //----------------------------------------- LOG METHODS ---------------------------
    public void debug(String message)
    {
       System.debug( className + ':' +  message);
    } 

    public void logMethod(String methodName)
    {
         System.debug( className + ':' +  methodName);
    }

    public void log(String message)
    {
         System.debug( className + ':' + 'e_out:' + message);
    }
    
    static final String UNABLE_TO_LOG_ERROR  = 'Unable to log error';
    public static void  writeErrorLog (String parentRecordId,
                                       String objectName,
                                       String className, 
                                       Exception exceptionRecord) {               
        try {
        	   Error_log_gne__c errorLog     = new Error_log_gne__c();
        	   errorLog.error_level_gne__c   = 'High';
        	   errorLog.object_name__c       = objectName;
        	   errorLog.code_type__c         = 'Apex Class';
        	   errorLog.snippet_name__c      = className;
        	   errorLog.error_description__c = 'Parent Record Id / Exception Recorded: ' + 
        	                                   parentRecordId + '/' + exceptionRecord.getMessage();        	   
        	   insert errorLog;        	
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 
                          UNABLE_TO_LOG_ERROR + ' ( ' + 
                          exceptionRecord.getMessage() + '). ' + 
                          'writeErrorLog exception --> ' + e.getMessage() );	
        }
	}  
    
    //----------------------------------------- VALIDATION METHODS ---------------------------
    /*	
    public Boolean isEmailValid(String email)
    {
        Boolean valid = false;             
        Pattern cpattern = Pattern.compile('^[a-zA-Z0-9\\._-]+@[a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,4}$');
        Matcher cmatcher = cpattern.matcher(email);                     
        if (email != null && email.length() > 0) valid = cmatcher.matches();             
        return valid;
    }
	
    public Boolean isSsnValid(String ssn)
    {
        Boolean valid = false;             
        Pattern cpattern = Pattern.compile('^[0-9]{3}-[0-9]{2}-[0-9]{4}$');
        Matcher cmatcher = cpattern.matcher(ssn);                     
        if (ssn != null && ssn.length() > 0) valid = cmatcher.matches();             
        return valid;
    }
	
    public Boolean isStateValid(String state)
    {
        Boolean valid = false;             
        Pattern cpattern = Pattern.compile('^(AK|AL|AR|AZ|CA|CO|CT|DC|DE|FL|GA|HI|IA|ID|IL|IN|KS|KY|LA|MA|MD|ME|MI|MN|MO|MS|MT|NB|NC|ND|NH|NJ|NM|NV|NY|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VA|VT|WA|WI|WV|WY)$');
        Matcher cmatcher = cpattern.matcher(state);                     
        if (state !=  null && state.length() > 0) valid = cmatcher.matches();             
        return valid;
    }
	
    public Boolean isPhoneValid(String pNum)
    {
        Boolean valid = false;             
		Pattern phPattern = Pattern.compile('[\\(\\)-]');		
		String tempPh = phPattern.matcher(pNum).replaceAll('');
		tempPh = tempPh.replaceAll(' ', '');		
		if(tempPh.length() == 10) valid = true;                             
        return valid;
    }
	
    public Boolean isDobValid(Date dob)
    {
        Boolean valid = false;         
        if(dob <= System.today()) valid = true;         
        return valid;
    }	
	
    public Boolean isDateRangeValid(Date startDate, Date endDate)
    {
        Boolean valid = false;         
        if(startDate <= endDate) valid = true;         
        return valid;
    }*/
    
    public Boolean isZipValid(String zip)
    {
        Boolean valid = false;             
        Pattern cpattern = Pattern.compile('^[0-9]{5}$|^[0-9]{5}-[0-9]{4}$');
        Matcher cmatcher = cpattern.matcher(zip);                     
        if (zip != null && zip.length() > 0) valid = cmatcher.matches();             
        return valid;
    }
    
    public Boolean isNullOrEmpty(String value)
    {
        return value == null || value == '';
    }	
      
    /**
	 * Sorts a list of SelectOptions
	 * @param List<SelectOption> the SelectOption list to sort 
	 * @param Integer the row to start with
	 * @param Integer the row to end with
	 * @return void
	 */
    public static void sortSelectOptions(List<SelectOption> a, Integer lo0, Integer hi0) {
        Integer lo = lo0;
        Integer hi = hi0;
        
        if (lo >= hi) {
            return;
        } else if( lo == hi - 1 ) {
        
            if (a[lo].getLabel() > a[hi].getLabel()) {
                SelectOption o = a[lo];
                a[lo]         = a[hi];
                a[hi]         = o;
            }
            return;
        }
        SelectOption pivot = a[(lo + hi) / 2];
        a[(lo + hi) / 2] = a[hi];
        a[hi] = pivot;
        while( lo < hi ) {
            while (a[lo].getLabel() <= pivot.getLabel() && lo < hi) { lo++; }
            while (pivot.getLabel() <= a[hi].getLabel() && lo < hi ) { hi--; }
            
            if( lo < hi ){
                SelectOption o = a[lo];
                a[lo]         = a[hi];
                a[hi]         = o;
            }
        }
        
        a[hi0] = a[hi];
        a[hi] = pivot;
        
        sortSelectOptions(a, lo0, lo-1);
        sortSelectOptions(a, hi+1, hi0);
    }	
}