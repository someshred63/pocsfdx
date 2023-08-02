/************************************************************
*  @author: Lukasz Kozminski, contractors Roche
*  Date: 2016-01-20
*  Description: This is a iphone service for retrieving Notifications
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@RestResource(urlMapping='/iPhoneGetNotifications/*')
global with sharing class iPhone_Get_Notification_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> territories) {
        return iPhone_Commons_gne.buildResponse(
                new NotificationResponseBuilder(), 
                new NotificationDeltaArgs(lastSyncDate, unixId, territories)
        );                              
    } 
    
    private class NotificationDeltaArgs extends iPhone_Commons_gne.DeltaArgs {
		
		public final List<String> territories;
		  
        public NotificationDeltaArgs(String lastSyncDate, String unixId, List<String> territories) {
            this.lastSyncDate = lastSyncDate;
            this.unixId = unixId;
            this.territories = territories;                                                                                                                                                         
        }
	}
	
    class NotificationResponseBuilder implements iPhone_Commons_gne.ResponseBuilder{

    	public iPhone_Commons_gne.RestResponse build(Object args){
	    	DateTime lastSynchronized = iPhone_StringUtil.hasValue(((NotificationDeltaArgs)args).lastSyncDate) ? DateTime.valueofGmt(((NotificationDeltaArgs)args).lastSyncDate) : null;
	    	User user = iPhone_DAO.getUserByExternalId(((NotificationDeltaArgs)args).unixId);
	    	List<NotificationRecord> records = new List<NotificationRecord>();
	    	
	    	for(GNE_SFA2_Notification_Ctrl.Notification notification: GNE_SFA2_Notification_Ctrl.getNotifications(user.Id, ((NotificationDeltaArgs)args).territories, lastSynchronized)){
    			records.add(new NotificationRecord(notification));
	    	}
	        return new DeltaRecordsResponse(records);
    	}
    } 
                    
    class NotificationRecord extends iPhone_Commons_gne.DeltaRecord {
        public String nm;  //(Record_Name_gne__c)
        public String ct;  //(Change_Type_gne__c)
        public String cf;  //(Changed_Field_gne__c)
        public String nv;  //(New_Value_gne__c)
        public String ov;  //(Old_Value_gne__c) 
        public String cd;  //(CreatedDate)
        public String nt;  //(NotificationTerritory)
        public String ds;  //(Description_gne__c)
        public String ar;  //Account_Record_Type_Name_gne__c
        public String ai;  //Account_Id
  
        public NotificationRecord(GNE_SFA2_Notification_Ctrl.Notification notification) {
        	this.ax = 'i';                   
            this.id = iPhone_StringUtil.getString(notification.id);                                              
            this.ct = iPhone_StringUtil.getString(notification.changeType);               
            this.cf = iPhone_StringUtil.getString(notification.changeField);                
            this.nm = iPhone_StringUtil.getString(notification.name);                                          
            this.nv = iPhone_StringUtil.getString(notification.newValue);        
            this.ov = iPhone_StringUtil.getString(notification.oldValue); 
            this.cd = iPhone_StringUtil.getString(notification.createdDate);
            this.nt = iPhone_StringUtil.getString(notification.territory);
            this.ds = iPhone_StringUtil.getString(notification.description);
            this.ar = iPhone_StringUtil.getString(notification.accountRecType);
            this.ai = iPhone_StringUtil.getString(notification.accountId);
        }                       
    }
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse{
    	public final List<DeltaRecord> records;
        
        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}