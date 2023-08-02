/******************************************************************************************
*  @author: Tomasz Kosecki, Roche (contractor)
*  @email: tomasz.kosecki@contractors.roche.com
*  Created: 2017-03-31
*  Project: SFA
*  Description: Web service used to create/update events
*******************************************************************************************/
global class Manage_Event_WS {
    
    global class EventError {
        webservice String source_system_id;
        webservice String message;
    }

    global class Messages {
        webservice String status;
        webservice String message;
        webservice EventError[] errors;

        Messages() {            
        }

        Messages(String status, String message) {
            this.status = status;
            this.message = message;
        }

        Messages(String status, String message, EventError[] errors) {
            this.status = status;
            this.message = message;
            this.errors = errors;
        }        
    }

    public static final Integer MAX_EVENTS_SIZE = 200;
    public static final String MESSAGE_CODE_PROCESSING  = 'PROCESSING';    
    public static final String MESSAGE_CODE_ERROR       = 'ERROR';
    public static final String MESSAGE_CODE_FAILURE     = 'FAILURE';
    public static final String MESSAGE_CODE_COMPLETED   = 'COMPLETED';

    webservice static Messages request_events_size () {
        return new Messages(String.valueOf(MAX_EVENTS_SIZE), 'Maximum number of events');
    }

    webservice static Messages create_update_events(List<New_Event_Creation_WS.New_Event> events_list) {
        Messages mesg = new Messages();
        try {
            if (events_list.size() > MAX_EVENTS_SIZE) {
                throw new ManageEventException('Request events size ' + events_list.size() + ' exceeds the acceptable size of ' + MAX_EVENTS_SIZE);              
            }

            Id jobId = Database.executeBatch(new Manage_Event_WS_Batch(events_list, UserInfo.getUserName()), 1);

            mesg = new Messages(MESSAGE_CODE_PROCESSING, String.valueOf(jobId));  
        } catch(Exception ex) {
            EventError err = new EventError();                
            err.message = ex.getMessage();
            mesg = new Messages(MESSAGE_CODE_ERROR, '', (new List<EventError>{err}));
        } 
        return mesg;
    }  

    webservice static Messages request_status(String batch_id) {
        
        if (!Pattern.matches('[a-zA-Z0-9]{18}|[a-zA-Z0-9]{15}', batch_id)) {            
            return new Messages(MESSAGE_CODE_FAILURE,
                                'Batch Id wrong format');
        }

        List<AsyncApexJob> jobs = [select TotalJobItems, JobItemsProcessed, Status from AsyncApexJob WHERE Id = :batch_id limit 1];

        if (jobs.size() == 0) {
            return new Messages(MESSAGE_CODE_FAILURE,
                                'Batch Id not exists');
        }

        Messages msg = new Messages();

        String jobStatus = jobs[0].status.toUpperCase();
        if (jobStatus.equalsIgnoreCase('Queued') || jobStatus.equalsIgnoreCase('Preparing') || jobStatus.equalsIgnoreCase('Processing')) {
            msg.status = MESSAGE_CODE_PROCESSING;  
        } else {
            msg.status = MESSAGE_CODE_COMPLETED;
        }
        
        msg.message = 'Total progress ' + String.valueOf(jobs[0].JobItemsProcessed) + '/' + String.valueOf(jobs[0].TotalJobItems) + 
            '. Batch job status ' + jobs[0].status.toUpperCase();
        msg.errors = getErrors(batch_id);
        
        return msg;
    }
    
    public static List<EventError> getErrors(String batchId) {
        List<EventError> result = null;
        String query = 'select id, Error_Description__c, Record_Id_gne__c from  Error_Log_gne__c ' +
            ' where Snippet_Name__c like \'Manage_Event_WS_Batch.execute.batchId-' + batchId + '-%\'';
        
        List<Error_Log_gne__c> errList = Database.query(query);

        if (errList != null && errList.size() > 0) {
            result = new List<EventError>();
            for (Error_Log_gne__c e : errList) {
                EventError err = new EventError();
                err.source_system_id = e.Record_Id_gne__c;
                err.message = e.Error_Description__c;
                result.add(err);
            }
        }
        return result;
    } 

    public class ManageEventException extends Exception {

    }

}