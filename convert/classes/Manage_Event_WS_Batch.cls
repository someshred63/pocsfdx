/******************************************************************************************
*  @author: Tomasz Kosecki, Roche (contractor)
*  @email: tomasz.kosecki@contractors.roche.com
*  Created: 2017-03-31
*  Project: SFA
*  Description: Batch class used to create/update events
*******************************************************************************************/
global class Manage_Event_WS_Batch implements Database.Batchable<New_Event_Creation_WS.New_Event>, Database.Stateful, Database.AllowsCallouts {
	
	List<New_Event_Creation_WS.New_Event> events;
	private String batchId;	
	private String userName;
	public static final String MESSAGE_CODE_SUCCESS = 'SUCCESS';

	private Set<String> attendeeIds = new Set<String>();
	
	global Manage_Event_WS_Batch(List<New_Event_Creation_WS.New_Event> events, String userName) {
		this.events = events;
		this.userName = userName;
	}
	
	global Iterable<New_Event_Creation_WS.New_Event> start(Database.BatchableContext BC) {
		return events;
	}

   	global void execute(Database.BatchableContext BC, List<New_Event_Creation_WS.New_Event> scope) {
   		batchId = String.valueOf(bc.getJobId()) + '-' + String.valueOf(Datetime.now().getTime());
		
		List<Error_Log_gne__c> errList = new List<Error_Log_gne__c>();
		for (New_Event_Creation_WS.New_Event evt : scope) {
    		try {
    			New_Event_Creation_WS.futureSupported = false;        
	            New_Event_Creation_WS.Messages msg = New_Event_Creation_WS.create_new_event(evt);
	            attendeeIds.addAll(New_Event_Creation_WS.attendeeIds);	            	            

	            if (msg.Status != MESSAGE_CODE_SUCCESS) {
	            	errList.add(logError(msg.message, 'execute', evt.source_system_id));                
	            }
	         } catch(Exception ex) {
		    	logError(ex.getMessage(), 'execute', evt.source_system_id);
		    }
        }
        if (errList.size() > 0) {
        	insert errList;
        }	   
	}
	
	global void finish(Database.BatchableContext BC) {		
		New_Event_Creation_WS.afterCreation(attendeeIds);

		sendNotificationEmail(String.valueOf(bc.getJobId()));
	}

	/*
		Prepare err log record
	*/
	private Error_Log_gne__c logError(String message, String method, String recordId) {
		Error_Log_gne__c err = new Error_Log_gne__c();
		err.Code_Type__c = 'Apex Batch Class';
		err.Error_Level_gne__c = 'Low';
		err.Error_Description__c = message;
		err.Object_Name__c = 'New_Event_Creation_WS.New_Event';
		err.Record_Id_gne__c = recordId;
		err.Snippet_Name__c = 'Manage_Event_WS_Batch.' + method + '.batchId-' + batchId;
		err.User_Name__c = userName;
		return err;
	}

	public void sendNotificationEmail(String batchId) {
		List<Manage_Event_WS.EventError> errors = Manage_Event_WS.getErrors(batchId);
        List<GNE_SFA2_Manage_Event_WS_Notification__c> notifications = GNE_SFA2_Manage_Event_WS_Notification__c.getall().values();        
        List<String> userNames = new List<String>();
        for (GNE_SFA2_Manage_Event_WS_Notification__c notif : notifications) {
            if (notif.Is_Active__c) {
                userNames.add(notif.Username__c);
            }
        }
        
        String subject = getNotificationEmailSubject(batchId);
        String body = getNotificationEmailBody(batchId, errors);

        if (userNames.size() > 0) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            List<User> users = [SELECT Id FROM User WHERE UserName in :userNames];
            
            for(User u : users){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(u.Id);
               	email.setSubject(subject);
        		email.setHtmlBody(body);
        		email.setSaveAsActivity(false);
                emails.add(email);
            }
            if(emails.size()>0){
                Messaging.sendEmail(emails);
            }
        }
	    
    }

    private String getNotificationEmailBody(String batchId, List<Manage_Event_WS.EventError> errors) {
    	String result = '';
    	if (errors != null && errors.size() > 0) {
	    	result = 'Manage Event WS batch id ' + batchId + ' reported following errors:<br />';
	    	result += '<ul>';
	    	for (Manage_Event_WS.EventError err : errors) {
	    		result += '<li>Event id ' + err.source_system_id + ': ' + err.message + '</li>';
	    	}
	    	result +='</ul>';
	    } else {
	    	result = 'Manage Event WS batch id ' + batchId + ' completed successfully';
	    }
    	return result;
    }

    private String getNotificationEmailSubject(String batchId) {
    	return 'Manage Event WS Notifiaction batch id ' + batchId;
    }
	
}