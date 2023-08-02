public without sharing class OTR_Crash_Email_Stats_Controller {
	
	@RemoteAction
	public static List<OTR_Crash_gne__c>  getCrashes(){
		return [SELECT name, createddate,crash_date__c, version__c, iOS_Version__c, hardware_model__c, profile__c, user__c, crash_gmt_date__c, unixId__c FROM OTR_Crash_gne__c ORDER BY CreatedDate DESC LIMIT 10000];
	}
	
	@RemoteAction
	public static ResultWrapper getCrashesInRange(DateWrapper range){
		DateTime dFrom, dTo;
		String message = '';
		
		List<String> queryFields = new List<String>{
			'Name', 
			'CreatedDate',
			String.valueOf(OTR_Crash_gne__c.Crash_Date__c), 
			String.valueOf(OTR_Crash_gne__c.Version__c), 
			String.valueOf(OTR_Crash_gne__c.iOS_Version__c), 
			String.valueOf(OTR_Crash_gne__c.Hardware_Model__c), 
			String.valueOf(OTR_Crash_gne__c.Profile__c), 
			String.valueOf(OTR_Crash_gne__c.User__c), 
			String.valueOf(OTR_Crash_gne__c.Crash_GMT_Date__c), 
			String.valueOf(OTR_Crash_gne__c.UnixId__c)
		};
		
		String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM OTR_Crash_gne__c ';		
		String whereCondition = '';
		
		if(String.isNotBlank(range.dateFrom)){
			dFrom = DateTime.valueOfGmt(range.dateFrom);
			whereCondition = 'WHERE Crash_GMT_Date__c >= :dFrom';
		}
		if(String.isNotBlank(range.dateTo)){
			dTo = DateTime.valueOfgmt(range.dateTo);				
			if (String.isBlank(whereCondition)){
				whereCondition = 'WHERE ';
			} else {
				whereCondition += ' AND ';
			}
			whereCondition += 'Crash_GMT_Date__c <= :dTo';
		}
		if (String.isNotBlank(whereCondition)){
			query += whereCondition;
		}
						
		if(dFrom != null && dTo != null && dFrom > dTo){
			message = 'Date range must be valid!';
		}
		query += ' ORDER BY Crash_GMT_Date__c DESC LIMIT 10000';
		List<OTR_Crash_gne__c> crashList = Database.query(query);
		return new ResultWrapper(crashList, message);
	}
	
	public class DateWrapper{
		public String dateFrom {get;set;}
		public String dateTo {get; set;}
		
		public DateWrapper(String dateFrom, String dateTo){
			this.dateFrom = datefrom;
			this.dateTo = dateTo;
		}
	}
	
	public class ResultWrapper{
		public List<OTR_Crash_gne__c> crashList {get; set;}
		public String message {get; set;}
			
		public ResultWrapper(List<OTR_Crash_gne__c> crashList, String message){
			this.crashList = crashList;
			this.message = message;
		}
	}
}