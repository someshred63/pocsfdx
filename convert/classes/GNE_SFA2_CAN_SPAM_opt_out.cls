/**
*  @author: Lukasz Kozminski, Roche
*  Created: 2016-08-16
 * Rest service to facilitate the delivery from CAN SPAM opt-outs to Salesforce (SFA-2276)
 */
 
@RestResource(urlMapping='/CanSpamOptOut/*')
global with sharing class GNE_SFA2_CAN_SPAM_opt_out {
	
	/*
	Save data (email, type and date) as a record to CAN SPAM Email Opt Out object. Use email as key.
	If an email exists already as a record in the object and the date is > (more recent) than the date on the file => update date.
	
	* @param optOutData - data from CAN SPAM opt-out service 
	*/
	@HttpPost
	global static CamOptOutResponse saveData(List<OptOutData> optOutData) {
		try{
			Map<String, OptOutData> emailToOptOutData = new Map<String, OptOutData>();
			Set<String>emails = new Set<String>();
			for(OptOutData ooData : optOutData) {
				emailToOptOutData.put(getKey(ooData), ooData);
				emails.add(ooData.email);
			}
			
			Map<String, CAN_SPAM_Email_Opt_Out_gne__c> emailToOptOutDataSfdc = new Map<String, CAN_SPAM_Email_Opt_Out_gne__c>();
			 		
			for(List<CAN_SPAM_Email_Opt_Out_gne__c> spamData : [SELECT Id, Email_gne__c, Channel_gne__c, Opt_Out_Date_gne__c
																FROM CAN_SPAM_Email_Opt_Out_gne__c 
																WHERE Email_gne__c IN :emails]){
				for(CAN_SPAM_Email_Opt_Out_gne__c sfdcOoData : spamData){
					emailToOptOutDataSfdc.put(getKey(sfdcOoData), sfdcOoData);
				}
			}
			
			List<CAN_SPAM_Email_Opt_Out_gne__c>recordsToUpsert = new List<CAN_SPAM_Email_Opt_Out_gne__c>();
			for(String key : emailToOptOutData.keySet()){
				OptOutData ooData = emailToOptOutData.get(key);
				if(!emailToOptOutDataSfdc.containsKey(key)){
					recordsToUpsert.add(new CAN_SPAM_Email_Opt_Out_gne__c(Email_gne__c = ooData.email, Channel_gne__c = ooData.type, Opt_Out_Date_gne__c = ooData.optoutdatetime));
				}else if(emailToOptOutDataSfdc.get(key).Opt_Out_Date_gne__c <  ooData.optoutdatetime){
					emailToOptOutDataSfdc.get(key).Opt_Out_Date_gne__c = ooData.optoutdatetime;
					recordsToUpsert.add(emailToOptOutDataSfdc.get(key));
				}
			}
			List<Database.UpsertResult> results = Database.upsert(recordsToUpsert, false);
			return new CamOptOutResponse(results);
		} catch(Exception e){
			return new CamOptOutResponse(e);
		}
	}
	
	private static String getKey(OptOutData ooData) {
		return ooData.email + '#' + ooData.type;
	}
	
	private static String getKey(CAN_SPAM_Email_Opt_Out_gne__c ooData) {
		return ooData.Email_gne__c + '#' + ooData.Channel_gne__c;
	}
	
	global class OptOutData {
		String email;
		String type;
		Datetime optoutdatetime;

		public OptOutData(String email, String type, Datetime optoutdatetime){
			this.email = email;
			this.type = type;
			this.optoutdatetime = optoutdatetime;
		}
	}
	
	    /**
        A base class for all webservice response objects. Contains an operation status and
        some debugging information.
    */
    global class CamOptOutResponse {    
        public Boolean success = false;
        public List<ErrorInfo> errors;	
        public ExceptionInfo ex;
        public Integer recordsInserted {get; private set;}
        public Integer recordsUpdated;
        public Integer errorsCount;
        
        public CamOptOutResponse(List<Database.UpsertResult> results){
        	success = true;
        	recordsInserted = 0;
        	recordsUpdated = 0;
        	errorsCount = 0;
        	errors = new List<ErrorInfo>();
        	for(Database.UpsertResult upsertResult : results){
        		if(upsertResult.isSuccess()){
        			if(upsertResult.isCreated()) {
        				recordsInserted++;
        			}else {
        				recordsUpdated++;
        			}
        		} else {
        			errorsCount++;
        			errors.add(new ErrorInfo(upsertResult.getErrors()));
        		}
        	}
        }
        
        public CamOptOutResponse(Exception e){
        	success = false;
        	ex = new ExceptionInfo(e);
        }
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
        
     public class ErrorInfo {
    	public String message;
    	
    	public ErrorInfo(List<Database.Error> errors){
    		message = errors.get(0).getMessage();
    	}
    }
}